PROC IMPORT OUT= WORK.m1
            DATAFILE= "P:\methodologie\DATAbase 2022-2023.XLSX"
               DBMS=xlsx REPLACE;                                                                                                     
     GETNAMES=YES; 
RUN;

PROC PRINT DATA=m1;
RUN;
PROC CONTENTS;
RUN;
/*QUESTION 1 : GRAPHIQUE  NUAGE DE POINTS*/ 

PROC GPLOT data=m1;
PLOT Poids*taille=456879745;
TITLE color=red height=3 font=times "Nuage de points :TAILLE en fonction Poids GR1";

RUN;

/*QUESTION 2 : GRAPHIQUE SERIES TEMPORELLES*/

GOPTIONS reset=all;/*Initialisation des séries ie remise à zéro des formats...*/
 /*gout=graphique3;*//*Pour sauvegarder un graphique*/
PROC GPLOT ;            
PLOT (poids taille)*obs/overlay legend=legend1;
SYMBOL interpol=join;
TITLE color=red height=2 font=times "poids & taille GR2";
LEGEND1 value=(tick=1 'Poids' tick=2 'Taille') label=none;
run;

GOPTIONS reset=all;
PROC GPLOT ;/*Avec 2 axes sur le meme graphique*/
PLOT poids*obs=1/haxis=axis1 vaxis=axis2;
PLOT2 taille*obs=2;
SYMBOL interpol=join;
TITLE color=red height=2 font=times "Poids & Taille GR3";
AXIS1 label=('Annees');
AXIS2 label=('Poids');
run;

/*QUESTION 3 : CORRELATION */
proc sort data=m1;
by genre;
run;


PROC CORR data=m1;
VAR poids taille age POINTURE;
*where m1="IEE";
*by genre;
RUN;

/*QUESTION 4 : ESTIMATION  ET NUAGE DE POINTS AVEC DROITE DE REGRESSION
EQUATION ESTIMEE : POIDS = A*TAILLE + B */

PROC REG data=M1 outest=coef;;
MODEL poids = taille /all;
PLOT poids*taille;

plot poids*taille / conf;
plot poids*taille / pred;

SYMBOL1 v=dot;
TITLE color=red height=3 "Regression simple GR4";
OUTPUT OUT=file1 P=prev R=res1;
*where m1="N4E";
*by genre;
RUN;
/*options de model

STB = standardized parameter estimates
CLB = confidence limits for B
ALL = acov clb cli clm corrb covb i p PCORR1 PCORR2 R SCORR1 SCORR2
      SEQB spec ss1 ss2 stb tol vif xpx

ACOV, ADJRSQ, AIC, ALL, ALPHA, B, BEST, BIC, CIC, CLB, CLI, CLM, COLLIN, COLLINOINT, CORRB, COVB, CP,
DETAILS, DW, EDF, GMSEP, GROUPNAMES, I, INCLUDE, INFLUENCE, JP, MAXSTEP, METHOD, MSE, NOINT, NOPRINT, OUTSEB, OUTSTB, OUTVIF, P, PARTIAL, PC, PCOMIT, PCORR1,
PCORR2, PRESS, R, RIDGE, RMSE, RSQUARE, RXY, SBC, SCORR1, SCORR2, SELECT, SELECTION, SEQB, SIGMA, SINGULAR, SLENTRY, SLSTAY, SP, SPEC, SS1, SS2, SSE, START,
STB, STOP, TOL, VIF, XPX

conf : intervalle de confiance pour les prévisions de la moyenne
pred : intervalle de confiance d'une observation individuelle */

/*QUESTION 5 : GRAPHIQUE DES RESIDUS*/

PROC GPLOT;
PLOT res1*obs;
SYMBOL interpol=join;
TITLE color=red height=2 font=times "Résidus GR5";
RUN;

/*QUESTION 6 : Y ET Y ESTIME*/

PROC GPLOT;
PLOT (poids prev)*obs/overlay legend=legend1;
SYMBOL interpol=join;
TITLE color=red height=2 font=times "Poids & poids estimé GR6";
LEGEND1 value=(tick=1 'Poids' tick=2 'Poids estimé') label=none;
RUN;

/*QUESTION 7 : PREVISION PONCTUELLE */

DATA ponct;
SET coef;
prev=intercept+175*taille;
PROC PRINT DATA=ponct;
RUN;


/*QUESTION 8 : INTERVALLE DE PREVISION */

DATA newvaleurs;
INPUT un1 taille1;	/* valeurs des exogenes supplémentaires */
CARDS;		
1.0 195
;RUN;

PROC IML;
USE M1;
READ all var {poids} into y ;
READ all var {un taille} into x;
USE newvaleurs;
READ first var {un1 taille1} into x0;
PRINT y x X0;
 START reg(x,y);
      reset print;		              /* affichage de toutes les matrices crées */
      n=nrow(x);                      /* nombre d'observations */
      k=ncol(x);                      /* nombre de variables */
      xpx=x`*x;                       /* produit croisé */
      xpy=x`*y;						  /* produit X*y */
      xpxi=inv(xpx);                  /* inverse du produit croisé */
      b=xpxi*xpy;                     /* estimations  */
      yhat=x*b;                       /* valeurs estimées */
      resid=y-yhat;                   /* résidus */
      sse=resid`*resid;               /* sum of squared errors */
      dfe=n-k;                        /* degrés de liberté */
      mse=sse/dfe;                    /* mean squared error VARIANCE DES RESIDUS */
      rmse=sqrt(mse);                 /* root mean squared error */
      covb=xpxi#mse;                  /* covariance des estimateurs */
      stdb=sqrt(vecdiag(covb));       /* ecart-type des estimateurs */
      t=b/stdb;                       /* t-ratio */
      probt=1-probf(t#t,1,dfe);       /* significance probability */

      bb=INV(X`*X)*X`*Y;              /* Nouveau calcul des estimations plus courte */
      print b stdb t probt bb;
	  store b;
	  STORE xpxi;
	  STORE mse;
FINISH;
RUN reg(x,y);  

START prev(x0,b);
		load b;
        yprev=x0*b; /* calcul de la valeur prévue */
		STORE yprev;
        print yprev x0 b;
FINISH;
RUN prev(x0,b);  

START VARZ(x0,xpxi);
		LOAD xpxi;
		LOAD mse;
        Z=mse*(1+x0*xpxi*x0`);		/* VARIANCE DE L'ERREUR DE PREVISION */
		etz=sqrt(z); 	            /* ECART-TYPE DE L'ERREUR DE PREVISION */
		STORE etz;
		print Z etz;
FINISH;
RUN VARZ(x0,xpxi);

START ICPREV(yprev,etz);	/* Intervalle de prévision */
		LOAD yprev;
		LOAD etz;
		ICinf=yprev-2.145*etz;   /* valeur 2.145 à changer selon taille échantillon */
		ICsup=yprev+2.145*etz;
		print ICinf ICsup;
FINISH;
RUN ICPREV(yprev,etz);

/* POINTS EXTREMES */

ods rtf file="M:\sortieA.rtf";
ods graphics on/labelmax=400;
PROC REG DATA=M1
plots(label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
id obs;
MODEL poids = taille /r influence;
OUTPUT out=influence H=levier cookd=dcook student=rsi rstudent=rse;
RUN;
ods rtf close;
ods graphics off;




/* COMMENTAIRES : CALCULER VOTRE POIDS IDEAL THEORIQUE (PIT)
1) FORMULE DE BROCA

PIT1 = TAILLE - 100

2) FORMULE DE LORENTZ

PIT2 masculin = TAILLE - 100 - ((TAILLE-150)/4)
PIT3 feminin = TAILLE - 100 - ((TAILLE-150)/2.5)
*/

DATA com;
SET M1;
pit1=175-100;
pit2f=175-100-((175-150)/2.5);
pit3m=175-100-((175-150)/4);

PROC PRINT DATA=com;
RUN;
/* A COMPARER AVEC VOTRE POIDS REEL........ */



/* GRAPHIQUE A TROIS DIMENSIONS */

PROC G3D DATA=uel;
scatter taille*poids=age;
RUN;

QUIT;
