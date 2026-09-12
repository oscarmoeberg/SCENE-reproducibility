import argparse
import json
from pathlib import Path
import scanpy as sc
import numpy as np
import pandas as pd
import anndata as ad

import scene


def _to_jsonable(obj):
    if isinstance(obj, dict):
        return {str(k): _to_jsonable(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_to_jsonable(v) for v in obj]
    if isinstance(obj, np.ndarray):
        return obj.tolist()
    if isinstance(obj, np.generic):
        return obj.item()
    if isinstance(obj, Path):
        return str(obj)
    return obj


def _validate_batch_inputs(args, adata):
    if args.batch_keys is None:
        if args.batch_variant is not None:
            raise ValueError("--batch_variant was provided, but --batch_keys/--batch_key is missing.")
        return

    missing_keys = [key for key in args.batch_keys if key not in adata.obs]
    if missing_keys:
        raise ValueError(
            f"batch key(s) not found in adata.obs: {missing_keys}. "
            f"Available keys include: {list(adata.obs.columns)}"
        )

    if isinstance(args.batch_variant, list) and len(args.batch_variant) != len(args.batch_keys):
        raise ValueError(
            "When providing multiple --batch_variant values, the count must match "
            f"the number of --batch_keys. Got {len(args.batch_variant)} variants for "
            f"{len(args.batch_keys)} batch keys."
        )


def save_val_results(val_results, out_path: Path):
    if val_results is None:
        return

    if isinstance(val_results, pd.DataFrame):
        val_results.to_csv(out_path.with_suffix(".csv"), index=False)
    elif isinstance(val_results, dict):
        with open(out_path.with_suffix(".json"), "w") as f:
            json.dump(_to_jsonable(val_results), f, indent=2)
    else:
        # Fallback
        with open(out_path.with_suffix(".txt"), "w") as f:
            f.write(str(val_results))


def save_latent_representations(adata, out_emb: str, out_dir: Path):
    if out_emb in adata.obsm:
        np.save(out_dir / f"{out_emb}_cell_latent.npy", adata.obsm[out_emb])
        np.save(out_dir / f"{out_emb}_cell_names.npy", adata.obs_names.to_numpy(dtype=str))

    if out_emb in adata.varm:
        np.save(out_dir / f"{out_emb}_gene_latent.npy", adata.varm[out_emb])
        np.save(out_dir / f"{out_emb}_gene_names.npy", adata.var_names.to_numpy(dtype=str))


def save_scene_parameters(adata, out_emb: str, out_dir: Path):
    re_cell_key = f"{out_emb}_re_cell"
    re_gene_key = f"{out_emb}_re_gene"
    params_key = f"{out_emb}_params"
    batch_effects_key = f"{out_emb}_batch_effects"

    if re_cell_key in adata.obs:
        np.save(out_dir / f"{out_emb}_re_cell.npy", adata.obs[re_cell_key].to_numpy())

    if re_gene_key in adata.var:
        np.save(out_dir / f"{out_emb}_re_gene.npy", adata.var[re_gene_key].to_numpy())

    if params_key in adata.uns:
        with open(out_dir / f"{out_emb}_params.json", "w") as f:
            json.dump(_to_jsonable(adata.uns[params_key]), f, indent=2)

    if batch_effects_key in adata.uns:
        batch_effects = adata.uns[batch_effects_key]
        meta = {}
        arrays = {}
        for level, level_data in batch_effects.items():
            meta[level] = {}
            for key, value in level_data.items():
                if isinstance(value, np.ndarray):
                    array_key = f"{level}__{key}"
                    arrays[array_key] = value
                    meta[level][key] = array_key
                else:
                    meta[level][key] = value

        with open(out_dir / f"{out_emb}_batch_effects_meta.json", "w") as f:
            json.dump(_to_jsonable(meta), f, indent=2)

        if arrays:
            np.savez_compressed(out_dir / f"{out_emb}_batch_effects.npz", **arrays)


def save_model(model, out_path: Path):
    # Preferred for PyTorch-style models
    if hasattr(model, "state_dict"):
        import torch
        torch.save(model.state_dict(), out_path.with_suffix(".pt"))
    elif hasattr(model, "save"):
        model.save(str(out_path))
    else:
        # Fallback: serialize string repr only
        with open(out_path.with_suffix(".txt"), "w") as f:
            f.write(str(model))


def main():
    parser = argparse.ArgumentParser(description="Train SCENE model")

    # I/O params
    parser.add_argument("--input_h5ad", type=str, required=True, help="Path to input AnnData .h5ad file")
    parser.add_argument("--results_dir", type=str, default="results", help="Directory to save outputs")
    parser.add_argument("--run_name", type=str, default="scene_run", help="Name of this training run")

    # Training params
    parser.add_argument("--latent_dim", type=int, default=16)
    parser.add_argument("--epochs", type=int, default=600)
    parser.add_argument("--device", type=str, default="cpu")
    parser.add_argument("--lr", type=float, default=0.05)
    parser.add_argument("--layer", type=str, default="counts", help="Layer in adata.layers to use for training (falls back to adata.X if missing).")
    parser.add_argument("--out_emb", type=str, default="SCENE")
    parser.add_argument("--subset", type=int, default=None, help="Optional number of cells to randomly subset before training.")
    parser.add_argument("--validate", action="store_true")
    parser.add_argument("--no_validate", dest="validate", action="store_false", help="Skip validation.")
    parser.add_argument("--pi_only", dest="pi_only", action="store_true", help="Use pi-only link scoring during validation (default).")
    parser.add_argument("--no_pi_only", dest="pi_only", action="store_false", help="Disable pi-only link scoring and use combined lambda/pi score.",)
    parser.add_argument("--cell_init", type=str, default="random")
    parser.add_argument("--gene_init", type=str, default="random")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--split_seed", type=int, default=None, help="Seed for the validation split. Defaults to --seed.")
    parser.add_argument("--batch_keys", "--batch_key", type=str, nargs="+", default=None, help="Optional obs column name(s) for batch effects (one or more keys).")
    parser.add_argument("--batch_variant", "--variant", type=str, nargs="+", default=None, help="Batch-effect parameterization: full or lowrank. Provide one value for all batch levels, or one value per --batch_keys.")
    parser.add_argument("--rank", type=int, default=2, help="Low-rank factor dimension for variant='lowrank'.")
    parser.add_argument("--loss_type", type=str, default="ZIP", help="Type of loss to use for training.")
    parser.add_argument("--cell_batch_size", type=int, default=None, help="Optional cell mini-batch size for stochastic training. Defaults to full-matrix training.")
    parser.set_defaults(pi_only=True)
    parser.set_defaults(validate=True)

    args = parser.parse_args()
    if args.split_seed is None:
        args.split_seed = args.seed

    if args.batch_variant is not None and len(args.batch_variant) == 1:
        args.batch_variant = args.batch_variant[0]

    run_dir = Path(args.results_dir) / args.run_name
    run_dir.mkdir(parents=True, exist_ok=True)

    # Save config
    with open(run_dir / "config.json", "w") as f:
        json.dump(_to_jsonable(vars(args)), f, indent=2)

    # Load data
    adata = ad.read_h5ad(args.input_h5ad)

    if args.subset is not None:
        if args.subset <= 0:
            raise ValueError(f"--subset must be a positive integer. Got: {args.subset}")
        if args.subset > adata.n_obs:
            raise ValueError(
                f"--subset ({args.subset}) exceeds number of cells in input ({adata.n_obs})."
            )
        rng = np.random.default_rng(seed=args.seed)
        idx = rng.choice(adata.n_obs, size=args.subset, replace=False)
        adata = adata[idx].copy()


    _validate_batch_inputs(args, adata)

    # Filter genes of no expression 
    sc.pp.filter_genes(adata, min_cells=1)

    # Train
    train_kwargs = dict(
        layer=args.layer,
        latent_dim=args.latent_dim,
        rank=args.rank,
        epochs=args.epochs,
        device=args.device,
        lr=args.lr,
        out_emb=args.out_emb,
        validate=args.validate,
        pi_only=args.pi_only,
        cell_init=args.cell_init,
        gene_init=args.gene_init,
        batch_keys=args.batch_keys,
        seed=args.seed,
        split_seed=args.split_seed,
        loss_type=args.loss_type,
        cell_batch_size=args.cell_batch_size,
    )
    if args.batch_variant is not None:
        train_kwargs["variant"] = args.batch_variant

    adata, val_results = scene.train_scene(
        adata,
        **train_kwargs,
    )


    # Save trained embeddings and learned model parameters/effects
    save_latent_representations(adata, args.out_emb, run_dir)
    save_scene_parameters(adata, args.out_emb, run_dir)
    save_val_results(val_results, run_dir / "val_results")

    print(f"Training complete. Results saved to: {run_dir}")


if __name__ == "__main__":
    main()
