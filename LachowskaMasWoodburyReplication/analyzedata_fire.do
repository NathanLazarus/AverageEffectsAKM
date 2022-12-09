set more off, permanently 
use "my_dislocated.dta", replace

keep if flag_main==1
keep if dis_dummies <= 41	
summarize mean_hours mean_earnings if dislocated==0 & pre_industry==5
summarize mean_hours mean_earnings if dislocated==0 & pre_industry!=5
summarize mean_hours mean_earnings if dislocated==1 & pre_industry==5
summarize mean_hours mean_earnings if dislocated==1 & pre_industry!=5


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

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_earnings `my_controls'  i.dis_dummies if pre_industry!=5, fe cluster(ssn) 
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using main_fire.xls, excel label bdec(3) sdec(3)  ctitle(log_prim_earnings_nonfire) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1')
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings") vertical coeflabel(`coeflabel') replace
graph save Graph "Prim_Earnings_Log_notfire.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  i.dis_dummies if pre_industry!=5, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using main_fire.xls, excel label bdec(3) sdec(3)  ctitle(log_prim_hours_nonfire) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1')
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_Log_notfire.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  i.dis_dummies if pre_industry!=5, fe cluster(ssn) 
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using main_fire.xls, excel label bdec(3) sdec(3)  ctitle(log_prim_wage_nonfire) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1')
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_Log_notfire.gph", replace


set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_emp `my_controls'  i.dis_dummies if pre_industry!=5, fe cluster(ssn)
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Point estimate") title("Pr(Earnings > 0 or Hours > 0)") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Emp_notfire.gph", replace


********************
/// Figure A6-1  ///
********************
grc1leg "Prim_Earnings_Log_notfire.gph" "Prim_Hours_Log_notfire.gph" "Prim_Wage_Log_notfire.gph" "Prim_Emp_notfire.gph" 
graph save Graph "FigureA6_1.gph", replace 

erase "Prim_Earnings_Log_notfire.gph" 
erase "Prim_Hours_Log_notfire.gph"
erase "Prim_Wage_Log_notfire.gph" 
erase "Prim_Emp_notfire.gph" 












