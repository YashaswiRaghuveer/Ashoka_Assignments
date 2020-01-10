* calculating attendance and enrollment

clear
set more off
global edu "/Users/Yashaswi/Dropbox/Education_Ashoka/data/education/Nss71_25.2/data_output/"

cd "$edu"
use level03, clear

* Attending
gen curr_att=1 if st_curr_edu_attendance>=3 & st_curr_edu_attendance<=7 & st_curr_edu_attendance~=.
replace curr_att =0 if st_curr_edu_attendance==1 | st_curr_edu_attendance==2


* weights
gen weight=round(multiplier/100) if nss==nsc
replace weight=round(multiplier/200) if nss~=nsc

* Age groups: 6-10
gen age_grp=1 if age>=6 & age<=10 & age~=.

*Age groups: 11-14
replace age_grp=2 if age>=11 & age<=14 & age~=.
* Age groups: 15-17
replace age_grp=3 if age>=15 & age<=17 & age~=.



* Just like the figure : this is the attendance and enrollment rate
tab curr_att if age_grp==1 [fw=weight]

* Enrolment
gen curr_enrolled=1 if curr_att==1 /* if you are attending you are enrolled */
replace curr_enrolled=1 if curr_att==0 & st_curr_edu_enrolment~=1 & st_curr_edu_enrolment~=. /*if you not attending but enrolled  (~ NOT Enrolled) */
replace curr_enrolled =0  if curr_att==0 & st_curr_edu_enrolment==1  /* Not attending and not enrolled */

* Here the age group is fixed and we are finding proportions
tab curr_enrolled if age_grp==1 [fw=weight]
tab curr_enrolled if age_grp==2 [fw=weight]


tab curr_att if age_grp==1 [fw=weight]

tab curr_att if age_grp==2 [fw=weight]

*Drop out
drop if person_srl_no=="0/" /* Data Error */
destring person_srl_no, replace
ren fod_sub_region fod_sub_region_master /* some format difference in the variable */
merge 1:1 common_id person_srl_no  using level06

gen drop_out=1 if wh_ever_enrolled==1 & curr_enrolled==0
replace drop_out=0 if  curr_enrolled==1

tab drop_out if age_grp==1 [fw=weight]
tab drop_out if age_grp==2 [fw=weight]
tab drop_out if age_grp==3 [fw=weight]



*But this is not gross enrolment rate
* Gross enrolment/Attendance Ratio (GER/GAR) is for education levels: not age groups: So different from Enrolment/ Attendance Ratio given above
* GER for Primary schooling = (Total Children enrolled in Primary School / Children in the age group when one goes to primary school)
* Assumption: Primary School age=6-10.

* To know what level of class the student is attending we need to bring in level 05 information.

drop if person_srl_no=="0/" /* Data Error */
destring person_srl_no, replace
merge 1:1 common_id person_srl_no  using level05

* Gross Attendance rate (GAR): Primary Schooling
************************************************


gen prim_att=weight if  level_curr_attendence==7 /* How many children are attending primary school */

egen t_prim_att=sum(prim_att) /* Total number of children attending primary school for India */
gen ipop6_10=weight if age_grp==1
egen pop_6_10=sum(ipop6_10) /* Total Population of children aged 6-10 for India */

gen gattr_prim=t_prim_att*100/pop_6_10 /* Gross Attendance Rate for Primary Schooling */
su gattr_prim

* Gender Wise GAR
bys sex: egen t_prim_att_sex=sum(prim_att) /* Gender wise: number of children attending primary school for India */
bys sex: egen pop_6_10_sex=sum(ipop6_10) /* Gender wise : Population of children aged 6-10 for India */

gen gatt_prim_sex=t_prim_att_sex*100/pop_6_10_sex /*Genderwise Gross Attendance Rate for Primary Schooling */
by sex: su gatt_prim_sex 


* Gross Enrolment Rate (GER)  : Primary Schooling
***************************************************



gen prim_curr_enrolled= weight if curr_enrolled==1 & level_curr_attendence==7  /* How many children enrolled in primary school: these ones also attend */
replace prim_curr_enrolled= weight if curr_enrolled==1 & st_curr_edu_enrolment==7 /* How many children enrolled in primary school: these ones don't attend */

egen t_prim_enrol=sum(prim_curr_enrolled) /* Total number of children enrolled in primary school for India */

gen ger_prim=t_prim_enrol*100/pop_6_10 /* Gross Enrollemnt Rate for Primary Schooling */

su ger_prim gattr_prim


* Gender Wise GER for Primary Schooling
bys sex: egen t_prim_enrol_sex=sum(prim_curr_enrolled) /* Gender wise: number of children attending primary school for India */

gen ger_prim_sex=t_prim_enrol_sex*100/pop_6_10_sex /*Genderwise Gross Enrolment Rate for Primary Schooling */

by sex: su ger_prim_sex gatt_prim_sex 



