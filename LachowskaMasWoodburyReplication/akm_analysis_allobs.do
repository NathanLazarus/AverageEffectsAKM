
set more off, permanently
use "my_dislocated.dta", clear
sort firmid
tostring yyyyq, generate(yyyyq_2) force 
gen str yyyyq_str = substr(yyyyq_2,1,4) 
destring yyyyq_str, gen(year)
xtset ssn mytime

merge m:1 (firmid) using "dw_akm_2002_2014.dta", generate(_merge_akm_2002_2014)  keepusing(logwage_fe loghours_fe logearnings_fe)
drop  if  _merge_akm_2002_2014 ==2  

keep if flag_allobs==1
keep if dis_dummies <= 41	

set matsize 10000
xtset ssn mytime

local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) 
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
graph save Graph "AKM_earnings_all.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  i.dis_dummies , fe cluster(ssn)
est store log_hours
xtreg loghours_fe `my_controls'  i.dis_dummies , fe cluster(ssn)
est store employer_fe_hours
coefplot employer_fe_hours log_hours, keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours")  vertical  coeflabel(`coeflabel')
graph save Graph "AKM_hours_all.gph", replace

set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  i.dis_dummies , fe cluster(ssn)
est store log_wage
xtreg logwage_fe `my_controls' i.dis_dummies , fe cluster(ssn)
est store employer_fe_wage
coefplot employer_fe_wage log_wage,  keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate")  vertical coeflabel(`coeflabel')
graph save Graph "AKM_wage_all.gph", replace


*******************
///Figure A5-4  ///
*******************
grc1leg "AKM_earnings_all.gph" "AKM_hours_all.gph" "AKM_wage_all.gph" ,  cols(2) 
graph save Graph "FigureA5_4.gph", replace
erase "AKM_earnings_all.gph" 
erase "AKM_hours_all.gph" 
erase "AKM_wage_all.gph" 

