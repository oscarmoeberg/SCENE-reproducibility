#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

# Run in the SCENE_repro environment.
python scripts/train_latent.py --input_h5ad data/GR_00.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_00_2D --latent_dim 2 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/GR_00.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_00_3D --latent_dim 3 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/GR_01.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_01_3D --latent_dim 3 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/GR_02.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_02_3D --latent_dim 3 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/GR_04.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_04_3D --latent_dim 3 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/GR_08.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_08_3D --latent_dim 3 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/GR_18.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_18_2D --latent_dim 2 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/GR_18.h5ad --results_dir results/geometric_biology --run_name scLDM_GR_18_3D --latent_dim 3 --epochs 200 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/tcr_stim_data.h5ad --results_dir results/geometric_biology --run_name scLDM_TCR --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_pca_harmony.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name PCA --seed 42

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scLDM_batch_full_full --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --split_seed 42 --loss_type ZIP --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scLDM_batch_full_full_2D --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scLDM_batch_full_full_3D --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scLDM_no_batch --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scLDM_no_batch_2D --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_scvi.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scVI --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cuda --seed 42

python scripts/train_latent.py --input_h5ad data/kang_2018.h5ad --results_dir results/kang --run_name scLDM --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_pca_harmony.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name PCA_2D --batch_key batch --seed 42 --embedding_dim 2

python scripts/train_pca_harmony.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name PCA_3D --batch_key batch --seed 42 --embedding_dim 3

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name scLDM_batch_full_2D --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name scLDM_batch_full_3D --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_scvi.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name scVI_2D --out_emb scVI --layer counts --batch_key batch --n_latent 2 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 42

python scripts/train_scvi.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name scVI_3D --out_emb scVI --layer counts --batch_key batch --n_latent 3 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 42

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name scLDM_2D --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name scLDM_32D_laplacian --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init laplacian --gene_init laplacian --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scLDM --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 42 --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scLDM_batch_full --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 42 --batch_keys Batch --batch_variant full --rank 2 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scLDM_batch_full_lowrank_4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 42 --batch_keys Batch SubBatch --batch_variant full lowrank --rank 4 --split_seed 42 --loss_type ZIP --validate --pi_only

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cuda --seed 42

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI_batch --out_emb scVI --layer counts --batch_key Batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cuda --seed 42

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI_batch_subbatch --out_emb scVI --layer counts --batch_key Batch SubBatch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cuda --seed 42
