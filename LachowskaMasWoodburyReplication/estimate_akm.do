set more off, permanently 

use dislocated4.dta, clear 
destring ssn, replace

sort ssn yyyyq
bysort ssn: egen max = max(mass_layoff2) 
replace mass_layoff2 = max 
drop max

sort ssn yyyyq
bysort ssn: egen max = max(separation) 
replace separation = max 
drop max

sort ssn yyyyq
gen yyyyq_separation2 = .
bysort ssn: egen min = min(yyyyq_separation) 
replace yyyyq_separation2 = min 
replace yyyyq_separation = yyyyq_separation2 
drop min yyyyq_separation2

gen demo = (!missing(age) & !missing(female) & !missing(race1) & !missing(educ1))

drop if mass_layoff2==0 & separation==1
drop if yyyyq_separation == 20074
collapse demo dislocated, by(ssn)
recode dislocated (nonm = 1)
save "dislocated_id.dta", replace

use linkdata7.dta, clear 
destring ssn, replace 
merge m:1 ssn using "dislocated_id.dta"
gen displaced_flag = demo==1|dislocated==1
drop if displaced_flag==1
drop _merge displaced_flag dislocated demo

// Data management
tostring ssn, replace
gen str spell2 = ssn+firmid

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

*******************************
/// Table B1, first column  ///
*******************************

summarize ssn if !missing(logearnings)
unique ssn if !missing(logearnings)
unique firmid if !missing(logearnings)
unique ssn if mover==1 & !missing(logearnings)
count if mover==1 & !missing(logearnings)
summarize logearnings loghours logwage  if !missing(logearnings)



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
//// 						AKM Estimation 									///
// ---------------------------------------------------------------------------//

bys ssn: gen panelworker = _N
drop if panelworker == 1
drop panelworker
group2hdfe ssn firmid , group(mygroup) largest(largest_connected_set) verbose
keep if largest_connected_set==1
drop mygroup largest_connected_set

*******************************
/// Table B2  ///
*******************************
keep ssn firmid year logwage logearnings loghours mover
xi: a2reg logwage i.year, individual(ssn) unit(firmid)  indeffect(logwage_pe) uniteffect(logwage_fe) xb(logwage_xb) resid(logwage_res)
xi: a2reg loghours i.year, individual(ssn) unit(firmid)  indeffect(loghours_pe) uniteffect(loghours_fe) xb(loghours_xb) resid(loghours_res)
xi: a2reg logearnings i.year, individual(ssn) unit(firmid)  indeffect(logearnings_pe) uniteffect(logearnings_fe) xb(logearnings_xb) resid(logearnings_res)

keep if  !missing(logearnings)
keep if  !missing(loghours)
keep if  !missing(logwage)

// CHK model
egen match = group(ssn firmid)
areg logwage i.year, absorb(match) 
areg loghours i.year, absorb(match) 
areg logearnings i.year, absorb(match) 

save "post_akm_data_2002_2014.dta", replace


// ---------------------------------------------------------------------------//
//// 						Post-AKM Analysis 								///
// ---------------------------------------------------------------------------//


*******************************
/// Table B1, second column  ///
*******************************
summarize ssn if  !missing(logearnings)
unique ssn if !missing(logearnings)
unique firmid if !missing(logearnings)
unique ssn if mover==1 & !missing(logearnings)
summarize logearnings loghours logwage if !missing(logearnings), 


*******************************
/// Table B2  ///
*******************************
// Variance-covariance matrix: 

foreach var of varlist logearnings loghours logwage {
	corr `var' `var'_pe `var'_fe `var'_xb `var'_res if !missing( `var'), covariance 
	matrix my_c = r(C)
	scalar var_y = my_c[1,1]
	scalar var_pe = my_c[2,2]
	scalar var_fe = my_c[3,3]
	scalar two_covar_pefe = 2*my_c[3,2]
	scalar two_covar_pexb = 2*my_c[4,2]
	scalar two_covar_fexb = 2*my_c[4,3]
	scalar var_xb = my_c[4,4]
	scalar var_res = my_c[5,5]
	display as text "Outcome variable is `var' "
	display "var(y) = var(pe) + var(fe) + var(xb) + 2*cov(pe,fe) + 2*cov(pe,xb) + 2*cov(fe,xb) + var(r)"
	display as text "var_y  = " var_y 
	display as text "var_pe  = " var_pe 
	display as text "var_fe  = " var_fe 
	display as text "var_xb  = " var_xb 
	display as text "2*covar_pefe  = " two_covar_pefe 
	display as text "2*covar_pexb  = " two_covar_pexb 
	display as text "2*covar_fexb  = " two_covar_fexb 
	display as text "var_res  = " var_res


	// Explained shares matrix:
	display "Now, divide each variance and covariance by var(y) to get explained shares:"
	scalar share_pe = var_pe/var_y
	scalar share_fe = var_fe/var_y
	scalar share_xb = var_xb/var_y
	scalar share_covar_pefe = two_covar_pefe/var_y
	scalar share_covar_pexb = two_covar_pexb/var_y
	scalar share_covar_fexb = two_covar_fexb/var_y
	scalar share_res = var_res/var_y
	display as text "share pe  = " share_pe 
	display as text "share fe  = " share_fe 
	display as text "share xb  = " share_xb 
	display as text "share covar_pefe  = " share_covar_pefe 
	display as text "share covar_pexb  = " share_covar_pexb 
	display as text "share covar_fexb  = " share_covar_fexb 
	display as text "share_res  = " share_res
}



// ---------------------------------------------------------------------------//
/// Event-study analysis



************************************************
/// Numbers underlying Table B3 & Figures B2-B4 
/// are in Excel file "Table_B3.xls"
************************************************

xtset ssn year

bysort ssn: gen firm0 = firmid
bysort ssn: gen firm_1 = L.firmid
bysort ssn: gen firm_2 = L2.firmid
bysort ssn: gen firm1 = F.firmid

// Same employer in year-1 and year-2
gen stayer_before = (firm_1 == firm_2 & firm_1!=. & firm_2!=.)

// Change of employer from year-1 to year 0
drop mover
gen mover = (firm0 != firm_1 & firm0 !=. & firm_1!=.)

// Same employer in year 0 and year 1
gen stayer_after = (firm0 == firm1 & firm0 !=. & firm1!=.)


// Wages
bysort ssn: gen logwage_fe0 = logwage_fe
bysort ssn: gen logwage_fe_1 = L.logwage_fe
bysort ssn: gen logwage_fe_2 = L2.logwage_fe
bysort ssn: gen logwage_fe1 = F.logwage_fe

bysort ssn: gen logwage0 = logwage
bysort ssn: gen logwage_1 = L.logwage
bysort ssn: gen logwage_2 = L2.logwage
bysort ssn: gen logwage1 = F.logwage

xtile logwagefe_xtile0 = logwage_fe0, nquantiles(4) 
xtile logwagefe_xtile_1 = logwage_fe_1, nquantiles(4)

gen logwagefe_xtile0_N = .
replace logwagefe_xtile0_N = 1 if logwagefe_xtile0==1
replace logwagefe_xtile0_N = 2 if logwagefe_xtile0==2
replace logwagefe_xtile0_N = 3 if logwagefe_xtile0==3
replace logwagefe_xtile0_N = 4 if logwagefe_xtile0==4

gen logwagefe_xtile_1_N = .
replace logwagefe_xtile_1_N = 1 if logwagefe_xtile_1==1
replace logwagefe_xtile_1_N = 2 if logwagefe_xtile_1==2
replace logwagefe_xtile_1_N = 3 if logwagefe_xtile_1==3
replace logwagefe_xtile_1_N = 4 if logwagefe_xtile_1==4


// Earnings
bysort ssn: gen logearnings_fe0 = logearnings_fe
bysort ssn: gen logearnings_fe_1 = L.logearnings_fe
bysort ssn: gen logearnings_fe_2 = L2.logearnings_fe
bysort ssn: gen logearnings_fe1 = F.logearnings_fe

bysort ssn: gen logearnings0 = logearnings
bysort ssn: gen logearnings_1 = L.logearnings
bysort ssn: gen logearnings_2 = L2.logearnings
bysort ssn: gen logearnings1 = F.logearnings

xtile logearningsfe_xtile0 = logearnings_fe0, nquantiles(4) 
xtile logearningsfe_xtile_1 = logearnings_fe_1, nquantiles(4)

gen logearningsfe_xtile0_N = .
replace logearningsfe_xtile0_N = 1 if logearningsfe_xtile0==1
replace logearningsfe_xtile0_N = 2 if logearningsfe_xtile0==2
replace logearningsfe_xtile0_N = 3 if logearningsfe_xtile0==3
replace logearningsfe_xtile0_N = 4 if logearningsfe_xtile0==4

gen logearningsfe_xtile_1_N = .
replace logearningsfe_xtile_1_N = 1 if logearningsfe_xtile_1==1
replace logearningsfe_xtile_1_N = 2 if logearningsfe_xtile_1==2
replace logearningsfe_xtile_1_N = 3 if logearningsfe_xtile_1==3
replace logearningsfe_xtile_1_N = 4 if logearningsfe_xtile_1==4


// Hours
bysort ssn: gen loghours_fe0 = loghours_fe
bysort ssn: gen loghours_fe_1 = L.loghours_fe
bysort ssn: gen loghours_fe_2 = L2.loghours_fe
bysort ssn: gen loghours_fe1 = F.loghours_fe

bysort ssn: gen loghours0 = loghours
bysort ssn: gen loghours_1 = L.loghours
bysort ssn: gen loghours_2 = L2.loghours
bysort ssn: gen loghours1 = F.loghours


xtile loghoursfe_xtile0 = loghours_fe0, nquantiles(4) 
xtile loghoursfe_xtile_1 = loghours_fe_1, nquantiles(4)

gen loghoursfe_xtile0_N = .
replace loghoursfe_xtile0_N = 1 if loghoursfe_xtile0==1
replace loghoursfe_xtile0_N = 2 if loghoursfe_xtile0==2
replace loghoursfe_xtile0_N = 3 if loghoursfe_xtile0==3
replace loghoursfe_xtile0_N = 4 if loghoursfe_xtile0==4

gen loghoursfe_xtile_1_N = .
replace loghoursfe_xtile_1_N = 1 if loghoursfe_xtile_1==1
replace loghoursfe_xtile_1_N = 2 if loghoursfe_xtile_1==2
replace loghoursfe_xtile_1_N = 3 if loghoursfe_xtile_1==3
replace loghoursfe_xtile_1_N = 4 if loghoursfe_xtile_1==4


save "post_akm_data_2002_2014_event.dta", replace


*******************************
/// Table B3, Panel A  ///
*******************************
// Earnings
use "post_akm_data_2002_2014_event.dta", clear
collapse (mean) logearnings_2 logearnings_1 logearnings0 logearnings1 (count) logearningsfe_xtile_1_N logearningsfe_xtile0_N ///	
		if mover==1 & stayer_before==1 & stayer_after==1 , by(logearningsfe_xtile_1 logearningsfe_xtile0)
		gen delta = logearnings1-logearnings_2
		gen adj = . in 1/16
		replace adj = delta[1] if logearningsfe_xtile_1 == 1
		replace adj = delta[6] if logearningsfe_xtile_1 == 2
		replace adj = delta[11] if logearningsfe_xtile_1 == 3
		replace adj = delta[16] if logearningsfe_xtile_1 == 4
		gen delta_adj = delta-adj
		drop adj
		rename logearningsfe_xtile_1_N N_obs
		drop logearningsfe_xtile0_N
		order logearningsfe_xtile_1 logearningsfe_xtile0 logearnings_2 logearnings_1 logearnings0 logearnings1 delta   delta_adj N_obs 
export excel using "Table_B3.xlsx", firstrow(variables) sheet("PanelA", replace) 

*******************************
/// Table B3, Panel B  ///
*******************************
// Hours
use "post_akm_data_2002_2014_event.dta", clear
collapse (mean) loghours_2 loghours_1 loghours0 loghours1 (count) loghoursfe_xtile_1_N loghoursfe_xtile0_N ///	
		if mover==1 & stayer_before==1 & stayer_after==1 , by(loghoursfe_xtile_1 loghoursfe_xtile0)
		gen delta = loghours1-loghours_2
		gen adj = . in 1/16
		replace adj = delta[1] if loghoursfe_xtile_1 == 1
		replace adj = delta[6] if loghoursfe_xtile_1 == 2
		replace adj = delta[11] if loghoursfe_xtile_1 == 3
		replace adj = delta[16] if loghoursfe_xtile_1 == 4
		gen delta_adj = delta-adj
		drop adj
		rename loghoursfe_xtile_1_N N_obs
		drop loghoursfe_xtile0_N
		order loghoursfe_xtile_1 loghoursfe_xtile0 loghours_2 loghours_1 loghours0 loghours1 delta   delta_adj N_obs
export excel using "Table_B3.xlsx", firstrow(variables) sheet("PanelB", replace) 

*******************************
/// Table B3, Panel C  ///
*******************************
// Wages
use "post_akm_data_2002_2014_event.dta", clear
collapse (mean) logwage_2 logwage_1 logwage0 logwage1 (count) logwagefe_xtile_1_N logwagefe_xtile0_N ///
		if mover==1 & stayer_before==1 & stayer_after==1 , by(logwagefe_xtile_1 logwagefe_xtile0)
		gen delta = logwage1-logwage_2
		gen adj = . in 1/16
		replace adj = delta[1] if logwagefe_xtile_1 == 1
		replace adj = delta[6] if logwagefe_xtile_1 == 2
		replace adj = delta[11] if logwagefe_xtile_1 == 3
		replace adj = delta[16] if logwagefe_xtile_1 == 4
		gen delta_adj = delta-adj
		drop adj
		rename logwagefe_xtile_1_N N_obs
		drop logwagefe_xtile0_N
order logwagefe_xtile_1 logwagefe_xtile0 logwage_2 logwage_1 logwage0 logwage1 delta  delta_adj  N_obs
export excel using "Table_B3.xlsx", firstrow(variables) sheet("PanelC", replace) 


// Clean up
erase "post_akm_data_2002_2014_event.dta"
erase "dislocated_id.dta"












