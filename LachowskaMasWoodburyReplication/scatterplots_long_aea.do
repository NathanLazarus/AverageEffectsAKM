use "DW_long_aea.dta", clear


* Figure 8A -- wage changes and employer effect changes (first DW then AKM)

reg DW_Δw DW_w_Δψ

reg AKM_Δw AKM_w_Δψ

twoway (scatter DW_Δw DW_w_Δψ) (scatter AKM_Δw AKM_w_Δψ) (lfit DW_Δw DW_w_Δψ) (lfit AKM_Δw AKM_w_Δψ) (line x45•half y45•half)

************

* Figure 8B -- match effect changes and employer effect changes (first DW then AKM)
* Note: Need to edit yaxis range/delta to -.5 to .5, and .5

reg DW_w_Δm DW_w_Δψ 

reg AKM_w_Δm AKM_w_Δψ 

twoway (scatter DW_w_Δm DW_w_Δψ) (scatter AKM_w_Δm AKM_w_Δψ) (lfit DW_w_Δm DW_w_Δψ) (lfit AKM_w_Δm AKM_w_Δψ) 

************

* Figure 8C -- direct effects for wages and employer effect changes
* Note: Need to edit yaxis range/delta to -.5 to .5, and .5

reg DW_w_dir DW_w_Δψ 

reg AKM_w_dir AKM_w_Δψ 

twoway (scatter DW_w_dir DW_w_Δψ) (scatter AKM_w_dir AKM_w_Δψ) (lfit DW_w_dir DW_w_Δψ) (lfit AKM_w_dir AKM_w_Δψ) 

************
************
************

* Figure A9-2 -- earnings changes and employer effects (AKM and DW)

reg DW_Δer DW_er_Δψ

reg AKM_Δer AKM_er_Δψ

twoway (scatter DW_Δer DW_er_Δψ) (scatter AKM_Δer AKM_er_Δψ) (lfit DW_Δer DW_er_Δψ) (lfit AKM_Δer AKM_er_Δψ) (line x45 y45)

************

* Figure A9-3 -- match effects for earnings and employer effect changes
* Note: Need to edit yaxis range/delta to -1.5 to 1, and .5

* gen DW_er_dir = DW_Δer - DW_er_Δψ - DW_er_Δm 

* gen AKM_er_dir = AKM_Δer - AKM_er_Δψ - AKM_er_Δm 

reg DW_er_Δm DW_er_Δψ 

reg AKM_er_Δm AKM_er_Δψ 

twoway (scatter DW_er_Δm DW_er_Δψ) (scatter AKM_er_Δm AKM_er_Δψ) (lfit DW_er_Δm DW_er_Δψ) (lfit AKM_er_Δm AKM_er_Δψ) 

************

* Figure A9-4 -- direct effects for earnings and employer effect changes
* Note: Need to edit yaxis range/delta to -1.5 to 1, and .5

reg DW_er_dir DW_er_Δψ 

reg AKM_er_dir AKM_er_Δψ 

twoway (scatter DW_er_dir DW_er_Δψ) (scatter AKM_er_dir AKM_er_Δψ) (lfit DW_er_dir DW_er_Δψ) (lfit AKM_er_dir AKM_er_Δψ) 

************
************
************

* Figure A9-6 -- hours changes and employer effects (AKM and DW)

corr DW_Δhr DW_hr_Δψ AKM_Δhr AKM_hr_Δψ  

reg DW_Δhr DW_hr_Δψ

reg AKM_Δhr AKM_hr_Δψ

twoway (scatter DW_Δhr DW_hr_Δψ) (scatter AKM_Δhr AKM_hr_Δψ) (lfit DW_Δhr DW_hr_Δψ) (lfit AKM_Δhr AKM_hr_Δψ) (line x45•half y45•half) 

************

* Figure A9-7 -- match effects for hours and employer effect changes
* Note: Need to edit yaxis range/delta to -1 to .5, and .5

reg DW_hr_Δm DW_hr_Δψ 

reg AKM_hr_Δm AKM_hr_Δψ 

twoway (scatter DW_hr_Δm DW_hr_Δψ) (scatter AKM_hr_Δm AKM_hr_Δψ) (lfit DW_hr_Δm DW_hr_Δψ) (lfit AKM_hr_Δm AKM_hr_Δψ) 

************

* Figure A9-8 -- direct effects for hours and employer effect changes
* Note: Need to edit yaxis range/delta to -1 to .5, and .5

reg DW_hr_dir DW_hr_Δψ 

reg AKM_hr_dir AKM_hr_Δψ 

twoway (scatter DW_hr_dir DW_hr_Δψ) (scatter AKM_hr_dir AKM_hr_Δψ) (lfit DW_hr_dir DW_hr_Δψ) (lfit AKM_hr_dir AKM_hr_Δψ) 

