
set more off, permanently

// ------------------------ 70 percent sample of firms --------------------//
use   "post_akm_data_2002_2014.dta", clear


xtset ssn year
keep ssn year firmid logearnings-logearnings_res

// Drop 30 percent of unique firm IDs (these are the firms in a state we can't observe)
set seed 810227 
gen rv = uniform()

// Randomize by firm id
bysort firmid: replace rv = rv[1]
summarize rv
drop if rv >= 0.70 
summarize rv


// AKM on this smaller sample 
xi: a2reg logearnings i.year 	, individual(ssn) unit(firmid) indeffect(logearnings_pe2) uniteffect(logearnings_fe2) xb(logearnings_xb2) resid(logearnings_res2)
xi: a2reg logwage i.year 		, individual(ssn) unit(firmid) indeffect(logwage_pe2) uniteffect(logwage_fe2) xb(logwage_xb2) resid(logwage_res2)
xi: a2reg loghours i.year 		, individual(ssn) unit(firmid) indeffect(loghours_pe2) uniteffect(loghours_fe2) xb(loghours_xb2) resid(loghours_res2)

binscatter  logearnings_fe2 logearnings_fe, reportreg
graph save Graph "Corr_FE_earnings_70.gph", replace

binscatter  loghours_fe2 loghours_fe, reportreg
graph save Graph "Corr_FE_hours_70.gph", replace

binscatter  logwage_fe2 logwage_fe, reportreg
graph save Graph "Corr_FE_wage_70.gph", replace

*******************
///Figure B5  ///
*******************

graph combine "Corr_FE_earnings_70.gph" "Corr_FE_hours_70.gph" "Corr_FE_wage_70.gph" ,  cols(2) 
graph save Graph "FigureB5.gph", replace
erase "Corr_FE_earnings_70.gph"  
erase "Corr_FE_hours_70.gph"
erase "Corr_FE_wage_70.gph"

corr logearnings_fe2 	logearnings_fe
corr logearnings_pe2 	logearnings_pe
corr logearnings_xb2 	logearnings_xb
corr logearnings_res2 	logearnings_res

corr logwage_fe2 	logwage_fe
corr logwage_pe2 	logwage_pe
corr logwage_xb2 	logwage_xb
corr logwage_res2 	logwage_res

corr loghours_fe2 	loghours_fe
corr loghours_pe2 	loghours_pe
corr loghours_xb2 	loghours_xb
corr loghours_res2 loghours_res



// ------------------------ 50 percent sample of firms --------------------//
use   "post_akm_data_2002_2014.dta", clear

xtset ssn year
keep ssn year firmid logearnings-logearnings_res

* Drop 50 percent of unique firm IDs (these are the firms in a state we can't observe)
set seed 810227 
gen rv = uniform()

* Randomize by firm id
bysort firmid: replace rv = rv[1]
summarize rv
drop if rv >= 0.50 
summarize rv


* Perform AKM on this smaller sample 
xi: a2reg logearnings i.year 	, individual(ssn) unit(firmid) indeffect(logearnings_pe2) uniteffect(logearnings_fe2) xb(logearnings_xb2) resid(logearnings_res2)
xi: a2reg logwage i.year 		, individual(ssn) unit(firmid) indeffect(logwage_pe2) uniteffect(logwage_fe2) xb(logwage_xb2) resid(logwage_res2)
xi: a2reg loghours i.year 		, individual(ssn) unit(firmid) indeffect(loghours_pe2) uniteffect(loghours_fe2) xb(loghours_xb2) resid(loghours_res2)

binscatter  logearnings_fe2 logearnings_fe, reportreg
graph save Graph "Corr_FE_earnings_50.gph", replace

binscatter  loghours_fe2 loghours_fe, reportreg
graph save Graph "Corr_FE_hours_50.gph", replace

binscatter  logwage_fe2 logwage_fe, reportreg
graph save Graph "Corr_FE_wage_50.gph", replace

*******************
///Figure B6  ///
*******************

graph combine "Corr_FE_earnings_50.gph" "Corr_FE_hours_50.gph" "Corr_FE_wage_50.gph" ,  cols(2) 
graph save Graph "FigureB6.gph", replace
erase "Corr_FE_earnings_50.gph"  
erase "Corr_FE_hours_50.gph"
erase "Corr_FE_wage_50.gph"

corr logearnings_fe2 	logearnings_fe
corr logearnings_pe2 	logearnings_pe
corr logearnings_xb2 	logearnings_xb
corr logearnings_res2 	logearnings_res

corr logwage_fe2 	logwage_fe
corr logwage_pe2 	logwage_pe
corr logwage_xb2 	logwage_xb
corr logwage_res2 	logwage_res

corr loghours_fe2 	loghours_fe
corr loghours_pe2 	loghours_pe
corr loghours_xb2 	loghours_xb
corr loghours_res2 loghours_res


