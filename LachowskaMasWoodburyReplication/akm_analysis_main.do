
set more off, permanently

// Merge AKM firm effects
use "post_akm_data_2002_2014.dta", clear
xtile logwagefe_xtile          = logwage_fe, nquantiles(5) 
xtile logearningsfe_xtile      = logearnings_fe, nquantiles(5) 
xtile loghoursfe_xtile         = loghours_fe, nquantiles(5)
collapse (mean) logwage_fe loghours_fe logearnings_fe logwagefe_xtile logearningsfe_xtile loghoursfe_xtile , by(firmid)
sort firmid
saveold  "dw_akm_2002_2014.dta", replace

use "my_dislocated.dta", replace
sort firmid
tostring yyyyq, generate(yyyyq_2) force 
gen str yyyyq_str = substr(yyyyq_2,1,4) 
destring yyyyq_str, gen(year)
xtset ssn mytime
merge m:1 (firmid) using "dw_akm_2002_2014.dta", generate(_merge_akm_2002_2014) 
keep if flag_main == 1
egen spell = group(ssn firmid)
drop  if  _merge_akm_2002_2014 == 2  

gen akm_earnings_xtile = . 
replace akm_earnings_xtile = logearningsfe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_earnings_xtile) 
replace akm_earnings_xtile = max 
drop max
label var akm_earnings_xtile "AKM earnings effect xtile in 2007Q4"
tab akm_earnings_xtile

gen akm_hours_xtile = . 
replace akm_hours_xtile = loghoursfe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_hours_xtile) 
replace akm_hours_xtile = max 
drop max
label var akm_hours_xtile "AKM hours effect xtile in 2007Q4"
tab akm_hours_xtile

gen akm_wage_xtile = . 
replace akm_wage_xtile = logwagefe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_wage_xtile) 
replace akm_wage_xtile = max 
drop max
label var akm_wage_xtile "AKM wage effect xtile in 2007Q4"
tab akm_wage_xtile

keep if flag_main==1
keep if dis_dummies <= 41       

/// Analysis 
xtset ssn mytime

save "my_dislocated_akm.dta", replace
use "my_dislocated_akm.dta", clear



***************************************
/// Appendix Table A12-4 ///
// See Excel table "akm_analysis.xls"
***************************************

local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) c.age##(c.age i.female i.race* i.educ*) 

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021 

xtreg log_prim_earnings `my_controls'  i.dis_dummies , fe cluster(ssn) 
gen akm_sample = e(sample)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using akm_analysis.xls, excel  label bdec(3) sdec(3) keep(i.dis_dummies)  ctitle(prim_earnings) addstat(First qtr, `combination2', Last four qtrs, `combination1')   replace

xtreg logearnings_fe  `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using akm_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(fe_earnings) addstat(First qtr, `combination2', Last four qtrs, `combination1')

xtreg log_prim_hours `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using akm_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(prim_hours) addstat(First qtr, `combination2', Last four qtrs, `combination1')

xtreg loghours_fe  `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using akm_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(fe_hours) addstat(First qtr, `combination2', Last four qtrs, `combination1')

xtreg log_prim_wage `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using akm_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(prim_wage) addstat(First qtr, `combination2', Last four qtrs, `combination1')

xtreg logwage_fe `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using akm_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(fe_wage) addstat(First qtr, `combination2', Last four qtrs, `combination1') noaster


local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) c.age##(c.age i.female i.race* i.educ*) 
local coeflabel /// 
2.dis_dummies = " "  3.dis_dummies = " "  4.dis_dummies = " "  6.dis_dummies = " "  7.dis_dummies = " " ///  
8.dis_dummies = " "  10.dis_dummies = " " 11.dis_dummies = " " 12.dis_dummies = " " 14.dis_dummies = " " /// 
15.dis_dummies = " " 16.dis_dummies = " " 18.dis_dummies = " " 19.dis_dummies = " " 20.dis_dummies = " " /// 
22.dis_dummies = " " 23.dis_dummies = " " 24.dis_dummies = " " 26.dis_dummies = " " 27.dis_dummies = " " /// 
28.dis_dummies = " " 30.dis_dummies = " " 31.dis_dummies = " " 32.dis_dummies = " " 34.dis_dummies = " " /// 
35.dis_dummies = " " 36.dis_dummies = " " 38.dis_dummies = " " 39.dis_dummies = " " 40.dis_dummies = " " /// 
42.dis_dummies = " " 43.dis_dummies = " " 44.dis_dummies = " " 

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_earnings `my_controls'  i.dis_dummies , fe cluster(ssn)
est store log_earnings
xtreg logearnings_fe `my_controls'  i.dis_dummies , fe cluster(ssn)
est store employer_fe_earnings
coefplot employer_fe_earnings log_earnings, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings")  vertical coeflabel(`coeflabel')
graph save Graph "AKM_earnings.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  i.dis_dummies , fe cluster(ssn)
est store log_hours
xtreg loghours_fe `my_controls'  i.dis_dummies , fe cluster(ssn)
est store employer_fe_hours
coefplot employer_fe_hours log_hours, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours") vertical  coeflabel(`coeflabel')
graph save Graph "AKM_hours.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  i.dis_dummies , fe cluster(ssn)
est store log_wage
xtreg logwage_fe `my_controls' i.dis_dummies , fe cluster(ssn)
est store employer_fe_wage
coefplot employer_fe_wage log_wage,  keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "AKM_wage.gph", replace


****************
/// Figure 6  ///
****************
grc1leg "AKM_earnings.gph" "AKM_hours.gph" "AKM_wage.gph" ,  cols(2) 
graph save Graph "Figure6.gph", replace

erase "AKM_earnings.gph" 
erase "AKM_hours.gph" 
erase "AKM_wage.gph"

