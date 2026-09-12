# SCENE reproducibility

Model implementation, dataset preparation, run commands, and figure notebooks
for *Setting the SCENE for Interpretable Cell–Gene Embeddings in Single-Cell
RNA-seq*.

## Install

```bash
conda env create -f environment_scene.yaml
conda activate SCENE_repro
pip install -e ./scene
python -c "import scene; print(scene.SCENE, scene.train_scene)"
```

SIMBA uses a separate environment because of its dependency constraints:

```bash
conda env create -f environment_simba.yaml
```

Only TCR preparation needs R; its conversion commands and separate environment
are described in [DATA.md](docs/DATA.md). The model API provides
`scene.SCENE`, `scene.train_scene`, `scene.reconstruct_rates_from_adata`, and
`scene.laplacian_init`.

## Small example

The bundled `data/cortex.h5ad` contains raw integer counts in `X` and biological
labels in `obs['cell_type']`. Training uses `layers['counts']` when present and
otherwise falls back to `X`. This example is a short execution check.

```bash
python scripts/train_latent.py \
  --input_h5ad data/cortex.h5ad --results_dir results --run_name example \
  --latent_dim 3 --epochs 2 --subset 100 --device cpu --seed 42

```

Training writes cell/gene embeddings and their identifiers, learned parameters,
run configuration, and validation results under `results/<run_name>/`.
Downstream commands read these exported arrays; the input `.h5ad` is unchanged.

## Reproduce the paper

Prepare the datasets using [DATA.md](docs/DATA.md), then run these commands
from the repository root in order:

```bash
conda activate SCENE_repro
bash bash/paper/figures.sh
bash bash/paper/benchmarks.sh
bash bash/paper/dimensions.sh
bash bash/paper/imputation.sh

conda activate SCENE_repro_simba
bash bash/paper/figures_simba.sh
bash bash/paper/benchmarks_simba.sh

conda activate SCENE_repro
bash bash/paper/evaluate_benchmarks.sh
bash bash/paper/evaluate_modules.sh
bash bash/paper/figures_all.sh
```

Figures, legends, and numerical tables are saved under
`notebooks/figures/output/`; executed notebooks are saved under `tmp/executed/`.
Large inputs and results are downloaded/generated locally and excluded from Git.

Full runs require substantial memory. Some training commands specify CUDA
and require a compatible GPU.

## Tests

```bash
python -m pytest -q tests
```

These tests cover small SCENE fits, hierarchical batch effects, reconstruction,
embedding alignment, PCA dimensions, and shared-mask SCENE/scVI imputation.

## Layout

- `scene/`: installable model implementation.
- `scripts/`: analysis scripts, data preparation, and notebook execution.
- `bash/paper/`: manuscript training and evaluation commands.
- `notebooks/`: paper figure generation and dataset QC.
- `data/`: cortex example and frozen module definitions.
- `docs/`: data preparation instructions and input, run, and module reference manifests.

Software is MIT licensed. Cite the manuscript and original dataset/reference
studies; external data retain their original attribution and terms.
