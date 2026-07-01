clear all
set more off
global ROOT "/Users/xuwenkai/Documents/Frontiers in Public Health"
global RAW  "$ROOT/charls原版数据/原始数据+问卷2011~2020/_extracted"
global CLEAN "$ROOT/整理完的-charls数据"
global TEMP "$ROOT/analysis/temp"
global OUT  "$ROOT/analysis/output"
cap mkdir "$ROOT/analysis"
cap mkdir "$TEMP"
cap mkdir "$OUT"
cap mkdir "$OUT/tables"
cap mkdir "$OUT/figures"
cap mkdir "$ROOT/analysis/data"
cap mkdir "$ROOT/analysis/data/dfii"
cap mkdir "$ROOT/analysis/data/regional"
cap mkdir "$ROOT/docs/protocols"
di "DIRS OK"

di "==== package presence check ===="
foreach p in ftools reghdfe conindex ivreghdfe estout coefplot esttab {
    capture which `p'
    if _rc di "MISSING: `p'"
    else   di "OK: `p'"
}
di "==== stata version / ado dir ===="
about
sysdir
di "SETUP DONE"
