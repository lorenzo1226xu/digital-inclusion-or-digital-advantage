clear all
set more off
global RAW "/Users/xuwenkai/Documents/Frontiers in Public Health/charls原版数据/原始数据+问卷2011~2020/_extracted"
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"

* harmonized checkup = had a physical examination in recall period (≈ recent / since last wave)
*  2013/2015 ec001: 1 -> 1 ; 2,3 -> 0
*  2018 ec001_w4: 1 -> 1 ; 2 -> 0
*  2020 da013: 1 -> 1 ; 2 -> 0 (da014 fallback)
*  2011 ec001_1 (year): 2009-2012 -> 1 ; 1950-2008 or 9999 -> 0

tempfile master
clear
save `master', emptyok replace

use "$RAW/2011/household_and_community_questionnaire_data/health_care_and_insurance.dta", clear
gen checkup = .
replace checkup = 1 if inrange(ec001_1, 2009, 2012)
replace checkup = 0 if inrange(ec001_1, 1950, 2008) | ec001_1==9999
gen wave = 1
gen byte checkup_approx = 1
keep ID wave checkup checkup_approx
append using `master'
save `master', replace

use "$RAW/2013/Health_Care_and_Insurance.dta", clear
gen checkup = .
replace checkup = 1 if ec001==1
replace checkup = 0 if inlist(ec001,2,3)
gen wave = 2
gen byte checkup_approx = 0
keep ID wave checkup checkup_approx
append using `master'
save `master', replace

use "$RAW/2015/Health_Care_and_Insurance.dta", clear
gen checkup = .
replace checkup = 1 if ec001==1
replace checkup = 0 if inlist(ec001,2,3)
gen wave = 3
gen byte checkup_approx = 0
keep ID wave checkup checkup_approx
append using `master'
save `master', replace

use "$RAW/2018/Health_Care_and_Insurance.dta", clear
gen checkup = .
replace checkup = 1 if ec001_w4==1
replace checkup = 0 if ec001_w4==2
gen wave = 4
gen byte checkup_approx = 0
keep ID wave checkup checkup_approx
append using `master'
save `master', replace

use "$RAW/2020/Health_Status_and_Functioning.dta", clear
gen checkup = .
replace checkup = 1 if da013==1
replace checkup = 0 if da013==2
replace checkup = 1 if missing(checkup) & da014==1
replace checkup = 0 if missing(checkup) & da014==2
gen wave = 5
gen byte checkup_approx = 0
keep ID wave checkup checkup_approx
append using `master'
save `master', replace

label var checkup "Had physical examination in recall period (1/0)"
label var checkup_approx "2011 year-based approximation flag"
compress
save "$TEMP/checkup_long.dta", replace

di "==== checkup prevalence by wave ===="
tabstat checkup, by(wave) stat(n mean)
