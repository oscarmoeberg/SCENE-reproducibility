"""Small scientific workflow checks; these do not rerun the paper experiments."""
import sys
from pathlib import Path

import anndata as ad
import numpy as np
import pandas as pd
import pytest
from scipy import sparse

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from benchmark_embedding import _align_embedding_to_adata
from imputation import load_or_create_heldout, main as impute
from train_pca_harmony import _pca_harmony_embeddings
import scene


@pytest.fixture
def counts():
    rng = np.random.default_rng(42)
    x = rng.poisson(0.7, (40, 24)).astype(np.float32)
    obs = pd.DataFrame({"batch": pd.Categorical(["a", "b"] * 20),
                        "donor": pd.Categorical(["x"] * 20 + ["y"] * 20)},
                       index=[f"c{i}" for i in range(40)])
    return ad.AnnData(sparse.csr_matrix(x), obs=obs,
                     var=pd.DataFrame(index=[f"g{i}" for i in range(24)]),
                     layers={"counts": sparse.csr_matrix(x)})


@pytest.mark.parametrize("keys,variant,loss,init", [
    (None, "full", "ZIP", "random"),
    (["batch"], "full", "ZIP", "laplacian"),
    (["batch", "donor"], ["full", "lowrank"], "ZIP", "random"),
    (None, "full", "poisson", "random"),
])
def test_training_and_reconstruction(counts, keys, variant, loss, init):
    a, metrics = scene.train_scene(counts, latent_dim=2, epochs=2, seed=42,
                                   split_seed=42, validate=True, batch_keys=keys,
                                   variant=variant, rank=2, loss_type=loss,
                                   cell_init=init, gene_init=init)
    lam, pi = scene.reconstruct_rates_from_adata(a, batch_keys=keys)
    assert lam.shape == counts.shape and np.isfinite(lam).all()
    assert np.isfinite(pi).all() and ((pi >= 0) & (pi <= 1)).all()
    assert a.obsm["SCENE"].shape == (40, 2)
    assert a.varm["SCENE"].shape == (24, 2)
    assert np.isfinite(metrics["auc"][-1])


def test_shared_mask_and_order(counts, tmp_path):
    _, rows, cols, values = load_or_create_heldout(counts, tmp_path, .1, 42)
    _, rows2, cols2, values2 = load_or_create_heldout(counts, tmp_path, .1, 7)
    np.testing.assert_array_equal(rows, rows2)
    np.testing.assert_array_equal(cols, cols2)
    np.testing.assert_array_equal(values, values2)
    with pytest.raises(AssertionError):
        load_or_create_heldout(counts[::-1].copy(), tmp_path, .1, 42)


def test_cell_alignment(counts, tmp_path):
    emb = np.arange(80).reshape(40, 2)
    names = tmp_path / "names.npy"
    np.save(names, counts.obs_names.to_numpy(dtype=str)[::-1])
    aligned = _align_embedding_to_adata(counts, emb[::-1], names)
    np.testing.assert_array_equal(aligned, emb)


def test_pca_dimension(counts):
    a = _pca_harmony_embeddings(counts, embedding_dim=3)
    assert a.obsm["X_pca_vanilla"].shape == (40, 3)


def test_imputation_cli_both_models(counts, tmp_path):
    path = tmp_path / "counts.h5ad"
    counts.write_h5ad(path)
    common = ["--data_path", str(path), "--results_dir", str(tmp_path),
              "--experiment_name", "shared", "--epochs", "1", "--device", "cpu"]
    impute(["--model", "scene", *common])
    impute(["--model", "scvi", *common])
    scores = pd.read_csv(tmp_path / "shared/imputation_metrics.csv")
    assert set(scores.Model) == {"SCENE", "SCVI"}
    assert np.isfinite(scores.RMSE).all()


def test_shared_permutation_stream(counts):
    from eval_gene_module import _build_eval_context, _evaluate_module_task, evaluate_gene_module
    w = np.random.default_rng(0).normal(size=(24, 2))
    names = counts.var_names.to_numpy()
    context = _build_eval_context(w, names)
    stream = np.random.default_rng(42)
    expected_stream = np.random.default_rng(42)
    for genes in [names[:4].tolist(), names[4:8].tolist()]:
        result = _evaluate_module_task("test", genes, w, names, context, 50, True, stream)
        expected = evaluate_gene_module(w, names, genes, n_perm=50, rng=expected_stream,
                                        euclidean=True, eval_context=context)
        assert result["pval"] == expected["pval"]


def test_cortex_preparation_uses_bundled_input(tmp_path, monkeypatch):
    import scvi
    from prepare_data import main as prepare

    def unexpected_download(*args, **kwargs):
        raise AssertionError("Bundled cortex preparation must not download data")

    monkeypatch.setattr(scvi.data, "cortex", unexpected_download)
    monkeypatch.setattr(sys, "argv", [
        "prepare_data.py", "cortex", "--data_dir", str(tmp_path),
        "--raw_dir", str(tmp_path / "raw"),
    ])
    prepare()
    prepared = ad.read_h5ad(tmp_path / "cortex.h5ad")
    assert prepared.shape == (3005, 19972)
    assert "counts" in prepared.layers
    assert (tmp_path / "preparation.json").exists()


def test_batch_silhouette_skips_groups_with_one_cell_per_batch():
    from benchmark_embedding import _silhouette_batch
    from sklearn.metrics import silhouette_score

    x = np.arange(14, dtype=float).reshape(7, 2)
    labels = np.array(["small"] * 3 + ["valid"] * 4)
    batches = np.array(["a", "b", "c", "a", "a", "b", "b"])
    expected = 1 - abs(silhouette_score(x[3:], batches[3:]))
    assert _silhouette_batch(x, labels, batches) == pytest.approx(expected)
    assert np.isnan(_silhouette_batch(x[:3], labels[:3], batches[:3]))
