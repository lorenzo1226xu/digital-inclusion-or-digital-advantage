clear all
set more off
global CLEAN "/Users/xuwenkai/Documents/Frontiers in Public Health/整理完的-charls数据"
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"

use "$CLEAN/charls.dta", clear
di "==== base panel: " _N " obs ===="

* ---- merge harmonized constructs + weights (stay on analytic frame) ----
merge 1:1 ID wave using "$TEMP/internet_long.dta", keep(master match) nogen
merge 1:1 ID wave using "$TEMP/checkup_long.dta",  keep(master match) nogen
merge 1:1 ID wave using "$TEMP/unmet_long.dta",    keep(master match) nogen
merge 1:1 ID wave using "$TEMP/weights_long.dta",  keep(master match) nogen

* ---- utilization outcome names ----
rename doctor   outpatient
rename hospital inpatient

* ---- SES / living-standard rank variable (primary = per-capita consumption; income = robustness) ----
* (per Codex: align language to the better-measured ranker; consumption is the recommended welfare
*  ranker in health-equity analysis. Headline => "socioeconomic / living-standard-related inequality")
gen double ses_rank  = hhcperc
gen double hhinc_pc  = income_total/family_size
label var ses_rank  "Per-capita household consumption (PRIMARY SES ranker)"
label var hhinc_pc  "Per-capita household income (robustness ranker)"

* ---- pre-determined CONTROLS vs MEDIATORS (kept distinct) ----
global CONTROLS  "age i.gender i.edu i.rural i.marry ins pension chronic adlab_c iadl total_cognition"
global MEDIATORS "ses_rank cesd10 exercise"

* ---- numeric panel id ----
egen long id_num = group(ID)
xtset id_num wave

* ---- ASSERT STOPS (fail visibly if a core input is missing where expected) ----
* weights must exist for all 2011-2018 person-waves that have an outcome
count if inlist(wave,1,2,3,4) & !missing(outpatient) & missing(weight)
assert r(N) < 0.20*_N
* checkup analytic cohort starts 2013 (2011 excluded as non-comparable)
count if wave==1 & !missing(checkup)
di "2011 checkup present (will be excluded in analysis): " r(N)
* internet_use must be missing in 2020 (quarantined), internet_ded present
count if wave==5 & !missing(internet_use)
assert r(N)==0
count if wave==5 & !missing(internet_ded)
assert r(N)>0

compress
save "$TEMP/panel_core.dta", replace
di "==== panel_core saved: " _N " obs ===="
di "==== weight non-missing by wave ===="
tabstat weight, by(wave) stat(n mean)
