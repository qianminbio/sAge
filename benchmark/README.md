# Benchmark code availability

For any comparison reported in the manuscript, a reviewer should be able to
locate the actual script used for training and evaluation, input dataset or
accession, shared split definition, feature-set selection, model version,
hyperparameters, random seeds, and metric calculation. A plot notebook alone
does not establish that a benchmark can be reproduced.

## Code currently available

| Analysis | Available source | What remains to verify |
| --- | --- | --- |
| Mouse MLP benchmark | `figure/figure-2-1-mouse-benchmark-MLP.ipynb` | Input/result file manifest, execution, reported settings |
| Human MLP benchmark | `figure/figure-2-4-human-benchmark-MLP.ipynb` | Input/result file manifest, execution, reported settings |
| Mouse/human MLP heatmaps and boxplots | Other `figure/figure-2-*` and `figure/figure-3-mouse-boxplot-MLP.ipynb` notebooks | Source result tables and panel mapping |
| Any other manuscript benchmark model | **Not identified in the supplied repository** | Actual scripts, versions, configurations, and results |

The two MLP notebooks contain `sklearn.neural_network.MLPRegressor` code,
but rely on author-specific paths and external input/result tables. They have
passed notebook-format and Python-syntax checks; they have not been rerun
against the paper's data.

## Submission rule of thumb

Publish the **custom code that produced every central benchmark result**,
including preprocessing and evaluation. It is usually enough to identify
third-party package names and exact versions rather than copy their source
code into this repository. Keep only diagnostic drafts that were not used in
the reported results outside the submission release. Cite the exact repository
commit or release tag used for the paper.

The author must confirm the full comparison-model list and supply any missing
source. This inventory is not a claim that all comparisons are available.
