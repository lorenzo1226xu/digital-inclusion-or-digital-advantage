clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global OUT  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output"
use "$TEMP/panel_analytic.dta", clear

gen double iu_dfii  = internet_use*dfii_c
gen byte   dfii_hi  = (dfii_c>0) if !missing(dfii_c)
keep if inlist(wave,2,3,4) & !missing(checkup,ses_rank,dfii_c,weight)
local XS internet_use iu_dfii dfii age gender edu rural marry chronic adlab_c iadl total_cognition ins pension ln_gdppc ln_doctors
foreach v of local XS {
    drop if missing(`v')
}

* digital (internet + interaction) Erreygers contribution share within each DFII stratum; returns hi - lo
capture program drop digshare
program define digshare, rclass
    tempvar R cw tot yR xR
    bysort dfii_hi (ses_rank): gen double `cw' = sum(weight)
    by dfii_hi: egen double `tot' = total(weight)
    gen double `R' = (`cw' - 0.5*weight)/`tot'
    forvalues g=0/1 {
        qui reg checkup internet_use iu_dfii dfii age gender edu rural marry chronic adlab_c iadl total_cognition ins pension ln_gdppc ln_doctors if dfii_hi==`g' [pw=weight]
        qui sum checkup if dfii_hi==`g' [aw=weight]
        local mu=r(mean)
        qui sum `R' if dfii_hi==`g' [aw=weight]
        local Rb=r(mean)
        cap drop `yR'
        qui gen double `yR'=checkup*`R'
        qui sum `yR' if dfii_hi==`g' [aw=weight]
        local Ey=4*`mu'*(2*(r(mean)-`mu'*`Rb')/`mu')
        local dig=0
        foreach x in internet_use iu_dfii {
            qui sum `x' if dfii_hi==`g' [aw=weight]
            local xb=r(mean)
            cap drop `xR'
            qui gen double `xR'=`x'*`R'
            qui sum `xR' if dfii_hi==`g' [aw=weight]
            local dig=`dig'+4*_b[`x']*`xb'*(2*(r(mean)-`xb'*`Rb')/`xb')
        }
        local s`g'=`dig'/`Ey'
    }
    return scalar share_lo=`s0'
    return scalar share_hi=`s1'
    return scalar diff=`s1'-`s0'
end

xtset, clear   // allow bootstrap to resample clusters without panel time-value conflict
di "===== point estimates ====="
digshare
di "  Low-DFII digital share  = " %6.3f r(share_lo)
di "  High-DFII digital share = " %6.3f r(share_hi)
di "  difference (hi - lo)    = " %6.3f r(diff)

di "===== manual cluster bootstrap (city), 300 reps ====="
tempname bs
postfile `bs' double diff double shhi double shlo using "$TEMP/bs_strat.dta", replace
set seed 20260701
forvalues b=1/300 {
    preserve
    bsample, cluster(city_id)
    capture digshare
    if _rc==0 post `bs' (r(diff)) (r(share_hi)) (r(share_lo))
    restore
}
postclose `bs'
use "$TEMP/bs_strat.dta", clear
qui sum diff
di "  bootstrap diff mean = " %6.3f r(mean) "  sd = " %6.3f r(sd) "  (reps=" _N ")"
_pctile diff, p(2.5 97.5)
di "  95% percentile CI for (hi-lo) = [" %6.3f r(r1) " , " %6.3f r(r2) "]"
qui count if diff<=0
di "  one-sided p (share of reps with diff<=0) = " %5.3f r(N)/_N
