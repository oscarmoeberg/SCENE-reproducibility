#!/usr/bin/env python3
"""Compute clustering, silhouette, and connectivity metrics for one embedding.

Metrics:
- KMeans NMI
- KMeans ARI
- Silhouette label
- Silhouette batch
- Graph connectivity
"""

from __future__ import annotations

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import TYPE_CHECKING

import numpy as np
import pandas as pd
from scipy.sparse.csgraph import connected_components
from sklearn.cluster import KMeans
from sklearn.metrics import adjusted_rand_score, normalized_mutual_info_score, silhouette_score
from sklearn.neighbors import NearestNeighbors

if TYPE_CHECKING:
    import anndata as ad


def configure_logging(out_dir: Path) -> None:
    log_fmt = "%(asctime)s | %(levelname)7s | %(message)s"
    date_fmt = "%Y-%m-%d %H:%M:%S"
    (out_dir / "logs").mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format=log_fmt,
        datefmt=date_fmt,
        handlers=[
            logging.FileHandler(out_dir / "logs" / "benchmark_embedding_simple.log"),
            logging.StreamHandler(sys.stdout),
        ],
    )


def _load_embedding(path: Path) -> np.ndarray:
    emb = np.load(path)
    emb = np.asarray(emb)
    if emb.ndim != 2:
        raise ValueError(f"Expected a 2D embedding array, got shape {emb.shape}.")
    return emb


def _align_embedding_to_adata(
    adata: "ad.AnnData",
    emb: np.ndarray,
    names_path: Path | None,
) -> np.ndarray:
    if names_path is None:
        if emb.shape[0] != adata.n_obs:
            raise ValueError(
                f"Embedding rows ({emb.shape[0]}) do not match adata.n_obs ({adata.n_obs}). "
                "Provide --embedding_cell_names_npy to align by cell name."
            )
        return emb

    emb_names = np.load(names_path, allow_pickle=True).astype(str)
    if emb_names.shape[0] != emb.shape[0]:
        raise ValueError(
            "Rows in --embedding_cell_names_npy do not match rows in --embedding_npy."
        )

    adata_names = adata.obs_names.to_numpy(dtype=str)
    if np.array_equal(emb_names, adata_names):
        return emb

    emb_index = {name: i for i, name in enumerate(emb_names)}
    if len(emb_index) != len(emb_names):
        raise ValueError("Duplicate cell names detected in --embedding_cell_names_npy.")

    adata_name_set = set(adata_names)
    missing = [name for name in adata_names if name not in emb_index]
    extra = [name for name in emb_names if name not in adata_name_set]
    if missing or extra:
        msg = []
        if missing:
            msg.append(f"missing_in_embedding={len(missing)}")
        if extra:
            msg.append(f"extra_in_embedding={len(extra)}")
        raise ValueError("Cell name mismatch between adata and embedding: " + ", ".join(msg))

    reorder_idx = np.array([emb_index[name] for name in adata_names], dtype=np.int64)
    return emb[reorder_idx]


def _build_knn_graph(X: np.ndarray, n_neighbors: int = 15):
    knn = NearestNeighbors(n_neighbors=n_neighbors, metric="euclidean")
    knn.fit(X)
    G = knn.kneighbors_graph(X, mode="connectivity")
    return G.maximum(G.T).tocsr()


def _kmeans_pred(
    X: np.ndarray, labels: np.ndarray, random_state: int = 0, n_init: int = 20
) -> np.ndarray:
    n_clusters = int(np.unique(labels).shape[0])
    km = KMeans(n_clusters=n_clusters, random_state=random_state, n_init=n_init)
    return km.fit_predict(X)

def _silhouette_label_scaled(X: np.ndarray, labels: np.ndarray) -> float:
    # scale from [-1, 1] to [0, 1]
    s = silhouette_score(X, labels, metric="euclidean")
    return float((s + 1.0) / 2.0)


def _silhouette_batch(X: np.ndarray, labels: np.ndarray, batch: np.ndarray) -> float:
    vals = []
    weights = []
    for lab in np.unique(labels):
        idx = np.where(labels == lab)[0]
        if idx.size < 3:
            continue
        b = batch[idx]
        if not 2 <= np.unique(b).shape[0] < idx.size:
            continue
        s = silhouette_score(X[idx], b, metric="euclidean")
        vals.append(1.0 - abs(float(s)))
        weights.append(int(idx.size))
    if not vals:
        return float("nan")
    return float(np.average(vals, weights=np.asarray(weights)))


def _graph_connectivity(X: np.ndarray, labels: np.ndarray, n_neighbors: int = 15) -> float:
    G = _build_knn_graph(X, n_neighbors=n_neighbors)
    gc_scores = []
    for lab in np.unique(labels):
        idx = np.where(labels == lab)[0]
        if idx.size <= 1:
            continue
        sub = G[idx][:, idx]
        _, comp = connected_components(sub, directed=False, connection="weak")
        largest = int(np.bincount(comp).max())
        gc_scores.append(largest / float(idx.size))
    if not gc_scores:
        return float("nan")
    return float(np.mean(gc_scores))


def benchmark_single_embedding(
    adata: "ad.AnnData",
    embedding_key: str,
    batch_key: str | None,
    label_key: str,
    out_dir: Path,
    n_jobs: int = 6,
    n_neighbors: int = 15,
    random_state: int = 0,
    kmeans_n_init: int = 20,
) -> None:
    del n_jobs

    X = np.asarray(adata.obsm[embedding_key], dtype=np.float64)
    labels = adata.obs[label_key].to_numpy()
    pred_kmeans = _kmeans_pred(X, labels, random_state=random_state, n_init=kmeans_n_init)

    scores = {
        "Embedding": embedding_key,
        "KMeans NMI": float(normalized_mutual_info_score(labels, pred_kmeans)),
        "KMeans ARI": float(adjusted_rand_score(labels, pred_kmeans)),
        "Silhouette label": _silhouette_label_scaled(X, labels),
        "Graph connectivity": _graph_connectivity(X, labels, n_neighbors=n_neighbors),
    }

    if batch_key is None:
        logging.warning("No batch_key provided; setting 'Silhouette batch' to NaN.")
        scores["Silhouette batch"] = float("nan")
    else:
        batch = adata.obs[batch_key].to_numpy()
        scores["Silhouette batch"] = _silhouette_batch(X, labels, batch)

    results_df = pd.DataFrame([scores])
    results_df.to_csv(out_dir / "benchmark_results.csv", index=False)
    logging.info("Benchmark results saved to %s", out_dir / "benchmark_results.csv")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Benchmark a single embedding with a minimal metric suite"
    )
    parser.add_argument("--input_h5ad", type=Path, required=True, help="Path to input AnnData .h5ad")
    parser.add_argument("--embedding_npy", type=Path, required=True, help="Path to embedding .npy (n_cells x n_dim)")
    parser.add_argument("--embedding_cell_names_npy", type=Path, default=None, help="Optional cell names .npy aligned to rows in --embedding_npy")
    parser.add_argument("--embedding_key", type=str, default="embedding", help="Name to store embedding in adata.obsm")
    parser.add_argument("--label_key", type=str, required=True, help="obs column for labels/cell types")
    parser.add_argument("--batch_key", type=str, default=None, help="obs column for batch labels")
    parser.add_argument("--output_dir", type=Path, required=True, help="Directory for benchmark outputs")
    parser.add_argument("--n_jobs", type=int, default=6, help="Kept for API compatibility")
    parser.add_argument("--n_neighbors", type=int, default=15, help="kNN graph size for graph connectivity")
    parser.add_argument("--random_state", type=int, default=0, help="Random seed for KMeans")
    parser.add_argument("--kmeans_n_init", type=int, default=20, help="KMeans n_init")

    args = parser.parse_args()

    import anndata as ad

    args.output_dir.mkdir(parents=True, exist_ok=True)
    configure_logging(args.output_dir)

    logging.info("Loading AnnData from %s", args.input_h5ad)
    adata = ad.read_h5ad(args.input_h5ad)
    if args.label_key not in adata.obs:
        raise ValueError(f"label_key '{args.label_key}' not found in adata.obs.")
    if args.batch_key is not None and args.batch_key not in adata.obs:
        raise ValueError(f"batch_key '{args.batch_key}' not found in adata.obs.")

    embedding = _load_embedding(args.embedding_npy)
    embedding = _align_embedding_to_adata(adata, embedding, args.embedding_cell_names_npy)
    adata.obsm[args.embedding_key] = embedding

    config = {
        "input_h5ad": str(args.input_h5ad),
        "embedding_npy": str(args.embedding_npy),
        "embedding_cell_names_npy": (
            str(args.embedding_cell_names_npy) if args.embedding_cell_names_npy else None
        ),
        "embedding_key": args.embedding_key,
        "label_key": args.label_key,
        "batch_key": args.batch_key,
        "n_jobs": args.n_jobs,
        "n_neighbors": args.n_neighbors,
        "random_state": args.random_state,
        "kmeans_n_init": args.kmeans_n_init,
        "embedding_shape": list(embedding.shape),
    }
    with open(args.output_dir / "config.json", "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2)

    benchmark_single_embedding(
        adata=adata,
        embedding_key=args.embedding_key,
        batch_key=args.batch_key,
        label_key=args.label_key,
        out_dir=args.output_dir,
        n_jobs=args.n_jobs,
        n_neighbors=args.n_neighbors,
        random_state=args.random_state,
        kmeans_n_init=args.kmeans_n_init,
    )


if __name__ == "__main__":
    main()
