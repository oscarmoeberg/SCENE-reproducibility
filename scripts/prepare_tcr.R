# Convert the two original GEO Seurat objects before prepare_data.py tcr.
library(Seurat)
library(SingleCellExperiment)
library(zellkonverter)

args <- commandArgs(trailingOnly = TRUE)
raw_dir <- if (length(args)) args[1] else "data/raw"
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

samples <- c("GSM4450386_stimulated", "GSM4450387_unstimulated")
for (sample in samples) {
    input <- file.path(raw_dir, paste0(sample, "_full_seurat.rds"))
    obj <- UpdateSeuratObject(readRDS(input))
    sce <- as.SingleCellExperiment(obj)
    writeH5AD(sce, file = file.path(raw_dir, paste0(sample, ".h5ad")), X_name = "counts")
}
