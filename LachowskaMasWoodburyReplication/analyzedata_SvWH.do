clear all 
use claims_separation.dta, clear

keep if yyyyq>=20081 & yyyyq<=20104
keep ssn  yyyyq empid1 id_change3 spinoff3 merger3
rename empid1 firmid 
saveold "claims_separation2.dta", replace

use dislocated5.dta, clear
set more off, permanently 
keep ssn tenure1
keep if  tenure1>=12
bys ssn: gen n = _n
keep if n==1
keep ssn
merge 1:m ssn using dislocated5.dta
keep if _merge==3
tab1 yyyyq
drop _merge
merge 1:1 ssn yyyyq firmid using "claims_separation2.dta"  
drop if _merge==2
drop _merge
erase "claims_separation2.dta"  

gen id_change = .
replace id_change  =  1 if id_change3 == 1 & dislocated == 1  & yyyyq == yyyyq_separation
tab id_change

gen merger = .
replace merger = 1 if merger3 == 1 & dislocated == 1 & yyyyq == yyyyq_separation
tab merger

gen spinoff = .
replace spinoff = 1  if spinoff3 == 1 & dislocated == 1 & yyyyq == yyyyq_separation 
tab spinoff

gen not_mass_layoff =. 
replace not_mass_layoff = 1 if id_change == 1 | merger == 1 | spinoff == 1
bysort ssn: egen max = max(not_mass_layoff) 
replace not_mass_layoff = max 
drop max
gen real_mass_layoff = 1 if dislocated == 1 & not_mass_layoff==.
drop if dislocated==1 & real_mass_layoff==. 

destring ssn, replace
destring firmid, replace

gen flag_jls = (dislocated==0 & flag_nondis==1) | (dislocated==1 & flag_nondis==0) 
label var flag_jls "JLS sample cut (control group never displaced)"

// Top-code quarterly hours at 2000
recode prim_hours (nonm = 2000) if prim_hours > 2000

// Winsorize positive earnings 
centile prim_earnings if prim_earnings>0 , centile(99) 
recode prim_earnings (nonm = `r(c_1)') if prim_earnings > `r(c_1)'

// Re-generate wages for new wisorized earnings and top-coded hours
replace prim_wage = prim_earnings/prim_hours
recode prim_wage (nonm = 150) if prim_wage > 150

// Get log transformations
gen log_prim_earnings = log(prim_earnings)
gen log_prim_hours = log(prim_hours)
gen log_prim_wage = log(prim_wage)

// Generate a within-person constant flag for mass layoff/separation 
sort ssn yyyyq
bysort ssn: egen max = max(mass_layoff2) 
replace mass_layoff2 = max 
drop max
sort ssn yyyyq
bysort ssn: egen max = max(separation) 
replace separation = max 
drop max

gen stringvar = string(yyyyq)
gen timey = substr(stringvar,1,4)
gen timeq= substr(stringvar,5,5)
destring timey, replace
destring timeq, replace
label var timey "Calendar year"
label var timeq "Quarter in a year"

gen mytime = yq(timey, timeq)
label var mytime "Time in quarters since 1960q1"

sort ssn yyyyq
gen yyyyq_mass_layoff3 = .
bysort ssn: egen max = max(yyyyq_mass_layoff2) 
replace yyyyq_mass_layoff3 = max 
replace yyyyq_mass_layoff2 = yyyyq_mass_layoff3 
drop max yyyyq_mass_layoff3

drop stringvar
gen stringvar = string(yyyyq_mass_layoff2)
gen yyyy_mass_layoff2 = substr(stringvar,1,4)
destring yyyy_mass_layoff2, replace
label var yyyy_mass_layoff2 "Year of mass layoff"

sort ssn yyyyq
gen yyyyq_separation2 = .
bysort ssn: egen min = min(yyyyq_separation) 
replace yyyyq_separation2 = min 
replace yyyyq_separation = yyyyq_separation2 
drop min yyyyq_separation2

drop stringvar
gen stringvar = string(yyyyq_separation)
gen yyyy_separation = substr(stringvar,1,4)
destring yyyy_separation, replace
label var yyyy_separation "Year of separation"

// Average logwage in the pre-displacement period 2006
bysort ssn: egen mean_logwage06 = mean(log_prim_wage) if yyyyq>=20061 & yyyyq<=20064
bysort ssn: egen max = max(mean_logwage06) 
replace mean_logwage06 = max 
drop max
label var mean_logwage06 "Mean log wage in 2006" 

// Average logwage in the pre-displacement period 2007
bysort ssn: egen mean_logwage07 = mean(log_prim_wage) if yyyyq>=20071 & yyyyq<=20074
bysort ssn: egen max = max(mean_logwage07) 
replace mean_logwage07 = max 
drop max
label var mean_logwage07 "Mean log wage in 2007" 

// Average hours in the pre-displacement period 2006
bysort ssn: egen mean_hours06 = mean(prim_hours) if yyyyq>=20061 & yyyyq<=20064
bysort ssn: egen max = max(mean_hours06) 
replace mean_hours06 = max 
drop max
label var mean_hours06 "Mean hours in 2006" 

// Firm size in 2007Q4
gen pre_firmsize = . 
replace pre_firmsize = firmsize if yyyyq==20074
bysort ssn: egen max = max(pre_firmsize) 
replace pre_firmsize = max 
drop max
label var pre_firmsize "Firm size (number of employees) in 2007Q4"

// Pre-displacement 1-digit industry
destring naics, replace
gen naics1 = floor(naics/100000)
gen pre_industry = 0
replace pre_industry = naics1 if yyyyq==20074
bysort ssn: egen max = max(pre_industry) 
replace pre_industry = max 
drop max
label var pre_industry "1-digit industry in 2007Q4"

// Pre-displacement 2-digit industry 
destring naics, replace
gen naics2 = floor(naics/10000)
gen pre_industry2 = 0
replace pre_industry2 = naics2 if yyyyq==20074
bysort ssn: egen max = max(pre_industry2) 
replace pre_industry2 = max 
drop max
label var pre_industry2 "2-digit industry in 2007Q4"

// Create age at the time of mass layoff/separation
gen age_at_disp = . 
replace age_at_disp = age if yyyyq == yyyyq_separation & dislocated == 1
replace age_at_disp = age if yyyyq == 20074 & dislocated == 0
bysort ssn: egen max = max(age_at_disp) 
replace age_at_disp = max 
drop max
label var age_at_disp "Age at displacement or age in 2007Q4"

generate demo = (!missing(age) & !missing(female) & !missing(race1) & !missing(educ1) & age_at_disp>=20 & age_at_disp<=50)
label variable demo "Demographic info on age, gender, race, and education, with age restrictions imposed" 

gen separation0810 = (yyyy_separation==2008|yyyy_separation==2009|yyyy_separation==2010|missing(yyyy_separation))
label variable separation0810 "Separation occured in 2008–10 or is missing"

// Drop separators who were not in a mass layoff 
drop if mass_layoff2==0 & separation==1

/// Drop separators who separated in 20074
drop if yyyyq_separation == 20074

gen dis_dummies = .
replace dis_dummies =  qtrs_since_separation + 21 if dislocated == 1
recode dis_dummies (-3 = 0) (-2 = 0) (-1 = 0) if dislocated == 1 
replace dis_dummies = 0 if dislocated == 0
tab dis_dummies
label var dis_dummies "Displacement dummies" 

keep if dis_dummies >=0 & dis_dummies<=41
# delimit ;
label define sep_quarters
0 "-(24-21)" 1 "-20" 2 "-19" 3 "-18" 4 "-17"  5 "-16" 6 "-15" 7 "-14" 8 "-13" 9 "-12" 
10 "-11"  11 "-10" 12 "-9" 13 "-8" 14 "-7" 15 "-6" 16 "-5"  17 "-4" 18 "-3" 19 "-2" 20 "-1" 21 "0" 22 "1"  23 "2"  24 "3"
25 "4" 26 "5" 27 "6" 28 "7" 29 "8"  30 "9" 31 "10" 32 "11" 33 "12" 34 "13" 
35 "14"  36 "15" 37 "16" 38 "17" 39 "18" 40 "19" 41 "20" 42 "21" 43 "22" 44 "23" 45 "24"  ;
# delimit cr
label value dis_dummies sep_quarters
compress


// Set up the panel 
xtset ssn mytime
saveold "my_dislocated_SvWH.dta", replace

// SvWH sample definition uses not displaced, rather than never displaced as the control group
use "my_dislocated_SvWH.dta", clear

gen flag_SvWH 		= (separation0810==1 & demo==1 & age_at_disp>=24 & age_at_disp<=50 & male==1)
keep if flag_SvWH==1

// Drop if public admin
drop if pre_industry == 9

// Drop if mining
drop if pre_industry2 == 21

// Keep if pre-disp. average hours/quarter are fulltime 
keep if mean_hours06 > 500 

recode dis_dummies (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (8=0) (9=0) (10=0) (11=0) (12=0) if  dislocated==1

// Tenure in the pre-displacement period
gen tenure = .
bysort ssn: egen max = max(tenure1) 
replace tenure = max 
drop max
label var tenure "Tenure before 2007" 
keep if tenure >= 12

// Merge in AKM FEs 
merge m:1 firmid using "dw_akm_2002_2014.dta", keepusing(logwage_fe loghours_fe logearnings_fe) gen(_merge_akm)
drop if _merge_akm==2

// Keep people with wages in 2006 and 2007 
drop if missing(mean_logwage07)
drop if missing(mean_logwage06)

// Match on pre-displacment chars within each 1-digit pre-displacement industry
set matsize 10000
logit dislocated (i.pre_industry)#(c.pre_firmsize c.mean_logwage07 c.mean_logwage06 c.tenure c.age_at_disp educ*) if yyyyq==20064 
predict my_pscore

// PSM: closest worker, no replacement
psmatch2 dislocated, outcome(log_prim_wage log_prim_earnings log_prim_hours logwage_fe loghours_fe logearnings_fe) pscore(my_pscore) noreplacement  

// Creates a set for each 1:1 matched pair 
gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
keep if paircount==2
tab dislocated

// Analysis
local coeflabel /// 
2.dis_dummies = " "  3.dis_dummies = " "  4.dis_dummies = " "  6.dis_dummies = " "  7.dis_dummies = " " /// 
8.dis_dummies = " "  10.dis_dummies = " " 11.dis_dummies = " " 12.dis_dummies = " " 14.dis_dummies = " " /// 
15.dis_dummies = " " 16.dis_dummies = " " 18.dis_dummies = " " 19.dis_dummies = " " 20.dis_dummies = " " /// 
22.dis_dummies = " " 23.dis_dummies = " " 24.dis_dummies = " " 26.dis_dummies = " " 27.dis_dummies = " " /// 
28.dis_dummies = " " 30.dis_dummies = " " 31.dis_dummies = " " 32.dis_dummies = " " 34.dis_dummies = " " ///
35.dis_dummies = " " 36.dis_dummies = " " 38.dis_dummies = " " 39.dis_dummies = " " 40.dis_dummies = " " /// 
42.dis_dummies = " " 43.dis_dummies = " " 44.dis_dummies = " " 

// Wage
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg log_prim_wage i.yyyyq age educ* i.dis_dummies , fe
est store log_prim_wage_psm
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
outreg2 using SvWH_analysis.xls, excel label bdec(3) sdec(3)  ctitle(logwage) keep(i.dis_dummies) addstat(First qtr, `combination2', Last four qtrs, `combination1') replace
xtreg logwage_fe i.yyyyq age educ* i.dis_dummies , fe
est store logwage_fe_psm
coefplot log_prim_wage_psm logwage_fe_psm ,  keep(*.dis_dummies*) recast(connected) xline(9) yline(0)  xtitle("Year relative to displacement") ytitle("log point") title("Log hourly wage rate") vertical coeflabel(`coeflabel')
graph save Graph "Log_wage_PSM.gph", replace

// Earnings
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg log_prim_earnings i.yyyyq age educ* i.dis_dummies , fe
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_prim_earnings_psm 
outreg2 using SvWH_analysis.xls, excel label bdec(3) sdec(3)  ctitle(logearnings) keep(i.dis_dummies)  addstat(First qtr, `combination2', Last four qtrs, `combination1')
xtreg logearnings_fe i.yyyyq age educ* i.dis_dummies , fe
est store logearnings_fe_psm
coefplot log_prim_earnings_psm logearnings_fe_psm ,  keep(*.dis_dummies*) recast(connected) xline(9) yline(0)  xtitle("Year relative to displacement") ytitle("log point") title("Log quarterly earnings") vertical coeflabel(`coeflabel')
graph save Graph "Log_earnings_PSM.gph", replace

// Hours
set more off, permanently 
char dis_dummies[omit] 0 
char yyyyq[omit] 20044
xtreg log_prim_hours i.yyyyq age educ* i.dis_dummies , fe
local combination1 = (_b[41.dis_dummies]+_b[40.dis_dummies]+_b[39.dis_dummies]+_b[38.dis_dummies])/4 
local combination2 = _b[22.dis_dummies] 
est store log_prim_hours_psm 
outreg2 using SvWH_analysis.xls, excel label bdec(3) sdec(3)  ctitle(loghours) keep(i.dis_dummies)  addstat(First qtr, `combination2', Last four qtrs, `combination1')
xtreg loghours_fe i.yyyyq age educ* i.dis_dummies , fe
est store loghours_fe_psm
coefplot log_prim_hours_psm loghours_fe_psm ,  keep(*.dis_dummies*) recast(connected) xline(9) yline(0)  xtitle("Year relative to displacement") ytitle("log point") title("Log quarterly work hours") vertical coeflabel(`coeflabel')
graph save Graph "Log_hours_PSM.gph", replace


******************************
/// Appendix Figure A8-1  ///
******************************

grc1leg "Log_earnings_PSM.gph" "Log_hours_PSM.gph" "Log_wage_PSM.gph" 
graph save Graph "FigureA8_1.gph" , replace

erase "Log_earnings_PSM.gph" 
erase "Log_hours_PSM.gph"
erase "Log_wage_PSM.gph" 
