
python scripts/train_latent.py \
  --input_h5ad data/cortex.h5ad \
  --results_dir tmp/smoke_results \
  --run_name scene_smoke \
  --layer counts \
  --latent_dim 2 \
  --epochs 2 \
  --device cpu \
  --lr 0.01 \
  --batch_key cell_type \
  --batch_variant lowrank \
  --no_validate


python scripts/train_latent.py \
  --input_h5ad data/cortex.h5ad \
  --results_dir tmp/smoke_results \
  --run_name scene_smoke \
  --layer counts \
  --latent_dim 2 \
  --epochs 2 \
  --device cpu \
  --lr 0.01 \
  --batch_key cell_type \
  --batch_variant lowrank \
  --no_validate \
  --cell_batch_size 8 \