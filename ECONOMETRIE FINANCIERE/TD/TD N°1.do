/* http://www.stata-press.com/data/r15/ts.html */


/* LES MODELES ARCH */
/* Exemple 1 
U.S. Wholesale Price Index (WPI) (Enders 2004)
 Data trimestrielle 1960q1 a 1990q4 */

use http://www.stata-press.com/data/r15/wpi1
*webuse wpi1
describe, numbers
regress D.ln_wpi

/*LM test pour effet ARCH
si PV < .05 on rejette H0 */
estat archlm, lags(1)

arch D.ln_wpi, arch(1) garch(1)

/*Le modele est : 
yt = 0.0061 + et
avec s2t = 0.436 e2t-1 + 0.454 s2t-1*/





/* Exemple 2: ARCH model avec processus  ARMA */

arch D.ln_wpi, ar(1) ma(1 4) arch(1) garch(1)

/* le modele est : voir CORRECTION TD1.PDF */

* NB : le coefficient de arch(1) pas significatif
* mais le modele constitué DE [arch(1) + garch(1)] est robuste :
* cf la valeur du prob chi2 <.05:

test [ARCH]L1.arch [ARCH]L1.garch
  
  
  
  
/* Example 3: Asymmetric effects (hausse/baisse)—EGARCH model */

arch D.ln_wpi, ar(1) ma(1 4) earch(1) egarch(1) 

/* voir CORRECTION TD1.PDF */






/* Example 4: Asymmetric power ARCH model avc erreur loi normale*/
*Dow Jones Industrial Average, variable dowclose

use http://www.stata-press.com/data/r15/dow1, clear
describe, numbers
list in 1/8
generate dayofwk = dow(date)
list date dayofwk t ln_dow D.ln_dow in 1/200

arch D.ln_dow, ar(1) aparch(1) pgarch(1)






/* Exemple 5 : ARCH model avec nonnormal erreurs */

arch D.ln_dow, ar(1) aparch(1) pgarch(1) distribution(ged)





