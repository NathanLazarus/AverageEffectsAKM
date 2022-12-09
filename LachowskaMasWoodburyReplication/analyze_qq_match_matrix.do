
set more off, permanently

use "my_dislocated_akm.dta", clear

keep if flag_main==1
keep if dis_dummies <= 41	


// AKM Qtiles in 2007Q4
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


**** Pre-displacement log earnings, hours, and wages Woodcock's MATCH FE *********
merge m:m ssn firmid using "post_match_data_2002_2014.dta" , keepusing(logearnings_met loghours_met logwage_met) 
keep if _merge==3

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




**** Pre-displacement log earnings, hours, and wages MATCH FE *********

// Post-displacement MATCH FE for earnings  (2 years after displacement) for DW only
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

// Average log earnings MATCH FE in the post-displacement (2010-2014) for controls
bysort ssn: egen logearnings_me2 = mean(logearnings_met) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(logearnings_me2)  
replace post_logearnings_me = max if dislocated==0 
drop max
drop logearnings_me2



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

// Average log wage MATCH FE in the post-displacement (2010-2014) for controls
bysort ssn: egen logwage_me2 = mean(logwage_met) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(logwage_me2)  
replace post_logwage_me = max if dislocated==0 
drop max
drop logwage_me2



// Post-displacement MATCH FE for hours  (2 years after displacement) for DW only
gen post_loghours_me = . 
replace post_loghours_me = loghours_met if yyyyq == 20101 & dislocated == 1 & yyyyq_separation==20081
replace post_loghours_me = loghours_me if yyyyq == 20102 & dislocated == 1 & yyyyq_separation==20082
replace post_loghours_me = loghours_me if yyyyq == 20103 & dislocated == 1 & yyyyq_separation==20083
replace post_loghours_me = loghours_me if yyyyq == 20104 & dislocated == 1 & yyyyq_separation==20084

replace post_loghours_me = loghours_met if yyyyq == 20111 & dislocated == 1 & yyyyq_separation==20091
replace post_loghours_me = loghours_met if yyyyq == 20112 & dislocated == 1 & yyyyq_separation==20092
replace post_loghours_me = loghours_met if yyyyq == 20113 & dislocated == 1 & yyyyq_separation==20093
replace post_loghours_me = loghours_met if yyyyq == 20114 & dislocated == 1 & yyyyq_separation==20094

replace post_loghours_me = loghours_met if yyyyq == 20121 & dislocated == 1 & yyyyq_separation==20101
replace post_loghours_me = loghours_met if yyyyq == 20122 & dislocated == 1 & yyyyq_separation==20102
replace post_loghours_me = loghours_met if yyyyq == 20123 & dislocated == 1 & yyyyq_separation==20103
replace post_loghours_me = loghours_met if yyyyq == 20124 & dislocated == 1 & yyyyq_separation==20104

// Average MATCH log hours FE in the post-displacement (2010-2014) for controls
bysort ssn: egen loghours_me2 = mean(loghours_met) if yyyyq>=20104 & yyyyq<=20124 
bysort ssn: egen max = max(loghours_me2)  
replace post_loghours_me = max if dislocated==0 
drop max
drop loghours_me2




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


save "my_dislocated_match_event.dta", replace




**** Results *********
use "my_dislocated_match_event.dta", clear
keep if dislocated==1
keep if !missing(post_logwage_me)
keep if !missing(pre_logwage_me)
keep if !missing(post_logwage_fe_xtile )
keep if !missing(pre_logwage_fe_xtile )
collapse (mean)  pre_logwage_me  post_logwage_me (count) preN = pre_logwage_me  postN = post_logwage_me  ///
		, by(pre_logwage_fe_xtile post_logwage_fe_xtile  )
		gen delta_me = post_logwage_me-pre_logwage_me
keep pre_logwage_fe_xtile post_logwage_fe_xtile  delta_me
order pre_logwage_fe_xtile post_logwage_fe_xtile  delta_me
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("DW_logw_me", replace) 

use "my_dislocated_match_event.dta", clear
keep if dislocated==1
keep if !missing(post_loghours_me)
keep if !missing(pre_loghours_me)
keep if !missing(post_loghours_fe_xtile )
keep if !missing(pre_loghours_fe_xtile )
collapse (mean)  pre_loghours_me  post_loghours_me (count) preN = pre_loghours_me  postN = post_loghours_me ///
		, by(pre_loghours_fe_xtile post_loghours_fe_xtile  )
		gen delta_me = post_loghours_me-pre_loghours_me
keep pre_loghours_fe_xtile post_loghours_fe_xtile delta_me
order pre_loghours_fe_xtile post_loghours_fe_xtile delta_me
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("DW_logh_me", replace) 

use "my_dislocated_match_event.dta", clear
keep if dislocated==1
keep if !missing(post_logearnings_me)
keep if !missing(pre_logearnings_me)
keep if !missing(post_logearnings_fe_xtile )
keep if !missing(pre_logearnings_fe_xtile )
collapse (mean)  pre_logearnings_me  post_logearnings_me (count) preN = pre_logearnings_me  postN = post_logearnings_me  ///
		, by(pre_logearnings_fe_xtile post_logearnings_fe_xtile  )
		gen delta_me = post_logearnings_me-pre_logearnings_me
keep pre_logearnings_fe_xtile post_logearnings_fe_xtile delta_me
order pre_logearnings_fe_xtile post_logearnings_fe_xtile delta_me
export excel using "DW_Long_Raw.xlsx", firstrow(variables) sheet("DW_loge_me", replace) 


// Clean up
erase "my_dislocated_match_event.dta"


