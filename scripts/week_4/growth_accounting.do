* Clear existing data
clear
cd "/Users/tomasoles/Library/CloudStorage/Dropbox/Makroekonómia/estimates/scripts/week_4" // change this appropriatelly

* Set the number of observations (e.g., 30 years)
set obs 40

* Generate a time variable (e.g., years 2000 to 2019)
gen year = 1980 + _n - 1

* Assume factor shares
scalar alpha = 0.3       // Capital share
scalar labor_share = 1 - alpha  // Labor share

* Define true growth rates (in percentages)
scalar true_labor_growth = 0.02    // 2% labor growth
scalar true_capital_growth = 0.03  // 3% capital growth
scalar true_tfp_growth = 0.01      // 1% TFP growth

* Generate labor and capital with a base value and growth

gen Labor = 100 * (1 + true_labor_growth)^(_n - 1)
gen Capital = 200 * (1 + true_capital_growth)^(_n - 1)

gen factor_error = rnormal(0, 0.01)  
replace Labor = Labor + factor_error
replace Capital = Capital + factor_error

* Generate TFP with a base value, growth, and an error term
gen TFP = 1 * (1 + true_tfp_growth)^(_n - 1)
gen error_term = rnormal(0, 0.02)  // Random error term with mean 0 and SD 0.02
replace TFP = TFP + error_term     // Add error term to TFP

* Calculate GDP using the Cobb-Douglas production function
gen GDP = TFP * (Capital^alpha) * (Labor^labor_share)

* Add some noise to GDP to simulate measurement error
gen gdp_error = rnormal(0, 0.05)  // Random error term for GDP
replace GDP = GDP + gdp_error     // Add error term to GDP

* Label variables
label variable year "Year"
label variable GDP "Gross Domestic Product"
label variable Labor "Labor Force"
label variable Capital "Capital Stock"
label variable TFP "Total Factor Productivity"

* Save the dataset
save "simulated_growth_data.dta", replace

* View the data
list year GDP Labor Capital TFP

*Set data as time series 
tsset year

* Calculate growth rates
gen gdp_growth = (GDP - L.GDP) / L.GDP
gen labor_growth = (Labor - L.Labor) / L.Labor
gen capital_growth = (Capital - L.Capital) / L.Capital

* Assume factor shares
scalar alpha = 0.3
scalar labor_share = 1 - alpha

* Compute TFP growth
gen tfp_growth = gdp_growth - (alpha * capital_growth) - (labor_share * labor_growth)

* Calculate contributions
gen labor_contribution = labor_share * labor_growth
gen capital_contribution = alpha * capital_growth
gen tfp_contribution = tfp_growth

* Summarize and visualize
summarize labor_contribution capital_contribution tfp_contribution

line GDP Labor Capital year
graph export "gdp_labor_capital.pdf", as(pdf)

line labor_contribution capital_contribution tfp_contribution year, legend(label(1 "Labor") label(2 "Capital") label(3 "TFP"))
graph export "growth_contributions_tfp_l_c.pdf", as(pdf)
