
describe

gen t=_n
tsset t

gen date = m(1990m1) + _n - 1 
format date %tm 
tsset date 


/* SECTION 1 : ESTIMATION */
/* Q1 : Graphique des donnees brutes (CAC40) */

tw line cac40 t

/* Q2 : Calul rendements + graphique (R) */

gen lcac40=log(cac40)
gen r=D.lcac40
tw line r t

list cac40 lcac40  r

/*  Q3 et Q4 : estimations de differents modeles (le meilleur modele) */

/* MODELE ARCH */
arch r, arch(1)       /* gtolerance(999) difficult  technique(bfgs) iterate(100) {nr | bhhh | dfp | bfgs} */
estat ic              /* pour avoir la valeur des Informations Criteres */
estimates store eq1   /* pour sauvegarder les estimations */
           
arch r, arch(1/2)  
estimates store eq2
estimates table eq1 eq2  /* pour comparer les estimations */
estimate stats eq1 eq2   /* pour comparer des statistiques */


arch r, arch(1/5)            
arch r, arch(1/7)            
arch r, arch(1/8)	

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */		

/* MODELE GARCH */
arch r, arch(1) garch(1) 	
arch r, arch(1) garch(1/3) 	
arch r, arch(1/3) garch(1/3) 
arch r, arch(1/4) garch(1/4)	

/* MODELE ARCH MEAN */
arch r, archm arch(1)		
arch r, archm arch(1/7)		
arch r, archm arch(1/10)		

arch r, archm arch(1/3) archmexp(1/sqrt(r)) 

arch r, archm arch(1) archmexp(sqrt(r)) 				
arch r, archm arch(1/3) archmexp(sqrt(r))           
											

arch r, archm arch(1) archmexp(sqrt(r)) garch(1/2)           
arch r, archm arch(1) archmexp(sqrt(r)) arima(1,0,1)         
arch r, archm arch(1) archmexp(sqrt(r)) arima(1,0,1) garch(1/2) 

arch r, archm arch(1) archmexp(sqrt(r))   ar(1)			
arch r, archm arch(1) archmexp(sqrt(r))   ar(1/5)			
arch r, archm arch(1) archmexp(sqrt(r))   ar(1/10)		
arch r, archm arch(1) archmexp(sqrt(r))   ma(1)		
arch r, archm arch(1) archmexp(sqrt(r))   ma(1/10)		
arch r, archm arch(1) archmexp(sqrt(r))   ma(1/20)	
arch r, archm arch(1/2) archmexp(sqrt(r)) ma(1/20)	
arch r, archm arch(1) archmexp(sqrt(r))   ar(1/20) ma(1/20)

/* MODELE GARCH  avec AR & MA */
arch r, arch(1) garch(1) ar(1) 				
arch r, arch(1) garch(1) ar(1) ma(1)			
arch r, arch(1/3) garch(1/3) ar(1/3) 		
arch r, arch(1/3) garch(1/3) ar(1/3) ma(1/3)
arch r, arch(1) garch(1) ar(1/3) ma(1/3) 	
arch r, arch(1) garch(1) ar(1/10) ma(1/10) 	
arch r, arch(1) garch(1) ar(1/5) ma(1/5) 	

/* MODELE EGARCH  */
arch r, earch(1)										
arch r, earch(1)	 egarch(1)			     		
arch r, earch(1/5)	 egarch(1)							
arch r, earch(1/20)	 egarch(1)					
arch r, earch(1/10)	 egarch(1)						
arch r, earch(1/10)	 egarch(1/5)						
arch r,          	 egarch(1/5)					/* manque earch */

/* MODELE TARCH */

arch r, abarch(1)									
arch r, abarch(1/5)								
arch r, abarch(1) atarch(1)						
arch r, abarch(1) atarch(1) sdgarch(1)				
arch r, abarch(1) atarch(1) sdgarch(1/5)				

/* MODELE GJR */

arch r, arch(1) tarch(1)								
arch r, arch(1/5) tarch(1)								
arch r, arch(1/5) tarch(1/4)
arch r, arch(1) tarch(1) garch(1)				
arch r, arch(1/5) tarch(1/4) garch(1)	

/* MODELE SAARCH */

arch r, arch(1) saarch(1)						
arch r, arch(1/5) saarch(1)						
arch r, arch(1/5) saarch(1/4)	
arch r, arch(1) saarch(1) garch(1)		
arch r, arch(1/4) saarch(1/4) garch(1/4)		    
arch r, arch(1) saarch(1) ar(1) ma(1)				
arch r, arch(1/4) saarch(1/4) garch(1/4)	ar(1/4) ma(1/4)
arch r, arch(1/4) saarch(1/4) garch(1/4)	ar(1) ma(1)	    

/* MODELE PARCH */

arch r, parch(1)				                		
arch r, parch(1/4)				               
arch r, parch(1)	pgarch(1)			           	
arch r, parch(1/4) ar(1) ma(1)			         
arch r, parch(1) ar(1) ma(1)			            	

/* MODELE NARCH */

arch r, narch(1)				                		
arch r, narch(1/4)										                	
arch r, narch(1)	garch(1)	                		
arch r, narch(1)	garch(1/4)	                	
arch r, narch(1)	garch(1/4) ar(1) ma(1)         	

/* MODELE NARCHK */

arch r, narchk(1)				                	
arch r, narchk(1/4)				                
arch r, narchk(1/4) garch(1)				        
arch r, narchk(1/4) garch(1/4)			         
arch r, narchk(1) garch(1/4)		     	        

/* MODELE A-PARCH */

arch r, aparch(1)				                
arch r, aparch(1/4)				               
arch r, aparch(1/3)				                
arch r, aparch(1) pgarch(1)			            

/* MODELE NPARCH */

arch r, nparch(1)				                
arch r, nparch(1/2)				                
arch r, nparch(1/4)				                
arch r, nparch(1) pgarch(1)		
             
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* SECTION 2: PREVISION SUR LE PASSE */

/* Q5 : Previsions sur le passe */

arch r, arch(1)  /* Si ce modele est le meilleur */

predict frvar, variance /* variance : variance conditionnelle */
predict fry, y /* y : endogene*/

gen prevr=fry + sqrt(frvar)  /* endogene + racine(var cond) */

tw line frvar t 
tw line fry t
tw line r prevr t


/* Q6 : Previsions sous-echantillon */

arch r, arch(1)  /* Si ce modele est le meilleur */

predict frvar, variance /* variance : variance conditionnelle */
predict fry, y /* y : endogene*/

gen prevr=fry + sqrt(frvar)  /* endogene + racine(var cond) */

tw line frvar t in -100/l /* 100 dernieres observations  */
tw line fry t in -100/l 
tw line r prevr t in -100/l 

tw line frvar t in f/100 /* 100 premieres observations  */
tw line fry t in f/100
tw line r prevr t in f/100

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* SECTION 3: PREVISION SUR LE FUTUR */

/* Q7 : Prévision en N+1 */


tsappend,add(1)          /* le faire une seule fois */

predict frvar1, variance /* variance : variance conditionnelle */
predict fry1, y /* y : endogene*/

gen prevr1=fry1 + sqrt(frvar1)  /* endogene + racine(var cond) */

list r frvar1 fry1 prevr1  in -10/l  

  
/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  */


drop frvar fry  prevr
drop frvar1 fry1  prevr1




/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  */
/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  */
/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  */
/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* SECTION 2: PREVISION SUR LE PASSE */

/* Q5 : Previsions sur le passe */

arch r, archm arch(1) archmexp(sqrt(r)) garch(1/2)   /* Si ce modele est le meilleur1 16/02/2021 */
predict frvar, variance /* variance : variance conditionnelle */
predict fry, y /* y : endogene*/

gen prevr=fry + sqrt(frvar)  /* endogene + racine(var cond) */

tw line frvar t,name(mod1var,replace) 
tw line r prevr t,name(mod1prev,replace)


arch r, archm arch(1) archmexp(sqrt(r)) arima(10,0,10) gtolerance(999) difficult  technique(bhhh) iterate(100)
predict frvar2, variance /* variance : variance conditionnelle */
predict fry2, y /* y : endogene*/

gen prevr2=fry2 + sqrt(frvar2)  /* endogene + racine(var cond) */

tw line frvar2 t,name(mod2var,replace) 
tw line r prevr2 t,name(mod2prev,replace)

arch r, archm arch(1) archmexp(sqrt(r)) arima(5,0,5) gtolerance(999) difficult  technique(bhhh) iterate(100)
predict frvar3, variance /* variance : variance conditionnelle */
predict fry3, y /* y : endogene*/

gen prevr3=fry3 + sqrt(frvar3)  /* endogene + racine(var cond) */

tw line frvar3 t,name(mod3var,replace) 
tw line r prevr3 t,name(mod3prev,replace)

arch r, archm arch(1) archmexp(sqrt(r)) 
predict frvar4, variance /* variance : variance conditionnelle */
predict fry4, y /* y : endogene*/

gen prevr4=fry4 + sqrt(frvar4)  /* endogene + racine(var cond) */

tw line frvar4 t,name(mod4var,replace) 
tw line r prevr4 t,name(mod4prev,replace)

graph combine mod1var mod2var mod3var mod4var , cols(2) name(variance,replace) title("PREVISIONS var")
graph drop mod1var mod2var mod3var mod4var

graph combine mod1prev mod2prev mod3prev mod4prev , cols(2) name(prevision,replace) title("PREVISIONS finales")
graph drop mod1prev mod2prev mod3prev mod4prev




/* Q6 : Previsions sous-echantillon */

arch r, arch(1)  /* Si ce modele est le meilleur */

predict frvar, variance /* variance : variance conditionnelle */
predict fry, y /* y : endogene*/

gen prevr=fry + sqrt(frvar)  /* endogene + racine(var cond) */

tw line frvar t in -100/l /* 100 dernieres observations  */
tw line fry t in -100/l 
tw line r prevr t in -100/l 

tw line frvar t in f/100 /* 100 premieres observations  */
tw line fry t in f/100
tw line r prevr t in f/100

/* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
/* SECTION 3: PREVISION SUR LE FUTUR */

/* Q7 : Prévision en N+1 */

arch r, archm arch(1) archmexp(sqrt(r)) arima(10,0,10) gtolerance(999) difficult  technique(bhhh) iterate(100)
tsappend,add(50)          /* le faire une seule fois */

predict frvar1, variance /* variance : variance conditionnelle */
predict fry1, y /* y : endogene*/

gen prevr1=fry1 + sqrt(frvar1)  /* endogene + racine(var cond) */

list r frvar1 fry1 prevr1  in -60/l  

 drop frvar1 fry1 prevr1 
  
/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  */


drop frvar fry  prevr
drop frvar1 fry1  prevr1
drop frvar2 fry2  prevr2
drop frvar3 fry3  prevr3
drop frvar4 fry4  prevr4

/* xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  */



