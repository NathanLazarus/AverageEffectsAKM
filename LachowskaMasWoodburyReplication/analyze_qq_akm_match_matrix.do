set more off, permanently


use  "post_match_data_2002_2014.dta", clear

// ---------------------------------------------------------------------------//

xtset ssn year
bysort ssn: gen firm0 = firmid
bysort ssn: gen firm_1 = L.firmid

bysort ssn: gen firm_2 = L2.firmid
bysort ssn: gen firm1 = F.firmid


// Same employer in year-1 and year-2
gen stayer_before = (firm_1 == firm_2 & firm_1!=. & firm_2!=.)

// Change of employer from year-1 to year 0
capture drop mover
gen mover = (firm0 != firm_1 & firm0 !=. & firm_1!=.)

// No change of employer from year-1 to year 0
gen stayer = (firm0 == firm_1 & firm0 !=. & firm_1!=.)

// Same employer in year 0 and year 1
gen stayer_after = (firm0 == firm1 & firm0 !=. & firm1!=.)

// Wages (FE)
bysort ssn: gen logwage_fe0 = logwage_fe2
bysort ssn: gen logwage_fe_1 = L.logwage_fe2
bysort ssn: gen logwage_fe_2 = L2.logwage_fe2
bysort ssn: gen logwage_fe1 = F.logwage_fe2

// Earnings (FE)
bysort ssn: gen logearnings_fe0 = logearnings_fe2
bysort ssn: gen logearnings_fe_1 = L.logearnings_fe2
bysort ssn: gen logearnings_fe_2 = L2.logearnings_fe2
bysort ssn: gen logearnings_fe1 = F.logearnings_fe2

// Hours (FE)
bysort ssn: gen loghours_fe0 = loghours_fe2
bysort ssn: gen loghours_fe_1 = L.loghours_fe2
bysort ssn: gen loghours_fe_2 = L2.loghours_fe2
bysort ssn: gen loghours_fe1 = F.loghours_fe2


// Calculate the qunitles of log wage employer effects (using AKM!) across all person-year observations
xtile logwagefe_xtile0 = logwage_fe0, nquantiles(5) 
xtile logwagefe_xtile_1 = logwage_fe_1, nquantiles(5)

gen logwagefe_xtile0_N = .
replace logwagefe_xtile0_N = 1 if logwagefe_xtile0==1
replace logwagefe_xtile0_N = 2 if logwagefe_xtile0==2
replace logwagefe_xtile0_N = 3 if logwagefe_xtile0==3
replace logwagefe_xtile0_N = 4 if logwagefe_xtile0==4
replace logwagefe_xtile0_N = 5 if logwagefe_xtile0==5

gen logwagefe_xtile_1_N = .
replace logwagefe_xtile_1_N = 1 if logwagefe_xtile_1==1
replace logwagefe_xtile_1_N = 2 if logwagefe_xtile_1==2
replace logwagefe_xtile_1_N = 3 if logwagefe_xtile_1==3
replace logwagefe_xtile_1_N = 4 if logwagefe_xtile_1==4
replace logwagefe_xtile_1_N = 5 if logwagefe_xtile_1==5


// Calculate the quntiles of log hours employer effects (using AKM!) across all person-year observations
xtile loghoursfe_xtile0 = loghours_fe0, nquantiles(5) 
xtile loghoursfe_xtile_1 = loghours_fe_1, nquantiles(5)

gen loghoursfe_xtile0_N = .
replace loghoursfe_xtile0_N = 1 if loghoursfe_xtile0==1
replace loghoursfe_xtile0_N = 2 if loghoursfe_xtile0==2
replace loghoursfe_xtile0_N = 3 if loghoursfe_xtile0==3
replace loghoursfe_xtile0_N = 4 if loghoursfe_xtile0==4
replace loghoursfe_xtile0_N = 5 if loghoursfe_xtile0==5

gen loghoursfe_xtile_1_N = .
replace loghoursfe_xtile_1_N = 1 if loghoursfe_xtile_1==1
replace loghoursfe_xtile_1_N = 2 if loghoursfe_xtile_1==2
replace loghoursfe_xtile_1_N = 3 if loghoursfe_xtile_1==3
replace loghoursfe_xtile_1_N = 4 if loghoursfe_xtile_1==4
replace loghoursfe_xtile_1_N = 5 if loghoursfe_xtile_1==5


// Calculate the quintiles of log earnings employer effects (using AKM!) across all person-year observations
xtile logearningsfe_xtile0 = logearnings_fe0, nquantiles(5) 
xtile logearningsfe_xtile_1 = logearnings_fe_1, nquantiles(5)

gen logearningsfe_xtile0_N = .
replace logearningsfe_xtile0_N = 1 if logearningsfe_xtile0==1
replace logearningsfe_xtile0_N = 2 if logearningsfe_xtile0==2
replace logearningsfe_xtile0_N = 3 if logearningsfe_xtile0==3
replace logearningsfe_xtile0_N = 4 if logearningsfe_xtile0==4
replace logearningsfe_xtile0_N = 5 if logearningsfe_xtile0==5

gen logearningsfe_xtile_1_N = .
replace logearningsfe_xtile_1_N = 1 if logearningsfe_xtile_1==1
replace logearningsfe_xtile_1_N = 2 if logearningsfe_xtile_1==2
replace logearningsfe_xtile_1_N = 3 if logearningsfe_xtile_1==3
replace logearningsfe_xtile_1_N = 4 if logearningsfe_xtile_1==4
replace logearningsfe_xtile_1_N = 5 if logearningsfe_xtile_1==5


// Rename the quintiles
rename logearningsfe_xtile_1 	pre_logearnings_fe_xtile
rename logearningsfe_xtile0 	post_logearnings_fe_xtile

// Rename the quintiles
rename logwagefe_xtile_1 		pre_logwage_fe_xtile
rename logwagefe_xtile0 		post_logwage_fe_xtile

// Rename the quintiles
rename loghoursfe_xtile_1 		pre_loghours_fe_xtile
rename loghoursfe_xtile0 		post_loghours_fe_xtile


// Save the data
save "post_akm_data_2002_2014_event.dta", replace
merge m:m ssn firmid using "post_match_data_2002_2014.dta"
keep if _merge==3
xtset  ssn year

// Wages (ME)
bysort ssn: gen logwage_me0 = logwage_met
bysort ssn: gen logwage_me_1 = L.logwage_met
bysort ssn: gen logwage_me_2 = L2.logwage_met
bysort ssn: gen logwage_me1 = F.logwage_met

// Earnings (ME)
bysort ssn: gen logearnings_me0 = logearnings_met
bysort ssn: gen logearnings_me_1 = L.logearnings_met
bysort ssn: gen logearnings_me_2 = L2.logearnings_met
bysort ssn: gen logearnings_me1 = F.logearnings_met

// Hours (ME)
bysort ssn: gen loghours_me0 = loghours_met
bysort ssn: gen loghours_me_1 = L.loghours_met
bysort ssn: gen loghours_me_2 = L2.loghours_met
bysort ssn: gen loghours_me1 = F.loghours_met


// Keep if separations occured 2008-2010
gen sep0810 = 1 if (year==2008|year==2009|year==2010) 
keep if sep0810==1

// Save the data
save "post_akm_data_2002_2014_event_match.dta", replace


	use "post_akm_data_2002_2014_event_match.dta", clear
	keep if !missing(pre_logwage_fe_xtile)
	keep if !missing(post_logwage_fe_xtile)
	collapse (mean) logwage_me_2 logwage_me_1 logwage_me0 logwage_me1 (count) ///
			preN = logwagefe_xtile_1_N postN = logwagefe_xtile0_N ///
			if mover==1 & stayer_before==1 & stayer_after==1 , by(pre_logwage_fe_xtile post_logwage_fe_xtile)
			gen delta_me = logwage_me1-logwage_me_2
	keep  pre_logwage_fe_xtile post_logwage_fe_xtile delta_me
	order  pre_logwage_fe_xtile post_logwage_fe_xtile delta_me
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Mover_logw_me", replace) 

	use "post_akm_data_2002_2014_event_match.dta", clear
	keep if !missing(pre_loghours_fe_xtile)
	keep if !missing(post_loghours_fe_xtile)
	collapse (mean) loghours_me_2 loghours_me_1 loghours_me0 loghours_me1 (count) /// 
			preN = loghoursfe_xtile_1_N postN = loghoursfe_xtile0_N ///	
			if mover==1 & stayer_before==1 & stayer_after==1 , by(pre_loghours_fe_xtile post_loghours_fe_xtile)
			gen delta_me = loghours_me1-loghours_me_2
	keep pre_loghours_fe_xtile post_loghours_fe_xtile delta_me
	order pre_loghours_fe_xtile post_loghours_fe_xtile delta_me
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Mover_logh_me", replace) 

	use "post_akm_data_2002_2014_event_match.dta", clear
	keep if !missing(pre_logearnings_fe_xtile)
	keep if !missing(post_logearnings_fe_xtile)
	collapse (mean) logearnings_me_2 logearnings_me_1 logearnings_me0 logearnings_me1 (count) ///
			preN = logearningsfe_xtile_1_N postN = logearningsfe_xtile0_N ///	
			if mover==1 & stayer_before==1 & stayer_after==1 , by(pre_logearnings_fe_xtile post_logearnings_fe_xtile)
			gen delta_me = logearnings_me1-logearnings_me_2
	keep pre_logearnings_fe_xtile post_logearnings_fe_xtile delta_me 
	order pre_logearnings_fe_xtile post_logearnings_fe_xtile delta_me
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Mover_loge_me", replace)

erase "post_akm_data_2002_2014_event_match.dta"
