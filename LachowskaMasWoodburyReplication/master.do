* This is a master do-file. 
* It calls the other files in the listed order. 
* The first 6 do files create the analysis extracts. 
* The last do file, "master_results.do" calls on do files that 
* produce the results in the paper and appendices. 
* The user needs to install following Stata user-written packages: 
* edo (attached) outreg2, coefplot, plotplain, grc1leg, a2reg, regintfe, xtrifreg, unique, reghdfe. 
* Note: "edo.do ” is to be put in the user's personal Stata directory; other user-written packages
* can be installed by typing <ssc install package_name> in Stata's command window. 


************************************************************************************
** The datasets should reside in the directory in which these files are executed. **         
***********************************************************************************;

************************************************************************************
** Install user-written commands used by the code					 			  **
************************************************************************************;
edo "install_packages" 

************************************************************************************
** Take raw wage records and interpolate a few cases missing hours to 			  **
** form wage data set (earn_hrs_wages) that is the basis for analysis.            **
************************************************************************************;
edo "dislocated4"

************************************************************************************
** Use earn_hrs_wages.dta from dislocated4.do to create dislocated4.dta,  	      **
** the main analysis sample. 												      **
************************************************************************************;
edo "dislocated5"

************************************************************************************
** Use earn_hrs_wages.dta.dta from dislocated4.do to create dislocated5.dta,      **
** the sample for short-tenure workers.											  **
************************************************************************************;
edo "dislocated8"


************************************************************************************
** Use earn_hrs_wages.dta.dta from dislocated4.do to create dislocated6.dta,      **
** the sample of less strongly attached workers. 								  **
************************************************************************************;
edo "dislocated9"

**************************************************************************************************
** Use earn_hrs_wages.dta.dta from dislocated4.do to merge in UI claim information		     	**
**************************************************************************************************;
edo "dislocated10"

**************************************************************************************************
** Use  wage data to create linkdata7.dta.		 	 										    **
** This is the file used to create the analysis sample for the AKM model and the Woodcock model.**
**************************************************************************************************;
edo "wa21f"

***************************************************************************************
** Execute programs that analyze the data and produce the results based on the above **
** data sets. It calls on other do files listed in "master_results.do"               **
***************************************************************************************;
edo "master_results" 
