function [SpO2, signalQuality, SNRRed, SNRGreen] ....
    = calculate_SpO2(filter_SOS, g, signal1, signal2, window_size, f_sample)
    % Calculates Oxigen Saturation (SpO2) from one Photoplethysmography
    % signal acquired from hand in two color channels (red and green)
    
    % Input:
    %   - A, B, C, D: Filter Coeficients
    %   - signal1: Signal acquired from red channel. Plays the role of red
    %   wavelength
    %   - signal2: Signal acquired from green channel. Plays the role of
    %   infrared wavelength
    %   - window_size: Time in seconds of the window used to calculate the
    %   ratio value of the ratios (R) (Normally 4 s)
    %   - f_sample: Sampling frequency of webcam (Normally 30 fps)
    % Output:
    %   - SpO2: Oxigen Saturation
    %   - signalQuality: Quality of signal pos processing, feedback for
    %   user
    %   - SNRRed: Signal Noise Relation (SNR) of red channel
    %   - SNRGreen: Signal Noise Relation (SNR) of green channel
    
    [ac1, dc1, R1, filtered_signal1] = calculate_AC_DC_ratio(filter_SOS, g, signal1, window_size, f_sample);
    [ac2, dc2, R2, filtered_signal2] = calculate_AC_DC_ratio(filter_SOS, g, signal2, window_size, f_sample);
    
    R = R1./R2;
    RR = movmean(R, [3 10]);
    
    SpO2 = SpO2_RG(RR);
    
    generateGraphs(RR, SpO2, window_size, filtered_signal1, filtered_signal2, ....
        ac1, dc1, ac2, dc2, f_sample);
    
    % --- Signal Evaluation ---
    SNRRed = snr(filtered_signal1, f_sample);
    SNRGreen = snr(filtered_signal2, f_sample);

    aux = min([SNRRed SNRGreen]);
    if aux > 0
        signalQuality = 'Excellent';
    else
        if aux > -2 & aux < 0
            signalQuality = 'Good';
        else
            signalQuality = 'Bad';
        end
    end
end

function [ac, dc, R, filtered_signal] = calculate_AC_DC_ratio(filter_SOS, g, signal, window_size, f_sample)
    % Calculates ratio (R) from one Photoplethysmography
    % signal acquired from hand in two color channels (red and green)
    
    % Input:
    %   - filter_SOS: Filter Coeficients
    %   - g: filter gain;
    %   - signal1: Signal acquired from red channel. Plays the role of red
    %   wavelength
    %   - signal2: Signal acquired from green channel. Plays the role of
    %   infrared wavelength
    %   - window_size: Time in seconds of the window used to calculate the
    %   ratio value of the ratios (R) (Normally 4 s)
    %   - f_sample: Sampling frequency of webcam (Normally 30 fps)
    % Output:
    %   - R: Ratio of AC component and DC component of signal
    %   - filtered_signal: Filtered signal from low passa filter
    %   - ac: AC component of signal
    %   - dc: DC component of signal

    % Removes noise
%     [filter_SOS,g] = ss2sos(A,B,C,D);
    filtered_signal = filtfilt(filter_SOS, g, signal);
    
    ac = [];
    dc = [];
    
    tam = window_size * f_sample;
    sobreposicao = window_size * f_sample;
    % Calculate AC and DC components
    % AC = standard deviation in a window of length "sobreposicao"
    % DC = mean in a window of length "sobreposicao"
    for i = 0:sobreposicao:size(filtered_signal, 2) - tam
        t_ac = std(filtered_signal(i+1:i+tam));
        t_dc = mean(filtered_signal(i+1:i+tam));
        

        ac = cat(2, ac, t_ac);
        dc = cat(2, dc, t_dc);
    end
    
    % Ratio
    R = ac./dc;
end

function SpO2 = SpO2_RG(RG)
    % Estimation of SpO2 after calibration
	SpO2 =-14.902*RG.^1 +102.865;
	SpO2= round(SpO2);
end

% Graphs for report generation
function generateGraphs(RR, SpO2, window_size, filtered_signal1, filtered_signal2, ....
                        ac1, dc1, ac2, dc2, f_sample)
% ----------------- Signals Graph -----------------------------------------
    figure('Name','Signals_Graph', 'visible','off');
    
    hold on;
    % Color Channel - Red
    x = linspace(0, size(filtered_signal1,2)/f_sample, size(filtered_signal1,2));
    plot(x, filtered_signal1, 'r', 'LineWidth', 2);

    % Color Channel - Green
    plot(x, filtered_signal2, 'g'   , 'LineWidth', 2);
    
    legend('Canal de cor vermelho', 'Canal de cor verde', ....
            'Location', 'southoutside');
    xlabel('Tempo (s)');
    ylabel('Brilho');
    
    title('Sinal Fotopletismográfico - Canais de cor verde e vermelho');
    hold off;
    
    saveas(gcf, 'Temp/Signals_Graph.png');
    close 'Signals_Graph';

% ----------------- Ratio of Ratios Graph ---------------------------------
    figure('Name','Ratio_of_Ratio_Graph', 'visible','off');
    
    x = 0:window_size:size(filtered_signal1, 2)/f_sample - 1;
    plot(x, RR, '-o', 'LineWidth', 2);
    xlabel('Tempo (s)');
    ylabel('Razão das Razões (R)');
    title('Valor da Razão das Razões ao longo do tempo');
    
    saveas(gcf, 'Temp/Ratio_of_Ratio_Graph.png');
    close 'Ratio_of_Ratio_Graph'; 


% ----------------- AC and DC Graphs --------------------------------------
    figure('Name','ACDC_Red_Graph', 'visible','off');
    
    x = 0:window_size:size(filtered_signal1, 2)/f_sample - 1;
    % Red
    subplot(3, 1, 1);
    plot(x, ac1, 'r', 'LineWidth', 2);
    xlabel('Tempo (s)');
    ylabel('Amplitude AC');
    title('Componente AC - Canal de cor vermelho');

    subplot(3, 1, 2);
    plot(x, dc1, 'r', 'LineWidth', 2);
    xlabel('Tempo (s)');
    ylabel('Amplitude DC');
    title('Componente DC - Canal de cor vermelho');
    
    subplot(3, 1, 3)
    plot(x, ac1./dc1, 'r', 'LineWidth', 2);
    xlabel('Tempo (s)');
    ylabel('Razão AC/DC');
    title('Razão AC/DC - Canal de cor vermelho');
    
    
    saveas(gcf, 'Temp/ACDC_Red_Graph.png');
    close 'ACDC_Red_Graph';    
    
    % Green
    figure('Name','ACDC_Green_Graph', 'visible','off');
    subplot(3, 1, 1);
    plot(x, ac2, 'g', 'LineWidth', 2);
    xlabel('Tempo (s)');
    ylabel('Amplitude AC');
    title('Componente AC - Canal de cor verde');

    subplot(3, 1, 2);
    plot(x, dc2, 'g', 'LineWidth', 2);
    xlabel('Tempo (s)');
    ylabel('Amplitude DC');
    title('Componente DC - Canal de cor verde');
    
    subplot(3, 1, 3)
    plot(x, ac2./dc2, 'r', 'LineWidth', 2);
    xlabel('Tempo (s)');
    ylabel('Razão AC/DC');
    title('Razão AC/DC - Canal de cor verde');

    saveas(gcf, 'Temp/ACDC_Green_Graph.png');
    close 'ACDC_Green_Graph'; 
    

    
% ----------------- SpO2 Graph --------------------------------------------
    figure('Name','SpO2_Graph', 'visible','off');
    hold on;
    plot(x, SpO2, '-o', 'LineWidth', 2); 
    y = mean(SpO2); 
    line([0 x(end)], [y y], 'Color', 'r', 'lineWidth', 2);
    hold off
    xlabel('Tempo (s)');
    ylabel('SpO2 (%)');
    ytickformat('percentage');
    legend('SpO2', sprintf(['Média SpO2 - ', num2str(y), '%']));
    title('Saturação de Oxigênio (SpO2)');
    
    saveas(gcf, 'Temp/SpO2_Graph.png');
    close 'SpO2_Graph'; 
end