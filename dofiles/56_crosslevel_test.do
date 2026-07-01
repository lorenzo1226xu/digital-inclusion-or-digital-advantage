clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
use "$TEMP/panel_analytic.dta", clear
gen double iu_dfii = internet_use*dfii_c
local XS internet_use iu_dfii dfii age gender edu rural marry chronic adlab_c iadl total_cognition ins pension ln_gdppc ln_doctors
keep if inlist(wave,2,3,4) & !missing(checkup,ses_rank,dfii_c,weight)
foreach v of local XS {
    drop if missing(`v')
}
xtset, clear

* program: wave-averaged Erreygers contribution SHARE of the interaction term iu_dfii (continuous cross-level moderator)
capture program drop digiu
program define digiu, rclass
    tempvar R cw tot yR xR
    bysort wave (ses_rank): gen double `cw'=sum(weight)
    by wave: egen double `tot'=total(weight)
    gen double `R'=(`cw'-0.5*weight)/`tot'
    local s=0
    local n=0
    foreach w in 2 3 4 {
        qui reg checkup internet_use iu_dfii dfii age gender edu rural marry chronic adlab_c iadl total_cognition ins pension ln_gdppc ln_doctors if wave==`w' [pw=weight]
        qui sum `R' if wave==`w' [aw=weight]
        local Rb=r(mean)
        cap drop `yR'
        qui gen double `yR'=checkup*`R'
        qui sum `yR' if wave==`w' [aw=weight]
        local EyR=r(mean)
        qui sum checkup if wave==`w' [aw=weight]
        local Ey=4*(2*(`EyR'-r(mean)*`Rb'))
        cap drop `xR'
        qui gen double `xR'=iu_dfii*`R'
        qui sum `xR' if wave==`w' [aw=weight]
        local ExR=r(mean)
        qui sum iu_dfii if wave==`w' [aw=weight]
        local GCx=2*(`ExR'-r(mean)*`Rb')
        local s=`s'+(4*_b[iu_dfii]*`GCx')/`Ey'
        local n=`n'+1
    }
    return scalar share=`s'/`n'
end

di "===== continuous cross-level test: avg iu_dfii contribution share ====="
digiu
local pe = r(share)
di "  point estimate (wave-avg iu_dfii share) = " %6.3f `pe'

tempname bs
postfile `bs' double sh using "$TEMP/bs_iu.dta", replace
set seed 20260701
forvalues b=1/300 {
    preserve
    bsample, cluster(city_id)
    capture digiu
    if _rc==0 post `bs' (r(share))
    restore
}
postclose `bs'
use "$TEMP/bs_iu.dta", clear
qui sum sh
di "  bootstrap mean=" %6.3f r(mean) "  sd=" %6.3f r(sd) "  reps=" _N
_pctile sh, p(2.5 97.5)
di "  95% CI = [" %6.3f r(r1) " , " %6.3f r(r2) "]"
qui count if sh>=0
di "  one-sided p (share>=0) = " %5.3f r(N)/_N
