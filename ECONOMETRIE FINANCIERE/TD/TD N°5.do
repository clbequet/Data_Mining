use http://www.stata-press.com/data/r15/stocks, clear
describe

tsline toyota, name(toy, replace) 
tsline nissan, name(nis, replace) 
tsline honda, name(hon, replace) 

graph combine toy nis hon, cols(2) name(all1, replace)

/* Section 1 : CCC Constant conditional correlation */

* Estimation

mgarch ccc (toyota nissan honda = L.toyota L.nissan L.honda, noconstant),arch(1) garch(1)

* prevision

tsappend, add(50)
predict H*, variance dynamic(2016)

tsline H*
tsline H* in -500/l, name(varcc,replace)

* NB : pensez à éliminer H*
drop H*

/* Section 2 : DCC Dynamic conditional correlation */
* estimation 
mgarch dcc (toyota nissan honda = L.toyota L.nissan L.honda, noconstant),arch(1) garch(1)

test _b[/Adjustment:lambda1] = _b[/Adjustment:lambda2] = 0.
* si lambda1=lambda2 =0 on retouve CCC si PV < 5%

* prévision
*tsappend, add(50)
predict H*, variance dynamic(2016)

tsline H*
tsline H* in -500/l, name(vardcc,replace)

* NB : pensez à éliminer H*
drop H*

/* Section 3 : VCC Varying conditional correlation */
* estimation 

mgarch vcc (toyota nissan honda = L.toyota L.nissan L.honda, noconstant), arch(1) garch(1)
test _b[/Adjustment:lambda1] = _b[/Adjustment:lambda2] = 0.

* prévision
*tsappend, add(50)
predict H*, variance dynamic(2016)

tsline H*
tsline H* in -500/l, name(varvcc,replace)

* NB : pensez à éliminer H*
drop H*

/* Section 4 : dvech — Diagonal vech */
* Estimation 

mgarch dvech (toyota nissan honda = L.toyota L.nissan L.honda, noconstant), arch(1)

* prévision
*tsappend, add(50)
predict H*, variance dynamic(2016)

tsline H*
tsline H* in -500/l, name(vardvech,replace)

graph combine varcc vardcc vardvech varvcc, cols(2) name(all2, replace)
