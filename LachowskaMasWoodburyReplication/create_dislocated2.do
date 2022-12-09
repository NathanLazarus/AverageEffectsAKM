clear all 
use dislocated6.dta, clear

set more off, permanently 
destring ssn, replace
destring firmid, replace

keep if dislocated==1
gen dislocated2 = dislocated 
label var dislocated2 "Worker is disclocated, with no constr."

recode prim_hours (nonm = 783) if prim_hours > 783
recode prim_earnings (nonm = 68816.41) if prim_earnings > 68816.41   
recode prim_wage (nonm =  138.59) if prim_wage >  138.59

gen log_prim_earnings = log(prim_earnings)
gen log_prim_hours = log(prim_hours)
gen log_prim_wage = log(prim_wage)

gen prim_emp = (prim_earnings > 0|prim_hours > 0)
label var prim_emp "Earnings or hours are positive in quarter"

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

// Average wage in the pre-displacement period
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
bysort ssn: egen max = max(age_at_disp) 
replace age_at_disp = max 
drop max
label var age_at_disp "Age at dispalcement or age in 2007Q4"
gen old = (age_at_disp>=40)
label var old "Age at displacment (or 2007Q4) 40+" 


generate demo = (!missing(age) & !missing(female) & !missing(race1) & !missing(educ1) & age_at_disp>=20 & age_at_disp<=50)
label variable demo "Demographic info on age, gender, race, and education, with age restrictions imposed" 

gen separation0810 = (yyyy_separation==2008|yyyy_separation==2009|yyyy_separation==2010|missing(yyyy_separation))
label variable separation0810 "Separation occured in 2008–10 or is missing"

// Count the number of dislocated workers before sample cuts
gen separation_in_that_quarter = (yyyyq==yyyyq_separation)
table yyyyq if separation_in_that_quarter == 1

// Drop separators who were not in a mass layoff 
sum  yyyyq if mass_layoff2==0 & separation==1
drop if mass_layoff2==0 & separation==1
tab dislocated  flag_nondis

// Drop separators who separated in 20074
drop if yyyyq_separation == 20074


/// Define  time to displacement dummies
gen dis_dummies = .
replace dis_dummies =  qtrs_since_separation + 21 if dislocated2 == 1

recode dis_dummies (-3 = 0) (-2 = 0) (-1 = 0) if dislocated == 1 
replace dis_dummies = 0 if dislocated2 == 0
tab dis_dummies
label var dis_dummies "Displacement dummies" 

// Keep if within -6 to +5 years of the event
keep if dis_dummies >=0 & dis_dummies<=41

# delimit ;
label define sep_quarters
0 "-(24-21)" 1 "-20" 2 "-19" 3 "-18" 4 "-17"  5 "-16" 6 "-15" 7 "-14" 8 "-13" 9 "-12" 
10 "-11"  11 "-10" 12 "-9" 13 "-8" 14 "-7" 15 "-6" 16 "-5"  17 "-4" 18 "-3" 19 "-2" 20 "-1" 21 "0" 22 "1"  23 "2"  24 "3"
25 "4" 26 "5" 27 "6" 28 "7" 29 "8"  30 "9" 31 "10" 32 "11" 33 "12" 34 "13" 
35 "14"  36 "15" 37 "16" 38 "17" 39 "18" 40 "19" 41 "20" 42 "21" 43 "22" 44 "23" 45 "24"  ;
# delimit cr
label value dis_dummies sep_quarters

keep if dislocated2==1
keep if dis_dummies<=41
keep if demo==1
keep if separation0810==1
xtset ssn mytime
saveold "my_dislocated2.dta", replace









