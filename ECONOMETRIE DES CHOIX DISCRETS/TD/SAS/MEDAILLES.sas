PROC IMPORT OUT= WORK.MEDAILLES                                                                                                           
DATAFILE= "D:\SERVEUR MASTER IDEE 2022-2023\
MASTER 1 IDEE\ECONOMETRIE DES CHOIX DISCRETS\DATA\medailles.xls"             DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN;

/* Statistiques diverses : base de données brute */

proc contents data=medailles ;
title 'médailles olympiques';
run;
proc print data=medailles (obs=50);
run;
proc sort data=medailles;
by annees;
run;
/*proc univariate data=medailles; * recherche Q2 et Q3 par année ;
by annees;
var pop pib;
title 'Statistiques';
run;*/
proc sort data=medailles;
by pays;
run;
proc univariate data=medailles; * recherche moyenne par pays toutes années;
by pays;
var pop pib;
OUTPUT OUT=moyenne mean=mpop mpib;
run;
proc print data=moyenne;
run;

/* Transformation des données en ln */

data medailles2;
set medailles;
lnpop = log(pop);
lnpib = log(pib);
label lnpop='log(pop)' lnpib='log(pib)';
if annees=88;           * on ne travaille que sur 1988 ;
if totalmedaille ne .;  * 'ne' : pas égal à ;
if pop ne .;
keep totalmedaille lnpop lnpib pop pib pays;
run;
proc contents data=medailles2 ;
title 'Fichier médailles transformées';
run;
proc print data=medailles2 (obs=50);
run;

proc univariate data=medailles2;
title 'Statistiques';
run;
proc sort data=medailles2;
by pays;
run;
proc univariate data=medailles2; * recherche moyenne par pays pour 1988;
by pays;
var pop pib;
OUTPUT OUT=moyenne mean=mpop mpib;
run;
proc print data=moyenne; /* pour tous les pays */
run;

proc print data=moyenne;
where PAYS='United Kingdom';
run;

/* Ajout de données */
data more;
input totalmedaille pop pib;
lnpop = log(pop);
lnpib = log(pib);
keep totalmedaille lnpop lnpib;
datalines; 
. 5.72e07 1.01e12
;/* données trouvées par UNIVARIATE 
1 mediane pop    & mediane pib . 5921270 5.51E09
2 Q3 pop         & mediane pib. 1.75e07 5.51e09
3 mediane pop    & Q3 pib. 5921270 5.18E10
4 pop GB         & pib GB ; */

data new88;
set medailles2 more;
run;

/* Estimation : Modèle de comptage (Poisson) */

proc countreg data=new88;
model totalmedaille = lnpop lnpib / dist=poisson;
output out=out88 xbeta=xbeta pred=phat prob=prob;
title 'poisson regression';
run;

proc print data=out88; * 1 prévision ;
var xbeta phat prob;
*where totalmedaille = .;   
title 'Prévisions modèle de Poisson';
run;

/* Calcul de la probabilité  + Calcul factorielle N */

Data calcul; /* pour la GB */
a=24;
factor = fact(a);
probanew=(26.2131**a*exp(-26.2131))/factor;
run;
proc print data=calcul;
run;

Data calcul; /* pour la russie */
a=142;
factor = fact(a);
probanew=(39.3968**a*exp(-39.3968))/factor;
run;
proc print data=calcul;
run;

Data calcul; /* pour le rawnda */
a=0;
factor = fact(a);
probanew=(.5023**a*exp(-.5023))/factor;
run;
proc print data=calcul;
run;




proc sort data=medailles2;
by totalmedaille;
run;
proc print data=medailles2;
where PAYS='United Kingdom';
run;





