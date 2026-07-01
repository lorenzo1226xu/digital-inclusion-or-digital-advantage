clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global OUT  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output"
use "$TEMP/panel_analytic.dta", clear

* ===== probe return names (correct Erreygers syntax for binary) =====
conindex checkup if wave==4 & !missing(ses_rank) [pw=weight], rankvar(ses_rank) erreygers bounded limits(0 1)
return list

* ===== Table 1 (lite): by internet_use, 2013-2018 estimation sample =====
preserve
keep if inlist(wave,2,3,4)
di "===== TABLE 1: means by internet_use (2013-2018) ====="
tabstat checkup outpatient inpatient age chronic adlab_c iadl total_cognition ses_rank ins pension, by(internet_use) stat(mean) columns(statistics)
tab edu internet_use, col nofreq
tab rural internet_use, col nofreq
restore

* ===== Erreygers CI by wave x outcome (weighted, SES-ranked) =====
tempname pf
postfile `pf' str10 outcome byte wave double errCI double se long n using "$TEMP/ci_bywave.dta", replace
foreach y in checkup outpatient inpatient {
    forvalues w=1/5 {
        if ("`y'"=="checkup" & `w'==1) continue   // 2011 checkup non-comparable
        qui count if wave==`w' & !missing(`y') & !missing(ses_rank) & !missing(weight)
        if r(N)>200 {
            qui conindex `y' if wave==`w' & !missing(ses_rank) [pw=weight], rankvar(ses_rank) erreygers bounded limits(0 1)
            post `pf' ("`y'") (`w') (r(CI)) (r(CIse)) (r(N))
        }
    }
}
postclose `pf'

use "$TEMP/ci_bywave.dta", clear
gen int year = .
replace year=2011 if wave==1
replace year=2013 if wave==2
replace year=2015 if wave==3
replace year=2018 if wave==4
replace year=2020 if wave==5
gen sig = abs(errCI/se)>1.96
di "===== ERREYGERS CONCENTRATION INDEX by outcome x year (>0 = pro-rich) ====="
list outcome year errCI se n sig, sepby(outcome) clean noobs
export delimited "$OUT/tables/ci_bywave.csv", replace
