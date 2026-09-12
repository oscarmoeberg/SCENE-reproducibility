"""Export run settings, module definitions, and full TCR results as CSV tables."""
import json
from pathlib import Path

import pandas as pd


def main():
    root = Path(__file__).resolve().parents[1]
    output = root / "notebooks/figures/output/tables"
    output.mkdir(parents=True, exist_ok=True)
    runs = json.loads((root / "docs/reference_runs.json").read_text())
    rows = [{"run": r["run"], "group": r["group"], "model": r["model"], **r["arguments"]} for r in runs]
    pd.DataFrame(rows).to_csv(output / "run_parameters.csv", index=False)
    modules = json.loads((root / "data/gr_modules.json").read_text())
    displayed = {"GR_direct_GRE_core", "GR_secondary_TF_core", "Glycolysis_core", "TCA_cycle_core"}
    pd.DataFrame([{"module": name, "genes": "; ".join(genes), "displayed_in_figure6": name in displayed}
                  for name, genes in modules.items()]).to_csv(output / "gr_modules.csv", index=False)
    for model in ["scLDM", "SIMBA"]:
        path = root / f"results/geometric_biology/{model}_TCR/gene_module_eval.csv"
        pd.read_csv(path).to_csv(output / f"{'SCENE' if model == 'scLDM' else model}_TCR.csv", index=False)
    print(f"Saved tables to {output}")


if __name__ == "__main__":
    main()
