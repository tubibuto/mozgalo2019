#Ova R biljeznica generira "vremenske nizove" iz raw pocetnog dataseta dobivenog od organizatora mozgala.
#ideja je izvuci za svaku partiju njihova stanja u kvartalima u danom izvjestaju te kreirati 33 featurea.
#svaki se odnosi na 4x8 datuma izvjestavanja + 31.12.2010 jer postoji feature stanja u prethodnom kvartalu
#za izvjestaje sa datumom 31.3.2011

rm(list=ls())
ls()

ptm <- proc.time()
mozgalo <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_enc.csv", header=TRUE, sep=",")
proc.time() - ptm

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




#trebaju nam samo ova 4 featura za vremenske, ostalo ne trebamo pamtiti.
newdata<-mozgalo_copy[c("DATUM_IZVJESTAVANJA","OZNAKA_PARTIJE","STANJE_NA_KRAJU_PRETH_KVARTALA","STANJE_NA_KRAJU_KVARTALA")]

rm(mozgalo_copy)
rm(mozgalo)

#sortaj po oznaka partije i medju njima po datumima izvj.
newdata<-newdata[order(mozgalo_data_num$OZNAKA_PARTIJE,mozgalo_data_num$DATUM_IZVJESTAVANJA),]



#izvlaci unique partije i datume.
partije<-unique(newdata["OZNAKA_PARTIJE"])
partije<-partije$OZNAKA_PARTIJE
partije<-sort(partije)
length(partije)


datumiizv<-unique(newdata["DATUM_IZVJESTAVANJA"])
datumiizv<-datumiizv$DATUM_IZVJESTAVANJA
datumiizv<-sort(datumiizv)
datumiizv
length(datumiizv)





#broj stupaca=koliko imamo datuma izvjestavanja + 1 (za "2010-12-31" ,javlja se ako je prethodnik od "2011-3-31") + partija
time_series<-data.frame(matrix(ncol=(length(datumiizv)+2),nrow=length(partije)))
#kreiramo imena feature po ovom redosljedu.
colnames(time_series)[1]<-"OZNAKA_PARTIJE"
colnames(time_series)[2]<-"2010-12-31"
for (i in 3:ncol(time_series))
{
      colnames(time_series)[i]<-as.character(as.Date(datumiizv[i-2],origin = "1970-01-01"))
}
colnames(time_series)
dim(time_series)

head(time_series,2)



#odma popuni vektorski oznake partije
time_series$OZNAKA_PARTIJE<-partije

ptm <- proc.time()
poz<-1
n<-length(partije)
#for (i in 1:n)
for (i in 1:100)
{
#iskoristimo sortiranost.
	print(i)
	part<-partije[i]
	pozicije<-numeric(0)
	pozicije<-c(pozicije,poz)
	poz=poz+1
	while(part==newdata$OZNAKA_PARTIJE[poz])
	{
		pozicije<-c(pozicije,poz)
		poz=poz+1
	}

	#pozicije<-which(partije[i]==newdata$OZNAKA_PARTIJE)
	
#ovdje samo lovimo kojim su nam datumi u pitanju na pozicijama za tu oznaku partije
#zatim sa poredcima samo gledamo gdje su ti stupci u tablici (ne moraju poceti od 
#prvog naravno)

	datumi<-newdata$DATUM_IZVJESTAVANJA[pozicije]
	poredci<-match(datumi,datumiizv)
	poredci<-sort(poredci)

	stanja1<-newdata$STANJE_NA_KRAJU_KVARTALA[pozicije]

#samo kada je prvi/najmanji datum jednak 15064 sto je 31.3.2011.
#koristimo stanje prethodnog kvartala i popunjavamo redak 31.12.2010.

#inace koristimo uvijek stanja u kvartalu jer oni nemaju ni jedan NA za razliku
#od stanja u preth kvartalu.
	if (datumi[1] == 15064 )
	{
		time_series[i,2]<-newdata$STANJE_NA_KRAJU_PRETH_KVARTALA[pozicije[1]]
	}

	time_series[i,poredci+2]<-stanja1


}
proc.time() - ptm

head(time_series,10)



write.csv(time_series,file="training_time_series.csv")





