remove(list=ls())
mozgalo <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_enc.csv", header=TRUE, sep=",")

#pocetna igra s podacima. 
colnames(mozgalo)
typeof(mozgalo)
typeof(mozgalo[,"DATUM_IZVJESTAVANJA"])
typeof(mozgalo[1,19])
mozgalo[1,"DATUM_IZVJESTAVANJA"]

dim(mozgalo)
class(mozgalo)
class(mozgalo[,"DATUM_IZVJESTAVANJA"])
class(mozgalo[,"PRIJEVREMENI_RASKID"])
class(mozgalo[,"X"])

mozgalo[c(1,2,3,4,5,6,7,8,9,10),c(6,7,8,9)]
head(mozgalo,20)
tail(mozgalo,10)



#transformiraj datume u standardni R format.
#defaultni date origin: January 1, 1970.
#datumi izvjestavanja su svi oblika 31.03.//30.06.//30.09.//31.12.
dat_izv<-as.Date(mozgalo[["DATUM_IZVJESTAVANJA"]],format=c("%d.%m.%Y"),origin = "01.01.1970")
dat_otv<-as.Date(mozgalo[["DATUM_OTVARANJA"]],format=c("%d.%m.%Y"),origin = "01.01.1970")
dat_pzat<-as.Date(mozgalo[["PLANIRANI_DATUM_ZATVARANJA"]],format=c("%d.%m.%Y"),origin = "01.01.1970")
dat_zat<-as.Date(mozgalo[["DATUM_ZATVARANJA"]],format=c("%d.%m.%Y"),origin = "01.01.1970")
#datumi<-as.Date(mozgalo_data_num[["DATUM_IZVJESTAVANJA"]],origin = origin = "01.01.1970")



#transformiraj datume sa std R formata u numeric pocevsi od 1.1.1970
dat_izv_num<-as.numeric(dat_izv)
dat_otv_num<-as.numeric(dat_otv)
dat_pzat_num<-as.numeric(dat_pzat)
dat_zat_num<-as.numeric(dat_zat)



#overwriteaj te numeric datume na stare datume (bolje raditi sa numeric)
mozgalo_copy<-mozgalo
mozgalo_copy[,"DATUM_IZVJESTAVANJA"]<-dat_izv_num
mozgalo_copy[,"DATUM_OTVARANJA"]<-dat_otv_num
mozgalo_copy[,"PLANIRANI_DATUM_ZATVARANJA"]<-dat_pzat_num
mozgalo_copy[,"DATUM_ZATVARANJA"]<-dat_zat_num

typeof(mozgalo_copy[,"DATUM_IZVJESTAVANJA"])
head(mozgalo_copy,20)

#ostavljamo samo bitne stupce u slucaju da se nesto ekstra iskopiralo.
mozgalo_copy<-mozgalo_copy[c("DATUM_IZVJESTAVANJA","KLIJENT_ID",
"OZNAKA_PARTIJE","DATUM_OTVARANJA","PLANIRANI_DATUM_ZATVARANJA",    
"DATUM_ZATVARANJA","UGOVORENI_IZNOS",   
"STANJE_NA_KRAJU_PRETH_KVARTALA","STANJE_NA_KRAJU_KVARTALA",      
"VALUTA","VRSTA_KLIJENTA",                
"PROIZVOD","VRSTA_PROIZVODA",               
"VISINA_KAMATE","TIP_KAMATE",                    
"STAROST","PRIJEVREMENI_RASKID")]



#spremi podatke sa numeric datumima.
write.csv(mozgalo_copy,file="training_dataset_enc_num.csv")




rm(list=ls())

#kopira se i neki ekstra supac X.1, nebitno, to je samo broj retka nekakav.
mozgalo_data_num <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_enc_num.csv", header=TRUE, sep=",")




#ostavljamo samo bitne stupce u slucaju da se nesto ekstra iskopiralo.
mozgalo_data_num<-mozgalo_data_num[c("DATUM_IZVJESTAVANJA","KLIJENT_ID",
"OZNAKA_PARTIJE","DATUM_OTVARANJA","PLANIRANI_DATUM_ZATVARANJA",    
"DATUM_ZATVARANJA","UGOVORENI_IZNOS",   
"STANJE_NA_KRAJU_PRETH_KVARTALA","STANJE_NA_KRAJU_KVARTALA",      
"VALUTA","VRSTA_KLIJENTA",                
"PROIZVOD","VRSTA_PROIZVODA",               
"VISINA_KAMATE","TIP_KAMATE",                    
"STAROST","PRIJEVREMENI_RASKID")]




#KORELACIJA i opcenito DESKRIPTIVNA statistika, sa originalnim podacima i
#numeric datumima.
summary(mozgalo_data_num)
#PLANIRANI_DATUM_ZATVARANJA--> NA= 421129
#DATUM_ZATVARANJA--> NA= 3978638
#STANJE_NA_KRAJU_PRETH_KVARTALA--> NA= 421068
#VISINA_KAMATE--> NA=51702
#OSTALI NEMAJU NA.

fivenum(mozgalo_data_num)

#install.packages("pastecs")
library(pastecs)
stat.desc(mozgalo_data_num)

#install.packages("Hmisc")
library(Hmisc)
describe(mozgalo_data_num)

#install.packages("installr")


#"PROIZVOD","VRSTA_PROIZVODA","TIP_KAMATE","PRIJEVREMENI_RASKID"
#Ovi nisu numeric (mogli bi se transformirati) pa necemo u korelaciju.
#pairwise ignorira NA.
mozgalo.cor<-cor(mozgalo_data_num[!names(mozgalo_data_num) %in% c("PROIZVOD","VRSTA_PROIZVODA","TIP_KAMATE","PRIJEVREMENI_RASKID")],use='pairwise')
mozgalo.cor

#mozgalo.corm<-rcorr(as.matrix(mozgalo))

#install.packages("corrplot")
library(corrplot)
#JAKO dobar plot korelacija
corrplot(mozgalo.cor)



#Dodajmo neke NOVE SMISLENE VARIJABLE

#bilo bi dobro dodati takodjer neke nove varijable na pametan nacin,
#tipa varijabla koju cemo generirati tako da gledamo koliko razlicitih ugovora klient
#(klient_ID) ima sa bankom, to bi trebalo nekako biti bitno.



#takodjer neke varijable koje nam oznacavaju nekakve makroekonomenske faktore vezane
#za ekonomiju u odredjenoj godini, nesto sto mozemo naci na netu ili neki kurac.
#npr kriza agrokora i tako neki kurci bi se mogli pokazati utjecajni, ili ulazak hrv
#u uniju ili nesto tako.




#neko kopiranje sto mi ostalo iz starog koda, da ne mijenjam sve.
mozgalo_data_num_clean<-mozgalo_data_num

#dim(mozgalo_data_num_clean)
#colnames(mozgalo_data_num)
#typeof(mozgalo_data_num_clean)
#class(mozgalo_data_num_clean)


#dodaj stupac razlika izmedju dat_zatvaranja-dat_otvaranja
mozgalo_data_num_clean["RAZLIKA_DAT_ZATV_DAT_OTV"]<-NA
mozgalo_data_num_clean["RAZLIKA_DAT_ZATV_DAT_OTV"]<-mozgalo_data_num_clean$DATUM_ZATVARANJA-mozgalo_data_num_clean$DATUM_OTVARANJA



#dodaj stupac razlika izm. planirani_dat_zatvaranja-dat_zatvaranja. 
mozgalo_data_num_clean["RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV"]<-NA
mozgalo_data_num_clean["RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV"]<-mozgalo_data_num_clean$PLANIRANI_DATUM_ZATVARANJA-mozgalo_data_num_clean$DATUM_ZATVARANJA

summary(mozgalo_data_num_clean)
#head(mozgalo_data_num_clean,10)



#stvorimo numeric od ovih kategorijskih varijabli (sto god to znacilo)
mozgalo_data_num_clean["PROIZVOD_NUM"]<-NA
mozgalo_data_num_clean["PROIZVOD_NUM"]<-as.numeric(mozgalo_data_num_clean$PROIZVOD)


mozgalo_data_num_clean["VRSTA_PROIZVODA_NUM"]<-NA
mozgalo_data_num_clean["VRSTA_PROIZVODA_NUM"]<-as.numeric(mozgalo_data_num_clean$VRSTA_PROIZVODA)


mozgalo_data_num_clean["TIP_KAMATE_NUM"]<-NA
mozgalo_data_num_clean["TIP_KAMATE_NUM"]<-as.numeric(mozgalo_data_num_clean$TIP_KAMATE)


#stvorimo novu numeric varijablu od Zavisne varijable PRIJEVREMENI_RASKID 
#da mozemo i za nju viditi korelaciju s ostalim varijablama.
mozgalo_data_num_clean["PRIJEVREMENI_RASKID_NUM"]<-NA
mozgalo_data_num_clean["PRIJEVREMENI_RASKID_NUM"]<-as.numeric(mozgalo_data_num_clean$PRIJEVREMENI_RASKID)



#MICANJE REDAKA.
#Trebalo bi pogledati ima li duplicata..

#Maknemo prvo podatke koji su OCITO krivi.
mozgalo_data_num<-mozgalo_data_num_clean
dim(mozgalo_data_num) 
#5193124      23


#starost izmedju 0 i 140
#u FAQ pise da su ovi iznad 0 i iznad 800 podaci osobe za koje ne znaju starost
mozgalo_data_num<-subset(mozgalo_data_num,STAROST<140)
mozgalo_data_num<-subset(mozgalo_data_num,STAROST>=0)
dim(mozgalo_data_num)
#5189290       23 --> makli smo 3834


#RAZLIKA_DAT_ZATV_DAT_OTV >= 0
mozgalo_data_num<-subset(mozgalo_data_num,RAZLIKA_DAT_ZATV_DAT_OTV>=0 | is.na(RAZLIKA_DAT_ZATV_DAT_OTV)==1)
dim(mozgalo_data_num)
#5188800      23 --> makli smo 490
summary(mozgalo_data_num)


#STANJE_NA_KRAJU_PRETH_KVARTALA<0 ???// STANJE_NA_KRAJU_KVARTALA<0 ???
#DA,ako su jako male vrijednosti, i stvarno imamo min = -60, dobro je!.



#VISINA_KAMATE >>0 ???
#Over the past 48 years, interest rates on the 30-year fixed-rate mortgage have ranged from 
#as high as 18.63% in 1981 to as low as 3.31% in 2012.
#Since the housing crisis in 2008, rates have consistently stayed under 6%
#Nemam pojma, mozda bi trebali <6% ???

#visina<-subset(mozgalo_data_num,VISINA_KAMATE>75) #sve visoke kamate su tipa C.
#dim(visina)
#visina


#2 kopije istih podataka.
mozgalo_data_num_clean<-mozgalo_data_num



#ovaj dio cisto demonstrativno.Da vidimo kakve se korelacije javljaju 
# za ove retke gdje imamo sve info.

#micanje NA-ova.
mozgalo_data_num_clean<-na.omit(mozgalo_data_num)

#dim(mozgalo_data_num_clean)
summary(mozgalo_data_num)
summary(mozgalo_data_num_clean)
library(Hmisc)
describe(mozgalo_data_num)
describe(mozgalo_data_num_clean)

######BITAN DIO######
######KORELACIJA za sve numeric varijable koje imamo, dakle bez:
######"PROIZVOD","VRSTA_PROIZVODA","TIP_KAMATE","PRIJEVREMENI_RASKID"
mozgalo_clean.cor<-cor(mozgalo_data_num_clean[!names(mozgalo_data_num_clean) %in% c("PROIZVOD","VRSTA_PROIZVODA","TIP_KAMATE","PRIJEVREMENI_RASKID")],use='pairwise')
mozgalo_clean.cor
library(corrplot)

png("korelacije_podataka_bez_NA.png")
corrplot(mozgalo_clean.cor)
dev.off()

dim(mozgalo_data_num_clean)

mozgalo.cor<-cor(mozgalo_data_num[!names(mozgalo_data_num) %in% c("PROIZVOD","VRSTA_PROIZVODA","TIP_KAMATE","PRIJEVREMENI_RASKID")],use='pairwise')
mozgalo.cor
library(corrplot)
corrplot(mozgalo.cor)
dim(mozgalo_data_num)
#postoji korelacija izmedju prijevremenog raskida i razlike planiranog 
#zatvaranja i stvarnog zatvaranja.
#dakle ta varijabla se definitivno moze koristiti u tom slucaju kada su nam poznati ti datumi!
#ipak ima li smisla racunati ovako korelaciju za binarne varijable???



#kreiraj neku binarnu varijablu od RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV
#mozgalo_data_num_clean$RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV_bin <- NA
#mozgalo_data_num_clean[mozgalo_data_num_clean$RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV>=0,  "RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV_bin"] <- 2
#mozgalo_data_num_clean[mozgalo_data_num_clean$RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV<0,  "RAZLIKA_PLAN_DAT_ZATV_DAT_ZATV_bin"] <- 1



