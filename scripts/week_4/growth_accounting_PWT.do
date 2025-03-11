* Clear existing data
clear
cd "/Users/tomasoles/Library/CloudStorage/Dropbox/Makroekonómia/estimates/scripts/week_4" // change this appropriatelly

*Use PWT
use pwt1001.dta, clear

* Set parameters
local alpha = 0.33  

* Compute log TFP
gen ln_A = log(cgdpe) - `alpha' * log(cn) - (1 - `alpha') * log(emp)

* Normalize TFP relative to the US in 2019
preserve
    keep if country == "United States" & year == 2019
    gen tfp_us_2019 = ln_A
    keep tfp_us_2019 year
    tempfile us_tfp
    save us_tfp.dta, replace
restore

merge m:1 year using us_tfp.dta, keepusing(tfp_us_2019) nogen
gen tfp_relative = exp(ln_A - tfp_us_2019)  // Normalize relative to US = 1

* Keep only 2019 for plotting
keep if year == 2019

* Compute GDP per worker (output per worker)
gen gdp_per_worker = cgdpe / emp

* Compute correlation
corr tfp_relative gdp_per_worker

* Scatter plot of TFP relative to US vs GDP per worker
twoway (scatter gdp_per_worker tfp_relative, msize(small) mlab(countrycode) mlabsize(tiny)), ///
    note("Corr = 0.96", size(small)) ///
    xlabel(, angle(0)) ///
    ylabel(, angle(0)) ///
    ytitle("GDP per Worker (2019)") ///
    xtitle("TFP (US = 1, 2019)") ///
    legend(off)

graph export "tfp_vs_gdp_per_worker.pdf", replace
