clear all
set more off
local HD "/Users/xuwenkai/Documents/Frontiers in Public Health/charls原版数据/原始数据+问卷2011~2020/Harmonized_CHARLS_D/H_CHARLS_D_Data.dta"
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"

use ID r1wtresp r2wtresp r3wtresp r4wtresp using "`HD'", clear
* 2020 individual weight if released
capture confirm variable r5wtresp
* (loaded selectively; r5 added below only if present in file)
rename (r1wtresp r2wtresp r3wtresp r4wtresp) (wt1 wt2 wt3 wt4)
reshape long wt, i(ID) j(wave)
rename wt weight
label var weight "CHARLS individual cross-sectional weight (r*wtresp, 2011-2018)"
drop if missing(weight)
compress
save "$TEMP/weights_long.dta", replace
di "==== weights by wave ===="
tabstat weight, by(wave) stat(n mean min max)
