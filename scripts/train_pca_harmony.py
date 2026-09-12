#!/usr/bin/env python3
"""Run PCA +/- Harmony on AnnData and save cell latent representations."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np


def _set_seed(seed: int) -> None:
    np.random.seed(seed)
    try:
        import random

        random.seed(seed)
    except ImportError:
        pass


def _save_embedding(adata, emb_key: str, out_dir: Path) -> dict[str, object]:
    if emb_key not in adata.obsm:
        raise ValueError(f"Embedding key '{emb_key}' not found in adata.obsm.")

    emb = np.asarray(adata.obsm[emb_key])
    if emb.ndim != 2:
        raise ValueError(f"Expected a 2D embedding for '{emb_key}', got shape {emb.shape}.")

    np.save(out_dir / f"{emb_key}_cell_latent.npy", emb)
    np.save(out_dir / f"{emb_key}_cell_names.npy", adata.obs_names.to_numpy(dtype=str))
    return {"key": emb_key, "shape": list(emb.shape)}


def _to_numpy_2d(value, name: str) -> np.ndarray:
    def _as_np(x):
        if hasattr(x, "detach"):
            x = x.detach()
        if hasattr(x, "cpu"):
            x = x.cpu()
        return np.asarray(x)

    arr = _as_np(value)
    if arr.ndim == 2 and arr.dtype != object:
        return arr

    try:
        rows = []
        for row in value:
            row_arr = _as_np(row).ravel()
            rows.append(row_arr)
        if rows:
            row_lens = {r.shape[0] for r in rows}
            if len(row_lens) == 1:
                return np.vstack(rows)
    except TypeError:
        pass

    if arr.ndim == 2:
        return np.asarray(arr, dtype=float)

    raise ValueError(f"Could not coerce '{name}' to a 2D numeric matrix. Got shape {arr.shape}.")


def _normalize_batch_keys(batch_key) -> list[str]:
    if batch_key is None:
        return []
    if isinstance(batch_key, str):
        return [batch_key]
    return list(batch_key)


def _harmony_integrate_safe(
    adata,
    batch_key: str | list[str] | tuple[str, ...],
    pca_key: str = "X_pca",
    out_key: str = "X_pca_harmony",
) -> None:
    import harmonypy as hm

    batch_keys = _normalize_batch_keys(batch_key)
    if not batch_keys:
        raise ValueError("At least one batch key must be provided for Harmony integration.")

    missing_keys = [k for k in batch_keys if k not in adata.obs]
    if missing_keys:
        raise ValueError(
            f"Batch key(s) {missing_keys} not found in adata.obs. "
            f"Available keys: {list(adata.obs.columns)}"
        )
    if pca_key not in adata.obsm:
        raise ValueError(f"PCA key '{pca_key}' not found in adata.obsm.")

    x_pca = np.asarray(adata.obsm[pca_key], dtype=np.float64)
    n_obs, n_pcs = x_pca.shape

    harmony_out = hm.run_harmony(x_pca, adata.obs, batch_keys)
    z_corr = _to_numpy_2d(harmony_out.Z_corr, "harmony_out.Z_corr")

    if z_corr.shape == (n_obs, n_pcs):
        x_harmony = z_corr
    elif z_corr.shape == (n_pcs, n_obs):
        x_harmony = z_corr.T
    else:
        raise ValueError(
            "Unexpected Harmony output shape. "
            f"Got {z_corr.shape}, expected {(n_obs, n_pcs)} or {(n_pcs, n_obs)}."
        )

    adata.obsm[out_key] = np.asarray(x_harmony, dtype=np.float32)


def _pca_harmony_embeddings(
    adata,
    batch_key: str | list[str] | tuple[str, ...] | None = None,
    hvg: int | None = None,
    embedding_dim: int = 50,
):
    import scanpy as sc

    adata = adata.copy()
    batch_keys = _normalize_batch_keys(batch_key)

    sc.pp.normalize_total(adata, target_sum=1e4)
    sc.pp.log1p(adata)

    if hvg is not None:
        hvg_kwargs = {"n_top_genes": hvg, "subset": True}
        if batch_keys:
            hvg_kwargs["batch_key"] = batch_keys[0]
        sc.pp.highly_variable_genes(adata, **hvg_kwargs)

    sc.pp.scale(adata, max_value=10)
    sc.tl.pca(adata, n_comps=embedding_dim, svd_solver="arpack")
    adata.obsm["X_pca_vanilla"] = adata.obsm["X_pca"].copy()

    if batch_keys:
        _harmony_integrate_safe(
            adata,
            batch_key=batch_keys,
            pca_key="X_pca",
            out_key="X_pca_harmony",
        )

    return adata


def main() -> None:
    parser = argparse.ArgumentParser(description="Train PCA/Harmony baseline")

    parser.add_argument("--input_h5ad", type=str, required=True, help="Path to input AnnData .h5ad file")
    parser.add_argument("--results_dir", type=str, default="results", help="Directory to save outputs")
    parser.add_argument("--run_name", type=str, default="pca_harmony_run", help="Name of this training run")

    parser.add_argument(
        "--batch_key",
        type=str,
        nargs="+",
        default=None,
        help="Batch key(s) for Harmony integration (one or more .obs columns).",
    )
    parser.add_argument("--hvg", type=int, default=None, help="Optional number of HVGs used in baseline")
    parser.add_argument("--embedding_dim", type=int, default=50)
    parser.add_argument("--seed", type=int, default=42)

    args = parser.parse_args()

    import anndata as ad
    _set_seed(args.seed)

    run_dir = Path(args.results_dir) / args.run_name
    run_dir.mkdir(parents=True, exist_ok=True)

    batch_keys = _normalize_batch_keys(args.batch_key)
    effective_config = vars(args).copy()
    effective_config["batch_key"] = batch_keys
    with open(run_dir / "config.json", "w", encoding="utf-8") as f:
        json.dump(effective_config, f, indent=2)

    adata = ad.read_h5ad(args.input_h5ad)

    adata_pca = _pca_harmony_embeddings(
        adata,
        batch_key=batch_keys,
        hvg=args.hvg,
        embedding_dim=args.embedding_dim,
    )

    produced: list[dict[str, object]] = []
    produced.append(_save_embedding(adata_pca, "X_pca_vanilla", run_dir))
    if batch_keys:
        produced.append(_save_embedding(adata_pca, "X_pca_harmony", run_dir))

    metadata = {
        "batch_key": batch_keys[0] if batch_keys else None,
        "batch_keys": batch_keys,
        "hvg": args.hvg,
        "n_obs": int(adata.n_obs),
        "n_vars": int(adata.n_vars),
        "produced_embeddings": produced,
    }
    with open(run_dir / "pca_harmony_embedding_meta.json", "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    print(f"PCA/Harmony run complete. Results saved to: {run_dir}")


if __name__ == "__main__":
    main()
