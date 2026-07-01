clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global OUT  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output"
use "$TEMP/panel_analytic.dta", clear
encode province, gen(prov_id)
global CONTROLS "age i.gender i.edu i.rural i.marry ins pension chronic adlab_c iadl total_cognition"
global RCTRL "ln_gdppc ln_doctors"

* ================= PRIMARY OUTCOME: CHECKUP (2013-2018) =================
* PRIMARY estimator = pooled + province & wave FE + controls (retains cross-sectional variation; Codex)
eststo clear
eststo c1: reghdfe checkup internet_use $CONTROLS if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
eststo c2: reghdfe checkup internet_use dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
eststo c3: reghdfe checkup c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
* robustness: individual FE
eststo cFE: reghdfe checkup c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(id_num wave) vce(cluster city_id)
esttab c1 c2 c3 cFE, b(%9.4f) se(%9.4f) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(internet_use dfii_c c.internet_use#c.dfii_c) ///
    mtitles("M1 pooled" "M2 +DFII" "M3 inter" "M3 indFE") title("CHECKUP 2013-2018")
esttab c1 c2 c3 cFE using "$OUT/tables/checkup_models.csv", replace b(%9.4f) se(%9.4f) ///
    star(* 0.10 ** 0.05 *** 0.01) keep(internet_use dfii_c c.internet_use#c.dfii_c)

* margins by DFII level (geographic moderation, NOT income-equity) + plot
quietly reghdfe checkup c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
margins, dydx(internet_use) at(dfii_c=(-1.5 -0.75 0 0.75 1.5))
marginsplot, title("Marginal assoc. of internet use on checkup by regional DFII") ///
    ytitle("dY/d(internet)") xtitle("Regional DFII (std)")
graph export "$OUT/figures/checkup_internet_by_dfii.png", replace width(1400)

* ---- switcher diagnostics (Codex) on checkup 2013-2018 cohort ----
preserve
keep if inlist(wave,2,3,4) & !missing(checkup) & !missing(internet_use)
bys id_num (wave): egen iu_min=min(internet_use)
bys id_num (wave): egen iu_max=max(internet_use)
bys id_num (wave): egen ck_min=min(checkup)
bys id_num (wave): egen ck_max=max(checkup)
gen sw_int = iu_min!=iu_max
gen sw_both= (iu_min!=iu_max) & (ck_min!=ck_max)
egen tag=tag(id_num)
qui count if tag
local nid=r(N)
qui count if tag & sw_int
local nsw=r(N)
qui count if tag & sw_both
local nbo=r(N)
di "CHECKUP cohort: IDs=`nid' ; internet-switchers=`nsw' ; switch-both=`nbo'"
restore

* ================= SECONDARY OUTCOMES (utilization, 2011-2018): M3 interaction =================
eststo clear
eststo o3: reghdfe outpatient c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,1,2,3,4), absorb(prov_id wave) vce(cluster city_id)
eststo i3: reghdfe inpatient  c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,1,2,3,4), absorb(prov_id wave) vce(cluster city_id)
esttab o3 i3, b(%9.4f) se(%9.4f) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(internet_use dfii_c c.internet_use#c.dfii_c) mtitles("outpatient" "inpatient") title("UTILIZATION 2011-2018 (M3)")
