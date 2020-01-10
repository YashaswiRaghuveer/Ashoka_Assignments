set more off

cd "/Users/Yashaswi/Dropbox/Ashoka/ECON 508/Term Paper/Term Paper Data/Scripting"

* Open individual dataset
use "/Users/Yashaswi/Dropbox/Ashoka/ECON 508/Term Paper/Term Paper Data/2012 IHDS/DS0001/36151-0001-Data.dta", clear

* Merge with household-level data to obtain occupation and industry 
* of household head's father and caste association membership data
merge m:m IDHH using "/Users/Yashaswi/Dropbox/Ashoka/ECON 508/Term Paper/Term Paper Data/2012 IHDS/DS0002/36151-0002-Data.dta", keepusing(ME8 ID18A ID18B)
drop _merge

* Pick up intercaste marriage data from `eligible women` dataset
merge m:m IDHH using "/Users/Yashaswi/Dropbox/Ashoka/ECON 508/Term Paper/Term Paper Data/2012 IHDS/DS0003/36151-0003-Data.dta", keepusing(MH7)


* Recode caste categorisation to club Brahmin and Forward Caste
recode ID13 (1/2 = 1) (3 = 2) (4 = 3) (5 = 4) (6 = 5)
label define ID13 1 "Brahmin and Forward Caste" 2 "Other Backward Castes (OBC)" ///
3 "Scheduled Castes (SC)" 4 "Scheduled Tribes (ST)" 5 "Others", modify
label val ID13 ID13

**************************Summary Statistics************************************

save preCollapse.dta, replace
**** income ****
bysort ID13: asdoc summarize INCOME if INCOME >1000 & INCOME <2000000, detail replace save(income.doc)
collapse ID13 INCOME, by(IDHH)
bysort ID13: asdoc summarize INCOME if INCOME >1000 & INCOME <2000000, detail label replace save(incomeCollapsed.doc)

**** income per capita ******
use preCollapse, clear
collapse ID13 INCOMEPC, by(IDHH)
bysort ID13: asdoc summarize INCOMEPC if INCOMEPC >250 & INCOMEPC <400000, detail replace save(incomePerCapita.doc)

**** educ ****
use preCollapse, clear
collapse ID13 HHEDUC, by(IDHH)
bysort ID13: asdoc tab HHEDUC ID13, replace save(education.doc)

****rural/urban******
use preCollapse, clear
bysort ID13: asdoc tab ID13 URBAN4_2011, replace save(ruralUrban.doc)

* Calculate size of households
capture drop hhSize
bysort IDHH: egen hhSize = count(IDHH)
replace hhSize = hhSize - 1

* Summarise by caste
bysort ID13: asdoc sum hhSize, replace save(hhSize.doc)

* drop _merge
* merge m:m IDPSU using "/Users/Yashaswi/Dropbox/Ashoka/ECON 508/Term Paper/Term Paper Data/2012 IHDS/DS0012/12withUniqueID.dta", keepusing(VH1*)

* drop those listed under non-remunerative occupations or out of the labour force
drop if inlist(ID18A,101,109,111,112,113,114,115,.)
drop if inlist(WS4,101,109,111,112,113,114,115,.)
* tab ID18A

* Classify workers in accordance with the labels below
label define occupationClassification 101 "Legislators, Senior Officials, Managers, and Professionals" ///
102 "Associate Professionals" 103 "Clerks" 104 "Service and Retail Workers" ///
105 "Craft and Related Trades" 106 "Plant and Machinery Workers" ///
107 "Elementary Occupations" 108 "Police" 109 "Miscellaneous"

* HHFs -> Household head's father *
gen HHFsOccup = 0 
replace HHFsOccup = 101 if inlist(ID18A,0,1,2,3,5,6,7,9,10,11,12,13,14,15,16,17,18,19,4,20,21,22,23,24,25,26,29,31,60)
replace HHFsOccup = 102 if inlist(ID18A,8,36,38)
replace HHFsOccup = 103 if inlist(ID18A,30,32,33,34,35,39)
replace HHFsOccup = 104 if inlist(ID18A,37,40,42,43,44,45,49,50,51,52,56,59)
replace HHFsOccup = 105 if inlist(ID18A,75,76,78,79,80,81,82,85,87,88,89)
replace HHFsOccup = 106 if inlist(ID18A,72,83,84,85,90,97,98)
replace HHFsOccup = 107 if inlist(ID18A,53,54,55,61,62,63,64,65,66,68,95,97,99)
replace HHFsOccup = 108 if inlist(ID18A,57)
replace HHFsOccup = 109 if inlist(ID18A,41,67,71,73,74,77,86,91,92,93,96,94) 

* Individual's occupation *
gen individualOccup = 0
replace individualOccup = 101 if inlist(WS4,0,1,2,3,5,6,7,9,10,11,12,13,14,15,16,17,18,19,4,20,21,22,23,24,25,26,29,31,60)
replace individualOccup = 102 if inlist(WS4,8,36,38)
replace individualOccup = 103 if inlist(WS4,30,32,33,34,35,39)
replace individualOccup = 104 if inlist(WS4,37,40,42,43,44,45,49,50,51,52,56,59)
replace individualOccup = 105 if inlist(WS4,75,76,78,79,80,81,82,85,87,88,89)
replace individualOccup = 106 if inlist(WS4,72,83,84,85,90,97,98)
replace individualOccup = 107 if inlist(WS4,53,54,55,61,62,63,64,65,66,68,95,97,99)
replace individualOccup = 108 if inlist(WS4,57)
replace individualOccup = 109 if inlist(WS4,41,67,71,73,74,77,86,91,92,93,96,94) 

* Assign labels to variables
label val HHFsOccup occupationClassification
label val individualOccup occupationClassification

* tab HHFsOccup
* tab individualOccup

* Create dummy for individuals whose preceding two generations persisted in the same occupation
gen persistenceAcrossTwoGenerations = cond(HHFsOccup == individualOccup & (RO4 == 1 | RO4 == 2 | RO4 == 7 | RO4 == 10), 1, 0)
label define twoGen 



* Create a dummy for individuals who practice the same occupation as their grandparent(s)
gen interstitialPersistence = cond(HHFsOccup == individualOccup & (RO4 == 3 | RO4 == 4 | RO4 == 5 | RO4 == 9), 1, 0)

* Create a dummy for individuals who have been practising the same occupation for three generations
capture drop hhSize
bysort IDHH: egen hhSize = count(IDHH)
gsort IDHH -persistenceAcrossTwoGenerations
bysort IDHH: gen persistence = cond(sum(persistenceAcrossTwoGenerations)>0, 1, 0)
gen persistenceThreeGenerations = cond(persistence == 1 & interstitialPersistence == 1, 1, 0)

* Adjust units of INCOMEPC
replace INCOMEPC = INCOMEPC/100000

* Recode caste categorisation to club Brahmin and Forward Caste
recode ID13 (1/2 = 1) (3 = 2) (4 = 3) (5 = 4) (6 = 5)
label define ID13 1 "Brahmin and Forward Caste" 2 "Other Backward Castes (OBC)" ///
3 "Scheduled Castes (SC)" 4 "Scheduled Tribes (ST)" 5 "Others", modify
label val ID13 ID13

regress persistenceAcrossTwoGenerations i.ID13#RO3 i.EDUC7 ME8 MH7 INCOMEPC /// 
hhSize ib(last).HHFsOccup URBAN2011 [pweight = FWT] ///
if RO4 == 1 | RO4 == 2 | RO4 == 7 | RO4 == 10, baselevels

capture drop yhat
predict yhat 
sum yhat, detail
capture drop outOfBounds
gen outOfBounds = cond( yhat < 0 | yhat > 1, 1, 0)
sum outOfBounds

regress interstitialPersistence i.ID13#RO3 i.EDUC7 ME8 MH7 INCOMEPC ///
hhSize ib(last).HHFsOccup URBAN2011 [pweight = FWT] if RO4 == 3 | RO4 == 4 | RO4 == 5 | RO4 == 9, baselevels ///

drop yhat
capture drop outOfBounds
predict yhat 
sum yhat, detail
gen outOfBounds = cond( yhat < 0 | yhat > 1, 1, 0)
sum outOfBounds

regress persistenceThreeGenerations i.ID13#RO3 i.EDUC7 ME8 MH7 INCOMEPC ///
hhSize ib(last).HHFsOccup URBAN2011 [pweight = FWT] if RO4 == 3 | RO4 == 4 | RO4 == 5 | RO4 == 9, baselevels 
capture drop yhat
capture drop outOfBounds
predict yhat 
sum yhat, detail
gen outOfBounds = cond( yhat < 0 | yhat > 1, 1, 0)
sum outOfBounds

regress persistenceAcrossTwoGenerations i.ID13#RO3 i.EDUC7 ME8 MH7 INCOMEPC /// 
hhSize URBAN2011 [pweight = FWT]

tab WS4 interstitialPersistence, col

tab persistenceAcrossTwoGenerations EDUC7, row
tab persistenceAcrossTwoGenerations HHFsOccup, col

tab EDUC7 interstitialPersistence, col
tab individualOccup interstitialPersistence, col
tab individualOccup HHFsOccup, col

* Generate summary statistics
tab ID13 persistenceAcrossTwoGenerations if RO4 == 1 | RO4 == 2 | RO4 == 7 | RO4 == 10, row
tab ID13 interstitialPersistence if RO4 == 3 | RO4 == 4 | RO4 == 5 | RO4 == 9, row
tab ID13 persistenceThreeGenerations if RO4 == 3 | RO4 == 4 | RO4 == 5 | RO4 == 9, row
tab individualOccup persistenceAcrossTwoGenerations, row
tab individualOccup interstitialPersistence, row
tab individualOccup persistenceThreeGenerations, row
tab ID13 persistenceAcrossTwoGenerations if individualOccup == 108, row
tab ID13 interstitialPersistence if individualOccup == 108, row 
tab ID13 persistenceThreeGenerations if individualOccup == 108, row 

tab individualOccup persistenceAcrossTwoGenerations, row

tab ID13 persistenceAcrossTwoGenerations if individualOccup == 107, row
tab ID13 persistenceAcrossTwoGenerations if individualOccup == 101, col

quietly levelsof individualOccup, local(levels)
foreach l of local levels {
	* tab ID13 persistenceAcrossTwoGenerations if individualOccup == `l', row
	if `l' == 101 {
		asdoc tab ID13 persistenceThreeGenerations if individualOccup == `l', row save(persistenceThreeGenerations.doc) replace title(Occupation = `l')
		asdoc tab ID13 persistenceAcrossTwoGenerations if individualOccup == `l', row save(persistenceAcrossTwoGenerations.doc) replace title(Occupation = `l')
	}
	else {
		asdoc tab ID13 persistenceThreeGenerations if individualOccup == `l', row save(persistenceThreeGenerations.doc) append title(Occupation = `l')
		asdoc tab ID13 persistenceAcrossTwoGenerations if individualOccup == `l', row save(persistenceAcrossTwoGenerations.doc) append title(Occupation = `l')
	}
}




gen sameOcc = 0
replace sameOcc = 1 if HHFsOccup == individualOccup
/*
gen sameInd = 0
replace sameInd = 1 if WS5 == ID18B
*/


gen sameOcc1 = 0
replace sameOcc1 = 1 if WS4 == ID18A
gen sameInd = 0
replace sameInd = 1 if WS5 == ID18B

sort RO3
by RO3: tab ID13 sameOcc, col
by RO3: tab ID13 sameInd, col
tab ID13 sameOcc, col

tab ID13 WS4 if (WS4 == 63 | WS4 == 95), col
