PROC IMPORT OUT= WORK.pib
            DATAFILE= "D:\SERVEUR MASTER IDEE 2022-2023\
MASTER 1 IDEE\ECONOMETRIE DES SERIES TEMPORELLES
\TD\tcrpibbelge.xlsX"
            DBMS=xlsX replace;
     GETNAMES=YES;
RUN;

proc print;
run;
proc contents;
run;
proc freq;
run;

PROC GPLOT;                                                                                                                             
PLOT tcr*obs;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "TCR PIB BELGE";                                                                                 
RUN; 

proc spectra out=g p s adjmean whitetest coef;
var tcr;
weights 1 2 3 4 3 2 1;
run;
proc print data=g;
run;
proc gplot data=g;
plot p_01*freq;
plot p_01*period;
plot s_01*freq;
plot s_01*period;
plot period*freq;
run;

proc gplot data=g;
*where period<40;
plot s_01*period/href=2;
run;


/* Reconstruction de la série avec les # cycles */
/* Etape 1 */

PROC SORT data=g out=sortg;
BY descending p_01;
RUN;
proc univariate; * pour avoir la somme ici 201.979318 ;
var p_01;
OUTPUT OUT=somme  sum=somme;
run;
proc print data=somme;
RUN;

data calcul;     * calcul des frequences pour determiner les cycles principaux;
set g;
freq=p_01/201.979318*100;
run;
data g;
set g somme;
run;


data calcul;     * calcul des frequences pour determiner les cycles principaux;
set g;
freq=p_01/somme*100;
run;
proc print data=g;
run;

proc sort data=calcul;
BY descending freq;
run;
proc print data=calcul; * les 3 cycles principaux sont 40-2-8 ;
var freq period COS_01 SIN_01 ;
run;

/* Etape 2 */

proc means data=pib; * pour avoir la moyenne de TCR ici 2.8194430 ;
var tcr;
run;

data etape2; * Calcul des valeurs des cycles ;
set pib;
cycle1=40;
cycle2=8;
cycle3=2;
mean=2.8194430;
time +1;
C40=  -0.79834*COS((2*3.14*time)/cycle1)+  0.90705 *SIN((2*3.14*time)/cycle1)+mean;
C2=   -1.08689*COS((2*3.14*time)/cycle2)+  0.00000 *SIN((2*3.14*time)/cycle2)+mean;
C8=   -0.96142*COS((2*3.14*time)/cycle3)+  0.29709 *SIN((2*3.14*time)/cycle3)+mean;
run;

PROC GPLOT data=etape2;                                                                                                                             
PLOT (tcr c40 c2 c8)*obs/overlay legend=legend ;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "TCR et cycleS 40-2-8 "; 
legend label=()
value=(tick=1 justify=c "TAUX DE CROISSANCE pib"
       tick=2 justify=c "CYCLE 40 ANS"
       tick=3 justify=c "CYCLE 2 ANS"
       tick=4 justify=c "CYCLE 8 ANS");
run; 

/* Etape 3 */
*calcul de la somme des # cycles;

data etape3;
set etape2;
CC40=  -0.79834*COS((2*3.14*time)/cycle1)+  0.90705 *SIN((2*3.14*time)/cycle1);
CC2=   -1.08689*COS((2*3.14*time)/cycle2)+  0.00000 *SIN((2*3.14*time)/cycle2);
CC8=   -0.96142*COS((2*3.14*time)/cycle3)+  0.29709 *SIN((2*3.14*time)/cycle3);

SOMME=cC40+cC2+cC8+mean;	
run;
PROC GPLOT data=etape3;                                                                                                                             
PLOT (tcr somme c40)*obs/overlay legend=legend;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "TCR et somme des cycleS : 40 + 2 + 8 "; 
legend label=()
value=(tick=1 justify=c "TAUX DE CROISSANCE pib"
       tick=3 justify=c "CYCLE 40 ANS"
       tick=2 justify=c "Somme des 3 cycles");
run; 

/* GRAPHIQUE DE LA CONJONCTURE : DIFFERENCE ENTRE SERIE BRUTE ET SOMME DES 3 CYCLES */

DATA CONJONCTURE;
SET etape3;
conj=tcr-somme;
RUN;
PROC GPLOT data=conjoncture;                                                                                                                             
PLOT (conj)*obs/overlay;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "CONJONCTURE "; 
run;


/* ETAPE 4 : EXTRAPOLATION DANS LE FUTUR : + 40 ANS */
DATA more;
input time cycle1 obs; /* choix inconnu : . */
datalines;
41 40 41
42 40 42
43 40 43
44 40 44
45 40 45
46 40 46
47 40 47
46 40 48
49 40 49
50 40 50
51 40 51
52 40 52
53 40 53
54 40 54
55 40 55
56 40 56
57 40 57
58 40 58
59 40 59
60 40 60
61 40 61
62 40 62
63 40 63
64 40 64
65 40 65
66 40 66
67 40 67
68 40 68
69 40 69
70 40 70
71 40 71
72 40 72
73 40 73
74 40 74
75 40 75
76 40 76
77 40 77
78 40 78
79 40 79
80 40 80
RUN;
/* Ajout nouvelles observations aux data */
data etape3;
set etape3 more;
run;
PROC PRINT data=etape3;
RUN;


DATA etape4;
SET etape3;
Cc40=  -0.79834*COS((2*3.14*time)/cycle1)+  0.90705 *SIN((2*3.14*time)/cycle1)+2.81944;
C40=  -0.79834*COS((2*3.14*time)/cycle1)+  0.90705 *SIN((2*3.14*time)/cycle1);
C2=   -1.08689*COS((2*3.14*time)/2)+  0.00000 *SIN((2*3.14*time)/2);
C8=   -0.96142*COS((2*3.14*time)/8)+  0.29709 *SIN((2*3.14*time)/8);

SOMME=C40+C2+C8+2.81944;	
run;

PROC PRINT data=etape4;
RUN;

GOPTIONS reset=all;
PROC GPLOT data=etape4;                                                                                                                             
PLOT (tcr cc40 somme)*time/overlay legend=legend;                                                                                                                           
*SYMBOL interpol=join;  
SYMBOL1 i = join c = blue  width=5;
SYMBOL2 i = join c = red;
SYMBOL3 i = join c = green;
TITLE color=red height=2 font=times "TCR et extrapolation des cycles "; 
legend label=()
value=(tick=1 justify=c "TAUX DE CROISSANCE pib"
       tick=2 justify=c "CYCLE 40 ANS"
       tick=3 justify=c "Somme des 3 cycles");
run;

 /* SANS LA SOMMES DES 3 CYCLES */

PROC GPLOT data=etape4;                                                                                                                             
PLOT (tcr cc40)*time/overlay legend=legend;                                                                                                                           
SYMBOL interpol=join;                                                                                                                   
TITLE color=red height=2 font=times "TCR et extrapolation des cycles "; 
legend label=()
value=(tick=1 justify=c "TAUX DE CROISSANCE pib"
       tick=2 justify=c "CYCLE 40 ANS");
run;



/* FIN analyse spectrale */

/* filtre de Hodrick-Prescott */


proc ucm data=pib;
  
   model tcr;
   irregular plot=smooth;
   level var=0 noest plot=smooth;
   slope var=0.0025 noest;
   estimate PROFILE;
   forecast plot=(decomp);
run;


/* FIN */









PROC EXPORT DATA= etape4
            OUTFILE= "D:\SERVEUR MASTER IDEE 2022-2023\
MASTER 1 IDEE\ECONOMETRIE DES SERIES TEMPORELLES
\TD\essai1.xlsx"
            DBMS=xlsx;
RUN;





