function [x3, it] = extremaSecant(df, x2, x1, errMax, itMax)

for it=1:itMax
    
    x3 = x2 - df(x2)/(df(x2)-df(x1)) * (x2-x1);
     if(abs(x3-x2)<errMax)
         return
     end
     
     x1 = x2;
     x2 = x3;
end

end