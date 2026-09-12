#!/usr/bin/env python3
"""Evaluate clustering of gene modules in latent gene embeddings."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import anndata as ad
import numpy as np
import pandas as pd
from scipy.spatial.distance import cdist, pdist
from statsmodels.stats.multitest import multipletests
from tqdm.auto import tqdm

try:
    from joblib import Parallel, delayed
    from joblib.parallel import BatchCompletionCallBack
except ImportError:  # pragma: no cover - optional dependency
    Parallel = None
    delayed = None
    BatchCompletionCallBack = None


def evaluate_gene_module(
    gene_embeddings: np.ndarray,
    gene_names: np.ndarray,
    manual_set: list[str],
    n_perm: int = 10000,
    rng: np.random.Generator | None = None,
    euclidean: bool = False,
    eval_context: dict | None = None,
) -> dict:
    """
    Evaluate clustering of a manual gene set in latent coordinates.

    Parameters
    ----------
    gene_embeddings : np.ndarray
        Gene latent coordinates, shape (n_genes, n_latent).
    gene_names : np.ndarray
        Gene names aligned to rows of gene_embeddings.
    manual_set : list of str
        List of gene names for the module of interest.
    n_perm : int
        Number of permutations for null distribution.
    rng : np.random.Generator or None
        Random generator. If None, defaults to np.random.default_rng().
    eval_context : dict or None
        Optional precomputed context from _build_eval_context for repeated module evaluation.

    Returns
    -------
    dict with observed scores and p-value.
    """
    if rng is None:
        rng = np.random.default_rng()

    if eval_context is None:
        eval_context = _build_eval_context(
            gene_embeddings=gene_embeddings,
            gene_names=gene_names,
        )

    W = eval_context["gene_embeddings"]
    gene_name_set = eval_context["gene_name_set"]
    gene_to_idx = eval_context["gene_to_idx"]
    all_idx = eval_context["all_idx"]

    manual_set_in = [g for g in manual_set if g in gene_name_set]
    dropped_genes = [g for g in manual_set if g not in manual_set_in]

    if len(manual_set_in) == 0:
        raise ValueError("No genes from manual_set found in gene_names.")

    idx_manual = np.asarray([gene_to_idx[g] for g in manual_set_in], dtype=int)
    idx_rest = all_idx[~np.isin(all_idx, idx_manual)]

    metric = "euclidean" if euclidean else "sqeuclidean"

    def clustering_score(manual_idx: np.ndarray, rest_idx: np.ndarray) -> tuple[float, float]:
        W_manual = W[manual_idx]
        W_rest = W[rest_idx]
        # within-manual
        if len(W_manual) > 1:
            score_within = pdist(W_manual, metric=metric).mean()
        else:
            score_within = np.nan

        # manual vs rest
        score_vs_rest = cdist(W_manual, W_rest, metric=metric).mean()

        return score_within, score_vs_rest

    # observed
    obs_within, obs_vs_rest = clustering_score(idx_manual, idx_rest)
    obs_ratio = obs_within / obs_vs_rest

    # permutation null
    m = idx_manual.shape[0]
    ratios = np.empty(n_perm, dtype=float)

    for i in range(n_perm):
        perm_idx = rng.choice(all_idx, size=m, replace=False)
        rest_idx = all_idx[~np.isin(all_idx, perm_idx)]
        w, r = clustering_score(perm_idx, rest_idx)
        ratios[i] = w / r

    pval = (np.sum(ratios <= obs_ratio) + 1) / (n_perm + 1)

    return {
        "n_manual_genes": len(manual_set),
        "obs_within": obs_within,
        "obs_vs_rest": obs_vs_rest,
        "obs_ratio": obs_ratio,
        "pval": pval,
        "dropped_genes": dropped_genes
    }


def _build_eval_context(
    gene_embeddings: np.ndarray,
    gene_names: np.ndarray,
) -> dict:
    gene_embeddings = np.asarray(gene_embeddings, dtype=float)
    gene_names = np.asarray(gene_names)

    if gene_embeddings.shape[0] != gene_names.shape[0]:
        raise ValueError("gene_embeddings rows must match number of genes in gene_names.")
    gene_to_idx = {g: i for i, g in enumerate(gene_names)}
    all_idx = np.arange(gene_names.shape[0], dtype=int)

    return {
        "gene_embeddings": gene_embeddings,
        "gene_name_set": set(gene_names.tolist()),
        "gene_to_idx": gene_to_idx,
        "all_idx": all_idx,
    }



def compute_module_mean_expression(adata: ad.AnnData, modules: dict[str, list[str]]) -> pd.DataFrame:
    module_expr = {}
    for module_name, genes in modules.items():
        present = [g for g in genes if g in adata.var_names]
        if not present:
            module_expr[module_name] = np.full(adata.n_obs, np.nan, dtype=float)
            continue
        x = adata[:, present].X.mean(axis=1)
        if hasattr(x, "A1"):
            x = x.A1
        else:
            x = np.asarray(x).ravel()
        module_expr[module_name] = x

    module_expr_df = pd.DataFrame(module_expr, index=adata.obs_names)
    mean_scores = module_expr_df.mean(axis=0).rename("mean_expr").reset_index()
    mean_scores.columns = ["module", "mean_expr"]
    return mean_scores


def load_modules(path: str) -> dict[str, list[str]]:
    with open(path, "r", encoding="utf-8") as f:
        modules = json.load(f)
    if not isinstance(modules, dict):
        raise ValueError("Module JSON must be a dict[str, list[str]].")
    for module_name, genes in modules.items():
        if not isinstance(module_name, str):
            raise ValueError("Module JSON keys must be strings.")
        if not isinstance(genes, list) or not all(isinstance(g, str) for g in genes):
            raise ValueError(f"Module '{module_name}' must map to a list of gene-name strings.")
    return modules


def align_external_embedding_to_adata(
    adata: ad.AnnData,
    gene_embeddings: np.ndarray,
    embedding_gene_names: np.ndarray,
) -> tuple[ad.AnnData, np.ndarray]:
    gene_embeddings = np.asarray(gene_embeddings)
    embedding_gene_names = np.asarray(embedding_gene_names).astype(str)

    if gene_embeddings.shape[0] != embedding_gene_names.shape[0]:
        raise ValueError(
            "Embedding rows must match number of genes in --embedding_gene_names_npy."
        )

    if len(pd.unique(embedding_gene_names)) != embedding_gene_names.shape[0]:
        raise ValueError("Duplicate gene names found in --embedding_gene_names_npy.")

    adata_gene_names = adata.var_names.to_numpy().astype(str)
    adata_gene_index = pd.Index(adata_gene_names)
    embedding_gene_index = pd.Index(embedding_gene_names)
    common_gene_names = adata_gene_index.intersection(embedding_gene_index, sort=False)

    if common_gene_names.empty:
        raise ValueError("No overlapping genes between adata.var_names and embedding gene names.")

    if common_gene_names.shape[0] < 2:
        raise ValueError(
            "Need at least two overlapping genes between adata and embedding for evaluation."
        )

    embedding_pos = pd.Series(np.arange(embedding_gene_names.shape[0]), index=embedding_gene_index)
    embedding_idx = embedding_pos.loc[common_gene_names].to_numpy(dtype=int)
    adata = adata[:, common_gene_names.to_numpy()].copy()
    gene_embeddings = gene_embeddings[embedding_idx]

    if gene_embeddings.shape[0] != adata.n_vars:
        raise ValueError("Failed to align embedding rows with adata genes.")

    return adata, gene_embeddings


def _evaluate_module_task(
    module_name: str,
    manual_set: list[str],
    gene_embeddings: np.ndarray,
    gene_names_arr: np.ndarray,
    eval_context: dict,
    n_perm: int,
    euclidean: bool,
    seed: np.random.SeedSequence | np.random.Generator,
) -> dict:
    try:
        result = evaluate_gene_module(
            gene_embeddings=gene_embeddings,
            gene_names=gene_names_arr,
            manual_set=manual_set,
            n_perm=n_perm,
            rng=np.random.default_rng(seed),
            euclidean=euclidean,
            eval_context=eval_context,
        )
    except ValueError as e:
        return {"module": module_name, "skipped": True, "skip_reason": str(e)}

    return {"module": module_name, "skipped": False, **result}


if BatchCompletionCallBack is not None:  # pragma: no cover - progress helper
    class _TqdmBatchCallback(BatchCompletionCallBack):
        tqdm_object = None

        def __call__(self, *args, **kwargs):
            if self.tqdm_object is not None:
                self.tqdm_object.update(n=self.batch_size)
            return super().__call__(*args, **kwargs)


    class tqdm_joblib:  # pragma: no cover - progress helper
        def __init__(self, tqdm_object):
            self.tqdm_object = tqdm_object

        def __enter__(self):
            import joblib.parallel as joblib_parallel

            self._old_callback = joblib_parallel.BatchCompletionCallBack
            _TqdmBatchCallback.tqdm_object = self.tqdm_object
            joblib_parallel.BatchCompletionCallBack = _TqdmBatchCallback
            return self.tqdm_object

        def __exit__(self, exc_type, exc_val, exc_tb):
            import joblib.parallel as joblib_parallel

            joblib_parallel.BatchCompletionCallBack = self._old_callback
            _TqdmBatchCallback.tqdm_object = None
            self.tqdm_object.close()
else:  # pragma: no cover - optional dependency
    class tqdm_joblib:
        def __init__(self, tqdm_object):
            self.tqdm_object = tqdm_object

        def __enter__(self):
            return self.tqdm_object

        def __exit__(self, exc_type, exc_val, exc_tb):
            self.tqdm_object.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Evaluate gene modules in latent embeddings.")
    parser.add_argument("--input_h5ad", type=str, required=True, help="Path to input AnnData .h5ad.")
    parser.add_argument("--embedding_npy",type=str,default=None,help="Path to gene embedding .npy. If not set, use adata.varm[--embedding_key].")
    parser.add_argument("--embedding_gene_names_npy",type=str,default=None,help="Optional gene-name .npy aligned to --embedding_npy rows for name-based alignment.")
    parser.add_argument("--embedding_key",type=str,default="SCENE",help="Key to read gene embeddings from adata.varm when --embedding_npy is not set.",)
    parser.add_argument("--module_json", type=str, required=True, help="Path to JSON file with module definitions (dict[str, list[str]]).")
    parser.add_argument("--output_csv", type=str, required=True, help="Path to output CSV.")
    parser.add_argument("--n_perm", type=int, default=10000, help="Number of permutations.")
    parser.add_argument("--seed", type=int, default=42, help="Seed for permutations.")
    parser.add_argument("--n_jobs", type=int, default=1, help="Number of processes to use.")
    parser.add_argument("--squared_distance",action="store_true",help="Use squared Euclidean distance instead of Euclidean distance.")
    parser.add_argument("--permutation_rng", choices=["independent", "shared"], default="independent",
                        help="Use shared with n_jobs=1 to reproduce the original paper permutations.")
    args = parser.parse_args()
    if args.permutation_rng == "shared" and args.n_jobs != 1:
        parser.error("--permutation_rng shared requires --n_jobs 1")
    output_path = Path(args.output_csv)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.with_suffix(".config.json").write_text(json.dumps(vars(args), indent=2) + "\n")

    adata = ad.read_h5ad(args.input_h5ad)

    if args.embedding_npy is not None:
        gene_embeddings = np.load(args.embedding_npy)
        if args.embedding_gene_names_npy is not None:
            embedding_gene_names = np.load(args.embedding_gene_names_npy, allow_pickle=True)
            adata, gene_embeddings = align_external_embedding_to_adata(
                adata=adata,
                gene_embeddings=gene_embeddings,
                embedding_gene_names=embedding_gene_names,
            )
        elif gene_embeddings.shape[0] != adata.n_vars:
            raise ValueError(
                "Embedding rows must match number of genes in adata.var_names. "
                "If embeddings were trained on a filtered gene set, pass --embedding_gene_names_npy."
            )
    else:
        if args.embedding_key not in adata.varm:
            raise ValueError(f"Embedding key '{args.embedding_key}' not found in adata.varm.")
        gene_embeddings = np.asarray(adata.varm[args.embedding_key])
    if gene_embeddings.shape[0] != adata.n_vars:
        raise ValueError(
            "Embedding rows must match number of genes in adata.var_names."
        )

    modules = load_modules(args.module_json)
    euclidean = not args.squared_distance
    gene_names_arr = adata.var_names.to_numpy()
    eval_context = _build_eval_context(
        gene_embeddings=gene_embeddings,
        gene_names=gene_names_arr,
    )

    module_items = list(modules.items())
    module_seeds = np.random.SeedSequence(args.seed).spawn(len(module_items))
    if args.permutation_rng == "shared":
        module_seeds = [np.random.default_rng(args.seed)] * len(module_items)

    if args.n_jobs == 1:
        rows = []
        for (module_name, manual_set), seed in tqdm(
            zip(module_items, module_seeds),
            total=len(module_items),
            desc="Evaluating gene modules",
        ):
            result = _evaluate_module_task(
                module_name=module_name,
                manual_set=manual_set,
                gene_embeddings=gene_embeddings,
                gene_names_arr=gene_names_arr,
                eval_context=eval_context,
                n_perm=args.n_perm,
                euclidean=euclidean,
                seed=seed,
            )
            if result.pop("skipped"):
                print(f"Skipping module '{module_name}': {result['skip_reason']}")
                continue
            rows.append(result)
    else:
        if Parallel is None or delayed is None:
            raise ImportError(
                "joblib is required for --n_jobs > 1. Install it with `pip install joblib`."
            )

        tasks = (
            delayed(_evaluate_module_task)(
                module_name=module_name,
                manual_set=manual_set,
                gene_embeddings=gene_embeddings,
                gene_names_arr=gene_names_arr,
                eval_context=eval_context,
                n_perm=args.n_perm,
                euclidean=euclidean,
                seed=seed,
            )
            for (module_name, manual_set), seed in zip(module_items, module_seeds)
        )

        with tqdm_joblib(tqdm(total=len(module_items), desc="Evaluating gene modules")):
            rows = Parallel(n_jobs=args.n_jobs, prefer="processes")(tasks)

        skipped = [row for row in rows if row.pop("skipped")]
        for row in skipped:
            print(f"Skipping module '{row['module']}': {row['skip_reason']}")
        rows = [row for row in rows if "skip_reason" not in row]

    results_df = pd.DataFrame(rows)
    if results_df.empty:
        output_path = Path(args.output_csv)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        results_df.to_csv(output_path, index=False)
        print("No modules evaluated successfully; wrote an empty results CSV.")
        return

    pvals = results_df["pval"].astype(float).to_numpy()
    finite = np.isfinite(pvals)
    qvals = np.full_like(pvals, np.nan, dtype=float)
    signif = np.zeros_like(pvals, dtype=bool)
    if finite.any():
        rej, q, _, _ = multipletests(pvals[finite], alpha=0.05, method="fdr_bh")
        qvals[finite] = q
        signif[finite] = rej
    results_df["qval_fdr_bh"] = qvals
    results_df["significant_5pct"] = signif

    mean_expr_df = compute_module_mean_expression(adata, modules)
    results_df = results_df.merge(mean_expr_df, on="module", how="left")

    output_path = Path(args.output_csv)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    results_df.to_csv(output_path, index=False)
    print(f"Saved module evaluation results to: {output_path}")


if __name__ == "__main__":
    main()
