
set more off, permanently

// Merge Woodcock's orthogonal match effects 

// Use the main displaced dataset
use "my_dislocated.dta", clear 
sort firmid
tostring yyyyq, generate(yyyyq_2) force 
gen str yyyyq_str = substr(yyyyq_2,1,4) 
destring yyyyq_str, gen(year)
xtset ssn mytime
merge m:m ssn firmid using "post_match_data_2002_2014.dta", keepusing(logearnings_me loghours_me logwage_me logearnings_met loghours_met logwage_met) 
drop if _merge == 2
keep if flag_main == 1
save  "outcome_me_merged.dta", replace

use "outcome_me_merged.dta", clear
keep if flag_main==1
keep if dis_dummies <= 41      


// Generate tenure variable
bys ssn firmid (yyyyq): gen tenure = _n
replace tenure  = tenure - 1
label var tenure "Tenure in quarters (0,1,2...)"
bys ssn firmid (yyyyq): gen compl_tenure = _N


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

qui xtreg log_prim_earnings `my_controls'  i.dis_dummies , fe cluster(ssn) 
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_earnings

qui xtreg logearnings_me  `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_earnings_me
outreg2 using me_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(me_earnings) addstat(First qtr, `combination2', Last four qtrs, `combination1') noaster replace

qui xtreg logearnings_met  `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_earnings_met
outreg2 using me_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(met_earnings) addstat(First qtr, `combination2', Last four qtrs, `combination1') noaster

qui xtreg log_prim_hours `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_hours

qui xtreg loghours_me  `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_hours_me
outreg2 using me_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(me_hours) addstat(First qtr, `combination2', Last four qtrs, `combination1') noaster

qui xtreg loghours_met  `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_hours_met
outreg2 using me_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(met_hours) addstat(First qtr, `combination2', Last four qtrs, `combination1') noaster

qui xtreg log_prim_wage `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_wage

qui xtreg logwage_me `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_wage_me
outreg2 using me_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(me_wage) addstat(First qtr, `combination2', Last four qtrs, `combination1') noaster

qui xtreg logwage_met `my_controls'  i.dis_dummies , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_wage_met
outreg2 using me_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies) ctitle(met_wage) addstat(First qtr, `combination2', Last four qtrs, `combination1') noaster

coefplot log_earnings log_earnings_met , keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings")   vertical coeflabel(`coeflabel')
graph save Graph "MEt_earnings.gph", replace

coefplot log_hours log_hours_met , keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours")   vertical coeflabel(`coeflabel')
graph save Graph "MEt_hours.gph", replace

coefplot log_wage log_wage_met , keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate")  vertical coeflabel(`coeflabel')
graph save Graph "MEt_wage.gph", replace

*******************
/// Figure 9  ///
*******************
grc1leg "MEt_earnings.gph" "MEt_hours.gph" "MEt_wage.gph" ,  cols(2) 
graph save Graph "Figure9.gph", replace

erase "MEt_earnings.gph" 
erase "MEt_hours.gph"
erase "MEt_wage.gph"


coefplot log_earnings log_earnings_me log_earnings_met, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings")   vertical coeflabel(`coeflabel')
graph save Graph "ME_earnings.gph", replace

coefplot log_hours log_hours_me log_hours_met, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours")   vertical coeflabel(`coeflabel')
graph save Graph "ME_hours.gph", replace

coefplot log_wage log_wage_me log_wage_met, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate")  vertical coeflabel(`coeflabel')
graph save Graph "ME_wage.gph", replace

*******************
/// Figure A11_1  ///
*******************
grc1leg "ME_earnings.gph" "ME_hours.gph" "ME_wage.gph" ,  cols(2) 
graph save Graph "FigureA11_1.gph", replace

erase "ME_earnings.gph"
erase "ME_hours.gph"
erase "ME_wage.gph"


