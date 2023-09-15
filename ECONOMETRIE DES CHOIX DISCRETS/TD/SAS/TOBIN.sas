PROC IMPORT OUT= WORK.TOBIN                                                                                                           
            DATAFILE= "W:\Droit\Public\Depots_Ens\Philippe_Compaire\
SERVEUR ECONOMETRIE 2020-2021\
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






