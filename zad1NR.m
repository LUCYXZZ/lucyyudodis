syms x
f=     2*x^4 - 3*x ; 

x0 = 1;
dfdt = diff(f,x);
dfdtt = diff(dfdt,x);
dfdt = matlabFunction(dfdt);
dfdtt = matlabFunction(dfdtt);

[x,it] = newraps(x0, dfdt, dfdtt, 10^(-2) ) 