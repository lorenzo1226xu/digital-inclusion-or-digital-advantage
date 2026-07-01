clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
use "$TEMP/panel_analytic.dta", clear
encode province, gen(prov_id)
* full control set incl regional controls (Codex R4 minor)
global CB "age i.gender i.marry ins pension chronic adlab_c iadl total_cognition ln_gdppc ln_doctors"

* ===== MECHANISMS: exploratory coefficient ATTENUATION (not causal mediation; Codex R4) =====
egen socialpart = rowtotal(act_1 act_2 act_3 act_4 act_5 act_6 act_7), missing
qui reghdfe checkup internet_use $CB i.edu i.rural if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
local bt = _b[internet_use]
di "===== coefficient attenuation of internet->checkup after adding candidate channel (exploratory, NOT causal) ====="
di "  internet beta (no channel) = " %6.4f `bt'
foreach m in exercise cesd10 ses_rank socialpart {
    qui reghdfe checkup internet_use `m' $CB i.edu i.rural if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
    di "  + `m' : beta=" %6.4f _b[internet_use] "  attenuation=" %5.1f 100*(`bt'-_b[internet_use])/`bt' "%"
}

* ===== HETEROGENEITY: TRIPLE interaction with FORMAL cross-group tests (Codex R4) =====
gen byte edu_hi = (edu>=3) if !missing(edu)
bys wave: egen double med_ses = median(ses_rank)
gen byte inc_hi = (ses_rank>med_ses) if !missing(ses_rank)
di "===== triple-interaction tests: does internet#DFII differ by subgroup? ====="
qui reghdfe checkup c.internet_use##c.dfii_c##i.rural $CB i.edu if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
test 1.rural#c.internet_use#c.dfii_c
di "  rural   : triple-term p = " %5.3f r(p)
qui reghdfe checkup c.internet_use##c.dfii_c##i.edu_hi $CB i.rural if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
test 1.edu_hi#c.internet_use#c.dfii_c
di "  edu_hi  : triple-term p = " %5.3f r(p)
qui reghdfe checkup c.internet_use##c.dfii_c##i.inc_hi $CB i.edu i.rural if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
test 1.inc_hi#c.internet_use#c.dfii_c
di "  inc_hi  : triple-term p = " %5.3f r(p)
