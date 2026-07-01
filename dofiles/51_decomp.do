clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global OUT  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output"
use "$TEMP/panel_analytic.dta", clear

* ===== DFII-stratified Erreygers CI of checkup (2013-2018): inclusion vs advantage descriptive =====
gen byte dfii_hi = (dfii_c>0) if !missing(dfii_c)
label define hilo 0 "Low-DFII region" 1 "High-DFII region"
label values dfii_hi hilo
di "===== CHECKUP Erreygers CI by regional DFII group (2013-2018) ====="
foreach g in 0 1 {
    qui conindex checkup if inlist(wave,2,3,4) & dfii_hi==`g' & !missing(ses_rank) [pw=weight], rankvar(ses_rank) erreygers bounded limits(0 1)
    di "  DFII group `g' : CI = " %6.4f r(CI) "  (se " %6.4f r(CIse) ", n=" r(N) ")"
}

* ===== Concentration-index DECOMPOSITION (digital contribution share), checkup 2013-2018 =====
* try conindex built-in decompose; fall back to manual if unsupported
di "===== conindex decompose attempt ====="
capture noisily conindex checkup if inlist(wave,2,3,4) & !missing(ses_rank) [pw=weight], ///
    rankvar(ses_rank) erreygers bounded limits(0 1) ///
    decompose(internet_use dfii_c age chronic edu ins ln_gdppc)
di "decompose rc = " _rc
