PROC IMPORT OUT= WORK.restaurants                                                                                                           
            DATAFILE= "W:\Droit\Public\Depots_Ens\Philippe_Compaire\
SERVEUR ECONOMETRIE 2020-2021\
MASTER 2 ING ECO\SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\DATA\restaurants.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN;

proc print data=restaurants(obs=100);
title 'dATA restaurants';
run;
proc univariate data=restaurants; * recherche moyenne ;
var COUT distance EVALUATION revenu;
OUTPUT OUT=moyenne mean=mcout mdistance mEVALUATION mrevenu;
run;

PROC PRINT data=moyenne;
RUN;


/* PARTIE 1 : ESTIMATIONS */
/* Nested logit MDC multivarie discrete choice*/

/*Version 1 : même choix de variables exogènes pour le niveau 1 */

proc mdc data=restaurants maxit=100; id id;
   model CHOIX =COUT distance EVALUATION revenu enfants/type=nlogit
           choice=(atype 1 2 3,altresto 1 2 3 4 5 6 7);
   utility u(1, ) =  COUT distance EVALUATION revenu enfants;
   nest level(1) = (1 2 @ 1, 3 4 5 @ 2, 6 7 @ 3),
        level(2) = (1 2 3 @ 1);
title 'nested logit version 1 : même choix de variables exogènes pour le niveau 1';
output out=predicted p=probas ;
run;


proc print data=predicted(obs=100);
title 'Prévisions nested modèle';
run;

*-- Tri des données par alternatives (7 alresto);
proc sort data=predicted;
by altresto;
run;

* Calcul des probabilités moyennes pour chaque alternative;
proc means data=predicted nonobs mean;
var probas;
class altresto;
run;

*--Tri des données par type de restaurants (3 atype);
proc sort data=predicted;
by atype;
run;
* Calcul des probabilités moyennes;
proc means data=predicted nonobs mean;
var probas;
class atype;
run;

/*Version 2 : différents choix de variables exogènes pour le niveau 1 et le niveau 2 */

proc mdc data=restaurants maxit=100 type=nlogit outest=ESTIM;
      model choix = COUT distance EVALUATION revenu enfants/
               choice=(altresto 1 2 3 4 5 6 7);
      id id;
     utility u(1,6 7   @3) =  distance ,
             u(1,3 4 5 @2) = COUT  distance ,
			 u(1,1 2   @1) = revenu ,
             u(2, 1 2 3) = COUT distance ;        
  nest  level(1) = (1 2 @ 1, 3 4 5 @ 2, 6 7 @ 3),
        level(2) = (1 2 3 @ 1);
title 'nested logit version 2 différents choix de variables exogènes pour le niveau 1 et le niveau 2';
output out=predicted p=probas ;
run;

proc print data=predicted(obs=100);
title 'Prévisions nested modèle';
run;

*-- Tri des données par alternatives (7 alresto);
proc sort data=predicted;
by altresto;
run;

* Calcul des probabilités moyennes pour chaque alternative;
proc means data=predicted nonobs mean;
var probas;
class altresto;
run;

*--Tri des données par type de restaurants (3 atype);
proc sort data=predicted;
by atype;
run;
* Calcul des probabilités moyennes;
proc means data=predicted nonobs mean;
var probas;
class atype;
run;

/*Version 3 : IV identiques pour 2-3 niveau 2 */

proc mdc data=restaurants maxit=100; id id;
   model CHOIX =COUT distance EVALUATION revenu enfants/type=nlogit spscale
           choice=(atype 1 2 3,altresto 1 2 3 4 5 6 7);
   utility u(1, ) =  COUT distance EVALUATION revenu enfants;
   nest level(1) = (1 2 @ 1, 3 4 5 @ 2, 6 7 @ 3),
        level(2) = (1 2 3 @ 1);
title 'nested logit version 3 IV identiques pour 2-3 niveau 2';
output out=predicted p=probas ;
run;
*-- Tri des données par alternatives (7 alresto);
proc sort data=predicted;
by altresto;
run;

* Calcul des probabilités moyennes pour chaque alternative;
proc means data=predicted nonobs mean;
var probas;
class altresto;
run;

*--Tri des données par type de restaurants (3 atype);
proc sort data=predicted;
by atype;
run;
* Calcul des probabilités moyennes;
proc means data=predicted nonobs mean;
var probas;
class atype;
run;

/*Version 4 : IV identiques pour 1-2-3 niveau 2 */

proc mdc data=restaurants maxit=100; id id;
   model CHOIX =COUT distance EVALUATION revenu enfants/type=nlogit samescale
           choice=(atype 1 2 3,altresto 1 2 3 4 5 6 7);
   utility u(1, ) =  COUT distance EVALUATION revenu enfants;
   nest level(1) = (1 2 @ 1, 3 4 5 @ 2, 6 7 @ 3),
        level(2) = (1 2 3 @ 1);
title 'nested logit version 4 IV identiques pour 1-2-3 niveau 2';
output out=predicted p=probas ;
run;

*-- Tri des données par alternatives (7 alresto);
proc sort data=predicted;
by altresto;
run;

* Calcul des probabilités moyennes pour chaque alternative;
proc means data=predicted nonobs mean;
var probas;
class altresto;
run;

*--Tri des données par type de restaurants (3 atype);
proc sort data=predicted;
by atype;
run;
* Calcul des probabilités moyennes;
proc means data=predicted nonobs mean;
var probas;
class atype;
run;



  
   





















* Calcul des probabilités moyennes par type de resto;
proc means data=predicted nonobs mean;
var probas;
class atype;
where atype=1;
output out=mean1 mean=moyenne1;
run;
data new1;
set mean1;
moyenneatype1 =moyenne1*2;
run;


* Calcul des probabilités moyennes par type de resto;
proc means data=predicted nonobs mean;
var probas;
class atype;
where atype=2;
output out=mean2 mean=moyenne2;
run;
data new2;
set mean2;
moyenneatype2 =moyenne2*3;
run;


* Calcul des probabilités moyennes par type de resto;
proc means data=predicted nonobs mean;
var probas;
class atype;
where atype=3;
output out=mean3 mean=moyenne3;
run;
data new3;
set mean3;
moyenneatype3 =moyenne3*2;
run;
data probaall;
merge new1 new2 new3;
drop moyenne1 moyenne2 moyenne3 _freq_ _type_ atype;
if _type_=0 then delete;
run;

proc print data=probaall;
title 'probabilités des atype ajustées';
run;




















