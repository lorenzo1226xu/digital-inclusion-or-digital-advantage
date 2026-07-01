# Wave-Harmonization Audit & Window Decision (P0 gate ② / P1.4)

Empirically verified from raw CHARLS modules, 2026-06-30. Wave: 1=2011, 2=2013, 3=2015, 4=2018, 5=2020.

## Construct comparability by wave

| Construct | Source var | 2011 | 2013 | 2015 | 2018 | 2020 | Comparable set |
|---|---|---|---|---|---|---|---|
| **internet_use** | da056s10 (11–18) / da040 (20) | 2.8% | 4.2% | 6.9% | 13.4% | **40.7%** | **2011–2018 consistent** (social-activity item); 2020 = *dedicated question* → framing break |
| internet_intensity | da057_10_ | ✓ | ✓ | ✓ | ✓(diff var) | n/a | secondary, 2013–2018 |
| **checkup** | ec001/ec001_w4 (13–18); da013 (20); ec001_1 (11) | **76%✗** | 42% | 42% | 48% | 47% | **2013–2020 consistent**; 2011 contaminated by CHARLS-2011 own physical measurement → **exclude** |
| **unmet_inpatient** | ee001 ("needed/advised inpatient, not received") | 4.4% | 6.5% | 5.7% | **dropped** | no module | **2011–2015 only** (2018 ee-block starts at ee003; 2020 has no health-care module) |
| unmet_outpatient | ed003 (reason not seeking) | ✓ | ✓ | ? | ? | no module | 2011–2013 confirmed; reason-coding needed |
| outpatient / inpatient | doctor / hospital (cleaned panel) | ✓ | ✓ | ✓ | ✓ | ✓ | all 5 waves |
| OOP expenditure | oop* | ✓ | ✓ | ✓ | ✓ | **missing** | 2011–2018 |
| controls (age/sex/edu/hukou/marry/ins/pension/chronic/ADL/IADL/cognition/income) | cleaned panel | ✓ | ✓ | ✓ | ✓ | ✓ | all 5 waves (verified) |

## The binding constraint
The three originally-co-primary outcomes do **not** share a common comfortable window:
- checkup needs **2013+** (2011 contaminated)
- unmet_inpatient needs **≤2015** (2018 dropped the item)
- consistent internet framing = **2011–2018**

Their triple intersection is only 2013+2015 (2 waves) — too thin to anchor the paper.

## DECISION (refined from spec v2)
- **Primary outcome = preventive checkup**; **primary window = 2013, 2015, 2018** (consistent checkup + consistent internet framing). 2020 = supplementary (checkup + utilization + dedicated-internet descriptives).
- **Secondary outcomes = outpatient & inpatient utilization** (all waves; core reported on 2013–2018).
- **unmet_inpatient = a separate 2011–2015 strand** (robustness / a focused secondary analysis), explicitly scoped to its 3 comparable waves — NOT forced into the main panel.
- 2011 retained for the unmet strand + utilization; excluded from checkup.

Rationale: maximizes comparability per outcome instead of forcing one window; checkup (vs BMC Public Health 2024, which had no digital variable) is the cleanest, most novel anchor; honestly scopes unmet need rather than overclaiming a 2011–2020 unmet panel.
