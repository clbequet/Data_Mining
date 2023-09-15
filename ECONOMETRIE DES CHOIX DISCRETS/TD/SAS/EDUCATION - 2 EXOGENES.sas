PROC IMPORT OUT= WORK.EDUCATION                                                                                                           
            DATAFILE= "G:\SERVEUR ECONOMETRIE 2017-2018\
MASTER 2 ING ECO\SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\
DATA\EDUCATION.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN; 
proc means data=education;
run;



/* LOGIT MULTINOMIAL */


/* lecture du fichier data (education.xls)*/
data new;					
set education;
id=_n_;               * Création de id personne;
label id='id personne';
run;

/* Contenu-statistiques-données */
proc contents data=new;
title 'Contenu du fichier de données NEW';
run;
proc means data=new;
title 'statistiques de base';
run;
proc print data=education(obs=10);
title '5 observations';  * 10 obs sur 1000;
run;

/* Création de 3 lignes d'observations par individu */
data new2;
set new;
choice = (Y=1); nocoll = 1; cst2 = 0; cst3 = 0; output;
choice = (Y=2); nocoll = 0; cst2 = 1; cst3 = 0; output;
choice = (Y=3); nocoll = 0; cst2 = 0; cst3 = 1; output;
run;
proc print data=new2(obs=10);
var id choice nocoll cst2 cst3 niveau revenu;
title 'Données empilées (10 obs)';
run;

/* Création d'une interaction entre le niveau et le choix */
data new3;
set new2;
b2=cst2*niveau;
b3=cst3*niveau;
b4=cst2*revenu;
b5=cst3*revenu;

run;
proc print data=new3(obs=10);
var id choice nocoll cst2 cst3 niveau revenu b2 b3 b4 b5;
title 'Données empilées (10 obs)';
run;


/* ESTIMATION DU logit multinomial MDC : multinomial discrete choice*/
proc mdc data=new3;
model choice = cst2 b2 cst3 b3 b4 b5/ type=clogit nchoice=3;
id id;
output out=mdcout p=p;
title 'ESTIMATION DU logit multinomial education choix';
run;

/* Ajout d'un autre identifiant (alt)*/
data mdcout2;
set mdcout;
alt = 1 + mod(_n_-1,3); * a mod n = a-[(reste de (a/n))*n] ;
run;
/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* Exemples de calculs avec la fonction MOD */
data modulo;
a1=1+mod(0,3);
a2=1+mod(1,3);
a3=1+mod(2,3);
a4=1+mod(3,3);
a5=1+mod(4,3);
a6=1+mod(5,3);
run;
proc print data=modulo;
run;
/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */

proc print data=mdcout2(obs=10); 
var id alt choice nocoll cst2 cst3 niveau p;
title 'Probabilités estimées';
run;

/* Séparation des probabilités estimées pour chaque alternative */
data alt1; set mdcout2; if alt=1; p1 = p; keep p1;
data alt2; set mdcout2; if alt=2; p2 = p; keep p2;
data alt3; set mdcout2; if alt=3; p3 = p; keep p3;
data alt;
merge alt1-alt3;
run;
proc print data=alt(obs=3);
title 'Probabilités estimées pour chaque alternative';
run;

/* Calcul des effets marginaux moyens */
data marginals;
set alt;
b2 = -0.2962;
b3 = -0.6795;
b4 =  0.0109;
b5 =  0.0189;
EM1 = p1*(0-b2*p2-b3*p3);
EM2 = p2*(b2-b2*p2-b3*p3);
EM3 = p3*(b3-b2*p2-b3*p3);
keep p1-p3 em1-em3;
run;
proc means data=marginals;
title 'Effets marginaux moyens pour logit multinomial';
run;

/* Calculs des effets marginaux à certains points */
data mef;
x = 2.635;	/* x=6.64*/		* x pour NIVEAU;
xx = 51.39;                 * xx pour REVENU;	
c2 = 1.965;						
c3 = 4.7244; 					
b2 = -0.2962; 						
b3 = -0.6795; 
b4 =0.0109;
b5 =0.0189;

/* Probabilités : dénominateur et valeurs */
den = 1 + exp(c2+b2*x+b4*xx) + exp(c3+b3*x+b5*xx);
p1 = 1/den;
p2 = exp(c2+b2*x+b4*xx)/den;
p3 = exp(c3+b3*x+b5*xx)/den;

/* Effets marginaux par probabilités */
em1 = p1*(0-b2*p2-b3*p3);
em2 = p2*(b2-b2*p2-b3*p3);
em3 = p3*(b3-b2*p2-b3*p3);
run;
proc print data=mef;
var p1-p3 em1-em3;
title 'Effets marginaux (au point 5ième décile 2.635)';
*title 'Effets marginaux (au point médian 6.64)';
run;



























