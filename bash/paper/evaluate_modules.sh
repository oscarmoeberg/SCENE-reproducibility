#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

python scripts/eval_gene_module.py --input_h5ad data/GR_00.h5ad --embedding_npy results/geometric_biology/SIMBA_GR_00/SIMBA_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/SIMBA_GR_00/SIMBA_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/SIMBA_GR_00/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_01.h5ad --embedding_npy results/geometric_biology/SIMBA_GR_01/SIMBA_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/SIMBA_GR_01/SIMBA_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/SIMBA_GR_01/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_02.h5ad --embedding_npy results/geometric_biology/SIMBA_GR_02/SIMBA_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/SIMBA_GR_02/SIMBA_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/SIMBA_GR_02/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_04.h5ad --embedding_npy results/geometric_biology/SIMBA_GR_04/SIMBA_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/SIMBA_GR_04/SIMBA_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/SIMBA_GR_04/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_08.h5ad --embedding_npy results/geometric_biology/SIMBA_GR_08/SIMBA_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/SIMBA_GR_08/SIMBA_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/SIMBA_GR_08/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_18.h5ad --embedding_npy results/geometric_biology/SIMBA_GR_18/SIMBA_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/SIMBA_GR_18/SIMBA_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/SIMBA_GR_18/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/tcr_stim_data.h5ad --embedding_npy results/geometric_biology/SIMBA_TCR/SIMBA_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/SIMBA_TCR/SIMBA_gene_names.npy --module_json data/tf_regulons.json --output_csv results/geometric_biology/SIMBA_TCR/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng independent

python scripts/eval_gene_module.py --input_h5ad data/GR_00.h5ad --embedding_npy results/geometric_biology/scLDM_GR_00_3D/scLDM_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/scLDM_GR_00_3D/scLDM_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/scLDM_GR_00_3D/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_01.h5ad --embedding_npy results/geometric_biology/scLDM_GR_01_3D/scLDM_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/scLDM_GR_01_3D/scLDM_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/scLDM_GR_01_3D/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_02.h5ad --embedding_npy results/geometric_biology/scLDM_GR_02_3D/scLDM_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/scLDM_GR_02_3D/scLDM_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/scLDM_GR_02_3D/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_04.h5ad --embedding_npy results/geometric_biology/scLDM_GR_04_3D/scLDM_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/scLDM_GR_04_3D/scLDM_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/scLDM_GR_04_3D/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_08.h5ad --embedding_npy results/geometric_biology/scLDM_GR_08_3D/scLDM_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/scLDM_GR_08_3D/scLDM_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/scLDM_GR_08_3D/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/GR_18.h5ad --embedding_npy results/geometric_biology/scLDM_GR_18_3D/scLDM_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/scLDM_GR_18_3D/scLDM_gene_names.npy --module_json data/gr_modules.json --output_csv results/geometric_biology/scLDM_GR_18_3D/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng shared

python scripts/eval_gene_module.py --input_h5ad data/tcr_stim_data.h5ad --embedding_npy results/geometric_biology/scLDM_TCR/scLDM_gene_latent.npy --embedding_gene_names_npy results/geometric_biology/scLDM_TCR/scLDM_gene_names.npy --module_json data/tf_regulons.json --output_csv results/geometric_biology/scLDM_TCR/gene_module_eval.csv --n_perm 10000 --seed 42 --n_jobs 1 --permutation_rng independent
