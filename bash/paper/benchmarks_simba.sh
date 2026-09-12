#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

# Run in the SCENE_repro_simba environment.
python scripts/train_simba.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SIMBA_seed0 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 0 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SIMBA_seed1 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 1 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SIMBA_seed2 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 2 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SIMBA_seed3 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 3 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SIMBA_seed4 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 4 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SIMBA_seed0 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key cell_source donor --seed 0 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SIMBA_seed1 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key cell_source donor --seed 1 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SIMBA_seed2 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key cell_source donor --seed 2 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SIMBA_seed3 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key cell_source donor --seed 3 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SIMBA_seed4 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key cell_source donor --seed 4 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SIMBA_seed0 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key batch --seed 0 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SIMBA_seed1 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key batch --seed 1 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SIMBA_seed2 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key batch --seed 2 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SIMBA_seed3 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key batch --seed 3 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SIMBA_seed4 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key batch --seed 4 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SIMBA_seed0 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 0 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SIMBA_seed1 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 1 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SIMBA_seed2 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 2 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SIMBA_seed3 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 3 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SIMBA_seed4 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --seed 4 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SIMBA_seed0 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch --seed 0 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SIMBA_seed1 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch --seed 1 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SIMBA_seed2 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch --seed 2 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SIMBA_seed3 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch --seed 3 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SIMBA_seed4 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch --seed 4 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SIMBA_seed0 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch SubBatch --seed 0 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SIMBA_seed1 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch SubBatch --seed 1 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SIMBA_seed2 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch SubBatch --seed 2 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SIMBA_seed3 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch SubBatch --seed 3 --pbg_workers 12

python scripts/train_simba.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SIMBA_seed4 --out_emb SIMBA --min_n_cells 3 --n_bins 5 --max_bins 100 --normalize_method lib_size --embedding_dim 50 --layer simba --batch_key Batch SubBatch --seed 4 --pbg_workers 12
