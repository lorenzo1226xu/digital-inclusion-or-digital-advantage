clear all
set more off
global DATA "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/data"
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"

* ---- DFII city keys ----
import delimited "$DATA/dfii/dfii_keys.csv", varnames(1) encoding("utf-8") clear
destring year dfii dfii_breadth dfii_depth dfii_digit, replace force
drop if missing(dfii)
duplicates drop city_key year, force
save "$TEMP/dfii_keys.dta", replace

* ---- city statistical-yearbook controls ----
import delimited "$DATA/regional/city_controls.csv", varnames(1) encoding("utf-8") clear
destring year gdp_pc urban_rate doctors beds, replace force
rename city city_key
keep city_key year gdp_pc urban_rate doctors beds
duplicates drop city_key year, force
save "$TEMP/city_controls.dta", replace

* ---- Broadband China pilot (IV candidate) ----
use "$DATA/0637_宽带中国-地级市版（2000-2024年）_一行/宽带中国-地级市版（2000-2024年）.dta", clear
keep 年份 城市 DID 试点城市
rename (年份 城市 DID 试点城市) (year city_key broadband_did broadband_pilot)
duplicates drop city_key year, force
save "$TEMP/broadband.dta", replace

* ======================== panel ========================
use "$TEMP/panel_core.dta", clear
gen int year = .
replace year = 2011 if wave==1
replace year = 2013 if wave==2
replace year = 2015 if wave==3
replace year = 2018 if wave==4
replace year = 2020 if wave==5

* city key: standardize + fix renamed/abolished prefectures
gen city_key = strtrim(city)
replace city_key = city_key + "市" if !ustrregexm(city_key,"(市|盟|州|区|地区|旗)$")
replace city_key = "襄阳市" if city_key=="襄樊市"   // renamed 2010
replace city_key = "合肥市" if city_key=="巢湖市"   // prefecture dissolved 2011 -> merged into Hefei

merge m:1 city_key year using "$TEMP/dfii_keys.dta",     keep(master match) gen(_m_dfii)
merge m:1 city_key year using "$TEMP/city_controls.dta", keep(master match) gen(_m_ctrl)
merge m:1 city_key year using "$TEMP/broadband.dta",     keep(master match) gen(_m_bb)
di "==== regional merge match rates ===="
foreach m in _m_dfii _m_ctrl _m_bb {
    qui count if `m'==3
    di "`m' matched = " r(N) " / " _N
}

* ---- moderator: standardize + center ; controls: logs ----
foreach v in dfii dfii_breadth dfii_depth dfii_digit {
    egen z_`v' = std(`v')
}
rename z_dfii dfii_c
label var dfii_c "Regional DFII (standardized, centered)"
gen ln_gdppc  = ln(gdp_pc)
gen ln_doctors= ln(doctors)
gen ln_beds   = ln(beds)
global RCTRL "ln_gdppc urban_rate ln_doctors"
egen long city_id = group(city_key)

* ---- ASSERT: DFII coverage adequate ----
qui count if !missing(dfii_c)
assert r(N) > 0.90*_N

compress
save "$TEMP/panel_analytic.dta", replace
di "==== panel_analytic saved: " _N " obs ; DFII-matched: "
count if !missing(dfii_c)
di "==== regional vars summary ===="
summarize dfii_c ln_gdppc urban_rate ln_doctors broadband_did
