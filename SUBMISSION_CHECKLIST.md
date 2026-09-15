# Submission release checklist

## Scientific provenance

- [ ] Confirm these model, feature-selection, and evaluation settings match the manuscript.
- [x] Confirm model name: sAge.
- [ ] Add manuscript title, authors, and citation metadata.
- [ ] Document all tissues/datasets, data accessions, preprocessing, feature order,
      class mapping, and covariate meaning.
- [ ] Confirm holdout and CV splitting units and whether donor separation is required.
- [ ] Resolve or explicitly justify the evaluation and random-seed limitations in docs/reproducibility.md.
- [ ] Supply commands/configurations linking each reported result to its dataset and seed.

## Reproduction

- [x] Add a separate installation environment with pinned runtime dependencies.
- [x] Validate CPU installation, synthetic one-epoch training/evaluation, and a pruned-checkpoint round trip.
- [ ] Recover and validate the original manuscript environment and establish result equivalence.
- [ ] Verify data preparation, one training epoch, pruning, checkpoint save/restore,
      and evaluation in a clean environment.
- [ ] Reproduce the manuscript experiments and preserve logs/configurations.
- [ ] Document hardware and expected runtime based on actual runs.
- [ ] Provide data and any released weights separately with checksums.
- [ ] Supply the missing cellphonedb_interaction_count_network helper and figure input manifest.
- [ ] Validate the figure notebooks/R scripts and record their final dependency versions.

## GitHub handoff

- [x] Confirm that the submission does not require anonymity.
- [x] Specify the public GitHub repository: https://github.com/qm713152/sAge.
- [ ] Select a license with the code owners and review third-party attribution.
- [x] Provide a portable environment.yml; retain the original export in docs/environment.original.yml.
- [ ] Review the explicit file list before committing; datasets and outputs are ignored.
- [ ] Complete the README release metadata and remove resolved preparation notes.
- [ ] Tag the exact version used for submission and include that link in the manuscript.

Repository: https://github.com/qm713152/sAge. Manuscript release readiness
depends on the unchecked scientific and reproduction items above.
