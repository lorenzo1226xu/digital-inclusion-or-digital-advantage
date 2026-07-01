clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
use "$TEMP/panel_analytic.dta", clear
encode province, gen(prov_id)
gen double iu_dfii = internet_use*dfii_c
global CONTROLS "age i.gender i.edu i.rural i.marry ins pension chronic adlab_c iadl total_cognition"
global RCTRL "ln_gdppc ln_doctors"

* ========== R1: Wagstaff index (vs Erreygers) for checkup ==========
di "===== R1: WAGSTAFF concentration index of checkup by wave (vs Erreygers) ====="
foreach w in 2 3 4 {
    qui conindex checkup if wave==`w' & !missing(ses_rank) [pw=weight], rankvar(ses_rank) wagstaff bounded limits(0 1)
    di "  wave `w' : Wagstaff CI = " %6.4f r(CI) "  (se " %6.4f r(CIse) ")"
}

* ========== R2: balanced panel (present in all 2013/2015/2018) ==========
preserve
keep if inlist(wave,2,3,4) & !missing(checkup)
bys id_num: gen n3 = _N
keep if n3==3
di "===== R2: engine-A M3 on BALANCED checkup panel (n=" _N ") ====="
reghdfe checkup c.internet_use##c.dfii_c $CONTROLS $RCTRL, absorb(prov_id wave) vce(cluster city_id)
restore

* ========== R3: UNMET-NEED strand (2011-2015) ==========
di "===== R3a: Erreygers CI of unmet_inpatient by wave (2011/13/15) ====="
foreach w in 1 2 3 {
    qui count if wave==`w' & !missing(unmet_inpatient,ses_rank,weight)
    if r(N)>200 {
        capture conindex unmet_inpatient if wave==`w' & !missing(ses_rank,weight) [pw=weight], rankvar(ses_rank) erreygers bounded limits(0 1)
        if _rc==0 di "  wave `w' : Erreygers CI = " %6.4f r(CI) "  (se " %6.4f r(CIse) ", n=" r(N) ")"
        else di "  wave `w' : conindex rc=" _rc
    }
    else di "  wave `w' : too few obs (" r(N) ")"
}
di "===== R3b: engine-A M3 on unmet_inpatient (2011-2015; >0 internet = more unmet) ====="
reghdfe unmet_inpatient c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,1,2,3), absorb(prov_id wave) vce(cluster city_id)

* ========== R4: exploratory IV (Broadband China pilot) ==========
di "===== R4: exploratory IV - internet instrumented by broadband_did (checkup 2013-2018) ====="
capture noisily ivreghdfe checkup $CONTROLS $RCTRL (internet_use = broadband_did) if inlist(wave,2,3,4), absorb(prov_id wave) cluster(city_id) first
