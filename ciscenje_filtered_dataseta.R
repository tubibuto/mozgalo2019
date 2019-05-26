#Ova R biljeznica prima filtrirani training set (dobivenog od c++ parsera)
#i naknadno cisti sve retke bez datuma zatvaranja ILI planiranog datuma zatvaranja.
#sve retke sa besmislenim datumima (datum otvaranja>planirani datum zatvaranja
#takodjer sve negativne starosti su overwriteane sa NA (prazno polje u Ru)
#sve starosti>800 su overwriteane sa NA (prazno polje u Ru)
#slicno za jako negativne kamate (< -0.5) i kamate vece od 18
#na kraju se dodaje redak s oznakom partije OZNAKA_PARTIJE=="12997777" jer je njegov PROIZVOD feature
#toliko rijedak da ga je jedno od nasih ciscenja "izgubilo".
#u cisti_data_clean se upisuju filtrirani podaci parsera.
#u raw_data se upisuju raw podaci dani od organizatora sa datumima u numeric formatu.



rm(list=ls())
ls()
#######################ciscenje############################################
ptm <- proc.time()
cisti_data_clean <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_set_economy_features.csv", header=TRUE, sep=",")
proc.time() - ptm

ptm <- proc.time()
raw_data <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_enc_num.csv", header=TRUE, sep=",")
proc.time() - ptm


describe(cisti_data_clean)

cisti_data_clean<-cisti_data_clean[complete.cases(cisti_data_clean[ ,c("DATUM_ZATVARANJA","PLANIRANI_DATUM_ZATVARANJA")]),]
cisti_data_clean<-subset(cisti_data_clean,PLANIRANI_DATUM_ZATVARANJA>=DATUM_OTVARANJA)

nandat<-which(cisti_data_clean$STAROST<0)
length(nandat)
cisti_data_clean[nandat,"STAROST"]<- NA

nandat<-which(cisti_data_clean$STAROST>800)
length(nandat)
cisti_data_clean[nandat,"STAROST"]<- NA

nandat<-which(cisti_data_clean$VISINA_KAMATE>18)
length(nandat)
cisti_data_clean[nandat,"VISINA_KAMATE"]<- NA

nandat<-which(cisti_data_clean$VISINA_KAMATE< -0.5)
length(nandat)
cisti_data_clean[nandat,"VISINA_KAMATE"]<- NA

#dodavanje ekstra rijetkog retka
nandat<-which(raw_data$OZNAKA_PARTIJE=="12997777")
length(nandat)
redak<-raw_data[nandat[2],]
redak<-redak[-c(1,2,9,10)]
redak

cisti_data_clean<-rbind(cisti_data_clean,redak)

write.csv(cisti_data_clean,file="training_dataset_filtered_najbolji.csv")

##################################################################################
