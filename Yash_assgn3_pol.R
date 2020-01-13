

######### DO FILE STARTS ######################


####### #######

Election_Data <- data.table(Final_Election_Data)
Election_Data$CAND_SEX[Election_Data$CAND_SEX == "ADVOCATE" ] <- NA
Election_Data$CAND_SEX[Election_Data$CAND_SEX == "NULL" ] <- NA
Election_Data$CAND_SEX[Election_Data$CAND_SEX == "O" ] <- NA


#### MAKING FEMALE DUMMY ##########

Election_Data <- Election_Data %>% mutate(female = ifelse(CAND_SEX=="F",1,0))

#####################


Mixed_Gender <- Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(POSITION==1) %>%
  mutate(Gender_First = CAND_SEX)
Mixed_Gender <- select(Mixed_Gender,c(ST_CODE,AC_NO,YEAR,DIST_NAME,Gender_First))

Mixed_Gender_1 <-  Election_Data %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>% filter(POSITION==2) %>%
  mutate(Gender_Second = CAND_SEX)

Mixed_Gender_1 <- select(Mixed_Gender_1,c(ST_CODE,AC_NO,YEAR,DIST_NAME,Gender_Second))


Mixed_Gender <- merge(Mixed_Gender,Mixed_Gender_1,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)

Mixed_Gender <- Mixed_Gender %>% group_by(ST_CODE,AC_NO,YEAR,DIST_NAME) %>%
  mutate(mixed_gender = ifelse(Gender_First != Gender_Second,1,0))


Election_Data <- merge(Election_Data,Mixed_Gender,by=c('YEAR','ST_CODE','AC_NO','DIST_NAME'),all.x = T)

###########

Election_Data <- Election_Data %>% 
  mutate(female_top = ifelse(Gender_First== "F" | Gender_Second =="F",1,0))


Bar_Graph_1 <- merge(Bar_Graph_1,EMPLOYMENT_DATA,by=c('ST_NAME'),all.x = T)


#########################
cor(Bar_Graph_1$FEMALE, Bar_Graph_1$female_top_prop,  method = "spearman", use = "complete.obs")

cor.test(Bar_Graph_1$female_top_prop,Bar_Graph_1$FEMALE,   method = "spearman")


###### DO- FILE ENDS #####
