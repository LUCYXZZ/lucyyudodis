syms x
f = @(x) 2*x^3 - 3*x;

dfdt = diff(f,x);
dfdtt = diff(dfdt,x); 

dfdt = matlabFunction(dfdt);
dfdtt = matlabFunction(dfdtt);

[x,it] = secant(0, 1, dfdt, 10^-2)