# Heart example data for reviewer execution

The repository includes two HDF5 files:

| File | Cells | Use |
| --- | ---: | --- |
| `Heart.hdf5` | 3,104 | Complete example file; stored with Git LFS |
| `Heart-reviewer-demo.h5` | 120 | Small, deterministic subset for a quick run |

Both have 22,919 float32 features in `data` and three int8 columns in
`label`. Class IDs are 1 (2,537 cells in the complete file) and 4
(567 cells). The first covariate has ID 1 for all cells; the second has ID 6
and is currently unused by the model. The model still has six output logits,
of which only classes 1 and 4 occur in this file.

These files have nonnegative, finite expression values. The file does not
provide gene names, cell IDs, donor IDs, tissue labels, or a public source
accession. The author must supply the provenance, label mappings, and
redistribution rights before a final manuscript release.

The small file was made with 60 cells from each class, seed 20201212,
without replacement, using `tools/make_reviewer_demo.py`. It retains the
selected rows' original feature and label values. Its role is to check
installation and execution; its scores do not reproduce the paper.
The provided subset's SHA-256 is
`f433fdbb624979cdcad47d83b7d39ea74dfcf64ce8c80eed5c04b0572cf0cb61`.
The documented one-epoch command was run successfully on Windows CPU. That
single run did not validate the full training or pruning schedule.

## Download the complete example

Install Git LFS, then clone and fetch LFS files:

```bash
git lfs install
git clone https://github.com/qm713152/sAge.git
cd sAge
git lfs pull
```

Check that `data/Heart.hdf5` is approximately 285 MB. The expected SHA-256 is:

```text
5a72f755adb1ed9eba62d85c7ab2d2f3502150be01d0892f4d7dd335b347e27f
```

Without Git LFS, a clone may contain only a small pointer file in place of
the complete HDF5. The small reviewer file is a regular Git file and does
not require LFS.

## Quick reviewer run with biological rows

From the repository root in the `sage` environment:

```bash
python model/prepare_dataset_for_cv.py --data_path data/Heart-reviewer-demo.h5 --output_dir prepared_data/Heart-reviewer-demo
python run_cross_validation.py --data-dir prepared_data/Heart-reviewer-demo --output-dir outputs/Heart-reviewer-demo --folds 0 -- --numhead 1 --batchsize 8 --batchrepeat 1 --max_epochs 1
```

Read `outputs/Heart-reviewer-demo/fold_0/train.log` after the runner finishes.
For the complete file, substitute `data/Heart.hdf5` and choose fresh
preparation/output directories. Full training is much longer than one epoch.
