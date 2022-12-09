*********************************************************************************
** DISLOCATED4.DO will take the wages data set for Washington and clean hours  **
** for less than 0.2% of all quarterly wage records.	 					   **
**                                                                             **
** 2016/08/26: Ken Kline                                                       **
** 2019/03/04: Modified to remove Linux path names since core data sets will   **
** reside in the directory in which this file is executed.                     **
*********************************************************************************;
set type float
tempfile wage impute
use wages.dta, clear
sort ssn empid yyyyq
replace hours=. if hours==9999
save `wage'

keep ssn empid yyyyq wages hours
reshape wide wages hours, i(ssn empid) j(yyyyq)
reshape long wages hours, i(ssn empid) j(yyyyq)
sort ssn empid yyyyq

by ssn empid: gen wage_rate=(wages[_n-1]+wages[_n+1])/(hours[_n-1]+hours[_n+1]) if _n > 1 & yyyyq < 20152 & ///
                            (hours==. | hours==0) & hours[_n-1] > 0 & hours[_n-1] !=. & hours[_n+1] > 0 & ///
                            hours[_n+1] !=. & wages > 0 & wages !=. & wages[_n-1] > 0 & wages[_n-1] !=. & ///
                            wages[_n+1] > 0 & wages[_n+1] !=. & empid==empid[_n-1] & empid==empid[_n+1] & empid !=""

gen byte imputed=0
replace imputed=1 if wage_rate !=.
replace hours=wages/wage_rate if imputed==1
keep if imputed==1
label var imputed 
format imputed %1.0f
keep ssn empid yyyyq hours imputed

save `impute'

use `wage', clear
merge 1:1 ssn empid yyyyq using `impute', update replace
  keep if _merge==1 | _merge >= 3
  drop _merge
replace imputed=0 if imputed==.
sort ssn yyyyq empid
save earn_hrs_wages.dta, replace

