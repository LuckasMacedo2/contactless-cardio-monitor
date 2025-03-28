close all; clc; clear;

% % 3
% % load('C:\Users\Pedro e Dione\Documents\MATLAB\2018\Windows 64\DATA\Isaac\Isaac.mat')
% % load('C:\Users\Pedro e Dione\Documents\Deploy MATLAB\Cardio Acquisition Tool\ECG\for_testing\DATA\Isaac500\Isaac500.mat')
% 
% % 1 Pedro -----------------------------------------------------------------
% load('C:\Users\Pedro e Dione\Documents\Deploy MATLAB\Cardio Acquisition Tool\ECG\for_testing\DATA\PedroInter500\PedroInter500.mat');
% load('C:\Users\Pedro e Dione\Documents\MATLAB\2018\Windows 64\DATA\PedroInter500\PedroInter500.mat');
% 
% peak = 1; % 1 {1}  2 {.8} 3 {1.2}
% [p,l] = findpeaks(ECG,FS,'MinPeakProminence',peak);
% if ~isempty(p)
% figure('Name','HRV Comparison','NumberTitle','off');
% subplot(4,1,1)
% findpeaks(ECG,FS,'MinPeakProminence',peak); 
% a= mean(diff(l));
% HR = round(60/a);
% legend('ECG', 'Picos R');
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Eletrocardiograma ', num2str(HR), ' BPM']);
% axis([0 Inf 0 5]);
% subplot(4,1,4)
% hrvecg = diff(l);
% plot(hrvecg*1000);
% xlabel('Batimentos');
% ylabel('Intervalo RR (ms)');
% title('Intervalo RR');
% 
% % PPG ---------------------------------------------------------------------
% mean_block = mean(PPG);
% std_block = std(PPG);
% PPG1 = (PPG - mean_block)/std_block;
% [p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG)*4); % 1 {4} 2 {5}
% [p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG), 'MinPeakDistance', mean(diff(l))); % 1 {1} 2 {1.5} 3 {1.5}
% subplot(4,1,2)
% plot(PPG_time,PPG1);
% hold on
% plot(l,p.^(1/3),'vg');
% hold off
% a= mean(diff(l));
% HR = round(60/a);
% legend('PPG', 'Picos R');
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Sinal Fotopletismográfico ', num2str(HR), ' BPM']);
% hrvppg = diff(l);
% x_hrv = linspace(0,PPG_time(end),numel(hrvppg));
% subplot(4,1,4)
% hold on
% plot(hrvppg*1000);
% hold off
% 
% % % CAMERA-----------------------------------------------------------------
% peak = 2.3; % 1 {2} 2 {2} 3 {1.5}
% subplot(4,1,3)
% 
% [p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel),'MinPeakHeight',1); % 1 {4} 2 {5}
% [p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel),'MinPeakHeight',1,'MinPeakDistance', mean(diff(l))*.7);
% 
% plot(linspace(0, size(plot_compORchannel,2)/FS, size(plot_compORchannel,2)), plot_compORchannel);
% hold on
% plot(l,p.^(1/3),'vg');
% hold off
% % [p,l] = findpeaks(plot_compORchannel.^3,FS,'SortStr','descend'); % 1 {4} 2 {5}
% 
% 
% hrvHRVCam = diff(l);
% a= mean(diff(l));
% HR = round(60/a);
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Sinal PPG HRVCam ', num2str(HR), ' BPM']);
% subplot(4,1,4)
% hold on
% plot(hrvHRVCam*1000);
% hold off
% legend('RR ECG', 'RR PPG','RR HRVCam')
% % % -----------------------------------------------------------------------
% 
%  
% %POINCARE -----------------------------------------------------------------
% % ECG
% hrv_poincare = [hrvecg(1,1:end-1); hrvecg(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineecg = coef(1)*hrv_poincare(1,:)+coef(2);
% figure('Name','Poincare ECG','NumberTitle','off'); 
% subplot(3,1,1)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineecg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% % PPG
% hrv_poincare = [hrvppg(1,1:end-1); hrvppg(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
% subplot(3,1,2)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineppg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% % HRVCam
% hrv_poincare = [hrvHRVCam(1,1:end-1); hrvHRVCam(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
% subplot(3,1,3)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineppg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% 
% else
% warndlg('Não foi possível encontrar o padrão de onda ECG no sinal capturado!');
% end
% 
% clc; clear;
% % % 2 Talles
% % ###############################################################################################################################################################
% load('C:\Users\Pedro e Dione\Documents\MATLAB\2018\Windows 64\DATA\Talles500\Talles500.mat');
% load('C:\Users\Pedro e Dione\Documents\Deploy MATLAB\Cardio Acquisition Tool\ECG\for_testing\DATA\Talles500\Talles500.mat')
% 
% peak = .8; % 1 {1}  2 {.8} 3 {1.2}
% [p,l] = findpeaks(ECG,FS,'MinPeakProminence',peak);
% if ~isempty(p)
% figure('Name','HRV Comparison','NumberTitle','off');
% subplot(4,1,1)
% findpeaks(ECG,FS,'MinPeakProminence',peak); 
% a= mean(diff(l));
% HR = round(60/a);
% legend('ECG', 'Picos R');
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Eletrocardiograma ', num2str(HR), ' BPM']);
% axis([0 Inf 0 5]);
% subplot(4,1,4)
% hrvecg = diff(l);
% % plot(x_hrv,hrv*1000);
% plot(hrvecg*1000);
% xlabel('Batimentos');
% ylabel('Intervalo RR (ms)');
% title('Intervalo RR');
% 
% % PPG ---------------------------------------------------------------------
% mean_block = mean(PPG);
% std_block = std(PPG);
% PPG1 = (PPG - mean_block)/std_block;
% [p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG)*5); % 1 {4} 2 {5}
% [p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG), 'MinPeakDistance', mean(diff(l))*1.5); % 1 {1} 2 {1.5} 3 {1.5}
% subplot(4,1,2)
% plot(PPG_time,PPG1);
% hold on
% plot(l,p.^(1/3),'vg');
% hold off
% a= mean(diff(l));
% HR = round(60/a);
% legend('PPG', 'Picos R');
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Sinal Fotopletismográfico ', num2str(HR), ' BPM']);
% hrvppg = diff(l);
% x_hrv = linspace(0,PPG_time(end),numel(hrvppg));
% subplot(4,1,4)
% hold on
% plot(hrvppg*1000);
% hold off
% 
% % % CAMERA-----------------------------------------------------------------
% peak = 2.3; % 1 {2} 2 {2} 3 {1.5}
% subplot(4,1,3)
% 
% [p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel),'MinPeakHeight',1); % 1 {4} 2 {5}
% [p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel),'MinPeakHeight',1,'MinPeakDistance', mean(diff(l))*.7);
% 
% plot(linspace(0, size(plot_compORchannel,2)/FS, size(plot_compORchannel,2)), plot_compORchannel);
% hold on
% plot(l,p.^(1/3),'vg');
% hold off
% 
% hrvHRVCam = diff(l);
% a= mean(diff(l));
% HR = round(60/a);
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Sinal PPG HRVCam ', num2str(HR), ' BPM']);
% subplot(4,1,4)
% hold on
% plot(hrvHRVCam*1000);
% hold off
% legend('RR ECG', 'RR PPG','RR HRVCam')
% % % -----------------------------------------------------------------------
% 
%  
% %POINCARE -----------------------------------------------------------------
% % ECG
% hrv_poincare = [hrvecg(1,1:end-1); hrvecg(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineecg = coef(1)*hrv_poincare(1,:)+coef(2);
% figure('Name','Poincare ECG','NumberTitle','off'); 
% subplot(3,1,1)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineecg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% % PPG
% hrv_poincare = [hrvppg(1,1:end-1); hrvppg(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
% subplot(3,1,2)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineppg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% % HRVCam
% hrv_poincare = [hrvHRVCam(1,1:end-1); hrvHRVCam(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
% subplot(3,1,3)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineppg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% else
% warndlg('Não foi possível encontrar o padrão de onda ECG no sinal capturado!');
% end
% 
% 
% % 1 Pedro -----------------------------------------------------------------
% load('C:\Users\Pedro e Dione\Documents\MATLAB\2018\Windows 64\DATA\Diogo\Diogo.mat')
% load('C:\Users\Pedro e Dione\Documents\Deploy MATLAB\Cardio Acquisition Tool\ECG\for_testing\DATA\Diogo500\Diogo500.mat')
% 
% peak = 1.4; % 1 {1}  2 {.8} 3 {1.2}
% [p,l] = findpeaks(ECG,FS,'MinPeakProminence',peak);
% if ~isempty(p)
% figure('Name','HRV Comparison','NumberTitle','off');
% subplot(4,1,1)
% findpeaks(ECG,FS,'MinPeakProminence',peak); 
% a= mean(diff(l));
% HR = round(60/a);
% legend('ECG', 'Picos R');
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Eletrocardiograma ', num2str(HR), ' BPM']);
% axis([0 Inf 0 5]);
% subplot(4,1,4)
% hrvecg = diff(l);
% plot(hrvecg*1000);
% xlabel('Batimentos');
% ylabel('Intervalo RR (ms)');
% title('Intervalo RR');
% 
% % PPG ---------------------------------------------------------------------
% mean_block = mean(PPG);
% std_block = std(PPG);
% PPG1 = (PPG - mean_block)/std_block;
% [p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG)*4); % 1 {4} 2 {5}
% [p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG), 'MinPeakDistance', mean(diff(l))); % 1 {1} 2 {1.5} 3 {1.5}
% subplot(4,1,2)
% plot(PPG_time,PPG1);
% hold on
% plot(l,p.^(1/3),'vg');
% hold off
% a= mean(diff(l));
% HR = round(60/a);
% legend('PPG', 'Picos R');
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Sinal Fotopletismográfico ', num2str(HR), ' BPM']);
% hrvppg = diff(l);
% x_hrv = linspace(0,PPG_time(end),numel(hrvppg));
% subplot(4,1,4)
% hold on
% plot(hrvppg*1000);
% hold off
% 
% % % CAMERA-----------------------------------------------------------------
% peak = 2.3; % 1 {2} 2 {2} 3 {1.5}
% subplot(4,1,3)
% 
% [p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel),'MinPeakHeight',1); % 1 {4} 2 {5}
% [p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel),'MinPeakHeight',1,'MinPeakDistance', mean(diff(l))*.7);
% 
% plot(linspace(0, size(plot_compORchannel,2)/FS, size(plot_compORchannel,2)), plot_compORchannel);
% hold on
% plot(l,p.^(1/3),'vg');
% hold off
% % [p,l] = findpeaks(plot_compORchannel.^3,FS,'SortStr','descend'); % 1 {4} 2 {5}
% 
% 
% hrvHRVCam = diff(l);
% a= mean(diff(l));
% HR = round(60/a);
% xlabel('Tempo (s)');
% ylabel('Amplitude (V)');
% title(['Sinal PPG HRVCam ', num2str(HR), ' BPM']);
% subplot(4,1,4)
% hold on
% plot(hrvHRVCam*1000);
% hold off
% legend('RR ECG', 'RR PPG','RR HRVCam')
% % % -----------------------------------------------------------------------
% 
%  
% %POINCARE -----------------------------------------------------------------
% % ECG
% hrv_poincare = [hrvecg(1,1:end-1); hrvecg(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineecg = coef(1)*hrv_poincare(1,:)+coef(2);
% figure('Name','Poincare ECG','NumberTitle','off'); 
% subplot(3,1,1)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineecg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% % PPG
% hrv_poincare = [hrvppg(1,1:end-1); hrvppg(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
% subplot(3,1,2)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineppg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% % HRVCam
% hrv_poincare = [hrvHRVCam(1,1:end-1); hrvHRVCam(1,2:end)];
% coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
% lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
% subplot(3,1,3)
% plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
% hold on
% p = plot(hrv_poincare(1,:), lineppg, 'r');
% hold off
% legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
% 
% 
% else
% warndlg('Não foi possível encontrar o padrão de onda ECG no sinal capturado!');
% end


% 1 Pedro -----------------------------------------------------------------
load('C:\Users\Pedro e Dione\Documents\Deploy MATLAB\HRVCam\HRVCam\for_testing\DATA\Matheus Melo Batista\Matheus Melo Batista.mat')
load('C:\Users\Pedro e Dione\Documents\Deploy MATLAB\Cardio Acquisition Tool\ECG\for_testing\DATA\Matheus Melo Batista\Matheus Melo Batista.mat')

peak = .8; % 1 {1}  2 {.8} 3 {1.2}
[p,l] = findpeaks(ECG,FS,'MinPeakProminence',peak);
if ~isempty(p)
figure('Name','HRV Comparison','NumberTitle','off');
subplot(4,1,1)
findpeaks(ECG,FS,'MinPeakProminence',peak); 
a= mean(diff(l));
HR = round(60/a);
legend('ECG', 'Picos R');
xlabel('Tempo (s)');
ylabel('Amplitude (V)');
title(['Eletrocardiograma ', num2str(HR), ' BPM']);
axis([0 Inf 0 5]);
subplot(4,1,4)
hrvecg = diff(l);
plot(hrvecg*1000);
xlabel('Batimentos');
ylabel('Intervalo RR (ms)');
title('Intervalo RR');

% PPG ---------------------------------------------------------------------
mean_block = mean(PPG);
std_block = std(PPG);
PPG1 = (PPG - mean_block)/std_block;
[p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG1.^3)*0.3); % 1 {4} 2 {5}
[p,l] = findpeaks(PPG1.^3,FS,'MinPeakProminence',std(PPG1.^3)*0.3, 'MinPeakDistance', mean(diff(l))*0.5); % 1 {1} 2 {1.5} 3 {1.5}
subplot(4,1,2)
plot(PPG_time,PPG1);
hold on
plot(l,p.^(1/3),'vg');
hold off
a= mean(diff(l));
HR = round(60/a);
legend('PPG', 'Picos R');
xlabel('Tempo (s)');
ylabel('Amplitude (V)');
title(['Sinal Fotopletismográfico ', num2str(HR), ' BPM']);
hrvppg = diff(l);
x_hrv = linspace(0,PPG_time(end),numel(hrvppg));
subplot(4,1,4)
hold on
plot(hrvppg*1000);
hold off

% % CAMERA-----------------------------------------------------------------
peak = .01; % 1 {2} 2 {2} 3 {1.5}
subplot(4,1,3)

[p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel.^3)*peak,'MinPeakHeight',1); % 1 {4} 2 {5}
[p,l] = findpeaks(plot_compORchannel.^3,FS,'MinPeakProminence',std(plot_compORchannel.^3)*peak,'MinPeakHeight',1,'MinPeakDistance', mean(diff(l))*0.1);

plot(linspace(0, size(plot_compORchannel,2)/FS, size(plot_compORchannel,2)), plot_compORchannel);
hold on
plot(l,p.^(1/3),'vg');
hold off
% [p,l] = findpeaks(plot_compORchannel.^3,FS,'SortStr','descend'); % 1 {4} 2 {5}


hrvHRVCam = diff(l);
a= mean(diff(l));
HR = round(60/a);
xlabel('Tempo (s)');
ylabel('Amplitude (V)');
title(['Sinal PPG HRVCam ', num2str(HR), ' BPM']);
subplot(4,1,4)
hold on
plot(hrvHRVCam*1000);
hold off
legend('RR ECG', 'RR PPG','RR HRVCam')
% % -----------------------------------------------------------------------

 
%POINCARE -----------------------------------------------------------------
% ECG
hrv_poincare = [hrvecg(1,1:end-1); hrvecg(1,2:end)];
coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
lineecg = coef(1)*hrv_poincare(1,:)+coef(2);
figure('Name','Poincare ECG','NumberTitle','off'); 
subplot(3,1,1)
plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
hold on
p = plot(hrv_poincare(1,:), lineecg, 'r');
hold off
legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));

% PPG
hrv_poincare = [hrvppg(1,1:end-1); hrvppg(1,2:end)];
coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
subplot(3,1,2)
plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
hold on
p = plot(hrv_poincare(1,:), lineppg, 'r');
hold off
legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));

% HRVCam
hrv_poincare = [hrvHRVCam(1,1:end-1); hrvHRVCam(1,2:end)];
coef = polyfit(hrv_poincare(1,:), hrv_poincare(2,:),1);
lineppg = coef(1)*hrv_poincare(1,:)+coef(2);
subplot(3,1,3)
plot(hrv_poincare(1,:),hrv_poincare(2,:),'*');
hold on
p = plot(hrv_poincare(1,:), lineppg, 'r');
hold off
legend(p, sprintf(['Line: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));


else
warndlg('Não foi possível encontrar o padrão de onda ECG no sinal capturado!');
end

