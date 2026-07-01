clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global OUT  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output"
use "$TEMP/panel_analytic.dta", clear
encode province, gen(prov_id)
gen double iu_dfii = internet_use*dfii_c
global CONTROLS "age i.gender i.edu i.rural i.marry ins pension chronic adlab_c iadl total_cognition"
global RCTRL "ln_gdppc ln_doctors"

label var internet_use "Internet use"
label var dfii_c "Regional DFII (std)"

* ===== Table 1: descriptives by internet use (2013-2018) =====
preserve
keep if inlist(wave,2,3,4)
capture noisily dtable age i.gender i.edu i.rural i.marry ins pension chronic adlab_c iadl total_cognition checkup outpatient inpatient, ///
    by(internet_use, tests) nformat(%6.2f mean sd) export("$OUT/tables/T1_descriptives.html", replace)
restore

* ===== Table 3: main regression (checkup, engine A) =====
eststo clear
eststo m1: reghdfe checkup internet_use $CONTROLS if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
estadd local feprov "Yes"
estadd local fewave "Yes"
eststo m2: reghdfe checkup internet_use dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
eststo m3: reghdfe checkup c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
eststo mfe: reghdfe checkup c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(id_num wave) vce(cluster city_id)
esttab m1 m2 m3 mfe using "$OUT/tables/T3_main_checkup.rtf", replace ///
    b(%9.4f) se(%9.4f) star(* 0.10 ** 0.05 *** 0.01) ///
    keep(internet_use dfii_c c.internet_use#c.dfii_c) ///
    mtitles("M1 base" "M2 +DFII" "M3 interaction" "M3 indiv-FE") ///
    stats(N r2_within, fmt(%9.0f %6.3f) labels("N" "Within R2")) ///
    title("Table 3. Internet use, regional DFII, and preventive checkup (CHARLS 2013-2018)") ///
    note("Pooled models absorb province + wave FE; final column individual + wave FE. SE clustered by city. Individual controls + regional GDP/doctor density included.")

* ===== Table 4: utilization outcomes =====
eststo clear
eststo o3: reghdfe outpatient c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,1,2,3,4), absorb(prov_id wave) vce(cluster city_id)
eststo i3: reghdfe inpatient  c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,1,2,3,4), absorb(prov_id wave) vce(cluster city_id)
esttab o3 i3 using "$OUT/tables/T4_utilization.rtf", replace b(%9.4f) se(%9.4f) ///
    star(* 0.10 ** 0.05 *** 0.01) keep(internet_use dfii_c c.internet_use#c.dfii_c) ///
    mtitles("Outpatient" "Inpatient") stats(N, fmt(%9.0f)) ///
    title("Table 4. Internet use x DFII on outpatient/inpatient utilization (2011-2018)")

* ===== margins data for Fig 5 =====
quietly reghdfe checkup c.internet_use##c.dfii_c $CONTROLS $RCTRL if inlist(wave,2,3,4), absorb(prov_id wave) vce(cluster city_id)
margins, dydx(internet_use) at(dfii_c=(-2(0.5)2))
matrix T = r(table)'
clear
svmat double T, names(col)
gen dfii_c = -2 + 0.5*(_n-1)
keep dfii_c b ll ul
rename (b ll ul) (estimate min95 max95)
export delimited using "$TEMP/margins_fig5.csv", replace

di "TABLES DONE"
