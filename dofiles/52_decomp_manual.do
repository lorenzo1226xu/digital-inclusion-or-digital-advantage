clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global OUT  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output"
use "$TEMP/panel_analytic.dta", clear

* ===== Wagstaff CI decomposition of checkup (2013-2018), CI computed from definition =====
local Xs internet_use dfii age chronic edu ins pension ln_gdppc ln_doctors
reg checkup `Xs' if inlist(wave,2,3,4) & !missing(ses_rank) [pw=weight]
keep if e(sample)

* weighted fractional rank of SES
sort ses_rank
qui sum weight
local W = r(sum)
gen double cw = sum(weight)
gen double R  = (cw - 0.5*weight)/`W'
qui sum R [aw=weight]
local Rbar = r(mean)

* program-free CI: CI(v)=2*cov_w(v,R)/mean_w(v)
capture program drop ci_of
program define ci_of, rclass
    args v
    tempvar vr
    qui gen double `vr' = `v'*R
    qui sum `vr' [aw=weight]
    local EvR = r(mean)
    qui sum `v' [aw=weight]
    local vbar = r(mean)
    return scalar ci = 2*(`EvR' - `vbar'*$Rbar_)/`vbar'
    return scalar mean = `vbar'
end
global Rbar_ = `Rbar'

ci_of checkup
local CIy = r(ci)
local ybar = r(mean)
di ""
di "===== DECOMPOSITION of checkup CI (CI_y = " %6.4f `CIy' ", mean=" %5.3f `ybar' ") ====="
di "  regressor            beta        CI(x)    contribution   % of CI_y"
tempname pf
postfile `pf' str14 regressor double contr double share using "$TEMP/decomp_checkup.dta", replace
local sumc = 0
foreach x of local Xs {
    ci_of `x'
    local CIx = r(ci)
    local xbar = r(mean)
    local bk = _b[`x']
    local contr = `bk'*`xbar'*`CIx'/`ybar'
    local share = `contr'/`CIy'
    local sumc = `sumc' + `contr'
    di "  " %-18s "`x'" %10.4f `bk' "  " %9.4f `CIx' "  " %11.5f `contr' "  " %7.1f 100*`share' "%"
    post `pf' ("`x'") (`contr') (`share')
}
postclose `pf'
local resid = `CIy' - `sumc'
di "  ----------"
di "  explained sum = " %8.5f `sumc' "  (" %5.1f 100*`sumc'/`CIy' "%)"
di "  residual      = " %8.5f `resid' "  (" %5.1f 100*`resid'/`CIy' "%)"
di "  >>> DIGITAL (internet_use) contribution share = see internet_use row above"
export delimited using "$OUT/tables/decomp_checkup.csv", replace
