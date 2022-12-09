****************************************************************************************
** DISLOCATED8.DO (formerly DISLOCATED5.DO) will take workers employed between 2002   **
** and 2007 but will not restrict the data set to only those with 24 consecutive      **
** quarters with the major employer.  It will allow shorter consecutive quarters of   **
** tenure and preserve that variable so that restriction can be reapplied if needed.  **
**                                                                                    **
** 2017/04/17: Ken Kline                                                              **
** 2019/03/04: Modified to remove Linux path names since core data sets will reside   **
** in the directory in which this file is executed.                                   **
****************************************************************************************;
set type float
tempfile wage cpi
****************************************************************************************
** Bring in CPI data.  I downloaded the CPI for all urban consumers for both the U.S. **
** city average and the Northwest city average.  I did not see much difference so I   **
** will use the U.S. city average.                                                    **
****************************************************************************************;
forvalues j=1/2 {
  tempfile temp`j'
  use cpiu`j'.dta, clear
  keep if substr(mm,1,1)=="M" & substr(mm,2,2) != "13"
  replace mm=substr(mm,2,2)
  destring mm, force replace
  gen yyyymm=100*yyyy+mm
  drop mm yyyy
  sort yyyymm
  save `temp`j''
}

** Data are monthly so I will convert to quarterly **;
use `temp1', clear
merge 1:1 yyyymm using `temp2'
  keep if _merge==3
  drop _merge
sort yyyymm
gen byte mm=yyyymm-100*int(yyyymm/100)
gen byte q=1 if mm >= 1 &mm <= 3
replace q=2 if mm >= 4 & mm <= 6
replace q=3 if mm >= 7 & mm <= 9
replace q=4 if mm >= 10 & mm <= 12
gen long yyyyq=10*int(yyyymm/100)+q
keep yyyyq cpiu1 cpiu2

forvalues j=1/2 {
  statsby cpiu`j'=r(mean), by (yyyyq) saving (`temp`j'', replace): summarize cpiu`j'
}
use `temp1', clear
merge 1:1 yyyyq using `temp2'
  drop _merge
sort yyyyq
label var yyyyq "Year and quarter"
label var cpiu1 "CPI Urban, U.S. city average"
label var cpiu2 "CPI Urban, Northwest city average"
format cpiu1 cpiu2 %8.4f
save `cpi', replace

** Will need to re-index to 2010 = 1 **;
keep if int(yyyyq/10)==2010
forvalues j=1/2 {
  quietly summarize cpiu`j'
  local cpiu`j'_2010=r(mean)
}
use `cpi', clear
replace cpiu1=cpiu1/`cpiu1_2010'
replace cpiu2=cpiu2/`cpiu2_2010'
sort yyyyq
save `cpi', replace

**************************************************************************************
** We are going to need maximum employer size between 2007 (formerly 2006) and 2006 **
** (formerly 2005) later in the program.  However, if at any point in 2002-2007     **
** formerly (2001-2006) the firm size is less than 50, drop that firm.              **
**************************************************************************************;
tempfile maxsize
use empid yyyyq wages hours using earn_hrs_wages.dta
keep if yyyyq >= 20021 & yyyyq <= 20074 & ((wages > 0 & wages !=.) | (hours > 0 & hours !=.))
keep empid yyyyq
sort empid yyyyq
by empid yyyyq: gen n=_n
by empid yyyyq: egen max_size=max(n)
gen byte flag50=0
replace flag50=1 if max_size < 50
by empid: egen maxflag=max(flag50)
drop if maxflag==1
keep if yyyyq >= 20061 & yyyyq <= 20074
drop n flag50 maxflag
save `maxsize'

forvalues y=2006/2007 {
  tempfile temp`y'
  use `maxsize'
  keep if int(yyyyq/10)==`y'
  gsort empid -max_size
  by empid: gen n=_n
  keep if n==1
  rename yyyyq yyyyq_max_`y'
  rename max_size max_size_`y'
  keep empid max_size_`y' yyyyq_max_`y'
  sort empid
  save `temp`y''
}

****************************************************************************************
** At this point, a firm may not be in both years.  Since things will be conditional  **
** on individuals working for the same primary employer in all quarters 2002Q1-2007Q4 **
** you can take only the firms that are in both.                                      **
****************************************************************************************;
use `temp2006'
merge 1:1 empid using `temp2007'
  keep if _merge==3
  drop _merge
sort empid
order empid max_size* yyyyq_max*
save `maxsize', replace


*******************************************************************************
** For each firm in the data, define whether a mass-layoff occurred which is **
** when employment at the firm falls to 70 percent or less of max-size.       **
*******************************************************************************;
use empid yyyyq wages hours using earn_hrs_wages.dta, clear
keep if (wages > 0 & wages !=.) | (hours > 0 & hours !=.)
drop if yyyyq >= 20151 | yyyyq <= 20014
sort empid yyyyq
by empid yyyyq: gen n=_n
by empid yyyyq: egen employment=max(n)
keep if n==1
keep empid yyyyq employment
label var employment "Employment at the firm in quarter"
format employment %5.0f

merge m:1 empid using `maxsize'
  keep if _merge==3
  drop _merge

save `maxsize', replace

***************************************************************************************
** Track when the employment level falls to 70 percent or lower of the maximum size  **
** in 2007 provided the 2006 maximum size is 130 percent or less of the 2007 value.  **
***************************************************************************************;
tempfile masslayoff
gen byte flag=0
replace flag=1 if employment <= 0.7*max_size_2007 & max_size_2006/max_size_2007 <= 1.3
keep if flag==1
keep empid yyyyq yyyyq_max_2007
sort empid yyyyq
save `masslayoff'


tempfile before after
keep if yyyyq <= 20074 & yyyyq < yyyyq_max_2007
gsort empid -yyyyq
by empid: gen n=_n
keep if n==1
drop n yyyyq_max_2007
rename yyyyq yyyyq_mass_layoff1
save `before'
tab1 yyyyq_mass_layoff1

use `masslayoff', clear
keep if yyyyq > 20074
sort empid yyyyq
by empid: gen n=_n
keep if n==1
drop n
rename yyyyq yyyyq_mass_layoff2
save `after'
tab1 yyyyq_mass_layoff2

merge 1:1 empid using `before'
  drop _merge
sort empid
label var yyyyq_mass_layoff1 "YYYY:Q of mass-layoff on/or before 2007Q4"
label var yyyyq_mass_layoff2 "YYYY:Q of mass-layoff after 2007Q4"
format yyyyq_mass_layoff1 yyyyq_mass_layoff2 %5.0f
save `masslayoff', replace

use `maxsize', clear
sort empid yyyyq
by empid: gen n=_n
keep if n==1
drop n yyyyq employment


merge 1:1 empid using `masslayoff'
  keep if _merge==1 | _merge==3
  drop _merge

sort empid
order empid yyyyq_mass_layoff1 yyyyq_mass_layoff2

** Calculate quarters from maximum size to the mass layoff **;
gen byte qmax=yyyyq_max_2007-10*int(yyyyq_max_2007/10) if yyyyq_max_2007 !=.
gen byte qmass=yyyyq_mass_layoff2-10*int(yyyyq_mass_layoff2/10) if yyyyq_mass_layoff2 !=.
gen byte yrs_between=int(yyyyq_mass_layoff2/10)-int(yyyyq_max_2007/10)-1
gen byte qtrs_max_to_mass=(4-qmax)+(4*yrs_between)+qmass
drop qmax qmass yrs_between
label var qtrs_max_to_mass "Number of quarters from max employment to mass-layoff"
format qtrs_max_to_mass %2.0f
save `maxsize', replace


** Calculate earnings and hours across all employers and deflate earnings **;
use earn_hrs_wages.dta, clear
drop imputed random
keep if (wages > 0 & wages !=.) | (hours > 0 & hours !=.)
drop if yyyyq >= 20151 | yyyyq <= 20014
by ssn yyyyq: gen n=_n
by ssn yyyyq: egen int nemp=max(n)
by ssn yyyyq: egen all_earnings=total(wages)
by ssn yyyyq: egen int all_hours=total(hours)

format nemp %2.0f
format all_earnings %12.2f
format all_hours %4.0f
drop n

sort yyyyq
save `wage', replace
merge m:1 yyyyq using `cpi'
  keep if _merge==1 | _merge==3
  drop _merge
  replace wages=wages/cpiu1
  replace all_earnings=all_earnings/cpiu1
  drop cpiu1 cpiu2

** Sort to obtain the primary employer in each quarter **;  
gsort ssn yyyyq -wages
by ssn yyyyq: gen n=_n
keep if n==1
gen prim_earnings=wages
gen prim_hours=hours
drop if (all_hours==0 & all_earnings==0) | (all_hours==. & all_earnings==.)

label var empid "Employer ID of primary employer"
label var naics "NAICS code of primary employer"
label var nemp "Number of employers in quarter"
label var all_hours "Hours from all employers"
label var all_earnings "Earnings from all employers (2010 $)"
label var prim_hours "Hours from primary employer"
label var prim_earnings "Earnings from primary employer (2010 $)"
format all_earnings prim_earnings %12.2f
drop wages hours n

sort ssn empid yyyyq
save `wage', replace

*******************************************************************************************
** Define tenure with "primary" employer where in this case it will be the employer that **
** is closest to the 2007Q4 cut-off after which we look for separation and dislocation.  **
** I will impose the requirement that the person be employed in each quarter of 2007.    **
*******************************************************************************************;
tempfile list
keep if yyyyq >= 20021 & yyyyq <= 20074
keep ssn empid yyyyq prim_earnings
******************************************************************************************
** Create dummy variables for whether employed in each year, 2002-2006 (the requirement **
** of all quarters of employment in 2007 makes a dummy for 2007 unnecessary.            **
******************************************************************************************;
forvalues yr=2002/2006 {
  gen byte employed_`yr'=0
  replace employed_`yr'=1 if prim_earnings !=. & prim_earnings > 0 & yyyyq >= `yr'1 & yyyyq <= `yr'4
  by ssn: egen xemployed_`yr'=max(employed_`yr')
  drop employed_`yr'
  rename xemployed_`yr' employed_`yr'
  label var employed_`yr' "Employed in `yr'"
  format employed_`yr' %1.0f
}
drop prim_earnings
sort ssn empid yyyyq
save `list'

keep if yyyyq >= 20071 & yyyyq <= 20074
by ssn empid: gen n=_n
by ssn empid: egen maxn=max(n)
keep if maxn==4
keep ssn
by ssn: gen n=_n
keep if n==1
drop n

merge 1:m ssn using `list'
  keep if _merge==3
  drop _merge
sort ssn empid yyyyq
save `list', replace

gen long yyyy=int(yyyyq/10)
gen q=yyyyq-10*yyyy
by ssn empid: gen nconsec=1 if _n==1
by ssn empid: replace nconsec=nconsec[_n-1]+1 if _n > 1 & nconsec==. & nconsec[_n-1] !=. & ((yyyy==yyyy[_n-1] & q-q[_n-1]==1) | ///
                                                                                            (yyyy-yyyy[_n-1]==1 & q==1 & q[_n-1]==4)) 
save `list', replace
tab1 nconsec


tempfile temp
forvalues j=1/15 {
  use `list', clear
  keep if nconsec==.
  count
  if r(N) > 0 {
    sort ssn empid yyyyq
    by ssn empid: replace nconsec=1 if _n==1
    by ssn empid: replace nconsec=nconsec[_n-1]+1 if _n > 1 & nconsec==. & nconsec[_n-1] !=. & ((yyyy==yyyy[_n-1] & q-q[_n-1]==1) | ///
                                                                                            (yyyy-yyyy[_n-1]==1 & q==1 & q[_n-1]==4)) 
    keep ssn empid yyyyq nconsec
    save `temp', replace


    use `list', clear
    merge 1:1 ssn empid yyyyq using `temp', update replace
      keep if _merge==1 | _merge >= 3
      drop _merge
    sort ssn empid yyyyq
    save `list', replace
  }
}
use `list', clear
sort ssn empid yyyyq
by ssn: gen n=_n
by ssn: egen employed_qtrs=max(n)
by ssn empid: egen tenure1=max(nconsec)
by ssn: egen tenure2=max(nconsec)
drop n nconsec q yyyy
save `list', replace

keep ssn empid yyyyq
sort ssn empid yyyyq
by ssn empid: gen n=_n
keep if n==1
drop n
by ssn: gen n=_n
by ssn: egen nemployers=max(n)
keep if n==1
keep ssn nemployers

merge 1:m ssn using `list'
  drop _merge
sort ssn yyyyq
save `list', replace

** Keep the 2007 value for TENURE1 and overwrite **;
tempfile temp2007
keep ssn yyyyq tenure1
keep if yyyyq==20074
drop yyyyq
save `temp2007'

use `list', clear
merge m:1 ssn using `temp2007', update replace
  keep if _merge >= 3
  drop _merge

sort empid

***************************************************************************************
** For the employers regardless of number of consecutive quarters employed with that **
** employer during the period, merge in their maximum size value during 2006-2007    **
***************************************************************************************;
merge m:1 empid using `maxsize'
  keep if _merge==1 | _merge==3
  drop empid

sort ssn yyyyq
save `list', replace


****************************************************************************************
** !! In the above merge, when merge=1, it means it was dropped out of the maxsize !! **
** !! data because the firm employment dropped below 50 at some point 2002-07.     !! **
** !! So keep those povided the individual is employed in 2007                     !! **
****************************************************************************************;
tempfile merge3
keep if _merge==3 & int(yyyyq/10)==2007
keep ssn
by ssn: gen n=_n
keep if n==1
drop n
save `merge3'

use `list', clear
drop _merge

merge m:1 ssn using `merge3'
  keep if _merge==3
  drop _merge

sort ssn yyyyq
save `list', replace

use `wage', clear
merge m:1 ssn using `merge3'
  keep if _merge==3
  drop _merge

sort ssn yyyyq

merge 1:1 ssn yyyyq using `list'
  keep if _merge==1 | _merge==3
  drop _merge

sort ssn yyyyq
save `wage', replace

***************************************************************************************
** An added constraint is that all workers have at least one quarter of wages in all **
** years going forward (beginning 2008Q1, formerly 2007Q1)                           **
***************************************************************************************;
use ssn using `list'
by ssn: gen n=_n
keep if n==1
drop n
save `list', replace

tempfile wage2
use ssn yyyyq all_earnings all_hours using `wage', clear
keep if yyyyq >= 20081 & ((all_earnings > 0 & all_earnings !=.) | (all_hours > 0 & all_hours !=.))
gen long yyyy=int(yyyyq/10)
drop yyyyq
sort ssn yyyy
by ssn yyyy: egen hours=total(all_hours)
by ssn yyyy: egen earnings=total(all_earnings)
by ssn yyyy: gen n=_n
keep if n==1
drop n
save `wage2'

forvalues y=2008/2014 {
  use `wage2', clear
  keep if yyyy==`y'
  merge 1:1 ssn using `list'
    keep if _merge==2
  keep ssn
  tempfile drop`y'
  save `drop`y''
}

use `drop2008', clear
forvalues y=2009/2014 {
  append using `drop`y''
}
sort ssn
by ssn: gen n=_n
keep if n==1
drop n
save `list', replace

use `wage', clear
merge m:1 ssn using `list'
  drop if _merge==3
  drop _merge

sort ssn yyyyq
#delimit ;
  local maxlist "employed_2002 employed_2003 employed_2004 employed_2005 employed_2006 employed_qtrs
                 nemployers tenure1 tenure2 qtrs_max_to_mass";
#delimit cr

foreach v of local maxlist {
  by ssn: egen byte x`v'=max(`v')
  drop `v'
  rename x`v' `v'
}
save `wage', replace

*******************************************************************************
** Prior to 2007Q4, the following variables can vary across individuals that **
** worked for more than one employer in the 2002-2007 period.  Carry the     **
** values associated with the 2007 employer forward.                         **
*******************************************************************************;
tempfile max
keep if max_size_2006 !=. & max_size_2007 !=. & yyyyq==20074
keep ssn max_size_2006 max_size_2007 yyyyq_max_2006 yyyyq_max_2007
local list "max_size_2006 max_size_2007 yyyyq_max_2006 yyyyq_max_2007"
foreach v of local list {
  rename `v' x`v'
}
save `max'

use `wage', clear

merge m:1 ssn using `max'
  foreach v of local list {
    replace `v'=x`v' if _merge==3 & yyyyq > 20074 & `v'==.
    drop x`v'
  }
drop _merge
sort ssn yyyyq

forvalues yr=2006/2007 {
  label var max_size_`yr' "Maximum employment, `yr'"
  label var yyyyq_max_`yr' "YYYY:Q of max employent in `yr'"
  format max_size_`yr' yyyyq_max_`yr' %5.0f
}
forvalues yr=2002/2006 {
  label var employed_`yr' "Employed in `yr'"
  format employed_`yr' %1.0f
}
label var employed_qtrs "Quarters employed, 2002Q1-2007Q4"
label var nemployers "Number of employers, 2002Q1-2007Q4"
label var tenure1 "Max consec qtrs employed, 2007 employer"
label var tenure2 "Max consec qtrs employed, all Emp IDs, 2001Q1-2007Q4"
label var qtrs_max_to_mass "Number of quarters from max employment to mass-layoff"

format employed_qtrs nemployers tenure1 tenure2 qtrs_max_to_mass %2.0f
save `wage', replace

*************************************************************************************
** Do same for year and quarter of mass layoff variables as an individual can have **
** multiple employers 2002-2007 that experienced mass layoffs.  Make sure to grab  **
** the 2007 employer.                                                              **
*************************************************************************************;
tempfile temp
local list "yyyyq_mass_layoff1 yyyyq_mass_layoff2"
foreach v of local list {
  use ssn yyyyq `v' using `wage', clear
  keep if `v' !=. & yyyyq==20074
  drop yyyyq
  rename `v' x`v'
  save `temp', replace

  use `wage', clear
  merge m:1 ssn using `temp'
  replace `v'=x`v' if _merge==3 & yyyyq > 20074 & `v'==.
    drop x`v'
  }
drop _merge
sort ssn yyyyq
label var yyyyq_mass_layoff1 "YYYY:Q of mass-layoff on/or before 2007Q4"
label var yyyyq_mass_layoff2 "YYYY:Q of mass-layoff after 2007Q4"
format yyyyq_mass_layoff1 yyyyq_mass_layoff2 %5.0f
save `wage', replace



tempfile sep
gen byte q=yyyyq-10*int(yyyyq/10)
gen long yyyy=int(yyyyq/10)
gen long yyyyq_separation=.
by ssn: replace yyyyq_separation=yyyyq[_n-1] if _n > 1 & yyyyq > 20074 & (empid != empid[_n-1] | ///
                                                 ((yyyyq-yyyyq[_n-1] > 1 & q != 1) | ///
                                                 (q==1 & (yyyyq-yyyyq[_n-1] > 1 & yyyyq[_n-1]-10*int(yyyyq[_n-1]/10) != 4))))
keep if yyyyq_separation !=.
keep ssn yyyyq_separation
sort ssn yyyyq_separation
by ssn: gen n=_n
keep if n==1
drop n
label var yyyyq_separation "YYYY:Q of separation"
format yyyyq_separation %5.0f
save `sep'

use `wage', clear
merge m:1 ssn using `sep'
  keep if _merge==1 | _merge==3
  drop _merge
sort ssn yyyyq
gen byte separation=0
gen byte mass_layoff1=0
gen byte mass_layoff2=0
gen byte dislocated=0
gen long yyyy_sep=int(yyyyq_separation/10)
gen long yyyy_mass=int(yyyyq_mass_layoff2/10)
gen byte q_sep=yyyyq_separation-10*yyyy_sep
gen byte q_mass=yyyyq_mass_layoff2-10*yyyy_mass

replace separation=1 if yyyyq==yyyyq_separation
replace mass_layoff1=1 if yyyyq==yyyyq_mass_layoff1
replace mass_layoff2=1 if yyyyq==yyyyq_mass_layoff2
replace dislocated=1 if yyyyq==yyyyq_separation & yyyyq_mass_layoff2 !=. & (yyyyq_mass_layoff2==yyyyq_separation | ///
                  ((yyyyq_separation > yyyyq_mass_layoff2 & (yyyy_sep-yyyy_mass==1 & (4-q_mass+q_sep <= 4))) | ///
                   (yyyyq_mass_layoff2 > yyyyq_separation & (yyyy_mass-yyyy_sep==1 & (4-q_sep+q_mass <= 4)))))  
drop yyyy_sep yyyy_mass q_sep q_mass                     
label var separation "Separation occurred, 1=yes, 0=no"
label var mass_layoff1 "70 pct threshold met, 2007Q4 or earlier, 1=yes, 0=no"
label var mass_layoff2 "Mass lay-off occurred, 2008Q1 or later, 1=yes, 0=no"
label var dislocated "Dislocated worker, 1=yes, 0=no"
format separation mass_layoff1 mass_layoff2 dislocated %1.0f


sort ssn yyyyq
save `wage', replace

*******************************************************************************************
** Right now the dislocated variable is set to one in the quarter of separation provided **
** that separation occurrs +/- 4 quarters from the mass-layoff.  I will change that to   **
** the quarter of the mass-layoff.                                                       **
*******************************************************************************************;
tempfile dislocated
keep if dislocated==1
keep ssn yyyyq
save `dislocated'

use `wage', clear
merge 1:1 ssn yyyyq using `dislocated'
  keep if _merge==1 | _merge==3
  replace dislocated=0 if dislocated==1 & _merge==3
  drop _merge

sort ssn yyyyq
save `wage', replace

use `dislocated', clear
keep ssn
save `dislocated', replace

use `wage', clear
merge m:1 ssn using `dislocated'
  keep if _merge==1 | _merge==3
  replace dislocated=1 if _merge==3 & yyyyq==yyyyq_mass_layoff2
  drop _merge

sort ssn empid yyyyq
save `wage', replace

*****************************************************************************************
** Create a flag for persons who were not dislocated that worked for the same primary  **
** employer for all quarters 2008Q1-2014Q4 (28 quarters) that is the same as the       **
** pre-2008Q1 employer (2007 employer).                                                **
*****************************************************************************************;
tempfile empid_2007
use ssn yyyyq empid using `wage', clear
keep if yyyyq==20074
drop yyyyq
rename empid empid_2007
sort ssn
save `empid_2007'

use `wage', clear
merge m:1 ssn using `empid_2007'
  keep if _merge==3
  drop _merge
sort ssn yyyyq
save `wage', replace

tempfile nondislocated
keep if dislocated==0
keep ssn
sort ssn
by ssn: gen n=_n
keep if n==1
drop n
merge 1:m ssn using `wage'
  keep if _merge==3
  drop _merge
sort ssn empid yyyyq
save `nondislocated'

keep ssn empid yyyyq empid_2007
keep if yyyyq >= 20081
by ssn empid: gen n=_n
by ssn empid: egen maxn=max(n)
keep if n==1 & maxn==28 & empid==empid_2007
keep ssn empid
save `nondislocated', replace

use `wage', clear
merge m:1 ssn empid using `nondislocated'
  keep if _merge==1 | _merge==3
  gen byte flag_nondis=0
  replace flag_nondis=1 if _merge==3 & yyyyq==20074
  drop _merge

label var flag_nondis "Same primary employer, 2008Q1-2014Q4, not dislocated"
format flag_nondis %1.0f
sort empid yyyyq
save `wage', replace

*****************************************************************************************
** At this point because of modifications above related to using max firm size in 2007 **
** and 2006 and not a continuous series, the firm size variable is not in the data.  I **
** will add.                                                                           **
*****************************************************************************************;
tempfile list
use earn_hrs_wages.dta, clear
keep if (wages > 0 & wages !=.) | (hours > 0 & hours !=.)
drop if yyyyq >= 20151 | yyyyq <= 20014
sort empid yyyyq
by empid yyyyq: gen n=_n
by empid yyyyq: egen firmsize=max(n)
keep if n==1
label var firmsize "Firm size"
format firmsize %5.0f
keep empid yyyyq firmsize
save `list'

use `wage', clear
merge m:1 empid yyyyq using `list'
  keep if _merge==1 | _merge==3
  drop _merge
sort ssn yyyyq empid
#delimit ;
  order ssn yyyyq empid employed_qtrs nemployers tenure1 tenure2 mass_layoff1 mass_layoff2 
        separation dislocated flag_nondis yyyyq_mass_layoff1 yyyyq_mass_layoff2;
#delimit cr

#delimit ;
  local varlist "empid empid_2007 employed_qtrs nemployers tenure1 tenure2 mass_layoff1 mass_layoff2 separation
                 dislocated flag_nondis naics nemp all_earnings all_hours prim_earnings prim_hours prim_imputed 
                 other_imputed firmsize yyyyq_mass_layoff1 yyyyq_mass_layoff2 yyyyq_separation max_size_2006 
                 max_size_2007 yyyyq_max_2006 yyyyq_max_2007 qtrs_max_to_mass employed_2002 employed_2003
                 employed_2004 employed_2005 employed_2006";
#delimit cr
gen byte prim_imputed=0
gen byte other_imputed=0
format prim_imputed other_imputed %1.0f
save `wage', replace

*********************************************************************************
** Merge in whether the hours were imputed.  Since EMPID at this point is for  **
** the primary employer, given that people can have multiple employers in a    **
** quarter, I will also have to flag whether hours from a non-primary employer **
** were imputed.                                                               **
*********************************************************************************;
tempfile imputed list
use ssn yyyyq empid imputed using earn_hrs_wages.dta, clear
sort ssn yyyyq empid
keep if imputed==1
by ssn yyyyq: egen total_imputed=total(imputed)
save `imputed'

use `wage', clear
merge 1:1 ssn yyyyq empid using `imputed'
  keep if _merge==1 | _merge==3
  replace prim_imputed=1 if _merge==3 & imputed==1
  replace other_imputed=1 if _merge==3 & imputed==1 & total_imputed >= 2
sort ssn yyyyq
drop imputed total_imputed
save `wage', replace

tempfile list
keep if _merge==3
keep ssn yyyyq empid
sort ssn yyyyq empid
save `list'

use `wage', clear
drop _merge
save `wage', replace

use `imputed', clear
merge 1:1 ssn yyyyq empid using `list'
  drop if _merge==3
  drop _merge
sort ssn yyyyq
by ssn yyyyq: gen n=_n
keep if n==1
drop n
save `imputed', replace

use `wage', clear
merge 1:1 ssn yyyyq using `imputed'
  keep if _merge==1 | _merge==3
  replace other_imputed=1 if _merge==3 & other_imputed==0 & total_imputed >= 1
  drop imputed total_imputed _merge
sort ssn yyyyq
save `wage', replace

reshape wide `varlist', i(ssn) j(yyyyq)
reshape long `varlist', i(ssn) j(yyyyq)

replace all_earnings=0 if all_earnings==.
replace all_hours=0 if all_hours==.
replace prim_earnings=0 if prim_earnings==.
replace prim_hours=0 if prim_hours==.

*****************************************************************************************
** Define number of quarters since dislocation where the quarter of dislocation is t=0 **
** Also, define the number of quarters
*****************************************************************************************;
by ssn: gen n=_n
save `wage', replace

tempfile qtrssince
keep if dislocated==1
keep ssn n
rename n ndislocated
save `qtrssince'

use `wage', clear
merge m:1 ssn using `qtrssince'
  keep if _merge==1 | _merge==3
  gen byte qtrs_since_dislocation=n-ndislocated if _merge==3
  drop _merge ndislocated

gen prim_wage=prim_earnings/prim_hours
label var prim_wage "Hourly wage rate, primary employer"
label var qtrs_since_dislocation "Number of quarters since dislocation"
format qtrs_since_dislocation %2.0f
format prim_wage %7.2f

sort ssn yyyyq
save `wage', replace

************************************************************
** Define the same variable for quarters since separation **
************************************************************;
keep if separation==1
keep ssn n
rename n nseparation
save `qtrssince', replace

use `wage', clear
merge m:1 ssn using `qtrssince'
  keep if _merge==1 | _merge==3
  gen byte qtrs_since_separation=n-nseparation if _merge==3
  drop _merge nseparation n
label var qtrs_since_separation "Number of quarters since separation"
format qtrs_since_separation %2.0f
sort ssn yyyyq

save `wage', replace

***********************************************************************************
** Set the dislocated variable to 1 for all observations as well as the flag for **
** persons employed all 28 quarters (2008Q1-2014Q4) for the same primary emp.    **
***********************************************************************************;
by ssn: egen xdislocated=max(dislocated)
by ssn: egen xflag=max(flag_nondis)
drop dislocated flag_nondis
rename xdislocated dislocated
rename xflag flag_nondis
label var dislocated "Dislocated worker"
label var flag_nondis "Same primary employer, 2008Q1-2014Q4, not dislocated"
format dislocated flag_nondis %1.0f
rename empid firmid
rename empid_2007 firmid_2007
save `wage', replace

******************************************
** Bring in UI data (regular UI claims) **
******************************************;
tempfile ui
use claimant_info.dta, clear
keep if program==0

gsort ssn edc -amount_paid
by ssn edc: gen n=_n
keep if n==1
drop n program
save `ui'


tempfile missingday validday
keep if birth_date==.
sort ssn edc
by ssn: gen n=_n
levelsof n, local (nlist)
save `missingday'

use `ui'
keep if birth_date !=.
rename edc edc2
drop age wba mbp amount_paid balance base_wba base_mbp
sort ssn edc2
save `validday'

local i=0
foreach n of local nlist {
  use `missingday', clear
  keep if n==`n'
  drop n
  merge 1:m ssn using `validday', update replace
    keep if _merge >= 3
    gen int diff=abs(edc-edc2)
    drop _merge

  quietly count
  local ncount=r(N)
  if `ncount' > 0 {
    local i=`i'+1
    tempfile temp`i'
    sort ssn diff
    by ssn: gen n=_n
    keep if n==1
    drop n edc2 diff
    save  `temp`i''
  }

}
use `temp1', clear
forvalues j=2/`i' {
  append using `temp`j''
}
replace age=int((edc-birth_date)/365.25)
sort ssn edc
save `temp1', replace

use `ui', clear
merge 1:1 ssn edc using `temp1', update replace
  keep if _merge==1 | _merge >= 3
  drop _merge

sort ssn edc
save `ui', replace

*********************************************************************************
** Among the records with non-missing birth dates, 521 have different dates of **
** birth.  I will choose the one associated with the most recent ui claim.     **
*********************************************************************************;
drop if birth_date==.
keep ssn edc birth_date
sort ssn birth_date
by ssn birth_date: gen n=_n
by ssn birth_date: egen maxn=max(n)
keep if maxn > 1
drop n maxn
gsort ssn -edc
by ssn: gen n=_n
keep if n==1
keep ssn birth_date
save `temp1', replace

use `ui', clear
merge m:1 ssn using `temp1', update replace
  keep if _merge==1 | _merge >= 3
  replace age=int((edc-birth_date)/365.25)
  drop _merge

sort ssn edc
save `ui', replace

********************************************************************************************
** There are a handful of persons who have multiple UI claims in the same quarter.  The   **
** pattern is that one involves receipt of UI benefits and the second has the same WBA    **
** but a benefits paid amount of zero.  I will choose the one associated with the highest **
** benefit payment amount.                                                                **
********************************************************************************************;
gen yyyyq=10*year(edc)+quarter(edc)
gsort ssn yyyyq -amount_paid
by ssn yyyyq: gen n=_n
keep if n==1
drop n
save `ui', replace

tempfile characteristics
drop edc wba mbp amount_paid balance age base_wba base_mbp
sort ssn yyyyq
by ssn: gen n=_n
by ssn: egen maxn=max(n)
levelsof n, local (nlist)
by ssn: gen yyyyq_prior=yyyyq[_n-1] if _n > 1
gen yyyyq_current=yyyyq
drop yyyyq

forvalues j=1/8 {
  rename educ`j' xeduc`j'
  if `j' <= 6 {
    rename race`j' xrace`j'
    if `j' <= 5 {
      rename veteran`j' xveteran`j'
      if `j' <= 3 {
        rename disabled`j' xdisabled`j'
      }
    }
  }
}
rename male xmale
rename female xfemale
rename birth_date xbirth_date
save `characteristics'

use `wage', clear
merge 1:1 ssn yyyyq using `ui'
  keep if _merge==1 | _merge==3
  gen byte ui_claimant1=0
  gen byte ui_claimant2=0
  replace ui_claimant1=1 if _merge==3
  replace ui_claimant2=1 if _merge==3
  drop _merge

sort ssn yyyyq
by ssn: egen xui_claimant1=max(ui_claimant1)
drop ui_claimant1
rename xui_claimant1 ui_claimant1
label var ui_claimant1 "UI applicant, 1=any time, 0=no"
label var ui_claimant2 "UI applicant, 1=YYYYQ specific, 0=no"
format ui_claimant1 ui_claimant2 %1.0f
save `wage', replace

***************************************************************************************
** Now update characteristics for SSN-YYYYQ periods where there was not a UI claim.  **
** For persons with multiple UI claims over time, use the characteristics applicable **
** from the prior claim up until the new claim and so on over time.                  **
***************************************************************************************;
foreach n of local nlist {
  tempfile char`n'
  use `characteristics', clear
  keep if n==`n'
  drop n
  save `char`n''

  use `wage'
  merge m:1 ssn using `char`n''
    keep if _merge==1 | _merge==3
  
  if `n'==1 {
    forvalues j=1/8 {
      replace educ`j'=xeduc`j' if _merge==3 & yyyyq < yyyyq_current
      if `j' <= 6 {
        replace race`j'=xrace`j' if _merge==3 & yyyyq < yyyyq_current
        if `j' <= 5 {
          replace veteran`j'=xveteran`j' if _merge==3 & yyyyq < yyyyq_current
          if `j' <= 3 {
            replace disabled`j'=xdisabled`j' if _merge==3 & yyyyq < yyyyq_current
          }
        }
      }
    }
    replace male=xmale if _merge==3 & yyyyq < yyyyq_current
    replace female=xfemale if _merge==3 & yyyyq < yyyyq_current
    replace birth_date=xbirth_date if _merge==3 & yyyyq < yyyyq_current

    ** If the person had only one UI claim, assume it applies throughout the entire period **;
    forvalues j=1/8 {
      replace educ`j'=xeduc`j' if _merge==3 & `n'==maxn & yyyyq > yyyyq_current
      if `j' <= 6 {
        replace race`j'=xrace`j' if _merge==3 & `n'==maxn & yyyyq > yyyyq_current
        if `j' <= 5 {
          replace veteran`j'=xveteran`j' if _merge==3 & `n'==maxn & yyyyq > yyyyq_current
          if `j' <= 3 {
            replace disabled`j'=xdisabled`j' if _merge==3 & `n'==maxn & yyyyq > yyyyq_current
          }
        }
      }
    }
    replace male=xmale if _merge==3 & `n'==maxn & yyyyq > yyyyq_current
    replace female=xfemale if _merge==3 & `n'==maxn & yyyyq > yyyyq_current
    replace birth_date=xbirth_date if _merge==3 & `n'==maxn & yyyyq > yyyyq_current
  }
  else {
    forvalues j=1/8 {
      replace educ`j'=xeduc`j' if _merge==3 & yyyyq < yyyyq_current & yyyyq > yyyyq_prior
      if `j' <= 6 {
        replace race`j'=xrace`j' if _merge==3 & yyyyq < yyyyq_current & yyyyq > yyyyq_prior
        if `j' <= 5 {
          replace veteran`j'=xveteran`j' if _merge==3 & yyyyq < yyyyq_current & yyyyq > yyyyq_prior
          if `j' <= 3 {
            replace disabled`j'=xdisabled`j' if _merge==3 & yyyyq < yyyyq_current & yyyyq > yyyyq_prior
          }
        }
      }
    } 
    replace male=xmale if _merge==3 & yyyyq < yyyyq_current & yyyyq > yyyyq_prior
    replace female=xfemale if _merge==3 & yyyyq < yyyyq_current & yyyyq > yyyyq_prior
    replace birth_date=xbirth_date if _merge==3 & yyyyq < yyyyq_current & yyyyq > yyyyq_prior

    ** There will be YYYYQ observations after the most recent UI claim.  Update **;
    forvalues j=1/8 {
      replace educ`j'=xeduc`j' if _merge==3 & yyyyq > yyyyq_current & `n'==maxn
      if `j' <= 6 {
        replace race`j'=xrace`j' if _merge==3 & yyyyq > yyyyq_current & `n'==maxn
        if `j' <= 5 {
          replace veteran`j'=xveteran`j' if _merge==3 & yyyyq > yyyyq_current & `n'==maxn
          if `j' <= 3 {
            replace disabled`j'=xdisabled`j' if _merge==3 & yyyyq > yyyyq_current & `n'==maxn
          }
        }
      }
    } 
    replace male=xmale if _merge==3 & yyyyq > yyyyq_current & `n'==maxn
    replace female=xfemale if _merge==3 & yyyyq > yyyyq_current & `n'==maxn
    replace birth_date=xbirth_date if _merge==3 & yyyyq > yyyyq_current & `n'==maxn
  } 
  drop x* yyyyq_current yyyyq_prior maxn _merge
  save `wage', replace
}
gen byte q=yyyyq-10*int(yyyyq/10)
gen byte mm=1 if q==1
replace mm=4 if q==2
replace mm=7 if q==3
replace mm=10 if q==4

replace age=int((mdy(mm,1,int(yyyyq/10))-birth_date)/365.25) if age==.
drop mm q base_wba base_mbp
#delimit ;
  order ssn yyyyq firmid firmid_2007 employed_qtrs nemployers nemp tenure1 tenure2 mass_layoff1 mass_layoff2 separation 
        dislocated qtrs_since_dislocation qtrs_since_separation qtrs_max_to_mass prim_earnings prim_hours prim_wage 
        all_earnings all_hours prim_imputed other_imputed firmsize naics yyyyq_mass_layoff1 yyyyq_mass_layoff2 
        yyyyq_separation max_size_2006 max_size_2007 yyyyq_max_2006 yyyyq_max_2007 employed_2002 employed_2003 
        employed_2004 employed_2005 employed_2006 ui_claimant1 ui_claimant2 edc birth_date age;
#delimit cr
sort ssn yyyyq
save dislocated5.dta, replace
