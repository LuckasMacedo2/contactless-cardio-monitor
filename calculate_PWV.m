function [PWV, PTT, signalQuality, SNRDistal, SNRProximal] = .....
    calculate_PWV(block, f_sample, f_inter, filterFCC, dist) 
    % Calculates Pulse Wave Velocity (PWV) and Pulse Time Transit (PTT)
    % from two Photoplethysmography signals acquired from hand
    
    % Input:
    %   - block: Matrix containing raw signals in the two ROIs
    %   - f_sample: Sampling frequency of webcam (Normally 30 fps)
    %   - f_inter: Interpolation frequency (Normally 500 Hz)
    %   - filterFCC: Filter 
    %   - dist: Fisical distance between two ROIs
    % Output:
    %   - PWV: Local Pulse Wave Velocity
    %   - PTT: Local Pulse Transit Time
    %   - signalQuality: Quality of signal pos processing, feedback for
    %   user
    %   - SNRDistal: Signal Noise Relation (SNR) of distal signal
    %   - SNRProximal: Signal Noise Relation (SNR) of proximal signal
    
    % ---------------------- PWV and PTT ----------------------------------
    distal_signal = PWV_SignalProcessing(block(5,:), f_sample, f_inter, filterFCC);
    proximal_signal = PWV_SignalProcessing(block(2,:), f_sample, f_inter, filterFCC);    
    f_sample = f_inter;
    
    % ---- Peaks of signals ----
    ratio = .75;
    % findpeaks -> looks for the signal peaks and returns one vector 
    % containing the peaks and another the index at which the peak occurs.
    [proximalPeaks, proximalLocks] = findpeaks(proximal_signal,f_sample,'MinPeakProminence',std(proximal_signal)*ratio); 
    [proximalPeaks, proximalLocks] = findpeaks(proximal_signal,f_sample,'MinPeakProminence',std(proximal_signal)*ratio,'MinPeakDistance', mean(diff(proximalLocks))*.7); 
    [distalPeaks, distalLocks] = findpeaks(distal_signal,f_sample,'MinPeakProminence',std(distal_signal)*ratio); 
    [distalPeaks, distalLocks] = findpeaks(distal_signal,f_sample,'MinPeakProminence',std(distal_signal)*ratio,'MinPeakDistance', mean(diff(distalLocks))*.7); 
   
 
    % ---- Customized algorithm (SmartPeaks) ----
    % Calculates the difference in t between the systolic and diastolic peaks to calculate PWV
    % Difference between the number of critical peaks

    if abs(size(proximalLocks,2) - size (distalLocks,2)) > 3
        sizeDiff = 3;
    else
        sizeDiff = abs(size(proximalLocks,2) - size (distalLocks,2));
    end
    timeDiff = 0.1;
    n = 1;
    
    % Custom Algorithm
    % Sees the difference of t and stores it in another vector
    % l -> value on the x axis
    % p -> value on the y axis
    proximalLocks2 = []; distalLocks2 = []; proximalPeaks2 = []; distalPeaks2 = [];
    
    if size(proximalLocks,2) <= size(distalLocks,2)
        for i = 1 : size(proximalLocks,2)
            if i - sizeDiff <=0
                for j = 1 : i + sizeDiff
                   if abs(proximalLocks(1,i)-distalLocks(1,j)) <= timeDiff
                        proximalLocks2(1,n) = proximalLocks(1,i);
                        distalLocks2(1,n) = distalLocks(1,j);
                        proximalPeaks2(1,n) = proximalPeaks(1,i);
                        distalPeaks2(1,n) = distalPeaks(1,j);
                        n = n+1;
                   end
                end
            elseif i + sizeDiff >= size(proximalLocks)
                for j = i - sizeDiff : size(proximalLocks)
                    if abs(proximalLocks(1,i)-distalLocks(1,j)) <= timeDiff
                        proximalLocks2(1,n) = proximalLocks(1,i);
                        distalLocks2(1,n) = distalLocks(1,j);
                        proximalPeaks2(1,n) = proximalPeaks(1,i);
                        distalPeaks2(1,n) = distalPeaks(1,j);
                        n = n+1;
                    end
                end
            else
                for j = i - sizeDiff : i+ sizeDiff
                    if abs(proximalLocks(1,i)-distalLocks(1,j)) <= timeDiff
                        proximalLocks2(1,n) = proximalLocks(1,i);
                        distalLocks2(1,n) = distalLocks(1,j);
                        proximalPeaks2(1,n) = proximalPeaks(1,i);
                        distalPeaks2(1,n) = distalPeaks(1,j);
                        n = n+1;
                    end
                end
            end
        end
    else
        for i = 1 : size(distalLocks,2)
            if i - sizeDiff <=0
                for j = 1 : i + sizeDiff
                    if abs(distalLocks(1,i)-proximalLocks(1,j)) <= timeDiff
                        distalLocks2(1,n) = distalLocks(1,i);
                        proximalLocks2(1,n) = proximalLocks(1,j);
                        distalPeaks2(1,n) = distalPeaks(1,i);
                        proximalPeaks2(1,n) = proximalPeaks(1,j);
                        n = n+1;
                    end
                end
            elseif i + sizeDiff >= size(distalLocks)
                for j = i - sizeDiff : size(distalLocks,2)
                    if abs(distalLocks(1,i)-proximalLocks(1,j)) <= timeDiff
                        distalLocks2(1,n) = distalLocks(1,i);
                        proximalLocks2(1,n) = proximalLocks(1,j);
                        distalPeaks2(1,n) = distalPeaks(1,i);
                        proximalPeaks2(1,n) = proximalPeaks(1,j);
                        n = n+1;
                    end
                end
            else
                for j = i - sizeDiff : i + sizeDiff
                    if abs(distalLocks(1,i)-proximalLocks(1,j)) <= timeDiff
                        distalLocks2(1,n) = distalLocks(1,i);
                        proximalLocks2(1,n) = proximalLocks(1,j);
                        distalPeaks2(1,n) = distalPeaks(1,i);
                        proximalPeaks2(1,n) = proximalPeaks(1,j);
                        n = n+1;
                    end
                end
            end
        end
    end
    n = n-1;
            
    % --- Approximation Test ---
    % t (time) of pulse transit
    t = distalLocks2-proximalLocks2;
    PTT = sum(abs(t))/n; % Average time difference between peaks
    
    % Pulse Wave Velocity
    PWV = dist / PTT;
    % ---------------------- PWV and PTT ----------------------------------
    
    % Calculates SNR signals
    SNRDistal = snr(distal_signal, f_sample);
    SNRProximal = snr(proximal_signal, f_sample);
    
    aux = min([SNRDistal SNRProximal]);
    if aux > 0
        signalQuality = 'Excellent';
    else
        if aux > -2 & aux < 0
            signalQuality = 'Good';
        else
            signalQuality = 'Bad';
        end
    end
    
    % Generates graproximalPeakss to the report.
    % All figures are save in "Temp" folder
    generateGraphs(proximal_signal, proximalPeaks2, proximalLocks2, ....
                        distal_signal, distalPeaks2, distalLocks2, ....
                        f_sample, n);
                    
    
end

% Graphs for report generation
function generateGraphs(proximalSignal, peaksProx, locsProx, ....
                        distSignal, peaksDist, locsDist, ....
                        f_sample, n)
    
% ----------------- PPG and peaks graph -----------------------------------
    % Arranges the peak values to stay on the signal
%     PP = PPG_Proximal(fix(LP * f_sample));
%     PD = PPG_Distal(fix(LD * f_sample));

    figure('Name','PPG_Peaks_Graph', 'visible','off');
    
    hold on;
    % Proximal Graph
    x = linspace(0, size(proximalSignal,2)/f_sample, size(proximalSignal,2));
    plot(x, proximalSignal);
    plot(locsProx, peaksProx, 'v');

    % Distal Graph
    plot(x, distSignal);
    plot(locsDist, peaksDist, 'v');
    
    % Number of proximal and distal peaks are the same, it's
    % size(peaksProx, 2) == size(peaksDist, 2), due to smart peaks
    % algorithm
    
    legend('Sinal Proximal', 'Picos Sinal Proximal', 'Sinal Distal', ....
           sprintf(['Picos Sinal Distal', newline, 'Nº de picos: ', ....
           num2str(size(peaksProx, 2))]));
    xlabel('Tempo (s)');
    ylabel('Amplitude Normalizada');
    
    title('Sinal Fotopletismográfico - Proximal e Distal');
    hold off;
    
    saveas(gcf, 'Temp/signalGraph.png');
    close 'PPG_Peaks_Graph';
% ----------------- PPG and peaks graph -----------------------------------

% ----------------- Time difference Graph ---------------------------------
     figure('Name','Time_Diff', 'visible','off');
     
     t = locsDist - locsProx;
     y = sum(abs(t))/n;
     
     hold off;
     plot(t, '-*', 'lineWidth', 2);
     line([0 size(locsDist, 2)], [y y], 'Color', 'r', 'lineWidth', 2);
     legend('Diferença de tempo entre os picos', sprintf(['TTP Local: ', num2str(y*1000), ' ms']));
     title('Diferença de tempo entre os picos (Distal - Proximal)');
     xlabel('Indice do vetor de tempo');
     ylabel('Diferença de tempo (s)');
     
     saveas(gcf, 'Temp/timeDifferenceGraph.png');
     close 'Time_Diff';
% ----------------- Time difference Graph ---------------------------------

% ----------------- Phase difference Graph --------------------------------
% Uses Hilbert Transformation to this.
    
    proxHil = hilbert(proximalSignal);
    proxHilPhase = deg2rad(unwrap(angle(proxHil)));
    
    distHil = hilbert(distSignal);
    distHilPhase = deg2rad(unwrap(angle(distHil)));
    
    figure('Name','Phase_Diff', 'visible','off');  
    
    hold on;
    plot(x, proxHilPhase, 'lineWidth', 2);
    plot(x, distHilPhase, 'lineWidth', 2);
    plot(x, distHilPhase - proxHilPhase, 'lineWidth', 2);
    
    xlabel('Tempo (s)');
    ylabel('Fase (rad)');
    legend('Fase - Sinal Proximal', 'Fase - Sinal Distal', ....
        'Diferença de fase', 'Location', 'northwest');
    title('Diferença de Fase Entre os Sinais - Distal e Proximal');
    hold off;

    
    saveas(gcf, 'Temp/phaseDifferenceGraph.png');
    close 'Phase_Diff';
% ----------------- Phase difference Graph --------------------------------

end