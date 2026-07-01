clear all
set more off
global RAW "/Users/xuwenkai/Documents/Frontiers in Public Health/charls原版数据/原始数据+问卷2011~2020/_extracted"
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"

* unmet_inpatient = needed/advised inpatient care but did not receive it (ee001==1)
*   consistent ~4-6% across 2011/2013/2015 ; 2018 var renamed -> locate below
tempfile master
clear
save `master', emptyok replace

* 2011
use "$RAW/2011/household_and_community_questionnaire_data/health_care_and_insurance.dta", clear
gen unmet_inpatient = .
replace unmet_inpatient = 1 if ee001==1
replace unmet_inpatient = 0 if ee001==2
gen wave = 1
keep ID wave unmet_inpatient
append using `master'
save `master', replace

* 2013
use "$RAW/2013/Health_Care_and_Insurance.dta", clear
gen unmet_inpatient = .
replace unmet_inpatient = 1 if ee001==1
replace unmet_inpatient = 0 if ee001==2
gen wave = 2
keep ID wave unmet_inpatient
append using `master'
save `master', replace

* 2015
use "$RAW/2015/Health_Care_and_Insurance.dta", clear
gen unmet_inpatient = .
replace unmet_inpatient = 1 if ee001==1
replace unmet_inpatient = 0 if ee001==2
gen wave = 3
keep ID wave unmet_inpatient
append using `master'
save `master', replace

save "$TEMP/unmet_long.dta", replace
di "==== unmet_inpatient prevalence by wave (2011/13/15) ===="
tabstat unmet_inpatient, by(wave) stat(n mean)

di "==== locate 2018 unmet-inpatient variable (ee* block) ===="
use "$RAW/2018/Health_Care_and_Insurance.dta", clear
ds ee*
foreach v of varlist ee* {
    local lab : variable label `v'
    di "`v' : `lab'"
}
