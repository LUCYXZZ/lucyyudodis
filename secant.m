function [x,it] = secant(x0, x1, df, errmax)

xsl = inf;
xtr = x1;
xpr = x0;
it = 0;
pom = x1;
dfdt = df;

dfdtt =( feval(df,xtr) - feval (df,xpr) )  /  (xtr - xpr);

while ( abs(xsl-xtr) > errmax)
    xtr = pom;
    %x2   %x1               %x1      %x1   %x0                  %x1%
    xsl = xtr - feval(dfdt, xtr) * ( xtr - xpr) / ( feval(dfdt, xtr) - feval(dfdt, xpr));
    xpr = xtr;
    pom = xsl;
    
    it = it+1;
    
    
end

x = xsl;

end