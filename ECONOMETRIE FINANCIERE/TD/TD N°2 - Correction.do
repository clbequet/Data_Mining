
describe

gen t=_n
tsset t

gen date = m(1990m1) + _n - 1 
format date %tm 
tsset date 

destring austra, replace

/* I) Histogramme, sd, test de normalité.....*/

qui tsline nasdaq, name(usa, replace) 
qui tsline austra, name(australie, replace) 
 
graph combine usa australie, cols(2) name(all1, replace)

qui histogram nasdaq, normal name(nas, replace) 
qui histogram austra, normal name(a, replace) 
 
graph combine nas a , cols(2) name(all2, replace) 

summarize nasdaq, detail
sktest nasdaq
* si prob < 5% pas normale


/* II) Mise en évidence de la volatilité avec NASDAQ */

arch nasdaq, arch(1)
predict htarch, variance 
tsline htarch, name(g1, replace)


/* Question 1 : refaire I et II avec les autres variables */
/* Question 2 : II avec combinaison de 4 graphiques */
/* Question 3 : refaire tout avec r (rendement) */
/* Question 4 : idem avec bb. Comentaires ?  */

/* Question 1 : refaire I et II avec les autres variables */
* I)

qui tsline nasdaq, name(usa, replace) 
qui tsline austra, name(australie, replace) 
qui tsline cac40, name(france, replace) 
qui tsline nikkei, name(japan, replace) 
graph combine usa australie france japan, cols(2) name(all3, replace)

qui histogram nasdaq, normal name(nas, replace) 
qui histogram austra, normal name(a, replace) 
qui histogram cac40, normal name(f, replace) 
qui histogram nikkei, normal name(nk, replace) 
graph combine nas a f nk, cols(2) name(all4, replace) 


summarize nasdaq austra cac40 nikkei, detail
sktest nasdaq austra cac40 nikkei

*II)

arch nasdaq, arch(1)
predict htarch1, variance
tsline htarch1, name(g1nasdaq, replace) title("nasdaq")

arch austra, arch(1)
predict htarch2, variance 
tsline htarch2, name(g2austra, replace) title("austra")

arch cac40, arch(1)
predict htarch3, variance 
tsline htarch3, name(g3cac40, replace) title("cac40")

arch nikkei, arch(1)
predict htarch4, variance 
tsline htarch4, name(g4nikkei, replace) title("nikkei")

/* Question 2 : II avec combinaison de 4 graphiques */

graph combine g1nasdaq g2austra g3cac40 g4nikkei, cols(2) name(all5, replace) 


/* Question 3 : refaire tout avec r (rendement) */

gen r1=D.nasdaq
gen r2=D.austra
gen r3=D.cac40
gen r4=D.nikkei

*I)

qui tsline r1, name(Dusa, replace) 
qui tsline r2, name(Daustralie, replace) 
qui tsline r3, name(Dfrance, replace) 
qui tsline r4, name(Djapan, replace) 
graph combine Dusa Daustralie Dfrance Djapan, cols(2) name(all6, replace)

qui histogram r1, normal name(Dnas, replace) 
qui histogram r2, normal name(Da, replace) 
qui histogram r3, normal name(Df, replace) 
qui histogram r4, normal name(Dnk, replace) 
graph combine Dnas Da Df Dnk, cols(2) name(all7, replace) 


summarize r1 r2 r3 r4, detail
sktest r1 r2 r3 r4

*II)

arch r1, arch(1)
predict htarch11, variance
tsline htarch11, name(g11nasdaq, replace) title("nasdaq")

arch r2, arch(1)
predict htarch22, variance 
tsline htarch22, name(g22austra, replace) title("austra")

arch r3, arch(1)
predict htarch33, variance 
tsline htarch33, name(g33cac40, replace) title("cac40")

arch r4, arch(1)
predict htarch44, variance 
tsline htarch44, name(g44nikkei, replace) title("nikkei")


graph combine g11nasdaq g22austra g33cac40 g44nikkei, cols(2) name(all8, replace)

/* Question 4 : idem avec bb. Commentaires ?  */

qui tsline bb, name(boule, replace) 
qui histogram bb, normal name(boulehisto, replace) 

summarize bb, detail
sktest bb

arch bb, arch(1)
predict hbb1, variance
tsline hbb1, name(hbb, replace) title("bb")


gen rbb=D.bb
qui tsline rbb, name(Dboule, replace) 
qui histogram rbb, normal name(Dboulehisto, replace) 

summarize rbb, detail
sktest rbb

arch rbb, arch(1)
predict hrbb1, variance
tsline hrbb1, name(hDbb, replace) title("Dbb")





