

clear
set more off
set matsize 10000
use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
cd "C:\Users\Amarendra\Desktop\Yashaswi_Education"

gen ln_wages = log(wages)
gen age_sq= age^2


*Question 1*

/*Producing OLS coefficients for 61st and 68th rounds as shown in 
tables 4 and 5 */

reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg i.state_region_reg#c.yrs_edu if round==61 & age >= 21, robust cluster(village_id_no)
outreg2 using 1tables45.doc, replace ctitle(OLS) keep(yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste)

reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg i.state_region_reg#c.yrs_edu if round==68 & age >= 21, robust cluster(village_id_no)
outreg2 using 1table45.doc, append ctitle(OLS) keep(yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste)


/*Producing Stats as presented in table 6*/

statsby, saving(reground61.dta, replace) : reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg i.state_region_reg#c.yrs_edu if round==61 & age>= 21, robust cluster(village_id_no)
clear
use reground61.dta

foreach var of varlist _stat_93 - _stat_170 {
  generate ER`var' = `var'+ _b_yrs_edu 
}
drop _b_yrs_edu -_b_cons

xpose, clear
rename v1 ERround61
summarize ERround61 /*this will generate stats as required in table 6*/
gen state_region_reg =_n
gen round=68
save reground61.dta, replace

clear all

use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
gen ln_wages = log(wages)
gen age_sq= age^2
statsby, saving(reground68.dta, replace) : reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg i.state_region_reg#c.yrs_edu if round==68 & age>= 21, robust cluster(village_id_no)
clear
use reground68.dta
foreach var of varlist _stat_93 - _stat_170 {
  generate ER`var' = `var'+ _b_yrs_edu 
}
drop _b_yrs_edu-_b_cons
xpose, clear
rename v1 ERround68
summarize ERround68 /*this will generate stats as required in table 6*/
gen state_region_reg =_n
gen round=68
save reground68.dta, replace
clear

/*Producing results as in table 7 for individuals only for round 68 
- both OLs and IV  */

**OLS**
use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
drop _merge
merge m:1 state_region_reg round using "C:\Users\Amarendra\Desktop\Yashaswi_Education\reground61.dta"
drop _merge
merge m:1 state_region_reg round using "C:\Users\Amarendra\Desktop\Yashaswi_Education\reground68.dta"

reg yrs_edu ERround68 female urban hh_exp hh_educ sch_tribe sch_caste age6-age20 if round==68 & age>= 5 & age <= 20, robust cluster(state_region)
outreg2 using 1table7.doc, replace ctitle(OLS)

**IV**
ivreg yrs_edu (ERround68 = ERround61) female urban hh_exp hh_educ sch_tribe sch_caste age6-age20 if round==68 & age>= 5 & age <= 20, robust cluster(state_region)
outreg2 using 1table7.doc, append ctitle(IV) 
***End of Question 1 - couldn't produce table 8 - the expenditure quartiles part***






*Question 2*

clear all
use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
gen ln_wages = log(wages)
gen age_sq= age^2

/*Redoing the analysis assuming returns vary by gender#caste and not by 
state-region.
Producing OLS coefficients for 61st and 68th rounds as shown in 
tables 4 and 5 */

gen GC = 0 /*GC- gender*caste - base category is male#other than SC and ST*/
replace GC = 1 if female ==1 & sch_tribe == 1
replace GC = 2 if female ==1 & sch_caste == 1
replace GC = 3 if female == 0 & sch_tribe == 1
replace GC = 4 if female == 0 & sch_caste == 1
replace GC = 5 if female == 1 & sch_caste == 0 & sch_tribe == 0

tab GC

reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste state_region_reg  i.GC#c.yrs_edu if round==61 & age >= 21, robust cluster(village_id_no)
outreg2 using 2table45.doc, replace ctitle(OLS) keep(yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.GC#c.yrs_edu)

reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste state_region_reg i.GC#c.yrs_edu  if round==68 & age >= 21, robust cluster(village_id_no)
outreg2 using 2table45.doc, append ctitle(OLS) keep(yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.GC#c.yrs_edu)
 
/*Producing Stats as presented in table 6*/

statsby, saving(reground612.dta, replace) : reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste state_region_reg i.GC#c.yrs_edu if round==61 & age >= 21, robust cluster(village_id_no)
clear
use reground612.dta

foreach var of varlist _stat_16 - _stat_21 {
  generate ER`var' = `var'+ _b_yrs_edu 
}
drop _b_yrs_edu -_b_cons

xpose, clear
rename v1 ERround61
summarize ERround61 /*this will generate stats as required in table 6*/
gen GC =_n
gen round=68
save reground612.dta, replace

clear all

use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
gen ln_wages = log(wages)
gen age_sq= age^2

gen GC = 0 /*GC- gender*caste - base category is male#other than SC and ST*/
replace GC = 1 if female ==1 & sch_tribe == 1
replace GC = 2 if female ==1 & sch_caste == 1
replace GC = 3 if female == 0 & sch_tribe == 1
replace GC = 4 if female == 0 & sch_caste == 1
replace GC = 5 if female == 1 & sch_caste == 0 & sch_tribe == 0


statsby, saving(reground682.dta, replace) : reg ln_wages yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste state_region_reg i.GC#c.yrs_edu if round==68 & age>= 21, robust cluster(village_id_no)
clear
use reground682.dta
foreach var of varlist _stat_16 - _stat_21 {
  generate ER`var' = `var'+ _b_yrs_edu 
}
drop _b_yrs_edu-_b_cons
xpose, clear
rename v1 ERround68
summarize ERround68 /*this will generate stats as required in table 6*/
gen GC =_n
gen round=68
save reground682.dta, replace
clear

/*Producing results as in table 7 for individuals only for round 68 
- both OLs and IV  */

**OLS**
use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
gen GC = 0 /*GC- gender*caste - base category is male#other than SC and ST*/
replace GC = 1 if female ==1 & sch_tribe == 1
replace GC = 2 if female ==1 & sch_caste == 1
replace GC = 3 if female == 0 & sch_tribe == 1
replace GC = 4 if female == 0 & sch_caste == 1
replace GC = 5 if female == 1 & sch_caste == 0 & sch_tribe == 0

drop _merge
merge m:1 GC round using "C:\Users\Amarendra\Desktop\Yashaswi_Education\reground612.dta"
drop _merge
merge m:1 GC round using "C:\Users\Amarendra\Desktop\Yashaswi_Education\reground682.dta"

reg yrs_edu ERround68 female urban hh_exp hh_educ sch_tribe sch_caste age6-age20 if round==68 & age>= 5 & age <= 20, robust cluster(GC)
outreg2 using 2table7.doc, replace ctitle(OLS)
**IV**
ivreg yrs_edu (ERround68 = ERround61) female urban hh_exp hh_educ sch_tribe sch_caste age6-age20 if round==68 & age>= 5 & age <= 20, robust cluster(GC)
outreg2 using 2table7.doc, append ctitle(IV)  
***End of question 2***




*Question 3*

clear all
use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
gen ln_wages = log(wages)
gen age_sq= age^2

/* Let's first incorporate the fact that marginal returns to
education differ depending on where the child is in his/her education
trajectory*/

reg ln_wages i.yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg if round==61 & age >= 21, robust cluster(village_id_no)
outreg2 using 3tables45.doc, replace ctitle(OLS) keep(i.yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste)

reg ln_wages i.yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg if round==68 & age >= 21, robust cluster(village_id_no)
outreg2 using 3tables45.doc, append ctitle(OLS) keep(i.yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste)

/*Suppose instead of years of schooling, we are to look at the current
decision: whether a child is attending an educational institution
conditional on having already reached a particular level of education*/

/* previously in table 7, years of education was our explained variable and the explanatory
variable was Education Returns at a state region level or for a gender-caste combination.
Now, we have to take Status of current attendance as explained variable and Education returns 
at different levels of education as the main explanatory variable*/

statsby, saving(reground613.dta, replace):reg ln_wages i.yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg if round==61 & age >= 21, robust cluster(village_id_no)
clear all
use 61question3.dta
drop _b_hours-_b_cons
xpose, clear
rename v1 ERround61
gen index =_n 
gen round=68
save reground613.dta, replace
clear all


use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
gen ln_wages = log(wages)
gen age_sq= age^2

statsby, saving(reground683.dta, replace): reg ln_wages i.yrs_edu hours age age_sq female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste i.state_region_reg if round==68 & age >= 21, robust cluster(village_id_no)
clear all
use reground683.dta

drop _b_hours-_b_cons
xpose, clear
rename v1 ERround68
gen index =_n
gen round=68
save reground683.dta, replace
clear all


use "C:\Users\Amarendra\Desktop\Yashaswi_Education\Assignment2\data_set.dta" 
sort yrs_edu
egen index = group(yrs_edu)
drop _merge
merge m:1 index round using "C:\Users\Amarendra\Desktop\Yashaswi_Education\reground613.dta"
drop _merge
merge m:1 index round using "C:\Users\Amarendra\Desktop\Yashaswi_Education\reground683.dta"

/*Producing results as in table 7 for individuals only for round 68 
- both OLs and IV  */

gen abs_att_status = 0
replace abs_att_status = 1 if status_curr_att <= 10

reg abs_att_status ERround68 hours age6-age18 female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste if round==68 & age>=6 & age<=18
outreg2 using 3table7.doc, replace ctitle(OLS)

ivreg abs_att_status (ERround68 = ERround61) hours age6-age18 female urban married rel_muslim rel_christ rel_sikh rel_jain rel_buddha sch_tribe sch_caste if round==68 & age>=6 & age<=18
outreg2 using 3table7.doc, append ctitle(IV)

*End of question 3*

