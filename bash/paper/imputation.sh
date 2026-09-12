#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

# Output directories used by the supplementary figure notebooks.
python scripts/imputation.py --model scene --data_path data/pbmc_cite_seq.h5ad --results_dir results/imputation --experiment_name pbmc_cite_seq_SCENE_zip --preset naive --epochs 600 --seed 42 --split_seed 42 --device cpu --loss_type ZIP --out_emb SCLDM
mkdir -p results/imputation/pbmc_cite_seq_SCENE_poisson results/imputation/pbmc_cite_seq_scVI
cp results/imputation/pbmc_cite_seq_SCENE_zip/held_out_counts.npz results/imputation/pbmc_cite_seq_SCENE_poisson/held_out_counts.npz
cp results/imputation/pbmc_cite_seq_SCENE_zip/held_out_counts.npz results/imputation/pbmc_cite_seq_scVI/held_out_counts.npz
python scripts/imputation.py --model scene --data_path data/pbmc_cite_seq.h5ad --results_dir results/imputation --experiment_name pbmc_cite_seq_SCENE_poisson --preset naive --epochs 600 --seed 42 --split_seed 42 --device cpu --loss_type poisson --out_emb SCLDM
python scripts/imputation.py --model scvi --data_path data/pbmc_cite_seq.h5ad --results_dir results/imputation --experiment_name pbmc_cite_seq_scVI --preset naive --epochs 400 --seed 42 --split_seed 42 --device cuda
