#!\bin\env python3

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