function [HR, plot_compORchannel, plot_frequency] = calculate_HR(block, f_sample, lowerFreq, upperFreq, filterFCC, HRDetecMethod)

block_R = detrending(block(1,:)', 10);
block_G = detrending(block(2,:)', 10);
block_B = detrending(block(3,:)', 10);

block = [block_R block_G block_B];
mean_block = mean(block);
std_block = std(block);

% block = normc(block)';
block = [(block(:,1) - mean_block(1,1))/std_block(1,1) (block(:,2) - mean_block(1,2))/std_block(1,2)  (block(:,3) - mean_block(1,3))/std_block(1,3)];
block = block';

NUM_FREQS = 4;

numero_canais = size(block, 1);

if HRDetecMethod == 1
    % ICA JADE
    matrix = jade(block, 3);
    Y = matrix * block;
    
    %Y = filter(b,1,Y);
    
    spectro_comp = [];
    spectro_limitado = [];
    maiores_pot_freq = [];
    
    for chn=1:numero_canais
        [pot_comp, freq_comp] = analisar_espectro_potencia(Y(chn, :), f_sample);
        [lim_freq_comp, ic_pfreq] = limitar_frequencia(pot_comp, freq_comp, lowerFreq, upperFreq);
        spectro_comp = cat(3, spectro_comp, [pot_comp ; freq_comp]);
        spectro_limitado = cat(3, spectro_limitado, [lim_freq_comp ; ic_pfreq]);
        
        % figure; plot(spectro_comp(2, :, chn), spectro_comp(1, :, chn));
        % figure; plot(spectro_limitado(2, :, chn), spectro_limitado(1, :, chn));
        
        [maiores_pot_comp, maiores_pot_comp_idx] = sort(lim_freq_comp, 'descend');
        maiores_pot_freq = cat(3, maiores_pot_freq, [ic_pfreq(maiores_pot_comp_idx(1:NUM_FREQS)); maiores_pot_comp(1:NUM_FREQS)]);
    end
    
    maiores_freqs = maiores_pot_freq(1,:, :);
    maiores_freqs = reshape(maiores_freqs(1,:,:), size(maiores_freqs(1,:,:),2), size(maiores_freqs(1,:,:),3));
    maiores_potencias = maiores_pot_freq(2,:, :);
    maiores_potencias = reshape(maiores_potencias(1,:,:), size(maiores_potencias(1,:,:),2), size(maiores_potencias(1,:,:),3));
    
    [maior_pot_canal, maior_pot_canal_idx] = max(maiores_potencias);
    [maior_pot, maior_pot_idx] = max(maior_pot_canal);
    
    max_pow_channel_freq = [];
    for chn=1:numero_canais
        max_pow_channel_freq = cat(2, max_pow_channel_freq, maiores_freqs(maior_pot_canal_idx(chn), chn));
    end
    
    max_pow_frequency = maiores_freqs(maior_pot_canal_idx(maior_pot_idx), maior_pot_idx);
    % figure; plot(Y(maior_pot_idx,:));
    % plot_component = filter(b,1,Y(maior_pot_idx,:));
    plot_compORchannel = Y(maior_pot_idx,:);
    plot_frequency = spectro_limitado(:, :, maior_pot_idx);
    
    % disp(['Powerful Frequency in each channel: ', num2str(max_pow_channel_freq), ' Hz.']);
    % disp(['Powerful Frequency: ', num2str(max_pow_frequency), ' Hz.']);
    HR = max_pow_frequency * 60;
    % disp(['BPM: ', num2str(HR)]);
    
elseif HRDetecMethod == 2 % Fixed Color Channel
    plot_compORchannel = filter(filterFCC,1,block(2,:));
    [p,l] = findpeaks(plot_compORchannel, f_sample,'MinPeakProminence',std(plot_compORchannel,0,2)*2);
    % HR = round((size(block,2)/f_sample)/mean(diff(l)));
    HR = round(60/mean(diff(l)));
    plot_frequency = [];
    % plot_compORchannel = block(2,:);
    % figure; findpeaks(plot_compORchannel, f_sample,'MinPeakProminence',.3);
end
end