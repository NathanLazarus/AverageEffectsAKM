set more off, permanently 

use "my_dislocated.dta", clear
 
set more off, permanently 


keep if flag_main==1
keep if dis_dummies <= 41       

bys ssn: gen trend = _n
replace trend = 0 if timey > 2006
tabulate dis_dummies, gen(dummies)
set matsize 10000

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


local my_controls_main _Yyyyyq* _HtimXmea* _EtimXmea* _FtimXpre* _NtimXpre* age age2 female agefem race* agerace* educ* ageeduc*  
local coeflabel ///
 dummies1 = "-6"  dummies2 = "-5" dummies3 =  " "  dummies4 = " "   dummies5 = " "    dummies6 = "-4"  dummies7 = " " /// 
 dummies8 = " "   dummies9 = " "  dummies10 = "-3" dummies11 = " "  dummies12 = " "  dummies13 = " " dummies14 = "-2" /// 
 dummies15 = " "  dummies16 = " " dummies17 = " "  dummies18 = "-1" dummies19 = " "  dummies20 = " " dummies21 = " " /// 
 dummies22 = "0"  dummies23 = " " dummies24 = " "  dummies25 = " "  dummies26 = "1"  dummies27 = " " /// 
 dummies28 = " "  dummies29 = " " dummies30 = "2"  dummies31 = " "  dummies32 = " "  dummies33 = " " dummies34 = "3" /// 
 dummies35 = " "  dummies36 = " " dummies37 = " "  dummies38 = "4"  dummies39 = " "  dummies40 = " " dummies41 = " " dummies42 = "5" 


set more off, permanently 
char yyyyq[omit] 20021

// Earnings
xtreg prim_earnings `my_controls_main'  dummies2-dummies42 , fe cluster(ssn)
est store prim_earnings_main
xi: regintfe prim_earnings `my_controls_main'  dummies2-dummies42,  id1(ssn) intvar(trend  ) cluster(ssn)
est store prim_earnings_trend
coefplot prim_earnings_main prim_earnings_trend, keep(*dummies*) recast(connected) xline(21) yline(0) xtitle("Year relative to displacement") ytitle("2010$, thousands") title("Quarterly earnings (2010$, thousands)") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_trend.gph", replace

// Log earnings
set more off, permanently  
char yyyyq[omit] 20021
xtreg log_prim_earnings `my_controls_main'  dummies2-dummies42 , fe cluster(ssn)
est store log_prim_earnings_main
xi: regintfe log_prim_earnings `my_controls_main'  dummies2-dummies42, id1(ssn) intvar(trend ) cluster(ssn)
local combination1 = (_b[dummies42]+_b[dummies41]+_b[dummies40]+_b[dummies39])/4 
local combination2 = _b[dummies23] 
est store log_prim_earnings_trend
outreg2 using trend_analysis.xls, excel label bdec(3) sdec(3) keep(*dummies*) ctitle(log_prim_earnings) addstat(First qtr, `combination2', Last four qtrs, `combination1') replace
coefplot log_prim_earnings_main log_prim_earnings_trend, keep(*dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_Log_trend.gph", replace

*******************
///Figure A7-1  ///
*******************
graph combine "Prim_Earnings_trend.gph" "Prim_Earnings_Log_trend.gph"  , cols(1) 
graph save Graph "FigureA7_1.gph", replace
erase "Prim_Earnings_trend.gph"
erase "Prim_Earnings_Log_trend.gph" 


// Hours
set more off, permanently 
char yyyyq[omit] 20021
xtreg prim_hours `my_controls_main'  dummies2-dummies42 , fe cluster(ssn)
est store prim_hours_main
xi: regintfe prim_hours `my_controls_main'  dummies2-dummies42 ,  id1(ssn) intvar(trend) cluster(ssn)
est store prim_hours_trend
coefplot prim_hours_main prim_hours_trend, keep(*dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Quarterly work hours") title("Quarterly work hours")  vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_trend.gph", replace 

// Log hours
set more off, permanently 
char yyyyq[omit] 20021 
xtreg log_prim_hours `my_controls_main'  dummies2-dummies42 , fe cluster(ssn)
est store log_prim_hours_main
xi: regintfe log_prim_hours `my_controls_main'  dummies2-dummies42,  id1(ssn) intvar(trend ) cluster(ssn)
local combination1 = (_b[dummies42]+_b[dummies41]+_b[dummies40]+_b[dummies39])/4 
local combination2 = _b[dummies23] 
est store log_prim_hours_trend
outreg2 using trend_analysis.xls, excel label bdec(3) sdec(3) keep(*dummies*)  ctitle(log_prim_hours) addstat(First qtr, `combination2', Last four qtrs, `combination1')
coefplot log_prim_hours_main log_prim_hours_trend, keep(*dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours")  vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_Log_trend.gph", replace

*******************
///Figure A7-2  ///
*******************
graph combine "Prim_Hours_trend.gph" "Prim_Hours_Log_trend.gph"  , cols(1) 
graph save Graph "FigureA7_2.gph", replace
erase "Prim_Hours_trend.gph"
erase "Prim_Hours_Log_trend.gph"


// Wage rates
set more off, permanently  
char yyyyq[omit] 20021 
xtreg prim_wage `my_controls_main'  dummies2-dummies42 , fe cluster(ssn)
est store prim_wage_main
xi: regintfe prim_wage `my_controls_main'  dummies2-dummies42, id1(ssn) intvar(trend ) cluster(ssn)
est store prim_wage_trend 
coefplot prim_wage_main prim_wage_trend, keep(*dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Hourly wage rate") title("Hourly wage rate")  vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_trend.gph", replace

// Log wage rates
set more off, permanently  
char yyyyq[omit] 20021 
xtreg log_prim_wage `my_controls_main'  dummies2-dummies42 , fe cluster(ssn)
est store log_prim_wage_main
xi: regintfe log_prim_wage `my_controls_main'  dummies2-dummies42, id1(ssn) intvar(trend ) cluster(ssn)
local combination1 = (_b[dummies42]+_b[dummies41]+_b[dummies40]+_b[dummies39])/4 
local combination2 = _b[dummies23] 
est store log_prim_wage_trend 
outreg2 using trend_analysis.xls, excel label bdec(3) sdec(3) keep(*dummies*) ctitle(log_prim_wage) addstat(First qtr, `combination2', Last four qtrs, `combination1')
coefplot log_prim_wage_main log_prim_wage_trend, keep(*dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate")  vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_Log_trend.gph", replace

*******************
///Figure A7-3  ///
*******************
graph combine "Prim_Wage_trend.gph" "Prim_Wage_Log_trend.gph"  , cols(1) 
graph save Graph "FigureA7_3.gph", replace
erase "Prim_Wage_trend.gph"
erase "Prim_Wage_Log_trend.gph"


