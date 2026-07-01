clear all
set more off
global TEMP "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/temp"
global TAB  "/Users/xuwenkai/Documents/Frontiers in Public Health/analysis/output/tables"

* ============== Table 1: descriptives by internet use (esttab + estpost ttest) ==============
use "$TEMP/panel_analytic.dta", clear
label var age "Age (years)"
label var chronic "Any chronic disease"
label var adlab_c "ADL limitations"
label var iadl "IADL limitations"
label var total_cognition "Cognition (0-21)"
label var ses_rank "Per-capita consumption"
label var ins "Medical insurance"
label var pension "Pension"
label var checkup "Preventive checkup"
label var outpatient "Outpatient (last month)"
label var inpatient "Inpatient (last year)"

eststo clear
estpost ttest age chronic adlab_c iadl total_cognition ses_rank ins pension checkup outpatient inpatient if inlist(wave,2,3,4), by(internet_use)
esttab using "$TAB/T1_descriptives.rtf", replace ///
    cells("mu_1(fmt(3)) mu_2(fmt(3)) b(fmt(3) star) p(fmt(3))") ///
    collabels("Non-user" "Internet user" "Difference" "p") ///
    label star(* 0.10 ** 0.05 *** 0.01) nonumber noobs ///
    title("Table 1. Descriptive statistics by internet use (CHARLS 2013-2018)") ///
    addnotes("Group means; difference = user minus non-user; t-test p-values.")

* ============== Supplementary tables (matrices -> one Word doc) ==============
* T2: concentration indices (>0 pro-rich)
matrix T2 = (0.172, 0.176, 0.034, 0.054 \ 0.165, 0.168, 0.031, 0.071 \ 0.127, 0.127, 0.034, 0.023)
matrix rownames T2 = 2013 2015 2018
matrix colnames T2 = Checkup_Erreygers Checkup_Wagstaff Outpatient Inpatient

* T5: decomposition contribution shares (%) by wave
use "$TEMP/decomp_wave.dta", clear
replace share = round(share*100, 0.1)
keep regressor wave share
reshape wide share, i(regressor) j(wave)
rename (share2 share3 share4) (y2013 y2015 y2018)
gen order = .
local i 0
foreach r in internet_use iu_dfii dfii edu ln_gdppc pension ln_doctors chronic total_cognition rural age ins gender marry adlab_c iadl {
    local ++i
    replace order = `i' if regressor=="`r'"
}
sort order
mkmat y2013 y2015 y2018, matrix(T5) rownames(regressor)

* T6: cross-level + robustness summary
matrix T6 = (0.087, ., ., . \ 0.107, ., ., . \ 0.019, -0.105, 0.109, 0.317 \ -0.044, -0.159, 0.040, 0.180)
matrix rownames T6 = Low_DFII_share High_DFII_share Diff_hi_lo Continuous_interaction
matrix colnames T6 = Estimate CI_low CI_high p_value

putdocx clear
putdocx begin
putdocx paragraph, style(Heading1)
putdocx text ("Supplementary results tables")
putdocx paragraph, style(Heading2)
putdocx text ("Table 2. Concentration indices of healthcare access by wave (>0 = pro-rich)")
putdocx table t2 = matrix(T2), rownames colnames nformat(%9.3f)
putdocx paragraph, style(Heading2)
putdocx text ("Table 5. Decomposition: contribution shares (%) to the checkup concentration index")
putdocx table t5 = matrix(T5), rownames colnames nformat(%9.1f)
putdocx paragraph, style(Heading2)
putdocx text ("Table 6. Cross-level equity test (digital contribution share; bootstrap, cluster=city)")
putdocx table t6 = matrix(T6), rownames colnames nformat(%9.3f)
putdocx paragraph, style(Heading2)
putdocx text ("Table 8. Robustness summary")
putdocx table t8 = (5,2), border(all, nil)
putdocx table t8(1,1) = ("Check"), bold
putdocx table t8(1,2) = ("Result"), bold
putdocx table t8(2,1) = ("Wagstaff vs Erreygers index")
putdocx table t8(2,2) = ("Checkup CI 0.176/0.168/0.127 ~ Erreygers; robust")
putdocx table t8(3,1) = ("Balanced panel (present all 3 waves)")
putdocx table t8(3,2) = ("internet x DFII = -0.095*** (stronger)")
putdocx table t8(4,1) = ("Unmet inpatient need strand (2011-2015)")
putdocx table t8(4,2) = ("CI ~ 0; internet effect null")
putdocx table t8(5,1) = ("Broadband-China IV (exploratory)")
putdocx table t8(5,2) = ("First-stage F=2.17 (weak); stay associational")
putdocx save "$TAB/Tables_supplement.docx", replace
di "TABLES2 DONE"
