PROC IMPORT OUT= WORK.bj                                                                                                           
            DATAFILE= "D:\SERVEUR MASTER IDEE 2022-2023\
MASTER 1 IDEE\ECONOMETRIE DES SERIES TEMPORELLES\DATA\tgvsas.xlsx"                        
            DBMS=xlsx REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN;                                                                                                                                    
PROC CONTENTS;                                                                                                                          
RUN;
PROC PRINT; 
RUN; 
 
/* PARTIE 0  TRANSFORMATIONS DES VARIABLES */                                                                                          
                                                                                                     
DATA travail;                                                                                                                              
SET bj;  
time=_n_; 
/* pour partie I-2 */
LTGV=log(TGV);
L12TGV=lTGV-lag12(lTGV);
d12LTGV=dif(l12TGV);
/* pour partie I-3 */
DD12lTGV = D12lTGV - 2*lag(D12lTGV) + lag2(d12lTGV); 
RUN;   

/* PARTIE I  IDENTIFICATION : ETAPE 1 DE BJ */    
/* PARTIE I-I : DONNEES BRUTES

/* QUESTION 1 : graphique ST : données brutes */
PROC GPLOT data=travail;                                                                                                                             
PLOT TGV*time;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR1 : Données brutes Trafic TGV";                                                                                 
RUN; 
 proc sgplot data=travail;
  series x=time y=TGV;
run;

/* QUESTION 2 : graphiques ST : moyennes et variances par groupe */

 PROC MEANS DATA=travail ;
VAR TGV;
by classe;
output out=stat mean=moy var=ect;
run;

proc print data=stat;
run;
PROC GPLOT data=stat;                                                                                                                             
PLOT moy*classe;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR2 : Données means par groupe";                                                                                 
RUN; 
PROC GPLOT data=stat;                                                                                                                             
PLOT ect*classe;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR3 : Données écart-type par groupe";                                                                                 
RUN; 

/* QUESTION 3 : graphiques : ACF & PACF */

proc arima data=travail;
      identify var=TGV nlag=200 outcov=acf;
      *estimate q=(1 2 3 4 5 6)(12) p=(1 2)(12)noint method=ml;
      *forecast id=time  printall out=b;
   run;

PROC PRINT data=acf;
RUN;

PROC GPLOT data=acf;                                                                                                                             
PLOT corr*lag;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR4 : ACF";                                                                                 
RUN;
PROC GPLOT data=acf;                                                                                                                             
PLOT corr*lag/href=12 href=24;
where lag<30; 
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR4bis : zoom ACF";                                                                                 
RUN;

PROC GPLOT data=acf;                                                                                                                             
PLOT partcorr*lag;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR5 : PACF";                                                                                 
RUN;

/* PARTIE I-II : DONNEES DESAISONNALISEES ET DIF1

/* QUESTION 1 : graphique ST : données désaisonnalisées & dif1 */
PROC GPLOT data=travail;                                                                                                                             
PLOT d12lTGV*time;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR6 : Données dif1 et désaisonnalisées Trafic TGV";                                                                                 
RUN; 
 proc sgplot data=travail;
  series x=time y=d12lTGV;
run;

/* QUESTION 2 : graphiques ST : moyennes et variances par groupe */

 PROC MEANS DATA=travail ;
VAR d12lTGV;
by classe;
output out=stat1 mean=moy var=ect;
run;

proc print data=stat1;
run;
PROC GPLOT data=stat1;                                                                                                                             
PLOT moy*classe;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR7 : Données means par groupe s12 et dif1";                                                                                 
RUN; 
PROC GPLOT data=stat1;                                                                                                                             
PLOT ect*classe;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "G8 : Données écart-type par groupe s12 et dif1";                                                                                 
RUN; 

/* QUESTION 3 : graphiques : ACF & PACF */

proc arima data=travail;
      identify var=d12lTGV nlag=200 outcov=acf1;
      *estimate q=(1 2 3 4 5 6)(12) p=(1 2)(12)noint method=ml;
      *forecast id=time  printall out=b;
   run;

PROC PRINT data=acf1;
RUN;
data new;
set acf1;
stderrplus=stderr;
stderrmoins=-stderr;
BUP=1.96/sqrt(216);
BLOW=-1.96/sqrt(206);
RUN;


PROC GPLOT data=new;                                                                                                                             
PLOT (corr stderrplus stderrmoins)*lag/overlay;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR9 : ACF s12 & dif1";                                                                                 
RUN;

PROC GPLOT data=new;                                                                                                                             
PLOT (partcorr bup blow)*lag/overlay;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR10 : PACF s12 et dif1";                                                                                 
RUN;


/* PARTIE I-III : DONNEES DESAISONNALISEES ET DIF2

/* QUESTION 1 : graphique ST : données désaisonnalisées & dif2 */
PROC GPLOT data=travail;                                                                                                                             
PLOT dd12lTGV*time;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR11 : Données dif2 et désaisonnalisées Trafic TGV";                                                                                 
RUN; 
 proc sgplot data=travail;
  series x=time y=dd12lTGV;
run;

/* QUESTION 2 : graphiques ST : moyennes et variances par groupe */

 PROC MEANS DATA=travail ;
VAR dd12lTGV;
by classe;
output out=stat2 mean=moy var=ect;
run;

proc print data=stat2;
run;
PROC GPLOT data=stat2;                                                                                                                             
PLOT moy*classe;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR12 : Données means par groupe s12 et dif2";                                                                                 
RUN; 
PROC GPLOT data=stat1;                                                                                                                             
PLOT ect*classe;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR13 : Données écart-type par groupe s12 et dif2";                                                                                 
RUN; 

/* QUESTION 3 : graphiques : ACF & PACF */

proc arima data=travail;
      identify var=dd12lTGV nlag=200 outcov=acf2;
      *estimate q=(1 2 3 4 5 6)(12) p=(1 2)(12)noint method=ml;
      *forecast id=time  printall out=b;
   run;

PROC PRINT data=acf2;
RUN;
data new2;
set acf2;
stderrplus=stderr;
stderrmoins=-stderr;
BUP=1.96/sqrt(216);
BLOW=-1.96/sqrt(206);
RUN;


PROC GPLOT data=new2;                                                                                                                             
PLOT (corr stderrplus stderrmoins)*lag/overlay;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR14 : ACF s12 & dif2";                                                                                 
RUN;

PROC GPLOT data=new2;                                                                                                                             
PLOT (partcorr bup blow)*lag/overlay;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "GR15 : PACF s12 et dif2";                                                                                 
RUN;

/* PARTIE I-III : DETERMINATION DES VALEURS MAX DE P Q p q  (s d D)

/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
               L'ACF DETERMINE LE    q  DU MA                                                                                      
               LE PACF DETERMINE LE  p  DU AR                   
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/










/* PARTIE II  ESTIMATION/VERIFICATION : ETAPE 2/3 DE BJ */    


proc arima data=travail;
      *identify var=lTGV(1,12) ;
      identify var=d12lTGV scan;
      *estimate q=(1)(12) p=(1 2 3)noint method=ml;
      estimate q=(1)(12) p=(1 2 3) method=ml;
   run;
/* method : ML-ULS-CLS
* var=serie(d,s*D)
* var=serie(1) ie dif1
* var=serie(1,1) ie dif2 */


/* PARTIE III  PREVISION PASSEE/PREVISION FUTUR : ETAPE 4 DE BJ */    

proc arima data=travail;
      identify var=lTGV(1,12) ;
      estimate q=(1)(12) p=(1 2 3)noint method=ml;
      *estimate q=(1)(12) p=(1 2 3) method=ml;
      *estimate q=(1)(12) method=ml;
      forecast id=time  printall out=b;
   run;

PROC PRINT data=b;
RUN;


PROC GPLOT data=b;                                                                                                                             
PLOT (LTGV forecast l95 u95)*time/overlay;                                                                                                                           
SYMBOL interpol=join; 
where time >13; 
TITLE color=red height=2 font=times "GR4 : PREVISIONS";                                                                                 
RUN;

PROC GPLOT data=b;                                                                                                                             
PLOT (LTGV forecast l95 u95)*time/overlay;                                                                                                                           
SYMBOL interpol=join; 
where time >210; 
TITLE color=red height=2 font=times "GR4 : PREVISIONS zoom";                                                                                 
RUN;



/* recherche fiablilité de la prévision */

PROC MEANs DATA=travail;
var lTGV;
RUN;
data new;
set b;
if forecast = . then delete;
if lTGV = . then delete;
run;
proc print data=new;
run;


PROC MEANs DATA=new;
var forecast;
var lTGV;
RUN;
proc corr data=new OUT=corre;
var lTGV forecast;
run;
PROC PRINT DATA=corre;
RUN;

data fiabilite;
SET travail;
Um=((7.82974-7.83190)**2)/0.003059; /*proche de 0 */
Us=((0.23076-0.22070)**2)/0.003059; /*proche de 0*/
Uc=(2*(1-0.97115)*(0.23076*0.22070))/0.003059;/* proche de 1*/
total=um+us+uc;
* NB : MSE = Var res = .003559;
run;
PROC PRINT data=fiabilite;
RUN;

/*  FIN  */
 






