#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python scripts/render_notebooks.py notebooks/figures/fig_*.ipynb notebooks/figures/app_low_dim_comparison.ipynb notebooks/figures/app_imputation.ipynb notebooks/figures/app_zero_inflation.ipynb notebooks/paper_data_qc_metrics.ipynb
python scripts/write_paper_tables.py
