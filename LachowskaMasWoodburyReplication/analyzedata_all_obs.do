set more off, permanently 

use "my_dislocated.dta", clear
set more off, permanently 

keep if flag_allobs==1
keep if dis_dummies <= 41	
summarize mean_hours mean_earnings if dislocated==0
summarize mean_hours mean_earnings if dislocated==1
scalar earnings_mean = r(mean) 
keep ssn prim_earnings log_prim_earnings prim_hours log_prim_hours ///
log_prim_wage prim_wage dis_dummies yyyyq timey mean_hours mean_earnings pre_logfirmsize pre_industry

set matsize 10000
local my_controls  i.yyyyq  i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) 
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
xtreg prim_earnings `my_controls'  b0.dis_dummies, fe cluster(ssn) 
scalar combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
scalar combination2 = _b[22.dis_dummies] 
disp combination1
disp combination2
scalar r = 1/(1.01227)
scalar combination3 = 1000*(_b[22.dis_dummies]*r^0+_b[23.dis_dummies]*r^1+_b[24.dis_dummies]*r^2+_b[25.dis_dummies]*r^3+ ///
_b[26.dis_dummies]*r^4+_b[27.dis_dummies]*r^5+_b[28.dis_dummies]*r^6+_b[29.dis_dummies]*r^7+_b[30.dis_dummies]*r^8+ ///
_b[31.dis_dummies]*r^9+_b[32.dis_dummies]*r^10+_b[33.dis_dummies]*r^11+_b[34.dis_dummies]*r^12+_b[35.dis_dummies]*r^13+ ///
_b[36.dis_dummies]*r^14+_b[37.dis_dummies]*r^15+_b[38.dis_dummies]*r^16+_b[39.dis_dummies]*r^17+_b[40.dis_dummies]*r^18+ ///
_b[41.dis_dummies]*r^19) 
disp combination3

// Extrapolating to 20 years using the last estimate of displacement
scalar combination4 = 1000*(_b[22.dis_dummies]*r^0+_b[23.dis_dummies]*r^1+_b[24.dis_dummies]*r^2+_b[25.dis_dummies]*r^3+ ///
_b[26.dis_dummies]*r^4+_b[27.dis_dummies]*r^5+_b[28.dis_dummies]*r^6+_b[29.dis_dummies]*r^7+_b[30.dis_dummies]*r^8+ ///
_b[31.dis_dummies]*r^9+_b[32.dis_dummies]*r^10+_b[33.dis_dummies]*r^11+_b[34.dis_dummies]*r^12+_b[35.dis_dummies]*r^13+ ///
_b[36.dis_dummies]*r^14+_b[37.dis_dummies]*r^15+_b[38.dis_dummies]*r^16+_b[39.dis_dummies]*r^17+_b[40.dis_dummies]*r^18+ ///
_b[41.dis_dummies]*r^19 +_b[41.dis_dummies]*r^20+_b[41.dis_dummies]*r^21+_b[41.dis_dummies]*r^22 +_b[41.dis_dummies]*r^23+ /// 
_b[41.dis_dummies]*r^24 +_b[41.dis_dummies]*r^25+_b[41.dis_dummies]*r^26+_b[41.dis_dummies]*r^27 +_b[41.dis_dummies]*r^28+ /// 
_b[41.dis_dummies]*r^29 +_b[41.dis_dummies]*r^30+_b[41.dis_dummies]*r^31+_b[41.dis_dummies]*r^32 +_b[41.dis_dummies]*r^33+ /// 
_b[41.dis_dummies]*r^34 +_b[41.dis_dummies]*r^35+_b[41.dis_dummies]*r^36+_b[41.dis_dummies]*r^37 +_b[41.dis_dummies]*r^38+ /// 
_b[41.dis_dummies]*r^39 +_b[41.dis_dummies]*r^40+_b[41.dis_dummies]*r^41+_b[41.dis_dummies]*r^42 +_b[41.dis_dummies]*r^43+ /// 
_b[41.dis_dummies]*r^44 +_b[41.dis_dummies]*r^45+_b[41.dis_dummies]*r^46+_b[41.dis_dummies]*r^47 +_b[41.dis_dummies]*r^48+ /// 
_b[41.dis_dummies]*r^49 +_b[41.dis_dummies]*r^50+_b[41.dis_dummies]*r^51+_b[41.dis_dummies]*r^52 +_b[41.dis_dummies]*r^53+ /// 
_b[41.dis_dummies]*r^54 +_b[41.dis_dummies]*r^55+_b[41.dis_dummies]*r^56+_b[41.dis_dummies]*r^57 +_b[41.dis_dummies]*r^58+ /// 
_b[41.dis_dummies]*r^59 +_b[41.dis_dummies]*r^60+_b[41.dis_dummies]*r^61+_b[41.dis_dummies]*r^62 +_b[41.dis_dummies]*r^63+ /// 
_b[41.dis_dummies]*r^64 +_b[41.dis_dummies]*r^65+_b[41.dis_dummies]*r^66+_b[41.dis_dummies]*r^67 +_b[41.dis_dummies]*r^68+ /// 
_b[41.dis_dummies]*r^69 +_b[41.dis_dummies]*r^70+_b[41.dis_dummies]*r^71+_b[41.dis_dummies]*r^72 +_b[41.dis_dummies]*r^73+ /// 
_b[41.dis_dummies]*r^74 +_b[41.dis_dummies]*r^75+_b[41.dis_dummies]*r^76+_b[41.dis_dummies]*r^77 +_b[41.dis_dummies]*r^78+ ///
_b[41.dis_dummies]*r^79 +_b[41.dis_dummies]*r^80+_b[41.dis_dummies]*r^81+_b[41.dis_dummies]*r^82 +_b[41.dis_dummies]*r^83+ /// 
_b[41.dis_dummies]*r^84 +_b[41.dis_dummies]*r^85+_b[41.dis_dummies]*r^86+_b[41.dis_dummies]*r^87 +_b[41.dis_dummies]*r^88+ /// 
_b[41.dis_dummies]*r^89 +_b[41.dis_dummies]*r^90+_b[41.dis_dummies]*r^91+_b[41.dis_dummies]*r^92 +_b[41.dis_dummies]*r^93+ /// 
_b[41.dis_dummies]*r^94 +_b[41.dis_dummies]*r^95+_b[41.dis_dummies]*r^96+_b[41.dis_dummies]*r^97 +_b[41.dis_dummies]*r^98+ /// 
_b[41.dis_dummies]*r^99 +_b[41.dis_dummies]*r^100+_b[41.dis_dummies]*r^101)  
disp combination4
disp earnings_mean

**** Note, to get the Table 3 PDV of losses/pre-disaplcement annual earnings ratios, 
**** divide the PDV number by average pre-displacement earnings fordisplwed workers times 4; this number is listed above 

coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0) xtitle("Year relative to displacement") ytitle("2010$, thousands") title("Quarterly earnings (2010$, thousands)") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_all_obs.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_earnings `my_controls'  b0.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using all_analysis.xls, excel keep(i.dis_dummies)   label bdec(3) sdec(3)  ctitle(log_earnings) addstat(First qtr, `combination2', Last four qtrs, `combination1') replace
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_Log_all_obs.gph", replace

*******************
/// Figure A5-1  ///
*******************
graph combine "Prim_Earnings_all_obs.gph"  "Prim_Earnings_Log_all_obs.gph"  , cols(1) 
graph save Graph "FigureA5_1.gph", replace
erase "Prim_Earnings_all_obs.gph"
erase "Prim_Earnings_Log_all_obs.gph"

// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_hours `my_controls'  b0.dis_dummies, fe cluster(ssn)
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Quarterly work hours") title("Quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_all_obs.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  b0.dis_dummies, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using all_analysis.xls, excel keep(i.dis_dummies)   label bdec(3) sdec(3)  ctitle(log_hours) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours")  vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_Log_all_obs.gph", replace

*******************
/// Figure A5-2  ///
*******************
graph combine "Prim_Hours_all_obs.gph"  "Prim_Hours_Log_all_obs.gph"   , cols(1) 
graph save Graph "FigureA5_2.gph", replace
erase "Prim_Hours_all_obs.gph"
erase "Prim_Hours_Log_all_obs.gph" 

// Wage rates
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  b0.dis_dummies, fe cluster(ssn) 
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using all_analysis.xls, excel keep(i.dis_dummies)   label bdec(3) sdec(3)  ctitle(logwage) addstat(First qtr, `combination2', Last four qtrs, `combination1') 
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_Log_all_obs.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_wage `my_controls'  b0.dis_dummies, fe cluster(ssn)
coefplot, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Hourly wage rate") title("Hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_all_obs.gph", replace

*******************
/// Figure A5-3  ///
*******************
graph combine "Prim_Wage_all_obs.gph" "Prim_Wage_Log_all_obs.gph"  , cols(1) 
graph save Graph "FigureA5_3.gph", replace
erase "Prim_Wage_all_obs.gph"
erase "Prim_Wage_Log_all_obs.gph" 
