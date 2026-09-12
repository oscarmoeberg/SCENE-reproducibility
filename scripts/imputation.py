#!/usr/bin/env python
"""
Impute masked counts with SCENE or scVI and evaluate prediction accuracy.
"""
from __future__ import annotations
import argparse, json, logging, sys
from pathlib import Path
from typing import Any, Dict, List, Tuple

import numpy as np
import pandas as pd
import scanpy as sc
import anndata as ad
import scipy.sparse as sp
import scipy.stats as stats

# ----------------------------------------------------------------------------- helpers
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

def set_seed(seed: int = 42) -> None:
    np.random.seed(seed)
    try:
        import torch
        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)
    except ImportError:
        pass


def configure_logging(save_dir: Path) -> None:
    log_fmt = "%(asctime)s | %(levelname)7s | %(message)s"
    date_fmt = "%Y-%m-%d %H:%M:%S"
    (save_dir / "logs").mkdir(exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format=log_fmt,
        datefmt=date_fmt,
        handlers=[
            logging.FileHandler(save_dir / "logs" / "pipeline.log"),
            logging.StreamHandler(sys.stdout),
        ],
    )


def load_adata(path: Path) -> ad.AnnData:
    logging.info(f"Loading AnnData from {path}")
    return sc.read_h5ad(path)


def ensure_counts_layer(adata: ad.AnnData) -> None:
    if "counts" in adata.layers:
        return
    logging.info("Copying .X to .layers['counts']")
    counts = adata.X.copy() if sp.issparse(adata.X) else sp.csr_matrix(adata.X)
    adata.layers["counts"] = counts


def mask_random_fraction(
    adata: ad.AnnData,
    frac: float = 0.10,
    layer: str = "counts",
    seed: int = 42,
) -> Tuple[ad.AnnData, np.ndarray, np.ndarray]:
    rng = np.random.default_rng(seed)
    X = adata.layers[layer]
    if not sp.issparse(X):
        X = sp.csr_matrix(X)
    X = X.tocsr(copy=True)
    X.eliminate_zeros()
    nnz, n_hide = X.nnz, int(X.nnz * frac)
    logging.info(f"Masking {n_hide:,d}/{nnz:,d} (~{100*frac:.1f} %) counts")
    rows, cols = X.nonzero()
    pos = rng.choice(nnz, size=n_hide, replace=False)
    row_idx, col_idx = rows[pos], cols[pos]
    X_masked = X.copy()
    X_masked[row_idx, col_idx] = 0
    X_masked.eliminate_zeros()
    adata_masked = adata.copy()
    adata_masked.layers[f"{layer}_masked"] = sp.csr_matrix(X_masked)
    adata_masked.uns["masked_pos"] = dict(row=row_idx.astype(np.int32),
                                          col=col_idx.astype(np.int32))
    return adata_masked, row_idx, col_idx


def apply_mask(
    adata: ad.AnnData,
    row_idx: np.ndarray,
    col_idx: np.ndarray,
    layer: str = "counts",
) -> ad.AnnData:
    X = adata.layers[layer]
    if not sp.issparse(X):
        X = sp.csr_matrix(X)
    X_masked = X.copy()
    X_masked[row_idx, col_idx] = 0
    X_masked.eliminate_zeros()
    adata_masked = adata.copy()
    adata_masked.layers[f"{layer}_masked"] = sp.csr_matrix(X_masked)
    adata_masked.uns["masked_pos"] = dict(
        row=row_idx.astype(np.int32),
        col=col_idx.astype(np.int32),
    )
    return adata_masked


def values_at(X, row_idx: np.ndarray, col_idx: np.ndarray) -> np.ndarray:
    if sp.issparse(X):
        return np.asarray(X[row_idx, col_idx]).ravel()
    return np.asarray(X)[row_idx, col_idx]


def load_or_create_heldout(
    adata: ad.AnnData,
    out_dir: Path,
    frac: float,
    seed: int,
) -> Tuple[ad.AnnData, np.ndarray, np.ndarray, np.ndarray]:
    heldout_path = out_dir / "held_out_counts.npz"
    if heldout_path.exists():
        with np.load(heldout_path) as heldout:
            row_idx = heldout["row"].astype(np.int64, copy=False)
            col_idx = heldout["col"].astype(np.int64, copy=False)
            heldout_count = heldout["heldout_count"]
            if "cell_names" in heldout:
                np.testing.assert_array_equal(heldout["cell_names"], adata.obs_names.to_numpy(dtype=str))
                np.testing.assert_array_equal(heldout["gene_names"], adata.var_names.to_numpy(dtype=str))
        if row_idx.max(initial=-1) >= adata.n_obs or col_idx.max(initial=-1) >= adata.n_vars:
            raise ValueError(
                "Saved held-out indices do not fit the loaded AnnData. "
                "Use a different experiment name or remove held_out_counts.npz."
            )
        logging.info(f"Re-using {len(row_idx):,d} held-out counts from {heldout_path}")
        return apply_mask(adata, row_idx, col_idx), row_idx, col_idx, heldout_count

    adata_masked, row_idx, col_idx = mask_random_fraction(
        adata,
        frac=frac,
        layer="counts",
        seed=seed,
    )
    heldout_count = values_at(adata.layers["counts"], row_idx, col_idx)
    np.savez_compressed(
        heldout_path,
        row=row_idx.astype(np.int32),
        col=col_idx.astype(np.int32),
        heldout_count=heldout_count,
        cell_names=adata.obs_names.to_numpy(dtype=str),
        gene_names=adata.var_names.to_numpy(dtype=str),
        n_obs=np.array(adata.n_obs, dtype=np.int64),
        n_vars=np.array(adata.n_vars, dtype=np.int64),
    )
    logging.info(f"Saved held-out counts to {heldout_path}")
    return adata_masked, row_idx, col_idx, heldout_count


# ----------------------------------------------------------------------------- model wrappers

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


def run_scene(
    adata: ad.AnnData,
    layer: str,
    batch_key: str | List[str] | None,
    latent_dim: int = 32,
    max_epochs: int = 1000,
    lr: float = 0.025,
    device: str | None = None,
    out_key: str = "SCENE",
    loss_type: str = "ZIP",
    seed: int = 42,
    split_seed: int | None = None,
):
    import importlib
    scene = importlib.import_module("scene")
    logging.info(f"Training SCENE ({out_key}) …")
    adata_out, _val_results, model = scene.train_scene(
        adata,
        latent_dim=latent_dim,
        layer=layer,
        batch_keys=batch_key,
        epochs=max_epochs,
        device=device,
        lr=lr,
        out_emb=out_key,
        return_model=True,
        loss_type=loss_type,
        seed=seed,
        split_seed=split_seed,
    )
    return model, adata_out


def run_scvi(
    adata: ad.AnnData,
    layer: str,
    batch_key: str | None,
    n_latent: int = 10,
    n_layers: int = 1,
    gene_likelihood: str = "zinb",
    device: str | None = None,
    out_key: str = "scVI",
    max_epochs: int = 400,
):
    import importlib
    scvi = importlib.import_module("scvi")
    logging.info("Training scVI …")
    scvi.model.SCVI.setup_anndata(adata, layer=layer, batch_key=batch_key)
    vae = scvi.model.SCVI(
        adata,
        n_layers=n_layers,
        n_latent=n_latent,
        gene_likelihood=gene_likelihood,
    )
    accelerator = "gpu" if device == "cuda" else device or "auto"
    vae.train(accelerator=accelerator, max_epochs=max_epochs)
    adata.obsm[out_key] = vae.get_latent_representation()
    return vae, adata



# ----------------------------------------------------------------------------- metrics
MetricDict = Dict[str, float]


def compute_metrics(y_true: np.ndarray, y_pred: np.ndarray) -> MetricDict:
    mse = np.mean((y_true - y_pred) ** 2)
    mae = np.mean(np.abs(y_true - y_pred))
    rmse = np.sqrt(mse)
    pearson_r = spearman_r = np.nan
    if np.std(y_true) > 0 and np.std(y_pred) > 0:
        pearson_r = np.corrcoef(y_true, y_pred)[0, 1]
        spearman_r = stats.spearmanr(y_true, y_pred, nan_policy="omit").correlation
    return dict(MSE=mse, RMSE=rmse, MAE=mae, Pearson_r=pearson_r, Spearman_r=spearman_r)

def scvi_impute(vae, adata):
    # 1) compute each cell's total counts from the masked layer
    masked = adata.layers.get("counts_masked")
    if masked is None:
        raise ValueError("‘counts_masked’ layer not found in adata.layers")

    imputed = vae.get_normalized_expression(adata, library_size="latent", return_numpy=True)
    
    return imputed


def scene_impute(
    model,
    adata: ad.AnnData,
    out_key: str,
    batch_keys: str | List[str] | None = None,
    device: str | None = None,
    loss_type: str = "ZIP",
) -> np.ndarray:
    import importlib

    scene = importlib.import_module("scene")
    lambda_, pi = scene.reconstruct_rates_from_adata(
        adata,
        out_emb=out_key,
        batch_keys=batch_keys,
        device=device or "cpu",
    )

    if loss_type.lower() == "zip":
        print(f"Using ZIP reconstruction formula for imputation")
        return pi * (lambda_ / (-np.expm1(-lambda_)))
    else:
        print(f"Using Poisson reconstruction formula for imputation")
        return lambda_



# ----------------------------------------------------------------------------- output helpers
def jsonable(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {str(k): jsonable(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [jsonable(v) for v in obj]
    if isinstance(obj, Path):
        return str(obj)
    if isinstance(obj, np.ndarray):
        return obj.tolist()
    if isinstance(obj, np.generic):
        return obj.item()
    return obj


def write_config(
    out_dir: Path,
    args: argparse.Namespace,
    out_key: str,
    params: Dict[str, Any],
    heldout_count: int,
) -> None:
    config_path = out_dir / "config.json"
    if config_path.exists():
        with open(config_path) as f:
            config = json.load(f)
    else:
        config = {}

    config.update(
        {
            "data_path": str(args.data_path),
            "results_dir": str(args.results_dir),
            "experiment_name": args.experiment_name,
            "seed": args.seed,
            "split_seed": args.split_seed,
            "sample_n": args.sample_n,
            "heldout_fraction": 0.10,
            "heldout_count": heldout_count,
            "heldout_counts_file": "held_out_counts.npz",
            "predictions_file": "model_predictions.npz",
            "metrics_file": "imputation_metrics.csv",
        }
    )
    config.setdefault("runs", {})
    config["runs"][out_key] = {
        "model": args.model,
        "preset": args.preset,
        "batch_key": args.batch_key,
        "device": args.device,
        "epochs": args.epochs,
        "params": params,
    }

    with open(config_path, "w") as f:
        json.dump(jsonable(config), f, indent=2)


def save_predictions(
    preds: np.ndarray,
    row_idx: np.ndarray,
    col_idx: np.ndarray,
    out_dir: Path,
    out_key: str,
) -> None:
    predictions_path = out_dir / "model_predictions.npz"
    pred_matrix = preds.to_numpy() if isinstance(preds, pd.DataFrame) else np.asarray(preds)
    prediction = pred_matrix[row_idx, col_idx].astype(np.float32)
    arrays = {}
    if predictions_path.exists():
        with np.load(predictions_path) as existing:
            arrays = {key: existing[key] for key in existing.files if key != out_key}
    arrays[out_key] = prediction
    np.savez_compressed(predictions_path, **arrays)
    logging.info(f"Saved model predictions to {predictions_path}")


def evaluate_prediction_files(out_dir: Path) -> None:
    heldout_path = out_dir / "held_out_counts.npz"
    predictions_path = out_dir / "model_predictions.npz"
    config_path = out_dir / "config.json"
    if not heldout_path.exists():
        raise FileNotFoundError(f"Missing held-out counts file: {heldout_path}")
    if not predictions_path.exists():
        raise FileNotFoundError(f"Missing predictions file: {predictions_path}")

    run_config = {}
    if config_path.exists():
        with open(config_path) as f:
            run_config = json.load(f).get("runs", {})

    with np.load(heldout_path) as heldout:
        heldout_count = heldout["heldout_count"]

    rows = []
    with np.load(predictions_path) as predictions:
        for out_key in sorted(predictions.files):
            predicted_count = predictions[out_key]
            if len(predicted_count) != len(heldout_count):
                raise ValueError(
                    f"Prediction length for {out_key} ({len(predicted_count)}) does not "
                    f"match held-out count length ({len(heldout_count)})."
                )
            res = compute_metrics(heldout_count, predicted_count)
            meta = run_config.get(out_key, {})
            res.update(
                Model=out_key,
                model=meta.get("model", np.nan),
                preset=meta.get("preset", np.nan),
            )
            rows.append(res)

    if rows:
        pd.DataFrame(rows).to_csv(out_dir / "imputation_metrics.csv", index=False)



# ----------------------------------------------------------------------------- CLI
def main(argv: List[str] | None = None) -> None:
    p = argparse.ArgumentParser("Flexible imputation quality pipeline")
    p.add_argument("--data_path", type=Path, default=None)
    p.add_argument("--results_dir", type=Path, default=Path("imputation_results"))
    p.add_argument("--batch_key", type=str, nargs="+", default=None, help=".obs column for batch labels")
    p.add_argument("--experiment_name", type=str, required=True)
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--split_seed", type=int, default=None, help="Seed for held-out masking/evaluation splits. Defaults to --seed.")
    p.add_argument("--device", type=str, default="cpu")
    p.add_argument("--sample_n", type=int, default=None)

    # Model and evaluation options
    p.add_argument("--model", required=True, choices=["scene", "scvi"])
    p.add_argument("--preset", choices=["naive", "batch_aware"], default="naive")
    p.add_argument("--epochs", type=int, default=None)
    p.add_argument("--out_emb", type=str, default=None, help="Optional name for saved predictions and embeddings.")
    p.add_argument("--evaluate", action="store_true", help="Skip training; only compute metrics from existing predictions")
    p.add_argument("--loss_type", type=str, default="ZIP", help="Type of loss to use for training.")


    args = p.parse_args(argv)
    if args.split_seed is None:
        args.split_seed = args.seed
    if not args.evaluate and args.data_path is None:
        p.error("--data_path is required unless --evaluate is set")

    # if exactly one batch key was given, unwrap it to a string
    if args.batch_key is not None and len(args.batch_key) == 1:
        args.batch_key = args.batch_key[0]

    # ------------------------------------------------------------------ paths & logging
    out_dir = args.results_dir / args.experiment_name
    out_dir.mkdir(parents=True, exist_ok=True)
    configure_logging(out_dir)
    set_seed(args.seed)

    # ------------------------------------------------------------------ model selection
    preset_cfg = {
        "scene": {
            "naive":       dict(latent_dim=16, lr=0.025, batch_key=None),
            "batch_aware": dict(latent_dim=48, lr=0.025),  # batch_key added later
        },
        "scvi": {
            "naive":       dict(n_latent=10, n_layers=1, gene_likelihood='zinb', batch_key=None),
            "batch_aware": dict(n_latent=30, n_layers=2, gene_likelihood='nb'),   # batch_key added later
        },
    }
    params = preset_cfg[args.model][args.preset].copy()
    if args.preset == "batch_aware":
        params["batch_key"] = args.batch_key
    params["max_epochs"] = args.epochs if args.epochs is not None else (600 if args.model == "scene" else 400)
    if args.model == "scene":
        params["loss_type"] = args.loss_type
    out_key = args.out_emb or f"{args.model.upper()}{'_batch' if params.get('batch_key') else ''}"

    # ------------------------------------------------------------------ evaluate-only
    if args.evaluate:
        evaluate_prediction_files(out_dir)
        logging.info("All available metrics computed & saved.")
        sys.exit(0)

    # ------------------------------------------------------------------ load data / mask
    adata = load_adata(args.data_path)

    if args.sample_n and args.sample_n < adata.n_obs:
        idx = np.random.choice(adata.n_obs, args.sample_n, replace=False)
        adata = adata[idx, :].copy()
        logging.info(f"Subsampled to {adata.n_obs} cells")

    ensure_counts_layer(adata)
    adata, row_idx, col_idx, heldout_count = load_or_create_heldout(
        adata,
        out_dir=out_dir,
        frac=0.10,
        seed=args.split_seed,
    )
    write_config(out_dir, args, out_key, params, heldout_count=len(heldout_count))

    # ------------------------------------------------------------------ train  predict
    if args.model == "scene":
        model, adata = run_scene(
            adata, layer="counts_masked", device=args.device,
            out_key=out_key, seed=args.seed, split_seed=args.split_seed, **params)
        preds = scene_impute(
            model,
            adata,
            out_key=out_key,
            batch_keys=params.get("batch_key"),
            device=args.device,
            loss_type=params.get("loss_type")
        )
        
        save_latent_representations(adata, out_key, out_dir)
        save_scene_parameters(adata, out_key, out_dir)

    else:  # scvi
        model, adata = run_scvi(
            adata, layer="counts_masked", device=args.device,
            out_key=out_key, **params)
        preds = scvi_impute(model, adata)

    # ------------------------------------------------------------------ save lightweight results
    save_predictions(preds, row_idx, col_idx, out_dir, out_key)
    evaluate_prediction_files(out_dir)
    logging.info("Done.")


if __name__ == "__main__":
    main()
