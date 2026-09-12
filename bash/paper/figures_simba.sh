#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

# Run in the SCENE_repro_simba environment.
python scripts/train_simba.py --input_h5ad data/GR_00.h5ad --results_dir results/geometric_biology --run_name SIMBA_GR_00 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --layer simba --seed 42 --pbg_workers 4 --embedding_dim 50

python scripts/train_simba.py --input_h5ad data/GR_01.h5ad --results_dir results/geometric_biology --run_name SIMBA_GR_01 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --layer simba --seed 42 --pbg_workers 4 --embedding_dim 50

python scripts/train_simba.py --input_h5ad data/GR_02.h5ad --results_dir results/geometric_biology --run_name SIMBA_GR_02 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --layer simba --seed 42 --pbg_workers 4 --embedding_dim 50

python scripts/train_simba.py --input_h5ad data/GR_04.h5ad --results_dir results/geometric_biology --run_name SIMBA_GR_04 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --layer simba --seed 42 --pbg_workers 4 --embedding_dim 50

python scripts/train_simba.py --input_h5ad data/GR_08.h5ad --results_dir results/geometric_biology --run_name SIMBA_GR_08 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --layer simba --seed 42 --pbg_workers 4 --embedding_dim 50

python scripts/train_simba.py --input_h5ad data/GR_18.h5ad --results_dir results/geometric_biology --run_name SIMBA_GR_18 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --layer simba --seed 42 --pbg_workers 4 --embedding_dim 50

python scripts/train_simba.py --input_h5ad data/tcr_stim_data.h5ad --results_dir results/geometric_biology --run_name SIMBA_TCR --out_emb SIMBA --min_n_cells 1 --n_bins 5 --max_bins 100 --normalize_method lib_size --layer simba --pbg_workers 4 --seed 42 --embedding_dim 50

python scripts/train_simba.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SIMBA_2D --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 2 --layer simba --batch_key batch --seed 42 --pbg_workers 4

python scripts/train_simba.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SIMBA_3D --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 3 --layer simba --batch_key batch --seed 42 --pbg_workers 4
