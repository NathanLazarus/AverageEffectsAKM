clear all
use claims_separation.dta, clear

keep if yyyyq>=20081 & yyyyq<=20104
keep ssn  yyyyq empid1 id_change3 spinoff3 merger3
rename empid1 firmid 

merge 1:1 ssn yyyyq firmid using dislocated4.dta
drop if _merge==1
drop _merge

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

// Merge in UI claim information 
merge 1:1 ssn yyyyq using dislocated4_merger_acquisition.dta, keepusing(ui_relative_to_sep)
drop _merge
gen real_mass_layoff = 1 if dislocated == 1 & not_mass_layoff==.
gen ui_4q = 1 if dislocated == 1 & abs(ui_relative_to_sep)<=4 

gen my_flag  = 1 if (dislocated==1 & (real_mass_layoff==. & ui_4q==.))
drop if my_flag == 1
drop my_flag 
drop real_mass_layoff
drop ui_4q

destring ssn, replace
destring firmid, replace

// Flag the JLS sample definition
gen flag_jls = (dislocated==0 & flag_nondis==1) | (dislocated==1 & flag_nondis==0) 
label var flag_jls "JLS sample cut (control group never displaced)"

// Top-code quarterly hours at 2000
recode prim_hours (nonm = 2000) if prim_hours > 2000
recode all_hours (nonm = 2000) if all_hours > 2000

// Winsorize positive earnings 
centile prim_earnings if prim_earnings>0 , centile(99) 
recode prim_earnings (nonm = `r(c_1)') if prim_earnings > `r(c_1)'

centile all_earnings if all_earnings>0 , centile(99) 
recode all_earnings (nonm = `r(c_1)') if all_earnings > `r(c_1)'

replace prim_wage = prim_earnings/prim_hours
gen all_wage = all_earnings/all_hours

recode prim_wage (nonm = 150) if prim_wage > 150
recode all_wage (nonm = 150) if all_wage > 150

// Log transformations
gen log_all_earnings 	= log(all_earnings)
gen log_all_hours 		= log(all_hours)
gen log_prim_earnings 	= log(prim_earnings)
gen log_prim_hours 		= log(prim_hours)
gen log_prim_wage 		= log(prim_wage)
gen log_all_wage 		= log(all_wage)


// Dummy for positive earnings or positive hourss
gen prim_emp = (prim_earnings > 0|prim_hours > 0)
label var prim_emp "Earnings or hours are positive in quarter"


// Replace mass layoff/separation indicator to be constant within person 
sort ssn yyyyq
bysort ssn: egen max = max(mass_layoff2) 
replace mass_layoff2 = max 
drop max
sort ssn yyyyq
bysort ssn: egen max = max(separation) 
replace separation = max 
drop max


// Manage the time variables
gen stringvar = string(yyyyq)
gen timey = substr(stringvar,1,4)
gen timeq = substr(stringvar,5,5)
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


// Average earnings in the pre-displacement period
bysort ssn: egen mean_earnings = mean(prim_earnings) if yyyyq<20061
bysort ssn: egen max = max(mean_earnings) 
replace mean_earnings = max 
drop max
label var mean_earnings "Mean earnings before 2006" 

// Average hours in the pre-displacement period
bysort ssn: egen mean_hours = mean(prim_hours) if yyyyq<20061
bysort ssn: egen max = max(mean_hours) 
replace mean_hours = max 
drop max
label var mean_earnings "Mean hours worked before 2006" 

// Average wages in the pre-displacement period
bysort ssn: egen mean_wage = mean(prim_wage) if yyyyq<20061
bysort ssn: egen max = max(prim_wage) 
replace mean_wage = max 
drop max
label var mean_wage "Mean wage before 2006"

// Firm ID in 2007Q4
gen firmid_2007 = . 
replace firmid_2007 = firmid if yyyyq==20074
bysort ssn: egen max = max(firmid_2007) 
replace firmid_2007 = max 
drop max
label var firmid_2007 "Firm ID in 2007Q4"

// Firm size in 2007Q4
gen pre_firmsize = . 
replace pre_firmsize = firmsize if yyyyq==20074
bysort ssn: egen max = max(pre_firmsize) 
replace pre_firmsize = max 
drop max
label var pre_firmsize "Firm size (number of employees) in 2007Q4"

// Log of firm size in 2007Q4
gen pre_logfirmsize = . 
replace pre_logfirmsize = log(firmsize) if yyyyq==20074
bysort ssn: egen max = max(pre_logfirmsize) 
replace pre_logfirmsize = max 
drop max
label var pre_logfirmsize "Log firm size (number of employees) in 2007Q4"

// Pre-displacement industry
destring naics, replace
gen naics1 = floor(naics/100000)
gen pre_industry = 0
replace pre_industry = naics1 if yyyyq==20074
bysort ssn: egen max = max(pre_industry) 
replace pre_industry = max 
drop max
label var pre_industry "1-digit industry in 2007Q4"

// Create age at the time of mass layoff/separation
gen age_at_disp = . 
replace age_at_disp = age if yyyyq == yyyyq_separation & dislocated == 1
replace age_at_disp = age if yyyyq == 20074 & dislocated == 0
bysort ssn: egen max = max(age_at_disp) 
replace age_at_disp = max 
drop max
label var age_at_disp "Age at displacement or age in 2007Q4"
gen old = (age_at_disp>=40)
label var old "Age at displacment (or 2007Q4) 40+" 

// Flag demographic information
generate demo = (!missing(age) & !missing(female) & !missing(race1) & !missing(educ1) & age_at_disp>=20 & age_at_disp<=50)
label variable demo "Demographic info on age, gender, race, and education, with age restrictions imposed" 

bysort ssn: egen mode = mode(female) 
replace female = mode 
drop mode
bysort ssn: egen mode = mode(male) 
replace male = mode 
drop mode
foreach var of varlist race1 race2 race3 race4 race5 race6 {
	bysort ssn: egen mode = mode(`var') 
	replace `var' = mode 
	drop mode	
	}


// Flag for separations occuring in 2008/2009/2010
gen separation0810 = (yyyy_separation==2008|yyyy_separation==2009|yyyy_separation==2010|missing(yyyy_separation))
label variable separation0810 "Separation occured in 2008–10 or is missing"

// Count the number of dislocated workers before sample cuts
gen separation_in_that_quarter = (yyyyq==yyyyq_separation)
table yyyyq if separation_in_that_quarter == 1

// Drop separators who were not in a mass layoff (non-mass layoff separators--more endogeneity)
sum  yyyyq if mass_layoff2==0 & separation==1
drop if mass_layoff2==0 & separation==1
tab dislocated  flag_nondis

// Drop separators who separated in 2007Q4
drop if yyyyq_separation == 20074


saveold "my_dislocated_1.dta", replace


*****************
/// Figure 1 ///
*****************

use "my_dislocated_1.dta", clear
sort ssn yyyyq 
set more off, permanently 

keep if demo==1 & age_at_disp>=20 & age_at_disp<=50


* Divide earnings by $1,000
replace prim_earnings = prim_earnings/1000

collapse (mean) prim_earnings prim_hours dislocated if dislocated==0 & flag_jls==1, by(yyyyq)
format %12.0f prim_earnings
format %12.0f prim_hours
saveold "collapsed_non_displaced.dta", replace

use "my_dislocated_1.dta", clear
keep if demo==1 & age_at_disp>=20 & age_at_disp<=50
replace prim_earnings = prim_earnings/1000
collapse (mean) prim_earnings prim_hours dislocated if flag_jls==1 & yyyyq_separation == 20091 & dislocated==1, by(yyyyq)
format %12.0f prim_earnings
format %12.0f prim_hours
saveold "collapsed_displaced.dta", replace
append using "collapsed_non_displaced.dta" 
set graphics off
twoway(line prim_earnings yyyyq if dislocated==1 & yyyyq>=20021 & yyyyq<=20141, legend(lab(1 "Displaced"))) (line prim_earnings yyyyq if dislocated==0 & yyyyq>=20021 & yyyyq<=20141, ///
legend(lab(2 "Not displaced"))), xline(20091) ytitle("Quarterly earnings (2010$, thousands)") title(20091) xtitle("Year and quarter") 
graph save Graph "prim_earnings_20091.gph", replace
set graphics off
twoway(line prim_hours yyyyq if dislocated==1 & yyyyq>=20021 & yyyyq<=20141, legend(lab(1 "Displaced"))) (line prim_hours yyyyq if dislocated==0 & yyyyq>=20021 & yyyyq<=20141, ///
legend(lab(2 "Not displaced"))), xline(20091) ytitle("Quarterly work hours") title(20091) xtitle("Year and quarter") 
graph save Graph "prim_hours_20091.gph", replace

grc1leg "prim_earnings_20091.gph" "prim_hours_20091.gph", cols(1) 
graph save Graph "Figure1.gph", replace

* Clean up
erase "prim_earnings_20091.gph"
erase "prim_hours_20091.gph"
erase "collapsed_non_displaced.dta"
erase "collapsed_displaced.dta"

