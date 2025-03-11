* Clear existing data
clear
cd "/Users/tomasoles/Library/CloudStorage/Dropbox/Makroekonómia/estimates/scripts/week_4" // change this appropriatelly

*Use the data from Mankiw, Romer and Weil (1992)
import delimited mrw.csv, clear


* Creating the desired variables for Mankiw, Romer, and Weil (1992)

* Generate lngd: log of population growth rate plus 0.05 ln(n+g+d)
gen lngd = log((popgrowth/100) + 0.05)

* Generate ls: log of investment share of GDP **ln(I/GDP)**
gen ls = log(i_y/100)

* Generate ls_lngd: difference between log investment share and log population growth adjustment
gen ls_lngd = ls - lngd

* Generate lschool: log of school variable
gen lschool = log(school)

* Generate lsch_ngd: difference between log of school and lngd
gen lsch_ngd = lschool - lngd

* Generate ly60: log of rgdpw60 - log GDP per working-age person in 1960
gen ly60 = log(rgdpw60)

* Generate ly85: log of rgdpw85 - log GDP per working-age person in 1985
gen ly85 = log(rgdpw85)

* Generate linv: log of investment share of GDP
gen linv = log(i_y)

* Subsetting the data (later)

* Data with no oil (n == 1)
gen no_oil = (n == 1)

* Data with population in 1960 less than 1 million (i == 1)
gen pop_1960_less_1mil = (i == 1)

* Data for OECD countries (o == 1)
gen oecd = (o == 1)

* Unrestricted Regressions (no restrictions on coefficients)

* 1. Regression for the Non-Oil Group
preserve
regress ly85 ls lngd if n == 1
eststo reg1
restore
mat b_regr = e(b)
local beta_regr = b_regr[1,"ls"]
local alpha_regr = `beta_regr' / (1 + `beta_regr')
display "Implied alpha: " `alpha_regr'


* 2. Regression for the Intermediate Group (pop in 1960 < 1 mil)
preserve
regress ly85 ls lngd if i == 1
eststo reg2
restore
mat b_regr = e(b)
local beta_regr = b_regr[1,"ls"]
local alpha_regr = `beta_regr' / (1 + `beta_regr')
display "Implied alpha: " `alpha_regr'


* 3. Regression for the OECD Group
preserve
regress ly85 ls lngd if o == 1
eststo reg3
restore
mat b_regr = e(b)
local beta_regr = b_regr[1,"ls"]
local alpha_regr = `beta_regr' / (1 + `beta_regr')
display "Implied alpha: " `alpha_regr'


* Restricted Regressions (with ls_lngd)

* 4. Regression for the Non-Oil Group
preserve
regress ly85 ls_lngd if n == 1
eststo regr1
restore
mat b_regr = e(b)
local beta_regr = b_regr[1,"ls_lngd"]
local alpha_regr = `beta_regr' / (1 + `beta_regr')
display "Implied alpha: " `alpha_regr'

* 5. Regression for the Intermediate Group (pop in 1960 < 1 mil)
preserve
regress ly85 ls_lngd if i == 1
eststo regr2
restore

mat b_regr = e(b)
local beta_regr = b_regr[1,"ls_lngd"]
local alpha_regr = `beta_regr' / (1 + `beta_regr')
display "Implied alpha: " `alpha_regr'

* 6. Regression for the OECD Group
preserve
regress ly85 ls_lngd if o == 1
eststo regr3
restore
mat b_regr = e(b)
local beta_regr = b_regr[1,"ls_lngd"]
local alpha_regr = `beta_regr' / (1 + `beta_regr')
display "Implied alpha: " `alpha_regr'



esttab reg1 reg2 reg3 using "unrestricted_regr.tex", ///
    starlevels(* 0.10 ** 0.05 *** 0.01) stats(r2) ///
    title("Unrestricted Regressions") ///
    replace

esttab regr1 regr2 regr3 using "restricted_regr.tex", ///
    starlevels(* 0.10 ** 0.05 *** 0.01) stats(r2) ///
    title("Restricted Regressions") ///
    replace

** MRV Augmented regression **
* Unrestricted regressions (no restrictions on coefficients)
regress ly85 ls lngd lschool if n == 1
scalar beta_ls1 = _b[ls]
scalar beta_lngd1 = _b[lngd]
scalar beta_lschool1 = _b[lschool]

regress ly85 ls lngd lschool if i == 1
scalar beta_ls2 = _b[ls]
scalar beta_lngd2 = _b[lngd]
scalar beta_lschool2 = _b[lschool]

regress ly85 ls lngd lschool if o == 1
scalar beta_ls3 = _b[ls]
scalar beta_lngd3 = _b[lngd]
scalar beta_lschool3 = _b[lschool]

* Regressions with restrictions (for non-Oil, Intermediate, and OECD groups)
regress ly85 ls_lngd lsch_ngd if n == 1
scalar beta_ls_lngd1 = _b[ls_lngd]
scalar beta_lschool_ngd1 = _b[lsch_ngd]

regress ly85 ls_lngd lsch_ngd if i == 1
scalar beta_ls_lngd2 = _b[ls_lngd]
scalar beta_lschool_ngd2 = _b[lsch_ngd]

regress ly85 ls_lngd lsch_ngd if o == 1
scalar beta_ls_lngd3 = _b[ls_lngd]
scalar beta_lschool_ngd3 = _b[lsch_ngd]

* Calculate implied alpha and beta for the unrestricted regressions
gen alpha1 = beta_ls1 / (1 + beta_ls1 + beta_lschool1)
gen beta1 = beta_lschool1 / (1 + beta_ls1 + beta_lschool1)

gen alpha2 = beta_ls2 / (1 + beta_ls2 + beta_lschool2)
gen beta2 = beta_lschool2 / (1 + beta_ls2 + beta_lschool2)

gen alpha3 = beta_ls3 / (1 + beta_ls3 + beta_lschool3)
gen beta3 = beta_lschool3 / (1 + beta_ls3 + beta_lschool3)

di alpha1
di beta1

di alpha2
di beta2

di alpha3
di beta3


* Calculate implied alpha and beta for the restricted regressions
gen alpha_r1 = beta_ls_lngd1 / (1 + beta_ls_lngd1 + beta_lschool_ngd1)
gen beta_r1 = beta_lschool_ngd1 / (1 + beta_ls_lngd1 + beta_lschool_ngd1)

gen alpha_r2 = beta_ls_lngd2 / (1 + beta_ls_lngd2 + beta_lschool_ngd2)
gen beta_r2 = beta_lschool_ngd2 / (1 + beta_ls_lngd2 + beta_lschool_ngd2)

gen alpha_r3 = beta_ls_lngd3 / (1 + beta_ls_lngd3 + beta_lschool_ngd3)
gen beta_r3 = beta_lschool_ngd3 / (1 + beta_ls_lngd3 + beta_lschool_ngd3)

di alpha_r1
di beta_r1

di alpha_r2
di beta_r2

di alpha_r3
di beta_r3


eststo clear
eststo reg1: regress ly85 ls lngd lschool if n == 1
eststo reg2: regress ly85 ls lngd lschool if i == 1
eststo reg3: regress ly85 ls lngd lschool if o == 1

eststo reg_r1: regress ly85 ls_lngd lsch_ngd if n == 1
eststo reg_r2: regress ly85 ls_lngd lsch_ngd if i == 1
eststo reg_r3: regress ly85 ls_lngd lsch_ngd if o == 1

esttab reg1 reg2 reg3 reg_r1 reg_r2 reg_r3 using mrw_results.tex,    /// 
		starlevels(* 0.10 ** 0.05 *** 0.01) stats(r2) ///
		replace
	
*Convergence (uncoditional and conditional)
gen dly = ly85 - ly60
* Clear previous estimates
eststo clear
eststo reg1: regress dly ly60 if n == 1
eststo reg2: regress dly ly60 if i == 1
eststo reg3: regress dly ly60 if o == 1

eststo reg_r1: regress dly ly60 ls lngd lschool if n == 1
eststo reg_r2: regress dly ly60 ls lngd lschool if i == 1
eststo reg_r3: regress dly ly60 ls lngd lschool if o == 1


* Run the regressions for each group
* Unrestricted Regressions

* Non-Oil Group
preserve
regress dly ly60 if n == 1
eststo reg1
* Extract coefficient of ly60 for implied lambda
local lambda_n = log(_b[ly60]+1)/25
display "Implied lambda for Non-Oil Group: " -`lambda_n'
restore

* Intermediate Group
preserve
regress dly ly60 if i == 1
eststo reg2
* Extract coefficient of ly60 for implied lambda
local lambda_i = log(_b[ly60]+1)/25
display "Implied lambda for Intermediate Group: " -`lambda_i'
restore

* OECD Group
preserve
regress dly ly60 if o == 1
eststo reg3
* Extract coefficient of ly60 for implied lambda
local lambda_o = log(_b[ly60]+1)/25
display "Implied lambda for OECD Group: " -`lambda_o'
restore

* Restricted Regressions (including other variables)

* Non-Oil Group
preserve
regress dly ly60 ls lngd lschool if n == 1
eststo reg_r1
* Extract coefficient of ly60 for implied lambda
local lambda_r1 = log(_b[ly60]+1)/25
display "Implied lambda for Non-Oil Group (Restricted): " -`lambda_r1'
restore

* Intermediate Group
preserve
regress dly ly60 ls lngd lschool if i == 1
eststo reg_r2
* Extract coefficient of ly60 for implied lambda
local lambda_r2 = log(_b[ly60]+1)/25
display "Implied lambda for Intermediate Group (Restricted): " -`lambda_r2'
restore

* OECD Group
preserve
regress dly ly60 ls lngd lschool if o == 1
eststo reg_r3
* Extract coefficient of ly60 for implied lambda
local lambda_r3 = log(_b[ly60]+1)/25
display "Implied lambda for OECD Group (Restricted): " -`lambda_r3'
restore
	
	
