# Benchmark code availability

The author's current figure organization puts mouse and human MLP analyses in
`figure/figure2/`. The relevant notebooks are:

| Analysis | Source | Additional inputs |
| --- | --- | --- |
| Mouse MLP age prediction | `figure/figure2/figure-2-1-mouse-benchmark-MLP.ipynb` | Selected genes, train/test HDF5, comparator results |
| Human MLP age prediction | `figure/figure2/figure-2-4-human-benchmark-MLP.ipynb` | Human HDF5, gene sets, comparator results |
| Mouse/human heatmaps and boxplots | Other `figure/figure2/` notebooks | Benchmark summary and full result tables |

See [the figure input inventory](../figure/INPUTS.md) for portable relative
paths. These notebooks passed format and Python-syntax checks, but the paper's
benchmark comparisons were not rerun in this repository preparation.

For every central manuscript comparison, a reviewer also needs the actual
training/evaluation code, data accession or released input, split definition,
selected feature set, model version, hyperparameters, random seeds, and metric
calculation. The complete list of manuscript comparator models and their
source/results still requires author review. This index is not a claim that
all benchmark results can be reproduced.
