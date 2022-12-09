set more off, permanently 

use "my_dislocated_short.dta", clear
gen short_tenure = 1 
gen tenure = .
bysort ssn: egen max = max(tenure1) 
replace tenure = max 
drop max
label var tenure "Tenure before 2007" 
destring firmid_2007, replace


// Keep if tenure is 3-4 years 
keep if tenure>=12 & tenure<=16
summarize tenure 
keep if flag_main==1
keep if dislocated==1


// Append the 6+ years of tenure analysis sample to the short-tenure sample
append using "my_dislocated.dta"
keep if flag_main==1
recode short_tenure (. = 0)
tab short_tenure


// Add tenure values for the 6+ years sample:
recode tenure (.=24) if short_tenure==0



// Drop pre-displacment outcomes with employers other than the employer you were displaced from, 
// For non-displaced workers, drop outcomes observed earlier than their tenure with 2007 employer
gen tenure_negative = -tenure1 

tostring yyyyq, generate(yyyyq_2) force 
gen str yyyyq_str = substr(yyyyq_2,1,4) 
destring yyyyq_str, gen(year)
drop yyyyq_2  yyyyq_str

tostring yyyyq, generate(yyyyq_2) force 
gen str yyyyq_str = substr(yyyyq_2,-1,.) 
destring yyyyq_str, gen(quarter)
drop yyyyq_2 yyyyq_str

gen qdate =  yq(year, quarter) 
format qdate %tq

gen year_2007 = 2007
gen qtr_4 = 4
gen qdate_2007 =  yq(year_2007, qtr_4) 
format qdate_2007 %tq
gen qtrs_since_2007 = qdate-qdate_2007


sort ssn yyyyq
recode prim_earnings (nonm = .) if (short_tenure==1 & dislocated==1) & (qtrs_since_separation < tenure_negative & qtrs_since_separation<0)
recode prim_earnings (nonm = .) if (short_tenure==1 & dislocated==0) & (qtrs_since_2007 < tenure_negative & qtrs_since_2007<0)

recode prim_hours (nonm = .) if (short_tenure==1 & dislocated==1) & (qtrs_since_separation < tenure_negative & qtrs_since_separation<0)
recode prim_hours (nonm = .) if (short_tenure==1 & dislocated==0) & (qtrs_since_2007 < tenure_negative & qtrs_since_2007<0)

recode prim_wage (nonm = .) if (short_tenure==1 & dislocated==1) & (qtrs_since_separation < tenure_negative & qtrs_since_separation<0)
recode prim_wage (nonm = .) if (short_tenure==1 & dislocated==0) & (qtrs_since_2007 < tenure_negative & qtrs_since_2007<0)

replace log_prim_earnings = log(prim_earnings)
replace log_prim_hours = log(prim_hours)
replace log_prim_wage = log(prim_wage)
replace prim_emp = (prim_earnings > 0|prim_hours > 0) if short_tenure==1 & dislocated==1


// Replace displacment dummies of workers if they are observed before their 2007 employer with missing values
recode dis_dummies (nonm = .) if missing(prim_earnings) & short_tenure==1 & dislocated==1
recode dislocated (nonm = .) if missing(prim_earnings) & short_tenure==1 & dislocated==1

recode dis_dummies (nonm = .) if missing(prim_earnings) & short_tenure==1 & dislocated==0
recode dislocated (nonm = .) if missing(prim_earnings) & short_tenure==1 & dislocated==0

// Make any outcomes observed before year -2 the omitted category
recode dis_dummies (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (8=0) (9=0) (10=0) (11=0) (12=0) if short_tenure==1 & dislocated==1


/// Firm ID in 2007Q4
drop firmid_2007
gen firmid_2007=.
replace firmid_2007 = firmid if yyyyq==20074
bysort ssn: egen max = max(firmid_2007) 
replace firmid_2007 = max 
drop max
label var firmid_2007 "Firm ID in 2007Q4"


*********************************
/// Short tenure sample analysis
*********************************

keep if dis_dummies <= 41	/* include only through year 5 */
set matsize 10000

local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry ) c.age##(c.age i.female i.race* i.educ*) 
local coeflabel /// 
2.dis_dummies = " "  3.dis_dummies = " "  4.dis_dummies = " "  6.dis_dummies = " "  7.dis_dummies = " " /// 
8.dis_dummies = " "  10.dis_dummies = " " 11.dis_dummies = " " 12.dis_dummies = " " 14.dis_dummies = " " /// 
15.dis_dummies = " " 16.dis_dummies = " " 18.dis_dummies = " " 19.dis_dummies = " " 20.dis_dummies = " " /// 
22.dis_dummies = " " 23.dis_dummies = " " 24.dis_dummies = " " 26.dis_dummies = " " 27.dis_dummies = " " /// 
28.dis_dummies = " " 30.dis_dummies = " " 31.dis_dummies = " " 32.dis_dummies = " " 


// Earnings
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg log_prim_earnings `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0, fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using short_analysis.xls, excel label bdec(3) sdec(3)  ctitle(prim_earnings) keep(i.dis_dummies)   addstat(First qtr, `combination2', Last four qtrs, `combination1') replace
est store log_prim_earnings_short


// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg log_prim_hours `my_controls'  i.dis_dummies if  short_tenure==1|dislocated==0 , fe cluster(ssn)
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using short_analysis.xls, excel label bdec(3) sdec(3)  ctitle(prim_hours) keep(i.dis_dummies)   addstat(First qtr, `combination2', Last four qtrs, `combination1') 
est store log_prim_hours_short


// Wage rates 
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg log_prim_wage `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0 , fe cluster(ssn) 
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using short_analysis.xls, excel label bdec(3) sdec(3)  ctitle(prim_wage) keep(i.dis_dummies)   addstat(First qtr, `combination2', Last four qtrs, `combination1') 
est store log_prim_wage_short


// Wage rates 
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg prim_wage `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0 , fe cluster(ssn)
est store prim_wage_short


// Employed 
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg prim_emp `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0 , fe cluster(ssn)
est store prim_emp_short




****************************
/// Full sample analysis
****************************

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
xtreg log_prim_earnings `my_controls'  i.dis_dummies if short_tenure==0 , fe cluster(ssn)
est store log_prim_earnings

// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_hours `my_controls'  i.dis_dummies if short_tenure==0 , fe cluster(ssn)
est store log_prim_hours

// Wage rates (logs)
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg log_prim_wage `my_controls'  i.dis_dummies if short_tenure==0 , fe cluster(ssn)
est store log_prim_wage

// Wage rates (levels)
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_wage `my_controls'  i.dis_dummies if short_tenure==0 , fe cluster(ssn)
est store prim_wage


// Employed
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
xtreg prim_emp `my_controls'  i.dis_dummies if short_tenure==0 , fe cluster(ssn)
est store prim_emp

coefplot prim_emp prim_emp_short ,  keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("Fraction employed") title("Quarterly employment probability") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Emp_tenure_combined.gph", replace

coefplot log_prim_wage log_prim_wage_short ,  keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate")  vertical coeflabel(`coeflabel')
graph save Graph "Prim_Wage_Log_tenure_combined.gph", replace

coefplot log_prim_hours log_prim_hours_short ,  keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Hours_Log_tenure_combined.gph", replace

coefplot log_prim_earnings log_prim_earnings_short ,  keep(*.dis_dummies*) recast(connected) xline(21) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings") vertical coeflabel(`coeflabel')
graph save Graph "Prim_Earnings_Log_tenure_combined.gph", replace


********************
/// Figure A1-1 ///
********************

grc1leg "Prim_Earnings_Log_tenure_combined.gph" "Prim_Hours_Log_tenure_combined.gph" "Prim_Wage_Log_tenure_combined.gph" "Prim_Emp_tenure_combined.gph"
graph save Graph "FigureA1_1.gph" , replace

erase "Prim_Emp_tenure_combined.gph"
erase "Prim_Wage_Log_tenure_combined.gph"
erase "Prim_Hours_Log_tenure_combined.gph" 
erase "Prim_Earnings_Log_tenure_combined.gph"

saveold "my_dislocated_short_tenure.dta", replace

