
describe, numbers

gen t=_n
tsset t

gen date = m(1990m1) + _n - 1 
format date %tm 
tsset date 

destring austra, replace

/* I) Histogramme, moyenne, test de normalité.....sur NASDAQ*/

qui tsline nasdaq, name(usa, replace) 

*qui tsline austra, name(australie, replace) 
*graph combine usa australie, cols(2) name(all1, replace)

qui histogram nasdaq, normal name(nas, replace) 

*qui histogram austra, normal name(a, replace) 
*graph combine nas a , cols(2) name(all2, replace) 

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
/* Question 4 : idem avec bb. Commentaires ?  */




















