PROC IMPORT OUT= WORK.EDUCATION                                                                                                           
            DATAFILE= "M:\SERVEUR ECONOMETRIE 2021-2022\
MASTER 2 ING ECO\SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\DATA\EDUCATION.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN; 

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
PROC UNIVARIATE data=new;
var niveau;
run;
proc print data=education(obs=5);
title '5 observations';  * 5 obs sur 1000;
run;

/* Création de 3 lignes d'observations par individu */
data new2;
set new;
choice = (Y=1); nocoll = 1; cst2 = 0; cst3 = 0; output;
choice = (Y=2); nocoll = 0; cst2 = 1; cst3 = 0; output;
choice = (Y=3); nocoll = 0; cst2 = 0; cst3 = 1; output;
run;
proc print data=new2(obs=12);
var id choice nocoll cst2 cst3 niveau;
title 'Données empilées (12 obs)';
run;

/* Création d'une interaction entre le niveau et le choix */
data new3;
set new2;
b2=cst2*niveau;  /* CHOIX 2 */
b3=cst3*niveau;  /* CHOIX 3 */
run;
proc print data=new3(obs=24);
title 'interaction (12 obs)';
run;



/* ESTIMATION DU logit multinomial */
proc mdc data=new3;
model choice = cst2 b2 cst3 b3/ type=clogit nchoice=3;
id id;
output out=nelsout p=p;
title 'ESTIMATION DU logit multinomial education choix';
run;

/* Ajout d'un autre identifiant (alt)*/
data nelsout2;
set nelsout;
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

proc print data=nelsout2(obs=12); 
var id alt choice nocoll cst2 cst3 niveau p;
title 'Probabilités estimées';
run;

/* Séparation des probabilités estimées pour chaque alternative */
data alt1; set nelsout2; if alt=1; p1 = p; keep p1;
data alt2; set nelsout2; if alt=2; p2 = p; keep p2;
data alt3; set nelsout2; if alt=3; p3 = p; keep p3;
data alt;
merge alt1-alt3;
run;
proc print data=alt(obs=1);
title 'Probabilités estimées pour chaque alternative';
run;

/* Calcul des effets marginaux moyens */
data marginals;
set alt;
b2 = -0.3088;
b3 = -0.7062;
EM1 = p1*(0-b2*p2-b3*p3);
EM2 = p2*(b2-b2*p2-b3*p3);
EM3 = p3*(b3-b2*p2-b3*p3);
keep p1-p3 em1-em3;
run;
proc means data=marginals;
title 'Effets marginaux moyens pour logit multinomial';
run;

/* Calcul de l'effet marginal du NIVEAU au point MEDIAN */
data mef;
x = 10.105;	/* x=6.64    2.635*/					
c2 = 2.5064;						
c3 = 5.7699; 						
b2 = -0.3088; 						
b3 = -0.7062; 						

/* Probabilités : dénominateur et valeurs */
den = 1 + exp(c2+b2*x) + exp(c3+b3*x);
p1 = 1/den;
p2 = exp(c2+b2*x)/den;
p3 = exp(c3+b3*x)/den;

/* Effets marginaux par probabilités */
em1 = p1*(0-b2*p2-b3*p3);
em2 = p2*(b2-b2*p2-b3*p3);
em3 = p3*(b3-b2*p2-b3*p3);
run;
proc print data=mef;
var p1-p3 em1-em3;
title 'Effets marginaux et probabilités(au point 5ième décile 2.635)';
*title 'Effets marginaux et probabilités (au point médian 6.64)';
run;



























