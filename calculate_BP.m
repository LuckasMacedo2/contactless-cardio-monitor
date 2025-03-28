function [SBP, DBP, PWV, PTT] = calculate_BP(block, f_sample, filterFCC, BH, gender)

%     block(1,:) = detrending(block(1,:)', 10)';
    block(2,:) = detrending(block(2,:)', 10)';
%     block(3,:) = detrending(block(3,:)', 10)';
%     block(4,:) = detrending(block(4,:)', 10)';
    block(5,:) = detrending(block(5,:)', 10)';
%     block(6,:) = detrending(block(6,:)', 10)';

    block_Forehead = block(2,:);%./sqrt(block(1,:).^2 + block(2,:).^2 + block(3,:).^2);
    block_Hand = block(5,:);%./sqrt(block(4,:).^2 + block(5,:).^2 + block(6,:).^2);

    % block_Forehead = block_Forehead';
    % block_Cheek = block_Cheek';

    block_Forehead = filter(filterFCC,1,block_Forehead);
    block_Hand = filter(filterFCC,1,block_Hand);

    block_Forehead = smooth(block_Forehead, 5)';
    block_Hand = smooth(block_Hand, 5)';

    % figure;
    % plot(block_Forehead);
    % hold on;
    % plot(block_Cheek);
    % hold off;

    % x = 0:size(block_Forehead,2)-1;
    % xx = linspace(0,size(block_Forehead,2)-1,(size(block_Forehead,2)/30)*500);
    % block_Forehead = spline(x,block_Forehead,xx);
 
    % x = 0:size(block_Cheek,2)-1;
    % xx = linspace(0,size(block_Cheek,2)-1,(size(block_Cheek,2)/30)*500);
    % block_Cheek = spline(x,block_Cheek,xx);
    % 
    % fp = [.75, 4];  % Bandpass frequencies
    % f = 500;
    % wp=(2/f).* fp;
    % filterFCC = fir1(128, wp);
    % block_Forehead = filter(filterFCC,1,block_Forehead);
    % block_Cheek = filter(filterFCC,1,block_Cheek);
            
    [aF,dF] = haart(block_Forehead,1);
    [aH,dH] = haart(block_Hand,1);

    % figure;
    % plot(aF);
    % hold on;
    % plot(aC);
    % hold off;

    mean_block_Forehead = mean(aF);
    mean_block_Cheek = mean(aH);

    std_block_Forehead = std(aF);
    std_block_Cheek = std(aH);

    block_Forehead = (aF' - mean_block_Forehead)/std_block_Forehead;
    block_Hand = (aH' - mean_block_Cheek)/std_block_Cheek;
 
    % figure;
    % plot(block_Forehead);
    % hold on;
    % plot(block_Cheek);
    % hold off;

    block_Forehead = diff(block_Forehead);
    block_Hand = diff(block_Hand);

    block_Forehead = smooth(block_Forehead, 5)';
    block_Hand = smooth(block_Hand, 5)';

%     figure;
%     plot(block_Forehead);
%     hold on;
%     plot(block_Cheek);
%     hold off;
    
    ratio = .75;
    [pF,lF] = findpeaks(block_Forehead,f_sample,'MinPeakProminence',std(block_Forehead)*ratio); 
    [pF,lF] = findpeaks(block_Forehead,f_sample,'MinPeakProminence',std(block_Forehead)*ratio,'MinPeakDistance', mean(diff(lF))*.7); 
    [pH,lH] = findpeaks(block_Hand,f_sample,'MinPeakProminence',std(block_Hand)*ratio); 
    [pH,lH] = findpeaks(block_Hand,f_sample,'MinPeakProminence',std(block_Hand)*ratio,'MinPeakDistance', mean(diff(lH))*.7); 

%     figure;
%     plot(linspace(0, size(block_Forehead,2)/fps, size(block_Forehead,2)),block_Forehead)
%     hold on
%     plot(lF,pF,'vr')
%     % hold off
%     % 
%     % figure;
%     plot(linspace(0, size(block_Cheek,2)/fps, size(block_Cheek,2)),block_Cheek)
%     % hold on
%     plot(lC,pC,'vb')
%     hold off

    if abs(size(lH,2) - size (lF,2)) > 3
        sizeDiff = 3;
    else
        sizeDiff = abs(size(lH,2) - size (lF,2));
    end

    timeDiff = 0.1;
    n = 1;

    if size(lH,2) <= size(lF,2)
        for i = 1 : size(lH,2)
            if i - sizeDiff <=0
                for j = 1 : i + sizeDiff
                   if abs(lH(1,i)-lF(1,j)) <= timeDiff
                        lH2(1,n) = lH(1,i);
                        lF2(1,n) = lF(1,j);
                        pH2(1,n) = pH(1,i);
                        pF2(1,n) = pF(1,j);
                        n = n+1;
                   end
                end
            elseif i + sizeDiff >= size(lH)
                for j = i - sizeDiff : size(lH)
                    if abs(lH(1,i)-lF(1,j)) <= timeDiff
                        lH2(1,n) = lH(1,i);
                        lF2(1,n) = lF(1,j);
                        pH2(1,n) = pH(1,i);
                        pF2(1,n) = pF(1,j);
                        n = n+1;
                    end
                end
            else
                for j = i - sizeDiff : i+ sizeDiff
                    if abs(lH(1,i)-lF(1,j)) <= timeDiff
                        lH2(1,n) = lH(1,i);
                        lF2(1,n) = lF(1,j);
                        pH2(1,n) = pH(1,i);
                        pF2(1,n) = pF(1,j);
                        n = n+1;
                    end
                end
            end
        end
    else
        for i = 1 : size(lF,2)
            if i - sizeDiff <=0
                for j = 1 : i + sizeDiff
                    if abs(lF(1,i)-lH(1,j)) <= timeDiff
                        lF2(1,n) = lF(1,i);
                        lH2(1,n) = lH(1,j);
                        pF2(1,n) = pF(1,i);
                        pH2(1,n) = pH(1,j);
                        n = n+1;
                    end
                end
            elseif i + sizeDiff >= size(lF)
                for j = i - sizeDiff : size(lF,2)
                    if abs(lF(1,i)-lH(1,j)) <= timeDiff
                        lF2(1,n) = lF(1,i);
                        lH2(1,n) = lH(1,j);
                        pF2(1,n) = pF(1,i);
                        pH2(1,n) = pH(1,j);
                        n = n+1;
                    end
                end
            else
                for j = i - sizeDiff : i + sizeDiff
                    if abs(lF(1,i)-lH(1,j)) <= timeDiff
                        lF2(1,n) = lF(1,i);
                        lH2(1,n) = lH(1,j);
                        pF2(1,n) = pF(1,i);
                        pH2(1,n) = pH(1,j);
                        n = n+1;
                    end
                end
            end
        end
    end

    n = n-1;

%     figure;
%     plot(linspace(0, size(block_Forehead,2)/f_sample, size(block_Forehead,2)),block_Forehead)
%     hold on
%     plot(lF2,pF2,'vr')
%     % hold off
%     % 
%     % figure;
%     plot(linspace(0, size(block_Hand,2)/f_sample, size(block_Hand,2)),block_Hand)
%     % hold on
%     plot(lH2,pH2,'vb')
%     hold off

PTT = sum(abs(lF2-lH2))/n;
if strcmp(gender,'Male')
    PTT2 = 0.174437+PTT;
    PWV = 1/PTT2;
    SBP = -721.1*PTT2 + 265.68;
    DBP = 16898*PTT2^2 - 6935.8*PTT2 + 782.57;
else
    PTT2 = 0.191194+PTT;
    PWV = 1/PTT2;
    SBP = -712.55*PTT2 + 263.52;
    DBP = -9258.9*PTT2^2 + 3531.2*PTT2 - 257.32;
end
end

