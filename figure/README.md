# Manuscript figure analysis

This directory contains the supplied Python notebooks and R analysis scripts.
The numbering follows the filenames supplied by the authors; it is not yet a
verified mapping to final manuscript panels. Model training is documented in
the [main README](../README.md).

## Python environment

From the repository root, after installing the model environment:

```bash
conda activate sage
python -m pip install -r requirements-figures.txt
python -m pip check
python -m ipykernel install --user --name sage --display-name "Python (sAge)"
jupyter lab
```

Open a notebook in `figure/`, select **Python (sAge)**, configure the input
and output paths, then run cells in order. The optional dependency ranges
are an installation starting point; figure execution and numerical results
have not been validated. They retain the model dependency pins via a pip
constraints file. Model installation does not require these optional packages.

## R environment

Install R and, optionally, RStudio. In an R console:

```r
install.packages(c("BiocManager", "tidyverse", "RColorBrewer", "pheatmap", "proxy"))
BiocManager::install(c("AnnotationDbi", "GOSemSim", "clusterProfiler",
                      "org.Hs.eg.db", "org.Mm.eg.db", "ComplexHeatmap"))
```

`grid`, `stats`, and `tools` ship with R. The remaining imports are included
in the package groups above. A manuscript-specific R/Bioconductor version
lock is not yet available. After reproducing the analysis, record
`sessionInfo()` with the results.

## Script index

| Files | Analysis indicated by the code and filenames |
| --- | --- |
| `0-elbow-gene-choose.ipynb` | Feature-count/elbow selection |
| `figure-2-1-*`, `figure-2-4-*` | Mouse and human MLP benchmarks |
| `figure-2-2-*`, `figure-2-5-*` | Benchmark heatmaps |
| `figure-3-mouse-boxplot-MLP.ipynb` | Mouse benchmark comparisons |
| `figure-3-1-*`, `figure-3-3-*` | Mouse and human nonlinear trajectories |
| `figure-3-2-cluster-GO.ipynb` | Gene Ontology enrichment of clusters |
| `figure-4-1-*.ipynb` | Tissue gene ratios and gene annotations |
| `figure-5-0-clock.ipynb` | Age prediction/clock analysis |
| `figure-5-1-leipameisu.ipynb` | Rapamycin analysis |
| `figure-5-2-CR.ipynb` | Caloric-restriction analysis |
| `figure-5-3-target-gene.ipynb` | Target-gene analysis |
| `figure-6-1-plasma.ipynb` | Plasma and tissue interaction analysis |
| `1-mouse-gene-upset-tissue.R` | Mouse/human tissue gene-set overlap |
| `1-mouse-gene-GO-jaccard-similarity.R` | Gene/GO similarity analysis |
| `1-mouse-multitissue-GO.R` | Multi-tissue enrichment visualization |
| `1-multi-tissue-target-gene.R` | Target-gene visualization |

## Required inputs and current limitations

- These files contain author-specific absolute paths (including Windows
  drive paths). Inspect the configuration variables in each notebook/script
  and replace every input and output path before running. Some files contain
  multiple analysis sections with separate path settings.
- Inputs include expression matrices, gene lists, benchmark tables,
  enrichment results, intervention datasets, and interaction result tables.
  They are not all produced by `run_cross_validation.py` and are not bundled
  here. Data accessions and a complete file-to-input manifest are pending.
- `figure-6-1-plasma.ipynb` imports
  `cellphonedb_interaction_count_network`. That local helper is **missing**
  from the supplied repository and is not included in the requirements file.
  Supply it before running the cells that import it.
- Enrichment and annotation calls in `gseapy` and `mygene` may use external
  services. Save database versions and retrieved responses for reproducibility.
- Cached notebook outputs and execution counts were cleared for source
  publication. This does not mean that the notebooks were rerun successfully.
- The figure scripts have not been executed against the manuscript datasets.
  Do not interpret a successful model installation check as figure validation.
