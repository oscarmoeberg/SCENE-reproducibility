#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

# Run in the SCENE_repro environment.
python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/PCA_seed0/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_vanilla --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/PCA_seed0/benchmark --embedding_cell_names_npy results/cortex/PCA_seed0/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/PCA_seed1/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_vanilla --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/PCA_seed1/benchmark --embedding_cell_names_npy results/cortex/PCA_seed1/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/PCA_seed2/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_vanilla --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/PCA_seed2/benchmark --embedding_cell_names_npy results/cortex/PCA_seed2/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/PCA_seed3/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_vanilla --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/PCA_seed3/benchmark --embedding_cell_names_npy results/cortex/PCA_seed3/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/PCA_seed4/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_vanilla --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/PCA_seed4/benchmark --embedding_cell_names_npy results/cortex/PCA_seed4/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SCENE_seed0/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SCENE_seed0/benchmark --embedding_cell_names_npy results/cortex/SCENE_seed0/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SCENE_seed1/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SCENE_seed1/benchmark --embedding_cell_names_npy results/cortex/SCENE_seed1/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SCENE_seed2/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SCENE_seed2/benchmark --embedding_cell_names_npy results/cortex/SCENE_seed2/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SCENE_seed3/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SCENE_seed3/benchmark --embedding_cell_names_npy results/cortex/SCENE_seed3/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SCENE_seed4/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SCENE_seed4/benchmark --embedding_cell_names_npy results/cortex/SCENE_seed4/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SIMBA_seed0/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SIMBA_seed0/benchmark --embedding_cell_names_npy results/cortex/SIMBA_seed0/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SIMBA_seed1/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SIMBA_seed1/benchmark --embedding_cell_names_npy results/cortex/SIMBA_seed1/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SIMBA_seed2/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SIMBA_seed2/benchmark --embedding_cell_names_npy results/cortex/SIMBA_seed2/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SIMBA_seed3/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SIMBA_seed3/benchmark --embedding_cell_names_npy results/cortex/SIMBA_seed3/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/SIMBA_seed4/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/SIMBA_seed4/benchmark --embedding_cell_names_npy results/cortex/SIMBA_seed4/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/scVI_seed0/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/scVI_seed0/benchmark --embedding_cell_names_npy results/cortex/scVI_seed0/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/scVI_seed1/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/scVI_seed1/benchmark --embedding_cell_names_npy results/cortex/scVI_seed1/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/scVI_seed2/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/scVI_seed2/benchmark --embedding_cell_names_npy results/cortex/scVI_seed2/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/scVI_seed3/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/scVI_seed3/benchmark --embedding_cell_names_npy results/cortex/scVI_seed3/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/cortex.h5ad --embedding_npy results/cortex/scVI_seed4/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key cell_type --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/cortex/scVI_seed4/benchmark --embedding_cell_names_npy results/cortex/scVI_seed4/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/PCA_seed0/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/PCA_seed0/benchmark --embedding_cell_names_npy results/hca_nuclei/PCA_seed0/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/PCA_seed1/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/PCA_seed1/benchmark --embedding_cell_names_npy results/hca_nuclei/PCA_seed1/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/PCA_seed2/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/PCA_seed2/benchmark --embedding_cell_names_npy results/hca_nuclei/PCA_seed2/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/PCA_seed3/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/PCA_seed3/benchmark --embedding_cell_names_npy results/hca_nuclei/PCA_seed3/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/PCA_seed4/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/PCA_seed4/benchmark --embedding_cell_names_npy results/hca_nuclei/PCA_seed4/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SCENE_seed0/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SCENE_seed0/benchmark --embedding_cell_names_npy results/hca_nuclei/SCENE_seed0/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SCENE_seed1/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SCENE_seed1/benchmark --embedding_cell_names_npy results/hca_nuclei/SCENE_seed1/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SCENE_seed2/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SCENE_seed2/benchmark --embedding_cell_names_npy results/hca_nuclei/SCENE_seed2/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SCENE_seed3/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SCENE_seed3/benchmark --embedding_cell_names_npy results/hca_nuclei/SCENE_seed3/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SCENE_seed4/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SCENE_seed4/benchmark --embedding_cell_names_npy results/hca_nuclei/SCENE_seed4/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SIMBA_seed0/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SIMBA_seed0/benchmark --embedding_cell_names_npy results/hca_nuclei/SIMBA_seed0/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SIMBA_seed1/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SIMBA_seed1/benchmark --embedding_cell_names_npy results/hca_nuclei/SIMBA_seed1/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SIMBA_seed2/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SIMBA_seed2/benchmark --embedding_cell_names_npy results/hca_nuclei/SIMBA_seed2/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SIMBA_seed3/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SIMBA_seed3/benchmark --embedding_cell_names_npy results/hca_nuclei/SIMBA_seed3/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/SIMBA_seed4/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/SIMBA_seed4/benchmark --embedding_cell_names_npy results/hca_nuclei/SIMBA_seed4/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/scVI_seed0/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/scVI_seed0/benchmark --embedding_cell_names_npy results/hca_nuclei/scVI_seed0/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/scVI_seed1/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/scVI_seed1/benchmark --embedding_cell_names_npy results/hca_nuclei/scVI_seed1/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/scVI_seed2/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/scVI_seed2/benchmark --embedding_cell_names_npy results/hca_nuclei/scVI_seed2/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/scVI_seed3/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/scVI_seed3/benchmark --embedding_cell_names_npy results/hca_nuclei/scVI_seed3/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/hca_nuclei.h5ad --embedding_npy results/hca_nuclei/scVI_seed4/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key donor --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/hca_nuclei/scVI_seed4/benchmark --embedding_cell_names_npy results/hca_nuclei/scVI_seed4/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/PCA_seed0/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/PCA_seed0/benchmark --embedding_cell_names_npy results/neurips_cite/PCA_seed0/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/PCA_seed1/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/PCA_seed1/benchmark --embedding_cell_names_npy results/neurips_cite/PCA_seed1/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/PCA_seed2/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/PCA_seed2/benchmark --embedding_cell_names_npy results/neurips_cite/PCA_seed2/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/PCA_seed3/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/PCA_seed3/benchmark --embedding_cell_names_npy results/neurips_cite/PCA_seed3/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/PCA_seed4/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/PCA_seed4/benchmark --embedding_cell_names_npy results/neurips_cite/PCA_seed4/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SCENE_seed0/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SCENE_seed0/benchmark --embedding_cell_names_npy results/neurips_cite/SCENE_seed0/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SCENE_seed1/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SCENE_seed1/benchmark --embedding_cell_names_npy results/neurips_cite/SCENE_seed1/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SCENE_seed2/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SCENE_seed2/benchmark --embedding_cell_names_npy results/neurips_cite/SCENE_seed2/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SCENE_seed3/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SCENE_seed3/benchmark --embedding_cell_names_npy results/neurips_cite/SCENE_seed3/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SCENE_seed4/scLDM_cell_latent.npy --embedding_key scLDM --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SCENE_seed4/benchmark --embedding_cell_names_npy results/neurips_cite/SCENE_seed4/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SIMBA_seed0/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SIMBA_seed0/benchmark --embedding_cell_names_npy results/neurips_cite/SIMBA_seed0/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SIMBA_seed1/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SIMBA_seed1/benchmark --embedding_cell_names_npy results/neurips_cite/SIMBA_seed1/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SIMBA_seed2/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SIMBA_seed2/benchmark --embedding_cell_names_npy results/neurips_cite/SIMBA_seed2/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SIMBA_seed3/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SIMBA_seed3/benchmark --embedding_cell_names_npy results/neurips_cite/SIMBA_seed3/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/SIMBA_seed4/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/SIMBA_seed4/benchmark --embedding_cell_names_npy results/neurips_cite/SIMBA_seed4/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/scVI_seed0/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/scVI_seed0/benchmark --embedding_cell_names_npy results/neurips_cite/scVI_seed0/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/scVI_seed1/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/scVI_seed1/benchmark --embedding_cell_names_npy results/neurips_cite/scVI_seed1/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/scVI_seed2/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/scVI_seed2/benchmark --embedding_cell_names_npy results/neurips_cite/scVI_seed2/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/scVI_seed3/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/scVI_seed3/benchmark --embedding_cell_names_npy results/neurips_cite/scVI_seed3/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/neurips_cite_gex.h5ad --embedding_npy results/neurips_cite/scVI_seed4/scVI_cell_latent.npy --embedding_key scVI --label_key cell_type --batch_key batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/neurips_cite/scVI_seed4/benchmark --embedding_cell_names_npy results/neurips_cite/scVI_seed4/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/PCA_seed0/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_harmony --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/PCA_seed0/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/PCA_seed0/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/PCA_seed1/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_harmony --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/PCA_seed1/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/PCA_seed1/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/PCA_seed2/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_harmony --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/PCA_seed2/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/PCA_seed2/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/PCA_seed3/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_harmony --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/PCA_seed3/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/PCA_seed3/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/PCA_seed4/X_pca_vanilla_cell_latent.npy --embedding_key X_pca_harmony --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/PCA_seed4/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/PCA_seed4/X_pca_vanilla_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SCENE_seed0/scLDM_cell_latent.npy --embedding_key scLDM --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SCENE_seed0/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SCENE_seed0/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SCENE_seed1/scLDM_cell_latent.npy --embedding_key scLDM --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SCENE_seed1/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SCENE_seed1/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SCENE_seed2/scLDM_cell_latent.npy --embedding_key scLDM --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SCENE_seed2/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SCENE_seed2/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SCENE_seed3/scLDM_cell_latent.npy --embedding_key scLDM --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SCENE_seed3/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SCENE_seed3/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SCENE_seed4/scLDM_cell_latent.npy --embedding_key scLDM --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SCENE_seed4/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SCENE_seed4/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SIMBA_seed0/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SIMBA_seed0/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SIMBA_seed0/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SIMBA_seed1/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SIMBA_seed1/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SIMBA_seed1/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SIMBA_seed2/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SIMBA_seed2/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SIMBA_seed2/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SIMBA_seed3/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SIMBA_seed3/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SIMBA_seed3/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/SIMBA_seed4/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/SIMBA_seed4/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/SIMBA_seed4/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/scVI_seed0/scVI_cell_latent.npy --embedding_key scVI --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/scVI_seed0/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/scVI_seed0/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/scVI_seed1/scVI_cell_latent.npy --embedding_key scVI --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/scVI_seed1/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/scVI_seed1/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/scVI_seed2/scVI_cell_latent.npy --embedding_key scVI --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/scVI_seed2/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/scVI_seed2/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/scVI_seed3/scVI_cell_latent.npy --embedding_key scVI --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/scVI_seed3/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/scVI_seed3/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/pbmc_cite_seq.h5ad --embedding_npy results/pbmc_cite_seq/scVI_seed4/scVI_cell_latent.npy --embedding_key scVI --label_key celltype.l2 --batch_key celltype.l2 --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/pbmc_cite_seq/scVI_seed4/benchmark --embedding_cell_names_npy results/pbmc_cite_seq/scVI_seed4/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/PCA_seed0/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/PCA_seed0/benchmark --embedding_cell_names_npy results/sim_1/PCA_seed0/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/PCA_seed1/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/PCA_seed1/benchmark --embedding_cell_names_npy results/sim_1/PCA_seed1/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/PCA_seed2/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/PCA_seed2/benchmark --embedding_cell_names_npy results/sim_1/PCA_seed2/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/PCA_seed3/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/PCA_seed3/benchmark --embedding_cell_names_npy results/sim_1/PCA_seed3/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/PCA_seed4/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/PCA_seed4/benchmark --embedding_cell_names_npy results/sim_1/PCA_seed4/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SCENE_seed0/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SCENE_seed0/benchmark --embedding_cell_names_npy results/sim_1/SCENE_seed0/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SCENE_seed1/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SCENE_seed1/benchmark --embedding_cell_names_npy results/sim_1/SCENE_seed1/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SCENE_seed2/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SCENE_seed2/benchmark --embedding_cell_names_npy results/sim_1/SCENE_seed2/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SCENE_seed3/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SCENE_seed3/benchmark --embedding_cell_names_npy results/sim_1/SCENE_seed3/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SCENE_seed4/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SCENE_seed4/benchmark --embedding_cell_names_npy results/sim_1/SCENE_seed4/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SIMBA_seed0/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SIMBA_seed0/benchmark --embedding_cell_names_npy results/sim_1/SIMBA_seed0/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SIMBA_seed1/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SIMBA_seed1/benchmark --embedding_cell_names_npy results/sim_1/SIMBA_seed1/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SIMBA_seed2/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SIMBA_seed2/benchmark --embedding_cell_names_npy results/sim_1/SIMBA_seed2/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SIMBA_seed3/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SIMBA_seed3/benchmark --embedding_cell_names_npy results/sim_1/SIMBA_seed3/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/SIMBA_seed4/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/SIMBA_seed4/benchmark --embedding_cell_names_npy results/sim_1/SIMBA_seed4/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/scVI_seed0/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/scVI_seed0/benchmark --embedding_cell_names_npy results/sim_1/scVI_seed0/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/scVI_seed1/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/scVI_seed1/benchmark --embedding_cell_names_npy results/sim_1/scVI_seed1/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/scVI_seed2/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/scVI_seed2/benchmark --embedding_cell_names_npy results/sim_1/scVI_seed2/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/scVI_seed3/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/scVI_seed3/benchmark --embedding_cell_names_npy results/sim_1/scVI_seed3/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim1_1_norm.h5ad --embedding_npy results/sim_1/scVI_seed4/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key Batch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_1/scVI_seed4/benchmark --embedding_cell_names_npy results/sim_1/scVI_seed4/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/PCA_seed0/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/PCA_seed0/benchmark --embedding_cell_names_npy results/sim_2/PCA_seed0/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/PCA_seed1/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/PCA_seed1/benchmark --embedding_cell_names_npy results/sim_2/PCA_seed1/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/PCA_seed2/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/PCA_seed2/benchmark --embedding_cell_names_npy results/sim_2/PCA_seed2/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/PCA_seed3/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/PCA_seed3/benchmark --embedding_cell_names_npy results/sim_2/PCA_seed3/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/PCA_seed4/X_pca_harmony_cell_latent.npy --embedding_key X_pca_harmony --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/PCA_seed4/benchmark --embedding_cell_names_npy results/sim_2/PCA_seed4/X_pca_harmony_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SCENE_seed0/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SCENE_seed0/benchmark --embedding_cell_names_npy results/sim_2/SCENE_seed0/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SCENE_seed1/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SCENE_seed1/benchmark --embedding_cell_names_npy results/sim_2/SCENE_seed1/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SCENE_seed2/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SCENE_seed2/benchmark --embedding_cell_names_npy results/sim_2/SCENE_seed2/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SCENE_seed3/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SCENE_seed3/benchmark --embedding_cell_names_npy results/sim_2/SCENE_seed3/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SCENE_seed4/scLDM_cell_latent.npy --embedding_key scLDM --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SCENE_seed4/benchmark --embedding_cell_names_npy results/sim_2/SCENE_seed4/scLDM_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SIMBA_seed0/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SIMBA_seed0/benchmark --embedding_cell_names_npy results/sim_2/SIMBA_seed0/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SIMBA_seed1/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SIMBA_seed1/benchmark --embedding_cell_names_npy results/sim_2/SIMBA_seed1/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SIMBA_seed2/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SIMBA_seed2/benchmark --embedding_cell_names_npy results/sim_2/SIMBA_seed2/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SIMBA_seed3/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SIMBA_seed3/benchmark --embedding_cell_names_npy results/sim_2/SIMBA_seed3/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/SIMBA_seed4/SIMBA_cell_latent.npy --embedding_key SIMBA --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/SIMBA_seed4/benchmark --embedding_cell_names_npy results/sim_2/SIMBA_seed4/SIMBA_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/scVI_seed0/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/scVI_seed0/benchmark --embedding_cell_names_npy results/sim_2/scVI_seed0/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/scVI_seed1/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/scVI_seed1/benchmark --embedding_cell_names_npy results/sim_2/scVI_seed1/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/scVI_seed2/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/scVI_seed2/benchmark --embedding_cell_names_npy results/sim_2/scVI_seed2/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/scVI_seed3/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/scVI_seed3/benchmark --embedding_cell_names_npy results/sim_2/scVI_seed3/scVI_cell_names.npy

python scripts/benchmark_embedding.py --input_h5ad data/sim2_norm.h5ad --embedding_npy results/sim_2/scVI_seed4/scVI_cell_latent.npy --embedding_key scVI --label_key Group --batch_key SubBatch --n_neighbors 15 --random_state 0 --kmeans_n_init 20 --output_dir results/sim_2/scVI_seed4/benchmark --embedding_cell_names_npy results/sim_2/scVI_seed4/scVI_cell_names.npy
