

Final_Election_Data_1 <- Final_Election_Data[POSITION == 1] 
Winners <- Final_Election_Data_1[,.(Winners = PARTYABBRE),by=.(YEAR, ST_NAME,AC_NO,win_margin)]

Winners_Second <- Winners[YEAR >= 2013]
Winners_First <- Winners[YEAR < 2013]
Winners_First <- Winners_First[ST_NAME != 'Himachal Pradesh'& ST_NAME != 'Gujarat' ]
Winners_Second <- Winners_Second[ ST_NAME != 'NCT OF Delhi'| YEAR !=2015]
Winners_Second <- Winners_Second[ST_NAME != 'NCT OF Delhi'| AC_NO != 39]
Winners_Second <- Winners_Second[ST_NAME != 'Meghalaya'| AC_NO != 37]



Winners_First <- Winners_First[order(Winners_First$ST_NAME)]
Winners_Second <- Winners_Second[order(Winners_Second$ST_NAME)]
M <- Winners_Second$Winners
Winners_First$Winners_Second_round <- M
Winners_First <-Winners_First %>%rename(Winners_First_Round = Winners)
winner_party = ifelse(Winners_First$Winners_First_Round == Winners_First$Winners_Second_round, 1, 0)
Winners_First$winner_party <- winner_party
Winners_First <- Winners_First[complete.cases(Winners_First),]
sum(Winners_First$winner_party)

#################################################################
A <- data.frame(POL_ECO_DATASET_1)

A_1 <-  filter(A,A$Winners_First_Round == 'INC') 
binsreg(A_1$winner_party,A_1$win_margin) 

##################################################################

Final_Election_Data_2 <- Final_Election_Data[POSITION == 2] 
Runner <- Final_Election_Data_2[,.(Winners = PARTYABBRE),by=.(YEAR, ST_NAME,AC_NO,win_margin)]

Runner_Second <- Winners_Second
Runner_First <-Runner[YEAR < 2013]
Runner_First <- Runner_First[ST_NAME != 'Himachal Pradesh'& ST_NAME != 'Gujarat' ]
Runner_Second <- Runner_Second[ST_NAME != 'Arunachal Pradesh'| AC_NO != 1]
Runner_Second <- Runner_Second[ST_NAME != 'Arunachal Pradesh'| AC_NO != 2]
Runner_Second <- Runner_Second[ST_NAME != 'Arunachal Pradesh'| AC_NO != 3]

##############################################################################

Runner_First <- Runner_First[order(Runner_First$ST_NAME)]
Runner_Second <- Runner_Second[order(Runner_Second$ST_NAME)]
M <- Runner_Second$Winners
Runner_First$Winner_Second_round <- M
Runner_First <-Runner_First %>%rename(Runner_First_Round = Winners)
runner_party = ifelse(Runner_First$Runner_First_Round == Runner_First$Runner_Second_round, 1, 0)
Runner_First$runner_party <- runner_party
Runner_First <- Runner_First[complete.cases(Runner_First),]
sum(Runner_First$runner_party)


