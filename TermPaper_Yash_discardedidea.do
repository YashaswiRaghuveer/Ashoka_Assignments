

clear

cd "C:\Users\Amarednra\Desktop\Yashaswi_Termpaper\Yash_CleanData\Regressions"

*merging DS0001 and DS0002 of IHDS2
use 36151-0002-Data, clear
merge 1:m IDHH using 36151-0001-Data
drop _merge
keep if RO3=="Female 2":RO3 //data for only women remain
keep if RO6=="Married 1":RO6 //data for only married people remain
merge 1:1 IDPERSON using 36151-0003-Data
keep if _merge==3

save "IHDS_2 0001 0002 0003 merged", replace

**Starting Data cleaning**

use "IHDS_2 0001 0002 0003 merged", clear

gen groom_wed_spent = (MP3B + MP3A)/2 // average money spent by groom's family in the wedding
label variable groom_wed_spent "Average money spent by groom's family in the wedding"
gen bride_wed_spent = (MP4A + MP4B)/2 // average money spent by bride's family in the wedding
label variable bride_wed_spent "Average money spent by bride's family in the wedding"

*following creates and equal weighted non-cash dowry index OF 2012
foreach var in MP6A MP6B  MP6C MP6D MP6E MP6F MP6G MP6H MP6I MP6J MP6K MP6L MP6M MP6N MP6O MP6P MP6Q MP6R MP6S MP6T MP6U MP6V{
 gen `var'_1 = string([`var'])
 destring (`var'_1) , generate (`var'_2)
 replace `var'_2 = 0 if `var'_2 == 1
 replace `var'_2 = 1 if `var'_2 == 2 | `var'_2 == 3

}

gen dowryindex2012 = (MP6A_2 + MP6B_2 + MP6C_2+ MP6D_2+ MP6E_2+ MP6F_2+ MP6G_2+ MP6H_2+ MP6I_2+ MP6J_2+ MP6K_2+ MP6L_2+ ///
MP6M_2+ MP6N_2+ MP6O_2+ MP6P_2+ MP6Q_2 +MP6R_2 + MP6S_2 +MP6T_2 + MP6U_2 + MP6V_2)/22
label variable dowryindex2012 "Equally weighted Dowry Index"

gen dowryindex_weight = (4*(MP6A_2 + MP6B_2 + MP6C_2+ MP6D_2+ MP6T_2) + ///
2*(MP6E_2+ MP6F_2+ MP6G_2+ MP6H_2+ MP6I_2+ MP6Q_2 +  MP6R_2 + MP6U_2 +MP6V_2) ///
 + MP6J_2+ MP6K_2+ MP6L_2+ MP6M_2+ MP6N_2+ MP6O_2+ MP6P_2+ MP6S_2)/46
label variable dowryindex_weight "Weighted Dowry Index"


gen AverageCash_2012 = (MP7B+ MP7A)/2 //generates average cash given by bride's family in wedding
label variable AverageCash_2012 "Average Cash Dowry"

gen beating_by_huband = (GR34 + GR35 + GR36 + GR37 + GR38 + GR39)/6
label variable beating_by_huband "Usual for Husbands to beat wives in the community"

gen Act_Gauna = 0
replace Act_Gauna = 1 if MH1DY>= 2005
label variable Act_Gauna "Inheritance act; 0= gauna before 2005, 1= gauna in/after 2005"

gen Act_Marriage = 0
replace Act_Marriage = 1 if MH1BY>= 2005
label variable Act_Marriage "Inheritance act; 0= marriage before 2005, 1= marriage in/after 2005"

*Respondent has the most say: Index

gen most_say = (GR1A + 3*GR2A +5*GR3A + 2*GR4A +4*GR5A +3*GR6A + 2*GR7A + 4*GR8A)/24
label variable most_say "Respondent has most say: Index"

gen most_say_eq = (GR1A + GR2A + GR3A + GR4A +GR5A +GR6A + GR7A + GR8A)/8 //equally weighted index

*Respondent needs to take permission: Index

gen perm_hc = 1
replace perm_hc = 0 if GR9A== "Yes 2":GR9A
label variable perm_hc "Respondent doesn't need permission to visit health centre"

gen perm_relatives = 1
replace perm_relatives = 0 if GR10A== "Yes 2":GR10A
label variable perm_relatives "Respondent doesn't need permission to visit relatives/friends"

gen perm_kirana = 1
replace perm_kirana = 0 if GR11A== "Yes 2":GR11A
label variable perm_kirana "Respondent doesn't need permission to visit kirana shop"

gen perm_train = 1
replace perm_train = 0 if GR12A== "Yes 2":GR12A
label variable perm_train "Respondent doesn't need permission to travel short distances by train/bus"

gen needs_perm = (2*perm_hc + 3*perm_relatives + perm_kirana + 2*perm_train)/8
label variable needs_perm "Respondent does not need permission: Index"

gen needs_perm_eq = (perm_hc + perm_relatives + perm_kirana + perm_train)/4 //equally weighted index

*Husband speaks to the respondent on various topics: Index
gen disc_work =1
replace disc_work = 0 if GR29A== 0
label variable disc_work "Husband discusses work with respondent"

gen disc_exp =1
replace disc_exp = 0 if GR29B== 0
label variable disc_exp "Husband discusses expenditure with respondent"

gen disc_politics =1
replace disc_politics = 0 if GR29C== 0
label variable disc_politics "Husband discusses politics with respondent"

gen husband_discusses = (disc_work + disc_exp + disc_politics)/3
label variable husband_discusses "Husban discusses various issues with the respondent: Index"

gen work_autonomy = 0
replace work_autonomy =1 if GR47==1
label variable work_autonomy "Respondent has the most say about her work"

gen log_dowry = log(dowryindex_weight)
label variable log_dowry "Log of Weighted Dowry Index"

gen dowry_g =log_dowry*Act_Gauna
gen dowry_m =log_dowry*Act_Marriage
gen cash_g = AverageCash_2012*Act_Gauna
gen cash_m = AverageCash_2012*Act_Marriage

save "IHDS_2 0001 0002 0003 merged Females", replace


use "IHDS_2 0001 0002 0003 merged Females", clear

*Summary Stats*

label variabel GR10A_1 "Respondent doesn't need permission to visit relatives/friends"

gen Hindu = 0
replace Hindu = 1 if ID11 == "Hindu 1":ID11

gen autonomy_index = (perm_relatives + GR3A + GR1A + GR26 + work_autonomy)/5
label variable autonomy_index "Autonomy Index"

gen interaction =  log_dowry*Hindu*Act_Gauna
label variable interaction "Log Dowry Index*Hindu*Inheritence Act"

asdoc sum RO5 MH1A MH1C dowryindex_weight AverageCash_2012 perm_relatives GR3A GR1A GR26 ///
work_autonomy autonomy_index Act_Gauna Religion, statistics(mean sd min max) ///
columns(statistics) by(Act_Gauna) save(Summary) label replace


save "IHDS_2 0001 0002 0003 merged Females", replace


*Difference in Difference

foreach var in dowryindex_weight AverageCash_2012 perm_relatives GR3A GR1A GR26 work_autonomy autonomy_index{

      diff `var', t(Religion) p(Act_Gauna)
	  diff `var', t(Act_Gauna) p(Religion)
	  }

	 
*Regressions*

*Simple OLS*

foreach var in perm_relatives GR3A  {
reg `var' RO5 i.EDUC7 EW12A EW12C EW12B EW12D i.EW15A i.EW15B i.EW15C i.EW15D /// 
EW17A EW17C EW17B EW17D groom_wed_spent bride_wed_spent SPED6 MH1BY ///    
log_dowry MH1DY MH7 i.MH10 i.MH13 i.URBAN4_2011 ///                         
MP1A i.EW10 GR20 GR27B GR33 EW13C EW13D FH5SK beating_by_huband  DISTRICT ///
Hindu Act_Gauna i.GROUPS AverageCash_2012
outreg2 using OLS1.doc, append label keep(AverageCash_2012 log_dowry Hindu Act_Gauna) ///
addtext(Individual and Household Controls, Yes, District Fixed Effects, Yes, Log Dowry Index*Hindu*Gauna after 2005 Control, No)
}
*

foreach var in GR1A GR26  {
reg `var' RO5 i.EDUC7 EW12A EW12C EW12B EW12D i.EW15A i.EW15B i.EW15C i.EW15D /// 
EW17A EW17C EW17B EW17D groom_wed_spent bride_wed_spent SPED6 MH1BY ///    
log_dowry MH1DY MH7 i.MH10 i.MH13 i.URBAN4_2011 ///                         
MP1A i.EW10 GR20 GR27B GR33 EW13C EW13D FH5SK beating_by_huband  DISTRICT ///
Hindu Act_Gauna i.GROUPS AverageCash_2012
outreg2 using OLS2.doc, append label keep(AverageCash_2012 log_dowry Hindu Act_Gauna) ///
addtext(Individual and Household Controls, Yes, District Fixed Effects, Yes, Log Dowry Index*Hindu*Gauna after 2005 Control, No)
}
*

foreach var in work_autonomy autonomy_index {
reg `var' RO5 i.EDUC7 EW12A EW12C EW12B EW12D i.EW15A i.EW15B i.EW15C i.EW15D /// 
EW17A EW17C EW17B EW17D groom_wed_spent bride_wed_spent SPED6 MH1BY ///    
log_dowry MH1DY MH7 i.MH10 i.MH13 i.URBAN4_2011 ///                         
MP1A i.EW10 GR20 GR27B GR33 EW13C EW13D FH5SK beating_by_huband  DISTRICT ///
Hindu Act_Gauna i.GROUPS AverageCash_2012
outreg2 using OLS3.doc, append label keep(AverageCash_2012 log_dowry Hindu Act_Gauna) ///
addtext(Individual and Household Controls, Yes, District Fixed Effects, Yes, Log Dowry Index*Hindu*Gauna after 2005 Control, No)
}
*

*OLS with Interaction*

foreach var in perm_relatives GR3A  {
reg `var' RO5 i.EDUC7 EW12A EW12C EW12B EW12D i.EW15A i.EW15B i.EW15C i.EW15D /// 
EW17A EW17C EW17B EW17D groom_wed_spent bride_wed_spent SPED6 MH1BY ///    
log_dowry MH1DY MH7 i.MH10 i.MH13 i.URBAN4_2011 ///                         
MP1A i.EW10 GR20 GR27B GR33 EW13C EW13D FH5SK beating_by_huband  DISTRICT ///
Hindu Act_Gauna i.GROUPS interaction AverageCash_2012
outreg2 using Interaction1.doc, append label keep(AverageCash_2012 log_dowry Hindu Act_Gauna interaction) ///
addtext(Individual and Household Controls, Yes, District Fixed Effects, Yes, Log Dowry Index*Hindu*Gauna after 2005 Control, Yes)
}
*

foreach var in GR1A GR26  {
reg `var' RO5 i.EDUC7 EW12A EW12C EW12B EW12D i.EW15A i.EW15B i.EW15C i.EW15D /// 
EW17A EW17C EW17B EW17D groom_wed_spent bride_wed_spent SPED6 MH1BY ///    
log_dowry MH1DY MH7 i.MH10 i.MH13 i.URBAN4_2011 ///                         
MP1A i.EW10 GR20 GR27B GR33 EW13C EW13D FH5SK beating_by_huband  DISTRICT ///
Hindu Act_Gauna i.GROUPS interaction AverageCash_2012
outreg2 using Interaction2.doc, append label keep(AverageCash_2012 log_dowry Hindu Act_Gauna interaction) ///
addtext(Individual and Household Controls, Yes, District Fixed Effects, Yes, Log Dowry Index*Hindu*Gauna after 2005 Control, Yes)
}
*

foreach var in work_autonomy autonomy_index {
reg `var' RO5 i.EDUC7 EW12A EW12C EW12B EW12D i.EW15A i.EW15B i.EW15C i.EW15D /// 
EW17A EW17C EW17B EW17D groom_wed_spent bride_wed_spent SPED6 MH1BY ///    
log_dowry MH1DY MH7 i.MH10 i.MH13 i.URBAN4_2011 ///                         
MP1A i.EW10 GR20 GR27B GR33 EW13C EW13D FH5SK beating_by_huband  DISTRICT ///
Hindu Act_Gauna i.GROUPS interaction AverageCash_2012
outreg2 using Interaction3.doc, append label keep(AverageCash_2012 log_dowry Hindu Act_Gauna interaction) ///
addtext(Individual and Household Controls, Yes, District Fixed Effects, Yes, Log Dowry Index*Hindu*Gauna after 2005 Control, Yes)
}
*

*Appendix Summary Statistics*

gen group = group(Act_Gauna Hindu)

asdoc sum RO5 MH1A MH1C dowryindex_weight dowryindex2012 AverageCash_2012 perm_relatives GR3A GR8A GR26 ///
work_autonomy disc_politics disc_exp, statistics(mean sd min max) ///
columns(statistics) by(Act_Gauna) save(table2) label replace

asdoc sum RO5 MH1A MH1C dowryindex_weight dowryindex2012 AverageCash_2012 perm_relatives GR3A GR8A GR26 ///
work_autonomy disc_politics disc_exp, statistics(mean sd min max) ///
columns(statistics) by(Act_Marriage) save(table2) label append

asdoc sum RO5 MH1A MH1C dowryindex_weight dowryindex2012 AverageCash_2012 perm_relatives GR3A GR8A GR26 ///
work_autonomy disc_politics disc_exp, statistics(mean sd min max) ///
columns(statistics) by(group) save(table2) label append

save "IHDS_2 0001 0002 0003 merged Females", replace
