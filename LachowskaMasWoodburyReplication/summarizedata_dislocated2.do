set more off, permanently 


use "my_dislocated.dta", replace
merge 1:1 (ssn yyyyq) using "my_dislocated2.dta", generate(_merge_dislocated) 
bysort ssn: egen post_earnings = sum(prim_earnings) if qtrs_since_dislocation>0 
bysort ssn: egen max = max(post_earnings)  
replace post_earnings = max 
drop max
label var post_earnings "Sum of post earnings after displacement" 
gen no_empl = .
replace no_empl =  0 if  _merge_dislocated == 2  
replace no_empl =  1 if  _merge_dislocated == 2  & post_earnings == 0 & !missing(post_earnings)


*******************
/// Table A3-1  ///
*******************
// Descriptives for all DW  (2007:4)
unique ssn if _merge_dislocated == 3 
unique firmid if _merge_dislocated == 3 
sum female race* age educ* mean_earnings mean_hours mean_wage pre_firmsize  if  _merge_dislocated == 3 & yyyyq==20074
tab pre_industry if _merge_dislocated == 3 & yyyyq==20074


// Descriptives for DW without employment constraint (2007:4)
unique ssn if _merge_dislocated == 2 
unique firmid if _merge_dislocated == 2 
sum female race* age educ* mean_earnings mean_hours mean_wage pre_firmsize  if  _merge_dislocated == 2 & yyyyq==20074
tab pre_industry if _merge_dislocated == 2 & yyyyq==20074


// Descriptives for DW without employment in 16 quarters post displacement (2007:4)
unique ssn if _merge_dislocated == 2 & no_empl==1
unique firmid if _merge_dislocated == 2 & no_empl==1
sum female race* age educ* mean_earnings mean_hours mean_wage pre_firmsize  if _merge_dislocated == 2 & yyyyq==20074 & no_empl==1
tab pre_industry if _merge_dislocated == 2 &  yyyyq==20074 & no_empl==1

