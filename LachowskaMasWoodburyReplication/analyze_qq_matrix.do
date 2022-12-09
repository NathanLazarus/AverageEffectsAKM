
set more off, permanently

use "my_dislocated_akm.dta", clear

keep if flag_main==1
keep if dis_dummies <= 41	

drop akm_earnings_xtile
gen akm_earnings_xtile = . 
replace akm_earnings_xtile = logearningsfe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_earnings_xtile) 
replace akm_earnings_xtile = max 
drop max
label var akm_earnings_xtile "AKM earnings effect xtile in 2007Q4"

drop akm_hours_xtile
gen akm_hours_xtile = . 
replace akm_hours_xtile = loghoursfe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_hours_xtile) 
replace akm_hours_xtile = max 
drop max
label var akm_hours_xtile "AKM hours effect xtile in 2007Q4"

drop akm_wage_xtile
gen akm_wage_xtile = . 
replace akm_wage_xtile = logwagefe_xtile if yyyyq==20074
bysort ssn: egen max = max(akm_wage_xtile) 
replace akm_wage_xtile = max 
drop max
label var akm_wage_xtile "AKM wage effect xtile in 2007Q4"




******** Pre-displacement earnings, hours, wages ***********

// Average logearnings in the pre-displacement period for DW and controls
bysort ssn: egen pre_logearnings = mean(log_prim_earnings) if yyyyq<20061
bysort ssn: egen max = max(pre_logearnings) 
replace pre_logearnings = max 
drop max
label var pre_logearnings "Mean log earnings before 2006" 

// Average loghours in the pre-displacement period for DW and controls
bysort ssn: egen pre_loghours = mean(log_prim_hours) if yyyyq<20061
bysort ssn: egen max = max(pre_loghours) 
replace pre_loghours = max 
drop max
label var pre_loghours "Mean log hours worked before 2006" 

// Average logwage in the pre-displacement period for DW and controls
bysort ssn: egen pre_logwage = mean(log_prim_wage) if yyyyq<20061 
bysort ssn: egen max = max(pre_logwage)  
replace pre_logwage = max  
drop max
label var pre_logwage "Mean log wage before 2006"


**** Pre-displacement AKM log earnings, hours, and wages firm FE *********

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

// Average logearnings in the post-displacement (2010-2012) for controls
bysort ssn: egen post_logearnings2 = mean(log_prim_earnings) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(post_logearnings2)  
replace post_logearnings = max  if dislocated==0 
drop max 
drop post_logearnings2


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

// Average loghours in the post-displacement (2010-2012) for controls
bysort ssn: egen post_loghours2 = mean(log_prim_hours) if  yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(post_loghours2)  
replace post_loghours = max  if dislocated==0 
drop max
drop post_loghours2


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

// Average logwage in the post-displacement (2010-2014) for controls
bysort ssn: egen post_logwage2 = mean(log_prim_wage) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(post_logwage2)  
replace post_logwage = max if dislocated==0 
drop max
drop post_logwage2


**** Pre-displacement AKM log earnings, hours, and wages firm FE *********

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

// Average AKM log earnings FE in the post-displacement (2010-2014) for controls
bysort ssn: egen logearnings_fe2 = mean(logearnings_fe) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(logearnings_fe2)  
replace post_logearnings_fe = max if dislocated==0 
drop max
drop logearnings_fe2




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

// Average AKM log wage FE in the post-displacement (2010-2014) for controls
bysort ssn: egen logwage_fe2 = mean(logwage_fe) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(logwage_fe2)  
replace post_logwage_fe = max if dislocated==0 
drop max
drop logwage_fe2



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

// Average AKM log hours FE in the post-displacement (2010-2014) for controls
bysort ssn: egen loghours_fe2 = mean(loghours_fe) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(loghours_fe2)  
replace post_loghours_fe = max if dislocated==0 
drop max
drop loghours_fe2




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


// Post-displacement AKM quintile of earnings (use the mode of firm FE quintile for 2010-2012) for controls
bysort ssn: egen post_logearnings_fe_xtile2 = mode(akm_earnings_xtile) if yyyyq>=20104 & yyyyq<=20124 & dislocated==0  , min
bysort ssn: egen max = max(post_logearnings_fe_xtile2)  
replace post_logearnings_fe_xtile = max if dislocated==0 
drop max
drop post_logearnings_fe_xtile2


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


// Post-displacement AKM quintile of hours (use the mode of firm FE quintile for 2010-2012) for controls
bysort ssn: egen post_loghours_fe_xtile2 = mode(akm_hours_xtile) if yyyyq>=20104 & yyyyq<=20124 & dislocated==0  , min
bysort ssn: egen max = max(post_loghours_fe_xtile2)  
replace post_loghours_fe_xtile = max if dislocated==0 
drop max
drop post_loghours_fe_xtile2




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


// Post-displacement AKM quintile of hours (use the mode of firm FE quintile for 2010-2012) for controls
bysort ssn: egen post_logwage_fe_xtile2 = mode(akm_wage_xtile) if yyyyq>=20104 & yyyyq<=20124 & dislocated==0  , min
bysort ssn: egen max = max(post_logwage_fe_xtile2)  
replace post_logwage_fe_xtile = max if dislocated==0 
drop max
drop post_logwage_fe_xtile2




save "my_dislocated_akm_event.dta", replace



***************************************
/// Data underlying: 
/// Figures 7, 8a, 8B, 8C, A9-1, A9-2, A9-3, A9-4, A9-5, A9-6, A9-7, A9-8, ///
/// Tables 4, 5, 6, A9-4, A9-5, A9-6,  7, A9-1, A9-2, A9-3, A9-4 ///
***************************************

use "my_dislocated_akm_event.dta", clear
keep if dislocated==1
keep if !missing(post_logwage)
keep if !missing(post_logwage_fe_xtile )
collapse (mean)  pre_logwage  post_logwage  pre_logwage_fe  post_logwage_fe  (count) preN = pre_logwage  Nobs = post_logwage ///
		(percent) pro = pre_logwage		, by(pre_logwage_fe_xtile post_logwage_fe_xtile  )
		gen delta = post_logwage-pre_logwage
		gen delta_fe = post_logwage_fe-pre_logwage_fe
keep pre_logwage_fe_xtile post_logwage_fe_xtile  Nobs delta   delta_fe 
order pre_logwage_fe_xtile post_logwage_fe_xtile  Nobs delta   delta_fe 
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("DW_logw_fe", replace) 

use "my_dislocated_akm_event.dta", clear
keep if dislocated==0
keep if  yyyyq==20074 
collapse (mean)  pre_logwage post_logwage pre_logwage_fe  post_logwage_fe (count) preN = pre_logwage  postN = post_logwage	///
		, by(pre_logwage_fe_xtile post_logwage_fe_xtile )
		gen delta = post_logwage-pre_logwage
		gen delta_fe = post_logwage_fe-pre_logwage_fe
keep pre_logwage_fe_xtile post_logwage_fe_xtile   delta   
order pre_logwage_fe_xtile post_logwage_fe_xtile   delta   
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("Ctrl_logw", replace) 
**** In Excel, for each quintile, subtract the average delta log wage for controls from the delta of DW


use "my_dislocated_akm_event.dta", clear
keep if dislocated==1
keep if !missing(post_loghours)
keep if !missing(post_loghours_fe_xtile)
collapse (mean)  pre_loghours  post_loghours pre_loghours_fe  post_loghours_fe  (count) preN = pre_loghours  Nobs = post_loghours ///
		(percent) pro = pre_loghours, by(pre_loghours_fe_xtile post_loghours_fe_xtile  )
		gen delta = post_loghours-pre_loghours
		gen delta_fe = post_loghours_fe-pre_loghours_fe
keep pre_loghours_fe_xtile post_loghours_fe_xtile Nobs  delta   delta_fe  
order pre_loghours_fe_xtile post_loghours_fe_xtile  Nobs delta    delta_fe  
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("DW_logh_fe", replace) 

use "my_dislocated_akm_event.dta", clear
keep if dislocated==0
keep if  yyyyq==20074 
collapse (mean)  pre_loghours post_loghours pre_loghours_fe post_loghours_fe (count) preN = pre_loghours  postN = post_loghours	///
		, by(pre_loghours_fe_xtile post_loghours_fe_xtile )
		gen delta = post_loghours-pre_loghours
		gen delta_fe = post_loghours_fe-pre_loghours_fe
keep pre_loghours_fe_xtile post_loghours_fe_xtile delta 
order pre_loghours_fe_xtile post_loghours_fe_xtile delta 
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("Ctrl_logh", replace) 
**** In Excel, for each quintile, subtract the average delta log hours for controls from the delta of DW


use "my_dislocated_akm_event.dta", clear
keep if dislocated==1
keep if !missing(post_logearnings)
keep if !missing(post_logearnings_fe_xtile)

collapse (mean)  pre_logearnings  post_logearnings pre_logearnings_fe  post_logearnings_fe (count) preN = pre_logearnings  Nobs = post_logearnings ///
		(percent) pro = pre_logearnings, by(pre_logearnings_fe_xtile post_logearnings_fe_xtile  )
		gen delta = post_logearnings-pre_logearnings
		gen delta_fe = post_logearnings_fe-pre_logearnings_fe
keep pre_logearnings_fe_xtile post_logearnings_fe_xtile Nobs delta  delta_fe  
order pre_logearnings_fe_xtile post_logearnings_fe_xtile Nobs delta  delta_fe  
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("DW_loge_fe", replace) 

use "my_dislocated_akm_event.dta", clear
keep if dislocated==0
keep if  yyyyq==20074 
collapse (mean)  pre_logearnings post_logearnings pre_logearnings_fe  post_logearnings_fe (count) preN = pre_logearnings  postN = post_logearnings	///
		, by(pre_logearnings_fe_xtile post_logearnings_fe_xtile )
		gen delta = post_logearnings-pre_logearnings
		gen delta_fe = post_logearnings_fe-pre_logearnings_fe
keep  pre_logearnings_fe_xtile post_logearnings_fe_xtile  delta 
order pre_logearnings_fe_xtile post_logearnings_fe_xtile  delta 
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("Ctrl_loge", replace) 
**** In Excel, for each quintile, subtract the average delta log earnings for controls from the delta of DW




