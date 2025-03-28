function generateReport(path, type, handles)
    % Generates reports with user data, variable data, and signals
    % informations
    % Input:
    %   - path: Path where report will be save 
    %   - type: Variable being acquired. It serves to determine the report template that will be used
    %       - PWV
    %       - HR and HRV
    %       - Regional Blood Pressure
    %   - handles: Data struct with data of current user
    % Output: Report generated and saved in the folder. Two reports are
    % generated, one in a docx file and the other in a pdf file
    
    if strcmp(type, 'PWV') % Generates PWV report
        generateReportPWV(path, handles);
    end
    
    if strcmp(type, 'SpO2') % Generates SpO2 report
        generateReportSpO2(path, handles);
    end
    
    if strcmp(type, 'HR') % Generates SpO2 report
        generateReportHR(path, handles);
    end
    
    if strcmp(type, 'BP') % Generates calibration PA report
        generateReportBP(path, handles);
    end
    
end

function generateReportBP(path, handles)
    % Generates reports with user data, variable data, and signals for
    % SpO2
    % Input:
    %   - handles: Data struct with data of current user
    %   - path: Path where report will be save 
    % Output: Report generated and saved in the folder. Two reports are
    % generated, one in a docx file and the other in a pdf file
    
    makeDOMCompilable();
    import mlreportgen.dom.*
    % ------------------------- SBP ---------------------------------------
    % Fill in the fields in the template and generate a new file for the user
    pathSBP = strcat([path, '\SBP']);  

    D = Document(pathSBP, 'docx', 'ReportTemplates\CalibrationBPTemplate.dotx');
    open(D);
    
    moveToNextHole(D);
    append(D, 'Sistólica');
    
    % Independent Variable
    moveToNextHole(D);
    if strcmp(handles.varSBP, 'PWV')
        append(D,'Velocidade da Onda de Pulso (VOP)');
    else
        append(D,'Tempo de Trânsito de Pulso (TTP)');
    end
    
    % Curve Equation
    moveToNextHole(D);
    append(D, handles.eqSBP);
    
    % Pearson Coeficient
    moveToNextHole(D);
    append(D,num2str(handles.corrSBP, 2));
    
    % Spearman Coeficient
    moveToNextHole(D);
    append(D, num2str(handles.pSBP, 2));
    
    % Table SBP        
    id = handles.tableBP_PWV.ID;
    id = cat(1, 'ID', id);
    
    if strcmp(handles.varSBP, 'PWV')
        variable = round(handles.tableBP_PWV.PWV, 5);
        s = 'VOP';
    else
        variable = round(handles.tableBP_PWV.PTT, 5);
        s = 'TTP';
    end
    variable = num2cell(string(variable));
    variable = cat(1, s, variable);
    
    
    SBP = handles.tableBP_PWV.SBP;
    SBP = num2cell(string(SBP));
    SBP = cat(1, 'PAS', SBP);
    
    SBP_Estimated = round(handles.SBP_Estimated, 5);
    SBP_Estimated = num2cell(string(SBP_Estimated));
    SBP_Estimated = cat(1, 'Estimada', SBP_Estimated);
    
    error = round(abs(handles.SBP_Estimated - handles.tableBP_PWV.SBP), 5);
    error = num2cell(string(error));
    error = cat(1, 'Erro Absoluto', error);
    
    t = Table([id variable SBP SBP_Estimated error]);    

    t.Border = 'solid';
    t.ColSep = 'solid';
    t.RowSep = 'solid';
    moveToNextHole(D);
    append(D,t);
    
    % ---- Graphs ----
    % Curve Graph
    PTT_temp = min(handles.tableBP_PWV.PTT):0.0001: max(handles.tableBP_PWV.PTT);
    PWV_temp = min(handles.tableBP_PWV.PWV):0.01: max(handles.tableBP_PWV.PWV);

    if strcmp(handles.varSBP, 'PWV')
        v = handles.tableBP_PWV.PWV;
        temp = PWV_temp;
        variable = 'Velocidade da Onda de Pulso (m/s)';
    else
        v = handles.tableBP_PWV.PTT;
        temp = PTT_temp;
        variable = 'Tempo de Trânsito de Pulso (s)';
    end
    
    % Convert string convert the string that represents the curve into a function
    str = strcat(['@(', handles.varSBP, ')', handles.eqSBP]);
    fun = str2func(str);
    SBP = fun(temp);
    
    str = strcat(['@(', handles.varDBP,')', handles.eqDBP]);
    fun = str2func(str);
    
    % ----- Plot ------
    figure('Name', 'Curve_SBP', 'visible','off');
    hold on;
    
    plot(v, handles.tableBP_PWV.SBP, 'o', 'LineWidth', 3);
    plot(temp, SBP, '-', 'LineWidth', 3);
    
    s = sort(handles.tableBP_PWV.SBP);
    text(temp(round(end/2)), s(round(end/2)), ....
        sprintf(['r = ', num2str(handles.corrSBP, 2), newline, ....
        'p = ', num2str(handles.pSBP, 2)]), 'FontSize', 15);
    
    xlabel(variable);
    ylabel('Pressão Arterial Sistólica (mmHg)');
    if strcmp(handles.varSBP, 'PWV')
        s = 'VOP';
    else
        s = 'TTP';
    end
        
    title(sprintf(['PASx', s]));
    legend('Samples', 'Curve');
    hold off;
    
    saveas(gcf, 'Temp/Curve_SBP.png');
    close('Curve_SBP');
    
    moveToNextHole(D);
    p = mlreportgen.dom.Image('Temp/Curve_SBP.png');
    p.Width = '25cm';
    p.Height = '15cm';
    %moveToNextHole(D);
    append(D, p);
    
    
    % ---
    error_SBP = round(handles.SBP_Estimated - handles.tableBP_PWV.SBP, 3);
    abs_error_SBP = abs(error_SBP);
    rmse_SBP = sqrt(mean(error_SBP.^2)); 
    
    figure('Name', 'Error_SBP', 'visible','off');
    bar(abs_error_SBP);
    
    title('Erro Absoluto x Amostra - PAS');
    xlabel('Amostra');
    ylabel('Erro Absoluto (mmHg)');
    
    legend(sprintf(['Erro Absoluto', newline, 'RMSE: ', num2str(rmse_SBP, 2)]));
    
    saveas(gcf, 'Temp/Error_SBP.png');
    close('Error_SBP');
    
    moveToNextHole(D);
    p = mlreportgen.dom.Image('Temp/Error_SBP.png');
    p.Width = '25cm';
    p.Height = '15cm';
    %moveToNextHole(D);
    append(D, p);
    
    % --
    f = figure('Name', 'bland_SBP', 'visible','off');
    BlandAltman(f, handles.tableBP_PWV.SBP, handles.SBP_Estimated, ....
    {'PAS', 'PAS Estimada'}, 'Bland Altman PAS', {'PAS' 'PAS Estimada'}, ....
    'corrInfo', {'n','SSE','r','eq'});
    saveas(gcf, 'Temp/bland_SBP.png');
    close('bland_SBP');
    
    moveToNextHole(D);
    p = mlreportgen.dom.Image('Temp/bland_SBP.png');
    p.Width = '25cm';
    p.Height = '15cm';
    %moveToNextHole(D);
    append(D, p);
    
    close(D);
    word2pdf(pathSBP);

    % ------------------------- DBP ---------------------------------------
    pathDBP = strcat([path, '/DBP']);
    D = Document(pathDBP, 'docx', 'ReportTemplates\CalibrationBPTemplate.dotx');
    open(D);
    
    moveToNextHole(D);
    append(D, 'Diastólica');
    
    % Independent Variable
    moveToNextHole(D);
    if strcmp(handles.varSBP, 'PWV')
        append(D,'Velocidade da Onda de Pulso (VOP)');
    else
        append(D,'Tempo de Trânsito de Pulso (TTP)');
    end
    
    % Curve Equation
    moveToNextHole(D);
    append(D, handles.eqDBP);
    
    % Pearson Coeficient
    moveToNextHole(D);
    append(D,num2str(handles.corrDBP, 2));
    
    % Spearman Coeficient
    moveToNextHole(D);
    append(D, num2str(handles.pDBP, 2));
    
    % Table SBP        
    
    id = handles.tableBP_PWV.ID;
    id = cat(1, 'ID', id);
    
    if strcmp(handles.varSBP, 'PWV')
        variable = round(handles.tableBP_PWV.PWV, 5);
        s = 'VOP';
    else
        variable = round(handles.tableBP_PWV.PTT, 5);
        s = 'TTP';
    end
    variable = num2cell(string(variable));
    variable = cat(1, s, variable);
    
    
    DBP = handles.tableBP_PWV.DBP;
    DBP = num2cell(string(DBP));
    DBP = cat(1, 'PAD', DBP);
    
    DBP_Estimated = round(handles.DBP_Estimated, 5);
    DBP_Estimated = num2cell(string(DBP_Estimated));
    DBP_Estimated = cat(1, 'Estimada', DBP_Estimated);
    
    error = round(abs(handles.DBP_Estimated - handles.tableBP_PWV.DBP), 5);
    error = num2cell(string(error));
    error = cat(1, 'Erro Absoluto', error);
    
    t = Table([id variable DBP DBP_Estimated error]);    

    t.Border = 'solid';
    t.ColSep = 'solid';
    t.RowSep = 'solid';
    moveToNextHole(D);
    append(D,t);
    
    % ---- Graphs ----
    % Curve Graph
    PTT_temp = min(handles.tableBP_PWV.PTT):0.0001: max(handles.tableBP_PWV.PTT);
    PWV_temp = min(handles.tableBP_PWV.PWV):0.01: max(handles.tableBP_PWV.PWV);

    if strcmp(handles.varDBP, 'PWV')
        v = handles.tableBP_PWV.PWV;
        temp = PWV_temp;
        variable = 'Velocidade da Onda de Pulso (m/s)';
    else
        v = handles.tableBP_PWV.PTT;
        temp = PTT_temp;
        variable = 'Tempo de Trânsito de Pulso (s)';
    end
    
    % Convert string convert the string that represents the curve into a function
    str = strcat(['@(', handles.varSBP, ')', handles.eqSBP]);
    fun = str2func(str);
    
    
    str = strcat(['@(', handles.varDBP,')', handles.eqDBP]);
    fun = str2func(str);
    DBP = fun(temp);
    % ----- Plot ------
    figure('Name', 'Curve_DBP', 'visible','off');
    hold on;
    
    plot(v, handles.tableBP_PWV.DBP, 'o', 'LineWidth', 3);
    plot(temp, DBP, '-', 'LineWidth', 3);
    
    s = sort(handles.tableBP_PWV.DBP);
    text(temp(round(end/2)), s(round(end/2)), ....
        sprintf(['r = ', num2str(handles.corrDBP, 2), newline, ....
        'p = ', num2str(handles.pDBP, 2)]), 'FontSize', 15);
    
    xlabel(variable);
    ylabel('Pressão Arterial Sistólica (mmHg)');
    if strcmp(handles.varDBP, 'PWV')
        s = 'VOP';
    else
        s = 'TTP';
    end
        
    title(sprintf(['PADx', s]));
    legend('Samples', 'Curve');
    hold off;
    
    saveas(gcf, 'Temp/Curve_DBP.png');
    close('Curve_DBP');
    
    moveToNextHole(D);
    p = mlreportgen.dom.Image('Temp/Curve_DBP.png');
    p.Width = '25cm';
    p.Height = '15cm';
    %moveToNextHole(D);
    append(D, p);
    
    
    % ---   
    error_DBP = round(handles.DBP_Estimated - handles.tableBP_PWV.DBP, 3);
    abs_error_DBP = abs(error_DBP);
    rmse_SBP = sqrt(mean(error_DBP.^2)); 
    
    figure('Name', 'Error_DBP', 'visible','off');
    bar(abs_error_DBP);
    
    title('Erro Absoluto x Amostra - PAD');
    xlabel('Amostra');
    ylabel('Erro Absoluto (mmHg)');
    
    legend(sprintf(['Erro Absoluto', newline, 'RMSE: ', num2str(rmse_SBP, 2)]));
    
    saveas(gcf, 'Temp/Error_DBP.png');
    close('Error_DBP');
    
    moveToNextHole(D);
    p = mlreportgen.dom.Image('Temp/Error_DBP.png');
    p.Width = '25cm';
    p.Height = '15cm';
    %moveToNextHole(D);
    append(D, p);
    
    % --
    f = figure('Name', 'bland_DBP', 'visible','off');
    BlandAltman(f, handles.tableBP_PWV.SBP, handles.SBP_Estimated, ....
    {'PAD', 'PAD Estimada'}, 'Bland Altman PAD', {'PAD' 'PAD Estimada'}, ....
    'corrInfo', {'n','SSE','r','eq'});
    saveas(gcf, 'Temp/bland_DBP.png');
    close('bland_DBP');
    
    moveToNextHole(D);
    p = mlreportgen.dom.Image('Temp/bland_DBP.png');
    p.Width = '25cm';
    p.Height = '15cm';
    %moveToNextHole(D);
    append(D, p);

    close(D);
    word2pdf(pathDBP);

end

function generateReportSpO2(path, handles)
    % Generates reports with user data, variable data, and signals for
    % SpO2
    % Input:
    %   - handles: Data struct with data of current user
    %   - path: Path where report will be save 
    % Output: Report generated and saved in the folder. Two reports are
    % generated, one in a docx file and the other in a pdf file
    
    makeDOMCompilable();
    import mlreportgen.dom.*
    % Fill in the fields in the template and generate a new file for the user
    D = Document(path, 'docx', 'ReportTemplates\SpO2Template.dotx');
    open(D);
    
    % ------------------------- User Informations -------------------------
    % User ID
    moveToNextHole(D);
    append(D, num2str(handles.userID));
    
    % User Name
    moveToNextHole(D);
    append(D, handles.userName);
    
    % Data of Birth
    moveToNextHole(D);
    append(D, handles.userBirthday);
    
    % Age
    moveToNextHole(D);
    append(D, handles.userAge);
    
    % Mass
    moveToNextHole(D);
    append(D, num2str(handles.userMass));
    
    % Height
    moveToNextHole(D);
    append(D, num2str(handles.userHeight));
    
    % Gender
    if strcmp(handles.userGender, 'Male') % Translates English to Portuguese
        userGender = 'Masculino';
    else
        userGender = 'Feminino';
    end
    moveToNextHole(D);
    append(D, userGender);
    
    % Skin Type
    moveToNextHole(D);
    append(D, num2str(handles.userSkin));
    
    % ------------------------- Physiological Variable -------------------------
    % Table SpO2
    time = 0:handles.time_sobre:handles.videoSize - 1;
    
    size(time)
    size(handles.SpO2)
    
    time = num2cell(time);
    SpO2 = num2cell(handles.SpO2);
    time = cat(2, 'Tempo (s)', time);
    SpO2 = cat(2, 'SpO2 %', SpO2);
    
    
    t = Table([time; SpO2]);
    t.Border = 'solid';
    % t.BorderWidth = '1px';
    t.ColSep = 'solid';
    % t.ColSepWidth = '1';
    t.RowSep = 'solid';
    % t.RowSepWidth = '1';
%     moveToNextHole(D);
    moveToNextHole(D);
    append(D,t);
    
    % Average of SpO2
    m = mean(handles.SpO2);
    m = num2str(m, 2);
    moveToNextHole(D);
    append(D,m);
    
    % ------------------------- Signal Acquisition and Processing -------------------------
    % Acquisition Frequency
    moveToNextHole(D);
    append(D, num2str(handles.videoFPS));
        
    % Acquisition Time
    moveToNextHole(D);
    append(D, num2str(handles.videoSize));
    
    % ------------------------- Signals Metrics ------------------------- 
    % Signal Quality
    % Translation of English to Portuguese
    if strcmp(handles.signal_quality_final, 'Excellent')
        signalQuality = 'Excelente';
    else
        if strcmp(handles.signal_quality_final, 'Acceptable')
            signalQuality = 'Bom';
        else
            if strcmp(handles.signal_quality_final, 'Unfit')
                signalQuality = 'Ruim';
            end
        end
    end
    moveToNextHole(D);
    append(D, signalQuality);   
    
    % SNR Green Channel
    moveToNextHole(D);
    append(D, num2str(round(handles.SNRGreen, 2)));  
    
    % SNR Red Channel
    moveToNextHole(D);
    append(D, num2str(round(handles.SNRRed, 2)));  
    
    % ------------------------- Graphs of Signals -------------------------
    % Signal graph
    p = mlreportgen.dom.Image('temp/Signals_Graph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);  
    
    % AC DC Red
    p = mlreportgen.dom.Image('temp/ACDC_Red_Graph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);   
    
    % AC DC Green
    p = mlreportgen.dom.Image('temp/ACDC_Green_Graph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);  
    
    % Ratio of Ratios Graph
    p = mlreportgen.dom.Image('temp/Ratio_of_Ratio_Graph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p); 
    
    % SpO2 Graph
    p = mlreportgen.dom.Image('temp/SpO2_Graph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);
    
    % ------------------------- Closes Document -------------------------
    close(D);
    word2pdf(path);
end

function generateReportPWV(path, handles)
    % Generates reports with user data, variable data, and signals for
    % Local PWV variable
    % Input:
    %   - handles: Data struct with data of current user
    %   - path: Path where report will be save 
    % Output: Report generated and saved in the folder. Two reports are
    % generated, one in a docx file and the other in a pdf file
    
    makeDOMCompilable();
    import mlreportgen.dom.*
    % Fill in the fields in the template and generate a new file for the user
    D = Document(path, 'docx', 'ReportTemplates\PWVTemplate.dotx');
    open(D);
    
    % ------------------------- User Informations -------------------------
    % User ID
    moveToNextHole(D);
    append(D, num2str(handles.userID));
    
    % User Name
    moveToNextHole(D);
    append(D, handles.userName);
    
    % Data of Birth
    moveToNextHole(D);
    append(D, handles.userBirthday);
    
    % Age
    moveToNextHole(D);
    append(D, handles.userAge);
    
    % Mass
    moveToNextHole(D);
    append(D, num2str(handles.userMass));
    
    % Height
    moveToNextHole(D);
    append(D, num2str(handles.userHeight));
    
    % Body Mass Index
    moveToNextHole(D);
    append(D, num2str(handles.userBMI));
    
    % Gender
    if strcmp(handles.userGender, 'Male') % Translates English to Portuguese
        userGender = 'Masculino';
    else
        userGender = 'Feminino';
    end
    moveToNextHole(D);
    append(D, userGender);
    
    % Skin Type
    moveToNextHole(D);
    append(D, num2str(handles.userSkin));
    
    % ------------------------- Physiological Variable -------------------------
    % PTT
    moveToNextHole(D);
    append(D, num2str(handles.PTT*1000));
    
    % Distance between two ROIs
    moveToNextHole(D);
    append(D, num2str(handles.distance));
    
    % PWV
    moveToNextHole(D);
    append(D, num2str(handles.PWV));
    
    % SBP
    moveToNextHole(D);
    append(D, num2str(handles.SBP));
    
    % DBP
    moveToNextHole(D);
    append(D, num2str(handles.DBP));
    
    % ------------------------- Signal Acquisition and Processing -------------------------
    % Acquisition Frequency
    moveToNextHole(D);
    append(D, num2str(handles.videoFPS));
    
    % Interpolation Frequency
    moveToNextHole(D);
    append(D, num2str(handles.interpolation));
    
    % Acquisition Time
    moveToNextHole(D);
    append(D, num2str(handles.videoSize));
    
    % ------------------------- Signals Metrics ------------------------- 
    % Signal Quality
    % Translation of English to Portuguese
    if strcmp(handles.signal_quality_final, 'Excellent')
        signalQuality = 'Excelente';
    else
        if strcmp(handles.signal_quality_final, 'Good')
            signalQuality = 'Bom';
        else
            if strcmp(handles.signal_quality_final, 'Bad')
                signalQuality = 'Ruim';
            end
        end
    end
    moveToNextHole(D);
    append(D, signalQuality);   
    
    % SNR Distal
    moveToNextHole(D);
    append(D, num2str(round(handles.SNRDistal, 2)));  
    
    % SNR Proximal
    moveToNextHole(D);
    append(D, num2str(round(handles.SNRProximal, 2)));  
    
    % ------------------------- Graphs of Signals -------------------------
    % Signal graph
    p = mlreportgen.dom.Image('temp/signalGraph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);    
    
    % Time Difference Graph
    p = mlreportgen.dom.Image('temp/timeDifferenceGraph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p); 
    
    % Phase Difference Graph
    p = mlreportgen.dom.Image('temp/phaseDifferenceGraph.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);
    
    % ------------------------- Closes Document -------------------------
    close(D);
    word2pdf(path);
end

function generateReportHR(path, handles)
    % Generates reports with user data, variable data, and signals for
    % Local PWV variable
    % Input:
    %   - handles: Data struct with data of current user
    %   - path: Path where report will be save 
    % Output: Report generated and saved in the folder. Two reports are
    % generated, one in a docx file and the other in a pdf file
    
    makeDOMCompilable();
    import mlreportgen.dom.*
    % Fill in the fields in the template and generate a new file for the user
    D = Document(path, 'docx', 'ReportTemplates\HR_HRV_Template.dotx');
    open(D);
    
    % ------------------------- User Informations -------------------------
    % User ID
    moveToNextHole(D);
    append(D, num2str(handles.userID));
    
    % User Name
    moveToNextHole(D);
    append(D, handles.userName);
    
    % Data of Birth
    moveToNextHole(D);
    append(D, handles.userBirthday);
    
    % Age
    moveToNextHole(D);
    append(D, handles.userAge);
    
    % Mass
    moveToNextHole(D);
    append(D, num2str(handles.userMass));
    
    % Height
    moveToNextHole(D);
    append(D, num2str(handles.userHeight));
    
    % Gender
    if strcmp(handles.userGender, 'Male') % Translates English to Portuguese
        userGender = 'Masculino';
    else
        userGender = 'Feminino';
    end
    moveToNextHole(D);
    append(D, userGender);
    
    % Skin Type
    moveToNextHole(D);
    append(D, num2str(handles.userSkin));
    
    % ------------------------- Physiological Variable -------------------------
    % Mean HR
    moveToNextHole(D);
    append(D, num2str(round(mean(handles.heart_rate))));
    
%     % Mean HRV
%     moveToNextHole(D);
%     append(D, num2str(round(mean(handles.heart_rate))));
    
    % ------------------------- Signal Acquisition and Processing -------------------------
    % Acquisition Frequency
    moveToNextHole(D);
    append(D, num2str(handles.videoFPS));
    
    % Interpolation Frequency
    moveToNextHole(D);
    append(D, num2str(handles.interpolation));
    
    % Acquisition Time
    moveToNextHole(D);
    append(D, num2str(handles.videoSize));
    
    % ------------------------- Graphs of Signals -------------------------
    % HR Graph
    figure('Name','HR_Plot','NumberTitle','off', 'visible','off')
    if(handles.windowSize == handles.videoSize)
        plot([handles.x_HR-1 handles.x_HR], [handles.heart_rate handles.heart_rate]);
        axis([handles.windowSize-1 handles.videoSize handles.lowerFrequency*60 handles.upperFrequency*60]);
    else
        plot(handles.x_HR, handles.heart_rate);
        axis([handles.windowSize handles.videoSize handles.lowerFrequency*60 handles.upperFrequency*60]);
    end
    title('Frequência Cardíaca');
    xlabel('Tempo (s)');
    ylabel('Batidas por minuto (BPM)');
    saveas(gcf, 'Temp/HR_Plot.png');
    close 'HR_Plot';
    
    p = mlreportgen.dom.Image('Temp/HR_Plot.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);  
    
    % Frequency
    figure('Name','Frequency_Plot','NumberTitle','off', 'visible','off')
    plot(handles.plot_frequency(2,:), handles.plot_frequency(1,:));
    title('Magnitude');
    xlabel('Frequência (Hz)');
    ylabel('Amplitude (dB)');
    
    saveas(gcf, 'Temp/Frequency_Plot.png');
    close 'Frequency_Plot';
    
    p = mlreportgen.dom.Image('Temp/Frequency_Plot.png');
    p.Width = '25cm';
    p.Height = '15cm';
    moveToNextHole(D);
    append(D, p);  
       
    % ------------------------- Closes Document -------------------------
    close(D);
    word2pdf(path);
end

function word2pdf(path)

    % Word to PDF conversion.
    % Input:
    %   - path: path where the report (docx) is saved
    % Output
    %   - Report in Word converted to PDF.

    % ------------------------- Word to pdf Conversion -------------------------
    filename =  strcat([path '.docx']);
    pdf_filename = strcat([path '.pdf']);
    
    % Create COM server
    actx_word = actxserver('Word.Application');
    actx_word.Visible = true;
    % Open existing document
    word_handle = invoke(actx_word.Documents,'Open',filename);
        
    % Save as PDF
    invoke(word_handle,'ExportAsFixedFormat',pdf_filename,'wdExportFormatPDF');
    
    % Close the window
    invoke(word_handle,'Close');
    % Quit Word
    invoke(actx_word,'Quit');
    % Close Word and terminate ActiveX
    delete(actx_word);
end