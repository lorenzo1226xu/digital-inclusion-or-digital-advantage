# Equity-Measurement Protocol (P0 gate ③ — pre-committed before any estimation)

All choices fixed in advance to prevent specification-mining of the inequality results.

| Parameter | Committed choice | Justification |
|---|---|---|
| **Primary index** | **Erreygers corrected concentration index** | Outcomes are binary/bounded; Erreygers satisfies the mirror/level-independence properties the standard CI violates, enabling valid cross-wave (changing-prevalence) comparison. |
| Robustness index | Wagstaff normalized CI | Different normative weighting; reported alongside to show results are not normalization-driven. |
| **Rank variable** | **wave-specific household per-capita income** (`hhinc_pc`) | Income-related inequality is the target; wave-specific rank reflects each wave's distribution. Pooled-rank = robustness. |
| Weights | CHARLS individual sampling weight | National representativeness. |
| **Need standardizers (for HI)** | age, gender, self-rated health, chronic disease, ADL/IADL | Legitimate health-need determinants; HI = inequity beyond need. |
| **Non-need variables** | income, education, rural/hukou, insurance, DFII | Treated as inequity sources, not need; appear as decomposition contributors. |
| **Decomposition** | Wagstaff–van Doorslaer–Watanabe via `conindex, decompose(...)`; linear approximation (LPM), probit marginal-effects as robustness | Standard, additive, interpretable contribution shares. |
| **Interaction handling** | `internet_use × dfii_c` entered as its OWN regressor in the decomposition (DFII mean-centered) | Yields the "digital moderation" contribution share cleanly; centering avoids scale artifacts. |
| **Engine separation** | CI/HI/decomposition = wave-wise CROSS-SECTIONAL only; panel FE lives in a separate engine | FE + nonlinear decomposition do not map to interpretable shares (avoids the methodological trap). |
| **Uncertainty** | bootstrap SE (or city-clustered) | Accounts for survey design + estimation. |
| **Dynamic** | repeat per wave → digital-contribution-share time series | Evidence for H4 (rising digital share). |
