
set more off, permanently

use "my_dislocated_short_tenure.dta", clear
sort firmid
xtset ssn mytime
merge m:1 (firmid) using "dw_akm_2002_2014.dta", generate(_merge_akm_2002_2014) 
drop  if  _merge_akm_2002_2014 ==2  
keep if flag_main == 1
keep if dis_dummies <= 41	
set matsize 10000
xtset ssn mytime
save "my_dislocated_akm_short.dta", replace

use "my_dislocated_akm_short.dta", clear

local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) c.age##(c.age i.race* i.educ*) 
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
qui xtreg log_prim_earnings `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0  , fe cluster(ssn)
est store log_prim_earnings_short
qui xtreg logearnings_fe `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0  , fe cluster(ssn)
est store logearnings_fe_short
coefplot logearnings_fe_short log_prim_earnings_short , keep(*.dis_dummies*) recast(connected) xline(9) yline(0) xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings") vertical coeflabel(`coeflabel')
graph save Graph "AKM_Earnings_short.gph", replace

// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
qui xtreg log_prim_hours `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0, fe 
est store log_prim_hours_short
qui xtreg loghours_fe `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0 , fe 
est store loghours_fe_short
coefplot loghours_fe_short log_prim_hours_short, keep(*.dis_dummies*) recast(connected) xline(9) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "AKM_Hours_short.gph", replace


// Wage rates
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021 
qui xtreg log_prim_wage `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0, fe 
est store log_prim_wage_short
outreg2 using akm_me_short_analysis.xls, excel label bdec(4) sdec(4) keep(i.dis_dummies) ctitle(log_wage) noaster replace
qui xtreg logwage_fe `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0 , fe 
est store logwage_fe_short
outreg2 using akm_me_short_analysis.xls, excel label bdec(4) sdec(4) keep(i.dis_dummies) ctitle(log_wage_fe) noaster 
coefplot logwage_fe_short log_prim_wage_short, keep(*.dis_dummies*) recast(connected) xline(9) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "AKM_Wage_short.gph", replace


grc1leg "AKM_Earnings_short.gph" "AKM_Hours_short.gph" "AKM_Wage_short.gph" ,  cols(2) 
graph save Graph "AKM_short.gph", replace
erase "AKM_Earnings_short.gph" 
erase "AKM_Hours_short.gph" 
erase "AKM_Wage_short.gph"
erase "AKM_short.gph" 

*****************************
******* QQ analysis *********
*****************************


use "my_dislocated_akm_short.dta", clear
merge m:m ssn firmid using "post_match_data_2002_2014.dta" , keepusing(logearnings_met loghours_met logwage_met) 
keep if  short_tenure==1|dislocated==0

**** Add Match Effects to Displacment Figures

local my_controls i.yyyyq i.timey#c.(mean_hours mean_earnings pre_logfirmsize i.pre_industry) c.age##(c.age i.race* i.educ*) 

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
qui xtreg logearnings_me `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0 , fe cluster(ssn)
est store logearnings_me_short
coefplot logearnings_me_short logearnings_fe_short log_prim_earnings_short , keep(*.dis_dummies*) recast(connected) xline(9) yline(0) xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly earnings") vertical coeflabel(`coeflabel')
graph save Graph "AKM_Earnings_short_ME.gph", replace


// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021
qui xtreg loghours_me `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0, fe 
est store loghours_me_short
coefplot loghours_me_short loghours_fe_short log_prim_hours_short, keep(*.dis_dummies*) recast(connected) xline(9) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "AKM_Hours_short_ME.gph", replace


// Wage rates
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20021 
qui xtreg logwage_me `my_controls'  i.dis_dummies if short_tenure==1|dislocated==0, fe 
est store logwage_me_short
outreg2 using akm_me_short_analysis.xls, excel label bdec(4) sdec(4) keep(i.dis_dummies) ctitle(log_wage_me) noaster 
coefplot logwage_me_short logwage_fe_short log_prim_wage_short, keep(*.dis_dummies*) recast(connected) xline(9) yline(0)  xtitle("Year relative to displacement") ytitle("log points") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "AKM_Wage_short_ME.gph", replace


*******************
/// Figure A1-2  ///
*******************
grc1leg "AKM_Earnings_short_ME.gph" "AKM_Hours_short_ME.gph" "AKM_Wage_short_ME.gph" ,  cols(2) 
graph save Graph "FigureA1_2.gph", replace
erase "AKM_Earnings_short_ME.gph" 
erase "AKM_Hours_short_ME.gph" 
erase "AKM_Wage_short_ME.gph" 

****************************************************************************
/// Data underlying the remaining tables/figures of Appendix A.1  ///
****************************************************************************


* Keep only the short-tenure guys 
keep if short_tenure==1

// AKM Qtiles in 2007Q4
capture drop akm_earnings_xtile
gen akm_earnings_xtile = . 
replace akm_earnings_xtile = logearningsfe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_earnings_xtile) 
replace akm_earnings_xtile = max 
drop max
label var akm_earnings_xtile "AKM earnings effect xtile in 2007Q4"

capture drop akm_hours_xtile
gen akm_hours_xtile = . 
replace akm_hours_xtile = loghoursfe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_hours_xtile) 
replace akm_hours_xtile = max 
drop max
label var akm_hours_xtile "AKM hours effect xtile in 2007Q4"

capture drop akm_wage_xtile
gen akm_wage_xtile = . 
replace akm_wage_xtile = logwagefe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_wage_xtile) 
replace akm_wage_xtile = max 
drop max
label var akm_wage_xtile "AKM wage effect xtile in 2007Q4"






******** Pre-displacement earnings, hours, wages ***********

// Average logearnings in the pre-displacement period for DW 
bysort ssn: egen pre_logearnings = mean(log_prim_earnings) if yyyyq<20071 
bysort ssn: egen max = max(pre_logearnings) 
replace pre_logearnings = max 
drop max
label var pre_logearnings "Mean log earnings before 2006" 

// Average loghours in the pre-displacement period for DW 
bysort ssn: egen pre_loghours = mean(log_prim_hours) if yyyyq<20071  
bysort ssn: egen max = max(pre_loghours) 
replace pre_loghours = max 
drop max
label var pre_loghours "Mean log hours worked before 2006" 

// Average logwage in the pre-displacement period for DW 
bysort ssn: egen pre_logwage = mean(log_prim_wage) if yyyyq<20071  
bysort ssn: egen max = max(pre_logwage)  
replace pre_logwage = max  
drop max
label var pre_logwage "Mean log wage before 2006"


******** Pre-displacement match effects for earnings, hours, wages ***********

// Pre-displacement 2007:4 ME earnings FE for all
bysort ssn: egen pre_logearnings_me = mean(logearnings_met) if yyyyq==20074 
bysort ssn: egen max = max(pre_logearnings_me)  
replace pre_logearnings_me = max  
drop max
label var pre_logearnings_me "2007:4 ME earnings FE"

// Pre-displacement 2007:4 AKM hours FE for all
bysort ssn: egen pre_loghours_me = mean(loghours_met) if yyyyq==20074 
bysort ssn: egen max = max(pre_loghours_me)  
replace pre_loghours_me = max  
drop max
label var pre_loghours_me "2007:4 AKM hours ME"

// Pre-displacement 2007:4 AKM wage FE for all
bysort ssn: egen pre_logwage_me = mean(logwage_met) if yyyyq==20074 
bysort ssn: egen max = max(pre_logwage_me)  
replace pre_logwage_me = max  
drop max
label var pre_logwage_me "2007:4 AKM wage ME"

******** Pre-displacement AKM firm effects for earnings, hours, wages ***********

// Pre-displacement 2007:4 AKM earnings FE for all
bysort ssn: egen pre_logearnings_fe = mean(logearnings_fe) if yyyyq==20074 
bysort ssn: egen max = max(pre_logearnings_fe)  
replace pre_logearnings_fe = max  
drop max
label var pre_logearnings_fe "2007:4 AKM earnings FE"

// Pre-displacement 2007:4 AKM hours FE for all
bysort ssn: egen pre_loghours_fe = mean(loghours_fe) if yyyyq==20074 
bysort ssn: egen max = max(pre_loghours_fe)  
replace pre_loghours_fe = max  
drop max
label var pre_loghours_fe "2007:4 AKM hours FE"

// Pre-displacement 2007:4 AKM wage FE for all
bysort ssn: egen pre_logwage_fe = mean(logwage_fe) if yyyyq==20074 
bysort ssn: egen max = max(pre_logwage_fe)  
replace pre_logwage_fe = max  
drop max
label var pre_logwage_fe "2007:4 AKM wage FE"



**** Pre-displacement quintiles of AKM log firm FE *********

// Pre-displacement 2007:4 AKM quintile of earnings for DW and controls
bysort ssn: egen pre_logearnings_fe_xtile = mean(akm_earnings_xtile) if yyyyq==20074 
bysort ssn: egen max = max(pre_logearnings_fe_xtile)  
replace pre_logearnings_fe_xtile = max  
drop max
label var pre_logearnings_fe_xtile "2007:4 AKM quintile of earnings"

// Pre-displacement 2007:4 AKM quintile of hours for DW and controls
bysort ssn: egen pre_loghours_fe_xtile = mean(akm_hours_xtile) if yyyyq==20074 
bysort ssn: egen max = max(pre_loghours_fe_xtile)  
replace pre_loghours_fe_xtile = max  
drop max
label var pre_loghours_fe_xtile "2007:4 AKM quintile of hours"

// Pre-displacement 2007:4 AKM quintile of wage for DW and controls
bysort ssn: egen pre_logwage_fe_xtile = mean(akm_wage_xtile) if yyyyq==20074 
bysort ssn: egen max = max(pre_logwage_fe_xtile)  
replace pre_logwage_fe_xtile = max  
drop max
label var pre_logwage_fe_xtile "2007:4 AKM quintile of wages"



******** Post-displacement earnings, hours, wages ***********

// Post-displacement earnings (2 years after displacement) for DW only
gen post_logearnings = . 
replace post_logearnings = log_prim_earnings if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logearnings = log_prim_earnings if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logearnings = log_prim_earnings if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logearnings = log_prim_earnings if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logearnings = log_prim_earnings if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logearnings = log_prim_earnings if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logearnings = log_prim_earnings if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logearnings = log_prim_earnings if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logearnings = log_prim_earnings if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logearnings = log_prim_earnings if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logearnings = log_prim_earnings if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logearnings = log_prim_earnings if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104



// Post-displacement hours  (2 years after displacement) for DW only
gen post_loghours = . 
replace post_loghours = log_prim_hours if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_loghours = log_prim_hours if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_loghours = log_prim_hours if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_loghours = log_prim_hours if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_loghours = log_prim_hours if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_loghours = log_prim_hours if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_loghours = log_prim_hours if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_loghours = log_prim_hours if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_loghours = log_prim_hours if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_loghours = log_prim_hours if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_loghours = log_prim_hours if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_loghours = log_prim_hours if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104



// Post-displacement wages  (2 years after displacement) for DW only
gen post_logwage = . 
replace post_logwage = log_prim_wage if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logwage = log_prim_wage if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logwage = log_prim_wage if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logwage = log_prim_wage if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logwage = log_prim_wage if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logwage = log_prim_wage if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logwage = log_prim_wage if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logwage = log_prim_wage if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logwage = log_prim_wage if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logwage = log_prim_wage if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logwage = log_prim_wage if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logwage = log_prim_wage if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104



**** Post-displacement firm effects log earnings, hours, and wages  *********

// Post-displacement AKM FE for earnings  (2 years after displacement) for DW only
gen post_logearnings_fe = . 
replace post_logearnings_fe = logearnings_fe if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logearnings_fe = logearnings_fe if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logearnings_fe = logearnings_fe if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logearnings_fe = logearnings_fe if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logearnings_fe = logearnings_fe if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logearnings_fe = logearnings_fe if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logearnings_fe = logearnings_fe if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logearnings_fe = logearnings_fe if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logearnings_fe = logearnings_fe if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logearnings_fe = logearnings_fe if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logearnings_fe = logearnings_fe if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logearnings_fe = logearnings_fe if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104




// Post-displacement AKM FE for wages  (2 years after displacement) for DW only
gen post_logwage_fe = . 
replace post_logwage_fe = logwage_fe if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logwage_fe = logwage_fe if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logwage_fe = logwage_fe if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logwage_fe = logwage_fe if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logwage_fe = logwage_fe if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logwage_fe = logwage_fe if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logwage_fe = logwage_fe if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logwage_fe = logwage_fe if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logwage_fe = logwage_fe if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logwage_fe = logwage_fe if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logwage_fe = logwage_fe if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logwage_fe = logwage_fe if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104




// Post-displacement AKM FE for hours  (2 years after displacement) for DW only
gen post_loghours_fe = . 
replace post_loghours_fe = loghours_fe if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_loghours_fe = loghours_fe if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_loghours_fe = loghours_fe if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_loghours_fe = loghours_fe if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_loghours_fe = loghours_fe if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_loghours_fe = loghours_fe if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_loghours_fe = loghours_fe if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_loghours_fe = loghours_fe if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_loghours_fe = loghours_fe if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_loghours_fe = loghours_fe if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_loghours_fe = loghours_fe if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_loghours_fe = loghours_fe if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104




**** Post-displacement match effects log earnings, hours, and wages  *********

// Post-displacement MATCH effects for earnings  (2 years after displacement) for DW only
gen post_logearnings_me = . 
replace post_logearnings_me = logearnings_met if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logearnings_me = logearnings_met if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logearnings_me = logearnings_met if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logearnings_me = logearnings_met if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logearnings_me = logearnings_met if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logearnings_me = logearnings_met if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logearnings_me = logearnings_met if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logearnings_me = logearnings_met if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logearnings_me = logearnings_met if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logearnings_me = logearnings_met if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logearnings_me = logearnings_met if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logearnings_me = logearnings_met if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104



// Post-displacement MATCH FE for wages  (2 years after displacement) for DW only
gen post_logwage_me = . 
replace post_logwage_me = logwage_met if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logwage_me = logwage_met if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logwage_me = logwage_met if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logwage_me = logwage_met if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logwage_me = logwage_met if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logwage_me = logwage_met if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logwage_me = logwage_met if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logwage_me = logwage_met if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logwage_me = logwage_met if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logwage_me = logwage_met if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logwage_me = logwage_met if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logwage_me = logwage_met if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104




// Post-displacement MATCH FE for hours  (2 years after displacement) for DW only
gen post_loghours_me = . 
replace post_loghours_me = loghours_met if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_loghours_me = loghours_met if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_loghours_me = loghours_met if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_loghours_me = loghours_met if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_loghours_me = loghours_met if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_loghours_me = loghours_met if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_loghours_me = loghours_met if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_loghours_me = loghours_met if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_loghours_me = loghours_met if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_loghours_me = loghours_met if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_loghours_me = loghours_met if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_loghours_me = loghours_met if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104







**** Post-displacement quintiles of AKM log firm FE *********
//// Earnings
//// Post-displacement quintiles (2 years after displacement) for displaced only 
gen post_logearnings_fe_xtile = .
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logearnings_fe_xtile = logearningsfe_xtile if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104

label var post_logearnings_fe_xtile "Post-displacement AKM quintile of earnings"



//// Hours
//// Post-displacement quintiles (2 years after displacement) for displaced only 
gen post_loghours_fe_xtile = .
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_loghours_fe_xtile = loghoursfe_xtile if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104

label var post_loghours_fe_xtile "Post-displacement AKM quintile of earnings"




//// Wage
//// Post-displacement quintiles (2 years after displacement) for displaced only 
gen post_logwage_fe_xtile = .
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_logwage_fe_xtile = logwagefe_xtile if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104

label var post_logwage_fe_xtile "Post-displacement AKM quintile of wage"

save "my_dislocated_akm_event_short.dta", replace

**** Results *********
use "my_dislocated_akm_event_short.dta", clear
keep if dislocated==1
keep if !missing(pre_logwage)
keep if !missing(post_logwage)
keep if !missing(post_logwage_fe_xtile )
collapse (mean)  pre_logwage  post_logwage  pre_logwage_fe  post_logwage_fe pre_logwage_me  post_logwage_me  (count) preN = pre_logwage  Nobs = post_logwage ///
		, by(pre_logwage_fe_xtile post_logwage_fe_xtile  )
		gen delta = post_logwage-pre_logwage
		gen delta_fe = post_logwage_fe-pre_logwage_fe
		gen delta_me = post_logwage_me-pre_logwage_me
keep pre_logwage_fe_xtile post_logwage_fe_xtile Nobs delta delta_fe delta_me 
order pre_logwage_fe_xtile post_logwage_fe_xtile Nobs delta  delta_fe delta_me 
export excel using "DW_Short_Raw.xlsx", firstrow(variables) sheet("DW_logw_fe_me", replace) 

use "my_dislocated_akm_event_short.dta", clear
keep if dislocated==1
keep if !missing(pre_loghours)
keep if !missing(post_loghours)
keep if !missing(post_loghours_fe_xtile)
collapse (mean)  pre_loghours  post_loghours pre_loghours_fe  post_loghours_fe pre_loghours_me  post_loghours_me (count) preN = pre_loghours  Nobs = post_loghours ///
		, by(pre_loghours_fe_xtile post_loghours_fe_xtile  )
		gen delta = post_loghours-pre_loghours
		gen delta_fe = post_loghours_fe-pre_loghours_fe
		gen delta_me = post_loghours_me-pre_loghours_me
keep pre_loghours_fe_xtile post_loghours_fe_xtile Nobs delta   delta_fe delta_me 
order pre_loghours_fe_xtile post_loghours_fe_xtile Nobs delta   delta_fe delta_me 
export excel using "DW_Short_Raw.xlsx", firstrow(variables) sheet("DW_logh_fe_me", replace) 

use "my_dislocated_akm_event_short.dta", clear
keep if dislocated==1
keep if !missing(pre_logearnings)
keep if !missing(post_logearnings)
keep if !missing(post_logearnings_fe_xtile)
collapse (mean)  pre_logearnings  post_logearnings pre_logearnings_fe  post_logearnings_fe pre_logearnings_me  post_logearnings_me (count) preN = pre_logearnings  Nobs = post_logearnings ///
		, by(pre_logearnings_fe_xtile post_logearnings_fe_xtile  )
		gen delta = post_logearnings-pre_logearnings
		gen delta_fe = post_logearnings_fe-pre_logearnings_fe
		gen delta_me = post_logearnings_me-pre_logearnings_me
keep pre_logearnings_fe_xtile post_logearnings_fe_xtile  Nobs delta     delta_fe   delta_me 
order pre_logearnings_fe_xtile post_logearnings_fe_xtile  Nobs delta     delta_fe   delta_me 
export excel using "DW_Short_Raw.xlsx", firstrow(variables) sheet("DW_loge_fe_me", replace) 


// Clean up 
erase "my_dislocated_akm_event_short.dta"



