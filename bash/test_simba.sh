python scripts/train_simba.py \
  --input_h5ad data/cortex.h5ad \
  --results_dir tmp/smoke_results \
  --run_name simba_smoke \
  --embedding_dim 2 \
  --min_n_cells 1 \
  --n_bins 3 \
  --max_bins 10 \
  --pbg_workers 1
