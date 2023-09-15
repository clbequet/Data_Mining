PROC IMPORT OUT= WORK.TOBIN                                                                                                           
            DATAFILE= "M:\SERVEUR ECONOMETRIE 2021-2022\
MASTER 2 ING ECO\SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\DATA\TOBIN.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN;

/* Modèle de régression : TOBIT censuré*/

proc contents data=tobin;
title 'Fichier des données';
run;
proc print data=tobin(obs=50);
run;

/* Histogramme  */
proc sgplot data=tobin;
title "Nb d'heures de travail de l'épouse en 2005";
histogram heure / scale=count;
run;
proc univariate data = tobin noprint; 
  histogram heure / vscale = count;
run;


/* OLS sur toutes les  observations */
proc reg data=tobin;
model heure = se exper agee enf6;
title 'Estimation OLS heures travaillées toutes observations';
run;

/* OLS sur observations censurées */
proc reg data=tobin ;
model heure = se exper agee enf6;
where heure>0;
title 'Estimation OLS heures travaillées sur données censurées';
run;

/* Estimation tobit */

proc qlim data=tobin outest=estim;
model heure = se exper agee enf6;
endogenous heure ~ censored(lb=0);
output out=tobit marginal;
title 'Estimations tobit';
run;

proc means data=tobit;
title 'tobit effets marginaux moyens';
run;
proc contents data=estim;
run;
proc print data=estim;
RUN;
data new;
set estim;
t=_n_;
if t=2 then delete;  /* NB : 2 correspond aux écart-types */
drop _name_ _type_ _status_;
run;
proc print data=new;
run;



/* Calcul des effets marginaux pour SE aux points moyens */
data marginalSE;
set new;
pmse=12.29;
pmexper=10.63;
pmagee=42.54;
pmenf6=1;
phi=(intercept+pmse*se+pmexper*exper+pmagee*agee+pmenf6*enf6)/_sigma;
probadephi=CDF('NORMAL',phi); 
marginalse=se*probadephi;
proba0=(1/sqrt(2*3.14159265358979))*exp(-0.5*phi**2);
proba1=1-proba0;
run;
PROC PRINT data=marginalse;
title 'Effet marginal et probabilites pour se';
RUN;

/* Calcul des effets marginaux pour EXPER aux points moyens */
data marginalEXPER;
set new;
pmse=12.29;
pmexper=10.63;
pmagee=42.54;
pmenf6=1;
phi=(intercept+pmse*se+pmexper*exper+pmagee*agee+pmenf6*enf6)/_sigma;
probadephi=CDF('NORMAL',phi); 
marginalEXPER=EXPER*probadephi;
proba0=(1/sqrt(2*3.14159265358979))*exp(-0.5*phi**2);
proba1=1-proba0;
run;
PROC PRINT data=marginalEXPER;
title 'Effet marginal et probabilites pour EXPER';
RUN;

/* mêmes calculs avec OLS */

proc reg data=tobin outest=estimols;
model heure = se exper agee enf6;
title 'Estimation OLS heures travaillées toutes observations';
run;

data new2;
set estimols;
t=_n_;
if t=2 then delete;  /* NB : 2 correspond aux écart-types */
drop _name_ _type_ _status_;
run;
proc print data=new2;
run;
/* Calcul des effets marginaux pour SE aux points moyens */
data marginalSE2;
set new2;
pmse=12.29;
pmexper=10.63;
pmagee=42.54;
pmenf6=1;
phi=intercept+pmse*se+pmexper*exper+pmagee*agee+pmenf6*enf6;
probadephi=CDF('NORMAL',phi); 
marginalse=se*probadephi;
proba0=(1/sqrt(2*3.14159265358979))*exp(-0.5*phi**2);
proba1=1-proba0;
run;
PROC PRINT data=marginalse2;
title 'Effet marginal et probabilites pour se';
RUN;


/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
/* Estimation tobit  avec toutes les variables exogènes*/

proc qlim data=tobin outest=estim3;
model heure = 	MFS	SPM	SMM	FES	T2005	ENF6	
ENF618	AGEE	SE	SALF	HAGE	SM	SALM	TAXEE	SME	SPE	TCHO	VILLEGRD	EXPER;
endogenous heure ~ censored(lb=0);
output out=tobit3 marginal;
title 'Estimations tobit 3  ALL VARIABLES';
run;

data new3;
set estim3;
t=_n_;
if t=2 then delete;  /* NB : 2 correspond aux écart-types */
drop _name_ _type_ _status_;
run;
proc print data=new3;
run;

PROC MEANS DATA=tobin;
var MFS	SPM	SMM	FES	T2005	ENF6	
ENF618	AGEE	SE	SALF	HAGE	SM	SALM	TAXEE	SME	SPE	TCHO	VILLEGRD	EXPER;
RUN;




/* Calcul des effets marginaux pour SE aux points moyens */
data marginalSE3;
set new3;

pmMFS=	1;           /*Nb de frères et sœurs du mari*/
pmSPM= 8.5245684;    /*niveau de scolarité du père du mari*/
pmSMM= 9.2416999;    /*niveau de scolarité de la mère du mari*/
pmFES=1;             /* Nb de frères et sœurs de l’épouse*/
pmT2005=1;           /* 1 si l’épouse a travaillé en 2005, sinon 0*/
pmENF6=	1;           /*Nb d'enfants de moins de 6 ans*/
pmENF618=8;          /*Nb d'enfants de 6 à 18 ans*/
pmAGEE= 42.5378486;  /* âge de l’épouse 30 puis 60*/
pmSE= 12.2868526 ;    /*niveau de scolarité de l'épouse, en années 12.2868526 puis 5 et 17*/
pmSALF= 2.3745653;   /*Salaire horaire moyen de l’épouse de 2005*/
pmHAGE=45.1208499;   /*âge du mari (agem) */
pmSM=  12.4913679;   /*niveau de scolarité de l'époux, en années*/
pmSALM=  7.4821788;  /*salaire du mari en dollars (de 2005)*/
pmTAXEE= 0.6788632;  /*taux d'imposition marginal de l’épouse*/
pmSME=	9.2509960;   /* niveau de scolarité de la mère de l'épouse*/
pmSPE=   8.8087649;  /*niveau de scolarité du père de l'épouse*/
pmTCHO=  8.6235060;  /*Taux de chômage dans la ville de résidence*/
pmVILLEGRD= 1;   /*1 si le ménage habite dans une grande ville, 0 sinon*/
pmEXPER= 10.6308101;    /*Nb d’années d’expérience sur le marché du travail de l'épouse*/

phi=(intercept+pmmfs*MFS+pmspm*	SPM	+pmsmm*SMM+pmfes*	FES+pmt2005*	T2005+pmenf6*	ENF6+	
pmenf618*ENF618+pmagee*	AGEE+pmse*	SE+pmsalf*	SALF+pmhage*	HAGE+pmsm*	SM+pmsalm*	SALM+pmtaxee*	TAXEE
+pmsme*SME	+pmspe*SPE+pmtcho*	TCHO+pmvillegrd*	VILLEGRD+pmexper*	EXPEr)/_sigma;
probadephi=CDF('NORMAL',phi); 
marginalse=se*probadephi;
marginalenfant8=ENF618*probadephi;
marginalEXPER=EXPER*probadephi;
proba0=(1/sqrt(2*3.14159265358979))*exp(-0.5*phi**2);
proba1=1-proba0;
run;
PROC PRINT data=marginalse3;
title 'Effet marginal et probabilites pour se';
RUN;


/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
/* Estimation tobit  CENSURE A DROITE ET GAUCHE*/

/* Estimation tobit */

proc qlim data=tobin outest=estim4;
model heure = se exper agee enf6;
endogenous heure ~ censored(lb=0 ub=2800);
output out=tobit4 marginal;
title 'Estimations tobit';
run;

proc means data=tobit4;
title 'tobit effets marginaux moyens';
run;
proc contents data=estim4;
run;
proc print data=estim4;
RUN;
data new4;
set estim4;
t=_n_;
if t=2 then delete;  /* NB : 2 correspond aux écart-types */
drop _name_ _type_ _status_;
run;
proc print data=new4;
run;



/* Calcul des effets marginaux pour SE aux points moyens */
data marginalSE4;
set new4;
pmse=12.29;
pmexper=10.63;
pmagee=42.54;
pmenf6=1;
phi=(intercept+pmse*se+pmexper*exper+pmagee*agee+pmenf6*enf6)/_sigma;
probadephi=CDF('NORMAL',phi); 
marginalse=se*probadephi;
proba0=(1/sqrt(2*3.14159265358979))*exp(-0.5*phi**2);
proba1=1-proba0;
run;
PROC PRINT data=marginalse4;
title 'Effet marginal et probabilites pour se, CENSURE droite et gauche';
RUN;


/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
/* Estimation tobit  TRONQUE A  GAUCHE*/

/* Estimation tobit */

proc qlim data=tobin outest=estim5;
model heure = se exper agee enf6;
endogenous heure ~ truncated(lb=100);
output out=tobit5 marginal;
title 'Estimations tobit truncated';
run;

proc means data=tobit5;
title 'tobit effets marginaux moyens';
run;
proc contents data=estim5;
run;
proc print data=estim5;
RUN;
data new5;
set estim5;
t=_n_;
if t=2 then delete;  /* NB : 2 correspond aux écart-types */
drop _name_ _type_ _status_;
run;
proc print data=new5;
run;



/* Calcul des effets marginaux pour SE aux points moyens */
data marginalSE5;
set new5;
pmse=12.29;
pmexper=10.63;
pmagee=42.54;
pmenf6=1;
phi=(intercept+pmse*se+pmexper*exper+pmagee*agee+pmenf6*enf6)/_sigma;
probadephi=CDF('NORMAL',phi); 
marginalse=se*probadephi;
proba0=(1/sqrt(2*3.14159265358979))*exp(-0.5*phi**2);
proba1=1-proba0;
run;
PROC PRINT data=marginalse5;
title 'Effet marginal et probabilites pour se, TRUNQUE gauche';
RUN;


