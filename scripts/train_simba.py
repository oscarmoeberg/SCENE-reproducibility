#!/usr/bin/env python3
"""Train SIMBA on scRNA-seq AnnData and save cell/gene embeddings."""

from __future__ import annotations

import argparse
import json
import random
import tempfile
import warnings
from pathlib import Path

import anndata as ad
import numpy as np
from scipy.sparse import csr_matrix, issparse


def _set_seed(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    try:
        import torch

        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)
    except ImportError:
        pass


def _as_dense_2d(x) -> np.ndarray:
    if hasattr(x, "toarray"):
        arr = x.toarray()
    elif hasattr(x, "A"):
        arr = x.A
    else:
        arr = x
    arr = np.asarray(arr)
    if arr.ndim != 2:
        raise ValueError(f"Expected a 2D embedding array, got shape {arr.shape}.")
    return arr


def _ensure_float_csr_matrix(adata: ad.AnnData, dtype=np.float32) -> None:
    """Ensure adata.X is CSR sparse with floating dtype for SIMBA/scikit-learn ops."""
    if issparse(adata.X):
        adata.X = adata.X.tocsr().astype(dtype)
    else:
        adata.X = csr_matrix(np.asarray(adata.X, dtype=dtype))


def _select_and_align_gene_embeddings(
    dict_adata: dict,
    target_gene_names: np.ndarray,
    preferred_prefixes: tuple[str, ...],
    fill_missing: float = 0.0,
) -> tuple[np.ndarray, np.ndarray, list[str], int]:
    target_names = np.asarray(target_gene_names, dtype=str)
    if target_names.ndim != 1:
        raise ValueError(f"Expected 1D target gene names, got shape {target_names.shape}.")
    if target_names.size == 0:
        raise ValueError("Target gene names are empty.")
    if len(np.unique(target_names)) != target_names.shape[0]:
        raise ValueError("Target gene names must be unique for deterministic alignment.")

    target_index = {name: i for i, name in enumerate(target_names)}
    target_set = set(target_names.tolist())

    entries = []
    for key, adata_entity in dict_adata.items():
        n_obs = getattr(adata_entity, "n_obs", None)
        if n_obs is None:
            continue
        names = np.asarray(adata_entity.obs_names.astype(str))
        if names.ndim != 1 or names.size == 0:
            continue
        overlap = int(sum(name in target_set for name in names.tolist()))
        entries.append((str(key), adata_entity, int(n_obs), names, overlap))

    if not entries:
        raise ValueError("SIMBA read_embedding returned no entity AnnData objects.")

    def _rank(key: str) -> tuple[int, str]:
        for i, prefix in enumerate(preferred_prefixes):
            if key.startswith(prefix):
                return (i, key)
        return (len(preferred_prefixes), key)

    preferred_entries = [
        entry for entry in entries
        if any(entry[0].startswith(prefix) for prefix in preferred_prefixes) and entry[4] > 0
    ]
    overlap_entries = [entry for entry in entries if entry[4] > 0]
    selected_entries = preferred_entries if preferred_entries else overlap_entries

    if not selected_entries:
        available = ", ".join([f"{k}:{n}" for k, _, n, _, _ in entries])
        raise ValueError(
            "Could not find SIMBA gene embedding entities with overlap to adata.var_names. "
            f"Available entities: {available}"
        )

    selected_entries = sorted(
        selected_entries,
        key=lambda x: (_rank(x[0]), -x[4], -x[2], x[0]),
    )

    gene_emb: np.ndarray | None = None
    emb_dim: int | None = None
    filled_idx: set[int] = set()
    used_keys: list[str] = []

    for key, adata_entity, _, names, overlap in selected_entries:
        if overlap == 0:
            continue
        emb = _as_dense_2d(adata_entity.X)
        if emb.shape[0] != names.shape[0]:
            raise ValueError(
                f"Entity '{key}' has mismatched shapes: "
                f"n_obs={names.shape[0]} vs embedding rows={emb.shape[0]}."
            )
        if len(np.unique(names)) != names.shape[0]:
            raise ValueError(f"Duplicate gene names detected inside SIMBA entity '{key}'.")

        if emb_dim is None:
            emb_dim = int(emb.shape[1])
        elif emb.shape[1] != emb_dim:
            raise ValueError(
                f"Embedding dimension mismatch across SIMBA gene entities: "
                f"expected {emb_dim}, got {emb.shape[1]} in '{key}'."
            )

        if gene_emb is None:
            gene_emb = np.full(
                (target_names.shape[0], emb_dim),
                fill_value=np.float32(fill_missing),
                dtype=np.float32,
            )

        used_any = False
        for source_i, name in enumerate(names):
            target_i = target_index.get(name)
            if target_i is None or target_i in filled_idx:
                continue
            gene_emb[target_i] = np.asarray(emb[source_i], dtype=np.float32)
            filled_idx.add(target_i)
            used_any = True

        if used_any:
            used_keys.append(key)
        if len(filled_idx) == target_names.shape[0]:
            break

    if emb_dim is None or gene_emb is None:
        raise ValueError("Could not determine gene embedding dimension from SIMBA outputs.")

    missing_count = target_names.shape[0] - len(filled_idx)
    if missing_count > 0:
        warnings.warn(
            f"Missing SIMBA embeddings for {missing_count}/{target_names.shape[0]} genes. "
            f"Filled missing rows with {fill_missing}.",
            RuntimeWarning,
        )

    return gene_emb, target_names.copy(), used_keys, missing_count


def _resolve_or_create_batch_key(
    adata: ad.AnnData,
    batch_key_values: list[str] | None,
) -> tuple[str | None, list[str]]:
    if not batch_key_values:
        return None, []

    batch_keys = [str(k) for k in batch_key_values]
    missing_keys = [k for k in batch_keys if k not in adata.obs]
    if missing_keys:
        raise ValueError(
            "Batch key(s) not found in adata.obs: "
            f"{missing_keys}. Available keys: {list(adata.obs.columns)}"
        )

    for key in batch_keys:
        series = adata.obs[key]
        if series.isna().any():
            n_missing = int(series.isna().sum())
            raise ValueError(
                f"Batch key '{key}' contains {n_missing} missing values. "
                "Please fill/drop missing batch labels before training."
            )

    if len(batch_keys) == 1:
        return batch_keys[0], batch_keys

    composite_batch_key = "*".join(batch_keys)
    if composite_batch_key in adata.obs.columns:
        base_name = composite_batch_key
        suffix = 1
        while composite_batch_key in adata.obs.columns:
            composite_batch_key = f"{base_name}__simba_concat_{suffix}"
            suffix += 1

    composite_series = adata.obs[batch_keys[0]].astype(str)
    for key in batch_keys[1:]:
        composite_series = composite_series + "*" + adata.obs[key].astype(str)
    adata.obs[composite_batch_key] = composite_series.astype("category")

    return composite_batch_key, batch_keys


def _build_list_cg_by_batch(
    adata: ad.AnnData,
    batch_key: str | None,
) -> tuple[list[ad.AnnData], list[str]]:
    if not adata.obs_names.is_unique:
        raise ValueError("adata.obs_names must be unique for SIMBA embedding reconstruction.")

    if batch_key is None:
        return [adata], []

    if batch_key not in adata.obs:
        raise ValueError(
            f"Batch key '{batch_key}' not found in adata.obs. "
            f"Available keys: {list(adata.obs.columns)}"
        )

    batch_series = adata.obs[batch_key]
    if batch_series.dtype.name != "category":
        batch_series = batch_series.astype("category")
    else:
        batch_series = batch_series.cat.remove_unused_categories()

    if batch_series.isna().any():
        n_missing = int(batch_series.isna().sum())
        raise ValueError(
            f"Batch key '{batch_key}' contains {n_missing} missing values. "
            "Please fill/drop missing batch labels before training."
        )

    adata.obs[batch_key] = batch_series
    categories = [str(cat) for cat in batch_series.cat.categories.tolist()]

    list_cg: list[ad.AnnData] = []
    for cat in batch_series.cat.categories:
        mask = (batch_series == cat).to_numpy()
        if not np.any(mask):
            continue
        list_cg.append(adata[mask].copy())

    if not list_cg:
        raise ValueError(
            f"No cells available after splitting by batch key '{batch_key}'."
        )

    return list_cg, categories


def _select_and_merge_cell_embeddings(
    dict_adata: dict,
    target_obs_names: np.ndarray,
    preferred_prefixes: tuple[str, ...],
) -> tuple[np.ndarray, np.ndarray, list[str]]:
    target_names = np.asarray(target_obs_names, dtype=str)
    if target_names.ndim != 1:
        raise ValueError(f"Expected 1D target obs names, got shape {target_names.shape}.")
    if len(np.unique(target_names)) != target_names.shape[0]:
        raise ValueError("Target obs names must be unique for deterministic reconstruction.")

    target_set = set(target_names.tolist())
    if not target_set:
        raise ValueError("Target obs names are empty.")

    entries = []
    for key, adata_entity in dict_adata.items():
        names = np.asarray(adata_entity.obs_names.astype(str))
        if names.ndim != 1 or names.size == 0:
            continue
        name_set = set(names.tolist())
        if not name_set.issubset(target_set):
            continue
        entries.append((str(key), adata_entity, names))

    if not entries:
        raise ValueError(
            "Could not find SIMBA embedding entities corresponding to cell names."
        )

    def _rank(key: str) -> tuple[int, str]:
        for i, prefix in enumerate(preferred_prefixes):
            if key.startswith(prefix):
                return (i, key)
        return (len(preferred_prefixes), key)

    preferred_entries = [e for e in entries if any(e[0].startswith(p) for p in preferred_prefixes)]
    selected_entries = preferred_entries if preferred_entries else entries
    selected_entries = sorted(selected_entries, key=lambda x: _rank(x[0]))

    used_keys: list[str] = []
    name_to_vec: dict[str, np.ndarray] = {}
    emb_dim: int | None = None

    for key, adata_entity, names in selected_entries:
        emb = _as_dense_2d(adata_entity.X)
        if emb.shape[0] != names.shape[0]:
            raise ValueError(
                f"Entity '{key}' has mismatched shapes: "
                f"n_obs={names.shape[0]} vs embedding rows={emb.shape[0]}."
            )
        if len(np.unique(names)) != names.shape[0]:
            raise ValueError(f"Duplicate cell names detected inside SIMBA entity '{key}'.")

        if emb_dim is None:
            emb_dim = int(emb.shape[1])
        elif emb.shape[1] != emb_dim:
            raise ValueError(
                f"Embedding dimension mismatch across SIMBA entities: "
                f"expected {emb_dim}, got {emb.shape[1]} in '{key}'."
            )

        used_any = False
        for i, name in enumerate(names):
            if name in name_to_vec:
                raise ValueError(
                    f"Duplicate cell name '{name}' found across SIMBA entities. "
                    "Cannot merge embeddings unambiguously."
                )
            name_to_vec[name] = emb[i]
            used_any = True

        if used_any:
            used_keys.append(key)

    missing = [name for name in target_names if name not in name_to_vec]
    if missing:
        raise ValueError(
            f"Missing embeddings for {len(missing)} cells after SIMBA merge. "
            "Ensure list_CG splitting and entity extraction cover all cells."
        )

    if emb_dim is None:
        raise ValueError("Could not determine cell embedding dimension from SIMBA outputs.")

    cell_emb = np.empty((target_names.shape[0], emb_dim), dtype=np.float32)
    for i, name in enumerate(target_names):
        cell_emb[i] = np.asarray(name_to_vec[name], dtype=np.float32)

    return cell_emb, target_names.copy(), used_keys


def save_latent_representations(
    cell_emb: np.ndarray,
    gene_emb: np.ndarray,
    out_emb: str,
    out_dir: Path,
) -> None:
    np.save(out_dir / f"{out_emb}_cell_latent.npy", cell_emb)
    np.save(out_dir / f"{out_emb}_gene_latent.npy", gene_emb)


def main() -> None:
    parser = argparse.ArgumentParser(description="Train SIMBA model on RNA AnnData")

    parser.add_argument("--input_h5ad", type=str, required=True, help="Path to input AnnData .h5ad file")
    parser.add_argument("--results_dir", type=str, default="results", help="Directory to save outputs")
    parser.add_argument("--run_name", type=str, default="simba_run", help="Name of this training run")

    parser.add_argument("--out_emb", type=str, default="SIMBA")
    parser.add_argument("--workdir_name", type=str, default="simba_workdir")
    parser.add_argument("--graph_dirname", type=str, default="graph0")
    parser.add_argument("--model_output", type=str, default="model")

    parser.add_argument("--min_n_cells", type=int, default=3)
    parser.add_argument("--n_bins", type=int, default=5)
    parser.add_argument("--max_bins", type=int, default=100)
    parser.add_argument("--normalize_method", type=str, default="lib_size")
    parser.add_argument(
        "--embedding_dim",
        type=int,
        default=None,
        help="Optional embedding dimension for SIMBA PBG training.",
    )

    parser.add_argument("--layer", type=str, default="simba", help="Layer used when building the graph")
    parser.add_argument("--skip_preprocess", action="store_true", help="Skip filter/normalize/log/discretize")
    parser.add_argument("--use_highly_variable", action="store_true")
    parser.add_argument("--use_edge_weights", action="store_true")
    parser.add_argument(
        "--missing_gene_fill_value",
        type=float,
        default=0.0,
        help="Fill value used for genes without a learned SIMBA embedding.",
    )
    parser.add_argument(
        "--batch_key",
        type=str,
        nargs="+",
        default=None,
        help=(
            "Optional obs column(s) for SIMBA batch-aware training. "
            "If multiple keys are passed, values are concatenated with '*' "
            "into one composite batch column."
        ),
    )

    parser.add_argument("--auto_wd", action=argparse.BooleanOptionalAction, default=False)
    parser.add_argument("--save_wd", action=argparse.BooleanOptionalAction, default=False)
    parser.add_argument(
        "--keep_workdir",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="Keep SIMBA graph/model artifacts on disk. Default: do not keep them.",
    )
    parser.add_argument("--seed", type=int, default=42, help="Random seed for SIMBA preprocessing and PBG setup.")
    parser.add_argument("--pbg_workers", type=int, default=4, help="Number of worker processes for PBG training. Adjust based on your CPU cores and memory.")

    args = parser.parse_args()
    if args.embedding_dim is not None and args.embedding_dim <= 0:
        raise ValueError("--embedding_dim must be a positive integer when provided.")

    try:
        import simba as si
    except ImportError as e:
        raise ImportError(
            "Could not import 'simba'. Install SIMBA first, then rerun this script."
        ) from e

    _set_seed(args.seed)

    run_dir = Path(args.results_dir) / args.run_name
    run_dir.mkdir(parents=True, exist_ok=True)

    adata = ad.read_h5ad(args.input_h5ad)

    batch_key, batch_keys = _resolve_or_create_batch_key(adata=adata, batch_key_values=args.batch_key)

    temp_workdir_ctx: tempfile.TemporaryDirectory[str] | None = None
    if args.keep_workdir:
        workdir = run_dir / args.workdir_name
        workdir.mkdir(parents=True, exist_ok=True)
        kept_workdir_path: str | None = str(workdir)
    else:
        temp_workdir_ctx = tempfile.TemporaryDirectory(prefix="simba_")
        workdir = Path(temp_workdir_ctx.name)
        kept_workdir_path = None

    effective_config = vars(args).copy()
    effective_config["resolved_batch_key"] = batch_key
    effective_config["resolved_batch_keys"] = batch_keys
    effective_config["effective_simba_workdir"] = str(workdir)
    effective_config["kept_simba_workdir"] = bool(args.keep_workdir)
    with open(run_dir / "config.json", "w", encoding="utf-8") as f:
        json.dump(effective_config, f, indent=2)

    try:
        si.settings.set_workdir(str(workdir))

        if not args.skip_preprocess:
            _ensure_float_csr_matrix(adata, dtype=np.float32)
            si.pp.filter_genes(adata, min_n_cells=args.min_n_cells)
            _ensure_float_csr_matrix(adata, dtype=np.float32)
            si.pp.normalize(adata, method=args.normalize_method)
            si.pp.log_transform(adata)
            si.tl.discretize(adata, n_bins=args.n_bins, max_bins=args.max_bins)

        if args.layer != "X" and args.layer not in adata.layers:
            raise ValueError(
                f"Layer '{args.layer}' not found in adata.layers. "
                "Either run preprocessing (which creates 'simba') or pass --layer X."
            )

        list_cg, batch_categories = _build_list_cg_by_batch(adata=adata, batch_key=batch_key)

        si.tl.gen_graph(
            list_CG=list_cg,
            layer=args.layer,
            use_highly_variable=args.use_highly_variable,
            dirname=args.graph_dirname,
            add_edge_weights=args.use_edge_weights,
        )

        dict_config = si.settings.pbg_params.copy()
        dict_config["workers"] = args.pbg_workers
        if args.embedding_dim is not None:
            dict_config["dimension"] = args.embedding_dim
        si.settings.pbg_params = dict_config
        si.tl.pbg_train(
            dirname=args.graph_dirname,
            output=args.model_output,
            auto_wd=args.auto_wd,
            save_wd=args.save_wd,
            use_edge_weights=args.use_edge_weights,
        )

        si.load_graph_stats()
        si.load_pbg_config()
        dict_adata = si.read_embedding(convert_alias=True)

        cell_emb, cell_names, cell_keys = _select_and_merge_cell_embeddings(
            dict_adata=dict_adata,
            target_obs_names=np.asarray(adata.obs_names.astype(str)),
            preferred_prefixes=("C", "E0"),
        )
        gene_emb, gene_names, gene_keys, n_missing_gene_embeddings = _select_and_align_gene_embeddings(
            dict_adata=dict_adata,
            target_gene_names=np.asarray(adata.var_names.astype(str)),
            preferred_prefixes=("G", "E1"),
            fill_missing=args.missing_gene_fill_value,
        )

        save_latent_representations(
            cell_emb=cell_emb,
            gene_emb=gene_emb,
            out_emb=args.out_emb,
            out_dir=run_dir,
        )

        np.save(run_dir / f"{args.out_emb}_cell_names.npy", cell_names)
        np.save(run_dir / f"{args.out_emb}_gene_names.npy", gene_names)

        metadata = {
            "batch_key": batch_key,
            "batch_keys": batch_keys,
            "batch_categories": batch_categories,
            "cell_entity_keys": cell_keys,
            "gene_entity_key": gene_keys[0] if len(gene_keys) == 1 else None,
            "gene_entity_keys": gene_keys,
            "cell_embedding_shape": list(cell_emb.shape),
            "gene_embedding_shape": list(gene_emb.shape),
            "n_genes_target": int(adata.n_vars),
            "n_genes_with_simba_embedding": int(adata.n_vars - n_missing_gene_embeddings),
            "n_genes_missing_simba_embedding": int(n_missing_gene_embeddings),
            "missing_gene_fill_value": float(args.missing_gene_fill_value),
            "requested_embedding_dim": args.embedding_dim,
            "simba_workdir": kept_workdir_path,
            "kept_simba_workdir": bool(args.keep_workdir),
        }
        with open(run_dir / f"{args.out_emb}_embedding_meta.json", "w", encoding="utf-8") as f:
            json.dump(metadata, f, indent=2)

    finally:
        if temp_workdir_ctx is not None:
            temp_workdir_ctx.cleanup()

    print(f"SIMBA training complete. Results saved to: {run_dir}")


if __name__ == "__main__":
    main()
