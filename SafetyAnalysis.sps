*APAGUE janela de resultados.
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
recode viralmat (0= 40).
recode viralpre (0 =40).
recode viralpar (0 =40).
execute.
*valor da últimate carga viral.
compute lastcv = 0.
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
SELECT IF (dtarv1 >= sdate).
EXECUTE.

ECHO "Avaliadas para elegibilidade de 08/2014 a 10/2018:".

DATASET ACTIVATE APOSCOMECO.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.

dataset activate aposcomeco.
compute repor = (DateDiff(dtretira,dtarv1,"weeks")>= 2)
and
NOT(arv1=0)
and
(
(DateDiff(dtlastcv,dtretira,"days")>=0)
and (DateDiff(dtlastcv,foo1,"days")>=0)
).
execute.
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

ECHO "ENGRAVIDARAM COM USO DE ARV:".

DATASET ACTIVATE NAONAIF.
DESCRIPTIVES VARIABLES=ID
  /STATISTICS=MEAN.

DATASET CLOSE NAONAIF.

*Caixa 3a:
**Escolha as pacientes de RAL apos a data do começo da pesquisa.
DATASET ACTIVATE APOSCOMECO.
DATASET COPY RAL.
DATASET ACTIVATE RAL.
FILTER OFF.
USE ALL.
SELECT IF (( (arv1 = 84) OR (arv1 = 89) OR (arv1 = 81)  ) AND (dtarv1 >= sdate) AND NOT(consupre=99) and (consupre >=3) and (freqentr=1)    
and (tarv1 >=0) and (tarv1 <45) and (dtlastcv > foo1) or ((repor=1) and ( (arv2 = 84) OR (arv2 = 89) OR (arv2 = 81)  ))).
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
SELECT IF ( ( (arv1 = 47) OR (arv1 = 58) or(arv1=50)) AND (dtarv1 >= sdate) AND NOT(consupre=99) AND  (consupre >=3)  and   (freqentr=1) and (tarv1 >=0) and (tarv1 <45) and (dtlastcv > foo1) or
 (repor=1 and ((arv2 = 47) OR (arv2 = 58) or(arv2=50)))).
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
SELECT IF (( (arv1 = 29) OR (arv1 =34)  OR (arv1 = 43) OR (arv1 = 38) or(arv1 = 59) or (arv1=60) or (arv1=90)  ) AND (dtarv1 >= sdate) AND NOT(consupre=99) 
and (consupre >=3) and (freqentr=1) and  (tarv1 >=2) and (tarv1 <45) and (dtlastcv > foo1) or ((repor=1) and ( (arv2 = 29) OR (arv2 =34)  OR (arv2 = 43) OR (arv2 = 38) or(arv2 = 59) or (arv2=60) or (arv2=90)  )) ).
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

**************************************************************************************************************************************.
* TAXA DE EVENTOS ADVERSOS POR BRACO
**************************************************************************************************************************************.
*monte banco de  RAL, EFV e LPV.
dataset activate RAL.
*select if (NOT(gemelar=2) and NOT(gemelar=3)).
compute medi = 1.
execute.

dataset activate EFV.
*select if(NOT(gemelar=2) and NOT(gemelar=3)).
compute medi=2.
execute.

dataset activate LOP.
*select if(NOT(gemelar=2) and NOT(gemelar=3)).
compute medi=3.
execute.

add files file RAL / file EFV / file LOP.
SAVE OUTFILE="C:/Users/ArtPCs/Documents/prsnnl090320b.sav".
Execute.
dataset name testtoxi.

dataset activate testtoxi.
compute toxic = ( (motivosu=2) or (motivosu=3) ).
compute tardia = idgestaz > 28.
execute.

crosstabs
/tables= toxic by medi by tardia
 /statistics=chisq
/FORMAT=AVALUE TABLES 
  /CELLS=COUNT COLUMN
  /COUNT ROUND CELL.


crosstabs
/tables= toxiarv by medi
 /statistics=chisq
/FORMAT=AVALUE TABLES 
  /CELLS=COUNT COLUMN
  /COUNT ROUND CELL.

crosstabs
/tables= toxiarv2 by medi 
 /statistics=chisq
/FORMAT=AVALUE TABLES 
  /CELLS=COUNT COLUMN
  /COUNT ROUND CELL.

dataset activate testtoxi.
dataset copy porqtoxi.
dataset activate porqtoxi.
select if toxic=1.
execute.

dataset activate porqtoxi.
crosstabs
/tables=toxiarv by medi
/statistics=chisq
/format=avalue tables
/cells=count column
/count round cell.

crosstabs
/tables=motivosu by medi
/statistics=chisq
/format=avalue tables
/cells=count column
/count round cell.

dataset activate porqtoxi.
dataset copy labtox.
select if motivosu = 2.
execute.
dataset activate labtox.
crosstabs 
/tables=toxiarv by medi
/statistics=chisq
/format=avalue tables
/cells = count column
/count round cell.

*dataset close labtox.

*dataset close porqtoxi.

*dataset close testtoxi.


