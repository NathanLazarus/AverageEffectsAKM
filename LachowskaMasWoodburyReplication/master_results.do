* This is a master do-file that produces the results reported in the paper and the appendices. 
* It calls the other files in the listed order. 
* The user needs to install following Stata user-written packages: 
* edo (attached) outreg2, coefplot, psmatch2, grc1leg, a2reg, regintfe, xtrifreg, unique, reghdfe. 
* Note: "edo.do ” is to be put in the user's personal Stata directory; other user-written packages
* can be installed by typing <ssc install package_name> in Stata's command window or
* by executing the do file "install_packages.do" 

clear all

/// Intital statements
graph set window fontface "Times New Roman"
set scheme plotplainblind, permanently 
set more off, permanently


/// Estimate AKM and Woodcock's model

edo "estimate_akm" 					
* Produces Appendix Tables B1 and B2 (see the log file output) and 
* Appendix Table B3 and Appendix Figures B2, B3, and B4
*** To obtain Appendix Figures B2, B3, and B4, see file "TableB3.xlsx" 


edo "estimate_woodcock" 				


/// Data creation

edo "createdata" 
* Creates variable definitions and cleans data 				 
* Produces Figure 1.

edo "summarizedata" 		
* Describes the data and creates the analysis extract 
* Produces numbers for Table 1 (see the log file output). 



/// Main analysis

edo "analyzedata_main"	
* JLS analysis, main sample 			
* Produces Figure 2, Figure 3, Figure 5, 
* "main_analysis.xls" produces Appendix Tables A12-1 and A12-2
* "main_analysis.xls" also produces numbers in row 1 of Appendix A Summary Table and in row 1 of Table 2 
* "main_analysis.xls" produces the PDVs in Table 3 for the UI claimant sample. 

edo "analyzedata_hours_rifreg"	
* JLS analysis, uses xtrifreg 	
* Produces Figure 4 and "hours_distr_analysis.xls" produces Appendix Table A12-3 


/// AKM + QQ transitions

edo "akm_analysis_main"			
* Adds AKM FEs to the main analysis sample for JLS analysis 
* Produces Figure 6 and "akm_analysis.xls" produces Appendix Table A12-4 
* "akm_analysis.xls" also produces numbers in row 2 of Appendix A Summary Table and in row 2 of Table 2. 

edo "analyze_qq_matrix" 				
* Produces the numbers for displaced workers for Tables 4 and 6, and for 
* Figures 7, 8A, 8B, 8C, and for all the tables and figures in Appendix A.9

edo "analyze_qq_akm_matrix" 			
* Produces the numbers for non-displaced job changers for Tables 5 and 6, and for 
* Figures 7, 8A, 8B, 8C, and for all the tables and figures in Appendix A.9


/// Match effects + QQ transitions 

edo "match_analysis_main" 	
* Adds match effects to JLS analysis 
* Produces Figure 9 and Appendix Figure A11-1
* "me_analysis.xls" produces numbers in row 10 and 11 of Appendix A Summary Table 
* and row 3 of Table 2. Note that row 4 of Table 2 is a residual.  
*** To obtain Figure 10, combine quarter 1-20 displacement coefficients for logwages 
*** from files "main_analysis.xls", "akm_analysis.xls", and "me_analysis.xls". 
*** Year 1 is computed as an average of quarters 1-4, year 2 as an average of quarter 5-8, etc. 
*** See file "Figure10_and_FigureA1_15.xlsx" for a rendering of the numbers

edo "analyze_qq_match_matrix" 			
* Produces the numbers for displaced workers for Tables 4 and 6, and for 
* Figures 8A, 8B, 8C, and for all the tables and figures in Appendix A.9

edo "analyze_qq_akm_match_matrix" 		
* Produces the numbers for non-displaced job changers for Tables 5 and 6, and for 
* Figures 8A, 8B, 8C, and for all the tables and figures in Appendix A.9 


******* Robustness checks for the Appendix, DW and AKM *******

/// Robustness, DW analysis 

edo "analyzedata_fire"					
* JLS analysis,  non-FIRE only 
* Produces Appendix Figure A6-1 
* "main_fire.xls" produces numbers in row 7 of Appendix A Summary Table 

edo "analyzedata_pk"					
* JLS analysis,  alternative control group 
* Produces Appendix Figures A4-1, Figure A4-2, and A4-3 
* "pk_analysis.xls" produces numbers in row 5 of Appendix A Summary Table 

edo "analyzedata_all_obs"				
* JLS analysis, broadened sample  
* "all_analysis.xls" produces numbers in row 6 of Appendix A Summary Table
* analyzedata_all_obs.log produces the PDVs in Table 3 for the broadened sample
* Produces Appendix Figures A5-1, Figure A5-2, and A5-3
 
edo "analyzedata_regintfe"				
* JLS analysis with "regintfe" used to compute worker-specific trends 
* "trend_analysis.xls" produces numbers in row 8 of Appendix A Summary Table. 


/// DW out-migration analysis 

edo "create_dislocated2"				
* Creates an extract of w/o constraints on earnings. 

edo "summarizedata_dislocated2" 		
* Produces Appendix Table A3-1 (see the log file output). 

edo "analyzedata_main_dislocated2"		
* Uses the JLS control group + the DWs defined as in create_dislocated2 to estimate the costs of displacement.
* Produces Appendix Figure A3-1. 
* "dislocated2_analysis.xls" produces numbers in row 4 of Appendix A Summary Table.


/// Schmieder, von Wachter, Heining (2018) sample cuts, DW and AKM analysis

edo "analyzedata_SvWH"  				
* Sample cuts and matching analysis emulating SvWH's cuts 
* Produces Appendix Figure A8-1 
* "SvWH_analysis.xls" produces numbers in row 9 of Appendix A Summary Table. 



/// AKM out-migration analysis 

edo "akm_outmigration"					
* Drops 70/50 % of the firms and reruns AKM 
* Produces Appendix Figures B5 and B6


/// DW/AKM analysis by subgroups
  
edo "akm_analysis_pk"					
* Adds AKM FEs to JLS analysis analysis to sample with alternative control group 
* Produces Appendix Figure A4-4.

edo "akm_analysis_allobs" 				
* Adds AKM FEs to JLS analysis for the broadened sample 
* Produces Appendix Figure A5-4.



/// Analysis for the 3-4 year tenure  sample 
	
// DW analysis 

edo "createdata_short"					
* Creates variable definitions for the 3-4 year tenure sample 

edo "summarizedata_short" 				
* Creates the analysis extract for the 3-4 year tenure sample 

edo "analyzedata_short" 				
* JLS analysis for 3-4 years tenure sample 
* "short_analysis.xls" produces numbers in row 3 of Appendix A Summary Table 
* Produces Appendix Figure A1-1. 


// AKM & Match effects analysis + QQ transitions 

edo "akm_match_analysis_short"				
* Adds AKM FEs and match effs to the 3-4 year tenure sample for JLS analysis
* Produces the numbers for short-tenure displaced workers for all tables and figures in Appendix A.1, 
* except for Figure A1-1 (see analyzedata_short.do above)
* Produces Figure A1-2 
*** To obtain Appendix Figure A1-15, combine quarter 1-20 displacement coefficients   
*** for logwages from file  "akm_me_short_analysis.xls". 
*** Year 1 is computed as an average of quarters 1-4, year 2 as an average of quarter 5-8, etc. 
*** See file "Figure10_and_FigureA1_15.xlsx" for a rendering of the numbers




// Scatterplots 

edo "scatterplots_long_aea"		
* Produces scatterplots in Figures 8A, 8B, 8C and Appendix A.9

edo "scatterplots_short_aea"		
* Produces scatterplots in Appendix A.1
		

