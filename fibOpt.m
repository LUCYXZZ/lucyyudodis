function [x,n] = fibOpt( a0,b0, errmax, f)

n = 0;
i = 2; 
h = (b0-a0) / errmax;
while (true)
   
    if ( h>= findFib(i+1) && h<=findFib(i+2) )
       n = i;
       break;
    end
    i = i+1;
end


x1 = a0 + fibonacci(n-2)/fibonacci(n) * (b0-a0);
x2 = b0 + a0 - x1;

for i = 1:n
    if(f(x1)<f(x2))
        % a0 ostaje
        b0 = x2;
        x2 = x1;
        x1 = a0 + b0 - x2;
    elseif(f(x1)>f(x2))
        a0 = x1;
        % b0 ostaje
        x1 = x2;
        x2 = a0+b0-x1;
    end
end

if(f(x1)<f(x2))
    x = x1;
else
    x = x2;
end

end




