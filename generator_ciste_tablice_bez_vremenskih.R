##############podaci bez datuma izvjestavanja############

#obrisi sve, kad si saveao ovu tablicu sa numeric datumima 
#mozes od ovog dijela nastaviti.
remove(list=ls())


#OVDJE se nalaze podaci gdje su stupci datuma promjenjeni u numeric sa originom 01.01.1970
#kopira se i neki ekstra supac X.1, nebitno, to je samo broj retka nekakav.
ptm <- proc.time()
data <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_enc_num.csv", header=TRUE, sep=",")
proc.time() - ptm


#prvo sortaj po oznaka partije i medju njima po datumima izvj.jer je pametno
data<-data[order(data$OZNAKA_PARTIJE,data$DATUM_IZVJESTAVANJA),]





#radimo sa sredjeni_data u njega cemo spremiti data frame bez datuma izvj.
#i stanjima u kvartalima
sredjeni_data<-data[c("KLIJENT_ID",
"OZNAKA_PARTIJE","DATUM_OTVARANJA","PLANIRANI_DATUM_ZATVARANJA",    
"DATUM_ZATVARANJA","UGOVORENI_IZNOS",         
"VALUTA","VRSTA_KLIJENTA",                
"PROIZVOD","VRSTA_PROIZVODA",               
"VISINA_KAMATE","TIP_KAMATE",                    
"STAROST","PRIJEVREMENI_RASKID")]



#provjera dobrote operacije
head(sredjeni_data,10)
dim(sredjeni_data)
colnames(sredjeni_data)



#estrakcija unique partija i sortiranje
partije<-unique(sredjeni_data["OZNAKA_PARTIJE"])
partije<-partije$OZNAKA_PARTIJE
partije<-sort(partije)
length(partije)




#funkcija koja vraca mode (najcescu vrijednost) prvu po indeksu.
getmode <- function(v) {
   uniqv <- unique(v)
   uniqv[which.max(tabulate(match(v, uniqv)))]
}



ptm <- proc.time()
dobri<-numeric(0)
n<-length(partije)
#for (i in 1:n)
for (i in 1:100)
{
	pozicije<-which(partije[i]==sredjeni_data$OZNAKA_PARTIJE)
	pozicije<-sort(pozicije)
	dobri<-c(dobri,pozicije[1])



#upisujemo pametno uzimajuci u obzir gdje postoje NA-ovi,
#za ostale podatke pretpostavljamo da su konzistentni inace jebat ga,
#ne mogu ja znat sto su htjeli napisat, ako postoji greska neka jebat ga.
#PLANIRANI_DATUM_ZATVARANJA--> NA= 421129
#DATUM_ZATVARANJA--> NA= 3978638
#STANJE_NA_KRAJU_PRETH_KVARTALA--> NA= 421068
#VISINA_KAMATE--> NA=51702
#OSTALI NEMAJU NA.

	
#uzimam sve datume zatvaranja
	datumzatv<-sredjeni_data$DATUM_ZATVARANJA[pozicije]
#upisat cu zadnji datum koji nije NA, pretpostavka je da je taj tocan.
	datumzatv<-na.omit(datumzatv)
	if (length(datumzatv)>0){
	sredjeni_data$DATUM_ZATVARANJA[dobri[i]]<-datumzatv[length(datumzatv)]}

#uzimam sve planirane datume zatvaranja
	pdatumzatv<-sredjeni_data$PLANIRANI_DATUM_ZATVARANJA[pozicije]
#ako ima vise iznosa upisat cu onaj raniji koji nije NA
	pdatumzatv<-na.omit(pdatumzatv)
	if (length(pdatumzatv)>0){
	sredjeni_data$PLANIRANI_DATUM_ZATVARANJA[dobri[i]]<-pdatumzatv[1]}


#	pdatumzatv<-pdatumzatv[length(pdatumzatv):1]
#	sredjeni_data$PLANIRANI_DATUM_ZATVARANJA[dobri[i]]<-getmode(pdatumzatv)

#uzimam sve kamate
	kamata<-sredjeni_data$VISINA_KAMATE[pozicije]
#ako ima vise iznosa upisat cu najcesci, ako ima vise najcescih upisat cu onaj raniji.
	kamata<-na.omit(kamata)
	if (length(kamata)>0){
	sredjeni_data$VISINA_KAMATE[dobri[i]]<-kamata[1]}


#	kamata<-kamata[length(kamata):1]
#	sredjeni_data$VISINA_KAMATE[dobri[i]]<-getmode(kamata)

}
proc.time() - ptm


sredjeni_data<-sredjeni_data[dobri,]

head(sredjeni_data,10)
head(data,50)



#jos dodaj:
#IF DATUM_ZATVARANJA + 10 dana < PLANIRANI_DATUM_ZATVARANJA:
#  PRIJEVREMENI_RASKID = Y
#ELSE
#  PRIJEVREMENI_RASKID = N


write.csv(sredjeni_data,file="training_without_TS.csv")



