# Data preparation

Run commands from the repository root in `SCENE_repro`. Raw downloads go to
`data/raw/`; prepared matrices go to `data/`. The cortex example is bundled.

| Dataset | Public source | Preparation command | Paper input |
|---|---|---|---|
| Cortex | [Zeisel GSE60361](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE60361), scvi-tools `cortex()` | `python scripts/prepare_data.py cortex` | `cortex.h5ad`: 3,005 × 19,972 |
| HCA nuclei | [Heart Cell Atlas](https://www.heartcellatlas.org/), scvi-tools `heart_cell_atlas_subsampled()` | `python scripts/prepare_data.py hca` | `hca_nuclei.h5ad`: 13,733 × 26,662 |
| PBMC CITE-seq | [Seurat reference distributed through scvi-tools](https://ndownloader.figshare.com/files/27458840), [GSE164378](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE164378) | `python scripts/prepare_data.py pbmc` | `pbmc_cite_seq.h5ad`: 152,094 × 20,729 |
| IFN-beta | [pertpy curated Kang matrix](https://exampledata.scverse.org/pertpy/kang_2018.h5ad) | `python scripts/prepare_data.py kang` | `kang_2018.h5ad`: 24,673 × 15,706 |
| NeurIPS | [GSE194122](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE194122), processed CITE BMMC file | `python scripts/prepare_data.py neurips` | Full GEX: 90,261 × 13,953; lineage subset: 39,860 × 13,953 |
| GR time course | [GSE141834 raw count table](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE141834) | `python scripts/prepare_data.py gr` | Six `GR_XX.h5ad` files, each 400 × 24,128 |
| TCR | [GSE147928](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE147928), stimulated/unstimulated full Seurat objects | R conversion below, then `python scripts/prepare_data.py tcr` | `tcr_stim_data.h5ad`: 9,492 × 17,840 |
| SIM1 | [scIB benchmark archive](https://figshare.com/articles/dataset/12420968), [exact matrix](https://ndownloader.figshare.com/files/33798263) | `python scripts/prepare_data.py sim1` | `sim1_1_norm.h5ad`: 12,097 × 9,979 |
| SIM2 | Same [scIB archive](https://figshare.com/articles/dataset/12420968), [exact matrix](https://ndownloader.figshare.com/files/33798764) | `python scripts/prepare_data.py sim2` | `sim2_norm.h5ad`: 19,318 × 10,000 |

The IFN-beta dataset is downloaded directly from the URL used by the [pertpy loader](https://pertpy.readthedocs.io/en/stable/_modules/pertpy/data/_datasets.html#kang_2018).

## Input preparation

Preparation checks dataset dimensions and cell/gene ordering against
`docs/reference_inputs.json`; count values are not checked by this reference.
Completed outputs are recorded in `data/preparation.json`.

- `X` is retained as distributed. A `counts` layer is added if absent.
  SCENE/scVI use counts; PCA/SIMBA preprocess `X`.
- HCA includes `Sanger-Nuclei` and `Harvard-Nuclei`, with `sample_post`
  recreated before subsetting. Training uses `cell_source` and `donor`.
- PBMC uses the scvi-tools loader's default filtering, retaining 152,094 cells.
- NeurIPS retains GEX features; the lineage subset uses the nine labels listed
  in `prepare_data.py`.
- GR retains cells with at least 200 detected genes and genes detected in at
  least three cells, then splits the six stimulation time points.

## TCR conversion

Download `GSM4450386_stimulated_full_seurat.rds` and
`GSM4450387_unstimulated_full_seurat.rds` from the GEO supplementary archive and
place them in `data/raw/`. Extract only these two files if downloading `GSE147928_RAW.tar`.

```bash
conda env create -f environment_data_r.yaml
conda run -n SCENE_data_r Rscript scripts/prepare_tcr.R data/raw
conda run -n SCENE_repro python scripts/prepare_data.py tcr
```

The R step updates the Seurat objects and exports the counts assay to
AnnData `X`. The Python step converts dtypes and concatenates the two conditions with an
outer join, adding the condition suffix to cell IDs.

## Gene modules and attribution

`data/gr_modules.json` contains the four modules used for the GR
analysis: early/direct GR targets, secondary GR transcription factors,
glycolysis and TCA. Benjamini–Hochberg adjustment is applied across these four
modules separately for each model and time point. Module order also affects the
shared permutation random stream. The paper commands explicitly select
`--permutation_rng shared --n_jobs 1`; the general CLI default remains independent
per-module streams.

`tf_regulons.json` is the frozen positive-weight human DoRothEA A/B reference
used for the TCR analysis. The reference was generated with
`decoupler.op.dorothea(organism="human", levels=["A", "B"])`, retained positive
weights, and selected TFs present in `decoupler.mt.ulm(..., tmin=3)` results.
Targets were deduplicated and sorted. To reproduce the manuscript analysis, use
the supplied gene–TF definitions in `data/tf_regulons.json`.
See [DoRothEA](https://saezlab.github.io/dorothea/) for resource attribution.
The exact original retrieval date/version was not recorded.

The repository MIT license covers its software. Public datasets and external
reference resources retain their original attribution and terms; cite the
original studies listed in the manuscript.
