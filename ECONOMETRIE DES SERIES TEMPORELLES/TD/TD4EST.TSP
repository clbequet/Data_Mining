?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? PROGRAMME TD4 ECONOMETRIE DES SERIES TEMPORELLES                                      
?XXXXXXXXXXXXXXXXX
? 
? PREVISION DU TRAFIC VOYAGEUR DE LA SNCF (SERIE TEMPORELLE)
?     PAR LA METHODE DE BOX-JENKINS
                                
?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
?                INITIALISATION DES PARAMETRES
?                XXXXXXXXXXXXXXXXXXXXXXXXXXXXX

OPTIONS MEMORY=2000;
NAME trafic;

? PARAMETRES A CHANGER UNIQUEMENT

SET TAILLE=216;	      ? Taille totale initiale de l'échantillon 
SET GROUPE=10;		  ? Choix du NB de DATA dans chaque sous-population
					  ? Ne pas oublier de compléter Ligne 51
SET SAISON=12;		  ? Valeur de la saisonnalité
SET	ESTIMATION=10;	  ? Taille de l'estimation (prévisions sur le passé)
SET PREVISION=36;	  ? NB DE PREVISIONS DANS LE FUTUR

? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

SET T=TAILLE ;             ? taille totale initiale de l'échantillon      
SET T1=T-1 ;               ? taille de l'échantillon -1    pour l ACF 0   OK
SET T2=ROUND(((T/2)-1));   ? taille de l'échantillon /2 -1 pour PACF  0   OK

SET NB=GROUPE;         ? choix du NB de DATA dans chaque sous-population  
SET NBFIN1=round((T/NB)+.5)-1;

SET GR1=NBFIN1-1;

SET NG2=NB;
SET NG3=NG2+NB;	   ? exemple de calcul :
SET NG4=NG3+NB;	   ? si NB= 10 il y aura 21 sous-populations (ROUND(216/10)-1)
SET NG5=NG4+NB;	   ? si NB=  7 il y aura 30 sous-populations (ROUND(216/ 7)-1)
SET NG6=NG5+NB;	   ? si NB= 23 il y aura  9 sous-populations (ROUND(216/23)-1)
SET NG7=NG6+NB;
SET NG8=NG7+NB;
SET NG9=NG8+NB;
SET NG10=NG9+NB;
SET NG11=NG10+NB;
SET NG12=NG11+NB;
SET NG13=NG12+NB;
SET NG14=NG13+NB;
SET NG15=NG14+NB;
SET NG16=NG15+NB;
SET NG17=NG16+NB;
SET NG18=NG17+NB;
SET NG19=NG18+NB;
SET NG20=NG19+NB;
SET NG21=NG20+NB;	? à continuer SI PLUS DE GROUPES


SET S=SAISON;              ? valeur de la saisonnalité  
SET SS=-S;				   ? valeur du retard saisonnier                  OK
SET S1=S+1;                ? valeur du début de l'échantillon   cvs       OK
SET S2=S1+1;               ? valeur du début de l'échantillon   dif1      OK
SET NBFIN2=S2+NB-1;
SET S3=S2+2;			   ? valeur du début de l'échantillon   dif2      OK
SET NBFIN3=S3+NB-1;
SET T3=T-S2-1;			   ? taille de l'échantillon -1     pour l ACF 1  OK
SET T4=ROUND((((T-S2)/2)-1));? taille de l'échantillon /2 -1 pour PACF 1  OK
SET T5=T-S3-1;			   ? taille de l'échantillon -1     pour l ACF 2  OK
SET T6=ROUND((((T-S3)/2)-1));? taille de l'échantillon /2 -1 pour PACF 2  OK

SET E1=T-ESTIMATION;       ? taille de l'estimation
SET E2=E1+1;               ? taille de l'estimation	+1	        		  OK

SET PREV=PREVISION;		   ? nombre de prévision        
SET E3=E2+PREV-1;		   ? fin de la prévision                          OK


?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? ATTENTION PROGRAMME SANS SAISONNALITE											  X
?                                                                                 X
SET NBB=groupe+1;													?			  X
SET NBBB=NBB+2;														?			  X
SET TT3=T-2;														?     OK	  X
SET TT4=ROUND((((TT3)/2)-1));										?	  OK	  X
SET TT5=TT3-1;														?	  OK	  X
SET TT6=ROUND((((TT5)/2)-1));										?	  OK	  X
SET EE1=T-ESTIMATION;       ? taille de l'estimation(à choisir ici 10)	          X
SET EE2=EE1+1;              ? taille de l'estimation	+1	        	  OK	  X
SET PREVV=PREVISION;	    ? nombre de prévision (à choisir ici 36)              X
SET EE3=EE2+PREVV-1;	    ? fin de la prévision                         OK	  X
?																				  X
? GOTO 100;               	? SI PAS DE SAISONNALITE RENDRE ACTIVE CETTE COMMANDE X								 X
?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
?                LECTURE ET GRAPHIQUE DES DONNEES BRUTES
?                XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FREQ N;
SMPL 1 T;

READ(file='TGV.XLS',format=excel);
SHOW serie;
GENR X = SNCF;		  ? VARIABLE
PLOT(PREVIEW,titl='DONNEES BRUTES : TRAFIC VOYAGEURS SNCF GR 1') X;

?WRITE(file='TRAFIC.XLS',format=excel) X;

?xxxxxxxxxxxxxxxxxxxxxxxx
? ETAPE 1: IDENTIFICATION
?xxxxxxxxxxxxxxxxxxxxxxxx

?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? RECHERCHE DE STATIONNARITE SUR LE SERIE BRUTE  (MOYENNE -VARIANCE)-ACF-PACF 
?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

? RECHERCHE DE LA MOYENNE ET DE LA VARIANCE PAR SOUS-POPULATION

FREQ N;
SMPL 1 NB;
MSD(noterse) X  X(NG2) X(NG3) X(NG4) X(NG5) X(NG6) X(NG7) X(NG8)
             X(NG9) X(NG10) X(NG11) X(NG12) X(NG13) X(NG14) X(NG15)
			 X(NG16) X(NG17) X(NG18) X(NG19) X(NG20) X(NG21) ;
FREQ N;
SMPL 1,NBFIN1;
UNMAKE @MEAN moy1;
UNMAKE @var var1;
PLOT(PREVIEW,titl='MOYENNES SUR DONNEES BRUTES: 21 PERIODES GR 2') moy1;
PLOT(PREVIEW,titl='VARIANCES SUR DONNEES BRUTES: 21 PERIODES GR 3') var1;

? RECHERCHE DES ACF ET PACF SUR DATA BRUTE AVEC CORRELOGRAMME
? ACF
FREQ N;
SMPL 1 T;
BJIDENT(NLAG=T1,NOPLOT,PLOTAC) X;

? Procedure pour visualiser le graphique ACF
PLOTAC;

? PACF
FREQ N;
SMPL 1 T;
BJIDENT(NLAGP=T2,NOPLOT,PLOTAC) X;

FREQ N;                        ? Transfert de data de matrice vers serie
SMPL 1,T2;
UNMAKE @pac PACF1;
GENR up1=1.96/sqrt(@nob);
GENR low1=-1.96/sqrt(@nob);
PLOT(PREVIEW,titl='PACF DONNEES BRUTES GR 5') PACF1 up1 low1 ;

?STOP;
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
? GRAPHIQUES MOYENNES,VARIANCES, ACF ET PACF SUR DATA DESAISONNALISEES LN et DIF 1
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FREQ N;
SMPL 1 T;                  
GENR lX = log(X);

SMPL S1 T;    
GENR lX12  = lX - lX(ss);

SMPL S2 T;? on perd une donnee de plus au debut
GENR D12LX = lX12 - lX12(-1); 

PLOT(PREVIEW,titl='DONNEES LN DIF1 ET DESAISONNALISEES 12 GR 6') d12LX;
print d12lX;

?write(file='sncfd1.XLS',format=excel) d12lX;
?stop;


? MOYENNES VARIANCES
FREQ N;
SMPL S2 NBFIN2;	 ? toujours groupes de 10
MSD(noterse) d12lX  d12lX(NG2) d12lX(NG3) d12lX(NG4) d12lX(NG5)
             d12lX(NG6) d12lX(NG7) d12lX(NG8) d12lX(NG9) d12lX(NG10)
			 d12lX(NG11) d12lX(NG12) d12lX(NG13) d12lX(NG14) d12lX(NG15)
			 d12lX(NG16) d12lX(NG17) d12lX(NG18) d12lX(NG19) d12lX(NG20) ;
FREQ N;
SMPL 1,GR1;
UNMAKE @MEAN moy2;
UNMAKE @var var2;
PLOT(PREVIEW,titl='MOYENNES SUR DONNEES LN DESAISONNALISEES 12 ET DIF1: 20 PERIODES GR 7') moy2;
PLOT(PREVIEW,titl='VARIANCES SUR DONNEES LN DESAISONNALISEES 12 ET DIF1: 20 PERIODES GR 8') var2;

? ACF
SMPL S2 T;
BJIDENT(NLAG=T3,NOPLOT,PLOTAC) d12LX;
PLOTAC;

? PACF
SMPL S2 T;
BJIDENT(NLAGP=T4,NOPLOT,PLOTAC) d12LX;
FREQ N;
SMPL 1,T4;
UNMAKE @pac PACF2;
GENR UP2=1.96/sqrt(@nob);
GENR LOW2=-1.96/sqrt(@nob);
PLOT(PREVIEW,titl='PACF DONNEES LN DESAISONNALISEES 12 ET DIF1 GR 10') PACF2 UP2 LOW2;

?STOP;

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
? GRAPHIQUE MOYENNES, VARIANCES, ACF ET PACF SUR DATA DESAISONNALISEES LN et DIF 2
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FREQ N;
SMPL S3 T;                                                  
GENR DD12lX = D12lX - 2*D12lX(-1) + d12lX(-2); 
PLOT(PREVIEW,titl='DONNEES DIF2 ET DESAISONNALISEES GR 11') dd12lX;

? MOYENNES VARIANCES
FREQ N;
SMPL S3 NBFIN3;
MSD(noterse) dd12lX  dd12lX(NG2) dd12lX(NG3) dd12lX(NG4) dd12lX(NG5)
             dd12lX(NG6) dd12lX(NG7) dd12lX(NG8) dd12lX(NG9) dd12lX(NG10)
			 dd12lX(NG11) dd12lX(NG12) dd12lX(NG13) dd12lX(NG14) dd12lX(NG15)
			 dd12lX(NG16) dd12lX(NG17) dd12lX(NG18) dd12lX(NG19) dd12lX(NG20) ;

FREQ N;
SMPL 1,GR1;
UNMAKE @MEAN moy3;
UNMAKE @var var3;
PLOT(PREVIEW,titl='MOYENNES SUR DONNEES LN DESAISONNALISEES 12 ET DIF2: 20 PERIODES GR 12') moy3;
PLOT(PREVIEW,titl='VARIANCES SUR DONNEES LN DESAISONNALISEES 12 ET DIF2: 20 PERIODES GR 13') var3;

? ACF
SMPL S3 T;
BJIDENT(NLAG=T5,NOPLOT,PLOTAC) dd12LX;
PLOTAC;

? PACF 
SMPL S3 T;
BJIDENT(NLAGP=T6,NOPLOT,PLOTAC) dd12LX;
FREQ N;
SMPL 1,T6;
UNMAKE @pac PACF3;
GENR UP3=1.96/sqrt(@nob);
GENR LOW3=-1.96/sqrt(@nob);
PLOT(PREVIEW,titl='PACF DONNEES LN DESAISONNALISEES 12 ET DIF2 GR 15') PACF3 UP3 LOW3;

?STOP;

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
?               L'ACF DETERMINE LE    q  DU MA:                                                                                      
?               LE PACF DETERMINE LE  p  DU AR:                   
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
? ETAPE 2: ESTIMATION DES PARAMETRES  (ET ETAPE 3)
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

?   INITIALISATION DES PARAMETRES

SET MA=1;  ? q   THETA
SET MAS=1; ? Q	 DELTA
SET AR=3;  ? p	 PHI
SET ARS=0; ? P	 GAMMA
SET d=1;   ? d
SET DS=1;  ? D

FREQ N;				   
SMPL 1 E1;             
                      
REGOPT(pvprint,stars) all;
? Les valeurs proviennent de l etape IDENTIFICATION
? la constante peut être mise : CONSTANT
BJEST(noplot,nocumplo,roots,NDIFF=d,NSDIFF=ds,NMA=ma,nsma=mas,nar=ar,nsar=ars,nspan=S) lX;
FORM(print) eq;

FREQ N;
SMPL S2 E1;
PLOT(PREVIEW,titl='DONNEES BRUTES ET DONNEES ESTIMEES GR 16') d12lX @FIT;

?xxxxxxxxxxxxxxxxxxxxxx
? GRAPHIQUE DES RESIDUS
?xxxxxxxxxxxxxxxxxxxxxx

SMPL S2 E1;            ?on perd 13 donnees au debut
PLOT(PREVIEW,titl='RESIDUS DE L ESTIMATION PAR BJ GR 17') @res;
?STOP;
?xxxxxxxxxxxxxxxxxxx
? ETAPE 4: PREVISION
?xxxxxxxxxxxxxxxxxxx

?(1) PREVISION SUR LA PERIODE D ECHANTILLON

smpl 1 E1;
BJFRCST(exp,plot,conbound=.95,NDIFF=d,NSDIFF=ds,NMA=ma,nsma=mas,nar=ar,nsar=ars,nspan=S)) lX;

smpl E2 T;            ? une donnee de plus pour le debut
print @fit @fitse;
ACTFIT X @FIT;           ? tests pour la prevision
genr upper=@fit+1.96*@fitse;
genr lower=@fit-1.96*@fitse;
PLOT(PREVIEW,titl=' PREVISIONS DANS ECHANTILLON ET INTERVALLES DE PREVISIONS GR 19') @fit X UPPER LOWER;

print @fit X UPPER LOWER;

?STOP;

?(2) PREVISION HORS PERIODE D ESTIMATION

smpl 1 T;
BJFRCST(exp,nhoriz=PREV,NDIFF=d,NSDIFF=ds,NMA=ma,nsma=mas,nar=ar,nsar=ars,nspan=S) lX;
smpl E2 E3;            ? une donnee de plus pour le debut

genr upper=@fit+1.96*@fitse;
genr lower=@fit-1.96*@fitse;												 
PLOT(PREVIEW,titl=' PREVISIONS HORS ECHANTILLON ET INTERVALLES DE PREVISIONS GR 21') @fit X UPPER LOWER;

GOTO 200;	 ? FIN DU PROGRAMME

? FIN DU PROGRAMME AVEC SAISONNALITE
? 
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

?   PROGRAMME SANS SAISONNALITE

? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
? GRAPHIQUES MOYENNES,VARIANCES, ACF ET PACF SUR DATA  LN et DIF 1
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
100 FREQ N;
SET SAISON=0;
SMPL 1 T;

READ(file='TRAFIC.XLS',format=excel);
GENR X = SNCF;	                 
GENR lX = log(X);

SMPL 2 T;? on perd une donnee de plus au debut
GENR DLX = lX- lX(-1); 

PLOT(PREVIEW,titl='DONNEES LN DIF1  GR 6bis') dLX;
print dlX;

? MOYENNES VARIANCES
FREQ N;
SMPL 2 NBB;	 ? toujours groupes de 10
MSD(noterse) dlX  dlX(NG2) dlX(NG3) dlX(NG4) dlX(NG5) dlX(NG6) 
           dlX(NG7) dlX(NG8) dlX(NG9) dlX(NG10) dlX(NG11) 
           dlX(NG12) dlX(NG13) dlX(NG14) dlX(NG15) dlX(NG16) 
           dlX(NG17) dlX(NG18) dlX(NG19) dlX(NG20) dlX(NG21);

FREQ N;
SMPL 1,NBFIN1;
UNMAKE @MEAN moy2;
UNMAKE @var var2;
PLOT(PREVIEW,titl='MOYENNES SUR DONNEES LN ET DIF1: 21 PERIODES GR 7bis') moy2;
PLOT(PREVIEW,titl='VARIANCES SUR DONNEES LN ET DIF1: 21 PERIODES GR 8bis') var2;

? ACF
SMPL 2 T;
BJIDENT(NLAG=TT3,NOPLOT,PLOTAC) dLX;
PLOTAC;

? PACF
SMPL 2 T;
BJIDENT(NLAGP=TT4,NOPLOT,PLOTAC) dLX;
FREQ N;
SMPL 1,TT4;
UNMAKE @pac PACF2;
GENR UP2=1.96/sqrt(@nob);
GENR LOW2=-1.96/sqrt(@nob);
PLOT(PREVIEW,titl='PACF DONNEES LN ET DIF1 GR 10bis') PACF2 UP2 LOW2;

?STOP;

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
? GRAPHIQUE MOYENNES, VARIANCES, ACF ET PACF SUR DATA LN et DIF 2
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

FREQ N;
SMPL 4 T;                                                  
GENR DDlX = DlX - 2*DlX(-1) + dlX(-2); 
PLOT(PREVIEW,titl='DONNEES DIF2 GR 11bis') ddlX;

? MOYENNES VARIANCES
FREQ N;
SMPL 4 NBBB;
MSD(noterse) ddlX  ddlX(NG2) ddlX(NG3) ddlX(NG4) ddlX(NG5)
             ddlX(NG6) ddlX(NG7) ddlX(NG8) ddlX(NG9) ddlX(NG10)
			 ddlX(NG11) ddlX(NG12) ddlX(NG13) ddlX(NG14) ddlX(NG15)
			 ddlX(NG16) ddlX(NG17) ddlX(NG18) ddlX(NG19) ddlX(NG20)
			 ddlX(NG21);

FREQ N;
SMPL 1,NBFIN1;
UNMAKE @MEAN moy3;
UNMAKE @var var3;
PLOT(PREVIEW,titl='MOYENNES SUR DONNEES LN ET DIF2: 21 PERIODES GR 12bis') moy3;
PLOT(PREVIEW,titl='VARIANCES SUR DONNEES LN ET DIF2: 21 PERIODES GR 13bis') var3;

? ACF
SMPL 4 T;
BJIDENT(NLAG=TT5,NOPLOT,PLOTAC) ddLX;
PLOTAC;

? PACF 
SMPL 4 T;
BJIDENT(NLAGP=TT6,NOPLOT,PLOTAC) ddLX;
FREQ N;
SMPL 1,TT6;
UNMAKE @pac PACF3;
GENR UP3=1.96/sqrt(@nob);
GENR LOW3=-1.96/sqrt(@nob);
PLOT(PREVIEW,titl='PACF DONNEES LN ET DIF2 GR 15bis') PACF3 UP3 LOW3;

? STOP;

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
?               L'ACF DETERMINE LE    q  DU MA:                                                                                      
?               LE PACF DETERMINE LE  p  DU AR:                   
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
? ETAPE 2: ESTIMATION DES PARAMETRES  (ET ETAPE 3)
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

?   INITIALISATION DES PARAMETRES

SET MA=1;  ? q
SET MAS=1; ? Q
SET AR=3;  ? p	
SET ARS=0; ? P
SET d=1;   ? d
SET DS=0;  ? D

FREQ N;				   ? Attention on garde 10 data pour la prévision
SMPL 1 EE1;            ? Attention : on perd des data
                       ? le logiciel le fait de lui-meme

REGOPT(pvprint,stars) all;
? Les valeurs proviennent de l etape IDENTIFICATION
? la constante peut être mise : CONSTANT
BJEST(noplot,nocumplo,roots,NDIFF=d,NSDIFF=ds,NMA=ma,nsma=mas,nar=ar,nsar=ars,nspan=S) lX;
FORM(print) eq;

FREQ N;
SMPL 2 EE1;
PLOT(PREVIEW,titl='DONNEES BRUTES ET DONNEES ESTIMEES GR 16bis') dlX @FIT;

?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
? NAR   represente  p   (PHI)	  NDIFF represente      d
? NSAR  represente  P   (GAMMA)	  NSDIFF represente     D
? NMA   represente  q   (THETA)	  NSPAN represente      s
? NSMA  represente  Q   (DELTA)
?xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
?
?xxxxxxxxxxxxxxxxxxxxxx
? GRAPHIQUE DES RESIDUS
?xxxxxxxxxxxxxxxxxxxxxx

SMPL 2 EE1;            ?on perd s donnees au debut
PLOT(PREVIEW,titl='RESIDUS DE L ESTIMATION PAR BJ GR 17bis') @res;
?STOP;
?xxxxxxxxxxxxxxxxxxx
? ETAPE 4: PREVISION
?xxxxxxxxxxxxxxxxxxx

?(1) PREVISION SUR LA PERIODE D ECHANTILLON

smpl 1 EE1;
BJFRCST(exp,plot,conbound=.95,NDIFF=d,NSDIFF=ds,NMA=ma,nsma=mas,nar=ar,nsar=ars,nspan=S)) lX;

smpl EE2 T;            ? une donnee de plus pour le debut
print @fit @fitse;
ACTFIT X @FIT;           ? tests pour la prevision
genr upper=@fit+1.96*@fitse;
genr lower=@fit-1.96*@fitse;
PLOT(PREVIEW,titl=' PREVISIONS DANS ECHANTILLON ET INTERVALLES DE PREVISIONS GR 19BIS') @fit X UPPER LOWER;

print @fit X UPPER LOWER;

?STOP;

?(2) PREVISION HORS PERIODE D ESTIMATION

smpl 1 T;
BJFRCST(exp,nhoriz=PREVV,NDIFF=d,NSDIFF=ds,NMA=ma,nsma=mas,nar=ar,nsar=ars,nspan=S) lX;
smpl EE2 EE3;            ? une donnee de plus pour le debut

genr upper=@fit+1.96*@fitse;
genr lower=@fit-1.96*@fitse;												 
PLOT(PREVIEW,titl=' PREVISIONS HORS ECHANTILLON ET INTERVALLES DE PREVISIONS GR 21BIS') @fit X UPPER LOWER;


? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? MACRO COMMANDE POUR GRAPHIQUE ACF

Proc PlotAC;
 local smpsav frqsav ub nac r acsq ub95% lb95%;
 copy @smpl smpsav;
 copy @freq frqsav;
 mat nac=nrow(@ac);
 supres smpl;
 freq n;
 smpl 1,nac;
 unmake @ac r;
 acsq = 0;
 smpl 2,nac;
 acsq = acsq(-1) + R(-1)**2;
 smpl 1,nac;
 ub = cnormi(1-.05/2)*sqrt((1+2*acsq)/nac);
 ub95%=ub;
 lb95%=-ub;
 plot(preview,origin,title="ACF with Bartlett SEs") R ub95% lb95%;
 freq frqsav;
 smpl smpsav;
endproc;

? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
? XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


END;










