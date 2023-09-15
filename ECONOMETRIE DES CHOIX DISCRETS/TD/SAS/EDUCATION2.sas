PROC IMPORT OUT= WORK.EDUCATION                                                                                                           
            DATAFILE= "D:\SERVEUR MASTER IDEE 2022-2023\
MASTER 1 IDEE\ECONOMETRIE DES CHOIX DISCRETS\DATA\EDUCATION.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN; 

/* Probit ordonné*/
/*XXXXXXXXXXXXXXXX*/
PROC contents data=education (obs=5);
RUN;
/* Lecture et élimination de data */
data EDUCATION1;					
set education;
keep y niveau;
run;
proc print data=education1 (obs=5);
title 'Education observations';
run;

/* Ajout d'observations */
data more;
input y niveau;
datalines;
. 6.64
. 2.635
;
run;
data pse;
set education1 more;
run;

/* Estimation probit ordonné*/
proc qlim data=pse;
model y = niveau / discrete(d=logit) limit1=varying; *(d=normal);
output out=pseout proball marginal;
title 'Estimation probit ordonné';
run;

proc print data=pseout;
where y = .;
title 'Sortie proba et effets marginaux';
run;

proc means data=pseout;
var meff_p1_niveau meff_p2_niveau meff_p3_niveau;
where y ne .;
title 'Effets marginaux moyens';
run;

