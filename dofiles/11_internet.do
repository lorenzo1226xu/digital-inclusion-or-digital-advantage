clear all
set more off
global RAW "/Users/xuwenkai/Documents/Frontiers in Public Health/charls原版数据/原始数据+问卷2011~2020/_extracted"
global CLEAN "/Users/xuwenkai/Documents/Frontiers in Public Health/整理完的-charls数据"
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"

* ============================================================
* internet_use = social-activity "used internet" item, CONSISTENT 2011-2018 ONLY
* internet_ded = 2020 DEDICATED question (da040) -> SEPARATE variable (framing break, quarantined)
* (per Codex: do NOT merge the two framings into one column)
* ============================================================

* ---- 2020 dedicated measure (separate variable) ----
use "$RAW/2020/Health_Status_and_Functioning.dta", clear
gen internet_ded = .
replace internet_ded = 1 if da040==1
replace internet_ded = 0 if da040==2
gen wave = 5
keep ID wave internet_ded
tempfile w5
save `w5'

* ---- 2011-2018 consistent social-activity measure ----
use "$CLEAN/charls.dta", clear
keep if inlist(wave,1,2,3,4)
gen internet_use = social10
keep ID wave internet_use
append using `w5'

label var internet_use "Used internet, social-activity item (2011-2018 only)"
label var internet_ded "Used internet, dedicated 2020 question (da040) - separate construct"
compress
save "$TEMP/internet_long.dta", replace

di "==== internet_use (2011-2018) prevalence by wave ===="
tabstat internet_use, by(wave) stat(n mean)
di "==== internet_ded (2020) ===="
tabstat internet_ded, by(wave) stat(n mean)
