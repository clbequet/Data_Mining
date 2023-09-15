PROC IMPORT OUT= WORK.etude5
            DATAFILE= "J:\SERVEUR ECONOMETRIE 2019-2020\
MASTER 1 SE\SERVEUR\MARKETING QUANTITATIF\
APPLICATION\ANALYSE SPECTRALE\nil.xls"
            DBMS=EXCEL REPLACE;
     GETNAMES=YES;
RUN;

proc print;
run;
proc contents data=etude5;
run;
DATA new;
SET etude5;
lnil=log(nil);
dlnil=dif(lnil);
RUN;


GOPTIONS reset=all; 
 SYMBOL1 i = join c = black;
 SYMBOL2 i = join c = redbold width=3 ;
proc gplot;
plot dlnil*date/overlay;
run;

		PROC GPLOT;                                                                                                                             
		PLOT (lnil hp)*date/overlay legend=legend1;                                                                                           
		SYMBOL interpol=join;                                                                                                                   
		TITLE color=RED height=2 font=times "GR1 : Graphique de séries temporelles";                                                   
		LEGEND1 value=(tick=1 'ln NIL' tick=2 'Ln HP');                                                         
		RUN; 

proc spectra data=new out=gg p s adjmean whitetest coef;
var dlnil;
weights 1 2 3 4 3 2 1 ;
*weights parzen .5 0;
run;

/*Smoothing Options :
specify the Bartlett kernel WEIGHTS BART
specify the Parzen kernel   WEIGHTS PARZEN
specify the quadratic spectral kernel WEIGHTS QS
specify the Tukey-Hanning kernel WEIGHTS TUKEY
specify the truncated kernel WEIGHTS TRUNCAT */


proc print data=gg;
run;
GOPTIONS reset=all; 
proc gplot data=gg;
symbol v=dot i=join c=black;
plot p_01*freq;
plot p_01*period;
plot s_01*freq;
plot s_01*period;
plot period*freq;
run;
proc gchart data=gg;
vbar p_01;
run;

proc gplot data=gg;
where period<30;
plot s_01*period/href=7 href=2;
run;

PROC SORT data=gg out=sortg;
BY descending p_01;
RUN;
PROC PRINT DATA=sortg;
var p_01 period cos_01 sin_01;
RUN;



