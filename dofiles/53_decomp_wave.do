clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global OUT  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output"
use "$TEMP/panel_analytic.dta", clear

* ===== WAVE-SPECIFIC ERREYGERS decomposition via GENERALIZED CI (Codex R4: no divide-by-mean) =====
* GC(v)=2*cov_w(v,R) ; E(y)=4*GC(y) ; contribution_k=4*beta_k*GC(x_k) ; share=contrib/E(y)
gen double iu_dfii = internet_use*dfii_c
label var iu_dfii "internet_use x DFII"
local XS internet_use iu_dfii dfii age gender edu rural marry chronic adlab_c iadl total_cognition ins pension ln_gdppc ln_doctors

tempname pf
postfile `pf' byte wave str14 regressor double contrib double share using "$TEMP/decomp_wave.dta", replace
foreach w in 2 3 4 {
    preserve
    qui keep if wave==`w' & !missing(checkup,ses_rank,dfii_c,weight)
    foreach v of local XS {
        qui drop if missing(`v')
    }
    sort ses_rank
    qui sum weight
    qui gen double R = (sum(weight)-0.5*weight)/r(sum)
    qui sum R [aw=weight]
    local Rb = r(mean)
    qui reg checkup `XS' [pw=weight]
    qui gen double yR = checkup*R
    qui sum yR [aw=weight]
    local EyR = r(mean)
    qui sum checkup [aw=weight]
    local GCy = 2*(`EyR' - r(mean)*`Rb')
    local Ey  = 4*`GCy'
    foreach x of local XS {
        cap drop xR
        qui gen double xR = `x'*R
        qui sum xR [aw=weight]
        local ExR = r(mean)
        qui sum `x' [aw=weight]
        local GCx = 2*(`ExR' - r(mean)*`Rb')
        local contrib = 4*_b[`x']*`GCx'
        post `pf' (`w') ("`x'") (`contrib') (`contrib'/`Ey')
    }
    restore
}
postclose `pf'

use "$TEMP/decomp_wave.dta", clear
gen int year = 2009+2*wave
replace year=2018 if wave==4
di "===== digital contribution shares by wave (GC-based) ====="
gen byte grp = 1 if regressor=="internet_use"
replace grp = 2 if regressor=="iu_dfii"
replace grp = 3 if inlist(regressor,"internet_use","iu_dfii")==0
preserve
keep if grp<=2
drop regressor
reshape wide contrib share, i(wave year) j(grp)
gen double share_digital_total = share1 + share2
list year share1 share2 share_digital_total, clean noobs
di "  (share1=internet main ; share2=interaction iu_dfii ; total=digital)"
restore
export delimited using "$OUT/tables/decomp_wave.csv", replace
