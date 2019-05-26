remove(list=ls())
ls()

ptm <- proc.time()
data <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_enc_num.csv", header=TRUE, sep=",")
proc.time() - ptm

data<-data[order(data$OZNAKA_PARTIJE,data$DATUM_IZVJESTAVANJA),]
dim(data)



ptm <- proc.time()
cisti_data <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_filtered.csv", header=TRUE, sep=",")
proc.time() - ptm

cisti_data<-cisti_data[order(cisti_data$OZNAKA_PARTIJE),]
dim(cisti_data)

summary(cisti_data)

fivenum(cisti_data)

#install.packages("pastecs")
library(pastecs)
stat.desc(cisti_data)

#install.packages("Hmisc")
library(Hmisc)
describe(cisti_data)

describe(data)

nandat<-which(-1==cisti_data$DATUM_ZATVARANJA & -1==cisti_data$PLANIRANI_DATUM_ZATVARANJA)
length(nandat)

nandat<-which(-1==cisti_data$DATUM_ZATVARANJA & -1!=cisti_data$PLANIRANI_DATUM_ZATVARANJA)
length(nandat)

nandat<-which(-1!=cisti_data$DATUM_ZATVARANJA & -1==cisti_data$PLANIRANI_DATUM_ZATVARANJA)
length(nandat)

nandat<-which(-1!=cisti_data$DATUM_ZATVARANJA & -1!=cisti_data$PLANIRANI_DATUM_ZATVARANJA)
length(nandat)

nandat<-which(0==cisti_data$PLANIRANI_DATUM_ZATVARANJA)
length(nandat)

nandat<-which(0==cisti_data$DATUM_ZATVARANJA)
length(nandat)

nandat<-which(0==cisti_data$STAROST)
length(nandat)


nandat<-which(1==data$PLANIRANI_DATUM_ZATVARANJA)
length(nandat)