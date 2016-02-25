#!binbash
#Autor Ardo Erik

#esimene kodutöö

#Väljumiskoodid
#1 - vale arv param
#2 - on vaja juure õigusi

#Juurkasutaja õiguste olemasolu kontroll

if [ $UID -ne 0 ]
then
    echo on vaja juurkasutaja õigusi
    exit 2
fi


#parameetrite arvu kontroll
if [ $# -ne  2 ] && [ $# -ne 3 ]; then
    echo kasutamine $0 KAUST GRUPP JAGATUD KAUST
    exit 1

fi

#muutujate väärtustamine parameetritega
#esimene param= kaust
#teine param= grupp
#kolmas param= jagatav kaust
KAUST=$1
KAUSTBASE=$(basename $KAUST)
GRUPP=$2
JAGAKAUST=${3-$KAUSTBASE}

#testimise argumendid, välja komenteeritud

#echo KAUST=$KAUST
#echo KAUSTBASE=$KAUSTBASE
#echo GRUPP=$GRUPP
#echo JAGAKAUST=$JAGAKAUST

#3 argumendi puhul kausta määramine
if [ $# -eq  3 ]; then
    KAUSTBASE=$JAGAKAUST
   
fi

#Käivitatava kausta asukoht
ALG=$(pwd)

#kontrollib samba olemasolu ja vajadusel paigaldab selle
type smbd  devnull 2&1

if [ $ -ne 0 ]
then
    echo pole sambat, installin
    apt-get update  devnull 2&1 && apt-get install samba -y  exit 1
fi

#kausta olemasolu kontroll, vajadusel luuakse
test -d $KAUST  mkdir -p $KAUST

#täis tee saamine ja algsesse tagasi minema
cd $KAUST
FULL=$(pwd)
#echo $FULL
cd $ALG

#gruppi olemasolu kontroll, teisel juhul see luuakse
getent group $GRUPP  devnull  addgroup $GRUPP  devnull

#sama faili varukoopia loomine
cp etcsambasmb.conf etcsambasmb.conf.varu



#varukoopia faili täiendatakse, PATH TÄISPIKK TEE
cat  etcsambasmb.conf.varu  ADDING

[$KAUSTBASE]
comment=jaga mind
path=$FULL
writable=yes
valid users=@$GRUPP
force group=$GRUPP
browsable=yes
create mask=0664
directory mask=0775

ADDING

#kopeerime muutuse algsesse confi ja reloadime. Sellega
#salvestatakse muutus jäävaks

cp etcsambasmb.conf.varu etcsambasmb.conf
service smbd restart

echo Kõik õnnestus edukalt, puhka nüüd.