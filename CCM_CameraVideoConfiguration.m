function varargout = CCM_CameraVideoConfiguration(varargin)
%CCM_PREFERENCES M-file for CCM_preferences.fig
%      CCM_PREFERENCES, by itself, creates a new CCM_PREFERENCES or raises the existing
%      singleton*.
%
%      H = CCM_PREFERENCES returns the handle to a new CCM_PREFERENCES or the handle to
%      the existing singleton*.
%
%      CCM_PREFERENCES('Property','Value',...) creates a new CCM_PREFERENCES using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to CCM_preferences_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CCM_PREFERENCES('CALLBACK') and CCM_PREFERENCES('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CCM_PREFERENCES.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CCM_preferences

% Last Modified by GUIDE v2.5 25-Oct-2020 01:35:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CCM_CameraVideoConfiguration_OpeningFcn, ...
    'gui_OutputFcn',  @CCM_CameraVideoConfiguration_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before CCM_CameraVideoConfiguration is made visible.
function CCM_CameraVideoConfiguration_OpeningFcn(hObject, eventdata, handles, varargin)
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(hObject,'JavaFrame'); % Remove if Javaframe becomes obsolete
javaFrame.setFigureIcon(javax.swing.ImageIcon([pwd,'\splash.png']));


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

if dontOpen
    disp('-----------------------------------------------------');
    disp('Improper input arguments. Pass a property value pair')
    disp('whose name is "CCM_main" and value is the handle')
    disp('to the CCM_main figure, e.g:');
    disp('   x = CCM_main()');
    disp('   CCM_CameraVideoConfiguration(''CCM_main'', x)');
    disp('-----------------------------------------------------');
else
    uiwait(hObject);
end


% --- Outputs from this function are returned to the command line.
function varargout = CCM_CameraVideoConfiguration_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.CCMMain;% [];
delete(hObject);

% --- Executes during object creation, after setting all properties.
function editChangeMe_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonOK.
function buttonOK_Callback(hObject, eventdata, handles)
if(ishandle(handles.CCMMain))
    mainHandles = guidata(handles.CCMMain);
    mainHandles.readVideo = handles.readVideo;
    mainHandles.upperFrequency = handles.upperFrequency;
    mainHandles.lowerFrequency = handles.lowerFrequency;
    mainHandles.webcamName = handles.webcamName;
    mainHandles.webcamList = handles.webcamList;
    mainHandles.videoFormat = handles.videoFormat;
    mainHandles.interpolation = handles.interpolation;
    mainHandles.saveVideoOpt = handles.saveVideoOpt;
    mainHandles.videoSize = handles.videoSize;
    mainHandles.videoFPS = handles.videoFPS;
    mainHandles.overlapSize = handles.overlapSize;
    mainHandles.windowSize = handles.windowSize;
    mainHandles.readVideo = handles.readVideo;
    mainHandles.faceDetectionUpdate = handles.faceDetectionUpdate;
    mainHandles.ROI = handles.ROI; 
    mainHandles.HRDetecMethod = handles.HRDetecMethod;
    mainHandles.HRVorBP = handles.HRVorBP;
    mainHandles.roiTrackingAM = handles.roiTrackingAM;
    mainHandles.distance = handles.distance;
    if(handles.readVideo)
        mainHandles.resolution = handles.resolution;
        mainHandles.firstFrame = handles.firstFrame;
        mainHandles.videoArchive = handles.videoArchive;
        mainHandles.fileName = handles.fileName;
    else
        mainHandles.firstFrame = [];
        mainHandles.videoArchive = [];
    end
end
guidata(handles.CCMMain, mainHandles);
uiresume(handles.figure1);


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);


% --- Executes on selection change in popupWindowSize.
function popupWindowSize_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.windowSize = str2double(str{val});
newOverlapRange = createStrWinOver(handles.windowSize-1, 0);
set(handles.popupOverlap, 'string', newOverlapRange);
set(handles.popupOverlap, 'Value', 1);
handles.overlapSize = str2double(newOverlapRange{1});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupWindowSize_CreateFcn(hObject, eventdata, handles)
str = createStrWinOver(60, 1);
set(hObject,'string',str);
set(hObject,'value',36); % 25 seconds
handles.windowSize = str2double(str{36});
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on selection change in popupOverlap.
function popupOverlap_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.overlapSize = str2double(str{val});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupOverlap_CreateFcn(hObject, eventdata, handles)
str = createStrWinOver(59, 0);
set(hObject,'string',str);
set(hObject,'value',36); % 24 seconds
handles.overlapSize = str2double(str{36});
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupLowerFrequency.
function popupLowerFrequency_Callback(hObject, eventdata, handles)
str = get(hObject, 'string');
val = get(hObject, 'value');
handles.lowerFrequency = str2double(str{val});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupLowerFrequency_CreateFcn(hObject, eventdata, handles)
str = createStrFreqLowUp(0.7, 2, 0.05);
set(hObject, 'string', str);
set(hObject, 'value', 2);
handles.lowerFrequency = 0.7;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupUpperFrequency.
function popupUpperFrequency_Callback(hObject, eventdata, handles)
str = get(hObject, 'string');
val = get(hObject, 'value');
handles.upperFrequency = str2double(str{val});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupUpperFrequency_CreateFcn(hObject, eventdata, handles)
str = createStrFreqLowUp(2, 5, 0.05);
set(hObject, 'string', str);
set(hObject, 'value', 41);
handles.upperFrequency = 4;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupInterpolation.
function popupInterpolation_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.interpolation = str2double(str{val});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupInterpolation_CreateFcn(hObject, eventdata, handles)
str = {'2000' '1000' '500' '250' '125'};
set(hObject,'string',str);
set(hObject,'value',3);
handles.interpolation = str2double(str{3});
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupHRDetecMethod.
function popupHRDetecMethod_Callback(hObject, eventdata, handles)
handles.HRDetecMethod = get(hObject, 'value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupHRDetecMethod_CreateFcn(hObject, eventdata, handles)
str = {'ICA' 'Fixed Color Channel'};
set(hObject, 'string', str);
set(hObject,'value', 1);
handles.HRDetecMethod = 1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupRoiTrackingAM.
function popupRoiTrackingAM_Callback(hObject, eventdata, handles)
handles.roiTrackingAM = get(hObject, 'value');
if handles.roiTrackingAM == 1
    set(handles.popupROIDetectionUpdate, 'enable', 'on');
    set(handles.popupROI, 'enable', 'on');
else
    set(handles.popupROIDetectionUpdate, 'enable', 'off');
    set(handles.popupROI, 'enable', 'off');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupRoiTrackingAM_CreateFcn(hObject, eventdata, handles)
str = {'Automatic' 'Manual'};
set(hObject, 'string', str);
handles.roiTrackingAM = 1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupROI.
function popupROI_Callback(hObject, eventdata, handles)
handles.ROI = get(hObject, 'value');
if handles.ROI ~= 4
    set(handles.popupROIDetectionUpdate, 'enable', 'on');
else
    set(handles.popupROIDetectionUpdate, 'enable', 'off');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupROI_CreateFcn(hObject, eventdata, handles)
str = {'Forehead' 'Cheek and Nose' 'Face' 'Hand'};
set(hObject, 'string', str);
set(hObject,'value', 1);
handles.ROI = 1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% --- Executes on selection change in popupROIDetectionUpdate.
function popupROIDetectionUpdate_Callback(hObject, eventdata, handles)
str = get(hObject, 'string');
val = get(hObject, 'value');
handles.faceDetectionUpdate = str2double(str{val});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupROIDetectionUpdate_CreateFcn(hObject, eventdata, handles)
str = {'0.5' '1' '1.5' '2' '2.5' '3'};
set(hObject, 'string', str);
set(hObject,'value', 2);
handles.faceDetectionUpdate = 1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupVariable.
function popupVariable_Callback(hObject, eventdata, handles)
handles.HRVorBP = get(hObject, 'value');
if handles.HRVorBP == 1 % HR
    set(handles.popupHRDetecMethod, 'enable', 'on');
    set(handles.popupInterpolation, 'enable', 'on');
    set(handles.popupROI, 'enable', 'on');
    set(handles.popupROIDetectionUpdate, 'enable', 'on');
    set(handles.popupRoiTrackingAM, 'enable', 'on');
    set(handles.editDistance, 'enable', 'off');
    
    set(handles.popupLowerFrequency, 'value', 2);
    handles.lowerFrequency = 0.75;
    set(handles.popupUpperFrequency, 'value', 41);
    handles.upperFrequency = 4;
else
    if handles.HRVorBP == 2 % BP
        set(handles.popupHRDetecMethod, 'enable', 'off');
        set(handles.popupHRDetecMethod, 'value', 2);
        handles.HRDetecMethod = 2;
        set(handles.popupInterpolation, 'enable', 'off');
        set(handles.popupWindowSize, 'enable', 'on');
        set(handles.popupOverlap, 'enable', 'on');
        set(handles.popupLowerFrequency, 'enable', 'on');
        set(handles.popupUpperFrequency, 'enable', 'on');
        set(handles.popupROI, 'enable', 'off');
        set(handles.popupROIDetectionUpdate, 'enable', 'off');
        set(handles.popupRoiTrackingAM, 'enable', 'off');
        set(handles.popupRoiTrackingAM, 'value', 2);
        handles.roiTrackingAM = 2;
        set(handles.editDistance, 'enable', 'off');

        set(handles.popupLowerFrequency, 'value', 2);
        handles.lowerFrequency = 0.75;
        set(handles.popupUpperFrequency, 'value', 41);
        handles.upperFrequency = 4;
    else 
        if handles.HRVorBP == 3  || handles.HRVorBP == 6 % PWV
            set(handles.popupHRDetecMethod, 'enable', 'off');
            set(handles.popupHRDetecMethod, 'value', 2);
            handles.HRDetecMethod = 2;
            set(handles.popupInterpolation, 'enable', 'on');
            set(handles.popupWindowSize, 'enable', 'on');
            set(handles.popupOverlap, 'enable', 'on');
            set(handles.popupLowerFrequency, 'enable', 'on');
            set(handles.popupUpperFrequency, 'enable', 'on');
            set(handles.popupROI, 'enable', 'off');
            set(handles.popupROIDetectionUpdate, 'enable', 'off');
            set(handles.popupRoiTrackingAM, 'enable', 'off');
            set(handles.popupRoiTrackingAM, 'value', 2);
            handles.roiTrackingAM = 2;
            set(handles.editDistance, 'enable', 'on');
            
            set(handles.popupLowerFrequency, 'value', 27);
            handles.lowerFrequency = 2;
            set(handles.popupUpperFrequency, 'value', 61);
            handles.upperFrequency = 5;
            
            set(handles.popupOverlap, 'value', 1);
            str = get(handles.popupOverlap, 'String');
            handles.overlapSize = str2double(str{1});
            set(handles.popupWindowSize, 'value', 1);
            str = get(handles.popupWindowSize, 'String');
            handles.windowSize = str2double(str{1});
        else % Calibrate - Distance
            if handles.HRVorBP == 4
                set(handles.popupHRDetecMethod, 'enable', 'off');
                set(handles.popupHRDetecMethod, 'value', 2);
                handles.HRDetecMethod = 2;
                set(handles.popupInterpolation, 'enable', 'off');
                set(handles.popupWindowSize, 'enable', 'off');
                set(handles.popupOverlap, 'enable', 'off');
                set(handles.popupLowerFrequency, 'enable', 'off');
                set(handles.popupUpperFrequency, 'enable', 'off');
                set(handles.popupROI, 'enable', 'off');
                set(handles.popupROIDetectionUpdate, 'enable', 'off');
                set(handles.popupRoiTrackingAM, 'enable', 'off');
                set(handles.popupRoiTrackingAM, 'value', 2);
                handles.roiTrackingAM = 2;
                set(handles.editDistance, 'enable', 'on');
            else % Pulse Oximetry
                set(handles.popupHRDetecMethod, 'enable', 'off');
                set(handles.popupHRDetecMethod, 'value', 2);
                handles.HRDetecMethod = 2;
                set(handles.popupInterpolation, 'enable', 'off');
                set(handles.popupWindowSize, 'enable', 'on');
                set(handles.popupOverlap, 'enable', 'on');
                set(handles.popupLowerFrequency, 'enable', 'on');
                set(handles.popupUpperFrequency, 'enable', 'on');
                set(handles.popupROI, 'enable', 'off');
                set(handles.popupROIDetectionUpdate, 'enable', 'off');
                set(handles.popupRoiTrackingAM, 'enable', 'off');
                set(handles.popupRoiTrackingAM, 'value', 2);
                handles.roiTrackingAM = 2;
                set(handles.editDistance, 'enable', 'off');    
                
                set(handles.popupLowerFrequency, 'value', 1);
                handles.lowerFrequency = 2;
                set(handles.popupUpperFrequency, 'enable', 'off');
                handles.upperFrequency = 0;
                
            set(handles.popupOverlap, 'value', 1);
            str = get(handles.popupOverlap, 'String');
            handles.overlapSize = str2double(str{1})
            set(handles.popupWindowSize, 'value', 1);
            str = get(handles.popupWindowSize, 'String');
            handles.windowSize = str2double(str{1});
            end
        end
    end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupVariable_CreateFcn(hObject, eventdata, handles)
str = {'HR and HRV' 'Blood Pressure' 'Local Pulse Wave Velocity' ....
    'Calibrate - Distance' 'Pulse Oximetry'};
set(hObject, 'string', str);
set(hObject,'value', 1);
handles.HRVorBP = 1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end
guidata(hObject, handles);

function editDistance_Callback(hObject, eventdata, handles)
    temp = str2double(get(hObject,'String'));
    temp = num2str(temp);
    handles.distance = temp;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editDistance_CreateFcn(hObject, eventdata, handles)
    handles.distance = '0';
    set(hObject,'string',handles.distance);
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

guidata(hObject, handles);


% --- Executes on selection change in popupReadVideo.
function popupReadVideo_Callback(hObject, eventdata, handles)
mainHandles = guidata(handles.CCMMain);
opt = get(hObject, 'value');
if opt == 1
    if handles.readVideo
        %         preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
        %         hold on
        %         handles.rec = rectangle('Position',[handles.resolution(1)/4 handles.resolution(2)/8 handles.resolution(1)/2 handles.resolution(2)/1.3], 'EdgeColor','r','LineWidth',3);
        %         hold off
        %         set(handles.textInfo, 'string', 'Place your face in the RED rectangle.');
    end
    handles.readVideo = false;
    aux = 'on';
    size_str = get(handles.popupVideoSize, 'string');
    handles.videoSize = str2double(size_str{get(handles.popupVideoSize, 'value')}) * 60;
    if strcmp(computer, 'PCWIN64')
      fps_str = get(handles.popupVideoFPS, 'string');
      handles.videoFPS = fps_str{get(handles.popupVideoFPS, 'value')};
    end
else
    aux = 'off';
    handles.readVideo = true;
    [filename, pathname] = uigetfile({'*.mp4;*.avi;*.mov;*.wmv*'}, 'Video Selector');
    if filename ~= 0
        handles.fileName = filename;
        handles.videoArchive = VideoReader([pathname, filename]);
        handles.videoSize = fix(handles.videoArchive.Duration);
        handles.videoFPS = num2str(handles.videoArchive.FrameRate);
        firstFrame = read(handles.videoArchive, 1);
        handles.firstFrame = firstFrame;
        handles.resolution = [size(firstFrame,2) size(firstFrame,1)];
        set(mainHandles.textInfo, 'string','First Frame of the Selected Video', 'ForegroundColor', 'w');
        set(mainHandles.textSource, 'string', filename);
        set(handles.popupSaveVideoOpt, 'value', 1);
        handles.saveVideoOpt = false;
    else
        aux = 'on';
        handles.readVideo = false;
        set(hObject, 'value', 1);
        handles.videoSize = 60;
    end
end

str1 = createStrWinOver(handles.videoSize, 1);
str2 = createStrWinOver(handles.videoSize-1, 0);
set(handles.popupWindowSize, 'string', str1);
set(handles.popupOverlap, 'string', str2);
handles.windowSize = str2double(str1{1});
handles.overlapSize = str2double(str2{1});
set(handles.popupWindowSize, 'Value', 1);
set(handles.popupOverlap, 'Value', 1);

%Locking the popup menus
set(handles.popupSaveVideoOpt, 'enable', aux);
set(handles.popupVideoSize, 'enable', aux);
set(handles.popupWebcamList, 'enable', aux);
set(handles.popupVideoFormat, 'enable', aux);
if strcmp(computer,'PCWIN64')
    set(handles.popupVideoFPS, 'enable', aux);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupReadVideo_CreateFcn(hObject, eventdata, handles)
str = {'Camera' 'Video'};
set(hObject, 'string', str);
handles.readVideo = false;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% --- Executes on selection change in popupWebcamList.
function popupWebcamList_Callback(hObject, eventdata, handles)
if strcmp(computer, 'MACI64')
    val = get(hObject, 'Value');
    str = get(hObject, 'String');
    handles.webcamList = val;
    handles.webcamName = str{val};
    f = imaqhwinfo('macvideo',val);
    set(handles.popupVideoFormat,'string',f.SupportedFormats);
    set(handles.popupVideoFormat,'Value',1);
    handles.videoFormat = f.SupportedFormats{1};
    handles.vid = videoinput('macvideo', handles.webcamList, handles.videoFormat);
    handles.src = getselectedsource(handles.vid);
    handles.resolution = handles.vid.VideoResolution;
elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
    val = get(hObject, 'Value');
    str = get(hObject, 'String');
    handles.webcamList = val;
    handles.webcamName = str{val};
    f = imaqhwinfo('winvideo',val);
    %f = f.DeviceInfo;
    set(handles.popupVideoFormat,'string',f.SupportedFormats);
    set(handles.popupVideoFormat,'Value',1);
    handles.videoFormat = f.SupportedFormats{1};
    
    handles.vid = videoinput('winvideo', handles.webcamList, handles.videoFormat);
    
    handles.src = getselectedsource(handles.vid);
    f = propinfo(handles.src, 'FrameRate');
    set(handles.popupVideoFPS, 'string', f.ConstraintValue); % Muda os valores de FPS para serem selecionados na interface.
    set(handles.popupVideoFPS, 'Value', 1);
    handles.videoFPS = f.ConstraintValue{1};
    handles.resolution = handles.vid.VideoResolution;
end

guidata(hObject, handles);

function popupWebcamList_CreateFcn(hObject, eventdata, handles)
str = webcamlist;
set(hObject, 'string', str);
handles.webcamName = str{1};
handles.webcamList = 1;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


guidata(hObject, handles);


% --- Executes on selection change in popupVideoFormat.
function popupVideoFormat_Callback(hObject, eventdata, handles)
if strcmp(computer,'MACI64')
    val = get(hObject, 'Value');
    str = get(hObject, 'String');
    handles.videoFormat = str{val};
    handles.vid = videoinput('macvideo', handles.webcamList, handles.videoFormat);
    handles.src = getselectedsource(handles.vid);
    handles.resolution = handles.vid.VideoResolution;  
elseif strcmp(computer,'PCWIN64') || strcmp(computer,'PCWIN32')
    val = get(hObject, 'Value');
    str = get(hObject, 'String');
    handles.videoFormat = str{val};
    handles.vid = videoinput('winvideo', handles.webcamList, handles.videoFormat);
    handles.src = getselectedsource(handles.vid);
    handles.resolution = handles.vid.VideoResolution;
    f = propinfo(handles.src, 'FrameRate');
    set(handles.popupVideoFPS, 'string', f.ConstraintValue); % Muda os valores de FPS para serem selecionados na interface.
    set(handles.popupVideoFPS, 'Value', 1);
    handles.videoFPS = f.ConstraintValue{1};
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupVideoFormat_CreateFcn(hObject, eventdata, handles)
if strcmp(computer, 'MACI64')
    f = imaqhwinfo('macvideo',1);
elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
    f = imaqhwinfo('winvideo',1);
end
%f = f.DeviceInfo;
set(hObject,'string',f.SupportedFormats);
handles.videoFormat = f.SupportedFormats{1};
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% --- Executes on selection change in popupVideoFPS.
function popupVideoFPS_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.videoFPS = str{val};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupVideoFPS_CreateFcn(hObject, eventdata, handles)
if strcmp(computer, 'MACI64')
    set(hObject, 'enable', 'off');
    handles.videoFPS = '30.0000';
elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
    vid = videoinput('winvideo', 1);
    src = getselectedsource(vid);
    f = propinfo(src, 'FrameRate');
    set(hObject,'string',f.ConstraintValue); % Muda os valores de FPS para serem selecionados na interface.
    handles.videoFPS = f.ConstraintValue{1};
end
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupSaveVideoOpt.
function popupSaveVideoOpt_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
if val == 1
    handles.saveVideoOpt = false;
else
    handles.saveVideoOpt = true;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupSaveVideoOpt_CreateFcn(hObject, eventdata, handles)
str = {'Enabled' 'Disabled'};
set(hObject, 'string', str);
handles.saveVideoOpt = true;
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

% --- Executes on selection change in popupVideoSize.
function popupVideoSize_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.videoSize = str2double(str{val}) * 60;
str1 = createStrWinOver(handles.videoSize, 1);
str2 = createStrWinOver(handles.videoSize-1, 0);
set(handles.popupWindowSize, 'string', str1);
set(handles.popupOverlap, 'string', str2);
handles.windowSize = str2double(str1{1});
handles.overlapSize = str2double(str2{1});
set(handles.popupWindowSize, 'Value', 1);
set(handles.popupOverlap, 'Value', 1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupVideoSize_CreateFcn(hObject, eventdata, handles)
str = {'1' '2' '3' '4' '5'};
set(hObject, 'string', str);
handles.videoSize = str2double(str{1}) * 60;

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);

function [str] = createStrWinOver(maximum, minimum)
str = {};
for ii = minimum:maximum
    str = cat(2, str, num2str(ii));
end
str = fliplr(str);

function [str] = createStrFreqLowUp(minimum, maximum, inter)
str = {};
for ii = minimum:inter:maximum
    str = cat(2, str, num2str(ii));
end
