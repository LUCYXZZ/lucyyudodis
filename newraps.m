function [x, it] = newraps( x0 , df , dff , errmax) 

xsl = inf; 
xtr = x0;
it = 0;
pom = x0;

while (abs(xsl - xtr) > errmax)

xtr = pom;    
xsl = xtr - feval(df,xtr) / feval(dff,xtr);    
    
pom = xsl; 


 it = it + 1;
end

x = xtr;

end 