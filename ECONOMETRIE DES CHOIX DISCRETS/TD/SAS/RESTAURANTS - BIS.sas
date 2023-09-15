PROC IMPORT OUT= WORK.restaurants                                                                                                           
            DATAFILE= "G:\SERVEUR ECONOMETRIE 2017-2018\
MASTER 2 ING ECO\SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\
DATA\restaurants.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN;

proc print data=restaurants(obs=100);
title 'dATA restaurants';
run;

/* Nested logit */

proc mdc data=restaurants maxit=100; id id;
   model CHOIX =COUT distance EVALUATION /type=nlogit
           choice=(atype 1 2 3,altresto 1 2 3 4 5 6 7);
   utility u(1, ) =  COUT distance EVALUATION;
   nest level(1) = (1 2 @ 1, 3 4 5 @ 2, 6 7 @ 3),
        level(2) = (1 2 3 @ 1);
title 'nested logit';
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

/* probit multinomial sans nested sur les 7 alternatives */

data new;					
set restaurants;
id=_n_;               * Création de id personne;
label id='id personne';
run;

/* Création de 7 lignes d'observations par individu */
data new2;
set new;
choice = (altresto=1); nocoll = 1; cst2 = 0; cst3 = 0; cst4 =0; cst5=0; cst6=0; cst7=0;output;
choice = (altresto=2); nocoll = 0; cst2 = 1; cst3 = 0; cst4 =0; cst5=0; cst6=0; cst7=0;output;
choice = (altresto=3); nocoll = 0; cst2 = 0; cst3 = 1; cst4 =0; cst5=0; cst6=0; cst7=0;output;
choice = (altresto=4); nocoll = 0; cst2 = 0; cst3 = 0; cst4 =1; cst5=0; cst6=0; cst7=0;output;
choice = (altresto=5); nocoll = 0; cst2 = 0; cst3 = 0; cst4 =0; cst5=1; cst6=0; cst7=0;output;
choice = (altresto=6); nocoll = 0; cst2 = 0; cst3 = 0; cst4 =0; cst5=0; cst6=1; cst7=0;output;
choice = (altresto=7); nocoll = 0; cst2 = 0; cst3 = 0; cst4 =0; cst5=0; cst6=0; cst7=1;output;
run;

proc print data=new2(obs=100);
var id choice nocoll cst2 cst3 cst4 cst5 cst6 cst7 distance;
title 'Données empilées (20 obs)';
run;

/* Création d'une interaction entre la distance et le choix */
data new3;
set new2;
b2=cst2*distance;
b3=cst3*distance;
b4=cst4*distance;
b5=cst5*distance;
b6=cst6*distance;
b7=cst7*distance;
run;


/* ESTIMATION DU logit multinomial */
proc mdc data=new3;
model choice = cst2 b2 cst3 b3 cst4 b4 cst5 b5 cst6 b6 cst7 b7/ 
type=clogit nchoice=7;
id id;
output out=nelsout p=p;
title 'ESTIMATION DU logit multinomial restaurant 7 choix';
run;

/* Ajout d'un autre identifiant (alt)*/
data nelsout2;
set nelsout;
alt = 1 + mod(_n_-1,7); * a mod n = a-[(reste de (a/n))*n] ;
run;

proc print data=nelsout2(obs=10); 
var id alt choice nocoll cst2 cst3 cst4 cst5 cst6 cst7 distance p;
title 'Probabilités estimées';
run;

/* Séparation des probabilités estimées pour chaque alternative */
data alt1; set nelsout2; if alt=1; p1 = p; keep p1;
data alt2; set nelsout2; if alt=2; p2 = p; keep p2;
data alt3; set nelsout2; if alt=3; p3 = p; keep p3;
data alt4; set nelsout2; if alt=4; p4 = p; keep p4;
data alt5; set nelsout2; if alt=5; p5 = p; keep p5;
data alt6; set nelsout2; if alt=6; p6 = p; keep p6;
data alt7; set nelsout2; if alt=7; p7 = p; keep p7;

data alt;
merge alt1-alt7;
run;
proc print data=alt(obs=1);
title 'Probabilités estimées pour chaque alternative';
run;
proc means data=alt;
run;


/* Calcul des effets marginaux moyens */
data marginals;
set alt;
b2 = -0.005044;
b3 = 1.3343;
b4 = 1.3971;
b5 = 1.3853;
b6 = 2.1866;
b7 = 2.1315;
EM1 = p1*(0-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM2 = p2*(b2-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM3 = p3*(b3-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM4 = p4*(b4-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM5 = p5*(b5-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM6 = p6*(b6-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM7 = p7*(b7-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);

keep p1-p7 em1-em7;
run;
proc means data=marginals;
title 'Effets marginaux moyens pour logit multinomial';
run;

/* obtain marginal effect of niveau at median DISTANCE */
PROC univariate data=restaurants;
var distance;
run;

data mef;
*x = 4.887317;  * médiane de la DISTANCE;	
*x = 8.712754;  * c95 de la DISTANCE;
x = 1.976733;  * c5 de la DISTANCE;
c2 = 0.0153;						
c3 = -5.2372; 
c4 = -5.5538;
c5 = -5.4937;
c6 = -10.2859;
c7 = -9.9034;
b2 = -0.005044;
b3 = 1.3343;
b4 = 1.3971;
b5 = 1.3853;
b6 = 2.1866;
b7 = 2.1315;						

/* Probabilités : dénominateur et valeurs */
den = 1 + exp(c2+b2*x) + exp(c3+b3*x)+ exp(c4+b4*x)+ exp(c5+b5*x)+
exp(c6+b6*x)+ exp(c7+b7*x);
p1 = 1/den;
p2 = exp(c2+b2*x)/den;
p3 = exp(c3+b3*x)/den;
p4 = exp(c4+b4*x)/den;
p5 = exp(c5+b5*x)/den;
p6 = exp(c6+b6*x)/den;
p7 = exp(c7+b7*x)/den;


/* Effets marginaux par probabilités */
EM1 = p1*(0-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM2 = p2*(b2-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM3 = p3*(b3-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM4 = p4*(b4-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM5 = p5*(b5-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM6 = p6*(b6-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
EM7 = p7*(b7-b2*p2-b3*p3-b4*p4-b5*p5-b6*p6-b7*p7);
run;
proc print data=mef;
var p1-p7 em1-em7;
title 'Effets marginaux (au point 5ième décile 1.97)';
*title 'Effets marginaux (au point médian 4.88)';
*title 'Effets marginaux (au point 95ième décile 8.71)';

run;








