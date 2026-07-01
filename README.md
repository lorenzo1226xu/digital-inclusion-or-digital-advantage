# Analysis code — "Digital Inclusion or Digital Advantage?"

Stata and R code that reproduces the results, tables, and figures in the manuscript.

## Contents
- `dofiles/` — Stata pipeline, run in numeric order:
  - `00_setup.do` (packages/paths) → `11_internet.do`, `12_checkup.do`, `13_unmet.do`, `20_weights.do` (extraction/harmonization) → `21_panel.do`, `22_regional.do` (analytic panel + DFII/regional merge) → `31_ci.do` (Erreygers CI) → `41_models.do` (Engine A, fixed effects) → `53_decomp_wave.do`, `54_decomp_stratified.do`, `56_crosslevel_test.do` (Engine B, decomposition + cross-level bootstrap) → `55_mech_hetero.do`, `57_hetero_mech_fixed.do` (mechanisms, heterogeneity) → `61_robust.do` (robustness) → `71_tables.do`, `72_tables2.do` (tables).
- `figs.R` — R (ggplot2/patchwork/ragg) publication figures.
- `protocols/` — equity-measurement protocol, wave-harmonization table, literature-search table.

## Data (not redistributed here, per source licenses)
- Individual: China Health and Retirement Longitudinal Study (CHARLS), https://charls.charlsdata.com (free registration).
- Regional: Peking University Digital Financial Inclusion Index, https://idf.pku.edu.cn; China City Statistical Yearbooks; Broadband China pilot list.

## Reproduce
1. Obtain the data above; set the `ROOT`/path globals at the top of each do-file to your local paths.
2. Run the do-files in numeric order in **Stata 18** (requires `reghdfe`, `ftools`, `conindex`, `ivreghdfe`, `ivreg2`, `ranktest`, `estout`, `coefplot`).
3. Run `figs.R` in **R 4.5** (requires `ggplot2`, `patchwork`, `ragg`, `ggrepel`, `dplyr`, `tidyr`, `scales`, `svglite`).

Contact: Wenkai Xu (2025111046@wsyu.edu.cn).
