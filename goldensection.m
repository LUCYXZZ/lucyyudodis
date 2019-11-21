function [x] = goldensection(a0, b0, f,  itMax)

while(true) 


c = 3/2 - sqrt(5)/2;

x1 = a0 + c* (b0 - a0);
x2 = a0 + b0 - x1; 

for i=1:itMax
    
    if ( f(x1) < f(x2))
        b0 = x2;
        x2=x1;
        x1 = a0+b0 - x2;
    else
        
        a0 = x1;
        x1 = x2;
        x2 = a0 + b0 - x2;
        
    end
    
end

if (f(x1) < f(x2) )
    x = x1;

else
    x = x2;
end

end
