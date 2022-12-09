*****************************************************************************************************
** WA21F.DO constructs an employer-employee linked longitudinal file for a project that Steve and  **
** Marta are doing.                                                                                **
**                                                                                                 **
** 2015/04/29: Ken Kline                                                                           **
** 2015/07/07: Modified to make the time unit of observation the year instead of YYYYQ to cut down **
** on the size of the data set.                                                                    **
** 2016/03/14: Modified to restrict the data set to only include persons that had at least two     **
** consecutive quarters of earnings with the primary employer in a given calendar year.            **
** 2016/03/16: Before the previous restriction is applied, I am going to drop (at the person-qtrly **
** level) the first two observed quarters and the last two observed quarters provided they are     **
** back-to-back.                                                                                   **
** 2016/05/06: Annual earnings and hours will be based on multiplying the average in a year by 4   **
** so if someone works three quarters the they will have a value that assumes what if the person   **
** worked at the average rate all year.                                                            **
** 2016/06/15:  Fixes a mistake that caused data for 2013Q4 to be dropped.                         **
** 2016/12/01:  Modified WA21E.DO to remove the first observation in any consecutive SSN-EMPID     **
** combination and also remove the last two observations in any consecutive SSN-EMPID combination. **
** 2019/03/04: Modified to remove Linux path names since core data sets will reside in the         **
** directory in which this file is executed.                                                       **
*****************************************************************************************************;
set type float
tempfile wage firmsize list

*************************************************************************************************
** First count the number employers an individual had in each year and then save the record    **
** associated with the major employer (most wages reported).  Note that this data set is       **
** already sorted such that the major employer in the quarter is the first record for the      **
** quarter.                                                                                    **
*************************************************************************************************;
use wages.dta, clear

by ssn yyyyq: egen xwages=total(wages)
by ssn yyyyq: gen n=_n
keep if n==1
drop wages n
rename xwages wages

******************************************************************************************
** Throw out first observation of consecutive SSN-EMPID and the last two of consecutive **
** SSN-EMPID.  If there is just one consecutive quarter, throw that observation out.    **
** All records associated with 2 or three consecutive quarters with the same SSN-EMPID  **
** will get dropped.  If the individual had four or more consecutive quarters with the  **
** same SSN-EMPID, drop the first and the last two.  With the constraint late in the    **
** program that the person must have two observations in a given calendar year, the     **
** person with four consecutive will get dropped because the 1st and last two are       **
** dropped leaving just 1.                                                              **
******************************************************************************************;
sort ssn empid yyyyq
gen int yyyy=int(yyyyq/10)
gen byte q=yyyyq-10*yyyy
by ssn empid: gen byte xconsec=1 if _n==1
by ssn empid: replace xconsec=xconsec[_n-1]+1 if _n > 1 & (yyyyq-yyyyq[_n-1]==1 | (q==1 & yyyy-yyyy[_n-1]==1 & q[_n-1]==4))
by ssn empid: egen consec=max(xconsec)
drop if consec <= 3 | (consec >= 4 & (xconsec==1 | xconsec==consec-1 | xconsec==consec))
drop xconsec consec


****************************************************************************************
** Since we are now including annualized wages and hours from the average, I will set **
** zero observations to missing.                                                      **
****************************************************************************************;
replace hours=. if hours <= 0
replace wages=. if wages==0
sort ssn yyyy empid

by ssn yyyy empid: egen xwages=total(wages)
by ssn yyyy empid: egen ywages=mean(wages)
by ssn yyyy empid: egen xhours=total(hours)
by ssn yyyy empid: egen yhours=mean(hours)
drop wages hours yyyyq
rename xwages wages1
rename ywages wages2
rename xhours hours1
rename yhours hours2
by ssn yyyy empid: gen n=_n
keep if n==1
replace wages2=wages2*4
replace hours2=hours2*4
gen hourlywage1=wages1/hours1
gen hourlywage2=wages2/hours2
drop n
sort ssn yyyy
by ssn yyyy: gen int n=_n
by ssn yyyy: egen int nemp=max(n)
drop n
sort ssn yyyy
by ssn : gen int n=_n
by ssn: egen int nemp_all=max(n)
drop n

gsort ssn yyyy -wages1
by ssn yyyy: gen n=_n
keep if n==1
drop n
label var yyyy "Year"
label var nemp "Number of Employers in the Year"
label var nemp_all "Number of Employers, All Years"
label var hourlywage1 "Hourly Wage Rate (Major Employer)"
label var hourlywage2 "Hourly Wage Rate (Annualzied, Major Emp)"
label var wages1 "Total Wages (Major Employer)"
label var wages2 "Annualized Wages from Average (Major Employer)
label var hours1 "Total Hours (Major Employer)"
label var hours2 "Annualized Total Hours from Average (Major Employer)"

format hourlywage1 hourlywage2 %9.2f
format nemp %3.0f
format yyyy %4.0f
sort ssn yyyy empid
save `wage'

** Keep list of major employer in each year **;
tempfile major
keep ssn yyyy empid
save `major'

***************************************************************************************************
** Grab data from all employers and then keep records associated with the major employer and     **
** verify two consecutive quarters of earnings and that the 2nd quarter occurred in the calendar **
** year.                                                                                         **
***************************************************************************************************;
use ssn yyyyq empid wages using wages.dta, clear
sort ssn yyyyq empid
gen int yyyy=int(yyyyq/10)
sort ssn yyyy empid yyyyq

merge m:1 ssn yyyy empid using `major'
  keep if _merge==3
  drop _merge

****************************************************************************************************
** Must have two consecutive quarters of data in the calendar year.  First throw out records with **
** just one observation in the given calendar year.                                               **
****************************************************************************************************;
sort ssn yyyy yyyyq
by ssn yyyy: gen n=_n
by ssn yyyy: egen maxn=max(n)
keep if maxn >= 2
drop n maxn

** Set a flag if records are consecutive **;
sort ssn yyyy yyyyq
gen byte flag=0
by ssn yyyy: replace flag=1 if _n > 1 & yyyyq-yyyyq[_n-1]==1
by ssn yyyy: egen maxflag=max(flag)
by ssn yyyy: gen n=_n
keep if n==1 & maxflag==1
drop flag maxflag n yyyyq wages
sort ssn yyyy empid
save `major', replace

use `wage', clear
merge 1:1 ssn yyyy empid using `major'
  keep if _merge==3
  drop _merge

sort empid yyyy
save `wage', replace


*********************************************************************************
** Count the number of employees (firm size) of the major employer in the year **
*********************************************************************************;
use ssn yyyyq empid using wages.dta, clear 
gen int yyyy=int(yyyyq/10)
drop yyyyq
sort empid yyyy
by empid yyyy: gen n=_n
by empid yyyy: egen int firmsize=max(n)
keep if n==1
keep empid yyyy firmsize
label var firmsize "Employees at Firm in Year"
format firmsize %6.0f
save `firmsize'

use `wage', clear
merge m:1 empid yyyy using `firmsize'
  keep if _merge==3
  drop _merge

sort ssn yyyy
save `wage', replace

by ssn: gen lagempid=empid[_n-1] if _n > 1 & yyyy-1==yyyy[_n-1]
by ssn: gen lagnaics=naics[_n-1] if _n > 1 & yyyy-1==yyyy[_n-1]
label var lagempid "Employer ID, T-1"
label var lagnaics "NAICS Code, T-1"
format lagempid %8s
format lagnaics %6s
rename empid firmid
rename lagempid lagfirmid
order ssn yyyy firmid lagfirmid firmsize wages1 wages2 hours1 hours2 hourlywage1 hourlywage2 naics lagnaics nemp nemp_all
drop q
sort ssn yyyy
save linkdata7.dta, replace
