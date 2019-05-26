#U ovoj R biljeznici je implementirano clusteriranje na retke iz validacijskog seta sa codalaba ciji je planirani datum zatvaranja poslije 19.4.2019
#osnovna pretpostavka je da svi retci sa target varijablom N, kojih ima 35% u tom dijelu su umjetno generirani i dakle lako odvojivi.
#metoda se pokazala bezuspjesna ali je svakako radila bolje od random, najbolji clustering je ulovio otprilike 75% svih redaka
#nakon 19.4.2019 cija je target varijabla Y.


rm(list=ls())
ls()

ptm <- proc.time()
cisti_data_clean <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_set_economy_features.csv", header=TRUE, sep=",")
proc.time() - ptm
cisti_data_clean<-cisti_data_clean[order(cisti_data_clean$OZNAKA_PARTIJE),]


ptm <- proc.time()
validation <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/validation_set_prepared.csv", header=TRUE, sep=",")
proc.time() - ptm

ptm <- proc.time()
student <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/eval_dataset_nan - Copia.csv", header=TRUE, sep=";",dec=",")
proc.time() - ptm

#ovaj dio jednostavno popunjava sva prazna polja sa averageima za taj feature, jer nan polja smetaju clustering funkciji

#######################STAROST-VISINA_KAMATE#######################
ind<-which(is.na(cisti_data_clean[,"STAROST"]))
starost<-floor(mean(cisti_data_clean[-ind,"STAROST"]))
cisti_data_clean[ind,"STAROST"]<-starost

A<-subset(cisti_data_clean,VRSTA_PROIZVODA=="A")
ind<-which(is.na(A[,"VISINA_KAMATE"]))
A_kamata<-mean(A[-ind,"VISINA_KAMATE"])
A[ind,"VISINA_KAMATE"]<-A_kamata


L<-subset(cisti_data_clean,VRSTA_PROIZVODA=="L")
ind<-which(is.na(L[,"VISINA_KAMATE"]))
L_kamata<-mean(L[-ind,"VISINA_KAMATE"])
L[ind,"VISINA_KAMATE"]<-L_kamata

cisti_data_clean<-rbind(A,L)
cisti_data_clean<-cisti_data_clean[order(cisti_data_clean$OZNAKA_PARTIJE),]



ind<-which(validation[,"VISINA_KAMATE"]>18)
validation[ind,"VISINA_KAMATE"]<-NA

ind<-which(is.na(validation[,"STAROST"]))
validation[ind,"STAROST"]<-starost

for (i in 1:dim(validation)[1]){
	if (is.na(validation[i,"VISINA_KAMATE"])){
		if(validation[i,"VRSTA_PROIZVODA"]=="A"){validation[i,"VISINA_KAMATE"]=A_kamata}
		else {validation[i,"VISINA_KAMATE"]=L_kamata}
	}
}

names1<- c("KLIJENT_ID","OZNAKA_PARTIJE","DATUM_OTVARANJA","PLANIRANI_DATUM_ZATVARANJA","UGOVORENI_IZNOS","PROIZVOD","TIP_KAMATE"
				,"VRSTA_KLIJENTA","STAROST","VISINA_KAMATE","VRSTA_PROIZVODA","VALUTA" )

names<- c("DATUM_OTVARANJA","PLANIRANI_DATUM_ZATVARANJA","UGOVORENI_IZNOS","STAROST","VISINA_KAMATE","VRSTA_PROIZVODA","PROIZVOD"
		,"TIP_KAMATE" ,"VALUTA","VRSTA_KLIJENTA")

#########################################################################
#################pripremi za clustering##################################

validation<-validation[names(validation) %in% names]
#describe(validation)
#head(validation)


validation$VRSTA_KLIJENTA<-as.factor(validation$VRSTA_KLIJENTA)
#validation$KLIJENT_ID<-as.factor(validation$KLIJENT_ID)
validation$VALUTA<-as.factor(validation$VALUTA)

#######################odvoji po vrsti proizvoda#########################

#as.Date(18005,format=c("%d.%m.%Y"),origin="01.01.1970")
visokiA<-which((validation$PLANIRANI_DATUM_ZATVARANJA>18005) & (validation$VRSTA_PROIZVODA=="A"))
visokiL<-which((validation$PLANIRANI_DATUM_ZATVARANJA>18005) & (validation$VRSTA_PROIZVODA=="L"))
length(visokiA)
length(visokiL)

#######################sve kategorijske u num##################################

library(tidyverse)
library(xgboost)
library(caret)
library(e1071)
library(Hmisc)

must_convert<-sapply(validation,is.factor)       
M2<-sapply(validation[,must_convert],unclass)    
validation<-cbind(validation[,!must_convert],M2)        

#################################################################################

validationA<-validation[visokiA,]
validationL<-validation[visokiL,]
dim(validationA)
dim(validationL)


scale_validationA<-validationA
scale_validationL<-validationL

scale_validationA<-scale_validationA[!names(validation) %in% c("VRSTA_PROIZVODA","M2")]
scale_validationL<-scale_validationL[!names(validation) %in% c("VRSTA_PROIZVODA","M2")]



#head(scale_validationA)


##########################skaliranje##############################

scale_validationA<-sapply(scale_validationA,scale)
scale_validationL<-sapply(scale_validationL,scale)


###################################################################################
head(scale_validationA)
head(scale_validationL)
dim(scale_validationA)
dim(scale_validationL)



#describe(scale_validationL)


set.seed(700)#20
clustersA <- kmeans(scale_validationA, 2,nstart=100,iter.max = 100,algorithm = "Hartigan-Wong")
str(clustersA)

library(cluster) 
clusplot(scale_validationA, clustersA$cluster, color=TRUE, shade=TRUE, 
   labels=2, lines=0)

clusplot(clara(scale_validationA,2))

set.seed(600)#20
clustersL <- kmeans(scale_validationL, 2,nstart=100,iter.max = 100,algorithm ="Hartigan-Wong")
str(clustersL)

library(cluster) 
clusplot(scale_validationL, clustersL$cluster, color=TRUE, shade=TRUE, 
   labels=2, lines=0)



# Save the cluster number in the dataset as column "class"
scale_validationA$class <- as.factor(clustersA$cluster)
scale_validationL$class <- as.factor(clustersL$cluster)

head(scale_validationA)

pozAN<-which(scale_validationA$class=="1")
pozAY<-which(scale_validationA$class=="2")

pozLN<-which(scale_validationL$class=="1")
pozLY<-which(scale_validationL$class=="2")


#head(student)
prijevremeni_stupac<-numeric(length(student$PRIJEVREMENI_RASKID))
prijevremeni_stupac[1:length(prijevremeni_stupac)]<-"N"

prijevremeni_stupac[visokiA[pozAY]]<-"Y"
prijevremeni_stupac[visokiL[pozLY]]<-"Y"

#length(which(prijevremeni_stupac=="Y"))

student$PRIJEVREMENI_RASKID<-prijevremeni_stupac

#describe(student)

write.csv(student,file="student.csv")



############################################################################################
##############################################neki mocniji cluster##########################

#install.packages("mclust")
#library(mclust)
clustersA <- Mclust(scale_validationA,G=2)
summary(clustersA) # display the best model


#install.packages("mclust")
#library(mclust)
clustersL <- Mclust(scale_validationL,G=2)
summary(clustersL) # display the best model


scale_validationA$class <- as.factor(clustersA$classification)
scale_validationL$class <- as.factor(clustersL$classification)

head(scale_validationA)

pozAN<-which(scale_validationA$class=="2")
pozAY<-which(scale_validationA$class=="1")

pozLN<-which(scale_validationL$class=="2")
pozLY<-which(scale_validationL$class=="1")


#head(student)
prijevremeni_stupac<-numeric(length(student$PRIJEVREMENI_RASKID))
prijevremeni_stupac[1:length(prijevremeni_stupac)]<-"N"

prijevremeni_stupac[visokiA[pozAY]]<-"Y"
prijevremeni_stupac[visokiL[pozLY]]<-"Y"

#length(which(prijevremeni_stupac=="Y"))

student$PRIJEVREMENI_RASKID<-prijevremeni_stupac

#describe(student)

write.csv(student,file="student.csv")







