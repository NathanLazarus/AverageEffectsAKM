set more off, permanently 

use "my_dislocated.dta", replace

keep if flag_pk==1
keep if dis_dummies <= 41	
summarize mean_hours mean_earnings if dislocated==0
summarize mean_hours mean_earnings if dislocated==1

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
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using pk_analysis.xls, excel label bdec(3) sdec(3)  ctitle(prim_earnings) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1')  replace
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0) xtitle("Year relative to displacement") ytitle("2010$, thousands") title("Quarterly earnings (2010$, thousands") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_pk.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_earnings `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using pk_analysis.xls, excel label bdec(3) sdec(3)  ctitle(log_prim_earnings) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_Log_pk.gph", replace

*******************
///Figure A4-1  ///
*******************
graph combine "Prim_Earnings_pk.gph" "Prim_Earnings_Log_pk.gph"  , cols(1) 
graph save Graph "FigureA4_1.gph", replace

erase "Prim_Earnings_pk.gph"
erase "Prim_Earnings_Log_pk.gph"


// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_hours `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using pk_analysis.xls, excel label bdec(3) sdec(3)  ctitle(prim_hours) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Quarterly work hours") title("Quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_pk.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using pk_analysis.xls, excel label bdec(3) sdec(3)  ctitle(log_prim_hours) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_Log_pk.gph", replace

*******************
/// Figure A4-2  ///
*******************
graph combine "Prim_Hours_pk.gph"  "Prim_Hours_Log_pk.gph"   , cols(1) 
graph save Graph "FigureA4_2.gph", replace

erase "Prim_Hours_pk.gph" 
erase "Prim_Hours_Log_pk.gph"

// Wage rates
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  i.dis_dummies, fe cluster(ssn) 
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using pk_analysis.xls, excel label bdec(3) sdec(3)  ctitle(log_prim_wage) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_Log_pk.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_wage `my_controls'  i.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using pk_analysis.xls, excel label bdec(3) sdec(3)  ctitle(prim_wage) keep(i.dis_dummies)  addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Hourly wage rate") title("Hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_pk.gph", replace

*******************
/// Figure A4-3  ///
*******************
graph combine "Prim_Wage_pk.gph" "Prim_Wage_Log_pk.gph"  , cols(1) 
graph save Graph "FigureA4_3.gph", replace

erase "Prim_Wage_pk.gph"
erase "Prim_Wage_Log_pk.gph"
