clear
set more off
set matsize 10000

cd "C:\Users\Amarendra\Desktop\Yashaswi Political Economics"

*Importing excel files and creating .dta file for each year*

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\2008.xls",
sheet("cand_wise") cellrange(A5:P32649) firstrow
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2008.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\2009.xls",
sheet("cand_wise") firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2009.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\2010.xls",
sheet("cand_wise") firstrow
describe
tostring CAND_AGE, replace
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2010.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\2011.xls",
sheet("CAND_WISE") cellrange(A4:O6683) firstrow
tostring CAND_AGE, replace
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2011.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\2012.xls",
sheet("cand_wise") firstrow
tostring CAND_AGE, replace
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2012.dta"
clear


import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\20131.xls",
sheet("Candidates") cellrange(A4:O3733) firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA20131dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\20132.xls",
sheet("Candidates") cellrange(A3:N7250) firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA20132.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\20141.xlsx",
sheet("Candidates") cellrange(A4:O6216) firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA20141.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\20142.xlsx",
sheet("Candidates") cellrange(A4:O5852) firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA20142.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\20143.xlsx",
sheet("Candidates") cellrange(A4:O2499) firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA20143.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\20151.xlsx",
sheet("Candidates") cellrange(A5:W753) firstrow
tostring TOTVOTPOLL, replace
drop P Q R S T U V W
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA20151.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\20152.xls",
sheet("CANDIDATES") cellrange(A3:O3696) firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA20152.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\2016.xls",
sheet("Candidates") cellrange(A3:O9263) firstrow
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2016.dta"
clear

import excel "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\2017.xls",
sheet("Candidate") firstrow
tostring TOTVOTPOLL, replace
save "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2017.dta"
clear

*Create one large datset by appending all datasets

use "C:\Users\Amarendra\Desktop\Yashaswi Political Economics\GESLA2008.dta"
append using "GESLA2009.dta" "GESLA2010.dta" "GESLA2011.dta" "GESLA2012.dta"
"GESLA20131.dta" "GESLA20132.dta" "GESLA20141.dta" "GESLA20142.dta" "GESLA20143.dta"
"GESLA20151.dta" "GESLA20152.dta" "GESLA2016.dta" "GESLA2017.dta" , force
save "GESLA.dta", replace

*Need to drop missing values
drop if ST_NAME == ""
drop if AC_NO == .

*Q1*
/*Use encode command to create an id for ACs which will assign
a unique number to each AC*/
/* concatenate the variables ST_CODE and AC_NO to generate a new varibale ST_AC
which will act as a unique marker for every assemble constituency. Then assign
unique number to the different constituencies*/

egen ST_AC = concat (ST_CODE AC_NO)
encode ST_AC, generate(AC_ID)
tab AC_ID, nolab

*Q2*
/* Creating a varibale called voteshare to capture voteshare of each candidate*/
/*for each assemby constituency for a particular year and month of election, total
the votes received by the candidates and then generate voteshare for each
candidates by dividing the candidate's voteshare by the total voteshare*/

destring TOTVOTPOLL, replace force
bysort AC_ID YEAR MONTH: egen TOTALVOTESHAREAC = total(TOTVOTPOLL)
generate VOTESHARE = TOTVOTPOLL/TOTALVOTESHAREAC

*Q3*
/* Need to calculate the win margin by subtracting the second highest voteshare
from the highest voteshare*/
/*this win margin is the same at the constituency level and therfore its value
will be the same for all candidates within a constituency fora given year*/

bysort AC_ID YEAR MONTH: egen HIGHESTVS = max(VOTESHARE)
generate SECONDHIGHESTVS = VOTESHARE if POSITION == 2
replace SECONDHIGHESTVS = 0 if POSITION !=2
bysort AC_ID YEAR MONTH : egen WIN_MARGIN = min(HIGHESTVS - SECONDHIGHESTVS)

*Q4*
/*Generate a new variable CANDIDATE_NO that will calculate the total number of
candidates running for elections in a constituency. This again will have same
values for all the rows with the same AC-year combination*/

bysort AC_ID YEAR MONTH : egen CANDIDATE_NO = count(VOTESHARE)

*Q5*
/*Plot in two separate graphs the average values of win margin and number of
candidates across the years. Remember that you should consider only one row
for each AC-year combination to calculate the averages, as the values for both
variables are repeated for rows having the same AC-year combination.*/

/*Plot 1 - plot average values of win margin across years*/
collapse WIN_MARGIN CANDIDATE_NO, by (YEAR MONTH AC_ID)
bysort YEAR : egen AVG_WINMARGIN = mean(WIN_MARGIN)
twoway (line AVG_WINMARGIN YEAR, sort) , title (Average values of win margin across years)

/*Plot 2 - plot average value of number of candidates across years*/
bysort YEAR : egen AVGNOCAND = mean(CANDIDATE_NO)
twoway (line AVGNOCAND YEAR, sort) , title (Average number of candidates across years)
