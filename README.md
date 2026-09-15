# sAge

Research code for **sAge**, implemented as `MaskedPruningModel` in JAX/Flax, with
masked feature augmentation and iterative feature selection.

Repository: https://github.com/qm713152/sAge

**Release status:** repository preparation in progress. The manuscript title,
authors, data accession, license, and a validated software environment must
be supplied before the submission release. No paper results are claimed here.

## Files

| File | Purpose |
| --- | --- |
| `model.py` | Model architecture |
| `data.py` | HDF5 loading, initial split, and stratified cross-validation folds |
| `prepare_dataset_for_cv.py` | Data preparation command |
| `train-tissue.py` | Train one fold, prune features, and evaluate the final test set |
| `run_cross_validation.py` | Run prepared folds sequentially and save logs |
| `test1-5x-tissue.sh`, `test1-5x-tissue.pl` | Compatibility wrappers for the runner |
| `requirements.txt` | Direct dependencies, without validated version pins |
| `environment.yml` | Historical Linux environment export; retained for provenance |

## Environment

The historical export records Python 3.10.14, JAX 0.4.10, Flax 0.6.8,
and Optax 0.1.7. It also contains a machine-specific prefix, Linux build
identifiers, and several CUDA package generations. It has **not** been
validated as a clean installation recipe. The unpinned `requirements.txt`
is an inventory, not a guarantee that current library versions can run this code.

Before reporting reproduced results, obtain the working training environment,
verify installation in a clean environment, and record exact package versions,
OS, accelerator, and driver. GPU configuration is environment-specific.

## Input data

Provide an HDF5 file containing:

| Dataset | Shape | Meaning |
| --- | --- | --- |
| `data` | `(N, 22919)` | Numeric expression features, in a fixed feature order |
| `label` | `(N, 1 + C)`, `C >= 1` | Class ID in column 0; covariates in subsequent columns |

The current model has six output classes, so class IDs must be integers 0–5.
Only the first covariate is used, as a two-category embedding (IDs 0 or 1).
The tissue embedding in `model.py` is commented out. The biological meanings
of the classes and covariates, gene identifiers/order, preprocessing procedure,
and data source must be documented by the authors.

Training normalizes each row by its total (clipped to at least 1), then applies
`log2(x * 1023 + 1)`. Preserve the input preprocessing used for the manuscript.
Data files are excluded from Git by `.gitignore`; distribute them separately
with an accession or download link once available.

## Prepare data

Run from this repository, in the validated training environment:

```bash
python prepare_dataset_for_cv.py --data_path Heart.hdf5 --output_dir prepared_data/Heart --initial_test_size_ratio 0.2 --n_cv_splits 5 --random_state 42
```

Outputs are `initial_split/train.h5`, `initial_split/test.h5`, and
`cv_folds/fold_0` through `fold_4`, each containing `train.h5` and `valid.h5`.
Use a new output directory to avoid overwriting previous splits.

The initial split uses a fixed seed of 20201212 in `data.py`; `--random_state`
controls only the stratified CV split. The initial split reserves the first
sample of each class for training and the second for testing, then fills
the requested test size. It is not a proportional stratified holdout split,
and its actual test size can differ from the requested ratio.

## Train

Check that all expected fold files exist:

```bash
python run_cross_validation.py --data-dir prepared_data/Heart --output-dir outputs/Heart --dry-run
```

Run all five folds, with optional training arguments after `--`:

```bash
python run_cross_validation.py --data-dir prepared_data/Heart --output-dir outputs/Heart -- --seed 20201212 --max_epochs 9999
```

For a short execution check, use `--folds 0` and pass `--max_epochs 1` after
`--`. This is not a reproduction of manuscript results. The runner records
each command in `fold_N/command.json` and redirects training output to
`fold_N/train.log`. It stops on the first failed fold and rejects nonempty
fold output directories. Use a new output directory for each experiment.

Training saves feature masks and checkpoints on validation improvements,
under `fold_N/checkpoints/featureXXXXXX/`. A `feature.txt` file is a mask
in the original input feature order, not a list of gene names.

## Reproducibility limitations requiring author review

- Model architecture and existing training/evaluation behavior have been
  retained during repository preparation.
- The training seed initializes JAX, but the shuffled PyTorch DataLoader is
  not explicitly seeded. Repeated runs are not guaranteed to agree.
- Validation and test metrics average batch means without weighting the final
  short batch by sample count.
- Final test evaluation uses the last training state and feature mask, rather
  than restoring a checkpoint chosen by validation performance.
- Each fold evaluates the same initial holdout. These are not independent
  test cohorts; do not use their test results to select hyperparameters.
- Cell-level splitting does not enforce donor-level separation. Whether this
  matches the manuscript design requires the sample/donor metadata.
- Full training and checkpoint restoration have not been verified in the
  repository-preparation environment, which lacks JAX, Flax, and PyTorch.

See [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md) for remaining release items.
