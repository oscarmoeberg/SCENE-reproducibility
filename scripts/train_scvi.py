#!/usr/bin/env python3
"""Train scVI on AnnData and save cell latent representations."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path

import numpy as np


def _set_seed(seed: int) -> None:
    np.random.seed(seed)
    try:
        import torch

        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)
    except ImportError:
        pass


def _ensure_layer(adata, layer: str) -> None:
    if layer == "X":
        return
    if layer in adata.layers:
        return
    if layer != "counts":
        raise ValueError(
            f"Layer '{layer}' not found in adata.layers. "
            "Use --layer X, provide an existing layer, or use --layer counts."
        )

    try:
        import scipy.sparse as sp
    except ImportError:
        sp = None

    if sp is not None and sp.issparse(adata.X):
        adata.layers["counts"] = adata.X.copy()
    else:
        if sp is not None:
            adata.layers["counts"] = sp.csr_matrix(adata.X)
        else:
            adata.layers["counts"] = np.asarray(adata.X).copy()


def _parse_batch_key(batch_key_values: list[str] | None) -> tuple[str | None, list[str] | None]:
    if not batch_key_values:
        return None, None
    if len(batch_key_values) == 1:
        return batch_key_values[0], None
    if len(batch_key_values) == 2:
        return batch_key_values[0], [batch_key_values[1]]
    raise ValueError("--batch_key accepts at most two values: <batch> [categorical_covariate].")


def _resolve_accelerator(device: str | None) -> str:
    if device is None:
        return "auto"
    dev = str(device).strip().lower()
    if dev == "cuda":
        return "gpu"
    return dev or "auto"


def main() -> None:
    parser = argparse.ArgumentParser(description="Train scVI model")

    parser.add_argument("--input_h5ad", type=str, required=True, help="Path to input AnnData .h5ad file")
    parser.add_argument("--results_dir", type=str, default="results", help="Directory to save outputs")
    parser.add_argument("--run_name", type=str, default="scvi_run", help="Name of this training run")

    parser.add_argument("--out_emb", type=str, default="scVI", help="Output embedding key/prefix")
    parser.add_argument("--layer", type=str, default="counts", help="Layer used for training. Use X for adata.X")
    parser.add_argument(
        "--batch_key",
        type=str,
        nargs="+",
        default=None,
        help="Optional batch key(s): <batch_key> [categorical_covariate_key]",
    )
    parser.add_argument("--n_latent", type=int, default=None)
    parser.add_argument("--n_layers", type=int, default=1)
    parser.add_argument("--gene_likelihood", type=str, default="zinb")
    parser.add_argument("--max_epochs", type=int, default=400)
    parser.add_argument("--device", type=str, default="cpu", help="Lightning accelerator: cpu, gpu, mps, auto")
    parser.add_argument(
        "--dl_num_workers",
        type=int,
        default=None,
        help="Dataloader worker count for scVI. If unset, auto-tuned for GPU/CUDA runs.",
    )
    parser.add_argument("--seed", type=int, default=42)

    args = parser.parse_args()

    import anndata as ad
    import scvi

    _set_seed(args.seed)
    scvi.settings.seed = args.seed

    run_dir = Path(args.results_dir) / args.run_name
    run_dir.mkdir(parents=True, exist_ok=True)

    adata = ad.read_h5ad(args.input_h5ad)
    _ensure_layer(adata, args.layer)

    batch_key, categorical_covariates = _parse_batch_key(args.batch_key)
    layer_for_scvi = None if args.layer == "X" else args.layer
    accelerator = _resolve_accelerator(args.device)

    # Use batch-aware scVI defaults whenever a batch key is provided.
    if batch_key is not None:
        args.n_layers = 2
        if args.n_latent is None:
            args.n_latent = 30
        args.gene_likelihood = "nb"
    else:
        if args.n_latent is None:
            args.n_latent = 10


    effective_config = vars(args).copy()
    effective_config["resolved_batch_key"] = batch_key
    effective_config["resolved_categorical_covariate_keys"] = categorical_covariates
    effective_config["resolved_accelerator"] = accelerator
    with open(run_dir / "config.json", "w", encoding="utf-8") as f:
        json.dump(effective_config, f, indent=2)

    scvi.model.SCVI.setup_anndata(
        adata,
        layer=layer_for_scvi,
        batch_key=batch_key,
        categorical_covariate_keys=categorical_covariates,
    )
    vae = scvi.model.SCVI(
        adata,
        n_layers=args.n_layers,
        n_latent=args.n_latent,
        gene_likelihood=args.gene_likelihood,
    )
    vae.train(accelerator=accelerator, max_epochs=args.max_epochs)

    latent = np.asarray(vae.get_latent_representation())
    adata.obsm[args.out_emb] = latent

    np.save(run_dir / f"{args.out_emb}_cell_latent.npy", latent)
    np.save(run_dir / f"{args.out_emb}_cell_names.npy", adata.obs_names.to_numpy(dtype=str))

    metadata = {
        "embedding_key": args.out_emb,
        "embedding_shape": list(latent.shape),
        "layer_used": args.layer,
        "batch_key": batch_key,
        "categorical_covariate_keys": categorical_covariates,
        "n_obs": int(adata.n_obs),
        "n_vars": int(adata.n_vars),
        "accelerator": accelerator,
    }
    with open(run_dir / f"{args.out_emb}_embedding_meta.json", "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)

    print(f"scVI training complete. Results saved to: {run_dir}")


if __name__ == "__main__":
    main()
