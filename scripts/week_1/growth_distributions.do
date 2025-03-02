/*
This file reproduce some of the growth distributions from 1960 - 2020 to capture differences in growth between countries used in Week 1 - Introduction to economic growth. 
*/

*Set this according to your system path
global project "~/my-path/"

use "${project}/pwt1001.dta", clear

*Plot GDP per capita over time
gen gdp_pc = rgdpna/emp
gen log_gdp_pc = log(gdp_pc)

twoway (tsline log_gdp_pc, lcolor(navy)) (lfit log_gdp_pc year, lcolor(maroon)) if country == "United States" & year >=1960, ///
    legend(order(1 "Time Series" 2 "Trend Line")) ytitle("Log GDP per worker. (2017 Prices)")
	
graph export "${project}/figures/gdp_pc_plot.pdf", as(pdf) replace

*Capital per worker 
gen rnna_pc = rnna/emp
gen log_rnna_pc = log(rnna_pc)

twoway (tsline log_rnna_pc, lcolor(navy)) (lfit log_rnna_pc year, lcolor(maroon)) if country == "United States" & year >=1960, ///
    legend(order(1 "Time Series" 2 "Trend Line")) ytitle("Log Capital stock per worker. (2017 Prices)")
	
graph export "${project}/figures/cpc_pc_plot.pdf", as(pdf) replace

*Capital to output
gen k_y = rnna/rgdpna
twoway (tsline k_y, lcolor(navy)) if country == "United States" & year >=1960, ///
    legend(order(1 "Time Series" 2 "Trend Line")) ytitle("K/Y")
	
graph export "${project}/figures/ky_pc_plot.pdf", as(pdf) replace

*Labor share 
twoway (tsline labsh, lcolor(navy)) if country == "United States" & year >=1960, ///
    legend(order(1 "Time Series" 2 "Trend Line")) ytitle("Labor share")
	
graph export "${project}/figures/ls_pc_plot.pdf", as(pdf) replace


*Return on capital (1-Labor share)Y/K

gen r_k = (1-labsh)*(rgdpna/rnna)

twoway (tsline r_k, lcolor(navy)) if country == "United States" & year >=1960, ///
    legend(order(1 "Time Series" 2 "Trend Line")) ytitle("Return on Capital")
	
graph export "${project}/figures/return_capital_pc_plot.pdf", as(pdf) replace


*Wages 
preserve 
import delimited "${project}/A034RC1A027NBEA.csv", clear
rename a034rc1a027nbea real_wage 
gen year = substr(observation_date, 1, 4)
destring year, replace

/*
use  "${project}/pwt1001.dta", clear 
keep if country == "United States"
keep year emp 
save "${project}/emp_us.dta", replace
*/
/*
import delimited "${project}/PCEPI.csv", clear
gen year = substr(observation_date, 1, 4)
destring year, replace
save "${project}/cpi_ch_l_us.dta", replace
*/


merge 1:1  year using "${project}/emp_us.dta", nogenerate
merge 1:1  year using "${project}/cpi_ch_l_us.dta", nogenerate

replace pcepi = pcepi/100
gen log_r_wage = log((real_wage/pcepi)/emp)


tsset year
twoway (tsline log_r_wage, lcolor(navy)) (lfit log_r_wage year, lcolor(maroon)) if year >=1960, ///
    legend(order(1 "Time Series" 2 "Trend Line")) ytitle("Log Real Wages")
	
graph export "${project}/figures/wage_pc_plot.pdf", as(pdf) replace
restore

*Densities of GDP per capita 
use "${project}/pwt1001.dta", clear

gen gdp_pc_ppp = rgdpe/pop
 
kdensity gdp_pc_ppp if year == 1960, generate(density1960 gdp1960)
kdensity gdp_pc_ppp if year == 1980, generate(density1980 gdp1980)
kdensity gdp_pc_ppp if year == 2000, generate(density2000 gdp2000)
kdensity gdp_pc_ppp if year == 2019, generate(density2020 gdp2020)

replace density1960 = . if density1960 > 50000
replace density1980 = . if density1980 > 50000
replace density2000 = . if density2000 > 50000
replace density2020 = . if density2020 > 50000

replace density1960 = . if density1960 < -10000
replace density1980 = . if density1980 < -10000
replace density2000 = . if density2000 < -10000
replace density2020 = . if density2020 < -10000


twoway (line gdp1960 density1960,  lpattern(solid) legend(label(1 "1960"))) ///
       (line gdp1980 density1980,  lpattern(dash) legend(label(2 "1980"))) ///
       (line gdp2000 density2000,  lpattern(dash_dot) legend(label(3 "2000"))) ///
	   (line gdp2020 density2020,  lpattern(solid) legend(label(4 "2020"))), ///
       xtitle("PPP-adjusted GDP per capita (1960, 1980, 2000, 2020)") ///
       ytitle("Density of countries")  xlabel(0(10000)50000)

graph export "${project}/figures/density_gdppc_ppp.pdf", as(pdf) replace


*Plot in log scale 
use "${project}/pwt1001.dta", clear

gen gdp_pc_ppp =log(rgdpe/pop)
 
kdensity gdp_pc_ppp if year == 1960, generate(density1960 gdp1960)
kdensity gdp_pc_ppp if year == 1980, generate(density1980 gdp1980)
kdensity gdp_pc_ppp if year == 2000, generate(density2000 gdp2000)
kdensity gdp_pc_ppp if year == 2019, generate(density2020 gdp2020)


twoway (line gdp1960 density1960,  lpattern(solid) legend(label(1 "1960"))) ///
       (line gdp1980 density1980,  lpattern(dash) legend(label(2 "1980"))) ///
       (line gdp2000 density2000,  lpattern(dash_dot) legend(label(3 "2000"))) ///
	   (line gdp2020 density2020,  lpattern(solid) legend(label(4 "2020"))), ///
       xtitle("PPP-adjusted Log GDP per capita (1960, 1980, 2000, 2020)") ///
       ytitle("Density of countries")  xlabel(6(1)13)

graph export "${project}/figures/log_density_gdppc_ppp.pdf", as(pdf) replace


*Plot in log scale and population weighted
use "${project}/pwt1001.dta", clear
gen pop_weight = round(pop/50) if pop > 0
expand pop_weight

gen gdp_pc_ppp =log(rgdpe/pop)
 
kdensity gdp_pc_ppp if year == 1960, generate(density1960 gdp1960)
kdensity gdp_pc_ppp if year == 1980, generate(density1980 gdp1980)
kdensity gdp_pc_ppp if year == 2000, generate(density2000 gdp2000)
kdensity gdp_pc_ppp if year == 2019, generate(density2020 gdp2020)


twoway (line gdp1960 density1960,  lpattern(solid) legend(label(1 "1960"))) ///
       (line gdp1980 density1980,  lpattern(dash) legend(label(2 "1980"))) ///
       (line gdp2000 density2000,  lpattern(dash_dot) legend(label(3 "2000"))) ///
	   (line gdp2020 density2020,  lpattern(solid) legend(label(4 "2020"))), ///
       xtitle("PPP-adjusted Log GDP per capita (1960, 1980, 2000, 2020)") ///
       ytitle("Population weighted density of countries ")  xlabel(6(1)13)

graph export "${project}/figures/log_p_w_density_gdppc_ppp.pdf", as(pdf) replace


*Plot in log scale per worker
use "${project}/pwt1001.dta", clear

gen gdp_emp_ppp =log(rgdpe/emp)
 
kdensity gdp_emp_ppp if year == 1960, generate(density1960 gdp1960) 
kdensity gdp_emp_ppp if year == 1980, generate(density1980 gdp1980)
kdensity gdp_emp_ppp if year == 2000, generate(density2000 gdp2000)
kdensity gdp_emp_ppp if year == 2019, generate(density2020 gdp2020)


twoway (line gdp1960 density1960,  lpattern(solid) legend(label(1 "1960"))) ///
       (line gdp1980 density1980,  lpattern(dash) legend(label(2 "1980"))) ///
       (line gdp2000 density2000,  lpattern(dash_dot) legend(label(3 "2000"))) ///
	   (line gdp2020 density2020,  lpattern(solid) legend(label(4 "2020"))), ///
       xtitle("PPP-adjusted Log GDP per worker (1960, 1980, 2000, 2020)") ///
       ytitle("Density of countries ")  xlabel(6(1)13)

graph export "${project}/figures/log_p_w_density_gdppw_ppp.pdf", as(pdf) replace

*Association GDP consumption
use "${project}/pwt1001.dta", clear

gen log_cons_pc_2015 = log(rconna/pop) if year == 2015
gen log_gdp_pc_2015 = log(rgdpna/pop) if year == 2015


twoway (scatter log_cons_pc_2015 log_gdp_pc_2015, mlabel(countrycode) msymbol(none) ///
        mlabposition(0) mlabsize(tiny)) ///
       (lfit log_cons_pc_2015 log_gdp_pc_2015, color(maroon)), ///
       xtitle("Log GDP per capita 2015") ///
       ytitle("Log Consumption per capita")

graph export "${project}/figures/consuption_gdp.pdf", as(pdf) replace


*Import life expectancy

preserve
import delimited "${project}/life_exp_2015.csv", varnames(1) clear
gen year = 2015
save "${project}/life_exp_2015.dta", replace
restore

use "${project}/pwt1001.dta", clear
merge m:m year countrycode using "${project}/life_exp_2015.dta", nogenerate
replace life_expectancy = "" if life_expectancy == ".."
destring life_expectancy, replace

gen log_gdp_pc_2015 = log(rgdpna/pop) if year == 2015


twoway (scatter life_expectancy log_gdp_pc_2015, mlabel(countrycode) msymbol(none) ///
        mlabposition(0) mlabsize(tiny)) ///
       (lfit life_expectancy log_gdp_pc_2015, color(maroon)), ///
       xtitle("Log GDP per capita 2015") ///
       ytitle("Life expectancy (Total)")

graph export "${project}/figures/life_gdp.pdf", as(pdf) replace


*Growth simulation 

clear
set obs 101  // 101 observations for 100 years (including year 0)
gen year = _n - 1  // Create year variable (from 0 to 100)

// Simulate GDP growth for two countries
gen gdp_country1 = 1000 * (1 + 0.02)^year  // Country 1 with 2% growth
gen gdp_country2 = 1000 * (1 + 0.04)^year  // Country 2 with 4% growth

twoway (line gdp_country1 year, lpattern(solid) lcolor(navy) ///
        legend(label(1 "Country 1 (2% Growth)"))) ///
       (line gdp_country2 year, lpattern(solid) lcolor(maroon) ///
        legend(label(2 "Country 2 (4% Growth)"))), ///
       xtitle("Years") ///
       ytitle("GDP (Index, initial = 1000)") 

graph export "${project}/figures/growth_simulation.pdf", as(pdf) replace


*Densities of growth 
use "${project}/pwt1001.dta", clear
encode countrycode, gen(country_en)
xtset country_en year

sort country_en year
bysort country_en: gen growth_var = log(rgdpna) - log(L.rgdpna)

kdensity growth_var if year == 1960, generate(density1960 growth1960)
kdensity growth_var if year == 1980, generate(density1980 growth1980)
kdensity growth_var if year == 2000, generate(density2000 growth2000)
kdensity growth_var if year == 2015, generate(density2015 growth2015)

replace density1960 = . if density1960 < -.2
replace density1980 = . if density1980 < -.2
replace density2000 = . if density2000 < -.2
replace density2015 = . if density2015 < -.2



twoway (line growth1960 density1960 , lpattern(solid) legend(label(1 "1960"))) ///
       (line growth1980 density1980, lpattern(dash) legend(label(2 "1980"))) ///
       (line growth2000 density2000, lpattern(dash_dot) legend(label(3 "2000"))) ///
       (line growth2015 density2015 , lpattern(longdash) legend(label(4 "2015"))), ///
       xtitle("GDP Growth Rate (%)") ///
       ytitle("Density") 

graph export "${project}/figures/growth_gdp.pdf", as(pdf) replace

*Economic growth over long run 
import delimited "${project}/gdp-world-regions-stacked-area.csv", varnames(1) clear
gen log_gdp = log(grossdomesticproductgdp)
drop if year >2020

twoway (line log_gdp year if entity == "Western offshoots ",  lpattern(solid) legend(label(1 "Western Offshoots"))) ///
       (line log_gdp year if entity == "Western Europe ",  lpattern(dash) legend(label(2 "Western Europe"))) ///
       (line log_gdp year if entity == "Latin America ",  lpattern(dot) legend(label(3 "Latin America"))) ///
       (line log_gdp year if entity == "South and South East Asia ",  lpattern(solid) legend(label(4 "Asia"))) ///
       (line log_gdp year if entity == "Sub Saharan Africa ",  lpattern(dash_dot) legend(label(5 "Africa"))), ///
       xtitle("Year") ytitle("Log GDP") 
	   
	   
	   
*Plot for countries	   
use "${project}/mpd2020.dta", clear
keep if country == "United States" | country == "United Kingdom" | country == "Spain" | country == "Brazil" | ///
         country == "South Korea" | country == "Singapore" | country == "Guatemala" | ///
         country == "Botswana" | country == "India" | country == "Nigeria"
		 
		 
gen log_gdppc = log(gdppc)

drop if year < 1840

twoway (line log_gdppc year if country == "United States", lpattern(solid) legend(label(1 "United States"))) ///
       (line log_gdppc year if country == "United Kingdom", lpattern(dash) legend(label(2 "United Kingdom"))) ///
       (line log_gdppc year if country == "Spain", lpattern(dot) legend(label(3 "Spain"))) ///
       (line log_gdppc year if country == "Brazil", lpattern(solid) legend(label(4 "Brazil"))) ///
       (line log_gdppc year if country == "South Korea", lpattern(dash_dot) legend(label(5 "South Korea"))) ///
       (line log_gdppc year if country == "Singapore", lpattern(solid) legend(label(6 "Singapore"))) ///
       (line log_gdppc year if country == "Guatemala", lpattern(dash) legend(label(7 "Guatemala"))) ///
       (line log_gdppc year if country == "Botswana", lpattern(dot) legend(label(8 "Botswana"))) ///
       (line log_gdppc year if country == "India", lpattern(longdash) legend(label(9 "India"))) ///
       (line log_gdppc year if country == "Nigeria", lpattern(dash_dot) legend(label(10 "Nigeria"))), ///
       xtitle("Year") ytitle("Log GDP per capita")

graph export "${project}/figures/gdp_long_run.pdf", as(pdf) replace

*Plot growth densities over long run 
use "${project}/mpd2020.dta", clear
gen log_gdppc = log(gdppc)



kdensity log_gdppc if year == 1820, generate(density1820 gdp1820)
kdensity log_gdppc if year == 1913, generate(density1913 gdp1913)
kdensity log_gdppc if year == 2000, generate(density2000 gdp2000)

twoway (line gdp1820 density1820 , lpattern(solid) legend(label(1 "1820"))) ///
       (line gdp1913 density1913 , lpattern(dash) legend(label(2 "1913"))) ///
       (line gdp2000 density2000, lpattern(solid) legend(label(3 "2000"))), ///
       xtitle("Log GDP per capita") ytitle("Density") 

graph export "${project}/figures/density_long_run.pdf", as(pdf) replace


*Plot convergence 
use "${project}/pwt1001.dta", clear
gen oecd = 0  // Initialize OECD indicator
replace oecd = 1 if countrycode == "AUS" | countrycode == "AUT" | countrycode == "BEL" | ///
                countrycode == "CAN" | countrycode == "CHL" | countrycode == "CZE" | ///
                countrycode == "DNK" | countrycode == "EST" | countrycode == "FIN" | ///
                countrycode == "FRA" | countrycode == "DEU" | countrycode == "GRC" | ///
                countrycode == "HUN" | countrycode == "ISL" | countrycode == "IRL" | ///
                countrycode == "ISR" | countrycode == "ITA" | countrycode == "JPN" | ///
                countrycode == "KOR" | countrycode == "LVA" | countrycode == "LTU" | ///
                countrycode == "LUX" | countrycode == "MEX" | countrycode == "NLD" | ///
                countrycode == "NZL" | countrycode == "NOR" | countrycode == "POL" | ///
                countrycode == "PRT" | countrycode == "SVK" | countrycode == "SVN" | ///
                countrycode == "ESP" | countrycode == "SWE" | countrycode == "CHE" | ///
                countrycode == "TUR" | countrycode == "GBR" | countrycode == "USA"
				
keep if oecd == 1	
gen log_gdp_worker = log(rgdpna / emp)  

* Keep data for 1960 and 2015
gen period = .
replace period = 1960 if year == 1960
replace period = 2015 if year == 2015
drop if missing(period)

keep period countrycode country log_gdp_worker
* Reshape to wide format to calculate growth rates
reshape wide log_gdp_worker, i(country) j(period)

* Compute the annualized growth rate
gen growth_rate = (log_gdp_worker2015 - log_gdp_worker1960) / (2015 - 1960)


twoway (scatter growth_rate log_gdp_worker1960, mlabel(country) msymbol(none)) ///
       (lfit growth_rate log_gdp_worker1960, color(maroon)), ///
       xtitle("Log GDP per Worker (1960)") ///
       ytitle("Annual Growth Rate (1960–2015)") xlabel(9(1)11.5)
	   
graph export "${project}/figures/conditional_convergence.pdf", as(pdf) replace

*Plot correlates with economic growth - investments and human capital  
use "${project}/pwt1001.dta", clear
gen oecd = 0  // Initialize OECD indicator
replace oecd = 1 if countrycode == "AUS" | countrycode == "AUT" | countrycode == "BEL" | ///
                countrycode == "CAN" | countrycode == "CHL" | countrycode == "CZE" | ///
                countrycode == "DNK" | countrycode == "EST" | countrycode == "FIN" | ///
                countrycode == "FRA" | countrycode == "DEU" | countrycode == "GRC" | ///
                countrycode == "HUN" | countrycode == "ISL" | countrycode == "IRL" | ///
                countrycode == "ISR" | countrycode == "ITA" | countrycode == "JPN" | ///
                countrycode == "KOR" | countrycode == "LVA" | countrycode == "LTU" | ///
                countrycode == "LUX" | countrycode == "MEX" | countrycode == "NLD" | ///
                countrycode == "NZL" | countrycode == "NOR" | countrycode == "POL" | ///
                countrycode == "PRT" | countrycode == "SVK" | countrycode == "SVN" | ///
                countrycode == "ESP" | countrycode == "SWE" | countrycode == "CHE" | ///
                countrycode == "TUR" | countrycode == "GBR" | countrycode == "USA"
				
*keep if oecd == 1	
gen log_gdp_worker = log(rgdpna / emp)  
gen log_capital = log(rnna)
bysort country: egen average_hc = mean(log(hc)) if year >= 1960 & year <=2015
* Keep data for 1960 and 2015
gen period = .
replace period = 1960 if year == 1960
replace period = 2015 if year == 2015
drop if missing(period)

keep period countrycode country log_gdp_worker log_capital average_hc
* Reshape to wide format to calculate growth rates
reshape wide log_gdp_worker log_capital average_hc, i(country) j(period)

* Compute the annualized growth rate
gen growth_rate = (log_gdp_worker2015 - log_gdp_worker1960) / (2015 - 1960)
gen capital_growth = (log_capital2015 - log_capital1960)/(2015 - 1960)

twoway (scatter growth_rate capital_growth, mlabel(country) msymbol(none)) ///
       (lfit growth_rate capital_growth, color(maroon)), ///
       xtitle("Average growth in capital stock (1960-2015)") ///
       ytitle("Average Growth Rate (1960–2015)") xlabel(0(0.02)0.1)
	   
graph export "${project}/figures/capital_growth.pdf", as(pdf) replace

twoway (scatter growth_rate average_hc2015, mlabel(country) msymbol(none)) ///
       (lfit growth_rate average_hc2015, color(maroon)), ///
       xtitle("Average Log Human Capital (1960–2015)") ///
       ytitle("Average Growth Rate (1960–2015)") 
	   
graph export "${project}/figures/human_capital_growth.pdf", as(pdf) replace





