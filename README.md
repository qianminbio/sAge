# sAge

**sAge** is a JAX/Flax model for classification and iterative feature selection
from single-cell expression data. This repository provides data splitting,
training, cross-validation, and feature-mask export.

**Workflow:** install the environment → prepare an HDF5 dataset → create the
train/test and cross-validation splits → train → inspect logs and selected features.

## 1. Download the code

Install Git and Miniconda (or Anaconda), then run:

```bash
git clone https://github.com/qm713152/sAge.git
cd sAge
```

Run the commands below from this repository directory. In Windows, use
**Anaconda Prompt** for the Conda commands.

## 2. Install the environment

### Option A: Conda (CPU, simplest starting point)

```bash
conda env create -f environment.yml
conda activate sage
python -m pip check
python check_environment.py
```

The environment file creates a separate Python 3.12 environment and installs
the pinned dependencies in `requirements.txt`. It does not modify your base
environment. CPU execution is sufficient for the installation check; full
experiments may take substantially longer on CPU.

### Option B: Install with pip in a fresh environment

```bash
conda create -n sage python=3.12 pip -y
conda activate sage
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python -m pip check
python check_environment.py
```

Use **either Option A or Option B**. The core versions are:

| Component | Version |
| --- | --- |
| Python | 3.12 |
| JAX / jaxlib | 0.4.30 / 0.4.30 |
| Flax / Optax | 0.8.5 / 0.2.3 |
| NumPy / SciPy | 1.26.4 / 1.12.0 |
| PyTorch | 2.6.0 |
| h5py / scikit-learn | 3.11.0 / 1.5.1 |

PyTorch supplies the data loader; JAX performs model computation.
These are installation-guide versions, **not a claim about the software used
to produce the manuscript results**. The original environment export is
preserved in [docs/environment.original.yml](docs/environment.original.yml).

Verified on Windows x86_64 with Python 3.12.7 and the CPU backend: clean pip
installation, dependency checks, model execution, one-epoch synthetic
training/evaluation, and a pruned-parameter checkpoint round trip. The exact
resolved packages are recorded in
[the Windows CPU snapshot](docs/requirements.windows-cpu.lock.txt).
Conda environment creation and GPU execution have not been independently tested.

To check the data-to-training workflow **without downloading biological data**:

```bash
python tools/smoke_test.py
```

This creates temporary synthetic data, prepares five folds, runs one epoch on
fold 0, checks that final evaluation completes, and removes its temporary files.
It does not validate manuscript results or the iterative pruning schedule.

### Optional: NVIDIA GPU on Linux

First install the CPU environment above. On Linux with a working NVIDIA
driver, add the CUDA 12 backend for the same JAX version:

```bash
nvidia-smi
python -m pip install "jax[cuda12]==0.4.30"
python -m pip check
python check_environment.py --require-gpu
```

This GPU path has not been tested on the preparation machine. Native Windows
does not support the JAX NVIDIA GPU backend; use Linux or a suitable WSL2
setup. See the [JAX installation guide](https://docs.jax.dev/en/latest/installation.html)
for platform and driver requirements. Do not install an unpinned latest JAX
over this environment.

A successful check prints package versions, the JAX devices, and a model
forward-pass result of shape `(2, 6)`. With `--require-gpu`, it fails if
JAX cannot see a GPU, so CPU fallback is not mistaken for GPU execution.

## 3. Prepare your input data

The repository does **not** include the input dataset or a public download
link yet. Obtain the preprocessed data from the authors and place
`Heart.hdf5` in the repository directory, or substitute your own file path.

Each HDF5 file must contain:

| Key | Shape | Contents |
| --- | --- | --- |
| `data` | `(N, 22919)` | Numeric expression matrix: cells by features |
| `label` | `(N, 1 + C)`, `C >= 1` | Class label followed by covariates |

For this implementation:

- Class labels in `label[:, 0]` are integer IDs from **0 to 5**.
- The first covariate, `label[:, 1]`, is an integer ID **0 or 1**.
- The model uses that first covariate only; the tissue embedding is disabled.
- Feature order must stay identical across all splits and downstream analysis.
- The training script normalizes each row by its total (clipped to at least 1),
  then applies `log2(x * 1023 + 1)`. Use the input preprocessing intended for
  the experiment; do not apply this transform twice.

The biological class names, covariate meaning, gene order, and data accession
still need author documentation.

Create a holdout test set and five cross-validation folds:

```bash
python model/prepare_dataset_for_cv.py --data_path Heart.hdf5 --output_dir prepared_data/Heart --initial_test_size_ratio 0.2 --n_cv_splits 5 --random_state 42
```

Expected layout:

```text
prepared_data/Heart/
├── initial_split/
│   ├── train.h5
│   └── test.h5
└── cv_folds/
    ├── fold_0/
    │   ├── train.h5
    │   └── valid.h5
    ├── fold_1/
    ├── fold_2/
    ├── fold_3/
    └── fold_4/
```

Every fold directory contains both `train.h5` and `valid.h5`. The CV folds
are formed from the initial training set. Use a new preparation directory
for each split configuration because this command can overwrite split files.

## 4. Train the model

### Check the file paths

```bash
python run_cross_validation.py --data-dir prepared_data/Heart --output-dir outputs/Heart --dry-run
```

This checks that the files exist and prints commands. It does not load the
HDF5 contents or train the model.

### Run a short check on one fold

```bash
python run_cross_validation.py --data-dir prepared_data/Heart --output-dir outputs/Heart-check --folds 0 -- --max_epochs 1
```

One epoch checks execution; it is not a full experiment or a pruning test.

### Run all five folds

```bash
python run_cross_validation.py --data-dir prepared_data/Heart --output-dir outputs/Heart -- --seed 20201212 --max_epochs 9999
```

Folds run sequentially. Training output is written to each fold's
`train.log`, so the terminal may remain quiet while a fold is running.
The runner stops on an error and rejects nonempty fold output directories;
choose a new output directory when rerunning an experiment.

Arguments **before** `--` configure the runner. Arguments **after** `--`
are passed to `model/train-tissue.py`.

| Training option | Default | Meaning |
| --- | --- | --- |
| `--numhead` | 8 | Number of model heads |
| `--batchsize` | 64 | Number of original cells per training batch |
| `--batchrepeat` | 8 | Number of augmented copies per batch |
| `--maskrate` | 0.15 | Feature masking probability |
| `--learnrate` | 0.001 | Learning-rate schedule peak |
| `--patience` | 64 | Early-stopping patience parameter |
| `--max_epochs` | 9999 | Maximum epoch count |
| `--seed` | 20201212 | JAX random seed |
| `--num_workers` | 0 | DataLoader worker count |

For example, reduce memory usage with
`-- --batchsize 16 --batchrepeat 2`. Changing these settings can change the
experimental results.

## 5. Find the outputs

```text
outputs/Heart/fold_0/
├── command.json
├── train.log
└── checkpoints/
    └── featureXXXXXX/
        ├── feature.txt
        └── ... checkpoint files ...
```

- **command.json:** exact command used for this fold.
- **train.log:** training/validation metrics and the final test loss and accuracy.
- **feature.txt:** a mask in the original feature order; `1` means retained
  and `0` means removed. It is not a list of gene names.
- **Checkpoint files:** saved parameters and feature mask at qualifying
  validation improvements. Checkpoints are not guaranteed after a short run:
  the existing training code initializes the accuracy threshold at 80%.

The remaining folds have the same structure. Data files and generated outputs
are excluded from Git.

## Troubleshooting

| Problem | What to check |
| --- | --- |
| `ModuleNotFoundError` | Activate `sage`; install with `python -m pip install -r requirements.txt`. |
| Dependency/version error | Create a fresh environment using the pinned requirements; avoid mixing with the historical export. |
| JAX lists only a CPU | Check the operating system, NVIDIA driver, and CUDA backend; run `check_environment.py --require-gpu`. |
| Feature-count assertion | The input must have 22,919 features in the expected order. |
| Missing fold file | Run data preparation first and pass its output directory as `--data-dir`. |
| Output directory is not empty | Choose a new `--output-dir`; existing experiments are retained. |
| Training fails after the runner prints a command | Inspect that fold's `train.log` for the underlying error. |

## 6. Figure analysis

The `figure/` directory contains the manuscript analysis notebooks and R scripts.
These require additional dependencies and external input/results files. Start
with [figure/README.md](figure/README.md) for the script index, installation,
and missing-input notes. The model environment alone does not install all
figure dependencies.

## Repository layout

| File | Purpose |
| --- | --- |
| `model/model.py` | sAge architecture (`MaskedPruningModel`) |
| `model/data.py` | Dataset loading and splitting |
| `model/prepare_dataset_for_cv.py` | Prepare holdout and CV files |
| `model/train-tissue.py` | Train and evaluate one fold |
| `run_cross_validation.py` | Run multiple folds and save logs |
| `check_environment.py` | Check imports, devices, model execution, and early-stopping compatibility |
| `environment.yml`, `requirements.txt` | Installation environment |
| `docs/environment.original.yml` | Historical environment export |
| `docs/reproducibility.md` | Validation scope and experimental caveats |

## Reproducibility and citation

See [reproducibility notes](docs/reproducibility.md) for validation status,
data-splitting behavior, random seeds, checkpoint selection, and metric
aggregation. The manuscript title, author list, citation, data accession,
and license are pending. See [the submission checklist](SUBMISSION_CHECKLIST.md)
for the remaining release items.
