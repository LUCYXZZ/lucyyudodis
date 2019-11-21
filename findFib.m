function [x] = findFib(n)
if(n<1)
    x = NaN;
    return
    
elseif(n==1 || n==2)
    x = 1;
    return
else
   n1 = 1;
   n2 = 1;
   
   for i=3:n
      tmp = n2;
      n2 = n2+n1;
      n1 = tmp;
   end
   
   x = n2;
end








end