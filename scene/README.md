# SCENE

Reference implementation of the **SCENE** single-cell embedding model used in the
SCENE manuscript.

The model places cells and genes in a shared latent space and parameterises counts
with a zero-inflated Poisson (or Poisson) likelihood, optionally accounting for one
or more hierarchical batch effects.

## Install

From the repository root:

```bash
pip install -e ./scene
```

## Usage

```python
import anndata as ad
import scene

adata = ad.read_h5ad("data/cortex.h5ad")
adata, val_results = scene.train_scene(
    adata,
    layer="counts",
    latent_dim=16,
)
# learned cell / gene embeddings:
adata.obsm["SCENE"]   # cells
adata.varm["SCENE"]   # genes
```

Public API: `scene.SCENE`, `scene.train_scene`,
`scene.reconstruct_rates_from_adata`, `scene.laplacian_init`.
