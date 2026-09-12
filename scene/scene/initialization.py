# file: scene/initialization.py
from scipy import sparse
from scipy.sparse.linalg import svds
import numpy as np
import torch.nn as nn
import torch


__all__ = ["bipartite_laplacian_from_svd", "laplacian_init"]

def bipartite_laplacian_from_svd(B: sparse.csr_matrix, k: int, tol: float = 1e-4):
    m, n = B.shape
    du = np.asarray(B.sum(axis=1)).ravel()
    dv = np.asarray(B.sum(axis=0)).ravel()

    # protect against zeros
    du_safe = np.where(du == 0, 1.0, du)
    dv_safe = np.where(dv == 0, 1.0, dv)

    Du_mhalf = sparse.diags(1.0 / np.sqrt(du_safe))
    Dv_mhalf = sparse.diags(1.0 / np.sqrt(dv_safe))

    B_tilde = Du_mhalf @ B @ Dv_mhalf          # (m × n)

    # 1) Ask for k+1 largest‐magnitude singular values,
    u_all, s_all, vt_all = svds(B_tilde, k=k+1, which="LM", tol=tol)

    # 2) Sort descending by σ:
    idx_all = np.argsort(s_all)[::-1]
    s_all = s_all[idx_all]
    u_all = u_all[:, idx_all]
    vt_all = vt_all[idx_all, :]

    # 3) Drop the very first singular value/vector (the trivial σ≈1).
    #    Keep the next k largest.
    s = s_all[1:]       # length k
    u = u_all[:, 1:]    # (m × k)
    vt = vt_all[1:, :]  # (k × n)

    lam = 1.0 - s                               # λ = 1 − σ

    left  = (u * (1.0 / np.sqrt(du_safe))[:, None]) / np.sqrt(2.0)
    right = (vt.T * (1.0 / np.sqrt(dv_safe))[:, None]) / np.sqrt(2.0)

    U = np.concatenate([left, right], axis=0)   # (m+n, k)
    return lam, U


def laplacian_init(B: sparse.csr_matrix, k: int):
    """
    Convenience wrapper that splits the eigenvectors into
    separate cell- and gene-blocks ready to pass to SCENE.
    """
    _, U = bipartite_laplacian_from_svd(B, k)
    n_cells = B.shape[0]
    Z_cells = U[:n_cells, :].astype(np.float32)
    Z_genes = U[n_cells:, :].astype(np.float32)
    return Z_cells, Z_genes

