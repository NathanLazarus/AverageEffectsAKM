
use "post_akm_data_2002_2014.dta", clear

// ---------------------------------------------------------------------------//

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

// No change of employer from year-1 to year 0
gen stayer = (firm0 == firm_1 & firm0 !=. & firm_1!=.)

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

// Earnings
bysort ssn: gen logearnings_fe0 = logearnings_fe
bysort ssn: gen logearnings_fe_1 = L.logearnings_fe
bysort ssn: gen logearnings_fe_2 = L2.logearnings_fe
bysort ssn: gen logearnings_fe1 = F.logearnings_fe

bysort ssn: gen logearnings0 = logearnings
bysort ssn: gen logearnings_1 = L.logearnings
bysort ssn: gen logearnings_2 = L2.logearnings
bysort ssn: gen logearnings1 = F.logearnings

// Hours
bysort ssn: gen loghours_fe0 = loghours_fe
bysort ssn: gen loghours_fe_1 = L.loghours_fe
bysort ssn: gen loghours_fe_2 = L2.loghours_fe
bysort ssn: gen loghours_fe1 = F.loghours_fe

bysort ssn: gen loghours0 = loghours
bysort ssn: gen loghours_1 = L.loghours
bysort ssn: gen loghours_2 = L2.loghours
bysort ssn: gen loghours1 = F.loghours


// Calculate the qunitles of log wage employer effects (using AKM) across all person-year observations
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

// Calculate the quntiles of log hours employer effects (using AKM) across all person-year observations
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



// Calculate the quintiles of log earnings employer effects (using AKM) across all person-year observations
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


// Keep if separations occured 2008-2010
gen sep0810 = 1 if (year==2008|year==2009|year==2010) 
keep if sep0810==1 

// Save the data
save "post_akm_data_2002_2014_event.dta", replace


	use "post_akm_data_2002_2014_event.dta", clear
	collapse (mean) logwage_2 logwage_1 logwage0 logwage1 logwage_fe_2 logwage_fe_1 logwage_fe0 logwage_fe1 (count) ///
			preN = logwagefe_xtile_1_N Nobs = logwagefe_xtile0_N (percent) prop = logwagefe_xtile_1_N ///
			if mover==1 & stayer_before==1 & stayer_after==1 , by(pre_logwage_fe_xtile post_logwage_fe_xtile)
			gen delta = logwage1-logwage_2
			gen delta_fe = logwage_fe1-logwage_fe_2
	keep pre_logwage_fe_xtile post_logwage_fe_xtile Nobs delta  delta_fe 
	order pre_logwage_fe_xtile post_logwage_fe_xtile Nobs delta  delta_fe 
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Mover_logw_fe", replace) 

	use "post_akm_data_2002_2014_event.dta", clear
	keep if stayer==1 & stayer_before==1 & stayer_after==1 
	collapse (mean) logwage_2 logwage_1 logwage0 logwage1 logwage_fe_2 logwage_fe_1 logwage_fe0 logwage_fe1 (count) ///
			preN = logwagefe_xtile_1_N postN = logwagefe_xtile0_N  ///
			if pre_logwage_fe_xtile == post_logwage_fe_xtile, by(pre_logwage_fe_xtile post_logwage_fe_xtile)
			gen delta = logwage1-logwage_2
			gen delta_fe = logwage_fe1-logwage_fe_2
	keep pre_logwage_fe_xtile post_logwage_fe_xtile delta 
	order pre_logwage_fe_xtile post_logwage_fe_xtile delta 
    export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Stayer_logw_fe", replace) 
**** In Excel, for each quintile, subtract the average delta log wage for stayers from the delta of movers

	
	use "post_akm_data_2002_2014_event.dta", clear
	collapse (mean) loghours_2 loghours_1 loghours0 loghours1 loghours_fe_2 loghours_fe_1 loghours_fe0 loghours_fe1 (count) /// 
			preN = loghoursfe_xtile_1_N Nobs = loghoursfe_xtile0_N prop = loghoursfe_xtile_1_N  ///	
			if mover==1 & stayer_before==1 & stayer_after==1 , by(pre_loghours_fe_xtile post_loghours_fe_xtile)
			gen delta = loghours1-loghours_2
			gen delta_fe = loghours_fe1-loghours_fe_2
	keep pre_loghours_fe_xtile post_loghours_fe_xtile Nobs delta  delta_fe 
	order pre_loghours_fe_xtile post_loghours_fe_xtile Nobs delta  delta_fe 
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Mover_logh_fe", replace)

	use "post_akm_data_2002_2014_event.dta", clear 
	keep if stayer==1 & stayer_before==1 & stayer_after==1 
	collapse (mean) loghours_2 loghours_1 loghours0 loghours1 loghours_fe_2 loghours_fe_1 loghours_fe0 loghours_fe1 (count) ///
			preN = loghoursfe_xtile_1_N postN = loghoursfe_xtile0_N ///	
			if pre_loghours_fe_xtile == post_loghours_fe_xtile, by(pre_loghours_fe_xtile post_loghours_fe_xtile)
			gen delta = loghours1-loghours_2
			gen delta_fe = loghours_fe1-loghours_fe_2
	keep pre_loghours_fe_xtile post_loghours_fe_xtile delta
	order pre_loghours_fe_xtile post_loghours_fe_xtile delta 
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Stayer_logh_fe", replace)
**** In Excel, for each quintile, subtract the average delta log hours for stayers from the delta of movers

	
	use "post_akm_data_2002_2014_event.dta", clear
	collapse (mean) logearnings_2 logearnings_1 logearnings0 logearnings1 logearnings_fe_2 logearnings_fe_1 logearnings_fe0 logearnings_fe1 (count) ///
			preN = logearningsfe_xtile_1_N Nobs = logearningsfe_xtile0_N prop = logearningsfe_xtile_1_N ///	
			if mover==1 & stayer_before==1 & stayer_after==1 , by(pre_logearnings_fe_xtile post_logearnings_fe_xtile)
			gen delta = logearnings1-logearnings_2
			gen delta_fe = logearnings_fe1-logearnings_fe_2
	keep pre_logearnings_fe_xtile post_logearnings_fe_xtile Nobs delta  delta_fe 
	order pre_logearnings_fe_xtile post_logearnings_fe_xtile Nobs delta  delta_fe 
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Mover_loge_fe", replace)

	use "post_akm_data_2002_2014_event.dta", clear
	keep if stayer==1 & stayer_before==1 & stayer_after==1 
	collapse (mean) logearnings_2 logearnings_1 logearnings0 logearnings1 logearnings_fe_2 logearnings_fe_1 logearnings_fe0 logearnings_fe1 (count) /// 
			preN = logearningsfe_xtile_1_N postN = logearningsfe_xtile0_N ///	
			if pre_logearnings_fe_xtile == post_logearnings_fe_xtile, by(pre_logearnings_fe_xtile post_logearnings_fe_xtile)
			gen delta = logearnings1-logearnings_2
			gen delta_fe = logearnings_fe1-logearnings_fe_2
	keep pre_logearnings_fe_xtile post_logearnings_fe_xtile delta 
	order pre_logearnings_fe_xtile post_logearnings_fe_xtile delta 
	export excel using "Seps0810_Raw.xlsx", firstrow(variables) sheet("Stayer_loge_fe", replace)
**** In Excel, for each quintile, subtract the average delta log earnings for stayers from the delta of movers




// Clean up
erase "post_akm_data_2002_2014_event.dta"


