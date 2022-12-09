set more off, permanently 

use "my_dislocated.dta", clear

keep if flag_main==1
keep if dis_dummies <= 41	


set matsize 10000
local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) c.age##(c.age i.female i.race* i.educ*) 
local coeflabel /// 
2.dis_dummies = " "  3.dis_dummies = " "  4.dis_dummies = " "  6.dis_dummies = " "  7.dis_dummies = " " /// 
8.dis_dummies = " "  10.dis_dummies = " " 11.dis_dummies = " " 12.dis_dummies = " " 14.dis_dummies = " " /// 
15.dis_dummies = " " 16.dis_dummies = " " 18.dis_dummies = " " 19.dis_dummies = " " 20.dis_dummies = " " /// 
22.dis_dummies = " " 23.dis_dummies = " " 24.dis_dummies = " " 26.dis_dummies = " " 27.dis_dummies = " " /// 
28.dis_dummies = " " 30.dis_dummies = " " 31.dis_dummies = " " 32.dis_dummies = " " 34.dis_dummies = " " ///
35.dis_dummies = " " 36.dis_dummies = " " 38.dis_dummies = " " 39.dis_dummies = " " 40.dis_dummies = " " /// 
42.dis_dummies = " " 43.dis_dummies = " " 44.dis_dummies = " " 

// Earnings
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_earnings `my_controls'  i.dis_dummies, fe cluster(ssn)
est store earnings

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_earnings `my_controls'  i.dis_dummies, fe cluster(ssn)
est store log_earnings


// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_hours `my_controls'  i.dis_dummies, fe cluster(ssn)
est store hours

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  i.dis_dummies, fe cluster(ssn)
est store hours_log


// Wage rates
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  i.dis_dummies, fe cluster(ssn) 
est store log_wage

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_wage `my_controls'  i.dis_dummies, fe cluster(ssn)
est store wage


// Employed
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_emp `my_controls'  i.dis_dummies, fe cluster(ssn)
est store emp


*<><><><><><><><><><><><><><><><><><><><>* 
/// Keep only the controls: JLS 
keep if dislocated==0

/// Append the new definition of displaced workers
append using "my_dislocated2.dta"

replace prim_earnings = prim_earnings/1000 if dislocated2==1
replace all_earnings = all_earnings/1000 if dislocated2==1


set matsize 10000
local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) c.age##(c.age i.female i.race* i.educ*) 

local coeflabel /// 
2.dis_dummies = " "  3.dis_dummies = " "  4.dis_dummies = " "  6.dis_dummies = " "  7.dis_dummies = " " /// 
8.dis_dummies = " "  10.dis_dummies = " " 11.dis_dummies = " " 12.dis_dummies = " " 14.dis_dummies = " " /// 
15.dis_dummies = " " 16.dis_dummies = " " 18.dis_dummies = " " 19.dis_dummies = " " 20.dis_dummies = " " /// 
22.dis_dummies = " " 23.dis_dummies = " " 24.dis_dummies = " " 26.dis_dummies = " " 27.dis_dummies = " " /// 
28.dis_dummies = " " 30.dis_dummies = " " 31.dis_dummies = " " 32.dis_dummies = " " 34.dis_dummies = " " ///
35.dis_dummies = " " 36.dis_dummies = " " 38.dis_dummies = " " 39.dis_dummies = " " 40.dis_dummies = " " /// 
42.dis_dummies = " " 43.dis_dummies = " " 44.dis_dummies = " " 


// Earnings
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_earnings `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_earnings_dislocated2
outreg2 using dislocated2_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies)   ctitle(log_earnings) addstat(First qtr, `combination2', Last four qtrs, `combination1') replace
coefplot log_earnings log_earnings_dislocated2, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings")  vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_Log_dislocated2.gph", replace

// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store hours_log_dislocated2
outreg2 using dislocated2_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies)   ctitle(log_hours) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot hours_log hours_log_dislocated2, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_Log_dislocated2.gph", replace

// Wage rates
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  i.dis_dummies, fe cluster(ssn) 
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_wage_dislocated2 
outreg2 using dislocated2_analysis.xls, excel label bdec(3) sdec(3) keep(i.dis_dummies)   ctitle(log_wage) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot log_wage log_wage_dislocated2, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_Log_dislocated2.gph", replace


// Employed
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_emp `my_controls'  i.dis_dummies, fe cluster(ssn)
est store emp_dislocated2
coefplot emp emp_dislocated2, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Fraction employed") title("Quarterly employment probability") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Emp_dislocated2.gph", replace


*******************
/// Figure A3-1  ///
*******************
grc1leg "Prim_Earnings_Log_dislocated2.gph" "Prim_Hours_Log_dislocated2.gph"  "Prim_Wage_Log_dislocated2.gph" "Prim_Emp_dislocated2.gph"
graph save Graph "FigureA3_1.gph", replace

erase "Prim_Earnings_Log_dislocated2.gph"
erase "Prim_Hours_Log_dislocated2.gph"
erase "Prim_Wage_Log_dislocated2.gph"
erase "Prim_Emp_dislocated2.gph"

