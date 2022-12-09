set more off, permanently

use linkdata7.dta, clear 

egen match = group(ssn firmid)

drop hours1 hourlywage1 wages1
rename hours2 hours
rename hourlywage2 hourlywage
rename wages2 earnings 
replace hourlywage = earnings/hours
rename hourlywage wage
destring ssn, replace 
rename yyyy year
destring lagfirmid, replace
destring firmid, replace

gen cpi 	= 1 if year == 2005
replace cpi = 0.906810036 if year == 2001
replace cpi = 0.921146953 if year == 2002
replace cpi = 0.942140297 if year == 2003
replace cpi = 0.967229903 if year == 2004
replace cpi = 1.032258065 if year == 2006
replace cpi = 1.061443932 if year == 2007
replace cpi = 1.102406554 if year == 2008
replace cpi = 1.098310292 if year == 2009
replace cpi = 1.116743472 if year == 2010
replace cpi = 1.1515617 if year == 2011
replace cpi = 1.17562724 if year == 2012
replace cpi = 1.193036354 if year == 2013
replace cpi = 1.211981567 if year == 2014
replace earnings = earnings/cpi

sort ssn firmid
by ssn: gen mover = (firmid != lagfirmid & lagfirmid != .)

xtset ssn year
gen logearnings = log(earnings)
gen loghours = log(hours)
gen logwage = log(wage)
keep if year>2001


// Sample cuts 
drop if hours == 0
drop if hours == .
drop if hours > 4800  
drop if hours < 400
drop if earnings <= 2850
drop if earnings == 0 
drop if earnings == .
drop if nemp >= 10
drop if firmsize < 5
drop if wage <= 2 
drop if wage == 0 
drop if wage == .
compress 



// ---------------------------------------------------------------------------//
//// 						Match Effects Estimation 						///
// ---------------------------------------------------------------------------//

bys ssn: gen panelworker = _N
drop if panelworker == 1
drop panelworker
group2hdfe ssn firmid , group(mygroup) largest(largest_connected_set) verbose
keep if largest_connected_set==1
drop mygroup largest_connected_set
keep ssn firmid year logwage logearnings loghours match

reg logwage i.year
predict logwage_tilde, resid

reg loghours i.year
predict loghours_tilde, resid

reg logearnings i.year
predict logearnings_tilde, resid


// Woodcock's match effects model
bys match: egen mean_logwage 		= mean(logwage_tilde)
bys match: egen mean_logearnings 	= mean(logearnings_tilde)
bys match: egen mean_loghours 		= mean(loghours_tilde)

reghdfe mean_logwage, absorb(logwage_pe2 = ssn logwage_fe2 = firmid) tol(0.001) verbose (1)
gen logwage_me = mean_logwage-(logwage_pe2+logwage_fe2)

reghdfe mean_logearnings, absorb(logearnings_pe2 = ssn logearnings_fe2 = firmid) tol(0.001) verbose (1)
gen logearnings_me = mean_logearnings-(logearnings_pe2+logearnings_fe2)

reghdfe mean_loghours, absorb(loghours_pe2 = ssn loghours_fe2 = firmid) tol(0.001) verbose (1)
gen loghours_me = mean_loghours-(loghours_pe2+loghours_fe2)


// Woodcock's model, controlling for tenure
bys ssn firmid (year): gen tenure = _n
replace tenure  = tenure - 1
label var tenure "Tenure in years (0,1,2...)"

areg logwage_tilde tenure, absorb(match)
gen logwage_test = logwage_tilde-(_b[tenure]*tenure)
bys match: egen mean_logwage_t = mean(logwage_test)
drop logwage_test

areg loghours_tilde tenure, absorb(match)
gen loghours_test = loghours_tilde-(_b[tenure]*tenure)
bys match: egen mean_loghours_t = mean(loghours_test)
drop loghours_test

areg logearnings_tilde tenure, absorb(match)
gen logearnings_test = logearnings_tilde-(_b[tenure]*tenure)
bys match: egen mean_logearnings_t = mean(logearnings_test)
drop logearnings_test

reghdfe mean_logwage_t, absorb(logwage_pet = ssn logwage_fet = firmid) tol(0.001) verbose (1)
gen logwage_met = mean_logwage_t-(logwage_pet+logwage_fet)

reghdfe mean_loghours_t, absorb(loghours_pet = ssn loghours_fet = firmid) tol(0.001) verbose (1)
gen loghours_met = mean_loghours_t-(loghours_pet+loghours_fet)

reghdfe mean_logearnings_t, absorb(logearnings_pet = ssn logearnings_fet = firmid) tol(0.001) verbose (1)
gen logearnings_met = mean_logearnings_t-(logearnings_pet+logearnings_fet)

save  "post_match_data_2002_2014.dta" , replace

summarize ssn 
unique ssn 
unique firmid 



