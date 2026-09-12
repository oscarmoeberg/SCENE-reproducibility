# file: scene/train.py

import torch
import numpy as np
import pytorch_lightning as pl
import warnings
from .model import SCENE
import random
from scipy.sparse import csr_matrix
from sklearn.metrics import roc_auc_score, precision_recall_curve, auc, mean_poisson_deviance

def set_seed(seed: int):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    pl.seed_everything(seed, workers=True)

# ---------------------------------------------------------------------- #
# helpers for validation / link‑prediction
# ---------------------------------------------------------------------- #
def _normalize_loss_type(loss_type):
    loss_type = loss_type.lower()
    if loss_type not in {"zip", "poisson"}:
        raise ValueError("loss_type must be one of {'ZIP', 'Poisson'}")
    return loss_type


def _link_score(pi: torch.Tensor, lam: torch.Tensor, score_type: str = "zip_pi") -> torch.Tensor:
    if score_type in {"zip_pi", "zip_nonzero_prob"}:
        return pi
    if score_type == "poisson_nonzero_prob":
        return -torch.expm1(-lam)
    if score_type == "poisson_lambda":
        return lam
    raise ValueError("unknown score_type")


def _resolve_link_score_type(loss_type, pi_only):
    if loss_type == "poisson":
        return "poisson_lambda"
    return "zip_pi" if pi_only else "zip_nonzero_prob"

def _mask_random_observed_entries(M_csr, frac=0.10, seed=0):
    """
    Randomly hold out `frac` of nonzero entries.
    Returns: (train_csr, (vals, rows, cols)) where tuple are held-out triplets.
    """
    import scipy.sparse as sp

    rng = np.random.default_rng(seed)
    M = sp.coo_matrix(M_csr)
    nnz = M.data.shape[0]
    idx = np.arange(nnz)
    rng.shuffle(idx)
    k = int(frac * nnz)

    hold = idx[:k]
    keep = idx[k:]

    train = sp.coo_matrix((M.data[keep], (M.row[keep], M.col[keep])), shape=M.shape).tocsr()
    return train, (M.data[hold], M.row[hold], M.col[hold])


def _validate_integer_input_matrix(X, layer):
    data = X.data
    if data.size == 0:
        return

    if not np.isfinite(data).all():
        raise ValueError(
            "Input matrix contains non-finite values (NaN/Inf). "
            "Please provide a finite integer count matrix."
        )

    rounded = np.round(data)
    is_integer = np.isclose(data, rounded, rtol=0.0, atol=1e-8)
    if is_integer.all():
        return

    bad_idx = np.flatnonzero(~is_integer)
    max_abs_diff = float(np.max(np.abs(data[bad_idx] - rounded[bad_idx])))
    source_name = "adata.X" if layer is None else f"layer='{layer}' (or adata.X fallback)"
    warnings.warn(
        "train_scene expects integer-valued counts. "
        f"Detected {bad_idx.size} non-integer entries in {source_name}; "
        f"max |x-round(x)|={max_abs_diff:.3e}. "
        "Continuing anyway. Select a raw counts layer for training if this is unintended.",
        UserWarning,
        stacklevel=2,
    )


def _sample_negatives(M_csr, n_neg, seed=0, exact_threshold_ratio=0.2):
    """
    Sample negative edges from a sparse matrix.
    """
    rng = np.random.default_rng(seed)
    n_rows, n_cols = M_csr.shape
    nnz = M_csr.nnz
    total = n_rows * n_cols
    available = total - nnz
    if n_neg > available:
        n_neg = available

    # If matrix is dense-ish, switch to exact sampling
    if nnz / total > exact_threshold_ratio:
        # Exact sampling by enumeration
        all_idx = np.arange(total, dtype=np.int64)
        pos_idx = np.ravel_multi_index(M_csr.nonzero(), dims=M_csr.shape)
        mask = np.ones(total, dtype=bool)
        mask[pos_idx] = False
        neg_idx = rng.choice(all_idx[mask], size=n_neg, replace=False)
    else:
        # Approximate sampling with rejection
        neg_idx = []
        pos_set = set(zip(*M_csr.nonzero()))
        while len(neg_idx) < n_neg:
            r = rng.integers(0, n_rows)
            c = rng.integers(0, n_cols)
            if (r, c) not in pos_set:
                neg_idx.append(r * n_cols + c)
                pos_set.add((r, c))
        neg_idx = np.array(neg_idx, dtype=np.int64)

    rows = neg_idx // n_cols
    cols = neg_idx % n_cols
    return rows, cols


def _validate_cell_batch_size(cell_batch_size, n_cells):
    if cell_batch_size is None:
        return None
    if isinstance(cell_batch_size, bool) or not isinstance(cell_batch_size, (int, np.integer)):
        raise ValueError("cell_batch_size must be a positive integer or None")
    cell_batch_size = int(cell_batch_size)
    if cell_batch_size <= 0:
        raise ValueError("cell_batch_size must be a positive integer or None")
    return min(cell_batch_size, n_cells)


def _collect_cell_block_positives(M_csr, cell_ids):
    """
    Collect positive edges for selected cells using local row indices.
    """
    pos_rows = []
    pos_cols = []
    pos_vals = []

    for local_row, cell_id in enumerate(cell_ids):
        start = M_csr.indptr[cell_id]
        end = M_csr.indptr[cell_id + 1]
        n_pos = end - start
        if n_pos == 0:
            continue

        pos_rows.append(np.full(n_pos, local_row, dtype=np.int64))
        pos_cols.append(M_csr.indices[start:end].astype(np.int64, copy=False))
        pos_vals.append(M_csr.data[start:end].astype(np.float32, copy=False))

    if pos_rows:
        return (
            np.concatenate(pos_rows),
            np.concatenate(pos_cols),
            np.concatenate(pos_vals),
        )

    return (
        np.empty(0, dtype=np.int64),
        np.empty(0, dtype=np.int64),
        np.empty(0, dtype=np.float32),
    )


@torch.no_grad()
def _eval_link_pred(
    model,
    batch_ids_per_level,
    pos_e,
    pos_v,
    neg_e,
    score_type="zip_pi",
):
    model.eval()
    pos_lam, pos_pi = model.forward_edges(
        cell_indices=pos_e[0],
        gene_indices=pos_e[1],
        batch_ids_per_level=batch_ids_per_level,
    )
    neg_lam, neg_pi = model.forward_edges(
        cell_indices=neg_e[0],
        gene_indices=neg_e[1],
        batch_ids_per_level=batch_ids_per_level,
    )
    
    pos_scores = _link_score(pos_pi, pos_lam, score_type=score_type)
    neg_scores = _link_score(neg_pi, neg_lam, score_type=score_type)

    y_true   = torch.cat([torch.ones_like(pos_scores), torch.zeros_like(neg_scores)])
    y_score  = torch.cat([pos_scores.cpu(),         neg_scores.cpu()]).numpy()
    y_true   = y_true.cpu().numpy()

    auc_roc = roc_auc_score(y_true, y_score)
    precision, recall, _ = precision_recall_curve(y_true, y_score)
    pr_auc = auc(recall, precision)

    # Mean Poisson deviance on held-out positive entries.
    lambda_vals = pos_lam.detach().cpu().numpy()
    lambda_vals = np.clip(lambda_vals, 1e-12, None)

    # Conditional mean under zero-truncated Poisson: E[X | X > 0]
    pred_vals = lambda_vals / (-np.expm1(-lambda_vals))
    if torch.is_tensor(pos_v):
        pos_v_np = pos_v.detach().cpu().numpy()
    else:
        pos_v_np = np.asarray(pos_v)
    poisson_deviance = mean_poisson_deviance(pos_v_np, pred_vals)

    # --- Compute best f1 ---
    f1 = 2 * precision * recall / (precision + recall + 1e-10)
    best_f = np.max(f1)

    return auc_roc, pr_auc, best_f, poisson_deviance


def _build_batch_tensors(adata, batch_keys, device):
    if batch_keys is None:
        batch_keys = []
    elif isinstance(batch_keys, str):
        batch_keys = [batch_keys]
    else:
        batch_keys = list(batch_keys)

    batch_cfg = {}
    id_tensors = []
    for key in batch_keys:
        if adata.obs[key].dtype.name != "category":
            adata.obs[key] = adata.obs[key].astype("category")
        codes = adata.obs[key].cat.codes.values
        batch_cfg[key] = adata.obs[key].nunique()
        id_tensors.append(torch.tensor(codes, dtype=torch.long, device=device))

    return batch_keys, batch_cfg, id_tensors


def _save_training_outputs(
    adata,
    model,
    out_emb,
    cell_init,
):
    adata.obsm[out_emb] = model.Z_cells.detach().cpu().numpy()
    adata.varm[out_emb] = model.Z_genes.detach().cpu().numpy()
    adata.obs[f"{out_emb}_re_cell"] = model.re_cells.detach().cpu().numpy().ravel()
    adata.var[f"{out_emb}_re_gene"] = model.re_genes.detach().cpu().numpy().ravel()

    batch_effects = {}
    gamma_levels = []
    for lvl, (tag, idx) in enumerate(model.gamma_levels):
        level_key = f"level_{lvl}"
        level_data = {
            "tag": tag,
        }

        if tag == "full":
            level_data["gamma"] = model.U_levels[idx].detach().cpu().numpy()
        elif tag == "lowrank":
            level_data["U"] = model.U_levels[idx].detach().cpu().numpy()
            level_data["V"] = model.V_levels[idx].detach().cpu().numpy()

        batch_effects[level_key] = level_data
        gamma_levels.append({"level": lvl, "tag": tag})

    adata.uns[f"{out_emb}_params"] = {
        "alpha": float(model.alpha.detach().cpu().item()),
        "variant": model.variant,
        "variant_levels": list(model.variant_levels),
        "rank": int(model.rank),
        "batch_levels": list(model.batch_levels),
        "cell_init": cell_init,
        "batch_categories": {
            key: adata.obs[key].astype("category").cat.categories.tolist()
            for key in model.batch_levels
        },
        "gamma_levels": gamma_levels,
    }
    adata.uns[f"{out_emb}_batch_effects"] = batch_effects


@torch.no_grad()
def reconstruct_rates_from_adata(
    adata,
    out_emb="SCENE",
    batch_keys=None,
    chunk_size=None,
    device="cpu",
    return_torch=False,
):
    """
    Reconstruct (_lambda, pi) from parameters saved by train_scene.
    """
    params_key = f"{out_emb}_params"
    be_key = f"{out_emb}_batch_effects"
    re_cell_key = f"{out_emb}_re_cell"
    re_gene_key = f"{out_emb}_re_gene"

    if out_emb not in adata.obsm:
        raise KeyError(f"Missing adata.obsm['{out_emb}']")
    if out_emb not in adata.varm:
        raise KeyError(f"Missing adata.varm['{out_emb}']")
    if re_cell_key not in adata.obs:
        raise KeyError(f"Missing adata.obs['{re_cell_key}']")
    if re_gene_key not in adata.var:
        raise KeyError(f"Missing adata.var['{re_gene_key}']")
    if params_key not in adata.uns:
        raise KeyError(f"Missing adata.uns['{params_key}']")
    if be_key not in adata.uns:
        raise KeyError(f"Missing adata.uns['{be_key}']")

    params = adata.uns[params_key]
    batch_effects = adata.uns[be_key]
    alpha = float(params["alpha"])

    if batch_keys is None:
        batch_keys = list(params.get("batch_levels", []))
    elif isinstance(batch_keys, str):
        batch_keys = [batch_keys]
    else:
        batch_keys = list(batch_keys)

    z_cells = torch.as_tensor(adata.obsm[out_emb], dtype=torch.float32, device=device)
    z_genes = torch.as_tensor(adata.varm[out_emb], dtype=torch.float32, device=device)
    re_cells = torch.as_tensor(
        adata.obs[re_cell_key].to_numpy(), dtype=torch.float32, device=device
    ).unsqueeze(1)
    re_genes = torch.as_tensor(
        adata.var[re_gene_key].to_numpy(), dtype=torch.float32, device=device
    ).unsqueeze(1)

    saved_categories = params.get("batch_categories", {})
    ids_per_level = []
    for key in batch_keys:
        if key not in adata.obs:
            raise KeyError(f"Batch key '{key}' not found in adata.obs")

        series = adata.obs[key]
        if series.dtype.name != "category":
            series = series.astype("category")

        expected = saved_categories.get(key)
        if expected is not None:
            series = series.cat.set_categories(expected)

        ids = torch.as_tensor(series.cat.codes.to_numpy(), dtype=torch.long, device=device)
        if torch.any(ids < 0):
            raise ValueError(
                f"Batch key '{key}' has categories not present in saved training categories."
            )
        ids_per_level.append(ids)

    gamma_levels = params.get("gamma_levels", [])
    if len(batch_keys) != len(gamma_levels):
        raise ValueError(
            f"Expected {len(gamma_levels)} batch keys, got {len(batch_keys)}. "
            f"Use the training keys order: {params.get('batch_levels', [])}"
        )
    preloaded_effects = []
    for lvl, meta in enumerate(gamma_levels):
        tag = meta["tag"]
        level_data = batch_effects.get(f"level_{lvl}", {"tag": tag})

        if tag == "none":
            preloaded_effects.append(("none", None, None))
        elif tag == "full":
            gamma = torch.as_tensor(level_data["gamma"], dtype=torch.float32, device=device)
            preloaded_effects.append(("full", gamma, None))
        elif tag == "lowrank":
            U = torch.as_tensor(level_data["U"], dtype=torch.float32, device=device)
            V = torch.as_tensor(level_data["V"], dtype=torch.float32, device=device)
            preloaded_effects.append(("lowrank", U, V))
        else:
            raise ValueError(f"Unsupported batch interaction tag at level {lvl}: {tag}")

    n_cells = z_cells.shape[0]
    if chunk_size is None or chunk_size <= 0 or chunk_size >= n_cells:
        chunk_size = n_cells

    lambda_chunks = []
    pi_chunks = []

    for start in range(0, n_cells, chunk_size):
        end = min(start + chunk_size, n_cells)

        zc = z_cells[start:end]
        re_mat = re_cells[start:end] + re_genes.T

        for lvl, (tag, e1, e2) in enumerate(preloaded_effects):
            if lvl >= len(ids_per_level):
                break
            ids = ids_per_level[lvl][start:end]

            if tag == "none":
                continue
            elif tag == "full":
                re_mat = re_mat + e1[:, ids].T
            elif tag == "lowrank":
                re_mat = re_mat + e1[ids] @ e2.T

        dist = torch.cdist(zc, z_genes, p=2)
        diff = re_mat - dist

        lambda_chunks.append(torch.exp(diff))
        pi_chunks.append(torch.sigmoid(alpha * diff))

    _lambda = torch.cat(lambda_chunks, dim=0)
    pi = torch.cat(pi_chunks, dim=0)

    if return_torch:
        return _lambda, pi
    return _lambda.cpu().numpy(), pi.cpu().numpy()



def train_scene(
    adata,
    layer="counts",
    latent_dim=16,
    batch_keys=None,
    cell_init="random",
    gene_init="random",
    epochs=600,
    lr=0.05,
    device="cpu",
    seed=42,
    split_seed=None,
    out_emb="SCENE",
    return_model=False,
    validate=False,
    val_frac=0.10, 
    val_interval=10,
    pi_only=True,
    loss_type="ZIP",
    cell_batch_size=None,
    use_lr_scheduler=False,
    **model_kwargs
    ):

    if split_seed is None:
        split_seed = seed

    torch.manual_seed(seed)
    np.random.seed(seed)
    loss_type = _normalize_loss_type(loss_type)
    link_score_type = _resolve_link_score_type(loss_type=loss_type, pi_only=pi_only)

    X_full = csr_matrix(adata.layers.get(layer, adata.X))
    _validate_integer_input_matrix(X=X_full, layer=layer)
    n_cells, n_genes = adata.n_obs, adata.n_vars
    cell_batch_size = _validate_cell_batch_size(cell_batch_size, n_cells=n_cells)
    val_results = {"epoch": [], "auc": [], "pr_auc": [], "f1": [], "poisson_deviance": []}

    # --- 1) Build Batches --- #
    batch_keys, batch_cfg, id_tensors = _build_batch_tensors(
        adata=adata,
        batch_keys=batch_keys,
        device=device,
    )
    n_batch_levels = len(id_tensors)

    # --- 2) Data Setup --- #
    rows, cols = X_full.nonzero()
    rows_t, cols_t = torch.from_numpy(rows), torch.from_numpy(cols)
    count_idx = torch.stack([rows_t, cols_t], dim=0).to(device)
    values = torch.tensor(X_full.data, dtype=torch.float32, device=device)

    if validate:
        # Split
        X_tr, (val_data, val_r, val_c) = _mask_random_observed_entries(X_full, frac=val_frac, seed=split_seed)

        # Pos val edges/values
        pos_e = torch.tensor(np.stack([val_r, val_c], axis=0), dtype=torch.long, device=device)
        pos_v = torch.tensor(val_data, dtype=torch.float32, device=device)

        # Neg edges: sample against FULL X (train+val positives),
        neg_r, neg_c = _sample_negatives(X_full, n_neg=pos_e.shape[1], seed=split_seed + 1)
        neg_e = torch.tensor(np.stack([neg_r, neg_c], axis=0), dtype=torch.long, device=device)

        # Training data from X_tr
        tr_r, tr_c = X_tr.nonzero()
        count_idx = torch.tensor(np.stack([tr_r, tr_c], axis=0), dtype=torch.long, device=device)
        values = torch.tensor(X_tr.data, dtype=torch.float32, device=device)
    else:
        X_tr = X_full

    # --- 3) Initialize Model --- #
    model = SCENE(
        num_cells   = n_cells,
        num_genes   = n_genes,
        latent_dim  = latent_dim,
        batch_cfg   = batch_cfg,
        cell_init   = cell_init,
        gene_init   = gene_init,
        RE          = True,
        device      = device,
        B           = X_tr if cell_init == "laplacian" else None,
        **model_kwargs
    ).to(device)

    # --- 4) Optimizer --- #
    no_decay = [model.re_cells, model.re_genes, model.raw_alpha]
    z_params = [model.Z_cells, model.Z_genes]
    uv_params = [p for p in model.U_levels if p is not None] + \
                [p for p in model.V_levels if p is not None]

    param_groups = [
        {"params": no_decay, "weight_decay": 0.0},
        {"params": z_params, "weight_decay": 1e-3},
    ]

    if len(uv_params) > 0:
        param_groups.append({"params": uv_params, "weight_decay": 1e-3})

    opt = torch.optim.AdamW(param_groups, lr=lr)
    sched = None
    if use_lr_scheduler:
        sched = torch.optim.lr_scheduler.ReduceLROnPlateau(
            opt,
            mode="min",
            factor=0.5,
            patience=3,
        )

    # --- 5) Training Loop --- #
    for epoch in range(epochs):

        batch_ids_per_level = id_tensors if n_batch_levels > 0 else None
        active_batch_levels = list(range(n_batch_levels))

        if cell_batch_size is None:
            # --- Standard full-matrix step ---
            opt.zero_grad(set_to_none=True)
            _lambda, pi = model(
                batch_ids_per_level=batch_ids_per_level,
                use_random_effects=True,
                use_batch_effects=True,
            )
            
            loss, mean_loss = model.compute_loss(
                _lambda,
                pi,
                count_values=values,
                count_indices=count_idx,
                loss_type=loss_type,
            )

            loss.backward()
            opt.step()
        else:
            rng = np.random.default_rng(seed + epoch)
            cell_order = rng.permutation(n_cells)
            batch_mean_losses = []

            for start in range(0, n_cells, cell_batch_size):
                batch_cells = cell_order[start:start + cell_batch_size]

                opt.zero_grad(set_to_none=True)

                cell_weight = float(n_cells) / float(batch_cells.shape[0])

                batch_pos_r, batch_pos_c, batch_pos_v = _collect_cell_block_positives(
                    X_tr,
                    batch_cells,
                )

                batch_cells_t = torch.tensor(batch_cells, dtype=torch.long, device=device)
                pos_idx_t = torch.tensor(
                    np.stack([batch_pos_r, batch_pos_c], axis=0),
                    dtype=torch.long,
                    device=device,
                )
                pos_v_t = torch.tensor(batch_pos_v, dtype=torch.float32, device=device)

                lambda_block, pi_block = model.forward_cell_block(
                    cell_indices=batch_cells_t,
                    batch_ids_per_level=batch_ids_per_level,
                    use_random_effects=True,
                    use_batch_effects=True,
                )

                loss, mean_loss = model.compute_cell_block_loss(
                    lambda_block=lambda_block,
                    pi_block=pi_block,
                    count_values=pos_v_t,
                    count_indices=pos_idx_t,
                    n_total=n_cells * n_genes,
                    loss_type=loss_type,
                    block_weight=cell_weight,
                )

                loss.backward()
                opt.step()
                batch_mean_losses.append(mean_loss.detach())

            if batch_mean_losses:
                mean_loss = torch.stack(batch_mean_losses).mean()
            else:
                mean_loss = torch.tensor(float("nan"), device=device)

        should_validate = validate and (epoch % val_interval == 0 or epoch == epochs - 1)
        val_metrics = None

        if should_validate:
            auc, pr_auc, f1, poisson_deviance = _eval_link_pred(
                model,
                batch_ids_per_level,
                pos_e,
                pos_v,
                neg_e,
                score_type=link_score_type,
            )
            val_metrics = (auc, pr_auc, f1, poisson_deviance)
            val_results["epoch"].append(epoch)
            val_results["auc"].append(auc)
            val_results["pr_auc"].append(pr_auc)
            val_results["f1"].append(f1)
            val_results["poisson_deviance"].append(poisson_deviance)

            if use_lr_scheduler and epoch >= 30:
                old_lr = opt.param_groups[0]["lr"]
                sched.step(poisson_deviance)
                new_lr = opt.param_groups[0]["lr"]

                if new_lr < old_lr:
                    print(
                        f"Epoch {epoch:4d}: LR reduced from "
                        f"{old_lr:.3e} to {new_lr:.3e}"
                    )
                
        # --- Logging ---
        if epoch % 50 == 0 or epoch == epochs - 1:
            msg = (f"Epoch {epoch:4d} loss={mean_loss.item():.4f}   dim={latent_dim} batch_levels={active_batch_levels}")
            
            if val_metrics is not None:
                auc, pr_auc, f1, poisson_deviance = val_metrics
                msg += (f"   [AUC={auc:.3f} PR_AUC={pr_auc:.3f} F1={f1:.3f}, P_DEV={poisson_deviance:.3f}, alpha={model.alpha.item():.3f}]")
            print(msg)

    # --- 6) Save --- #
    _save_training_outputs(
        adata=adata,
        model=model,
        out_emb=out_emb,
        cell_init=cell_init,
    )

    if return_model:
        return adata, val_results, model
    else:
        return adata, val_results
