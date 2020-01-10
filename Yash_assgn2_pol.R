
######## Assignment Starts ###################################

Election_Data <- Final_Election_Data


BJP_1 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE == 'BJP')  %>% 
  mutate(BJP_Winmargin = ifelse(POSITION ==1,vote_share - Runner_Up_Vote,vote_share-Winner_Vote  )) 

BJP_1 <- select(BJP_1,c(ST_CODE,AC_NO,YEAR,DIST_NAME,BJP_Winmargin))
Election_Data = merge(Election_Data, BJP_1, by=c('YEAR', 'ST_CODE', 'AC_NO','DIST_NAME'),all.x  = T)


INC_1 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE =='INC') %>%
  mutate(INC_Winmargin = ifelse(POSITION==1,vote_share - Runner_Up_Vote,vote_share-Winner_Vote ))

INC_1 <- select(INC_1,c(ST_CODE,AC_NO,YEAR,DIST_NAME,INC_Winmargin))
Election_Data = merge(Election_Data,INC_1,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)


AITC_1 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE =='AITC') %>%
  mutate(AITC_Winmargin = ifelse(POSITION==1,vote_share - Runner_Up_Vote,vote_share-Winner_Vote ))

AITC_1 <- select(AITC_1,c(ST_CODE,AC_NO,YEAR,DIST_NAME,AITC_Winmargin))
Election_Data = merge(Election_Data,AITC_1,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)



ADMK_1 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE =='ADMK') %>%
  mutate(ADMK_Winmargin = ifelse(POSITION==1,vote_share - Runner_Up_Vote,vote_share-Winner_Vote ))

ADMK_1 <- select(ADMK_1,c(ST_CODE,AC_NO,YEAR,DIST_NAME,ADMK_Winmargin))
Election_Data = merge(Election_Data,ADMK_1,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)


###############################################3

BJP_2 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE == 'BJP') %>%
  mutate(BJP_Win = ifelse(POSITION==1,1,0))
BJP_2 <- select(BJP_2,c(ST_CODE,AC_NO,YEAR,DIST_NAME,BJP_Win))
Election_Data = merge(Election_Data,BJP_2,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)

INC_2 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE == 'INC') %>%
  mutate(INC_Win = ifelse(POSITION==1,1,0))
INC_2 <- select(INC_2,c(ST_CODE,AC_NO,YEAR,DIST_NAME,INC_Win))
Election_Data = merge(Election_Data,INC_2,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)

AITC_2 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE == 'AITC') %>%
  mutate(AITC_Win = ifelse(POSITION==1,1,0))
AITC_2 <- select(AITC_2,c(ST_CODE,AC_NO,YEAR,DIST_NAME,AITC_Win))
Election_Data = merge(Election_Data,AITC_2,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)

ADMK_2 <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(PARTYABBRE == 'ADMK') %>%
  mutate(ADMK_Win = ifelse(POSITION==1,1,0))
ADMK_2 <- select(ADMK_2,c(ST_CODE,AC_NO,YEAR,DIST_NAME,ADMK_Win))
Election_Data = merge(Election_Data,ADMK_2,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)

Election_Data <- select(Election_Data,-c(V1))

#############################################


ggplot(Election_Data, aes(x = BJP_Winmargin, y =BJP_Win)) +
  # geom_line( color = 'darkorange1',lwd = 1.5)+ 
  geom_point(color='red') +
  labs(
    x = "BJP_Winmargin",
    y = "BJP_Win",
    title = "Win_Margin and Winning Plot : BJP"
  ) +theme_bw()



ggplot(Election_Data, aes(x = INC_Winmargin, y =INC_Win)) +
  # geom_line( color = 'darkorange1',lwd = 1.5)+ 
  geom_point(color='red') +
  labs(
    x = "INC_Winmargin",
    y = "INC_Win",
    title = "Win_Margin and Winning Plot : INC"
  ) +theme_bw()


ggplot(Election_Data, aes(x = AITC_Winmargin, y =AITC_Win)) +
  # geom_line( color = 'darkorange1',lwd = 1.5)+ 
  geom_point(color='red') +
  labs(
    x = "AITC_Winmargin",
    y = "AITC_Win",
    title = "Win_Margin and Winning Plot : AITC"
  ) +theme_bw()

ggplot(Election_Data, aes(x = ADMK_Winmargin, y =ADMK_Win)) +
  # geom_line( color = 'darkorange1',lwd = 1.5)+ 
  geom_point(color='red') +
  labs(
    x = "ADMK_Winmargin",
    y = "ADMK_Win",
    title = "Win_Margin and Winning Plot : ADMK"
  ) +theme_bw()

################################
################################

Final_Election_Data_1 <- Election_Data[POSITION == 1] 
Winners <- Final_Election_Data_1[,.(Winners = PARTYABBRE),by=.(ST_CODE,ST_NAME,AC_NO,YEAR,DIST_NAME,win_margin)]
Winners_Second <- Winners[YEAR >= 2013]
Winners_First <- Winners[YEAR < 2013]
Winners_First <- Winners_First[ST_NAME != 'Himachal Pradesh'& ST_NAME != 'Gujarat' ]
Winners_Second <- Winners_Second[ ST_NAME != 'NCT OF Delhi'| YEAR !=2015]
Winners_Second <- Winners_Second[ST_NAME != 'NCT OF Delhi'| AC_NO != 39]
Winners_Second <- Winners_Second[ST_NAME != 'Meghalaya'| AC_NO != 37]
Winners_First <- Winners_First[order(Winners_First$ST_NAME)]
Winners_Second <- Winners_Second[order(Winners_Second$ST_NAME)]
Winners_First <-Winners_First %>%rename(Winners_First_Round = Winners)
Winners_Second <- Winners_Second %>% rename(Winner_Second_Round = Winners)


Winners_First <- select(Winners_First,c(ST_CODE,YEAR,AC_NO,Winners_First_Round))
Election_Data = merge(Election_Data,Winners_First,by=c('ST_CODE','YEAR','AC_NO'),all.x = T)

Winners_Second <- select(Winners_Second,c(ST_CODE,AC_NO,Winner_Second_Round))
Election_Data = merge(Election_Data,Winners_Second,by=c('ST_CODE','AC_NO'),all.x = T)

Election_Data <- data.frame(Election_Data)
Election_Data <- Election_Data %>%  mutate(BJP_Winnext = ifelse(Winner_Second_Round == 'BJP' ,1,0))

# Election_Data <- Election_Data %>%  mutate(INC_Winnext = ifelse(Winners_First_Round == 'INC' & Winners_First_Round == Winner_Second_Round,1,0))

Election_Data <- Election_Data %>%  mutate(INC_Winnext = ifelse(Winner_Second_Round == 'INC' ,1,0))
Election_Data <- Election_Data %>%  mutate(AITC_Winnext = ifelse(Winner_Second_Round == 'AITC' ,1,0))
Election_Data <- Election_Data %>%  mutate(ADMK_Winnext = ifelse(Winner_Second_Round == 'ADMK' ,1,0))

Election_Data <- data.table(Election_Data)
Election_Data <- Election_Data[YEAR < 2013]
Election_Data <- Election_Data[POSITION == 1]



########### THIS PART IS DONE IN BOTH STATA AND AS WELL AS R ##########
########## STATA COMMANDS #################

# ********************* Question 4 ******************************************************************************
# rdrobust BJP_winnext BJP_winmargin
# rdrobust INC_winnext INC_winmargin
# rdrobust AITC_winnext AITC_winmargin
# rdrobust ADMK_winnext ADMK_winmargin
# 
# 
# ****************** Question 5 ******************************************************
# rdplot BJP_winnext BJP_winmargin, ci(95) shade
# rdplot INC_winnext INC_winmargin, ci(95) shade
# rdplot AITC_winnext AITC_winmargin, ci(95) shade
# rdplot ADMK_winnext ADMK_winmargin, ci(95) shade


