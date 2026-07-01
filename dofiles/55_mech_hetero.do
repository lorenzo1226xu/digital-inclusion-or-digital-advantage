clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
use "$TEMP/panel_analytic.dta", clear
encode province, gen(prov_id)
global CONTROLS "age i.gender i.edu i.rural i.marry ins pension chronic adlab_c iadl total_cognition"

* ===== MECHANISMS: difference method on internet->checkup (2013-2018) =====
* candidate mediators kept SEPARATE from controls (avoid bad control in main models)
egen socialpart = rowtotal(act_1 act_2 act_3 act_4 act_5 act_6 act_7), missing
qui reghdfe checkup internet_use $CONTROLS if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
local bt = _b[internet_use]
di "===== MECHANISM (mediated share of internet->checkup) ====="
di "  total internet beta = " %6.4f `bt'
foreach m in exercise cesd10 ses_rank socialpart {
    qui reghdfe checkup internet_use `m' $CONTROLS if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
    local bd = _b[internet_use]
    di "  + `m' : direct=" %6.4f `bd' "  mediated share=" %5.1f 100*(`bt'-`bd')/`bt' "%"
}

* ===== HETEROGENEITY: internet main + internet#DFII by subgroup (checkup 2013-2018) =====
gen byte edu_hi = (edu>=3) if !missing(edu)
bys wave: egen double med_ses = median(ses_rank)
gen byte inc_hi = (ses_rank>med_ses) if !missing(ses_rank)
di "===== HETEROGENEITY (checkup 2013-2018; internet beta | internet#DFII) ====="
foreach v in "rural==0" "rural==1" "edu_hi==0" "edu_hi==1" "inc_hi==0" "inc_hi==1" {
    qui reghdfe checkup c.internet_use##c.dfii_c $CONTROLS if inlist(wave,2,3,4) & `v', absorb(prov_id wave) vce(cluster city_id)
    di "  " %-12s "`v'" " : internet=" %6.4f _b[internet_use] "   internet#DFII=" %7.4f _b[c.internet_use#c.dfii_c] "  (n=" e(N) ")"
}
