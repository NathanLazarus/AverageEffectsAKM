program define edo
	capture log close
	set more off
	program drop _all
	clear
	set logtype text
	log using `1', replace
	di "Do-file `1' run on $S_DATE at $S_TIME"
	capture noisily do `1'
	local myrc=_rc
	log close
	exit `myrc'
	end
exit

