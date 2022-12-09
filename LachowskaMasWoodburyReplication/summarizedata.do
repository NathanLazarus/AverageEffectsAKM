set more off, permanently 


use "my_dislocated_1.dta", clear

gen dis_dummies = .
replace dis_dummies =  qtrs_since_separation + 21 if dislocated == 1
recode dis_dummies (-3 = 0) (-2 = 0) (-1 = 0) if dislocated == 1 
replace dis_dummies = 0 if dislocated == 0
label var dis_dummies "Displacement dummies" 
keep if dis_dummies >= 0 & dis_dummies <= 41

# delimit ;
label define sep_quarters
0 "-(24-21)" 1 "-20" 2 "-19" 3 "-18" 4 "-17"  5 "-16" 6 "-15" 7 "-14" 8 "-13" 9 "-12" 
10 "-11"  11 "-10" 12 "-9" 13 "-8" 14 "-7" 15 "-6" 16 "-5"  17 "-4" 18 "-3" 19 "-2" 20 "-1" 21 "0" 22 "1"  23 "2"  24 "3"
25 "4" 26 "5" 27 "6" 28 "7" 29 "8"  30 "9" 31 "10" 32 "11" 33 "12" 34 "13" 
35 "14"  36 "15" 37 "16" 38 "17" 39 "18" 40 "19" 41 "20" 42 "21" 43 "22" 44 "23" 45 "24"  ;
# delimit cr
label value dis_dummies sep_quarters
compress


// Divide earnings by 1,000
replace prim_earnings = prim_earnings/1000
replace all_earnings = all_earnings/1000

// Seasonality dummies
gen long yyyy=int(yyyyq/10)
gen byte q=yyyyq-10*yyyy

// Generate flags 
gen flag_main 		= (flag_jls==1 & separation0810==1 & demo==1 & age_at_disp>=20 & age_at_disp<=50)
gen flag_manuf 		= (flag_jls==1 & separation0810==1 & demo==1 & pre_industry == 3 & age_at_disp>=20 & age_at_disp<=50)
gen flag_pk 		= (separation0810==1 & demo==1 & age_at_disp>=20 & age_at_disp<=50)
gen flag_allobs 	= (flag_jls==1 & separation0810==1) 



/// Descriptives for workers with demographics at baseline (20074)

*****************
/// Table 1 ///
/// Note: less than high school = educ1 + educ2
*****************

// Displaced--JLS
unique ssn if dislocated == 1 & flag_main==1
unique firmid if dislocated == 1 & flag_main==1
sum female race* age educ* mean_earnings mean_hours mean_wage pre_firmsize  if  dislocated == 1 & flag_main==1 & yyyyq==20074
tab pre_industry if dislocated == 1 & flag_main==1 & yyyyq==20074

// Controls--JLS 
unique ssn if dislocated == 0 & flag_main==1
unique firmid if dislocated == 0 & flag_main==1
sum female race* age educ* mean_earnings mean_hours mean_wage pre_firmsize if dislocated == 0 & flag_main==1 & yyyyq==20074
tab pre_industry if dislocated == 0 & flag_main==1 & yyyyq==20074


// Displaced--JLS; non-FIRE
unique ssn  if  dislocated == 1  & flag_main==1 & yyyyq==20074 & pre_industry!=5
unique firmid if    dislocated == 1  & flag_main==1 & yyyyq==20074 & pre_industry!=5
sum female race* age educ* mean_earnings mean_hours mean_wage pre_firmsize  if  dislocated == 1  & flag_main==1 & yyyyq==20074 & pre_industry!=5
tab pre_industry if dislocated == 1 & flag_main==1 & yyyyq==20074 & pre_industry!=5

// Controls--JLS; non-FIRE
unique ssn if dislocated == 0 & flag_main==1  & yyyyq==20074 & pre_industry!=5
unique firmid if dislocated == 0 & flag_main==1 & yyyyq==20074 & pre_industry!=5
sum female race* age educ* mean_earnings mean_hours mean_wage pre_firmsize if dislocated == 0 & flag_main==1 & yyyyq==20074 & pre_industry!=5
tab pre_industry if dislocated == 0 & flag_main==1 & yyyyq==20074 & pre_industry!=5


// Set up the panel 
xtset ssn mytime
saveold "my_dislocated.dta", replace


erase "my_dislocated_1.dta"
