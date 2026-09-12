#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

# Run in the SCENE_repro environment.
python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_16D_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_16D_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_16D_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_16D_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_16D_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_2D_seed0 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_2D_seed1 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_2D_seed2 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_2D_seed3 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_2D_seed4 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_32D_seed0 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_32D_seed1 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_32D_seed2 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_32D_seed3 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_32D_seed4 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_3D_seed0 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_3D_seed1 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_3D_seed2 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_3D_seed3 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_3D_seed4 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_64D_seed0 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_64D_seed1 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_64D_seed2 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_64D_seed3 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_64D_seed4 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_8D_seed0 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_8D_seed1 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_8D_seed2 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_8D_seed3 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/cortex.h5ad --results_dir results/cortex --run_name SCENE_8D_seed4 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_16D_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_16D_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_16D_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_16D_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_16D_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_2D_seed0 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_2D_seed1 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_2D_seed2 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_2D_seed3 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_2D_seed4 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_32D_seed0 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_32D_seed1 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_32D_seed2 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_32D_seed3 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_32D_seed4 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_3D_seed0 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_3D_seed1 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_3D_seed2 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_3D_seed3 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_3D_seed4 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_64D_seed0 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_64D_seed1 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_64D_seed2 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_64D_seed3 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_64D_seed4 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_8D_seed0 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_8D_seed1 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_8D_seed2 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_8D_seed3 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/hca_nuclei.h5ad --results_dir results/hca_nuclei --run_name SCENE_8D_seed4 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys cell_source donor --batch_variant full full --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_16D_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_16D_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_16D_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_16D_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_16D_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_2D_seed0 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_2D_seed1 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_2D_seed2 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_2D_seed3 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_2D_seed4 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_32D_seed0 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_32D_seed1 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_32D_seed2 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_32D_seed3 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_32D_seed4 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_3D_seed0 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_3D_seed1 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_3D_seed2 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_3D_seed3 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_3D_seed4 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_64D_seed0 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_64D_seed1 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_64D_seed2 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_64D_seed3 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_64D_seed4 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_8D_seed0 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_8D_seed1 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_8D_seed2 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_8D_seed3 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/neurips_cite_gex_stem_cells.h5ad --results_dir results/neurips_cite_stem_cells --run_name SCENE_8D_seed4 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --batch_keys batch --batch_variant lowrank --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_16D_seed0 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_16D_seed1 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_16D_seed2 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_16D_seed3 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_16D_seed4 --latent_dim 16 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_2D_seed0 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_2D_seed1 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_2D_seed2 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_2D_seed3 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_2D_seed4 --latent_dim 2 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_32D_seed0 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_32D_seed1 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_32D_seed2 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_32D_seed3 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_32D_seed4 --latent_dim 32 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_3D_seed0 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_3D_seed1 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_3D_seed2 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_3D_seed3 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_3D_seed4 --latent_dim 3 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_64D_seed0 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_64D_seed1 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_64D_seed2 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_64D_seed3 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_64D_seed4 --latent_dim 64 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_8D_seed0 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 0 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_8D_seed1 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 1 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_8D_seed2 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 2 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_8D_seed3 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 3 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only

python scripts/train_latent.py --input_h5ad data/pbmc_cite_seq.h5ad --results_dir results/pbmc_cite_seq --run_name SCENE_8D_seed4 --latent_dim 8 --epochs 600 --device cpu --lr 0.05 --layer counts --out_emb scLDM --cell_init random --gene_init random --seed 4 --split_seed 42 --rank 2 --loss_type ZIP --validate --pi_only
