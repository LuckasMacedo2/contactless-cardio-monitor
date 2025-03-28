function [lOUT1, pOUT1, lOUT2, pOUT2, n] = pttVectors(lIN1, pIN1,  .....
    lIN2, pIN2, sizeDiff, timeDiff)
% Author: Israel M B Souza
% E-mail: israel.mbrito@gmail.com
n = 1;

for i = 1 : size(lIN1,2)
    if i - sizeDiff <=0
        for j = 1 : i + sizeDiff
            if abs(lIN1(1,i)-lIN2(1,j)) <= timeDiff
                lOUT1(1,n) = lIN1(1,i);
                lOUT2(1,n) = lIN2(1,j);
                pOUT1(1,n) = pIN1(1,i);
                pOUT2(1,n) = pIN2(1,j);
                n = n+1;
            end
        end
    elseif i + sizeDiff >= size(lIN2,2)
        for j = i - sizeDiff : size(lIN2,2)
            if abs(lIN1(1,i)-lIN2(1,j)) <= timeDiff
                lOUT1(1,n) = lIN1(1,i);
                lOUT2(1,n) = lIN2(1,j);
                pOUT1(1,n) = pIN1(1,i);
                pOUT2(1,n) = pIN2(1,j);
                n = n+1;
            end
        end
    else
        for j = i - sizeDiff : i+ sizeDiff
            if abs(lIN1(1,i)-lIN2(1,j)) <= timeDiff
                lOUT1(1,n) = lIN1(1,i);
                lOUT2(1,n) = lIN2(1,j);
                pOUT1(1,n) = pIN1(1,i);
                pOUT2(1,n) = pIN2(1,j);
                n = n+1;
            end
        end
    end
end

n = n-1;