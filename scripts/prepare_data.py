"""Prepare the public count matrices used by the SCENE paper."""
import argparse
import gzip
import hashlib
import json
import shutil
from pathlib import Path
from urllib.request import Request, urlopen

import anndata as ad
import numpy as np
import pandas as pd
import scanpy as sc


GEO = "https://ftp.ncbi.nlm.nih.gov/geo/series"
NEURIPS = "GSE194122_openproblems_neurips2021_cite_BMMC_processed.h5ad"
STEM_TYPES = ["Reticulocyte", "Erythroblast", "Proerythroblast", "Normoblast",
              "G/M prog", "HSC", "MK/E prog", "CD14+ Mono", "CD16+ Mono"]


def download(url, path):
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        print(f"Downloading {url}")
        partial = path.with_suffix(path.suffix + ".part")
        request = Request(url, headers={"User-Agent": "SCENE-reproducibility/0.1"})
        with urlopen(request) as response, partial.open("wb") as target:
            shutil.copyfileobj(response, target)
        partial.replace(path)
    return path


def unpack(path):
    output = path.with_suffix("")
    if not output.exists():
        with gzip.open(path, "rb") as source, output.open("wb") as target:
            shutil.copyfileobj(source, target)
    return output


def save(adata, path, source):
    # PCA/SIMBA preprocess X as distributed.
    # SCENE/scVI use the counts layer, including for normalized NeurIPS/SIM data.
    if "counts" not in adata.layers:
        adata.layers["counts"] = adata.X.copy()
    record = {
        "source": source,
        "shape": list(adata.shape),
        "cell_names_sha256": hashlib.sha256("\n".join(adata.obs_names).encode()).hexdigest(),
        "gene_names_sha256": hashlib.sha256("\n".join(adata.var_names).encode()).hexdigest(),
    }
    reference = json.loads((Path(__file__).resolve().parents[1] / "docs/reference_inputs.json").read_text())
    if path.name in reference:
        for key in ("shape", "cell_names_sha256", "gene_names_sha256"):
            if record[key] != reference[path.name][key]:
                raise ValueError(f"{path.name}: {key} differs from the paper input; inspect the source version before training.")
    adata.write_h5ad(path, compression="gzip")
    manifest = path.parent / "preparation.json"
    records = json.loads(manifest.read_text()) if manifest.exists() else {}
    records[path.name] = record
    manifest.write_text(json.dumps(records, indent=2) + "\n")
    print(f"Saved {path}: {adata.shape}")


def prepare_gr(raw, output):
    name = "GSE141834_scRNAseq_rawCounts.txt"
    path = raw / name
    if not path.exists():
        path = unpack(download(f"{GEO}/GSE141nnn/GSE141834/suppl/{name}.gz", raw / (name + ".gz")))
    df = pd.read_csv(path, sep="\t", index_col=0)
    a = ad.AnnData(df.T)
    a.var_names_make_unique()
    a.var["mt"] = a.var_names.str.upper().str.startswith("MT-")
    a.var["ribo"] = a.var_names.str.upper().str.startswith(("RPS", "RPL"))
    a.var["hb"] = a.var_names.str.upper().str.match(r"^HB(?!P)")
    sc.pp.calculate_qc_metrics(a, qc_vars=["mt", "ribo", "hb"], percent_top=None, log1p=False)
    sc.pp.filter_cells(a, min_genes=200)
    sc.pp.filter_genes(a, min_cells=3)
    a.obs["time_code"] = a.obs_names.str[:6]
    code = a.obs_names.str.extract(r"^(Dex\.\d{2})", expand=False)
    time_map = {f"Dex.{t:02d}": t for t in [0, 1, 2, 4, 8, 18]}
    a = a[code.isin(time_map)].copy()
    a.obs["dex_code"] = code[code.isin(time_map)].values
    a.obs["time_hr"] = a.obs["dex_code"].map(time_map).astype(int)
    a.obs["time_label"] = a.obs["time_hr"].astype(str) + "hr"
    for code, hour in time_map.items():
        save(a[a.obs.dex_code == code].copy(), output / f"GR_{hour:02d}.h5ad", "GSE141834 rawCounts; original GR preparation")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dataset", choices=["cortex", "hca", "pbmc", "kang", "neurips", "gr", "tcr", "sim1", "sim2"])
    parser.add_argument("--data_dir", type=Path, default=Path("data"))
    parser.add_argument("--raw_dir", type=Path, default=Path("data/raw"))
    args = parser.parse_args()
    output, raw = args.data_dir, args.raw_dir
    output.mkdir(parents=True, exist_ok=True)
    raw.mkdir(parents=True, exist_ok=True)

    if args.dataset in ["cortex", "hca", "pbmc"]:
        import scvi
        if args.dataset == "cortex":
            a = ad.read_h5ad(Path(__file__).resolve().parents[1] / "data/cortex.h5ad")
            # Use the bundled paper input without an additional download.
            save(a, output / "cortex.h5ad", "scvi.data.cortex; GSE60361")
        elif args.dataset == "pbmc":
            a = scvi.data.pbmc_seurat_v4_cite_seq(save_path=str(raw))
            save(a, output / "pbmc_cite_seq.h5ad", "scvi.data.pbmc_seurat_v4_cite_seq; GSE164378")
        else:
            a = scvi.data.heart_cell_atlas_subsampled(save_path=str(raw))
            small = a.obs["sample"].value_counts().loc[lambda x: x < 20].index
            a.obs["sample_post"] = np.where(a.obs["sample"].isin(small), a.obs["cell_source"], a.obs["sample"])
            a = a[a.obs.cell_source.isin(["Sanger-Nuclei", "Harvard-Nuclei"])].copy()
            save(a, output / "hca_nuclei.h5ad", "scvi.data.heart_cell_atlas_subsampled; nuclei only")
    elif args.dataset == "kang":
        url = "https://exampledata.scverse.org/pertpy/kang_2018.h5ad"
        a = ad.read_h5ad(download(url, raw / "kang_2018.h5ad"))
        save(a, output / "kang_2018.h5ad", url)
    elif args.dataset == "neurips":
        path = raw / NEURIPS
        if not path.exists():
            path = unpack(download(f"{GEO}/GSE194nnn/GSE194122/suppl/{NEURIPS}.gz", raw / (NEURIPS + ".gz")))
        a = ad.read_h5ad(path)
        a = a[:, a.var.feature_types == "GEX"].copy()
        save(a, output / "neurips_cite_gex.h5ad", "GSE194122; GEX features")
        a = a[a.obs.cell_type.isin(STEM_TYPES)].copy()
        coarse = {**dict.fromkeys(STEM_TYPES[:4], "Erythroid"), **dict.fromkeys(STEM_TYPES[4:7], "Progenitor"), **dict.fromkeys(STEM_TYPES[7:], "Monocyte")}
        a.obs["cell_type_coarse"] = a.obs.cell_type.map(coarse)
        save(a, output / "neurips_cite_gex_stem_cells.h5ad", "GSE194122; nine lineage labels in prepare_data.py")
    elif args.dataset == "gr":
        prepare_gr(raw, output)
    elif args.dataset == "tcr":
        # R conversion writes independent inputs under raw_dir; see prepare_tcr.R.
        unstim = ad.read_h5ad(raw / "GSM4450387_unstimulated.h5ad")
        stim = ad.read_h5ad(raw / "GSM4450386_stimulated.h5ad")
        for a in [unstim, stim]:
            a.X = a.X.astype(np.float32)
        unstim.obs["percent.mito"] = unstim.obs["percent.mito"].astype("float32")
        stim.obs["nCount_RNA"] = stim.obs["nCount_RNA"].astype("float32")
        a = ad.concat({"unstimulated": unstim, "stimulated": stim}, label="condition", join="outer", index_unique="-")
        save(a, output / "tcr_stim_data.h5ad", "GSE147928 Seurat objects; prepare_tcr.R")
    else:
        name = "sim1_1_norm.h5ad" if args.dataset == "sim1" else "sim2_norm.h5ad"
        path = raw / name
        file_id = "33798263" if args.dataset == "sim1" else "33798764"
        download(f"https://ndownloader.figshare.com/files/{file_id}", path)
        save(ad.read_h5ad(path), output / name, "Luecken et al. scIB benchmark matrix; counts layer retained")


if __name__ == "__main__":
    main()
