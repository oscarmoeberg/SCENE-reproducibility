#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

# Run in the SCENE_repro environment.
python scripts/train_pca_harmony.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name PCA_seed0 --seed 0 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name PCA_seed1 --seed 1 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name PCA_seed2 --seed 2 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name PCA_seed3 --seed 3 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name PCA_seed4 --seed 4 --embedding_dim 50

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --rank 2 --loss_type ZIP --split_seed 0 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --rank 2 --loss_type ZIP --split_seed 1 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --rank 2 --loss_type ZIP --split_seed 2 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --rank 2 --loss_type ZIP --split_seed 3 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --rank 2 --loss_type ZIP --split_seed 4 --no_validate --pi_only

python scripts/train_scvi.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name scVI_seed0 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cpu --seed 0

python scripts/train_scvi.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name scVI_seed1 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cpu --seed 1

python scripts/train_scvi.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name scVI_seed2 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cpu --seed 2

python scripts/train_scvi.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name scVI_seed3 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cpu --seed 3

python scripts/train_scvi.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name scVI_seed4 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cpu --seed 4

python scripts/train_pca_harmony.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name PCA_seed0 --batch_key cell_source donor --seed 0 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name PCA_seed1 --batch_key cell_source donor --seed 1 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name PCA_seed2 --batch_key cell_source donor --seed 2 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name PCA_seed3 --batch_key cell_source donor --seed 3 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name PCA_seed4 --batch_key cell_source donor --seed 4 --embedding_dim 50

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --split_seed 0 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --split_seed 1 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --split_seed 2 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --split_seed 3 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --split_seed 4 --no_validate --pi_only

python scripts/train_scvi.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scVI_seed0 --out_emb scVI --layer counts --batch_key cell_source donor --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 0

python scripts/train_scvi.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scVI_seed1 --out_emb scVI --layer counts --batch_key cell_source donor --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 1

python scripts/train_scvi.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scVI_seed2 --out_emb scVI --layer counts --batch_key cell_source donor --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 2

python scripts/train_scvi.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scVI_seed3 --out_emb scVI --layer counts --batch_key cell_source donor --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 3

python scripts/train_scvi.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name scVI_seed4 --out_emb scVI --layer counts --batch_key cell_source donor --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 4

python scripts/train_pca_harmony.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name PCA_seed0 --batch_key batch --seed 0 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name PCA_seed1 --batch_key batch --seed 1 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name PCA_seed2 --batch_key batch --seed 2 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name PCA_seed3 --batch_key batch --seed 3 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name PCA_seed4 --batch_key batch --seed 4 --embedding_dim 50

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SCENE_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --batch_keys batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 0 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SCENE_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --batch_keys batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 1 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SCENE_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --batch_keys batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 2 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SCENE_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --batch_keys batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 3 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name SCENE_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --batch_keys batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 4 --no_validate --pi_only

python scripts/train_scvi.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name scVI_seed0 --out_emb scVI --layer counts --batch_key batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cuda --seed 0

python scripts/train_scvi.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name scVI_seed1 --out_emb scVI --layer counts --batch_key batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cuda --seed 1

python scripts/train_scvi.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name scVI_seed2 --out_emb scVI --layer counts --batch_key batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cuda --seed 2

python scripts/train_scvi.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name scVI_seed3 --out_emb scVI --layer counts --batch_key batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cuda --seed 3

python scripts/train_scvi.py --input_h5ad data/neurips_cite_gex.h5ad --results_dir results/neurips_cite --run_name scVI_seed4 --out_emb scVI --layer counts --batch_key batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cuda --seed 4

python scripts/train_pca_harmony.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name PCA_seed0 --seed 0 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name PCA_seed1 --seed 1 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name PCA_seed2 --seed 2 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name PCA_seed3 --seed 3 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name PCA_seed4 --seed 4 --embedding_dim 50

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --rank 2 --loss_type ZIP --split_seed 0 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --rank 2 --loss_type ZIP --split_seed 1 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --rank 2 --loss_type ZIP --split_seed 2 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --rank 2 --loss_type ZIP --split_seed 3 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --rank 2 --loss_type ZIP --split_seed 4 --no_validate --pi_only

python scripts/train_scvi.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name scVI_seed0 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cuda --seed 0

python scripts/train_scvi.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name scVI_seed1 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cuda --seed 1

python scripts/train_scvi.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name scVI_seed2 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cuda --seed 2

python scripts/train_scvi.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name scVI_seed3 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cuda --seed 3

python scripts/train_scvi.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name scVI_seed4 --out_emb scVI --layer counts --n_latent 10 --n_layers 1 --gene_likelihood zinb --max_epochs 400 --device cuda --seed 4

python scripts/train_pca_harmony.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name PCA_seed0 --batch_key Batch --seed 0 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name PCA_seed1 --batch_key Batch --seed 1 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name PCA_seed2 --batch_key Batch --seed 2 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name PCA_seed3 --batch_key Batch --seed 3 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name PCA_seed4 --batch_key Batch --seed 4 --embedding_dim 50

python scripts/train_latent.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SCENE_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --batch_keys Batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 0 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SCENE_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --batch_keys Batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 1 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SCENE_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --batch_keys Batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 2 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SCENE_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --batch_keys Batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 3 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name SCENE_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --batch_keys Batch --batch_variant full --rank 2 --loss_type ZIP --split_seed 4 --no_validate --pi_only

python scripts/train_scvi.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name scVI_seed0 --out_emb scVI --layer counts --batch_key Batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 0

python scripts/train_scvi.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name scVI_seed1 --out_emb scVI --layer counts --batch_key Batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 1

python scripts/train_scvi.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name scVI_seed2 --out_emb scVI --layer counts --batch_key Batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 2

python scripts/train_scvi.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name scVI_seed3 --out_emb scVI --layer counts --batch_key Batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 3

python scripts/train_scvi.py --input_h5ad data/sim1_1_norm.h5ad --results_dir results/sim_1 --run_name scVI_seed4 --out_emb scVI --layer counts --batch_key Batch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 4

python scripts/train_pca_harmony.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name PCA_seed0 --batch_key Batch SubBatch --seed 0 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name PCA_seed1 --batch_key Batch SubBatch --seed 1 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name PCA_seed2 --batch_key Batch SubBatch --seed 2 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name PCA_seed3 --batch_key Batch SubBatch --seed 3 --embedding_dim 50

python scripts/train_pca_harmony.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name PCA_seed4 --batch_key Batch SubBatch --seed 4 --embedding_dim 50

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SCENE_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --batch_keys Batch SubBatch --batch_variant full lowrank --rank 4 --loss_type ZIP --split_seed 0 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SCENE_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --batch_keys Batch SubBatch --batch_variant full lowrank --rank 4 --loss_type ZIP --split_seed 1 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SCENE_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --batch_keys Batch SubBatch --batch_variant full lowrank --rank 4 --loss_type ZIP --split_seed 2 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SCENE_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --batch_keys Batch SubBatch --batch_variant full lowrank --rank 4 --loss_type ZIP --split_seed 3 --no_validate --pi_only

python scripts/train_latent.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name SCENE_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --batch_keys Batch SubBatch --batch_variant full lowrank --rank 4 --loss_type ZIP --split_seed 4 --no_validate --pi_only

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI_seed0 --out_emb scVI --layer counts --batch_key Batch SubBatch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 0

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI_seed1 --out_emb scVI --layer counts --batch_key Batch SubBatch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 1

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI_seed2 --out_emb scVI --layer counts --batch_key Batch SubBatch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 2

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI_seed3 --out_emb scVI --layer counts --batch_key Batch SubBatch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 3

python scripts/train_scvi.py --input_h5ad data/sim2_norm.h5ad --results_dir results/sim_2 --run_name scVI_seed4 --out_emb scVI --layer counts --batch_key Batch SubBatch --n_latent 30 --n_layers 2 --gene_likelihood nb --max_epochs 400 --device cpu --seed 4
