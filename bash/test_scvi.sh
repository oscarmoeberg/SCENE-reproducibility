python scripts/train_scvi.py \
  --input_h5ad data/cortex.h5ad \
  --results_dir tmp/smoke_results \
  --run_name scvi_smoke \
  --layer counts \
  --n_latent 2 \
  --n_layers 1 \
  --max_epochs 2 \
  --device cpu
