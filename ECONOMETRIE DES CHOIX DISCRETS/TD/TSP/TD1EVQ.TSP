?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

?   ENQUETE SUR LA PROBABILITE DE REUSSITE DES ETUDIANTS 

?             TOUTE FILIERE                            
?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

NAME PROBIT;
SET nobs=1*21;
SMPL 1 nobs;

?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

?                       ***********************
?                       * LECTURE DES DONNEES *
?                       ***********************

READ(FILE='transport.xls') ;
SHOW series;

?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
?
REGOPT(pvprint,stars) all;

OLSQ Y C X;
  PLOT(preview) y @fit;
PRINT y @fit;


PROBIT Y c x;

PLOT(preview) y @fit;
PRINT y @fit;
FORCST XB;
yprev=cnorm(xb);
millsr=y*dlcnorm(xb)+(1-y)*(-dlcnorm(-xb));

print xb yprev millsr;

?STOP;
LOGIT y c x;
PLOT(preview) y @fit;
PRINT y @fit;

END;
