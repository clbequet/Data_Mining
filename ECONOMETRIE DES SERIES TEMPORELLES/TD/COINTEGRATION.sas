PROC IMPORT OUT= WORK.TD1                                                                                                           
            DATAFILE= "D:\SERVEUR MASTER IDEE 2022-2023\
MASTER 1 IDEE\ECONOMETRIE DES SERIES TEMPORELLES\TD\
data1963-2021.xls"                        
            DBMS=xls;                                                                                                     
     GETNAMES=YES;                                                                                                                      
RUN;                                                                                                                                    
PROC PRINT; 
RUN; 
PROC CONTENTS;                                                                                                                          
RUN;                                                                                                                                    
/* QUESTION 0 : TRANSFORMATIONS DES VARIABLES */                                                                                          
/* transformations en logarithmes népériens*/                                                                                                      
                                                                                                                                        
DATA travail;                                                                                                                              
SET td1;  
time=_n_; 
lypy=log(ypy);                                                                                                                          
LRD = log(rd);
lcpc =log(cpc);                                                                                                                         
lpc=log(pc);
dtcho=dif(tcho);
dlypy=dif(lypy);

/*if time<50 then output;  sous-période */
RUN;
 

proc autoreg data = TRAVAIL;
   *model LCPC = / stationarity =(adf =12) ;
   *model LCPC = /STATIONARITY=( KPSS );
model lcpc= /STATIONARITY=( ADF=(12),ERS=(12),
KPSS=(KERNEL=QS AUTO), NP=(12), PHILLIPS=(12) ) ;
   *model LCPC = /STATIONARITY=( PHILLIPS=( 1 2 12 )) ;
OUTPUT OUT=file1  R=res1; 
run;


PROC REG data=travail;
model lcpc = lrd tcho lpc;
OUTPUT out=file2 p=yhat2 R=res2;  
RUN;



proc autoreg data = file2;
   model res2 = / stationarity =(adf =12) ;
   *model res1 = /STATIONARITY=( KPSS );
   *model res1 = /STATIONARITY=( PHILLIPS=( 12 )) ; 
run;




proc varmax data=travail;
model lcpc lrd tcho lpc / p=12 cointtest;
RUN;




END;
