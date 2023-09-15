?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

?   ENQUETE SUR LA PROBABILITE DE REUSSITE DES ETUDIANTS 

?             TOUTES FILIERES                            
?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

NAME PROBIT;
SET nobs=1*114;
SMPL 1 nobs;

?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

?                       ***********************
?                       * LECTURE DES DONNEES *
?                       ***********************

READ(FILE='reussite.xls') @id Y sexe tc lhab age obac meanbac baces bacs
etp bourse trav nbpf bur priv  p1 p2 p3 p4 p5 p6 p7 p8 m1 m2 m3 m4 m5 m6 m7 m8;


?XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
?
REGOPT(pvprint,stars) all;

PROBIT Y c sexe ;?tc lhab age obac meanbac baces bacs etp bourse trav
?nbpf bur priv  p2 p3 p4 p5 p6 p8 m1;

PLOT(preview) y @fit;
PRINT y @fit;

PROBIT 	Y sexe tc lhab age obac meanbac baces bacs
etp bourse trav nbpf bur priv  p2 p3 p4 p5 p6 p8 m1 m2 m3 m4 m5 m6 m7 m8;

print  @t;

?WRITE(file='sortie.xls') @coef;
END;
