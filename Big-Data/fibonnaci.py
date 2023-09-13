#!\bin\env python3


#Exo ge1

"""
def fibo():
    x = 0
    y = 1
    yield x
    yield y
    while True:
        x,y = y, x+y
        yield [x,y]
        
suite = fibo()
for i in suite:
    print(i)
    if i > 20:
        break

"""

#Exo ge2

"""
from datetime import datetime
import time

def chrono():
    debut=datetime.now()
    while True:
        s=datetime.now()- debut
        yield s
        
mon_chrono = chrono()
next(mon_chrono)         
time.sleep(5)
print(next(mon_chrono))  
time.sleep(2)
print(next(mon_chrono))  
"""

#Exo ge3


"""
def chercher(n = None):
    with open("/usr/share/dict/words", "r") as f:
        for line in f:
            mot=line.replace("\n","")
            if n :
                if type(n)== int:
                    if mot != "" and len(mot)== n:
                        inverse=mot[::-1]
                        if mot == inverse:
                            yield mot

                elif type(n)== list:
                    for i in range(len(n)):
                        if mot != "" and len(mot)== n[i]:
                            inverse=mot[::-1]
                            if mot == inverse:
                                yield mot
            else:
                if mot != "" and len(mot)>1:
                    inverse=mot[::-1]
                    if mot == inverse:
                        yield mot

def palin(n):
    try:
        return next(chercher.h[n])
    except KeyError:
        palin.h[n] = chercher(n)
        return next(palin.h[n])
"""

"""
for i,c in enumerate(chercher()):
    print(c)
    if i > 20:
        break
print('\n')
for i,c in enumerate(chercher(5)):
    print(c)
    if i > 20:
        break

"""

"""
for i in p:
    print(i)


for i in range(20):
  for j in [5,6,7]:
    if randrange(10)<7:
      try:
        print(j,palind(j))
      except StopIteration:
        print(f"plus de palindrome de {j} lettres")
"""



def termes(n):
    y = [1] * n
    yield y
    while y[0] != n-1:
        if y[-1] <= 2:
            y[-2] = y[-2] +1
            y[-1] = y[-1] -1
            if y[-1] == 0:
                del y[-1]
        else:
            y[-2] = y[-2] +1
            m = y[-1] -2
            y[-1] = 1
            for i in range(m):
                y.append(1)
        yield y

suite = termes(7)
k = 0
for i in suite:
    print(i)
    if k == 80:
        break
    k +=1