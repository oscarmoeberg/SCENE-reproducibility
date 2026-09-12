# file scene/model.py

import torch
import torch.nn as nn
import torch.nn.functional as F
from .initialization import laplacian_init

class SCENE(nn.Module):
    """
    SCENE with any number of hierarchical batch effects.

    Args
    ----
    num_cells, num_genes, latent_dim : int
    batch_cfg : Ordered dict
        {level_name: num_batches_at_that_level, ...}
        The order (outer→inner) is the hierarchy.
    """
    def __init__(self,
                num_cells,
                num_genes,
                latent_dim,
                batch_cfg=None,
                variant="lowrank",    # "full" | "lowrank" | "none"
                rank=2,
                cell_init="random",
                gene_init="random",
                B=None,
                RE=True,
                device="cpu"):
        
        super().__init__()
        self.device   = device
        self.variant  = variant
        self.RE       = RE
        self.rank     = rank
        self.lgamma   = None

        self.batch_levels = list(batch_cfg.keys()) if batch_cfg else []
        if isinstance(variant, (list, tuple)):
            if len(variant) != len(self.batch_levels):
                raise ValueError(
                    f"variant list length ({len(variant)}) must match "
                    f"number of batch levels ({len(self.batch_levels)})")
            self.variant_levels = list(variant)
        else:
            self.variant_levels = [variant] * len(self.batch_levels)

        # latent positions ---------------------------------------------------
        if cell_init == "laplacian":
            Zc, Zg = laplacian_init(B, latent_dim)
            self.Z_cells = nn.Parameter(torch.from_numpy(Zc).float())
            if gene_init == "laplacian":
                print("---- Init Strategy: Fixed Cells + Fixed Spectral Genes ----")
                self.Z_genes = nn.Parameter(torch.from_numpy(Zg).float())
            else:
                print("---- Init Strategy: Fixed Cells + Random Genes ----")
                self.Z_genes = nn.Parameter(torch.randn(num_genes, latent_dim))
        else:
            self.Z_cells = nn.Parameter(torch.randn(num_cells, latent_dim))
            self.Z_genes = nn.Parameter(torch.randn(num_genes, latent_dim))
        

        # random effects ----------------------------------
        self.raw_alpha = nn.Parameter(torch.log(torch.expm1(torch.tensor(1.0))))
        self.re_cells = nn.Parameter(torch.randn(num_cells, 1) * 0.01)
        self.re_genes = nn.Parameter(torch.randn(num_genes, 1) * 0.01)

        # hierarchical batch effects -----------------------------------------
        self.gamma_levels = []                 # keep meta‑info only
        self.U_levels     = nn.ParameterList() # low‑rank left factors
        self.V_levels     = nn.ParameterList() # low‑rank right factors

        for lvl, n_batches in enumerate((batch_cfg or {}).values()):
            vtype = self.variant_levels[lvl]   # per‑level choice

            if vtype == "full":
                GxB = nn.Parameter(torch.zeros(num_genes, n_batches))
                self.gamma_levels.append(("full", len(self.U_levels)))
                self.U_levels.append(GxB)
                self.V_levels.append(None)

            elif vtype == "lowrank":
                U = nn.Parameter(torch.randn(n_batches, self.rank) * 0.01)
                V = nn.Parameter(torch.randn(num_genes,  self.rank) * 0.01)
                self.gamma_levels.append(("lowrank", len(self.U_levels)))
                self.U_levels.append(U)
                self.V_levels.append(V)

            elif vtype == "none":
                self.gamma_levels.append(("none", None))
                self.U_levels.append(None)
                self.V_levels.append(None)

            else:
                raise ValueError(f"Unknown variant at level {lvl}: {vtype}")
            
    @property
    def alpha(self):
        return F.softplus(self.raw_alpha)

    def forward(
        self,
        batch_ids_per_level=None,
        use_random_effects=True,
        use_batch_effects=True,
    ):

        # base random-effects matrix
        if use_random_effects:
            re_mat = self.re_cells + self.re_genes.T
        else:
            re_mat = torch.zeros(
                (self.Z_cells.shape[0], self.Z_genes.shape[0]),
                dtype=self.Z_cells.dtype,
                device=self.Z_cells.device,
            )

        # --- add hierarchical batch terms ------------------------------------
        if use_batch_effects and batch_ids_per_level is not None:
            for lvl, meta in enumerate(self.gamma_levels):
                if lvl >= len(batch_ids_per_level):
                    continue
                ids = batch_ids_per_level[lvl]
                if ids is None:
                    continue

                tag, idx = meta

                if tag == "none":
                    continue
                elif tag == "full":
                    gamma = self.U_levels[idx] # the full G×B tensor
                    re_mat = re_mat + gamma[:, ids].T

                elif tag == "lowrank":
                    U = self.U_levels[idx]
                    V = self.V_levels[idx]
                    re_mat = re_mat + (U[ids] @ V.T)

                else:
                    raise ValueError(f"Unknown batch interaction tag at level {lvl}: {tag}")

        # calculate λ and π from the distance matrix
        dist = torch.cdist(self.Z_cells, self.Z_genes, p=2)

        diff = re_mat - dist
        _lambda = torch.exp(diff)
        pi = torch.sigmoid(self.alpha*diff)

        return _lambda, pi

    def forward_edges(
        self,
        cell_indices,
        gene_indices,
        batch_ids_per_level=None,
        use_random_effects=True,
        use_batch_effects=True,
    ):
        """
        Compute lambda and pi only for requested cell-gene pairs.
        """
        cell_indices = cell_indices.to(device=self.Z_cells.device, dtype=torch.long)
        gene_indices = gene_indices.to(device=self.Z_cells.device, dtype=torch.long)

        if cell_indices.shape != gene_indices.shape:
            raise ValueError("cell_indices and gene_indices must have the same shape")

        if use_random_effects:
            re_vals = self.re_cells[cell_indices, 0] + self.re_genes[gene_indices, 0]
        else:
            re_vals = torch.zeros(
                cell_indices.shape,
                dtype=self.Z_cells.dtype,
                device=self.Z_cells.device,
            )

        if use_batch_effects and batch_ids_per_level is not None:
            for lvl, meta in enumerate(self.gamma_levels):
                if lvl >= len(batch_ids_per_level):
                    continue
                ids = batch_ids_per_level[lvl]
                if ids is None:
                    continue

                tag, idx = meta
                if tag == "none":
                    continue
                elif tag == "full":
                    gamma = self.U_levels[idx]
                    edge_batch_ids = ids[cell_indices]
                    re_vals = re_vals + gamma[gene_indices, edge_batch_ids]
                elif tag == "lowrank":
                    U = self.U_levels[idx]
                    V = self.V_levels[idx]
                    edge_batch_ids = ids[cell_indices]
                    re_vals = re_vals + (U[edge_batch_ids] * V[gene_indices]).sum(dim=1)
                else:
                    raise ValueError(f"Unknown batch interaction tag at level {lvl}: {tag}")

        dist = torch.linalg.norm(
            self.Z_cells[cell_indices] - self.Z_genes[gene_indices],
            dim=1,
        )
        diff = re_vals - dist
        _lambda = torch.exp(diff)
        pi = torch.sigmoid(self.alpha * diff)

        return _lambda, pi

    def forward_cell_block(
        self,
        cell_indices,
        batch_ids_per_level=None,
        use_random_effects=True,
        use_batch_effects=True,
    ):
        """
        Compute dense lambda and pi for selected cells against all genes.
        """
        cell_indices = cell_indices.to(device=self.Z_cells.device, dtype=torch.long)

        if use_random_effects:
            re_mat = self.re_cells[cell_indices] + self.re_genes.T
        else:
            re_mat = torch.zeros(
                (cell_indices.shape[0], self.Z_genes.shape[0]),
                dtype=self.Z_cells.dtype,
                device=self.Z_cells.device,
            )

        if use_batch_effects and batch_ids_per_level is not None:
            for lvl, meta in enumerate(self.gamma_levels):
                if lvl >= len(batch_ids_per_level):
                    continue
                ids = batch_ids_per_level[lvl]
                if ids is None:
                    continue

                tag, idx = meta

                if tag == "none":
                    continue
                elif tag == "full":
                    gamma = self.U_levels[idx]
                    block_batch_ids = ids[cell_indices]
                    re_mat = re_mat + gamma[:, block_batch_ids].T
                elif tag == "lowrank":
                    U = self.U_levels[idx]
                    V = self.V_levels[idx]
                    block_batch_ids = ids[cell_indices]
                    re_mat = re_mat + (U[block_batch_ids] @ V.T)
                else:
                    raise ValueError(f"Unknown batch interaction tag at level {lvl}: {tag}")

        dist = torch.cdist(self.Z_cells[cell_indices], self.Z_genes, p=2)
        diff = re_mat - dist
        _lambda = torch.exp(diff)
        pi = torch.sigmoid(self.alpha * diff)

        return _lambda, pi

    def compute_loss(
        self,
        lambda_matrix,
        pi_matrix,
        count_values,
        count_indices,
        loss_type="zip",
    ):
        loss_type = loss_type.lower()

        if loss_type == "zip":
            return self._zip_nll(
                lambda_matrix=lambda_matrix,
                pi_matrix=pi_matrix,
                count_values=count_values,
                count_indices=count_indices,
            )
        if loss_type == "poisson":
            return self._poisson_nll(
                lambda_matrix=lambda_matrix,
                count_values=count_values,
                count_indices=count_indices,
            )

        raise ValueError("loss_type must be one of {'zip', 'poisson'}")

    def compute_cell_block_loss(
        self,
        lambda_block,
        pi_block,
        count_values,
        count_indices,
        n_total,
        loss_type="zip",
        block_weight=1.0,
    ):
        loss_type = loss_type.lower()

        if loss_type == "zip":
            return self._zip_block_nll(
                lambda_block=lambda_block,
                pi_block=pi_block,
                count_values=count_values,
                count_indices=count_indices,
                n_total=n_total,
                block_weight=block_weight,
            )
        if loss_type == "poisson":
            return self._poisson_block_nll(
                lambda_block=lambda_block,
                count_values=count_values,
                count_indices=count_indices,
                n_total=n_total,
                block_weight=block_weight,
            )

        raise ValueError("loss_type must be one of {'zip', 'poisson'}")

    def _zip_block_nll(
        self,
        lambda_block,
        pi_block,
        count_values,
        count_indices,
        n_total,
        block_weight=1.0,
    ):
        epsilon = 1e-10

        positive_log_likelihood = lambda_block.new_tensor(0.0)
        positive_zero_log_likelihood = lambda_block.new_tensor(0.0)
        if count_values.numel() > 0:
            lambda_vals = lambda_block[count_indices[0], count_indices[1]]
            pi_vals_nonzero = pi_block[count_indices[0], count_indices[1]]
            log_expm1 = lambda_vals + torch.log(-torch.expm1(-lambda_vals) + epsilon)

            positive_log_likelihood = (
                torch.log(pi_vals_nonzero + epsilon)
                + count_values * torch.log(lambda_vals + epsilon)
                - torch.lgamma(count_values + 1)
                - log_expm1
            ).sum()
            positive_zero_log_likelihood = torch.log(1 - pi_vals_nonzero + epsilon).sum()

        zero_log_likelihood = torch.log(1 - pi_block + epsilon).sum() - positive_zero_log_likelihood
        total_log_likelihood = (positive_log_likelihood + zero_log_likelihood) * block_weight

        nll = -total_log_likelihood
        mean_nll = nll / n_total

        return nll, mean_nll

    def _poisson_block_nll(
        self,
        lambda_block,
        count_values,
        count_indices,
        n_total,
        block_weight=1.0,
    ):
        eps = torch.finfo(lambda_block.dtype).eps

        positive_log_likelihood = lambda_block.new_tensor(0.0)
        if count_values.numel() > 0:
            lambda_vals = lambda_block[count_indices[0], count_indices[1]].clamp_min(eps)
            positive_log_likelihood = (
                count_values * torch.log(lambda_vals)
                - torch.lgamma(count_values + 1)
            ).sum()

        total_log_likelihood = (positive_log_likelihood - lambda_block.sum()) * block_weight
        nll = -total_log_likelihood
        mean_nll = nll / n_total

        return nll, mean_nll

    def _zip_nll(self, lambda_matrix, pi_matrix, count_values, count_indices):
        """
        Compute the strict Zero-Inflated Poisson log-likelihood where:
        - Zeros are generated only from the Bernoulli process (with probability pi).
        - Positive values are generated only from the Poisson process (with rate lambda).

        Args:
            count_values (torch.Tensor): Observed non-zero count data.
            count_indices (torch.Tensor): Indices of the non-zero counts.
            zero_indices (torch.Tensor): Indices of the zero counts.
            lambda_matrix (torch.Tensor): Poisson rate parameters (dense matrix, shape: num_cells x num_genes).
            pi_matrix (torch.Tensor): Zero-inflation probabilities (dense matrix, shape: num_cells x num_genes).

        Returns:
            torch.Tensor: Total log-likelihood of the observed data.
        """
        epsilon = 1e-10  # Small value to avoid log(0)

        # --- Non-zero count likelihood ---
        # Extract the lambda and pi values corresponding to positive counts
        lambda_vals = lambda_matrix[count_indices[0], count_indices[1]]
        pi_vals_nonzero = pi_matrix[count_indices[0], count_indices[1]]

        if self.lgamma is None:
            self.lgamma = torch.lgamma(count_values + 1)

        log_expm1 = lambda_vals + torch.log(-torch.expm1(-lambda_vals) + epsilon)

        log_likelihood_nonzero = (
            torch.log(pi_vals_nonzero + epsilon)
            + count_values * torch.log(lambda_vals + epsilon)
            - torch.lgamma(count_values + 1)
            - log_expm1
        )

        # Sum the log-likelihood for all non-zero counts
        observed_log_likelihood = log_likelihood_nonzero.sum()

        # # --- Zero count likelihood ---
        log_one_minus_pi = torch.log(1 - pi_matrix + epsilon)
        total_zero_log_likelihood = log_one_minus_pi.sum()
        log_one_minus_pi_non_zero = torch.log(1 - pi_vals_nonzero + epsilon).sum()
        
        # Subtract the contributions from non-zero counts i.e. the complement
        zero_log_likelihood = total_zero_log_likelihood - log_one_minus_pi_non_zero

        # --- Total log-likelihood ---
        total_loss = observed_log_likelihood + zero_log_likelihood
        n_total = lambda_matrix.numel()
        mean_nll_all = -total_loss / n_total
        
        return -total_loss, mean_nll_all
    
    
    def _poisson_nll(
        self,
        lambda_matrix,
        count_values,
        count_indices,
    ):
        """
        Compute the full Poisson negative log-likelihood using a dense lambda matrix
        and sparse observed nonzero counts.

        Model:
            x_ij ~ Poisson(lambda_ij)

        Full log-likelihood:
            sum_ij [x_ij log(lambda_ij) - lambda_ij - log(x_ij!)]

        Since only nonzero counts are stored, this is computed as:
            sum_{x_ij > 0} [x_ij log(lambda_ij) - log(x_ij!)]
            - sum_{all i,j} lambda_ij
        """

        eps = torch.finfo(lambda_matrix.dtype).eps

        lambda_vals = lambda_matrix[count_indices[0], count_indices[1]].clamp_min(eps)

        positive_log_likelihood = (
            count_values * torch.log(lambda_vals)
            - torch.lgamma(count_values + 1)
        ).sum()

        rate_penalty = lambda_matrix.sum()

        total_log_likelihood = positive_log_likelihood - rate_penalty

        n_total = lambda_matrix.numel()
        nll = -total_log_likelihood
        mean_nll = nll / n_total

        return nll, mean_nll
