*APAGUE janela de resultados.
set  locale="en_US.windows-1252"
OUTPUT CLOSE.
*a pesquisa comecou em agosto de 2014 que eh quando a primeira paciente recebeu RALTEGRAVIR.
COMPUTE sdate = Date.DMY(1,8,2014).

*data do fim da pesquisa.
compute finald = Date.DMY(31,10,2018).

*data da última carga viral.
compute foo1= Date.DMY(9,9,1900).
compute foo2 = Date.DMY(7,7,1700).
compute foo3 = Date.DMY(8,8,1800).
compute dtlastcv = Date.DMY(9,9,1900).

if(NOT(viralpar=77777777 OR viralpar=88888888 OR viralpar=99999999 ) AND NOT(viralmat=77777777 OR viralmat=88888888 OR viralmat=99999999 ) )
dtlastcv = dtvirmat.
if (NOT(viralpar=77777777 OR viralpar=88888888 OR viralpar=99999999 ) AND (viralmat=77777777 OR viralmat=88888888 OR viralmat=99999999 ) )
dtlastcv = dtvirpro.
if((viralpar=77777777 OR viralpar=88888888 OR viralpar=99999999 ) AND NOT(viralmat=77777777 OR viralmat=88888888 OR viralmat=99999999 ) )
dtlastcv = dtvirmat.

*if(NOT(dtvirpro=foo1 or dtvirpro=foo2 or dtvirpro=foo3 )AND NOT(dtvirmat=foo1 or dtvirmat=foo2 or dtvirmat=foo3) ) 
dtlastcv = dtvirmat.
*if (NOT(dtvirpro=foo1 or dtvirpro=foo2 or dtvirpro=foo3 ) AND (dtvirmat=foo1 or dtvirmat=foo2 or dtvirmat=foo3) )
dtlastcv = dtvirpro.
*if((dtvirpro=foo1 or dtvirpro=foo2 or dtvirpro=foo3 ) AND NOT(dtvirmat=foo1 or dtvirmat=foo2 or dtvirmat=foo3 ) )
dtlastcv = dtvirmat.
dataset activate aposcomeco.
*recode viralmat (0= 40).
*recode viralpre (0 =40).
*recode viralpar (0 =40).
execute.
*valor da últimate carga viral.
compute lastcv = 0.
lastcv=viralpar.
if(NOT(viralpar=77777777 OR viralpar=88888888 OR viralpar=99999999 ) AND NOT(viralmat=77777777 OR viralmat=88888888 OR viralmat=99999999 ) )
lastcv = viralmat.
if (NOT(viralpar=77777777 OR viralpar=88888888 OR viralpar=99999999 ) AND (viralmat=77777777 OR viralmat=88888888 OR viralmat=99999999 ) )
lastcv = viralpar.
if((viralpar=77777777 OR viralpar=88888888 OR viralpar=99999999 ) AND NOT(viralmat=77777777 OR viralmat=88888888 OR viralmat=99999999 ) )
lastcv = viralmat.

*CALCULE TEMPO DE EXPOSICAO AO ARV1.
*COMPUTE tarv1=DATEDIFF(dtlastcv,dtarv1,"weeks").
compute tarv1 = datediff(dtlastcv,dtarv1,"weeks").

*1. Escolha os casos apos a data do começo da pesquisa.
* Caixa 1: Avaliadas para elegibilidade de COMEÇO ate 01/2018.
* O numero de casos nesse dataset vai ser o valor de "Avaliadas para elegibilidade de 08/2014 a 01/2018 (n= xxx)" no diagrama CONSORT

DATASET ACTIVATE DataSet1.
DATASET COPY  APOSCOMECO.
DATASET ACTIVATE APOSCOMECO.
FILTER OFF.
USE ALL.
SELECT IF (dtarv1 >= sdate and dtarv1 > foo1).
EXECUTE.

ECHO "Avaliadas para elegibilidade de 08/2014 a 10/2018:".

DATASET ACTIVATE APOSCOMECO.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.


*Caixa 2. Quantas pacientes vao ser excluidas antes de separar elas em braços de medicinas?

*Caixa 2a: O numero de consultas pre-natais desconhecido ou menos de < 3.
* O numero de casos nesse dataset vai ser o valor de "Sem dados do número de consultas pré-natais (n=xxx)" no diagrama CONSORT.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY NAOPRE.
DATASET ACTIVATE NAOPRE.
FILTER OFF.
USE ALL.
SELECT IF ( (consupre=99  or consupre <3))  . 
EXECUTE.

ECHO "Sem dados do número de consultas pré-natais ou menos de 3 visitas:".

DATASET ACTIVATE NAOPRE.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.

DATASET CLOSE NAOPRE.

*Caixa 2b: < 2 weeks ARV.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY LT2WKS.
DATASET ACTIVATE LT2WKS.
SELECT IF ( 
((tarv1 >=45) or (tarv1 <=1)) 
).
EXECUTE.

ECHO "Tempo de exposiçao ao ARV foi menos de duas semanas:".

DATASET ACTIVATE LT2WKS.
DESCRIPTIVES VARIABLES=ID
/STATISTICS=MEAN.

DATASET CLOSE LT2wks.

ECHO "Trocou ARV mais tomou pelo ARV por pelo menos duas semanas:".

*Toxicidade.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY toxi.
DATASET ACTIVATE toxi.
SELECT IF (motivosu=3 or motivosu=2).
EXECUTE.

ECHO "Motivo de suspensão toxicidade:".

DATASET ACTIVATE toxi.
DESCRIPTIVES VARIABLES=ID
/STATISTICS=MEAN.

DATASET CLOSE toxi.

*gemelar.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY GEM.
DATASET ACTIVATE GEM.
FILTER OFF.
USE ALL.
SELECT IF(    gemelar=2 or gemelar=3 ).
EXECUTE.

ECHO "GEM:".

DATASET ACTIVATE GEM.
DESCRIPTIVES VARIABLES=ID
/statistics=mean.
execute.

DATASET CLOSE GEM.

*Caixa 2: nao tem cv ou próximo ao parto ou ao parto.
DATASET ACTIVATE APOSCOMECO.
compute semcv = (( (viralpar =77777777 ) OR (viralpar = 88888888 ) OR (viralpar = 99999999 ) )AND ( (viralmat = 77777777) OR (viralmat =88888888) OR (viralmat =99999999) ) ).
DATASET COPY NOCV.
DATASET ACTIVATE NOCV.
SELECT IF semcv=1.
EXECUTE.

ECHO "Sem CV AO PARTO OU PROXIMO AO PARTO:".

DATASET ACTIVATE NOCV.
DESCRIPTIVES VARIABLES=ID
/STATISTICS=MEAN.

DATASET CLOSE NOCV.

*Caixa 2: Número de pacientes que trocaram de regime de ARV.".
DATASET ACTIVATE APOSCOMECO.
DATASET COPY TROCA.
DATASET ACTIVATE TROCA.
SELECT IF ( 
(NOT(arv1=0) and 
NOT(arv1=88) and 
NOT(arv1>=99) and 
(arv2 >= 1) and 
not(arv2 = 88)and
(arv2 < 99) and
NOT(
(DateDiff(dtretira,dtarv1,"weeks")>= 2)
and
(
(DateDiff(dtlastcv,dtretira,"days")>=0)
)
)
)
).
EXECUTE.

dataset activate aposcomeco.
compute repor = (DateDiff(dtretira,dtarv1,"weeks")>= 2)
and
(
(DateDiff(dtlastcv,dtretira,"days")>=0)
and (DateDiff(dtlastcv,foo1,"days")>=0)
).
execute.

ECHO "Número de pacientes que trocaram de ARV:".

DATASET ACTIVATE TROCA.
DESCRIPTIVES VARIABLES=ID
/STATISTICS=MEAN.

DATASET CLOSE TROCA.

*Caixa 2c: O esquema de TARV nao foi RAL, EFV ou Lopinavir e a data de ARV1 foi apos o começo da pesquisa.
* O numero de casos nesse dataset vai ser o valor de "ESQUEMA de TARV nao foi RAL, EFV ou LOPINAVIR (n =xxx)" no diagrama CONSORT.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY TARVDIFF.
DATASET ACTIVATE TARVDIFF.
FILTER OFF.
USE ALL.
SELECT IF ( NOT(
(arv1 = 0)
or
(arv1 = 81)
or
(arv1 = 84)
or
(arv1 = 89)
or
(arv1 = 47)
or
(arv1 = 58)
or
(arv1 = 29)
or
(arv1 = 34)
or
(arv1 = 43)
or
(arv1 = 38)
or
(arv1 = 59)
or
(arv1 = 50)
or
(arv1 = 60) 
or
(arv1 = 90)
) 
). 
EXECUTE.

ECHO "ESQUEMA de TARV nao foi RAL, EFV, LPV, ou ATV:".

DATASET ACTIVATE TARVDIFF.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.

DATASET CLOSE TARVDIFF.

*Caixa 2d:Engravidaram com uso de ARV.
* O numero de casos nesse dataset vai ser o valor de "ENGRAVIDARAM COM USO DE ARV (N=94)" no diagrama CONSORT.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY NAONAIF.
DATASET ACTIVATE NAONAIF.
FILTER OFF.
USE ALL.
SELECT IF (( arv1= 0 )or (freqentr > 1)). 
EXECUTE.

dataset activate naonaif.
compute tarv4 = datediff(cadastro,dtarv1,"weeks").
execute.

ECHO "ENGRAVIDARAM COM USO DE ARV:".

DATASET ACTIVATE NAONAIF.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.

DATASET CLOSE NAONAIF.

*Caixa 2e:Genotipagem detectou resistência.
* O numero de casos nesse dataset vai ser o valor de "Genotipagem indica resistência a RAL, EFV ou Lopinavir" no diagrama CONSORT.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY RES.
DATASET ACTIVATE RES.
FILTER OFF.
USE ALL.
SELECT IF ( (dtarv1 >=sdate)  AND( ( ( arv1 = 84 )  AND (motivosu = 6) )OR ( ( arv1 = 89 ) AND (motivosu = 6) ) OR ( ( arv1 = 81 ) AND (motivosu = 6) ) OR
 ( ( arv1 = 47 ) AND (motivosu = 6) ) OR ( ( arv1 = 58 ) AND (motivosu = 6) ) OR
 ( ( arv1 = 29 ) AND (motivosu=6 )) OR ( ( arv1 = 34 ) AND (motivosu=6 ) ) OR ( ( arv1 = 43 ) AND (motivosu=6) ) OR ( (arv1 = 38) AND (motivosu=6) ) or( (arv1 = 59)
 AND (motivosu=6) ) or( (arv1 = 60) AND (motivosu=6) ) or ( (arv1 = 90) AND (motivosu=6) )     ) ). 
EXECUTE. 

ECHO "Genotipagem indica resistência a RAL, EFV ou LPV:".

DATASET ACTIVATE RES.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.

DATASET CLOSE RES.

dataset activate aposcomeco.
compute repor2 = (arv1 = 84) OR (arv1 = 89) OR (arv1 = 81).
execute.


*Caixa 3a:
**Escolha as pacientes de RAL apos a data do começo da pesquisa.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY RAL.
DATASET ACTIVATE RAL.
FILTER OFF.
USE ALL.
SELECT IF (NOT(semcv) AND ( (arv1 = 84) OR (arv1 = 89) OR (arv1 = 81)  ) AND (dtarv1 >= sdate) AND NOT(consupre=99) and (consupre >=3) and (freqentr=1) and 
NOT(motivosu=6) and (tarv1 >=1) and (tarv1 <45) and (dtlastcv > foo1) or ((repor=1) and ( (arv1 = 84) OR (arv1 = 89) OR (arv1 = 81)  ))).
*SELECT IF (NOT(semcv) AND ( (arv1 = 84) OR (arv1 = 89) OR (arv1 = 81)  ) AND (dtarv1 >= sdate) AND NOT(consupre=99) and (consupre >=3) and (freqentr=1) and NOT(motivosu=6)and (tarv1 >=1)   and (tarv1 <45) and (arv2 >=99)).
EXECUTE.

ECHO "Pacientes de RAL:".

DATASET ACTIVATE RAL.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN
/MISSING LISTWISE.
execute.

*Caixa 3b:
**Escolha as pacientes de EFV apos a data do começo da pesquisa.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY EFV.
DATASET ACTIVATE EFV.
FILTER OFF.
USE ALL.
SELECT IF (NOT(semcv) AND ( (arv1 = 47) OR (arv1 = 58) or(arv1=50)) AND (dtarv1 >= sdate) AND NOT(consupre=99) AND NOT(motivosu=6)and (consupre >=3) and (freqentr=1) and (tarv1 >=1) and (tarv1 <45) and dtlastcv > foo1 or
 (repor=1 and ((arv1 = 47) OR (arv1 = 58) or(arv1=50))) ).
*SELECT IF (NOT(semcv) AND ( (arv1 = 47) OR (arv1 = 58) or(arv1=50)) AND (dtarv1 >= sdate) AND NOT(consupre=99) AND NOT(motivosu=6)and (consupre >=3) and (freqentr=1)and (tarv1 >=1)  and (tarv1 <45) and (arv2 >=99) ).
EXECUTE.

ECHO "Pacientes de EFV:".

DATASET ACTIVATE EFV.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.
execute.

*Caixa 3c:
**Escolha as pacientes de LOP apos a data do começo da pesquisa.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY LOP.
DATASET ACTIVATE LOP.
FILTER OFF.
USE ALL.
SELECT IF (NOT(semcv) AND ( (arv1 = 29) OR (arv1 =34)  OR (arv1 = 43) OR (arv1 = 38) or(arv1 = 59) or (arv1=60) or (arv1=90)  ) AND (dtarv1 >= sdate) AND NOT(consupre=99) AND
NOT(motivosu=6)and (consupre >=3) and (freqentr=1) and  (tarv1 >=1) and (tarv1 <45) and dtlastcv > foo1 or ((repor=1) and ( (arv1 = 29) OR (arv1 =34)  OR (arv1 = 43) OR (arv1 = 38) or(arv1 = 59) or (arv1=60) or (arv1=90)  ))).
*SELECT IF (NOT(semcv) AND ( (arv1 = 29) OR (arv1 =34)  OR (arv1 = 43) OR (arv1 = 38) or(arv1 = 59) or (arv1=60) or (arv1=90)  ) AND (dtarv1 >= sdate) AND NOT(consupre=99) AND
* NOT(motivosu=6)and (consupre >=3) and (freqentr=1) and (tarv1 >= 1) and (tarv1 <45) and (arv2 >=99)  ).

EXECUTE.

ECHO "Pacientes de LPV or ATV:".

DATASET ACTIVATE LOP.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.
execute.

DATASET ACTIVATE LOP.
Dataset copy atv.
dataset activate atv.
select if (arv1 = 38 or arv1=59 or arv1=60 or arv1=90).
execute.

ECHO "ATV only".

dataset activate atv.
descriptives variables=id
/statistics=mean.
execute.

dataset close atv.
DATASET CLOSE APOSCOMECO.
*Caixa 4a:
**Escolha as pacientes de RAL que nao tem Carga Viral proximo ao parto.
*Sem CV mais próximo ao parto (n=1).
DATASET ACTIVATE RAL.
DATASET COPY RALSEMCV.
DATASET ACTIVATE RALSEMCV.
FILTER OFF.
USE ALL.
SELECT IF (lastcv=99999999 or lastcv=0 ).
EXECUTE.

ECHO "RAL sem CV mais próximo ao parto.".

DATASET ACTIVATE RALSEMCV.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN
/MISSING LISTWISE.
execute.
DATASET CLOSE RALSEMCV.

*Caixa 4b:
**Escolha as pacientes de EFV que nao tem Carga Viral proximo ao parto.
*Sem CV mais próximo ao parto (n=2).
DATASET ACTIVATE EFV.
DATASET COPY EFVSEMCV.
DATASET ACTIVATE EFVSEMCV.
FILTER OFF.
USE ALL.
SELECT IF (lastcv=99999999 or lastcv=0 ).
EXECUTE.

ECHO "EFV sem CV maispróximo ao parto.".

DATASET ACTIVATE EFVSEMCV.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.
execute.
DATASET CLOSE EFVSEMCV.

*Caixa 4c:
**Escolha as pacientes de LOP que nao tem Carga Viral proximo ao parto.
*Sem CV mais próximo ao parto (n=0).
DATASET ACTIVATE LOP.
DATASET COPY LOPSEMCV.
DATASET ACTIVATE LOPSEMCV.
FILTER OFF.
USE ALL.
SELECT IF (lastcv=99999999 or lastcv=0).
EXECUTE.

ECHO "LPV ou ATV sem CV maispróximo ao parto.".

DATASET ACTIVATE LOPSEMCV.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.
DATASET CLOSE LOPSEMCV.

*Caixa 5a:
**Escolha as pacientes de RAL que precisavam trocar o esquema de ARV por toxiciade clinica ou laboratorial.
*Precisava trocar o esquema TARV (n=2).
DATASET ACTIVATE RAL.
DATASET COPY RALTROC.
DATASET ACTIVATE RALTROC.
FILTER OFF.
USE ALL.
SELECT IF ( NOT(lastcv=99999999 ) and ((motivosu=2) OR (motivosu=3)  )).
EXECUTE.

ECHO "Numero de pacientes de RAL que precisavam trocar o esquema de ARV:".

DATASET ACTIVATE RALTROC.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN
/MISSING LISTWISE.
execute.
DATASET CLOSE RALTROC.

*Caixa 5b:
**Escolha as pacientes de EFV que precisavam trocar o esquema de ARV.
*Precisava trocar o esquema TARV (n=29).
DATASET ACTIVATE EFV.
DATASET COPY EFVTROC.
DATASET ACTIVATE EFVTROC.
FILTER OFF.
USE ALL.
SELECT IF( NOT(lastcv=99999999 ) and ( (motivosu=2) OR (motivosu=3)  )).
EXECUTE.

ECHO "Numero de pacientes de EFV que precisavam trocar o esquema de ARV:".

DATASET ACTIVATE EFVTROC.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.
execute.
DATASET CLOSE EFVTROC.

*Caixa 5c:
**Escolha as pacientes de LOP que precisavam trocar o esquema de ARV.
*Precisava trocar o esquema TARV (n=41).
DATASET ACTIVATE LOP.
DATASET COPY LOPTROC.
DATASET ACTIVATE LOPTROC.
FILTER OFF.
USE ALL.
SELECT IF ( NOT(lastcv=99999999 ) and( (motivosu=2) OR (motivosu=3) ) ).
EXECUTE.


ECHO "Numero de pacientes de LPV ou ATV que precisavam trocar o esquema de ARV:".

DATASET ACTIVATE LOPTROC.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.
execute.
DATASET CLOSE LOPTROC.

*RAL gravidez gemelar.
DATASET ACTIVATE RAL.
DATASET COPY RALGEM.
DATASET ACTIVATE RALGEM.
FILTER OFF.
USE ALL.
SELECT IF(    gemelar=2 or gemelar=3 ).
EXECUTE.

ECHO "RAL GEM:".

DATASET ACTIVATE RALGEM.
DESCRIPTIVES VARIABLES=gemelar
/statistics=mean.
execute.

DATASET CLOSE RALGEM.

*RAL com CV proximo ao parto e nao trocaram o esquema.
DATASET ACTIVATE RAL.
DATASET COPY RALBOM.
DATASET ACTIVATE RALBOM.
FILTER OFF.
USE ALL.
SELECT IF(   NOT( (motivosu=2  OR motivosu=3  ) OR   lastcv=99999999 or lastcv=0 or gemelar=2 or gemelar=3) ).
EXECUTE.
DATASET CLOSE RAL.

ECHO "RAL CV PROXIMO AO PARTO (34 a 35 SEMANAS) e SEM TOXICIDADE DE RAL:".


*Variável categórica para definir classe de medicina".
DATASET ACTIVATE RALBOM.
COMPUTE MEDICINA=1.
DESCRIPTIVES VARIABLES=lastcv
/STATISTICS=MEAN.
EXECUTE.

*EFV gravidez gemelar.
DATASET ACTIVATE EFV.
DATASET COPY EFVGEM.
DATASET ACTIVATE EFVGEM.
FILTER OFF.
USE ALL.
SELECT IF(    gemelar=2 or gemelar=3 ).
EXECUTE.

ECHO "EFV GEM:".

DATASET ACTIVATE EFVGEM.
DESCRIPTIVES VARIABLES=gemelar
/statistics=mean.
execute.

DATASET CLOSE EFVGEM.

*EFV com CV proximo ao parto e nao trocaram o esquema.
DATASET ACTIVATE EFV.
DATASET COPY EFVBOM.
DATASET ACTIVATE EFVBOM.
FILTER OFF.
USE ALL.
SELECT IF(   NOT( (motivosu=2  OR motivosu=3) OR   lastcv=99999999 or lastcv=0 or FREQENTR = 3) ).
EXECUTE.
DATASET CLOSE EFV.

ECHO "EFV CV PROXIMO AO PARTO (34 a 35 SEMANAS):".

DATASET ACTIVATE EFVBOM.
DESCRIPTIVES VARIABLES=lastcv
/STATISTICS=MEAN.
execute.
*Variável categórica para definir classe de medicina".
DATASET ACTIVATE EFVBOM.
COMPUTE MEDICINA=2.
EXECUTE.

*LOP gravidez gemelar.
DATASET ACTIVATE LOP.
DATASET COPY LOPGEM.
DATASET ACTIVATE LOPGEM.
FILTER OFF.
USE ALL.
SELECT IF(    gemelar=2 or gemelar=3 ).
EXECUTE.

ECHO "LOP GEM:".

DATASET ACTIVATE LOPGEM.
DESCRIPTIVES VARIABLES=gemelar
/statistics=mean.
execute.

DATASET CLOSE LOPGEM.
*LOP com CV proximo ao parto e nao trocaram o esquema.
DATASET ACTIVATE LOP.
DATASET COPY LOPBOM.
DATASET ACTIVATE LOPBOM.
FILTER OFF.
USE ALL.
SELECT IF(   NOT( (motivosu=2  OR motivosu=3) OR   lastcv=99999999 or lastcv = 0 ) ).
EXECUTE.
DATASET CLOSE LOP.

*Variável categórica para definir classe de medicina".
DATASET ACTIVATE LOPBOM.
COMPUTE MEDICINA=3.
EXECUTE.

VALUE LABELS
Medicina 
1 'RAL'
2 'EFV'
3 'LPV/r&ATV/r'.
EXECUTE.

ECHO "LOP CV PROXIMO AO PARTO (34 a 35 SEMANAS):".

DATASET ACTIVATE LOPBOM.
DESCRIPTIVES VARIABLES=lastcv
/STATISTICS=MEAN.
execute.
ECHO "LOP MTCT: ".

DATASET ACTIVATE LOPMTCT.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.
DATASET CLOSE LOPMTCT.

add files file RALBOM / file EFVBOM / file LOPBOM.
SAVE OUTFILE="C:/Users/Fuller/Documents/prsnnl250220_2.sav".
Execute.
dataset name merged1.

dataset activate merged1.
examine viralpre 
/statistics descriptives.
execute.

compute logbas2 = lg10(viralpre).
dataset activate merged1.
examine logbas2 by medicina
/statistics descriptives.
execute.


dataset activate merged1.
RECODE tarv1 (1 thru 7=1) (8 thru 14=2) (14 thru 44=3)INTO tarv2. 
VARIABLE LABELS  tarv2 'tarv2'. 
EXECUTE.

value labels
tarv2
1 '2-7'
2 '8-14'
3 '>14'.
execute.

value labels
MEDICINA
1 'RAL'
2 'EFV'
3 'LPV/r and ATV/r'.
execute.

Examine tarv1 by tarv2 by medicina
/statistics descriptives.
execute.

DATASET ACTIVATE merged1 . 
COMPUTE delcv =lg10(lastcv/viralpre).
EXECUTE.

DATASET ACTIVATE RALBOM. 
COMPUTE delcv =lg10(lastcv/viralpre).
EXECUTE.
dataset close ralbom.

DATASET ACTIVATE EFVBOM. 
COMPUTE delcv =lg10(lastcv/viralpre).
EXECUTE.
DATASET CLOSE EFVBOM.

DATASET ACTIVATE LOPBOM. 
COMPUTE delcv =lg10(lastcv/viralpre).
EXECUTE.
dataset close lopbom.

dataset activate merged1.
compute delcv2 = -1*delcv.
missing values delcv2 (-1).
if(delcv >= 0)delcv2 = -1.
if(delcv < 0)delcv2 = -1*delcv.
execute.
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
*----------------------------------------------------------------------------------------------------------------------------------------------.
*.
* GRAFICO QUEDA DA CV COMO FUNCIONA DO TEMPO DE ARV
*.
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------.
*---------------------------------------------------------------------------------------------------------------------------------------------.

* Chart Builder. 
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=tarv2 MEANSE(delcv2, 1.)[name="MEAN_delcv2" LOW="MEAN_delcv2_LOW" HIGH="MEAN_delcv2_HIGH"] MEDICINA MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: tarv2=col(source(s), name("tarv2"), unit.category()) 
  DATA: MEAN_delcv2=col(source(s), name("MEAN_delcv2")) 
  DATA: MEDICINA=col(source(s), name("MEDICINA"), unit.category()) 
  DATA: LOW=col(source(s), name("MEAN_delcv2_LOW")) 
  DATA: HIGH=col(source(s), name("MEAN_delcv2_HIGH")) 
  COORD: rect(dim(1,2), cluster(3,0)) 
	 GUIDE: text.title(label(""))
  GUIDE: axis(dim(3), label("Exposure to cART (weeks)")) 
  GUIDE: axis(dim(2), label("Log decrease in viral load after cART (mean +/- S.E.)")) 
  GUIDE: legend(aesthetic(aesthetic.texture.pattern.interior), label("ARV")) 
  SCALE: cat(dim(3), include("1.00", "2.00", "3.00")) 
  SCALE: linear(dim(2), min(0), max(3.0)) 
  SCALE: cat(aesthetic(aesthetic.texture.pattern.interior)) 
  SCALE: cat(dim(1), include("1.00", "2.00", "3.00"))
  ELEMENT: interval(position(MEDICINA*MEAN_delcv2*tarv2), texture.pattern.interior(MEDICINA), shape.interior(shape.square)) 
  ELEMENT: interval(position(region.spread.range(MEDICINA*(LOW+HIGH)*tarv2)), shape.interior(shape.ibeam)) 
END GPL.

*DATASET CLOSE merged1. 
MEANS TABLES=viralmat viralpar viralpre BY MEDICINA 
  /CELLS GEOMETRIC 
  /STATISTICS ANOVA.
Examine viralpre  by medicina
/statistics descriptives.
execute.
****************************************************************************************************.
* CV MEDIA NA ENTRADA .
****************************************************************************************************.

MEANS TABLES=viralpre BY MEDICINA 
  /CELLS MEAN COUNT STDDEV 
  /STATISTICS ANOVA.

****************************************************************************************************.
* LOG CV MEDIA NA ENTRADA .
****************************************************************************************************.

examine logbasal BY MEDICINA 
 /STATISTICS descriptives.
execute.

ONEWAY logbasal BY MEDICINA 
  /MISSING ANALYSIS.

****************************************************************************************************.
* LOG CV MEDIA PROXIMO AO PARTO .
****************************************************************************************************.

examine logparto BY MEDICINA 
 /STATISTICS descriptives.
execute.

ONEWAY logparto BY MEDICINA 
  /MISSING ANALYSIS.

****************************************************************************************************.
* LOG CV MEDIA AO PARTO .
****************************************************************************************************.

examine logmater BY MEDICINA 
 /STATISTICS descriptives.
execute.

ONEWAY logmater BY MEDICINA 
  /MISSING ANALYSIS.

BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: tardia=col(source(s), name("tardia"), unit.category())
  DATA: MEAN_delcd4=col(source(s), name("MEAN_delcd4"))
  DATA: MEDICINA=col(source(s), name("MEDICINA"), unit.category())
  DATA: LOW=col(source(s), name("MEAN_delcd4_LOW"))
  DATA: HIGH=col(source(s), name("MEAN_delcd4_HIGH"))
  COORD: rect(dim(1,2), cluster(3,0))
	 GUIDE: text.title(label("Mudança na CD4 após a Exposição da Gestante a ARV"))
  GUIDE: axis(dim(3), label("Apresentaçao tardia"))
  GUIDE: axis(dim(2), label("Mudança na CD4 após à exposiçao ao ARV (média +/- IC95)"))
  GUIDE: legend(aesthetic(aesthetic.texture.pattern.interior), label("ARV"))
  SCALE: cat(dim(3), include("0.00", "1.00"))
  SCALE: linear(dim(2), min(0), max(300.0))
  SCALE: cat(aesthetic(aesthetic.texture.pattern.interior))
  SCALE: cat(dim(1), include("0.00", "1.00"))
  ELEMENT: interval(position(MEDICINA*MEAN_delcd4*tardia), texture.pattern.interior(MEDICINA), shape.interior(shape.square))
  ELEMENT: interval(position(region.spread.range(MEDICINA*(LOW+HIGH)*tardia)), shape.interior(shape.ibeam))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=MEDICINA MEANCI(delcd4, 95.)[name="MEAN_delcd4" LOW="MEAN_delcd4_LOW" HIGH="MEAN_delcd4_HIGH"] MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: MEDICINA=col(source(s), name("MEDICINA"), unit.category())
  DATA: MEAN_delcd4=col(source(s), name("MEAN_delcd4"))
  DATA: LOW=col(source(s), name("MEAN_delcd4_LOW"))
  DATA: HIGH=col(source(s), name("MEAN_delcd4_HIGH"))
  GUIDE: axis(dim(1), label("ART regime"))
  GUIDE: axis(dim(2), label("Increase in CD4 count from baseline to 34 to 36 weeks of gestation"))
  GUIDE: text.footnote(label("Error Bars: 95% CI"))
  SCALE: cat(dim(1), include("1.00", "2.00", "3.00"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(MEDICINA*MEAN_delcd4))
  ELEMENT: interval(position(region.spread.range(MEDICINA*(LOW+HIGH))), shape.interior(shape.ibeam))
END GPL.

dataset activate merged1.
compute foo = lastcv <= 40.
execute.

compute tardia = idgestaz > 28.
execute.

crosstabs foo by medicina by tardia
  /FORMAT=AVALUE TABLES 
  /statistics=chisq
  /CELLS=COUNT column
  /COUNT ROUND CELL.

crosstabs antihbcg by medicina
  /FORMAT=AVALUE TABLES 
  /CELLS=column.

crosstabs antihbs_ by medicina
  /FORMAT=AVALUE TABLES
  /CELLS=column.

crosstabs aghbs_2 by medicina
  /FORMAT=AVALUE TABLES 
  /CELLS=column.

crosstabs htlv_2 by medicina
  /FORMAT=AVALUE TABLES
  /CELLS=column.

crosstabs hcv_2 by medicina
  /FORMAT=AVALUE TABLES
  /CELLS=column.

Examine cd4mae  by medicina
/statistics descriptives.
execute.

MEANS TABLES=delcd4 BY MEDICINA by tardia
  /STATISTICS ANOVA.

dataset activate merged1.
compute foo2 = lastcv <= 40.
execute.

DATASET ACTIVATE merged1 . 
COMPUTE delcopy =viralpar.
EXECUTE.

dataset activate merged1.
compute redcop = viralpar <=40.
execute.

KM tarv1 BY MEDICINA 
  /STATUS=redcop(1) 
  /PRINT TABLE MEAN 
  /TEST LOGRANK 
  /COMPARE OVERALL POOLED.

crosstabs foo2 by medicina
  /FORMAT=AVALUE TABLES 
  /CELLS=COUNT column
  /COUNT ROUND CELL.
*DATASET CLOSE merged1.
*************************************************************.
*AGE.
*******************************************************************************.
dataset activate merged1.
compute dummydt = date.dmy(09,09,1900).
execute.
compute idmae = DATE.DMY(09,09,1900).
execute.
if(NOT(nascgest=dummydt) and NOT(dtparto=dummydt)) idmae= datediff(dtparto,nascgest,"years").
execute.

missing values idmae (60 thru hi).

ONEWAY idmae BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).


compute agecat =-1.
if(idmae < 20)agecat=0.
if(idmae >=20 and idmae <=29)agecat=1.
if(idmae >29 and idmae <= 39)agecat=2.
if(idmae >39 and idmae < 60)agecat =3.
value labels agecat -1 'missing'  0 '<20'  1 '20-<29'   2 '30-<39'  3 '40-<60'.
execute.

crosstabs agecat by medicina
  /FORMAT=AVALUE TABLES 
  /CELLS=COUNT column
  /COUNT ROUND CELL.

CROSSTABS 
  /TABLES=agecat BY MEDICINA 
  /FORMAT=AVALUE TABLES 
  /STATISTICS=CHISQ 
  /CELLS=COUNT 
  /COUNT ROUND CELL.
*************************************************************.
* ANOS DE ESCOLA.
*******************************************************************************.
dataset activate merged1.
compute escolcat = -1.
if(anoescol <= 4)escolcat = 0.
if(anoescol > 4 and anoescol <=9)escolcat = 1.
if(anoescol > 9 and anoescol <=14 )escolcat = 2.
if(anoescol > 14 and anoescol < 88 )escolcat = 3.
value labels escolcat -1 'missing'   0 '<-4'  1 '5-<9' 2 '10-<14'  3 '>-15'.
execute.




crosstabs escolcat by medicina
  /FORMAT=AVALUE TABLES 
  /CELLS=COUNT column
  /COUNT ROUND CELL.

MEANS TABLES=anoescol BY MEDICINA
  /STATISTICS ANOVA.

ONEWAY anoescol BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).

*****************************************************************************************************.
* ETNIA
**************************************************************************************************************************************************.
crosstabs cor by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

*****************************************************************************************************.
* ESTADO CIVIL
**************************************************************************************************************************************************.
crosstabs estadoci by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.
**************************************************************************************************************.
* SIFILIS
**********************************************************************************************************************************************************************.

compute sif = -1.
if(tpha1=1 and vdrl1=1)sif = 1.
if(tpha1=2 or vdrl1=2)sif=0.
execute.

missing values sif (-1).
execute.

crosstabs sif by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.
execute.
**************************************************************************************************************.
* VISITAS PRENATAIS
**********************************************************************************************************************************************************************.
examine consupre by medicina
/percentiles(25,75)=empiricial.

ONEWAY consupre BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).
**************************************************************************************************************.
* CD4% MED -cel1
**********************************************************************************************************************************************************************.
examine cel1 by medicina
/PERCENTILES(25,75)=EMPIRICAL.

ONEWAY cel1 BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).
**************************************************************************************************************.
* CD4 COUNT
**********************************************************************************************************************************************************************.
compute cdcat = -1.
if(cd4mae<200)cdcat =0.
if(cd4mae >=200 and cd4mae <500)cdcat=1.
if(cd4mae>=500)cdcat=2.
value labels cd4mae 0 '<200' 1 '>=200,<500' 2 '>=500'.
missing values cdcat (-1).


crosstabs cdcat by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.
**************************************************************************************************************.
* VL LOG ENTRADA - logbasal
**********************************************************************************************************************************************************************.
examine logbasal by medicina
/PERCENTILES(25,75)=EMPIRICAL.

ONEWAY logbasal BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).
**************************************************************************************************************.
* IDGESTATIONAL ENTRADA - idgestaz
**********************************************************************************************************************************************************************.
examine idgestaz by medicina
/PERCENTILES(25,75)=EMPIRICAL.

ONEWAY idgestaz BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).

***********************************************************.
* Tempo de exposicção a TARV por medicina.
*******************************************************************************************.
examine tarv1 by medicina
/PERCENTILES(25,75)=EMPIRICAL.

ONEWAY tarv1 BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).

****************************************************************************************.
* Por centagem das pacientes com supressão ao parto
****************************************************************************************************.
crosstabs foo2 by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

*******************************************************************************************************************************************.
* CV near delivery
*******************************************************************************************************************************************..
missing values logmater (88,99).
examine logmater by medicina
/PERCENTILES(25,75)=EMPIRICAL.

ONEWAY logmater BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).



*******************************************************************************************************************************************.
* DELTA CD4.
*******************************************************************************************************************************************..
compute delcd4p = cel2-cel1.

ONEWAY delcd4p BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).

examine delcd4p by medicina
/PERCENTILES(25,75)=EMPIRICAL.


*******************************************************************************************************************************************.
* RATE OF STILLBIRTH .
******************************************************************************************************************************************.
crosstabs desfecho by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

*******************************************************************************************************************************************.
* VIA DE PARTO CESAREO.
******************************************************************************************************************************************.
crosstabs tiparto by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

*******************************************************************************************************************************************.
* Indicação DE PARTO CESAREO.
******************************************************************************************************************************************.
crosstabs indces1 by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

*******************************************************************************************************************************************.
*CONCL TV
******************************************************************************************************************************************.
crosstabs CONCLTV by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.



*******************************************************************************************************************************************.
*ID GEST AO NASCER
******************************************************************************************************************.
compute prem = idgest < 37.
crosstabs prem by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

*******************************************************************************************************************************************.
* PEQUENO PARA IDADE GESTACIONAL
******************************************************************************************************************.
crosstabs classcrecri by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

*******************************************************************************************************************************************.
* PESO
******************************************************************************************************************.
dataset activate merged1.

compute peso2 = (pesocri*(desfecho=1)).
missing values peso2 (0).

examine peso2  by medicina
/PERCENTILES(25,75)=EMPIRICAL.


ONEWAY peso2 BY MEDICINA 
  /MISSING ANALYSIS 
  /POSTHOC=TUKEY LSD BONFERRONI SIDAK ALPHA(0.05).

*******************************************************************************************************************************************.
*BAIXO PESO
******************************************************************************************************************.
compute bp = (peso2 < 2500).
crosstabs bp by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.


compute drop = 0.
if (delcv2 <1) drop = 1.
if (delcv2 >= 1 and delcv2 <2) drop = 2.
if (delcv2 >= 2 ) drop = 3.

crosstabs tarv2 by drop by medicina
/FORMAT=AVALUE TABLES
/CELLS=COUNT column
/STATISTICS CHISQ
/COUNT ROUND CELL.

SET DECIMAL = COMMA.