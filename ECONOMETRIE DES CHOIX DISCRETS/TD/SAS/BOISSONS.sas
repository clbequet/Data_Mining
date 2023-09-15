PROC IMPORT OUT= WORK.BOISSONS                                                                                                           
            DATAFILE= "m:\SERVEUR ECONOMETRIE 2021-2022\
MASTER 2 ING ECO\SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\
DATA\BOISSONS.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN;
/* LOGIT MULTINOMIAL */

/* logit Conditionnel de McFadden */
proc contents data=boissons;
run;

/* Statistiques */
proc means data=boissons;
title 'boissons statistiques';
run;

/* Observations additionnelles */
/* Ordre est : pepsi, sevenup, coca */
data more; /* Ensuite changer 1.00 par 1.10 pour pepsi au 9999*/
input id choix prix ; /* choix inconnu : . */
datalines;
9998 . 1.00 
9998 . 1.25 
9998 . 1.10 

9999 . 1.00 
9999 . 1.25 
9999 . 1.10 
run;



/* Ajout nouvelles observations aux data */
data boissons;
set boissons more;
run;

/* Creation d'indicateurs */
/* NB : 1 pour pepsi, 2 pour sevenup, 3 pour coca */
data boissons;
set boissons;
alt = 1 + mod(_n_-1,3); * a mod n = a-[(reste de (a/n))*n] ;
pepsi = (alt=1);
sevenup = (alt=2);
coca = (alt=3);
run;

proc print data=boissons(obs=12);
title 'boissons observations';
run;
proc contents data=boissons;
run;

/* Estimation logit conditionnel */

proc mdc data=boissons outest=est;
model choix = prix pepsi sevenup / type=clogit nchoice=3;
id id;
output out=boissonsout p=phat;
title 'boissons conditionnel logit';
run;
proc print data=est;
run;


/* Probabilités estimées des observations additionnelles*/
proc print data=boissonsout;
where id = 9999;
var id phat prix alt;
title 'Probabilités estimées';
run;
proc sort data=boissonsout;
by id;
run;

/* Effets  marginaux*/
data marginals;
array predict(3) phat1-phat3;
do i=1 to 3 until(last.id);
	set boissonsout;
	by id;
	predict(i)=phat;
end;
if id < 9999 then delete;
beta2 = -2.2963684;
d11 = phat1*(1-phat1)*beta2;
d22 = phat2*(1-phat2)*beta2;
d33 = phat3*(1-phat3)*beta2;
d12 = -phat1*phat2*beta2;
d13 = -phat1*phat3*beta2;
d23 = -phat2*phat3*beta2;
keep id phat1-phat3 d11 d22 d33 d23 d12 d13 d23;
run;

proc print data=marginals(obs=1);
var id d11 d22 d33;
title 'Effets marginaux propres';
run;

proc print data=marginals(obs=1);
var id d12 d13 d23;
title 'Effets marginaux croisés';
run;

*proc means data=marginals;
*var phat1-phat3 d11 d22 d33 d23 d12 d13 d23;
*title 'Effets marginaux moyens';
*run;

/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
/* Test de Hausman pour vérifier l'hypothèse IIA     */
/* Etape 1 : Estimation du modèle complet : pepsi, sevenup, coca */

proc mdc data=boissons outest=boissonsparm covout;
model choix = prix afficher promo pepsi sevenup/ type=clogit nchoice=3;
id id;
title 'conditional logit estimates';
run;

proc print data=boissonsparm;
title 'boissons outest data';
run;

/* Création de 3 variables de choix */
data choixs;
array choixs(3) choix1-choix3;
do i=1 to 3 until(last.id);
	set boissons;
	by id;
	choixs(i)=choix;
end;
keep id choix1-choix3;
run;
proc print data=choixs(obs=100);
title 'boissons observations';
run;

/* Sous-ensemble avec coca seulement */
data cocaid;
set choixs;
if choix3=1;
run;
proc print data=cocaid(obs=100);
title 'boissons observations';
run;

/* fusionner avec les données sur les boissons et éliminer le coca */
data nococa;
merge boissons cocaid;
by id;
if choix3=1 then delete;
drop choix1-choix3 coca;
if alt < 3;
run;

/* Etape 2 : Estimation du modèle sans coca */
proc mdc data=nococa outest=nococaparm covout;
model choix = prix afficher promo sevenup/ type=clogit nchoice=2;
id id;
title 'Estimation logit conditionnel sans coca';
run;

/* Etape 3 : calcul du test d'Hausman */
proc iml;
title;
start hausman;

* Estimations & cov du modèle entier;
use boissonsparm;
read all into boissons var{prix afficher promo};
bf = boissons[1,];
covf = boissons[2:4,];

* Estimations & cov du modèle restreint;
use nococaparm;
read all into nococa var{prix afficher promo};
bs = nococa[1,];
covs = nococa[2:4,];

* test statistique, valeur critique & p-value;
H = (bs-bf)*inv(covs-covf)*(bs-bf)`;
chi95 = cinv(.95,3);
pval = 1 - probchi(H,3);
print,, "Hausman test IIA",, H chi95 pval;

finish;
run hausman;
quit;
