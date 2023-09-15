PROC IMPORT OUT= WORK.REUSSITE                                                                                                          
            DATAFILE= "M:\SERVEUR ECONOMETRIE 2021-2022\MASTER 2 ING ECO\
SERVEUR\ECONOMETRIE DES VARIABLES QUALITATIVES\DATA\REUSSITESAS.xls"                        
            DBMS=xls REPLACE;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN; 

/* MODELES A CHOIX BINAIRE */
/***************************/

proc contents;					
title 'Contenu du fichier REUSSITESAS.XLS';
run;
proc print data=REUSSITE;
run;
proc means; 						
title 'Statistiques de base';
run;
/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */

/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* S1: le modèle  PROBIT  */

proc qlim data=reussite outest=estim method=QUANEW;			
model y = sexe lhab age tc obac meanbac baces bacs etp bourse trav etp bourse trav nbpf bur priv  p2 p3 p4 p5 p6 p8 m1 m2 m3 m4 m5 m6 m7 m8/discrete; 			    * discrete pour probit;
output out=probitout xbeta marginal;
title 'Estimations Probit';
run;

/*METHOD=CONGRA DBLDOG NMSIMP NEWRAP NRRIDG QUANEW TRUREG*/

proc print data=probitout; 
title 'Sortie du probit';
run;

