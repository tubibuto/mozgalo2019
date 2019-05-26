remove(list=ls())
#stavi neki svoj directory gdje drzis podatke.
mozgalo <- read.csv("C:/Users/User/Desktop/MOZGALO/MOZGALO2019/training_dataset_enc.csv", header=TRUE, sep=",")

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
