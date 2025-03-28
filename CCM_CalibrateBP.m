
function varargout = CCM_CalibrateBP(varargin)
% CCM_CALIBRATEBP MATLAB code for CCM_CalibrateBP.fig
%      CCM_CALIBRATEBP, by itself, creates a new CCM_CALIBRATEBP or raises the existing
%      singleton*.
%
%      H = CCM_CALIBRATEBP returns the handle to a new CCM_CALIBRATEBP or the handle to
%      the existing singleton*.
%
%      CCM_CALIBRATEBP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CCM_CALIBRATEBP.M with the given input arguments.
%
%      CCM_CALIBRATEBP('Property','Value',...) creates a new CCM_CALIBRATEBP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CCM_CalibrateBP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CCM_CalibrateBP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CCM_CalibrateBP

% Last Modified by GUIDE v2.5 20-Nov-2020 09:35:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CCM_CalibrateBP_OpeningFcn, ...
                   'gui_OutputFcn',  @CCM_CalibrateBP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% ---------------------------- Configurations -----------------------------
% --- Executes just before CCM_CalibrateBP is made visible.
function CCM_CalibrateBP_OpeningFcn(hObject, eventdata, handles, varargin)
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(hObject,'JavaFrame'); % Remove if Javaframe becomes obsolete
javaFrame.setFigureIcon(javax.swing.ImageIcon([pwd,'\splash.png']));

clc;

% Interface configuration 
set(handles.popupGraph, 'enable', 'off');
set(handles.popupCurveSelect, 'enable', 'off');
set(handles.popupDegreeSelect, 'enable', 'off');
set(handles.textBestEqSBP, 'string', '');
set(handles.popupVariable, 'enable', 'off');
set(handles.pushbutton_StartFit, 'enable', 'off');
set(handles.pushbutton_StartBPCalibrate, 'enable', 'off');
set(handles.popupFitMetric, 'enable', 'off');
set(handles.radiobutton_OperationMethod, 'enable', 'off');
set(handles.pushbutton_BlandAltman, 'enable', 'off');

% Toolbar of axes
handles.axesSBP.Toolbar.Visible = 'on';
handles.axesDBP.Toolbar.Visible = 'on';

% Tables and other variables
handles.tableBP = [];
handles.tableBP_PWV = [];

handles.eqDBP = '';
handles.corrDBP = 0;
handles.pDBP = 0;
handles.varDBP = '';

handles.eqSBP = '';
handles.corrSBP = 0;
handles.pSBP = 0;
handles.varSBP = '';

handles.SBP_Estimated = [];
handles.DBP_Estimated = [];

% Reads the PWV and PTT table from disk
try
    handles.tablePWV = readtable('Files/PTT_PWV_Table.xlsx');
    handles.tablePWV.PTT = str2double(handles.tablePWV.PTT);
catch
    handles.tablePWV = [];
end


dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'CCM_main'));
if (isempty(mainGuiInput)) ...
        || (length(varargin) <= mainGuiInput) ...
        || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Remember the handle, and adjust our position
    handles.CCMMain = varargin{mainGuiInput+1};
    
    % Obtain handles using GUIDATA with the caller's handle
    %     mainHandles = guidata(handles.CCMMain);
    % Set the edit text to the String of the main GUI's button
    %     set(handles.editChangeMe, 'String', ...
    %         get(mainHandles.buttonSettings, 'String'));
    
    % Position to be relative to parent:
    %     parentPosition = getpixelposition(handles.CCMMain);
    %     currentPosition = get(hObject, 'Position');
    %     % Set x to be directly in the middle, and y so that their tops align.
    %     newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
    %     newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
    %     %newY = parentPosition(2) + (parentPosition(4) - currentPosition(4));
    %     newW = currentPosition(3);
    %     newH = currentPosition(4);
    %
    %     set(hObject, 'Position', [newX, newY, newW, newH]);
end

% Update handles structure
guidata(hObject, handles);

% Update handles structure
guidata(hObject, handles);

if dontOpen
    disp('-----------------------------------------------------');
    disp('Improper input arguments. Pass a property value pair')
    disp('whose name is "CCM_main" and value is the handle')
    disp('to the CCM_main figure, e.g:');
    disp('   x = CCM_main()');
    disp('   CCM_UserConfiguration(''CCM_main'', x)');
    disp('-----------------------------------------------------');
else
    uiwait(hObject);
end

% UIWAIT makes CCM_CalibrateBP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CCM_CalibrateBP_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.CCMMain;% [];
delete(hObject);
% ---------------------------- Configurations -----------------------------



% ---------------------------- Button and GUI elements --------------------
% Buttons
% --- Executes on button press in pushbutton_LoadBPTable.
function pushbutton_LoadBPTable_Callback(hObject, eventdata, handles)

    if size(handles.tablePWV, 2) > 0 % PWV Table was created, were captured PWV with software
        
        % Load table with SBP and DBP values
        [file, path] = uigetfile({'*.xlsx'; '*.csv'});
        file = strcat([path, file]);

        % Configures the mouse pointer, such as a loading pointer
        oldpointer = get(handles.figure1, 'pointer');
        set(handles.figure1, 'pointer', 'watch');
        drawnow;

        if ~isempty(file) % BP table was not loaded
    
            handles.tableBP = readtable(file);
            
            % GUI configuration
            set(handles.textBestEqSBP, 'string', '');
            set(handles.textBestEqDBP, 'string', '');
            
            set(handles.pushbutton_StartFit, 'enable', 'on');
            set(handles.popupVariable, 'enable', 'on');
            set(handles.popupGraph, 'enable', 'off');
            set(handles.pushbutton_BlandAltman, 'enable', 'off');
            
            set(handles.radiobutton_OperationMethod, 'enable', 'on');
            set(handles.pushbutton_StartBPCalibrate, 'enable', 'off');
            
            if get(handles.radiobutton_OperationMethod, 'value') == 0
                set(handles.popupFitMetric, 'enable', 'off');
                set(handles.popupCurveSelect, 'enable', 'on');
                set(handles.popupDegreeSelect, 'enable', 'on');
            else
               set(handles.popupFitMetric, 'enable', 'on');
               set(handles.popupCurveSelect, 'enable', 'off');
               set(handles.popupDegreeSelect, 'enable', 'off'); 
            end

            
            
            % Clear axes
            cla(handles.axesSBP);
            cla(handles.axesDBP);

            % Plots
            % SBP
            axes(handles.axesSBP);
            plot(handles.axesSBP, handles.tableBP.SBP, 'o', 'LineWidth', 3);
            xlabel('Sample');
            ylabel('Systolic Blood Pressure (mmHg)');
            title('Systolic Blood Pressure (SBP) - Samples');
            
            % DBP
            axes(handles.axesDBP);
            plot(handles.tableBP.DBP, 'o', 'LineWidth', 3);
            xlabel('Sample');
            ylabel('Diastolic Blood Pressure (mmHg)');
            title('Diastolic Blood Pressure (DBP) - Samples');
            
            % Enable tool bar in axes
            handles.axesSBP.Toolbar.Visible = 'on';
            handles.axesDBP.Toolbar.Visible = 'on';
        end
        
    else % PWV Table wasn't created, weren't captured PWV with software
        msgbox('The PWV table was not found! Capture PVW with software');
    end
    
    % Returns the normal mouse pointer
    set(handles.figure1, 'pointer', oldpointer);
guidata(hObject, handles);

% --- Executes on button press in pushbutton_StartFit.
function pushbutton_StartFit_Callback(hObject, eventdata, handles)
    % Configures the mouse pointer, such as a loading pointer
    oldpointer = get(handles.figure1, 'pointer');
    set(handles.figure1, 'pointer', 'watch')
    drawnow;
    
    handles.tableBP_PWV = tableOrganization (handles.tableBP, handles.tablePWV);
    
    % If the table is not filled, that is, their IDs are not matching.
    if isempty(handles.tableBP_PWV)
        msgbox('Error. The table is not consistent! Check the BP table IDs');
    else
        
        method_choice = get(handles.radiobutton_OperationMethod, 'value');
        variable_choice = get(handles.popupVariable, 'value');
        
        if variable_choice == 1
            handles.varDBP = 'PTT';
            handles.varSBP = 'PTT';
            x = handles.tableBP_PWV.PTT;
        else
            handles.varDBP = 'PWV';
            handles.varSBP = 'PWV';
            x = handles.tableBP_PWV.PWV;
        end
        
        if method_choice == 0 % Manual
            
            % Gets curve and degree
            curve_choice = get(handles.popupCurveSelect, 'value');
            n = get(handles.popupDegreeSelect, 'value');

            switch curve_choice
                case 1  % Polinomyal
                    [handles.eqSBP, handles.corrSBP, handles.pSBP, handles.SBP_Estimated] = fit_linear(x, ....
                    handles.tableBP_PWV.SBP, handles.varSBP, 'SBP', n);

                    [handles.eqDBP, handles.corrDBP, handles.pDBP, handles.DBP_Estimated] = fit_linear(x, ....
                    handles.tableBP_PWV.DBP, handles.varDBP, 'DBP', n);
                case 2  % Inversaly
                    [handles.eqSBP, handles.corrSBP, handles.pSBP, handles.SBP_Estimated] = fit_ratio(x, ....
                    handles.tableBP_PWV.SBP, handles.varSBP, 'SBP', n);

                    [handles.eqDBP, handles.corrDBP, handles.pDBP, handles.DBP_Estimated] = fit_ratio(x, ....
                    handles.tableBP_PWV.DBP, handles.varDBP, 'DBP', n);
                case 3  % Logarithmic
                    [handles.eqSBP, handles.corrSBP, handles.pSBP, handles.SBP_Estimated] = fit_ln(x, ....
                    handles.tableBP_PWV.SBP, handles.varSBP, 'SBP');

                    [handles.eqDBP, handles.corrDBP, handles.pDBP, handles.DBP_Estimated] = fit_ln(x, ....
                    handles.tableBP_PWV.DBP, handles.varDBP, 'DBP');
                case 4  % Exponential
                    [handles.eqSBP, handles.corrSBP, handles.pSBP, handles.SBP_Estimated] = fit_exponential(x, ....
                    handles.tableBP_PWV.SBP, handles.varSBP, 'SBP', n);

                    [handles.eqDBP, handles.corrDBP, handles.pDBP, handles.DBP_Estimated] = fit_exponential(x, ....
                    handles.tableBP_PWV.DBP, handles.varDBP, 'DBP', n);
            end
        else % Automatic
            
            choice_metric =  get(handles.popupFitMetric, 'value');
            
            % Define metric function (stop criter) and saves in fun 
            if choice_metric == 1 % Root Mean Square Error
                str = '@(x1, x2) sqrt(mean((x1-x2).^2))';
                fun = str2func(str);
            else % Mean Suqared Error
                if choice_metric == 2
                    str = '@(x1, x2) mean((x1-x2).^2)';
                    fun = str2func(str);
                else
                    str = '@(x1, x2) mean(abs(x1-x2))';
                    fun = str2func(str);
                end
            end
            
             [handles.eqSBP, handles.corrSBP, handles.pSBP, handles.SBP_Estimated] = ....
                 select_best(x, handles.tableBP_PWV.SBP, handles.varSBP, 'SBP', fun);
             [handles.eqDBP, handles.corrDBP, handles.pDBP, handles.DBP_Estimated] = ....
                 select_best(x, handles.tableBP_PWV.DBP, handles.varDBP, 'DBP', fun);
        end
        
        % Enable Calibrate Button and set equation strings
        set(handles.pushbutton_StartBPCalibrate, 'enable', 'on');
        
        str = sprintf([handles.eqSBP, newline, 'Correlation: ', num2str(handles.corrSBP, 3)]);
        set(handles.textBestEqSBP, 'string', strcat(['SBP = ', str]));
        
        str = sprintf([handles.eqDBP, newline, 'Correlation: ', num2str(handles.corrDBP, 3)]);
        set(handles.textBestEqDBP, 'string', strcat(['DBP = ', str]));

        
        if get(handles.popupGraph, 'value') == 1     % Curve Graph
            plot_graph(handles);
        else
            if get(handles.popupGraph, 'value') == 2 % Error Graph
                plot_errorGraph(handles);
            end
        end
    end
    set(handles.figure1, 'pointer', oldpointer);
    set(handles.popupGraph, 'enable', 'on');
    set(handles.pushbutton_BlandAltman, 'enable', 'on');
    
guidata(hObject, handles);

% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)

uiresume(handles.figure1);

% --- Executes on button press in pushbutton_StartBPCalibrate.
function pushbutton_StartBPCalibrate_Callback(hObject, eventdata, handles)
clc;
    % Generates the .m file with equations of SBP and DBP
    
    oldpointer = get(handles.figure1, 'pointer');
    set(handles.figure1, 'pointer', 'watch');
    drawnow;
    
%     str = strcat(['function [SBP, DBP] = PWV_PTT_to_BP(PTT, PWV)\n\t%% Correlation SBP: ' ....
%     num2str(handles.corrSBP,3) '\n\tSBP = ' ....
%     handles.eqSBP ';\n\t%% Correlation DBP: ' num2str(handles.corrDBP, 3) '\n\tDBP = ' ....
%     handles.eqDBP ';\nend\n\n']);
    try 
        str = strcat([handles.eqSBP '\n' handles.eqDBP]);

        fileID = fopen('BP_equations.txt','w');
        fprintf(fileID, str);
        fclose(fileID);

        generateReport([pwd, '\BPReports'], 'BP', handles);
        % Returns the normal mouse pointer
        set(handles.figure1, 'pointer', oldpointer);
        msgbox('Blood Pressure calibration completed');
    catch ME
        msgbox(ME.identifier);
    end
guidata(hObject, handles);

% Combox
% --- Executes on selection change in popupGraph.
function popupGraph_Callback(hObject, eventdata, handles)   
    choice = get(hObject, 'value');
    if choice == 1 % Graph with the curve and samples
       plot_graph(handles); 
    else 
        plot_errorGraph(handles);
    end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupGraph_CreateFcn(hObject, eventdata, handles)
    str = {'Curve' 'Error'};
    set(hObject,'string',str);
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
guidata(hObject, handles);

% --- Executes on selection change in popupCurveSelect.
function popupCurveSelect_Callback(hObject, eventdata, handles)
    set(handles.popupDegreeSelect, 'enable', 'on');
    set(handles.popupDegreeSelect, 'value', 1);

    choice = get(hObject, 'value');
    str = {}; % Degree number
    
    % Define degree number
    switch choice
        case 1
            str = {'1' '2' '3' '4' '5'};
        case 2
            str = {'1' '2'};
        case 3
           str = {''};
           set(handles.popupDegreeSelect, 'enable', 'off');
        case 4
            str = {'1' '2'};
    end
    
    set(handles.popupDegreeSelect, 'string', str);
    set(handles.popupDegreeSelect, 'value', 1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupCurveSelect_CreateFcn(hObject, eventdata, handles)

    str = {'Polynomial' 'Inversely' 'Logarithmic' 'Exponential'};
    set(hObject, 'string', str);
    set(hObject, 'value', 1);
        
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
guidata(hObject, handles);

% --- Executes on selection change in popupDegreeSelect.
function popupDegreeSelect_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupDegreeSelect_CreateFcn(hObject, eventdata, handles)

    str = {'1' '2' '3' '4' '5'};
    set(hObject, 'string', str);
    set(hObject,'value', 1);
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
guidata(hObject, handles);

% --- Executes on selection change in popupVariable.
function popupVariable_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupVariable_CreateFcn(hObject, eventdata, handles)
    str = {'PTT' 'PWV'};
    set(hObject, 'string', str);
    set(hObject,'value', 1);
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
guidata(hObject, handles);

% --- Executes on selection change in popupFitMetric.
function popupFitMetric_Callback(hObject, eventdata, handles)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupFitMetric_CreateFcn(hObject, eventdata, handles)
    str = {'Root Mean Square Error' 'Mean Squared Error' 'Mean Abosolute Error'};
    set(hObject, 'string', str);
    set(hObject,'value', 1);
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
guidata(hObject, handles);

% RadioButton
function radiobutton_OperationMethod_Callback(hObject, eventdata, handles)
     choice = get(handles.radiobutton_OperationMethod, 'value');
     
     if choice == 1
        set(handles.popupFitMetric, 'enable', 'on');
        set(handles.popupCurveSelect, 'enable', 'off');
        set(handles.popupDegreeSelect, 'enable', 'off');
     else 
        set(handles.popupFitMetric, 'enable', 'off');
        set(handles.popupCurveSelect, 'enable', 'on');
        set(handles.popupDegreeSelect, 'enable', 'on');
     end
guidata(hObject, handles);  
% ---------------------------- Button and GUI elements --------------------



% --------------------------- Others --------------------------------------
function plot_graph(handles)
    cla(handles.axesSBP);
    cla(handles.axesDBP);
    
    % -------------------------- SBP Information --------------------------
    PTT_temp = min(handles.tableBP_PWV.PTT):0.0001: max(handles.tableBP_PWV.PTT);
    PWV_temp = min(handles.tableBP_PWV.PWV):0.01: max(handles.tableBP_PWV.PWV);

    if strcmp(handles.varSBP, 'PWV')
        v = handles.tableBP_PWV.PWV;
        temp = PWV_temp;
        variable = 'Pulse Wave Velocity (m/s)';
    else
        v = handles.tableBP_PWV.PTT;
        temp = PTT_temp;
        variable = 'Pulse Transit Time (s)';
    end
    
    % Convert string convert the string that represents the curve into a function
    str = strcat(['@(', handles.varSBP, ')', handles.eqSBP]);
    fun = str2func(str);
    SBP = fun(temp);
    
    str = strcat(['@(', handles.varDBP,')', handles.eqDBP]);
    fun = str2func(str);
    DBP = fun(temp);
    
    % ----- Plot ------
    axes(handles.axesSBP);
    hold on;
    
    plot(v, handles.tableBP_PWV.SBP, 'o', 'LineWidth', 3);
    plot(temp, SBP, '-', 'LineWidth', 3);
    
    s = sort(handles.tableBP_PWV.SBP);
    text(temp(round(end/2)), s(round(end/2)), ....
        sprintf(['r = ', num2str(handles.corrSBP, 2), newline, ....
        'p = ', num2str(handles.pSBP, 2)]), 'FontSize', 15);
    
    xlabel(variable);
    ylabel('Systolic Blood Pressure (mmHg)');
    title(sprintf(['SBPx', handles.varSBP]));
    legend('Samples', 'Curve');
    hold off;


    % -------------------------- DBP Information --------------------------
%     if strcmp(handles.varDBP, 'PWV')
%         v = handles.tableBP_PWV.PWV;
%         temp = PWV_temp;
%     else
%         v = handles.tableBP_PWV.PTT;
%         temp = PTT_temp;
%     end
    
    % ----- Plot ------
    axes(handles.axesDBP)
    hold on;
    plot(v, handles.tableBP_PWV.DBP, 'o', 'LineWidth', 3);
    plot(temp, DBP, '-', 'LineWidth', 3);
    
    s = sort(handles.tableBP_PWV.DBP);

    text(temp(round(end/2)), s(round(end/2)), ....
        sprintf(['r = ', num2str(handles.corrDBP, 2), newline, ....
        'p = ', num2str(handles.pDBP, 2)]), 'FontSize', 15);
    
    xlabel(variable);
    ylabel('Diastolic Blood Pressure (mmHg)');
    title(sprintf(['DBPx', handles.varSBP]));
    legend('Samples', 'Curve');
    hold off;
    
    handles.axesSBP.Toolbar.Visible = 'on';
    handles.axesDBP.Toolbar.Visible = 'on';
       
function plot_blandAltman(handles)

    BlandAltman(handles.tableBP_PWV.SBP, handles.SBP_Estimated, ....
    {'SBP', 'SBP Estimated'}, 'Bland Altman SBP', {'SBP' 'SBP Estimated'}, ....
    'corrInfo', {'n','SSE','r','eq'});
            
    BlandAltman(handles.tableBP_PWV.DBP, handles.DBP_Estimated, ....
    {'DBP', 'DBP Estimated'}, 'Bland Altman DBP', {'DBP' 'DBP Estimated'}, ....
    'corrInfo', {'n','SSE','r','eq'});

% --- Executes on button press in pushbutton_BlandAltman.
function pushbutton_BlandAltman_Callback(hObject, eventdata, handles)
    plot_blandAltman(handles);
guidata(hObject, handles);  

function plot_errorGraph(handles)
    cla(handles.axesSBP);
    cla(handles.axesDBP);
    
    % -------------------------- SBP Information --------------------------
    error_SBP = round(handles.SBP_Estimated - handles.tableBP_PWV.SBP, 3);
    abs_error_SBP = abs(error_SBP);
    rmse_SBP = sqrt(mean(error_SBP.^2)); 
    
    ame =  mean(abs_error_SBP);
    
    axes(handles.axesSBP)
    bar(abs_error_SBP);
    
    title('Absolute Error x Sample - SBP');
    xlabel('Sample');
    ylabel('Absolute Error (mmHg)');
    
    legend(sprintf(['Absolute Error', newline, 'AME: ', num2str(ame, 2), ....
        newline, 'RMSE: ', num2str(rmse_SBP, 2)]));
    
    % -------------------------- DBP Information --------------------------
    error_DBP = round(handles.DBP_Estimated - handles.tableBP_PWV.DBP, 3);
    abs_error_DBP = abs(error_DBP);
    rmse_DBP = sqrt(mean(error_DBP.^2));
        
    ame = mean(abs_error_DBP);
    
    axes(handles.axesDBP)
    bar(abs_error_DBP);
    
    title('Absolute Error x Sample - DBP');
    xlabel('Sample');
    ylabel('Absolute Error (mmHg)');
    
    legend(sprintf(['Absolute Error', newline, 'AME: ', num2str(ame, 2), ....
        newline, 'RMSE: ', num2str(rmse_DBP, 2)]));
    
    handles.axesSBP.Toolbar.Visible = 'on';
    handles.axesDBP.Toolbar.Visible = 'on';
    
function T = tableOrganization (SBP_DBP, PTT_PWV)
    % Creates a table with specified fields
    % ID -> User identifier
    % PTT -> Pulse Time Transition
    % PWV -> Pulse Wave Velocity
    % SBP -> Sistolyc Blood Pressure
    % DBP -> Diastolic Blood Pressure
    % Values are combined from the ID
    
    % Input:
    %   - SBP_DBP: Table with SBP, DBP, and ID information of user
    %   - PTT_PWV: Table with PTT, PWV, and ID information of user
    % Outpu:
    %   - T: Table with ID, SBP, DBP, PTT, and PWV information of user

    T = table(0,0,0,0,0,'VariableNames', {'ID', 'PTT', 'PWV', 'SBP', 'DBP'});

    for i = 1: size(PTT_PWV, 1)
        for j = 1: size(SBP_DBP, 1)
            % If the IDs are the same, then the values are combined to 
            % generate the complete table
            if isequal(PTT_PWV(i, :).ID, SBP_DBP(j, :).ID)
                T = [T; table(PTT_PWV(i, :).ID,  PTT_PWV(i, :).PTT, PTT_PWV(i, :).PWV, ....
                    SBP_DBP(j, :).SBP, SBP_DBP(j, :).DBP, ....
                    'VariableNames', {'ID', 'PTT', 'PWV', 'SBP', 'DBP'})];
                SBP_DBP(j,:) = [];
                break;
            end
        end
    end
    T(1,:) = []; % Remove frist row
% --------------------------- Others --------------------------------------



% --------------------------- Curves -------------------------------------- 
% --- Executes on button press in radiobutton_OperationMethod.
function [eq, c, p, pred] = select_best(x, y, variableX, variableY, fun)
    % Receive the values of the variables and adjust a curve that best fits
    % fits the data. The curves are The curves are those mentioned in the 
    % calibrate function. Returns then with menor metric defined by fun function.
    % For example, metric is RMSE, then the fun is RMSE function and code
    % find the curve what present lower RMSE
    
    % Input:
    %   - x: Values of x;
    %   - y: values of y;
    %   - variableX: string with the name of the variable independent;
    %   - variableY: string with the name of the variable dependent
    %   - fun: Stop metric function
    % Output:
    %   - eq: string with the equation of the best line;
    %   - c: Pearson Coeficient Correlation Value
    %   - p: Spearman Coeficient Correlation Value
    %   - pred: Vector with the predicted values with the curve
    
    % Metric selection inicialization
    [eqTemp, corrTemp, pTemp, predTemp] = fit_linear(x, y, variableX, variableY, 1);
    
    eq = eqTemp;
    c = corrTemp;
    p = pTemp;
    pred = predTemp;
    
    metric = fun(y, predTemp);
    bestMetric = metric;
    
    % ------ Polymonial --------
    % Polynomial 1st to 5th
    for i = 2:5
        [eqTemp, corrTemp, pTemp, predTemp] = fit_linear(x, y, variableX, variableY, i);
        
        metric = fun(y, predTemp);
        
        if metric < bestMetric
            bestMetric = metric;
            eq = eqTemp;
            c = corrTemp;
            p = pTemp;
            pred = predTemp;
        end
        
    end
    
    % ------ Ratio --------
    % Ratio 1st degree
    [eqTemp, corrTemp, pTemp, predTemp] = fit_ratio(x, y, variableX, variableY, 1);
    metric = fun(y, predTemp);
    if metric < bestMetric
        bestMetric = metric;
        eq = eqTemp;
        c = corrTemp;
        p = pTemp;
        pred = predTemp;
    end
        
    % Ratio 2nd degree
    [eqTemp, corrTemp, pTemp, predTemp] = fit_ratio(x, y, variableX, variableY, 2);
    metric = fun(y, predTemp);
    if metric < bestMetric
        bestMetric = metric;
        eq = eqTemp;
        c = corrTemp;
        p = pTemp;
        pred = predTemp;
    end

    % ------ Logarithmic --------
    % Logarithmic
    [eqTemp, corrTemp, pTemp, predTemp] = fit_ln(x, y, variableX, variableY);
    metric = fun(y, predTemp);
    if metric < bestMetric
        bestMetric = metric;
        eq = eqTemp;
        c = corrTemp;
        p = pTemp;
        pred = predTemp;
    end
    
    % ------ Exponential --------    
    % Exponential 1st degree
    [eqTemp, corrTemp, pTemp, predTemp] = fit_exponential(x, y, variableX, variableY, 1);
    metric = fun(y, predTemp);
    if metric < bestMetric
        bestMetric = metric;
        eq = eqTemp;
        c = corrTemp;
        p = pTemp;
        pred = predTemp;
    end
        
    % Exponential 2nd degree
    [eqTemp, corrTemp, pTemp, predTemp] = fit_exponential(x, y, variableX, variableY, 1);
    metric = fun(y, predTemp);
    if metric < bestMetric
        eq = eqTemp;
        c = corrTemp;
        p = pTemp;
        pred = predTemp;
    end
    
function [eq, c, p, pred] = fit_linear(x, y, variableX, variableY, n)
    % Receive the values of the variables and adjust a curve that best fits
    % fits the data. The curves range from order 1 to order 5. Returns
    % then the curve that has the highest correlation coefficient between the
    % data.
    % Input:
    %   - x: Values of x;
    %   - y: values of y;
    %   - variableX: string with the name of the variable independent;
    %   - variableY: string with the name of the variable dependent
    % Output:
    %   - eq: string with the equation of the best line;
    %   - corr: Correlation Value
    %   - pred: Vector with the predicted values with the curve

    reg_str = '';

    coef = polyfit(x,y,n);
    pred = 0;
    
    for i = 1: size(coef, 2) - 1
        pred = pred + x*coef(i).^(size(coef, 2) - i);
        reg_str = strcat([reg_str sprintf('%.3f*%s.^%.f + ', coef(i), ....
            variableX, size(coef, 2) - i)]);
    end
    
    pred = pred + coef(end);
    reg_str = strcat([reg_str sprintf('%.3f', coef(end))]);
    
    c = corrcoef(y, pred);
    p = corr(y, pred, 'Type', 'Spearman');
    
    eq = reg_str;
    c = c(1, 2);
    
function [eq, c, p, pred] = fit_ratio(x, y, variableX, variableY, n)
    % Fits the 1st and 2nd degree ratio equation in datas

    % Input:
    %   - x: Values of x;
    %   - y: values of y;
    %   - variableX: string with the name of the variable independent;
    %   - variableY: string with the name of the variable dependent
    % Output:
    %   - eq: string with the equation of the best line;
    %   - corr: Correlation Value
    %   - pred: Vector with the predicted values with the curve
    
    if n == 1
        % Ratio 1st degree
        ft1 = fittype('a / x + b',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b'});
        f = fit(x, y, ft1, 'StartPoint',[100 100]);

        pred = f.a./x + f.b;

        c1 = corrcoef(y, pred);
        eq = strcat([num2str(f.a) './' variableX ' + ' num2str(f.b)]);
        c = c1(1, 2);
        p = corr(y, pred, 'Type', 'Spearman');
        
    else
        opt = fitoptions('Method', 'NonlinearLeastSquares', ...
                       'Lower', [0 0 0], ...
                       'Upper', [Inf Inf 2], ...
                       'StartPoint', [85 85 85]);
%         opt.StartPoint = [100, 100, 80, 80, 105, 105];
        
        ft2 =  fittype('a / (x - b).^2 + c',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b', 'c'}, 'options', opt);
        

        f = fit(x, y, ft2);

        pred = f.a./(x - f.b).^2 + f.c;

        c2 = corrcoef(y, pred);

        eq = strcat([num2str(f.a) './(' variableX ' - ' num2str(f.b) ').^2 + ' num2str(f.c)]);
        c = c2(1, 2);
        p = corr(y, pred, 'Type', 'Spearman');
    end
    
function [eq, c, p, pred] = fit_ln(x, y, variableX, variableY)
    % Fits the natural logarithm equation in datas

    % Input:
    %   - x: Values of x;
    %   - y: values of y;
    %   - variableX: string with the name of the variable independent;
    %   - variableY: string with the name of the variable dependent
    % Output:
    %   - eq: string with the equation of the best line;
    %   - corr: Correlation Value
    %   - pred: Vector with the predicted values with the curve
        
    % Natural logarithm
    ft1 = fittype('a*log(x) + b',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b'});
    f = fit(x, y, ft1, 'StartPoint',[100 100]);

    pred = f.a*log(x) + f.b;
    
    c1 = corrcoef(y, pred);
    eq = strcat([num2str(f.a) '*log(' variableX ') + ' num2str(f.b)]);
    c = c1(1, 2);
    p = corr(y, pred, 'Type', 'Spearman');
    
function [eq, c, p, pred] = fit_exponential(x, y, variableX, variableY, n)   
    % Fits the 1st and 2nd degree exponential equation in datas

    % Input:
    %   - x: Values of x;
    %   - y: values of y;
    %   - variableX: string with the name of the variable independent;
    %   - variableY: string with the name of the variable dependent
    % Output:
    %   - eq: string with the equation of the best line;
    %   - corr: Correlation Value
    %   - pred: Vector with the predicted values with the curve
    
    % Exponential 1st degree
    if n == 1
        f = fit(x, y,'exp1');
        pred = f.a*exp(f.b*x);

        c1 = corrcoef(y, pred);
        eq = strcat([num2str(f.a) '*exp(' num2str(f.b) '*' variableX ')']);
        c = c1(1, 2);
        p = corr(y, pred, 'Type', 'Spearman');
    else
        % Exponential 2nd degree
        f = fit(x, y,'exp2');
        pred = f.a*exp(f.b*x) + f.c*exp(f.d*x);

        c2 = corrcoef(y, pred);
        
        eq = strcat([num2str(f.a) '*exp(' num2str(f.b) '*' variableX ')' ....
                    ' + ' num2str(f.c) '*exp(' num2str(f.d) '*' variableX ')']);
        c = c2(1, 2);
        p = corr(y, pred, 'Type', 'Spearman');
    end
    
% References
%  KHONG, Wei Leong; RAO, Nittala Surya Venkata Kameswara; MARIAPPAN, Muralindran. 
%  Blood pressure measurements using non-contact video imaging techniques. 
%  2017 Ieee 2nd International Conference On Automatic Control And Intelligent Systems (i2cacis), 
%  [s.l.], p. 35-40, out. 2017. IEEE. http://dx.doi.org/10.1109/i2cacis.2017.8239029.

%  MUKKAMALA, Ramakrishna et al. Toward Ubiquitous Blood Pressure Monitoring via Pulse Transit Time: theory and practice. 
%  Ieee Transactions On Biomedical Engineering, [S.L.], v. 62, n. 8, p. 1879-1901, ago. 2015. 
%  Institute of Electrical and Electronics Engineers (IEEE). http://dx.doi.org/10.1109/tbme.2015.2441951.
% --------------------------- Curves --------------------------------------  
