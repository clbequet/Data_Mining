PROC IMPORT OUT= WORK.transport                                                                                                           
            DATAFILE= "M:\SERVEUR ECONOMETRIE 2021-2022\MASTER 2 ING ECO\
SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\DATA\TRANSPORT.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN; 

/* MODELES A CHOIX BINAIRE */
/***************************/

proc contents;					
title 'Contenu du fichier TRANSPORT.XLS';
run;
proc print data=transport;
run;
proc means; 						
title 'Statistiques de base';
run;
/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* S1 : Le modèle de probabilité linéaire i.e. OLS  */

proc reg data=transport;
model y=x/clb hcc hccmethod=1;	* utilisation robuste se; 	
title 'OLS avec robuste se';
output out=olsout p=probaols; 				
run;

proc print data=olsout; 			
title 'Prévisions avec le modèle de probabilité linéaire (OLS)';
run;
/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* S2: le modèle  PROBIT  */

proc qlim data=transport outest=estim method=QUANEW;			
model y =x/discrete; 			    * discrete pour probit;
output out=probitout xbeta marginal;
title 'Estimations Probit';
run;

/*METHOD=CONGRA DBLDOG NMSIMP NEWRAP NRRIDG QUANEW TRUREG*/

proc print data=probitout (obs=21); 
title 'Sortie du probit';
run;

/* Effet marginal moyen EMM*/
proc means data=probitout;
var meff_p1_x meff_p2_x;
title 'Effet marginal moyen pour PROBIT';
run; 

/*  Calculs des Valeurs prédites  */
data transport2;
set probitout;
pnormale = probnorm(xbeta_y);  * calcul des probabilités loi normale;
phat = (pnormale >= .5); 		 * phat = 1 si p >= .5;
run;
proc print data=transport2;
run;


/* Graphique pour comparer prev par OLS et prev par PROBIT */
* Pour ne garder que certaines variables;

DATA NEW22;
SET olsout(keep=probaols);
RUN;
DATA NEW23;
SET transport2(keep=pnormale);
RUN;

DATA NEW2223;
MERGE new22 new23;
time=_n_; 
run;
proc gplot data=new2223;	
PLOT (pnormale probaols)*time/overlay legend=legend1 vref=1 vref=0;
SYMBOL interpol=join; 
 TITLE color=RED height=2 font=times "Comparaison de probabilité OLS vs PROBIT";                                                   
		LEGEND1 value=(tick=1 'prev Probit' tick=2 'Prev OLS') label=none;                                                         
run;

/* Calcul des effets marginaux à certains points : .5-1-1.5-2-2.5-3-3.5 */

PROC PRINT data=estim;
run;
data new;
set estim;
t=_n_;
if t=2 then delete;
drop _name_ _type_ _status_;
run;
proc print data=new;
run;

DATA marginal;
SET new;
aug=2;  /*  changer la valeur */
phi=intercept+aug*x;
effetm=((1/sqrt(2*3.14159265358979))*exp(-0.5*phi**2))*x;
probadephi=CDF('NORMAL',phi); 
run;
PROC PRINT data=marginal;
title 'Effet marginal et probabilités pour probit';
RUN;

/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */

/* S3: le modèle  LOGIT  */

proc qlim data=transport;
model y=x/discrete(d=logit);
output out=logitout xbeta marginal; 
title 'Estimations logit';	
run;
proc print data=logitout;
run;

/* Effet marginal moyen EMM*/
proc means data=logitout;
var meff_p1_x meff_p2_x;
title 'Effet marginal moyen pour LOGIT';
run; 

/*  Calculs des Valeurs prédites  */
data transport3;
set logitout;
plogistic = CDF('LOGISTIC',xbeta_y,0,1); 		* calcul des probabilités;
phat = (plogistic >= .5); 				        * phat = 1 si p >= .5;
run;

proc print data=transport3;
var plogistic;
run;

DATA NEW33;
SET transport3(keep=plogistic);
RUN;

DATA NEW4;
MERGE new22 new23 new33;
time=_n_; 
run;

PROC PRINT data=new4;
RUN;

proc gplot data=new4;	
PLOT (pnormale probaols plogistic)*time/overlay legend=legend1 vref=1 vref=0;
SYMBOL interpol=join; 
 TITLE color=RED height=2 font=times "Comparaison de probabilité OLS vs PROBIT vs LOGIT";                                                   
		LEGEND1 value=(tick=1 'prev Probit' tick=2 'Prev OLS' tick=3 'Prev Logistic') label=none;                                                         
run;

/*XXXXXXXXXXXXXXXXX EN CHANGEANT Y=1 par Y=10 XXXXXXXXXXXXXXXXXXXXXXXXXX*/

DATA ESSAI10;
SET transport;
y10=y*10;
RUN;
PROC PRINT;
RUN;

/* S3: le modèle  PROBIT  */

proc qlim data=essai10 outest=estim method=QUANEW;			
model y10=x/discrete; 			    * discrete pour probit;
output out=probitout xbeta marginal;
title 'Estimations Probit s3';
run;

/*XXXXXXXXXXXXXXXXX EN CHANGEANT Y=1 par Y=1 et y=0 par 20 XXXXXXXXXXXXXXXXXXXXXXXXXX*/

DATA ESSAI12;
SET transport;
if y=0 then  y=20;
RUN;
PROC PRINT;
RUN;

/* S4: le modèle  PROBIT  */

proc qlim data=essai12 outest=estim method=QUANEW;			
model y=x/discrete; 			    * discrete pour probit;
output out=probitout xbeta marginal;
title 'Estimations Probit s4';
run;



/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* autres procedure POUR PROBIT: */
proc probit data=transport outest=estim;			
model y(event=last)=x; 			 
output out=probitout xbeta=xb ;
title 'Estimations Probit';
run;

proc probit data=transport outest=estim;			
model y(event=first)=x; 			 
output out=probitout xbeta=xb ;
title 'Estimations Probit';
run;
/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
DATA ESSAInew;
SET transport;
y10=y+1;
if y10 =2 then y10=0;
RUN;
PROC PRINT;
RUN;

/* S3: le modèle  PROBIT  */

proc qlim data=essainew outest=estim method=QUANEW;			
model y10=x/discrete; 			    * discrete pour probit;
output out=probitout xbeta marginal;
title 'Estimations Probit s3';
run;
