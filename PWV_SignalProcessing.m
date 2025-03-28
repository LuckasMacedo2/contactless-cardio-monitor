function sinal = PWV_SignalProcessing(block, f_sample, f_inter, filterFCC)
    % ---- Impaired Blocks ----
     % High Pass Filter
     % Cutoff frequency 0.059 (0.33 Hz)
     % Removes frequencies below 0.3 Hz (caused by the movement of the
     % user)
    sinal = detrending(block', 10)';
    
    % ----- Normalizes the signal ----
    sinal = (sinal - mean(sinal,2))/std(sinal,0,2);    
    
    % ----- Filters the signal ----
    sinal = filter(filterFCC,1,sinal);
    
    % ---- Interpolation ----
    sinal = interpolation(sinal, f_sample, f_inter);
end