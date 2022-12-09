set more off, permanently 
set more off, permanently 

use "my_dislocated.dta", replace


/// Analysis 
keep if flag_main==1
keep if dis_dummies <= 41

xi i.yyyyq, prefix(_Y)
xi i.timey*mean_hours, prefix(_H)
xi i.timey*mean_earnings, prefix(_E)
xi i.timey*pre_logfirmsize, prefix(_F)
xi i.timey*i.pre_industry, prefix(_N)

gen age2 = age*age
gen agefem = age*female 

gen agerace1 = age*race1 
gen agerace2 = age*race2
gen agerace3 = age*race3
gen agerace4 = age*race4
gen agerace5 = age*race5
gen agerace6 = age*race6

gen ageeduc1 = age*educ1
gen ageeduc2 = age*educ2
gen ageeduc3 = age*educ3
gen ageeduc4 = age*educ4
gen ageeduc5 = age*educ5
gen ageeduc6 = age*educ6
gen ageeduc7 = age*educ7
gen ageeduc8 = age*educ8



set matsize 10000

local coeflabel /// 
2.dis_dummies = " "  3.dis_dummies = " "  4.dis_dummies = " "  6.dis_dummies = " "  7.dis_dummies = " " /// 
8.dis_dummies = " "  10.dis_dummies = " " 11.dis_dummies = " " 12.dis_dummies = " " 14.dis_dummies = " " /// 
15.dis_dummies = " " 16.dis_dummies = " " 18.dis_dummies = " " 19.dis_dummies = " " 20.dis_dummies = " " /// 
22.dis_dummies = " " 23.dis_dummies = " " 24.dis_dummies = " " 26.dis_dummies = " " 27.dis_dummies = " " /// 
28.dis_dummies = " " 30.dis_dummies = " " 31.dis_dummies = " " 32.dis_dummies = " " 34.dis_dummies = " " ///
35.dis_dummies = " " 36.dis_dummies = " " 38.dis_dummies = " " 39.dis_dummies = " " 40.dis_dummies = " " /// 
42.dis_dummies = " " 43.dis_dummies = " " 44.dis_dummies = " " 


/// RIFreg Does not accept ## interaction terms
local my_controls _Yyyyyq* _HtimXmea* _EtimXmea* _FtimXpre* _NtimXpre* age age2 female agefem race* agerace* educ* ageeduc*  


*********************************************
/// Appendix Table A12-3 ///
// See Excel table "hours_distr_analysis.xls"
*********************************************

*************************************************************************
/// Figure 4 ///
// To obtain the figure, divide the displacement coefficients from 
// "hours_distr_analysis.xls" by the baseline average reported at bottom 
// of each column.
*************************************************************************

set more off, permanently 
char dis_dummies[omit] 0 
gen hours_zero = (prim_hours>0)
summarize hours_zero if dislocated==1 & yyyyq<20061, detail
local mean_hours_0 `r(mean)' 
xi: xtreg hours_zero  i.dis_dummies `my_controls', fe cluster(ssn)
outreg2 using hours_distr_analysis.xls, excel label bdec(3) sdec(3) ctitle(hours_0)   addstat(Pre-disp. mean, `mean_hours_0') noaster replace
est store hours_0

set more off, permanently 
char dis_dummies[omit] 0 
summarize prim_hours if dislocated==1 & yyyyq<20061, detail
local hours_10 = `r(p10)' 
xi:  xtrifreg prim_hours  i.dis_dummies `my_controls' , quantile(0.1) fe i(ssn)  
outreg2 using hours_distr_analysis.xls, excel label bdec(2) sdec(2) ctitle(hours_10)    addstat(Pre-disp. centile, `hours_10')  noaster 
est store hours_10

char dis_dummies[omit] 0 
summarize prim_hours if dislocated==1 & yyyyq<20061, detail
local hours_25 = `r(p25)' 
xi:  xtrifreg prim_hours  i.dis_dummies `my_controls' , quantile(0.25) fe i(ssn) 
outreg2 using hours_distr_analysis.xls, excel label bdec(2) sdec(2) ctitle(hours_25)   addstat(Pre-disp. centile, `hours_25')  noaster 
est store hours_25

char dis_dummies[omit] 0 
summarize prim_hours if dislocated==1 & yyyyq<20061, detail
local hours_50 = `r(p50)' 
xi:  xtrifreg prim_hours  i.dis_dummies `my_controls' , quantile(0.5) fe i(ssn)  
outreg2 using hours_distr_analysis.xls, excel label bdec(2) sdec(2) ctitle(hours_50)  addstat(Pre-disp. centile, `hours_50')  noaster 
est store hours_50

char dis_dummies[omit] 0 
summarize prim_hours if dislocated==1 & yyyyq<20061, detail
local hours_75 = `r(p75)' 
xi:  xtrifreg prim_hours  i.dis_dummies `my_controls' , quantile(0.75) fe i(ssn)  
outreg2 using hours_distr_analysis.xls, excel label bdec(2) sdec(2) ctitle(hours_75)  addstat(Pre-disp. centile, `hours_75')  noaster 
est store hours_75

char dis_dummies[omit] 0 
summarize prim_hours if dislocated==1 & yyyyq<20061, detail
local hours_90 = `r(p90)'  
xi:  xtrifreg prim_hours  i.dis_dummies `my_controls' , quantile(0.9) fe i(ssn)  
outreg2 using hours_distr_analysis.xls, excel label bdec(2) sdec(2) ctitle(hours_90)   addstat(Pre-disp. centile, `hours_90')  noaster 
est store hours_90

