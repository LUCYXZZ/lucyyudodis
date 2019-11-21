a0 = 0;
b0 = 1;
errmax = 10^-5; 

f =@(x) 2*x^4 - 3*x ; 

[x,it] = fibOpt(a0,b0, errmax,f)

