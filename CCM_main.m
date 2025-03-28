% --------------------------------------------------------------------
% Configurations - Start;
% --------------------------------------------------------------------
function varargout = CCM_main(varargin)
%CCM_main M-file for CCM_main.fig
%      CCM_main, by itself, creates a new CCM_main or raises the existing
%      singleton*.
%
%      H = CCM_main returns the handle to a new CCM_main or the handle to
%      the existing singleton*.
%
%      CCM_main('Property','Value',...) creates a new CCM_main using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to CCM_main_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CCM_main('CALLBACK') and CCM_main('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CCM_main.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CCM_main

% Last Modified by GUIDE v2.5 02-Nov-2020 22:58:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CCM_main_OpeningFcn, ...
    'gui_OutputFcn',  @CCM_main_OutputFcn, ...
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

% --- Executes just before CCM_main is made visible.
function CCM_main_OpeningFcn(hObject, eventdata, handles, varargin)
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(hObject,'JavaFrame'); % Remove if Javaframe becomes obsolete
javaFrame.setFigureIcon(javax.swing.ImageIcon([pwd,'\splash.png']));

clc;

handles.zoom = 0;
webcam_list = webcamlist;

% Menus Configurations
set(handles.itemMenu_plotFrequency, 'enable', 'off');
set(handles.itemMenu_plotHR, 'enable', 'off');
set(handles.itemMenu_plotHRV, 'enable', 'off');
set(handles.itemMenu_plotComponent, 'enable', 'off');
set(handles.itemMenu_plotRRPeaks, 'enable', 'off');
set(handles.itemMenu_plotPWV, 'enable', 'off');
set(handles.itemMenu_plotSpO2, 'enable', 'off');


% Buttons Configuration
set(handles.pushbutton_StartHRV,'visible','off');
set(handles.pushbutton_StartBP,'visible','off');
set(handles.pushbutton_StartCalibrate,'visible','off');
set(handles.pushbutton_StartPWV,'visible','on');
set(handles.pushbutton_StartPulseOximetry,'visible','off');
set(handles.textHR, 'string', 'Local Pulse Wave Velocity');



handles.interpolation = 500;
handles.ROI = 1;
handles.HRDetecMethod = 1;
handles.faceDetectionUpdate = 1;
handles.readVideo = 0;

% Frequency
handles.upperFrequency = 5;
handles.lowerFrequency = 2;

% Distance between ROIs
handles.distance = '0';

% Load calibration factor.
handles.calibrationFactor = 0;
if isfile('Files/calibrationFactor.mat')
     load 'Files/calibrationFactor.mat' dcm;
     handles.calibrationFactor = dcm;
end

% Load calibration factor.
handles.userID = 1;
if isfile('Files/userID.mat')
     load 'Files/userID.mat' userID;
     handles.userID = userID;
end

% User Mass
handles.userMass = '0';
handles.userSkin = 1;

% Signal Info
handles.signalInfo = text(10, 50, 'Signal Quality ', 'color', 'w', 'FontSize',15);

% Birthday
handles.userBirthday = '';

% User BMI
handles.userBMI = 0;

handles.webcamList = 1;
handles.webcamName = webcam_list{handles.webcamList};
handles.videoFormat = [];
handles.saveVideoOpt = 1;
handles.videoSize = 60;
handles.videoFPS = '30.0000';
handles.overlapSize = 59;
handles.windowSize = 60;
handles.userRace = 'White';
handles.userAge = '22';
handles.userGender = 'Male';
handles.userName = 'User1';
handles.HRVorBP = 3;
handles.userHeight = 1.7;
handles.roiTrackingAM = 1;
handles.recROI = [];

handles.pointTracker = vision.PointTracker('MaxBidirectionalError', 10);

if strcmp(computer, 'MACI64')
    handles.vid = videoinput('macvideo', handles.webcamList);
elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
    handles.vid = videoinput('winvideo', handles.webcamList);
end

handles.src = getselectedsource(handles.vid);
if strcmp(handles.webcamName, 'Logitech HD Pro Webcam C920') || strcmp(handles.webcamName, 'HD Pro Webcam C920')
    set(handles.src,'BacklightCompensation','off');
    set(handles.src,'WhiteBalanceMode','manual');
    % set(handles.src,'Gain',25);
    set(handles.src,'WhiteBalance',6000);
    set(handles.src,'ExposureMode','manual');
    set(handles.src,'Exposure',-5);
end

handles.resolution = handles.vid.VideoResolution;
axes(handles.axesUserImg);
handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
handles.faceDetector = vision.CascadeObjectDetector('ClassificationModel','EyePairBig', 'MinSize', [fix(handles.resolution(2)/10) fix(handles.resolution(1)/10)],'MergeThreshold',24); %Face detection Object
set(handles.p,'ButtonDownFcn',{@position_and_button, hObject, handles});

if handles.HRVorBP == 1 % HRV and HR or BP
    set(handles.textInfo, 'string', 'Place your FACE or HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
else
    if handles.HRVorBP == 3 % PWV
        set(handles.textInfo, 'string', 'Place your HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
    end
end

set(handles.textSource, 'string', handles.webcamName);
set(handles.textZoom, 'string', sprintf(['Zoom: 1X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
handles.output = hObject;

handles = createRois(hObject, handles);

guidata(hObject, handles);
setappdata(handles.figure,'waiting',1)
uiwait(handles.figure);

% --- Outputs from this function are returned to the command line.
function varargout = CCM_main_OutputFcn...
    (hObject, eventdata, handles)
varargout{1} = [];
delete(hObject);

% --- Executes when user attempts to close figure.
function figure_CloseRequestFcn(hObject,eventdata,handles)
if getappdata(handles.figure,'waiting')
    disp('Entrei no if');
    % The GUI is still in UIWAIT, so call UIRESUME and return
    uiresume(hObject);
    setappdata(handles.figure,'waiting',0)
else
    % The GUI is no longer waiting, so destroy it now.
    disp('Entrei no else');
    delete(hObject);
    stop(handles.vid);
    % exit
end

function menu_Settings_Callback(hObject, eventdata, handles)
% closepreview(handles.vid);
% handles = guidata(CCM_preferences('CCM_main', handles.figure));
% 
% if handles.HRVorBP == 1 % HRV and HR
%     if ~handles.readVideo
%         set(handles.textInfo, 'string', 'Place your FACE or HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
%     end
%     set(handles.pushbutton_StartHRV,'visible','on');
%     set(handles.pushbutton_StartBP,'visible','off');
%     set(handles.pushbutton_StartPWV,'visible','off');
%     set(handles.pushbutton_StartCalibrate,'visible','off');
% else 
%     if handles.HRVorBP == 2 % BP
%         if ~handles.readVideo
%             set(handles.textInfo, 'string', 'Place your FACE and HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
%         end
%         set(handles.pushbutton_StartHRV,'visible','off');
%         set(handles.pushbutton_StartBP,'visible','on');
%         set(handles.pushbutton_StartPWV,'visible','off');
%         set(handles.pushbutton_StartCalibrate,'visible','off');
%     else 
%         if handles.HRVorBP == 3 % PWV
%             if ~handles.readVideo
%                 set(handles.textInfo, 'string', 'Place your HAND in FRONT of the CAMERA and press <<START PWV>>', 'ForegroundColor', 'r');
%             end
%             set(handles.pushbutton_StartHRV,'visible','off');
%             set(handles.pushbutton_StartBP,'visible','off');
%             set(handles.pushbutton_StartPWV,'visible','on');
%             set(handles.pushbutton_StartCalibrate,'visible','off');
%         else
%             if ~handles.readVideo
%                 set(handles.textInfo, 'string', 'Place the squares between two reference points', 'ForegroundColor', 'r');
%             end
%             set(handles.pushbutton_StartHRV,'visible','off');
%             set(handles.pushbutton_StartBP,'visible','off');
%             set(handles.pushbutton_StartPWV,'visible','off');
%             set(handles.pushbutton_StartCalibrate,'visible','on');
%         end
%     end
% end
% 
% if(~handles.readVideo)
%     if(isempty(handles.videoFormat))  % Default format if the user cancel the setup
%         if strcmp(computer, 'MACI64')
%             handles.vid = videoinput('macvideo', handles.webcamList);
%         elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
%             handles.vid = videoinput('winvideo', handles.webcamList);
%         end
%     else
%         if strcmp(computer, 'MACI64')
%             handles.vid = videoinput('macvideo', handles.webcamList, handles.videoFormat);
%         elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
%             handles.vid = videoinput('winvideo', handles.webcamList, handles.videoFormat);
%         end
%     end
%     % Logitech
%     handles.src = getselectedsource(handles.vid);
%     if strcmp(handles.webcamName, 'Logitech HD Pro Webcam C920') || strcmp(handles.webcamName, 'HD Pro Webcam C920') 
%         set(handles.src,'BacklightCompensation','off');
%         set(handles.src,'WhiteBalanceMode','manual');
%         % set(handles.src,'Gain',25);
%         set(handles.src,'WhiteBalance',6000);
%         set(handles.src,'ExposureMode','manual');
%         set(handles.src,'Exposure',-5);
%     end
%     
%     axes(handles.axesUserImg);
%     set(handles.textSource, 'string', handles.webcamName);
%     
%     handles.resolution = handles.vid.VideoResolution; % get the new resolution of the video stream
%     
%     set(handles.textZoom, 'string', sprintf(['Zoom: 1X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
%     handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
%     set(handles.p,'ButtonDownFcn',{@position_and_button, hObject, handles});
%     
%     if handles.ROI == 4 && handles.roiTrackingAM == 1
%         if handles.resolution(1)/handles.resolution(2) <= 1.5 % Resolucao 4/3
%             handles.bHand = [handles.resolution(1)/12 handles.resolution(2)/1.65 handles.resolution(1)/8 handles.resolution(2)/8];
%         else
%             handles.bHand = [handles.resolution(1)/5 handles.resolution(2)/1.65 handles.resolution(1)/9 handles.resolution(2)/8];
%         end
%         set(handles.textInfo, 'string', 'Please, place your HAND in the RED rectangle and press <<START>>', 'ForegroundColor', 'r');
%         hold on
%         handles.recROI = rectangle('Position',handles.bHand, 'EdgeColor','r','LineWidth',3);
%         hold off
%     end
%     handles.zoom = 0;
% else % Se estiver lendo um arquivo de video
%     set(handles.textZoom, 'string', [num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]);
%     imshow(handles.firstFrame);
%     if handles.ROI == 4 && handles.roiTrackingAM == 1
%         if handles.resolution(1)/handles.resolution(2) <= 1.5 % Resolucao 4/3
%             handles.bHand = [handles.resolution(1)/12 handles.resolution(2)/1.65 handles.resolution(1)/8 handles.resolution(2)/8];
%         else
%             handles.bHand = [handles.resolution(1)/5 handles.resolution(2)/1.65 handles.resolution(1)/9 handles.resolution(2)/8];
%         end
%     end
% end
% if ~(fix(handles.resolution(2)/12) <= 11 || fix(handles.resolution(1)/12) <= 45)
%     handles.faceDetector = vision.CascadeObjectDetector('ClassificationModel','EyePairBig', 'MinSize', [fix(handles.resolution(2)/12) fix(handles.resolution(1)/12)]);%,'MergeThreshold',24); %Face detection Object
% else
%     handles.faceDetector = vision.CascadeObjectDetector('ClassificationModel','EyePairBig', 'MinSize', [11 45],'MergeThreshold',24); %Face detection Object
% end
% 
% % Sliding ROI
% if handles.HRVorBP == 3 || handles.HRVorBP == 4
%     handles.tam_roi = 50;
%     handles.roi1 = drawrectangle('Label', 'Proximal Region', ....
%         'LabelVisible', 'hover', 'Position', ....
%         [handles.resolution(1)/2,handles.resolution(2)/2,handles.tam_roi,handles.tam_roi]);
%     handles.roi2 = drawrectangle('Label', 'Distal Region', ....
%         'LabelVisible', 'hover', 'Position', ....
%         [handles.resolution(1)/2 + 100,handles.resolution(2)/2,handles.tam_roi,handles.tam_roi]);
% 
% 
%     posRoi1 = handles.roi1.Position;
%     posRoi2 = handles.roi2.Position;
% 
%     centroRoi1 = [(posRoi1(1) + posRoi1(3) + posRoi1(1))/2, (posRoi1(2) + posRoi1(4) + posRoi1(2))/2];
%     centroRoi2 = [(posRoi2(1) + posRoi2(3) + posRoi2(1))/2, (posRoi2(2) + posRoi2(4) + posRoi2(2))/2];
% 
%     handles.linha = line([centroRoi1(1) centroRoi2(1)] ....
%         , [centroRoi1(2) centroRoi2(2)], 'Color', 'b', 'LineWidth', 5);
%     addlistener(handles.roi1,'MovingROI',@(src,evnt)allevents(src,evnt,handles, hObject));
%     addlistener(handles.roi2,'MovingROI',@(src,evnt)allevents(src,evnt,handles, hObject));
% end 

guidata(hObject, handles);

% Configuration user information
function itemMenu_UserConfiguration_Callback(hObject, eventdata, handles)
    closepreview(handles.vid);
    handles = guidata(CCM_UserConfiguration('CCM_main', handles.figure));
    handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
    
    handles = createRois(hObject, handles);
guidata(hObject, handles);

% Configuration Video/Camera information
function itemMenu_VideoCameraConfiuration_Callback(hObject, eventdata, handles)
closepreview(handles.vid);
handles = guidata(CCM_CameraVideoConfiguration('CCM_main', handles.figure));

% Button Configuration
set(handles.pushbutton_StartHRV,'visible','off');
set(handles.pushbutton_StartBP,'visible','off');
set(handles.pushbutton_StartPWV,'visible','off');
set(handles.pushbutton_StartCalibrate,'visible','off');
set(handles.pushbutton_StartPulseOximetry,'visible','off');

switch handles.HRVorBP
    case 1 % HR and HRV
        set(handles.pushbutton_StartHRV,'visible','on');
        set(handles.textHR, 'string', 'HR and HRV');
        if ~handles.readVideo
            set(handles.textInfo, 'string', 'Place your FACE or HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
    case 2 % Blood Pressure with Regional PWV
        set(handles.pushbutton_StartBP,'visible','on');
        set(handles.textHR, 'string', 'Blood Pressure (Regional PWV)');
        if ~handles.readVideo
            set(handles.textInfo, 'string', 'Place your FACE or HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
    case 3 % Local PWV
        set(handles.pushbutton_StartPWV,'visible','on');
        set(handles.textHR, 'string', 'Local Pulse Wave Velocity');
        if ~handles.readVideo
            set(handles.textInfo, 'string', 'Place your HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
    case 4 % Calibrate Distance
        set(handles.pushbutton_StartCalibrate,'visible','on');
        set(handles.textHR, 'string', 'Distance Calibration');
        if ~handles.readVideo
            set(handles.textInfo, 'string', 'Place the squares between two reference points', 'ForegroundColor', 'r');
        end
        
    case 5 % Pulse Oximetry
        set(handles.pushbutton_StartPulseOximetry,'visible','on');
        set(handles.textHR, 'string', 'Pulse Oximetry');
        if ~handles.readVideo
            set(handles.textInfo, 'string', 'Place your HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
end

if(~handles.readVideo)
    if(isempty(handles.videoFormat))  % Default format if the user cancel the setup
        if strcmp(computer, 'MACI64')
            handles.vid = videoinput('macvideo', handles.webcamList);
        elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
            handles.vid = videoinput('winvideo', handles.webcamList);
        end
    else
        if strcmp(computer, 'MACI64')
            handles.vid = videoinput('macvideo', handles.webcamList, handles.videoFormat);
        elseif strcmp(computer, 'PCWIN64') || strcmp(computer, 'PCWIN32')
            handles.vid = videoinput('winvideo', handles.webcamList, handles.videoFormat);
        end
    end
    % Logitech
    handles.src = getselectedsource(handles.vid);
    if strcmp(handles.webcamName, 'Logitech HD Pro Webcam C920') || strcmp(handles.webcamName, 'HD Pro Webcam C920') 
        set(handles.src,'BacklightCompensation','off');
        set(handles.src,'WhiteBalanceMode','manual');
        % set(handles.src,'Gain',25);
        set(handles.src,'WhiteBalance',6000);
        set(handles.src,'ExposureMode','manual');
        set(handles.src,'Exposure',-5);
    end
    
    axes(handles.axesUserImg);
    set(handles.textSource, 'string', handles.webcamName);
    
    handles.resolution = handles.vid.VideoResolution; % get the new resolution of the video stream
    
    set(handles.textZoom, 'string', sprintf(['Zoom: 1X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
    handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
    set(handles.p,'ButtonDownFcn',{@position_and_button, hObject, handles});
    
    if handles.ROI == 4 && handles.roiTrackingAM == 1
        if handles.resolution(1)/handles.resolution(2) <= 1.5 % Resolucao 4/3
            handles.bHand = [handles.resolution(1)/12 handles.resolution(2)/1.65 handles.resolution(1)/8 handles.resolution(2)/8];
        else
            handles.bHand = [handles.resolution(1)/5 handles.resolution(2)/1.65 handles.resolution(1)/9 handles.resolution(2)/8];
        end
        set(handles.textInfo, 'string', 'Please, place your HAND in the RED rectangle and press <<START>>', 'ForegroundColor', 'r');
        hold on
        handles.recROI = rectangle('Position',handles.bHand, 'EdgeColor','r','LineWidth',3);
        hold off
    end
    handles.zoom = 0;
else % Se estiver lendo um arquivo de video
    set(handles.textZoom, 'string', [num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]);
    imshow(handles.firstFrame);
    if handles.ROI == 4 && handles.roiTrackingAM == 1
        if handles.resolution(1)/handles.resolution(2) <= 1.5 % Resolucao 4/3
            handles.bHand = [handles.resolution(1)/12 handles.resolution(2)/1.65 handles.resolution(1)/8 handles.resolution(2)/8];
        else
            handles.bHand = [handles.resolution(1)/5 handles.resolution(2)/1.65 handles.resolution(1)/9 handles.resolution(2)/8];
        end
    end
end
if ~(fix(handles.resolution(2)/12) <= 11 || fix(handles.resolution(1)/12) <= 45)
    handles.faceDetector = vision.CascadeObjectDetector('ClassificationModel','EyePairBig', 'MinSize', [fix(handles.resolution(2)/12) fix(handles.resolution(1)/12)]);%,'MergeThreshold',24); %Face detection Object
else
    handles.faceDetector = vision.CascadeObjectDetector('ClassificationModel','EyePairBig', 'MinSize', [11 45],'MergeThreshold',24); %Face detection Object
end

handles = createRois(hObject, handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_CalibrationBP_Callback(hObject, eventdata, handles)
    guidata(CCM_CalibrateBP('CCM_main', handles.figure));
guidata(hObject, handles);

function position_and_button(hObject, eventdata, h, handles)
handles = guidata(h);
if strcmp(handles.vid.Running, 'off')
    if(isprop(handles.src, 'Zoom'))
        if handles.zoom == 0
            handles.src.Zoom = 150;
            handles.zoom = 1;
            set(handles.textZoom, 'string', sprintf(['Zoom: ', num2str(double(handles.src.Zoom)/100), 'X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
        elseif handles.zoom == 1
            handles.src.Zoom = 175;
            handles.zoom = 2;
            set(handles.textZoom, 'string', sprintf(['Zoom: ', num2str(double(handles.src.Zoom)/100), 'X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
        elseif handles.zoom == 2
            handles.src.Zoom = 200;
            handles.zoom = 3;
            set(handles.textZoom, 'string', sprintf(['Zoom: ', num2str(double(handles.src.Zoom)/100), 'X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
        elseif handles.zoom == 3
            handles.src.Zoom = 250;
            handles.zoom = 4;
            set(handles.textZoom, 'string', sprintf(['Zoom: ', num2str(double(handles.src.Zoom)/100), 'X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
        elseif handles.zoom == 4
            handles.src.Zoom = 300;
            handles.zoom = 5;
            set(handles.textZoom, 'string', sprintf(['Zoom: ', num2str(double(handles.src.Zoom)/100), 'X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
        else
            handles.src.Zoom = 100;
            handles.zoom = 0;
            set(handles.textZoom, 'string', sprintf(['Zoom: ', num2str(double(handles.src.Zoom)/100), 'X\n', num2str(handles.resolution(1)),'X',num2str(handles.resolution(2))]));
        end
    else
        errordlg(['The Zoom feature is not available for ', handles.webcamName], 'Zoom', 'replace');
    end
end
guidata(h,handles);
% --------------------------------------------------------------------
% Configurations - End
% --------------------------------------------------------------------



% --------------------------------------------------------------------
% Plots - Start
% --------------------------------------------------------------------
function menu_Plots_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function itemMenu_plotHR_Callback(hObject, eventdata, handles)
figure('Name','Heart Rate Plot','NumberTitle','off')
if(handles.windowSize == handles.videoSize)
    plot([handles.x_HR-1 handles.x_HR], [handles.heart_rate handles.heart_rate]);
    axis([handles.windowSize-1 handles.videoSize handles.lowerFrequency*60 handles.upperFrequency*60]);
else
    plot(handles.x_HR, handles.heart_rate);
    axis([handles.windowSize handles.videoSize handles.lowerFrequency*60 handles.upperFrequency*60]);
end
title('Heart Rate');
xlabel('Time (Seconds)');
ylabel('Beats per Minute (BPM)');
if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
    z = double(handles.src.Zoom)/100;
else
    z = 1;
end
if ~handles.readVideo
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nUser Name: ',...
        handles.userName, '\nSource: ', handles.webcamName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),' FPS\nCamera Zoom: ', num2str(z), 'X',...
        '\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']));
else
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nSource: ', handles.fileName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),...
        ' FPS\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency),' Hz']));
end
grid on
grid minor
guidata(hObject, handles);

% --------------------------------------------------------------------
function itemMenu_plotFrequency_Callback(hObject, eventdata, handles)
figure('Name','Frequency Plot','NumberTitle','off')
plot(handles.plot_frequency(2,:), handles.plot_frequency(1,:));
title('Powerful Frequency');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
    z = double(handles.src.Zoom)/100;
else
    z = 1;
end
if ~handles.readVideo
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nUser Name: ',...
        handles.userName, '\nSource: ', handles.webcamName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),' FPS\nCamera Zoom: ', num2str(z), 'X',...
        '\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']));
else
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nSource: ', handles.fileName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),...
        ' FPS\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']));
end
axis([handles.lowerFrequency handles.upperFrequency 0 Inf]);
grid on
grid minor
guidata(hObject, handles);

% --------------------------------------------------------------------
function itemMenu_plotHRV_Callback(hObject, eventdata, handles)
figure('Name','Poincaré HRV Plot','NumberTitle','off')
handles.hrv_poincare = [handles.plot_RR(1,1:end-1); handles.plot_RR(1,2:end)];
coef = polyfit(handles.hrv_poincare(1,:), handles.hrv_poincare(2,:),1);
line = coef(1)*handles.hrv_poincare(1,:)+coef(2);
plot(handles.hrv_poincare(1,:), handles.hrv_poincare(2,:),'*');
hold on
plot(handles.hrv_poincare(1,:), line, 'r');
hold off
if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
    z = double(handles.src.Zoom)/100;
else
    z = 1;
end
if ~handles.readVideo
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nUser Name: ',...
        handles.userName, '\nSource: ', handles.webcamName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),' FPS\nCamera Zoom: ', num2str(z), 'X',...
        '\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']), sprintf(['Linear Regression: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
else
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nSource: ', handles.fileName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),...
        ' FPS\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']), sprintf(['Linear Regression: Y = AX+B\n','A: ', num2str(coef(1)),'\nB: ', num2str(coef(2))]));
end

title('Poincare HRV');
ylabel('RR (n+1) in ms');
xlabel('RR (n) in ms');
guidata(hObject, handles);

% --------------------------------------------------------------------
function itemMenu_plotComponent_Callback(hObject, eventdata, handles)
if handles.HRDetecMethod == 1 
    figure('Name','ICA Component Plot','NumberTitle','off');
else
    figure('Name','Fixed Color Channel','NumberTitle','off');
end

% [pks, locs] = findpeaks(handles.plot_compORchannel, handles.interpolation, 'MinPeakProminence',std(handles.plot_compORchannel,0,2)*2);
[pks,locs] = findpeaks(handles.plot_compORchannel.^3,handles.interpolation,'MinPeakProminence',std(handles.plot_compORchannel)*.5); % 1 {4} 2 {5}
[pks,locs] = findpeaks(handles.plot_compORchannel.^3,handles.interpolation,'MinPeakProminence',std(handles.plot_compORchannel)*.5,'MinPeakDistance', mean(diff(locs))*.7);
plot((0:size(handles.plot_compORchannel, 2) - 1)/handles.interpolation, handles.plot_compORchannel);
hold on
plot(locs, pks.^(1/3), 'vg');
hold off
axis([0 size(handles.plot_compORchannel,2)/handles.interpolation -Inf Inf])
title('Component');
xlabel('Time (Seconds)');
ylabel('Amplitude');
if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
    z = double(handles.src.Zoom)/100;
else
    z = 1;
end
if ~handles.readVideo
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nUser Name: ',...
        handles.userName, '\nSource: ', handles.webcamName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),' FPS\nCamera Zoom: ', num2str(z), 'X',...
        '\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency),' Hz']), 'Heart Beat Peaks');
else
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nSource: ', handles.fileName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),...
        ' FPS\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']), 'Heart Beat Peaks');
end
grid on
grid minor
guidata(hObject, handles);

% --------------------------------------------------------------------
function itemMenu_plotRRPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to itemMenu_plotRRPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure('Name','RR Peaks Plot','NumberTitle','off')
x = linspace(0,handles.videoSize, size(handles.plot_RR,2));
meanRR = mean(handles.plot_RR);
plot(x,handles.plot_RR);
hold on
plot([x(1) x(end)],[meanRR meanRR]);
hold off
title('RR Peaks');
xlabel('Time (Seconds)');
ylabel('RR (ms)');
if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
    z = double(handles.src.Zoom)/100;
else
    z = 1;
end
if ~handles.readVideo
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nUser Name: ',...
        handles.userName, '\nSource: ', handles.webcamName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),' FPS\nCamera Zoom: ', num2str(z), 'X',...
        '\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']), ['Average RR Time: ', num2str(meanRR), ' ms']);
else
    legend(sprintf(['Avg. HR of Blocks: ', num2str(round(mean(handles.heart_rate))), ' BPM\nMode HR: ', num2str(round(handles.HR)), ' BPM\nSource: ', handles.fileName ,'\nVideo Length: ', ...
        num2str(handles.videoSize), ' seconds\nWindow Size: ', num2str(handles.windowSize),...
        ' seconds\nOverlap Size: ', num2str(handles.overlapSize), ' seconds\nFrame Rate: ', num2str(handles.videoFPS),...
        ' FPS\nFrequency Range: ', num2str(handles.lowerFrequency), ' - ', num2str(handles.upperFrequency), ' Hz']), ['Average RR Time: ', num2str(meanRR), ' ms']);
end

% --------------------------------------------------------------------
function itemMenu_plotPWV_Callback(hObject, eventdata, handles)
    figure('Name','PWV Plot','NumberTitle','off');
    
    distal = PWV_SignalProcessing(handles.raw_signals(5,:), handles.fps, ....
        handles.interpolation, handles.filterFCC);
    
    proximal = PWV_SignalProcessing(handles.raw_signals(2,:), handles.fps, ....
        handles.interpolation, handles.filterFCC);
   
    fs = handles.interpolation;
    y = proximal;
    x = linspace(0, size(y,2)/fs, size(y,2));
    
    ratio = .75;
    [pF,lF] = findpeaks(proximal,handles.interpolation,'MinPeakProminence',std(proximal)*ratio); 
    [pF,lF] = findpeaks(proximal,handles.interpolation,'MinPeakProminence',std(proximal)*ratio,'MinPeakDistance', mean(diff(lF))*.7); 
    [pH,lH] = findpeaks(distal,handles.interpolation,'MinPeakProminence',std(distal)*ratio); 
    [pH,lH] = findpeaks(distal,handles.interpolation,'MinPeakProminence',std(distal)*ratio,'MinPeakDistance', mean(diff(lH))*.7); 
    
    if abs(size(lH,2) - size (lF,2)) > 3
        sizeDiff = 3;
    else
        sizeDiff = abs(size(lH,2) - size (lF,2));
    end
    timeDiff = 0.1;
    
    [lOUT1, pOUT1, lOUT2, pOUT2, n] = pttVectors(lF, pF,  .....
    lH, pH, sizeDiff, timeDiff);

    
    hold on;
    plot(x, proximal, 'LineWidth', 5);
    plot(lOUT1, pOUT1, 'v', 'LineWidth', 5);
    plot(x, distal, 'LineWidth', 5);
    plot(lOUT2, pOUT2, 'v', 'LineWidth', 5);
    
    title('PPG signals - Proximal and Distal');
    
    str = sprintf(['Distance: ', num2str(handles.distance), newline, 'PTT: ', ....
        num2str(handles.PTT), 's', newline, 'PWV: ', num2str(handles.PWV), ....
        ' m/s']);
    
    text(0, max([pH pF]), str, 'FontSize', 15);
    
    legend('Proximal Signal', ....
        'Proximal Peaks', ....
        'Distal Signal', ....
        sprintf(['Distal Peaks', newline, 'Number of peaks: ', ....
           num2str(n)]));
    
    xlabel('Time (s)');
    ylabel('Normalized Amplitude');
    
    hold off;
    
guidata(hObject, handles);

% --------------------------------------------------------------------
function itemMenu_plotSpO2_Callback(hObject, eventdata, handles)
    figure('Name','PWV Plot','NumberTitle','off');
    
    hold on;
    y = mean(handles.SpO2);
    
    x = 0:handles.time_sobre:handles.videoSize - 1;
    plot(x, handles.SpO2, '-o', 'LineWidth', 2);
    line([0 x(end)], [y y], 'Color', 'r', 'lineWidth', 2);
    
    xlabel('Time (s)');
    ylabel('SpO2');
    ytickformat('percentage');
    title('Contactless SpO2%');
    legend('SpO2', sprintf(['Average SpO2 - ', num2str(y), '%']));
    
    hold off;
guidata(hObject, handles);
% --------------------------------------------------------------------
% Plots - End
% --------------------------------------------------------------------



% --------------------------------------------------------------------
% Variables - Start
% --------------------------------------------------------------------
function pushbutton_StartHRV_Callback(hObject, eventdata, handles)
show_info_roi = true;
color = 'w';
set(handles.textHR, 'string', ' ');
set(hObject, 'visible', 'off');
set(hObject, 'enable', 'off');
set(handles.menu_Settings, 'enable', 'off');
set(handles.itemMenu_plotFrequency, 'enable', 'off');
set(handles.itemMenu_plotHR, 'enable', 'off');
set(handles.itemMenu_plotHRV, 'enable', 'off');
set(handles.itemMenu_plotComponent, 'enable', 'off');
set(handles.itemMenu_plotRRPeaks, 'enable', 'off');
set(handles.itemMenu_plotPWV, 'enable', 'off');
set(handles.itemMenu_plotSpO2, 'enable', 'off');
set(handles.menu_CalibrationBP, 'enable', 'off');

if handles.roiTrackingAM == 2
    set(handles.textInfo, 'string','Select the REGION OF INTEREST');
    handles.rectROI = round(getrect);
    bbox_detection = 1;
    b_distance = handles.rectROI;
end

handles.raw_signals = [];
handles.heart_rate = [];
handles.x_HR = [];
handles.fps = str2double(handles.videoFPS);
max_frames = handles.videoSize * handles.fps; % Limite de frames pro loop de controle

if ~handles.readVideo
    handles.vid.FramesPerTrigger = 1;
    handles.vid.TriggerRepeat = max_frames + round(handles.fps/2);
    handles.vid.ReturnedColorspace = 'rgb';
    if strcmp(computer,'PCWIN64')
        handles.src.FrameRate = handles.videoFPS;
    end
end

window = handles.windowSize; % in seconds
sobreposicao = handles.overlapSize; % in seconds

bbox = [handles.resolution(1)/4 handles.resolution(2)/8 handles.resolution(1)/2 handles.resolution(2)/1.3]; % Red Rectangle Area
block = [];
block_size = window * handles.fps;
block_sobreposicao = sobreposicao * handles.fps;

frameCount = 0;
faceDetectionFrame = 0;
updateFrame = 0;

fp = [handles.lowerFrequency, handles.upperFrequency];  % Bandpass frequencies
f = handles.fps;
wp=(2/f).* fp;
handles.filterFCC = fir1(15, wp);

if handles.roiTrackingAM == 1
    numPts = 0;
    maxNumPts = 10;
    if handles.ROI ~= 4
        if ~handles.readVideo
            test_img = getsnapshot(handles.vid);
            bbox_detection = handles.faceDetector.step(rgb2gray(test_img));
        else
            test_img = read(handles.videoArchive, 1);
            bbox_detection = handles.faceDetector.step(rgb2gray(test_img));
        end
    else
        bbox_detection = 1;
        handles.rectROI = handles.bHand;
    end
end

if ~isempty(bbox_detection) % Se a face do usuario estiver posicionada no lugar correto
    if(handles.saveVideoOpt) % Create a new folder
        if strcmp(computer, 'PCWIN64')
            folder = [pwd, '\DATA\', handles.userName];
            mkdir(folder);
            video = VideoWriter([folder, '\', handles.userName, '.avi']);
        elseif strcmp(computer, 'MACI64')
            folder = [pwd, '/DATA/', handles.userName];
            mkdir(folder);
            video = VideoWriter([folder, '/', handles.userName, '.avi']);
        end
        video.FrameRate = str2double(handles.videoFPS);
        open(video);
    end
    
    if ~handles.readVideo
        set(handles.textInfo, 'string','Starting Acquisition...');
        start(handles.vid); % Começar a captura de frames
        pause(1);
        getdata(handles.vid,round(handles.fps/2),'uint8');
    end
    
    while frameCount <= max_frames
        if ~handles.readVideo
            videoFrame = getdata(handles.vid,1,'uint8');
        else
            videoFrame = read(handles.videoArchive, frameCount + 1);
        end
        if(handles.saveVideoOpt)
            writeVideo(video, videoFrame);
        end
        
        if handles.ROI ~= 4 && handles.roiTrackingAM == 1
            videoFrameGray = rgb2gray(videoFrame);
            if frameCount >= faceDetectionFrame
                if numPts < maxNumPts
                    bbox_detection = handles.faceDetector.step(videoFrameGray);
                    if ~isempty(bbox_detection) % Atualiza somente se bboxDetection não for vazio, ou seja, se houver alguma face na imagem.
                        bbox = bbox_detection(1,:);
                    end
                    points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));
                    xyPoints = points.Location;
                    numPts = size(xyPoints,1);
                    release(handles.pointTracker);
                    initialize(handles.pointTracker, xyPoints, videoFrameGray);
                    oldPoints = xyPoints;
                    bboxPoints = bbox2points(bbox(1, :));
                    bboxPolygon = reshape(bboxPoints', 1, []);
                else
                    [xyPoints, isFound] = step(handles.pointTracker, videoFrameGray);
                    visiblePoints = xyPoints(isFound, :);
                    oldInliers = oldPoints(isFound, :);
                    numPts = size(visiblePoints, 1);
                    if numPts >= maxNumPts
                        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
                        bboxPoints = transformPointsForward(xform, bboxPoints);
                        bboxPolygon = reshape(bboxPoints', 1, []);
                        oldPoints = visiblePoints;
                        setPoints(handles.pointTracker, oldPoints);
                    end
                end
                faceDetectionFrame = frameCount + round(handles.fps * handles.faceDetectionUpdate);
            end
            x = bboxPolygon(1:2:end);
            y = bboxPolygon(2:2:end);
            b_distance = [min(x) min(y) max(x)-min(x) max(y)-min(y)];
        end
        
        if block_size > size(block, 2)
            if handles.roiTrackingAM == 1
                if handles.ROI == 1
                    %b = [b_distance(1,1), b_distance(1,2)-b_distance(1,2)*.5, b_distance(1,3), (b_distance(1,4))];
                    handles.rectROI = [b_distance(1,1)+b_distance(1,1)*.05, b_distance(1,2)-b_distance(1,2)*.6, b_distance(1,3)-b_distance(1,1)*2*.05, (b_distance(1,4))-b_distance(1,2)*.05];
                elseif handles.ROI == 2
                    handles.rectROI = [b_distance(1,1), b_distance(1,2)+b_distance(1,2)*.4, b_distance(1,3), (b_distance(1,4))-((b_distance(1,4))*.05)];
                elseif handles.ROI == 3
                    handles.rectROI = [b_distance(1,1), b_distance(1,2)-b_distance(1,2)*.5, b_distance(1,3), (b_distance(1,4))+((b_distance(1,4))*4)];
                end
            end
            img = imcrop(videoFrame, handles.rectROI);
            
            R = mean2(img(:,:,1)); % Média dos pixels vermelhos
            G = mean2(img(:,:,2)); % Média dos pixels verdes
            B = mean2(img(:,:,3)); % Média dos pixels azuis
            handles.raw_signals = cat(2, handles.raw_signals, [R;G;B]);
            block = cat(2, block, [R;G;B]);
            
            %Retangulo Region of Interest
            if frameCount >= updateFrame
                if(handles.saveVideoOpt)
                    updateFrame = frameCount + round(handles.fps * handles.faceDetectionUpdate);
                else
                    updateFrame = frameCount + round(handles.fps * handles.faceDetectionUpdate/2);
                end
                % axes(handles.axesUserImg);
                delete(handles.recROI);
                if(handles.readVideo)
                    % axes(handles.axesUserImg);
                    imshow(videoFrame);
                end
                if handles.ROI ~= 4 && handles.roiTrackingAM == 1
                    if (b_distance(1,3)/handles.resolution(1)) < 0.20
                        handles.recROI= rectangle('Position', handles.rectROI, 'EdgeColor','y','LineWidth',3);
                        color = 'y';
                        if show_info_roi
                            set(handles.textInfo, 'string', sprintf(['GET CLOSER to the Camera <', num2str(round((frameCount/max_frames)*100)), '%% Complete>']), 'ForegroundColor', color);
                            show_info_roi = false;
                        else
                            set(handles.textInfo, 'string', ' ');
                            show_info_roi = true;
                        end
                    else
                        color = 'g';
                        if show_info_roi
                            set(handles.textInfo, 'string', sprintf(['PLEASE, WAIT <', num2str(round((frameCount/max_frames)*100)), '%% Complete>']), 'ForegroundColor', color);
                            show_info_roi = false;
                        else
                            set(handles.textInfo, 'string', ' ');
                            show_info_roi = true;
                        end
                        handles.recROI= rectangle('Position', handles.rectROI, 'EdgeColor','g','LineWidth',3);
                    end
                else
                    color = 'g';
                    if show_info_roi
                        set(handles.textInfo, 'string', sprintf(['PLEASE, WAIT <', num2str(round((frameCount/max_frames)*100)), '%% Complete>']), 'ForegroundColor', color);
                        show_info_roi = false;
                    else
                        set(handles.textInfo, 'string', ' ');
                        show_info_roi = true;
                    end
                    handles.recROI = rectangle('Position', handles.rectROI, 'EdgeColor','g','LineWidth',3);
                end
            end
        else
            if block_size == max_frames
                [HR, handles.plot_compORchannel, handles.plot_frequency] = calculate_HR(block, handles.fps, handles.lowerFrequency, handles.upperFrequency, handles.filterFCC, handles.HRDetecMethod);
            else
                HR = calculate_HR(block, handles.fps, handles.lowerFrequency, handles.upperFrequency, handles.filterFCC, handles.HRDetecMethod);
            end
            sobreposicao = fix(block_size - block_sobreposicao);
            block = block(:, sobreposicao:end);
            handles.heart_rate = cat(2, handles.heart_rate, HR);
            if(isempty(handles.x_HR))
                handles.x_HR = cat(2, handles.x_HR, handles.overlapSize + sobreposicao/handles.fps);
            else
                handles.x_HR = cat(2, handles.x_HR, handles.x_HR(end) + sobreposicao/handles.fps);
            end
            set(handles.textHR, 'string', ['Heart Rate: ', num2str(round(HR)), ' BPM'], 'ForegroundColor',color);
        end
        frameCount = frameCount + 1;
        
        
    end
    
    if ~handles.readVideo
        stop(handles.vid);
    end
    if(handles.saveVideoOpt)
        close(video);
    end
    
    if block_size ~= max_frames % Calcula o HR e os vetores do sinal inteiro somente se isso ja nao tiver sido feito acima.
        [handles.HR, handles.plot_compORchannel, handles.plot_frequency] = calculate_HR(handles.raw_signals, handles.fps, handles.lowerFrequency, handles.upperFrequency, handles.filterFCC, handles.HRDetecMethod);
    else
        handles.HR = mean(handles.heart_rate);
    end
    set(handles.textHR, 'string', ['Avg. HR: ' , num2str(round(mean(handles.heart_rate))), ' BPM'],'ForegroundColor', 'g');
    
    if handles.HRDetecMethod == 2
        x = 0:size(handles.plot_compORchannel,2)-1;
        xx = linspace(0,size(handles.plot_compORchannel,2)-1,(size(handles.plot_compORchannel,2)/handles.fps)*handles.interpolation);
        handles.plot_compORchannel = spline(x,handles.plot_compORchannel,xx);
        %[pks, locs] = findpeaks(handles.plot_compORchannel, handles.interpolation,'MinPeakProminence',std(handles.plot_compORchannel,0,2)*2);
        [pks,locs] = findpeaks(handles.plot_compORchannel.^3,handles.interpolation,'MinPeakProminence',std(handles.plot_compORchannel),'MinPeakHeight',1); % 1 {4} 2 {5}
        [pks,locs] = findpeaks(handles.plot_compORchannel.^3,handles.interpolation,'MinPeakProminence',std(handles.plot_compORchannel),'MinPeakHeight',1,'MinPeakDistance', mean(diff(locs))*.7);
        handles.plot_RR = diff(locs)*1000;
    end
    
    if handles.HRDetecMethod == 1
        set(handles.itemMenu_plotFrequency, 'enable', 'on');
    else
        set(handles.itemMenu_plotHRV, 'enable', 'on');
        set(handles.itemMenu_plotComponent, 'enable', 'on');
        set(handles.itemMenu_plotRRPeaks, 'enable', 'on');
    end
    set(handles.itemMenu_plotHR, 'enable', 'on');

    if(handles.saveVideoOpt)
        userName = handles.userName;
        userGender = handles.userGender;
        userAge = handles.userAge;
        videoSize = handles.videoSize;
        windowSize = handles.windowSize;
        overlapSize = handles.overlapSize;
        videoFPS = handles.videoFPS;
        lowerFrequency = handles.lowerFrequency;
        upperFrequency = handles.upperFrequency;
        videoFormat = handles.videoFormat;
        faceDetectionUpdate = handles.faceDetectionUpdate;
        raw_signals = handles.raw_signals;
        w_list = webcamlist;
        webcamName = w_list(handles.webcamList);
        HRVorBP = handles.HRVorBP;
        userHeight = handles.userHeight;
        userMass = handles.userMass;
        userSkin = handles.userSkin;
        userBirthday = handles.userBirthday;
        userID = handles.userID;
        
        if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
            cameraZoom = double(handles.src.Zoom)/100;
        else
            cameraZoom = 100;
        end
        
        HRDetecMethod = handles.HRDetecMethod;
        interpolation = handles.interpolation;
        ROI = handles.ROI;
        if(handles.windowSize == handles.videoSize)
            plot_HR = [[handles.x_HR-1 handles.x_HR];[handles.heart_rate handles.heart_rate]];
        else
            plot_HR = [handles.x_HR; handles.heart_rate];
        end
        plot_frequency_data = handles.plot_frequency;
        plot_compORchannel = handles.plot_compORchannel;
        
        if handles.HRDetecMethod == 2
            plot_RR = handles.plot_RR;
        else
            plot_RR = []; % se for ICA, nao possui vetor RR
        end
        if strcmp(computer,'MACI64')
            save([folder, '/', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'videoFormat', ...
                'lowerFrequency', 'upperFrequency', 'plot_HR', 'plot_frequency_data', 'plot_compORchannel',...
                'plot_RR', 'raw_signals', 'cameraZoom', 'HRDetecMethod', 'userSkin', 'userBirthday', 'userID', 'interpolation', 'userMass', 'ROI', 'faceDetectionUpdate', 'HRVorBP');
            
            % Generate the report
            generateReport([folder, '/', userName], 'HR', handles);
                        
            
            % ID update and save
            userID = userID + 1;
            handles.userID = userID;
            save('Files/userID.mat', 'userID');
            
        elseif strcmp(computer,'PCWIN64')
            save([folder, '\', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'videoFormat', ...
                'lowerFrequency', 'upperFrequency', 'plot_HR', 'plot_frequency_data', 'plot_compORchannel', ...
                'plot_RR', 'raw_signals', 'cameraZoom', 'HRDetecMethod', 'userSkin', 'userBirthday', 'userID', 'interpolation', 'userMass', 'ROI', 'faceDetectionUpdate', 'HRVorBP');
        
            % Generate the report
            generateReport([folder, '\', userName], 'HR', handles);
                        
            
            % ID update and save
            userID = userID + 1;
            handles.userID = userID;
            save('Files/userID.mat', 'userID');
        
        end
    end

    delete(handles.recROI);
    if ~handles.readVideo
        if handles.roiTrackingAM == 1
            if handles.ROI == 4
                set(handles.textInfo, 'string', 'Please, place your HAND in the RED rectangle and press <<START>>', 'ForegroundColor', 'r');
                handles.recROI= rectangle('Position',handles.bHand, 'EdgeColor','r','LineWidth',3);
            else
                set(handles.textInfo, 'string', 'Place your FACE in the FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
            end
        else 
            set(handles.textInfo, 'string', 'Place your FACE or HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
    else
        set(handles.textInfo, 'string', 'Video Processing Complete', 'ForegroundColor', 'w');
    end
    % set(handles.textInfo, 'string', sprintf([num2str(round((frameCount/max_frames)*100)), '%% Complete']));
else
    set(handles.textInfo, 'string', 'Invalid face alignment. Please, align your face and press <<START>>', 'ForegroundColor', 'r');
end

set(hObject, 'visible', 'on');
set(hObject, 'enable', 'on');
set(handles.menu_Settings, 'enable', 'on');
set(handles.menu_CalibrationBP, 'enable', 'on');
guidata(hObject, handles);

% --- Executes on button press in pushbutton_StartBP.
function pushbutton_StartBP_Callback(hObject, eventdata, handles)
show_info_roi = true;
color = 'w';
set(handles.textHR, 'string', ' ');
set(hObject, 'visible', 'off');
set(hObject, 'enable', 'off');
set(handles.menu_Settings, 'enable', 'off');
set(handles.itemMenu_plotFrequency, 'enable', 'off');
set(handles.itemMenu_plotHR, 'enable', 'off');
set(handles.itemMenu_plotHRV, 'enable', 'off');
set(handles.itemMenu_plotComponent, 'enable', 'off');
set(handles.itemMenu_plotRRPeaks, 'enable', 'off');
set(handles.itemMenu_plotPWV, 'enable', 'off');
set(handles.itemMenu_plotplotSpO2, 'enable', 'off');
set(handles.menu_CalibrationBP, 'enable', 'off');

% try
    if handles.roiTrackingAM == 2
        set(handles.textInfo, 'string','Select the FOREHEAD Area');
        handles.rect_forehead = round(getrect);
%         handles.h = imrect(handles.axesUserImg);
%         handles.rect_forehead = round(getPosition(handles.h));
%         delete(handles.h);
        handles.recForehead = rectangle('Position', handles.rect_forehead, 'EdgeColor','g','LineWidth',3);
        set(handles.textInfo, 'string','Select the HAND Area');
        handles.rect_hand = round(getrect);
%         handles.h = imrect(handles.axesUserImg);
%         handles.rect_hand = round(getPosition(handles.h));
%         delete(handles.h);
        handles.recHand = rectangle('Position', handles.rect_hand, 'EdgeColor','g','LineWidth',3);
        bbox_detection = 1;
        b_distance = handles.rect_forehead;
    end
% catch
%     bbox_detection = [];
%     disp('Entrei no Catch')
% end

handles.raw_signals = [];
handles.recForehead = [];
handles.recHand = [];
handles.fps = str2double(handles.videoFPS);
max_frames = handles.videoSize * handles.fps; % Limite de frames pro loop de controle

if ~handles.readVideo
    handles.vid.FramesPerTrigger = 1;
    handles.vid.TriggerRepeat = max_frames + round(handles.fps/2);
    handles.vid.ReturnedColorspace = 'rgb';
    if strcmp(computer,'PCWIN64')
        handles.src.FrameRate = handles.videoFPS;
    end
end

window = handles.windowSize; % in seconds
sobreposicao = handles.overlapSize; % in seconds

block = [];
block_size = window * handles.fps;
block_sobreposicao = sobreposicao * handles.fps;

frameCount = 0;
faceDetectionFrame = 0;
updateFrame = 0;

fp = [handles.lowerFrequency, handles.upperFrequency];  % Bandpass frequencies
f = handles.fps;
wp=(2/f).* fp;
handles.filterFCC = fir1(f, wp);

if handles.roiTrackingAM == 1
    numPts = 0;
    maxNumPts = 10;
    if handles.ROI ~= 4
        if ~handles.readVideo
            test_img = getsnapshot(handles.vid);
            bbox_detection = handles.faceDetector.step(rgb2gray(test_img));
        else
            test_img = read(handles.videoArchive, 1);
            bbox_detection = handles.faceDetector.step(rgb2gray(test_img));
        end
    else
        bbox_detection = 1;
        handles.rect_hand = handles.bHand;
    end
end

if ~isempty(bbox_detection) % Se a face do usuario estiver posicionada no lugar correto
    if(handles.saveVideoOpt) % Create a new folder
        if strcmp(computer, 'PCWIN64')
            folder = [pwd, '\DATA\', handles.userName];
            mkdir(folder);
            video = VideoWriter([folder, '\', handles.userName, '.avi']);
        elseif strcmp(computer, 'MACI64')
            folder = [pwd, '/DATA/', handles.userName];
            mkdir(folder);
            video = VideoWriter([folder, '/', handles.userName, '.avi']);
        end
        video.FrameRate = str2double(handles.videoFPS);
        open(video);
    end
    
    if ~handles.readVideo
        set(handles.textInfo, 'string','Starting Acquisition...');
        start(handles.vid); % Começar a captura de frames
        pause(1);
        getdata(handles.vid,round(handles.fps/2),'uint8');
    end
    
    while frameCount <= max_frames
        if ~handles.readVideo
            videoFrame = getdata(handles.vid,1,'uint8');
        else
            videoFrame = read(handles.videoArchive, frameCount + 1);
        end
        
        if(handles.saveVideoOpt)
            writeVideo(video, videoFrame);
        end
        
        if handles.roiTrackingAM == 1
            if handles.ROI ~= 4
                videoFrameGray = rgb2gray(videoFrame);
                if frameCount >= faceDetectionFrame
                    if numPts < maxNumPts
                        bbox_detection = handles.faceDetector.step(videoFrameGray);
                        if ~isempty(bbox_detection) % Atualiza somente se bboxDetection não for vazio, ou seja, se houver alguma face na imagem.
                            bbox = bbox_detection(1,:);
                        end
                        points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));
                        xyPoints = points.Location;
                        numPts = size(xyPoints,1);
                        release(handles.pointTracker);
                        initialize(handles.pointTracker, xyPoints, videoFrameGray);
                        oldPoints = xyPoints;
                        bboxPoints = bbox2points(bbox(1, :));
                        bboxPolygon = reshape(bboxPoints', 1, []);
                    else
                        [xyPoints, isFound] = step(handles.pointTracker, videoFrameGray);
                        visiblePoints = xyPoints(isFound, :);
                        oldInliers = oldPoints(isFound, :);
                        numPts = size(visiblePoints, 1);
                        if numPts >= maxNumPts
                            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
                            bboxPoints = transformPointsForward(xform, bboxPoints);
                            bboxPolygon = reshape(bboxPoints', 1, []);
                            oldPoints = visiblePoints;
                            setPoints(handles.pointTracker, oldPoints);
                        end
                    end
                    faceDetectionFrame = frameCount + round(handles.fps * handles.faceDetectionUpdate);
                end
                x = bboxPolygon(1:2:end);
                y = bboxPolygon(2:2:end);
                b_distance = [min(x) min(y) max(x)-min(x) max(y)-min(y)];
            end
        end
        
        if block_size > size(block, 2)
            if handles.roiTrackingAM == 1
                handles.rect_forehead = [b_distance(1,1)+b_distance(1,1)*.05, b_distance(1,2)-b_distance(1,2)*.6, b_distance(1,3)-b_distance(1,1)*2*.05, (b_distance(1,4))-b_distance(1,2)*.05];
                handles.rect_hand = handles.bHand;
            end
            img_forehead = imcrop(videoFrame, handles.rect_forehead);
            img_Hand = imcrop(videoFrame, handles.rect_hand);
            
            R_forehead = mean2(img_forehead(:,:,1)); % Média dos pixels vermelhos da testa
            G_forehead = mean2(img_forehead(:,:,2)); % Média dos pixels verdes da testa
            B_forehead = mean2(img_forehead(:,:,3)); % Média dos pixels azuis da testa
            R_hand = mean2(img_Hand(:,:,1)); % Média dos pixels vermelhos da mao
            G_hand = mean2(img_Hand(:,:,2)); % Média dos pixels verdes da mao
            B_hand = mean2(img_Hand(:,:,3)); % Média dos pixels azuis da mao
            
            handles.raw_signals = cat(2, handles.raw_signals, [R_forehead; G_forehead; B_forehead; R_hand;  G_hand;  B_hand]);
            block = cat(2, block, [R_forehead; G_forehead; B_forehead; R_hand;  G_hand;  B_hand]);
            
            %Retangulo Region of Interest
            if frameCount >= updateFrame
                if(handles.saveVideoOpt)
                    updateFrame = frameCount + round(handles.fps * handles.faceDetectionUpdate);
                else
                    updateFrame = frameCount + round(handles.fps * handles.faceDetectionUpdate/2);
                end
                delete(handles.recForehead);
                delete(handles.recHand);
                if(handles.readVideo)
                    % axes(handles.axesUserImg);
                    imshow(videoFrame);
                end
                if (b_distance(1,3)/handles.resolution(1)) < 0.20 && handles.roiTrackingAM == 1
                    handles.recForehead = rectangle('Position', handles.rect_forehead, 'EdgeColor','y','LineWidth',3);
                    handles.recHand = rectangle('Position', handles.rect_hand, 'EdgeColor','y','LineWidth',3);
                    color = 'y';
                    if show_info_roi
                        set(handles.textInfo, 'string', sprintf(['GET CLOSER to the Camera <', num2str(round((frameCount/max_frames)*100)), '%% Complete>']), 'ForegroundColor', color);
                        show_info_roi = false;
                    else
                        set(handles.textInfo, 'string', ' ');
                        show_info_roi = true;
                    end
                else
                    color = 'g';
                    if show_info_roi
                        set(handles.textInfo, 'string', sprintf(['PLEASE, WAIT <', num2str(round((frameCount/max_frames)*100)), '%% Complete>']), 'ForegroundColor', color);
                        show_info_roi = false;
                    else
                        set(handles.textInfo, 'string', ' ');
                        show_info_roi = true;
                    end
                    handles.recForehead = rectangle('Position', handles.rect_forehead, 'EdgeColor','g','LineWidth',3);
                    handles.recHand = rectangle('Position', handles.rect_hand, 'EdgeColor','g','LineWidth',3);
                end
            end
        else
            filterFCC = handles.filterFCC;
            fps = handles.fps;
            save([pwd, '/mapa.mat'], 'block', 'fps', 'filterFCC');
            [handles.SBP, handles.DBP, handles.PWV, handles.PTT] = calculate_BP(block, handles.fps, handles.filterFCC, handles.userHeight, handles.userGender);
            sobreposicao = fix(block_size - block_sobreposicao);
            block = block(:, sobreposicao:end);
            set(handles.textHR, 'string', ['Blood Pressure: ', num2str(round(handles.SBP)), '/', num2str(round(handles.DBP)), ' mmHg'], 'ForegroundColor',color);
        end
        frameCount = frameCount + 1;
    end
    
    if ~handles.readVideo
        stop(handles.vid);
    end
    if(handles.saveVideoOpt)
        close(video);
    end
    
    if(handles.saveVideoOpt)
        userName = handles.userName;
        userGender = handles.userGender;
        userAge = handles.userAge;
        videoSize = handles.videoSize;
        windowSize = handles.windowSize;
        overlapSize = handles.overlapSize;
        videoFPS = handles.videoFPS;
        lowerFrequency = handles.lowerFrequency;
        upperFrequency = handles.upperFrequency;
        videoFormat = handles.videoFormat;
        faceDetectionUpdate = handles.faceDetectionUpdate;
        raw_signals = handles.raw_signals;
        w_list = webcamlist;
        webcamName = w_list(handles.webcamList);
        HRVorBP = handles.HRVorBP;
        userMass = handles.userMass;
        userHeight = handles.userHeight;
        if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
            cameraZoom = double(handles.src.Zoom)/100;
        else
            cameraZoom = 100;
        end
        SBP = handles.SBP;
        DBP = handles.DBP;
        PWV = handles.PWV;
        PTT = handles.PTT;
        if strcmp(computer,'MACI64')
            save([folder, '/', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'videoFormat', ...
                'lowerFrequency', 'upperFrequency', 'raw_signals', 'userMass', 'cameraZoom', 'faceDetectionUpdate', 'HRVorBP', 'SBP', 'DBP', 'PWV', 'PTT');
        elseif strcmp(computer,'PCWIN64')
            save([folder, '\', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'videoFormat', ...
                'lowerFrequency', 'upperFrequency', 'raw_signals', 'userMass', 'cameraZoom', 'faceDetectionUpdate', 'HRVorBP', 'SBP', 'DBP', 'PWV', 'PTT');
        end   
    end
    delete(handles.recForehead);
    delete(handles.recHand);
    if ~handles.readVideo
        if handles.ROI == 4 && handles.roiTrackingAM == 1
            set(handles.textInfo, 'string', 'Place your HAND in the RED rectangle and your FACE in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
            handles.recHand = rectangle('Position',handles.bHand, 'EdgeColor','r','LineWidth',3);
        else
            set(handles.textInfo, 'string', 'Place your FACE and HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
    else
        set(handles.textInfo, 'string', 'Video Processing Complete', 'ForegroundColor', 'w');
    end
    % set(handles.textInfo, 'string', sprintf([num2str(round((frameCount/max_frames)*100)), '%% Complete']));
else
    set(handles.textInfo, 'string', 'Invalid ROI alignment. Please, align the ROI and press <<START>>', 'ForegroundColor', 'r');
end
% imrect(handles.axesUserImg)

set(hObject, 'visible', 'on');
set(hObject, 'enable', 'on');
set(handles.menu_Settings, 'enable', 'on');
set(handles.menu_CalibrationBP, 'enable', 'on');
guidata(hObject, handles);

% --- Executes on button press in pushbutton_StartPWV.
function pushbutton_StartPWV_Callback(hObject, eventdata, handles)
    dist = str2double(handles.distance) * 0.01;
    % ROIs positions
    posRoi1 = handles.roi1.Position;
    posRoi2 = handles.roi2.Position;    
    
    % ---------------------------------------------------------------------   
    % Defines some graphical interface settings
    set(handles.textHR, 'string', ' ');
    set(hObject, 'visible', 'off');
    set(hObject, 'enable', 'off');
    set(handles.menu_Settings, 'enable', 'off');
    set(handles.itemMenu_plotFrequency, 'enable', 'off');
    set(handles.itemMenu_plotHR, 'enable', 'off');
    set(handles.itemMenu_plotHRV, 'enable', 'off');
    set(handles.itemMenu_plotComponent, 'enable', 'off');
    set(handles.itemMenu_plotRRPeaks, 'enable', 'off');
    set(handles.menu_Plots, 'enable', 'off');
    set(handles.menu_CalibrationBP, 'enable', 'off');
    set(handles.itemMenu_plotPWV, 'enable', 'off');
    set(handles.itemMenu_plotSpO2, 'enable', 'off');
    set(handles.menu_CalibrationBP, 'enable', 'off');
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    % Filter
    handles.fps = str2double(handles.videoFPS);
    fs = handles.fps;
    rp = 3;
    rs = 60;
    
    f = [handles.lowerFrequency, handles.upperFrequency];

    a = [2 0];

    dev = [(10^(rp/20)-1) / ....
    (10^(rp/20)+1) 10^(-rs/20)];

    [n,fo,ao,w] = firpmord(f,a,dev,fs);

    handles.filterFCC = firpm(n,fo,ao,w);
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    % Inicialization
    handles.recForehead = [];
    handles.recHand = [];
    window = handles.windowSize; % in seconds
    sobreposicao = handles.overlapSize; % in seconds
    
    % Stores signals
    handles.raw_signals = [];
    block = [];
    block_size = window * handles.fps;
    block_sobreposicao = sobreposicao * handles.fps;
    % Controls the loop
    max_frames = handles.videoSize * handles.fps; % Frame limit for the control loop             
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    % Video configuration
    % --- Starts capturing the video --- 
    if ~handles.readVideo
        handles.vid.FramesPerTrigger = 1;
        handles.vid.TriggerRepeat = max_frames + round(handles.fps/2);
        handles.vid.ReturnedColorspace = 'rgb';
        if strcmp(computer,'PCWIN64')
            handles.src.FrameRate = handles.videoFPS;
        end
    end
    
    % --- Save the video ---
    handles.saveVideoOpt
    if(handles.saveVideoOpt)
        if strcmp(computer, 'PCWIN64')
            folder = [pwd, '\DATA\', handles.userName,  '_', num2str(handles.userID)];
            mkdir(folder);
            video = VideoWriter([folder, '\', handles.userName, '.avi']);
        elseif strcmp(computer, 'MACI64')
            folder = [pwd, '/DATA/', handles.userName,  '_', num2str(handles.userID)];
            mkdir(folder);
            video = VideoWriter([folder, '/', handles.userName, '.avi']);
        end
        video.FrameRate = str2double(handles.videoFPS);
        open(video);
    end
    
    % --- Starts capturing frames ---
    if ~handles.readVideo
        set(handles.textInfo, 'string','Starting Acquisition...');
        start(handles.vid); % Start capturing frames
        pause(1);
        getdata(handles.vid,round(handles.fps/2),'uint8');
    end
    
    updateFrame = 0;
    
    % Settings for data to be acquired from a saved video
     % on PC
     % For webcam video
    if ~handles.readVideo
        stop(handles.vid);
    end
    
    % --- Mostar Preview and order ROIs ---
    if ~handles.readVideo
        handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
    end
    % ---------------------------------------------------------------------

    % ---------------------------------------------------------------------
    % Rectangles of regions of interest
    % --- Proximal Region ---
    handles.rect_Proximal = posRoi1;
    handles.rectProximal = rectangle('Position', handles.rect_Proximal, 'EdgeColor','g','LineWidth',3);
    
    % --- Distal Region ---
    handles.rect_Distal = posRoi2;
    handles.recDistal = rectangle('Position', handles.rect_Distal, 'EdgeColor','g','LineWidth',3);
    
    % --- Starts capturing frames ---
    if ~handles.readVideo
        set(handles.textInfo, 'string','Starting Acquisition...');
        start(handles.vid); % Start capturing frames
        pause(1);
        getdata(handles.vid,round(handles.fps/2),'uint8');
    end
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    signal_quality = '';
    
    for i = 0 : max_frames  

        % --- Video ---
        % Reads the buffer frame
        if ~handles.readVideo
            videoFrame = getdata(handles.vid,1,'uint8');
        else
            videoFrame = read(handles.videoArchive, i + 1);
        end
        
        % Video Save
        if(handles.saveVideoOpt)
            writeVideo(video, videoFrame);
        end
        % --- video ---
         
        % --- Processing ---
        if block_size > size(block, 2)
            % Take the rectangle of distal and proximal region
            img_Forehead = imcrop(videoFrame, handles.rect_Proximal);
            img_Hand = imcrop(videoFrame, handles.rect_Distal);

            % Pixel Average
            % Proximal
            R_Hand = mean2(img_Hand(:,:,1));
            G_Hand = mean2(img_Hand(:,:,2));
            B_Hand = mean2(img_Hand(:,:,3));

            % Distal
            R_Forehead = mean2(img_Forehead(:,:,1));
            G_Forehead = mean2(img_Forehead(:,:,2));
            B_Forehead = mean2(img_Forehead(:,:,3));
            
            % Saves the signals
            handles.raw_signals = cat(2, handles.raw_signals, [R_Forehead; G_Forehead; B_Forehead; R_Hand;  G_Hand;  B_Hand]);
            block = cat(2, block, [R_Forehead; G_Forehead; B_Forehead; R_Hand;  G_Hand;  B_Hand]);
            
            % Rectangle of the region of interest
            if i >= updateFrame
                
                if(handles.readVideo)
                    imshow(videoFrame);
                end
                
                if(handles.saveVideoOpt)
                    updateFrame = i + round(handles.fps * handles.faceDetectionUpdate);
                else
                    updateFrame = i + round(handles.fps * handles.faceDetectionUpdate/2);
                end
                
                delete(handles.rectProximal);
                delete(handles.recDistal);
                
                handles.rectProximal = rectangle('Position', handles.rect_Proximal, 'EdgeColor','g','LineWidth',3);
                handles.recDistal = rectangle('Position', handles.rect_Distal, 'EdgeColor','g','LineWidth',3);
                
                set(handles.textInfo, 'string', sprintf(['PLEASE, WAIT <', ....
                num2str(round((i/max_frames)*100)), '%% Complete>']),  ....
                'ForegroundColor', 'w');
                
                % Signal Quality
                delete(handles.signalInfo);
                handles.signalInfo = text(10, 50, signal_quality, 'color', 'w', 'FontSize',15);
            end
        else
            % Calculates the PWV and PTT
            filterFCC = handles.filterFCC;
            fps = handles.fps;
            save([pwd, '/PWV.mat'], 'dist', 'block', 'fps', 'filterFCC');
            
            % Pulse Wave Velocity and Pulse Time Transit
            [handles.PWV, handles.PTT, handles.signal_quality_final, handles.SNRDistal, handles.SNRProximal] ....
                = calculate_PWV(block, handles.fps, ....
               handles.interpolation, handles.filterFCC, dist);
           
            [handles.SBP, handles.DBP] = PWV_PTT_to_BP(handles.PTT, handles.PWV);
            
            handles.SBP = round(handles.SBP, 2);
            handles.DBP = round(handles.DBP, 2);
            
            sobreposicao = fix(block_size - block_sobreposicao);
            block = block(:, sobreposicao:end);
            set(handles.textHR, 'string', [sprintf('PTT: %.4f', handles.PTT), ....
                sprintf(' s | PWV: %.2f', handles.PWV), ' m/s | ',  ....
                sprintf('Distance: %.2f m', dist), newline, ....
                sprintf('SBP: %.2f mmHg', handles.SBP), sprintf(' | DBP: %.2f mmHg', handles.DBP)],....
                'FontSize', 10, 'ForegroundColor','w');
        end
        % --- Processing ---
        
        % --- Signal Evaluation ---
        try 
        if i ~= 0
            if mod(i, 10*handles.fps) == 0
                snr_d = snr(block(2, i - 10*handles.fps + 1: i), handles.fps);
                snr_p = snr(block(5, i - 10*handles.fps + 1: i), handles.fps);
                aux = min([snr_d snr_p]);
                signal_quality = 'Signal Quality Preview: ';
                if aux < -2
                    signal_quality = strcat([signal_quality 'Bad']);
                else
                    if aux < 2
                        signal_quality = strcat([signal_quality 'Good']);
                    else
                        signal_quality = strcat([signal_quality 'Excellent']);
                    end
                end
                
                signal_quality = sprintf([signal_quality, newline, ....
                    'SNR Proximal: ', num2str(snr_p), ' dB', newline, ....
                    'SNR Distal: ', num2str(snr_d), ' dB']);
                               
            end
        end
        catch
             warning('There are not enough samples to assess the signal');
        end
        % --- Signal Evaluation ---
    end
    % ---------------------------------------------------------------------        
    
    % ---------------------------------------------------------------------   

    % Video stop
    if ~handles.readVideo
        stop(handles.vid);
    end
    % Video close
    if(handles.saveVideoOpt)
        close(video);
    end
    
    % Saves the data in a .mat file
    if(handles.saveVideoOpt)
        userName = handles.userName;
        userGender = handles.userGender;
        userAge = handles.userAge;
        videoSize = handles.videoSize;
        windowSize = handles.windowSize;
        overlapSize = handles.overlapSize;
        videoFPS = handles.videoFPS;
        lowerFrequency = handles.lowerFrequency;
        upperFrequency = handles.upperFrequency;
        videoFormat = handles.videoFormat;
        faceDetectionUpdate = handles.faceDetectionUpdate;
        raw_signals = handles.raw_signals;
        w_list = webcamlist;
        webcamName = w_list(handles.webcamList);
        HRVorBP = handles.HRVorBP;
        userHeight = handles.userHeight;
        interpolation = handles.interpolation;
        dcm = handles.calibrationFactor;
        userMass = handles.userMass;
        userBMI = handles.userBMI;
        userSkin = handles.userSkin;
        userBirthday = handles.userBirthday;
        userID = handles.userID;
        SBP = handles.SBP;
        DBP = handles.DBP;
        
        if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
            cameraZoom = double(handles.src.Zoom)/100;
        else
            cameraZoom = 100;
        end
        PWV = handles.PWV;
        PTT = handles.PTT;
        if strcmp(computer,'MACI64')
            save([folder, '/', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'interpolation', 'videoFormat', ...
                'lowerFrequency', 'upperFrequency', 'raw_signals', 'userMass', 'userSkin', 'cameraZoom', 'faceDetectionUpdate', 'HRVorBP', 'PWV', 'PTT', 'dist' ....
                ,'dcm', 'filterFCC', 'userBirthday', 'userID', 'SBP', 'DBP', 'userBMI');
                        
            % ---- Report -----
            set(handles.textInfo, 'string', 'Generating the Report...', 'ForegroundColor', 'w');
            % Graphical User Interface Elements
            % Loading pointer
            oldpointer = get(handles.figure, 'pointer');
            set(handles.figure, 'pointer', 'watch')
            drawnow;
            
            % Generate the report
            generateReport([folder, '/', userName], 'PWV', handles);
            
            set(handles.figure, 'pointer', oldpointer);
            
            % Saves ID, PTT and PWV as a csv file
            PTT = round(PTT, 5);
            PWV = round(PWV, 5);
            T = table(userID, PTT, PWV, 'VariableNames', {'ID', 'PTT', 'PWV'});
            writetable(T, 'Files/PTT_PWV_table.xlsx','WriteMode','Append');
            
            % ID update and save
            userID = userID + 1;
            handles.userID = userID;
            save('Files/userID.mat', 'userID');
        elseif strcmp(computer,'PCWIN64')
            save([folder, '\', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'interpolation', 'videoFormat', ...
                'lowerFrequency', 'upperFrequency', 'raw_signals', 'userMass', 'userSkin', 'cameraZoom', 'faceDetectionUpdate', 'HRVorBP', 'PWV', 'PTT', 'dist' ....
                ,'dcm', 'filterFCC', 'userBirthday', 'userID', 'SBP', 'DBP','userBMI');
            
            set(handles.textInfo, 'string', 'Generating the Report...', 'ForegroundColor', 'w');

            % Graphical User Interface Elements
            % Loading pointer
            oldpointer = get(handles.figure, 'pointer');
            set(handles.figure, 'pointer', 'watch')
            drawnow;
            
            % Generate the report
            generateReport([folder, '\', userName], 'PWV', handles);
            
            set(handles.figure, 'pointer', oldpointer);
            
            % Saves ID, PTT and PWV as a csv file
            PTT = round(PTT, 5);
            PWV = round(PWV, 5);
            T = table(userID, PTT, PWV, 'VariableNames', {'ID', 'PTT', 'PWV'});
            writetable(T, 'Files/PTT_PWV_table.xlsx','WriteMode','Append');
            
            % ID update and save
            userID = userID + 1;
            handles.userID = userID;
            save('Files\userID.mat', 'userID');
        end   
    end
    
    delete(handles.recForehead);
    delete(handles.recHand);
    
    if ~handles.readVideo
        if handles.ROI == 4 && handles.roiTrackingAM == 1
            set(handles.textInfo, 'string', 'Place your HAND in the RED rectangle and your FACE in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
            handles.recHand = rectangle('Position',handles.bHand, 'EdgeColor','r','LineWidth',3);
        else
            set(handles.textInfo, 'string', 'Place your HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
    else
        set(handles.textInfo, 'string', 'Processing Complete', 'ForegroundColor', 'w');
    end
    
    handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
    set(hObject, 'visible', 'on');
    set(hObject, 'enable', 'on');
    set(handles.menu_Settings, 'enable', 'on');
    set(handles.menu_CalibrationBP, 'enable', 'on');
    set(handles.menu_Plots, 'enable', 'on');
    set(handles.itemMenu_plotPWV, 'enable', 'on');
    
    % Signal Quality Information
    c = 'g';
    
    if strcmp(handles.signal_quality_final, 'Good')
       c = 'y';
    else
        if strcmp(handles.signal_quality_final, 'Bad')
            c = 'r';
        end
    end
    
    delete(handles.signalInfo);
    handles.signalInfo = text(10, 50, strcat(['Signal Quality Final: ' handles.signal_quality_final]), 'color', c, 'FontSize',15);
   
    % Reset Distance
    handles.distance = '0';
    
    handles = createRois(hObject, handles);
   
guidata(hObject, handles);

% --- Executes on button press in pushbutton_StartPulseOximetry.
function pushbutton_StartPulseOximetry_Callback(hObject, eventdata, handles)
    % ROIs positions
    posRoi = handles.roi1.Position;   
    
    handles.time_sobre = 4;
    
    % ---------------------------------------------------------------------   
    % Defines some graphical interface settings
    set(handles.textHR, 'string', ' ');
    set(hObject, 'visible', 'off');
    set(hObject, 'enable', 'off');
    set(handles.menu_Settings, 'enable', 'off');
    set(handles.itemMenu_plotFrequency, 'enable', 'off');
    set(handles.itemMenu_plotHR, 'enable', 'off');
    set(handles.itemMenu_plotHRV, 'enable', 'off');
    set(handles.itemMenu_plotComponent, 'enable', 'off');
    set(handles.itemMenu_plotRRPeaks, 'enable', 'off');
    set(handles.menu_Plots, 'enable', 'off');
    set(handles.itemMenu_plotPWV, 'enable', 'off');
    set(handles.itemMenu_plotSpO2, 'enable', 'off');
    set(handles.menu_CalibrationBP, 'enable', 'off');
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    % Filter
    handles.fps = str2double(handles.videoFPS);
    handles.lowerFrequency = 0.7;
    [A,B,C,D] = butter(1, handles.lowerFrequency/handles.fps, 'low');
    [handles.filter_SOS, handles.g] = ss2sos(A,B,C,D);
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    % Inicialization
    handles.rectRoi = [];
    window = handles.windowSize; % in seconds
    sobreposicao = handles.overlapSize; % in seconds
    
    % Stores signals
    handles.raw_signals = [];
    block = [];
    block_size = window * handles.fps;
    block_sobreposicao = sobreposicao * handles.fps;
    % Controls the loop
    max_frames = handles.videoSize * handles.fps; % Frame limit for the control loop             
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    % Video configuration
    % --- Starts capturing the video --- 
    if ~handles.readVideo
        handles.vid.FramesPerTrigger = 1;
        handles.vid.TriggerRepeat = max_frames + round(handles.fps/2);
        handles.vid.ReturnedColorspace = 'rgb';
        if strcmp(computer,'PCWIN64')
            handles.src.FrameRate = handles.videoFPS;
        end
    end
    
    % --- Save the video ---
    handles.saveVideoOpt
    if(handles.saveVideoOpt)
        if strcmp(computer, 'PCWIN64')
            folder = [pwd, '\DATA\', handles.userName];
            mkdir(folder);
            video = VideoWriter([folder, '\', handles.userName, '.avi']);
        elseif strcmp(computer, 'MACI64')
            folder = [pwd, '/DATA/', handles.userName];
            mkdir(folder);
            video = VideoWriter([folder, '/', handles.userName, '.avi']);
        end
        video.FrameRate = str2double(handles.videoFPS);
        open(video);
    end
    
    % --- Starts capturing frames ---
    if ~handles.readVideo
        set(handles.textInfo, 'string','Starting Acquisition...');
        start(handles.vid); % Start capturing frames
        pause(1);
        getdata(handles.vid,round(handles.fps/2),'uint8');
    end
    
    updateFrame = 0;
    
    % Settings for data to be acquired from a saved video
    % on PC
    % For webcam video
    if ~handles.readVideo
        stop(handles.vid);
    end
    
    % --- Mostar Preview and order ROIs ---
    if ~handles.readVideo
        handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
    end
    % ---------------------------------------------------------------------

    % ---------------------------------------------------------------------
    % Rectangle of region of interest
    handles.rect_roi = posRoi;
    handles.rectRoi = rectangle('Position', handles.rect_roi, 'EdgeColor','g','LineWidth',3);
    
    
    % --- Starts capturing frames ---
    if ~handles.readVideo
        set(handles.textInfo, 'string','Starting Acquisition...');
        start(handles.vid); % Start capturing frames
        pause(1);
        getdata(handles.vid,round(handles.fps/2),'uint8');
    end
    % ---------------------------------------------------------------------
    
    % ---------------------------------------------------------------------
    signal_quality = '';
    signal_quality_final = '';
    
    handles.SpO2 = [];
    handles.std_signals = [];
    
    for i = 0 : max_frames  

        % --- Video ---
        % Reads the buffer frame
        if ~handles.readVideo
            videoFrame = getdata(handles.vid,1,'uint8');
        else
            videoFrame = read(handles.videoArchive, i + 1);
        end
        
        % Video Save
        if(handles.saveVideoOpt)
            writeVideo(video, videoFrame);
        end
        % --- video ---
         
        % --- Processing ---
        if block_size > size(block, 2)
            % Take the rectangle of distal and proximal region
            img_roi = imcrop(videoFrame, handles.rect_roi);

            % Pixel Average
            % Proximal
            R_Roi = mean2(img_roi(:,:,1));
            G_Roi = mean2(img_roi(:,:,2));
            B_Roi = mean2(img_roi(:,:,3));

            % Saves the signals
            handles.raw_signals = cat(2, handles.raw_signals, [R_Roi; G_Roi; B_Roi]);
            block = cat(2, block, [R_Roi; G_Roi; B_Roi]);
            
            % Rectangle of the region of interest
            if i >= updateFrame
                
                if(handles.readVideo)
                    imshow(videoFrame);
                end
                
                if(handles.saveVideoOpt)
                    updateFrame = i + round(handles.fps * handles.faceDetectionUpdate);
                else
                    updateFrame = i + round(handles.fps * handles.faceDetectionUpdate/2);
                end
                
                delete(handles.rectRoi);
                
                handles.rectRoi = rectangle('Position', handles.rect_roi, 'EdgeColor','g','LineWidth',3);
                
                set(handles.textInfo, 'string', sprintf(['PLEASE, WAIT <', ....
                num2str(round((i/max_frames)*100)), '%% Complete>']),  ....
                'ForegroundColor', 'w');
                
                % Signal Quality
                delete(handles.signalInfo);
                handles.signalInfo = text(10, 50, signal_quality, 'color', 'w', 'FontSize',15);
            end
        else
            % Calculates the SpO2 saturation
            
            save([pwd, '/SpO2.mat'],'block');
            
            [temp, handles.signal_quality_final, handles.SNRRed, handles.SNRGreen] = ....
                calculate_SpO2(handles.filter_SOS, handles.g, block(1,:), block(2,:), ....
                handles.time_sobre, handles.fps);
            
            handles.SpO2 = cat(2, temp, handles.SpO2);
            
            sobreposicao = fix(block_size - block_sobreposicao);
            block = block(:, sobreposicao:end);
            
            formatSpect = "%d%%";
            str = join(compose(formatSpect, handles.SpO2));
            str = join(['SpO2 every' num2str(handles.time_sobre) 's:' str]);
            
            set(handles.textHR, 'string', str, 'FontSize', 10, ....
                'ForegroundColor','w');
        end
        % --- Processing ---
        
        % --- Signal Evaluation ---
        try 
            if mod(i, 10*handles.fps) == 0
                snr_r = snr(block(1, i - 10*handles.fps + 1: i), handles.fps);
                snr_g = snr(block(2, i - 10*handles.fps + 1: i), handles.fps);
                aux = min([snr_r snr_g]);
                signal_quality = 'Signal Quality Preview: ';
                if aux < -2
                    signal_quality = strcat([signal_quality 'Bad']);
                else
                    if aux < 2
                        signal_quality = strcat([signal_quality 'Good']);
                    else
                        signal_quality = strcat([signal_quality 'Excellent']);
                    end
                end
                
                signal_quality = sprintf([signal_quality, newline, ....
                    'SNR Red Channel: ', num2str(snr_r), ' dB', newline, ....
                    'SNR Green Channel: ', num2str(snr_g), ' dB']);
                               
            end
        catch
             warning('There are not enough samples to assess the signal');
        end
        % --- Signal Evaluation ---
    end

    % ---------------------------------------------------------------------        
    
    % --- SpO2 Plot ---
    figure('Name','PWV Plot','NumberTitle','off');
    
    hold on;
    y = mean(handles.SpO2);
    
    x = 0:handles.time_sobre:handles.videoSize - 1;
    plot(x, handles.SpO2, '-o', 'LineWidth', 2);
    line([0 x(end)], [y y], 'Color', 'r', 'lineWidth', 2);
    
    xlabel('Time (s)');
    ylabel('SpO2');
    ytickformat('percentage');
    title('Contactless SpO2%');
    legend('SpO2', sprintf(['Average SpO2 - ', num2str(y), '%']));
    
    hold off;
    % --- SpO2 Plot ---
    % ---------------------------------------------------------------------   

    % Video stop
    if ~handles.readVideo
        stop(handles.vid);
    end
    % Video close
    if(handles.saveVideoOpt)
        close(video);
    end
    
    % Saves the data in a .mat file
    if(handles.saveVideoOpt)
        userName = handles.userName;
        userGender = handles.userGender;
        userAge = handles.userAge;
        videoSize = handles.videoSize;
        windowSize = handles.windowSize;
        overlapSize = handles.overlapSize;
        videoFPS = handles.videoFPS;
        lowerFrequency = handles.lowerFrequency;
        videoFormat = handles.videoFormat;
        faceDetectionUpdate = handles.faceDetectionUpdate;
        raw_signals = handles.raw_signals;
        w_list = webcamlist;
        webcamName = w_list(handles.webcamList);
        HRVorBP = handles.HRVorBP;
        userHeight = handles.userHeight;
        userMass = handles.userMass;
        userSkin = handles.userSkin;
        userBirthday = handles.userBirthday;
        userID = handles.userID;
        SpO2 = handles.SpO2;
        time_sobre = handles.time_sobre;
        filter = handles.filter_SOS;
        gain = handles.g;
        
        if(isprop(handles.src, 'Zoom')) % If the camera does not have the 'Zoom' property, set z as the default value = 100
            cameraZoom = double(handles.src.Zoom)/100;
        else
            cameraZoom = 100;
        end
        
        if strcmp(computer,'MACI64')
            save([folder, '/', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'videoFormat', ...
                'lowerFrequency', 'raw_signals', 'userMass', 'userSkin', 'cameraZoom', 'faceDetectionUpdate', 'HRVorBP', ....
                'userID', 'filter', 'gain', 'SpO2', 'time_sobre', 'userBirthday');
            
            % Fix this
            
            % -- Report ---
            set(handles.textInfo, 'string', 'Generating the Report...', 'ForegroundColor', 'w');
            % Graphical User Interface Elements
            % Loading pointer
            oldpointer = get(handles.figure, 'pointer');
            set(handles.figure, 'pointer', 'watch')
            drawnow;
            
            generateReport([folder, '/', userName], 'SpO2', handles);
            
            set(handles.figure, 'pointer', oldpointer);

            
            % ID update and save
            userID = userID + 1;
            handles.userID = userID;
            save('Files/userID.mat', 'userID');
            
        elseif strcmp(computer,'PCWIN64')
            save([folder, '\', handles.userName, '.mat'], 'userName', 'userGender', 'userAge', 'userHeight', ...
                'videoSize', 'windowSize', 'overlapSize', 'webcamName', 'videoFPS', 'videoFormat', ...
                'lowerFrequency', 'raw_signals', 'userMass', 'userSkin', 'cameraZoom', 'faceDetectionUpdate', 'HRVorBP', ....
                'userID', 'filter', 'gain', 'SpO2', 'time_sobre', 'userBirthday');
            
            % Fix this
            
            % -- Report ---
            set(handles.textInfo, 'string', 'Generating the Report...', 'ForegroundColor', 'w');
            % Graphical User Interface Elements
            % Loading pointer
            oldpointer = get(handles.figure, 'pointer');
            set(handles.figure, 'pointer', 'watch')
            drawnow;
            
            generateReport([folder, '\', userName], 'SpO2', handles);
            
            set(handles.figure, 'pointer', oldpointer);

            
            % ID update and save
            userID = userID + 1;
            handles.userID = userID;
            save('Files\userID.mat', 'userID');
        end
    end
    
    delete(handles.rectRoi);
    
    if ~handles.readVideo
        if handles.ROI == 4 && handles.roiTrackingAM == 1
            set(handles.textInfo, 'string', 'Place your HAND in the RED rectangle and your FACE in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
            handles.recHand = rectangle('Position',handles.bHand, 'EdgeColor','r','LineWidth',3);
        else
            set(handles.textInfo, 'string', 'Place your HAND in FRONT of the CAMERA and press <<START>>', 'ForegroundColor', 'r');
        end
    else
        set(handles.textInfo, 'string', 'Video Processing Complete', 'ForegroundColor', 'w');
    end
    
    handles.p = preview(handles.vid, image(zeros(handles.resolution(2),handles.resolution(1),3),'Parent',handles.axesUserImg));
    set(hObject, 'visible', 'on');
    set(hObject, 'enable', 'on');
    set(handles.menu_Settings, 'enable', 'on');
    set(handles.menu_Plots, 'enable', 'on');
    set(handles.itemMenu_plotSpO2, 'enable', 'on');
    set(handles.menu_CalibrationBP, 'enable', 'on');
    
    % Signal Quality Information
    c = 'g';
    
    if strcmp(handles.signal_quality_final, 'Good')
       c = 'y';
    else
        if strcmp(handles.signal_quality_final, 'Bad')
            c = 'r';
        end
    end
    
    delete(handles.signalInfo);
    handles.signalInfo = text(10, 50, strcat(['Signal Quality Final: ' handles.signal_quality_final]), 'color', c, 'FontSize',15);
   
    handles = createRois(hObject, handles);
guidata(hObject, handles);
% --------------------------------------------------------------------
% Variables - End
% --------------------------------------------------------------------



% --------------------------------------------------------------------
% Others - Start
% --------------------------------------------------------------------
% --- Executes on button press in pushbutton_StartCalibrate.
% Software calibration for measure the distance between two rois in real time
function pushbutton_StartCalibrate_Callback(hObject, eventdata, handles)
    start(handles.vid); % Starts the frames acquisition
    if strcmp(handles.distance, '0')
        set(handles.textHR, 'string', 'Please enter the distance');
        msgbox('Please enter the distance');
    else
        posRoi1 = handles.roi1.Position;
        posRoi2 = handles.roi2.Position;

        p1 = [(posRoi1(1) + posRoi1(3) + posRoi1(1))/2, (posRoi1(2) + posRoi1(4) + posRoi1(2))/2];
        p2 = [(posRoi2(1) + posRoi2(3) + posRoi2(1))/2, (posRoi2(2) + posRoi2(4) + posRoi2(2))/2];
        
        dpix = sqrt((p1(1)-p2(1))^2+(p1(2)-p2(2))^2);

        % Convert an unknown distance in pixels to cm
        dcm = dpix/str2double(handles.distance);                         
        save('Files/calibrationFactor.mat', 'dcm');
        handles.calibrationFactor = dcm;
        set(handles.textHR, 'string', 'Software calibration completed');
        msgbox('Software calibration completed');
        
%         set(handles.distance, 'string', '0');

    end
    
    handles.distance = '0';

guidata(hObject, handles);

% Calculates and shows the distance in real time between the two rois
function allevents(src, evt, handles, hObject)
    % Calculation of distance in real time. Needs Calibrate
    
    evname = evt.EventName;
    switch(evname)
        case{'MovingROI'}
            
            displayDistance = 1;
            if str2double(handles.distance) ~= 0 && ....
                    (handles.HRVorBP == 3 || handles.HRVorBP == 4)
                displayDistance = 0;
            end
            
            if str2double(handles.distance) <= 0 && handles.HRVorBP == 4
                set(handles.textHR, 'string', 'Please enter the distance');
                msgbox('Please enter the distance');
                return;
            end
            
            if ~isfile('Files/calibrationFactor.mat') && handles.HRVorBP == 3
                 msgbox('Please calibrate the software before');
                 displayDistance = 0;
                 set(handles.textHR, 'string', 'Please calibrate the software before');
            end

            posRoi1 = handles.roi1.Position;
            posRoi2 = handles.roi2.Position;
                
            centroRoi1 = [(posRoi1(1) + posRoi1(3) + posRoi1(1))/2, (posRoi1(2) + posRoi1(4) + posRoi1(2))/2];
            centroRoi2 = [(posRoi2(1) + posRoi2(3) + posRoi2(1))/2, (posRoi2(2) + posRoi2(4) + posRoi2(2))/2];
            
            if displayDistance == 1
                
                dcm = handles.calibrationFactor;
                dist = ROIS_distance(centroRoi1(1), centroRoi2(1), centroRoi1(2), ....
                    centroRoi2(2), dcm);

                handles.distance = num2str(dist);

                set(handles.textInfo, 'string',strcat(['Distance = ', num2str(str2double(handles.distance)*0.01), ' m'])); 
                set(handles.linha, 'x', [centroRoi1(1) centroRoi2(1)]);
                set(handles.linha, 'y', [centroRoi1(2) centroRoi2(2)]);
            else
                set(handles.textInfo, 'string',strcat(['Distance = ', num2str(str2double(handles.distance)*0.01), ' m'])); 
                set(handles.linha, 'x', [centroRoi1(1) centroRoi2(1)]);
                set(handles.linha, 'y', [centroRoi1(2) centroRoi2(2)]);
            end
    end
guidata(hObject, handles);

% Creates two rois of signal
function handles = createRois(hObject, handles)
    % Create two sliding ROIs case choice is option PWV or Calibrate -
    % Distancce
    
    % Sets an acceptable size to show the square of the ROIs in 
    % different resolutions
    if handles.resolution(1) <= 850
        handles.tam_roi = 50;
    else
        handles.tam_roi = 75;
    end
    
    % Create ROIs for PWV and Calibrate Distance
    if handles.HRVorBP == 3 || handles.HRVorBP == 4
        % Roi size in pixels for 800x488 pixels of resolution        
        % Proximal Region of Interest
        handles.roi1 = drawrectangle('Label', 'Proximal Region', ....
            'LabelVisible', 'hover', 'Position', ....
            [handles.resolution(1)/2,handles.resolution(2)/2,handles.tam_roi,handles.tam_roi]);
        % Distal Region of Interest
        handles.roi2 = drawrectangle('Label', 'Distal Region', ....
            'LabelVisible', 'hover', 'Position', ....
            [handles.resolution(1)/2 + 100,handles.resolution(2)/2,handles.tam_roi,handles.tam_roi], ...
            'Color', 'r');
        
        
        posRoi1 = handles.roi1.Position;
        posRoi2 = handles.roi2.Position;
        
        centroRoi1 = [(posRoi1(1) + posRoi1(3) + posRoi1(1))/2, (posRoi1(2) + posRoi1(4) + posRoi1(2))/2];
        centroRoi2 = [(posRoi2(1) + posRoi2(3) + posRoi2(1))/2, (posRoi2(2) + posRoi2(4) + posRoi2(2))/2];
        
        % Auxliary line between the two ROIs
        handles.linha = line([centroRoi1(1) centroRoi2(1)] ....
            , [centroRoi1(2) centroRoi2(2)], 'Color', '#191970', 'LineWidth', 5);
        
        % Add listener, in two ROIs, for real time distance calculation
        addlistener(handles.roi1,'MovingROI',@(src,evnt)allevents(src,evnt,handles, hObject));
        addlistener(handles.roi2,'MovingROI',@(src,evnt)allevents(src,evnt,handles, hObject));
    else % Create ROIs for Pulse Oximetry
        if handles.HRVorBP == 5
            handles.tam_roi = 2*handles.tam_roi;
            
            % Region of Interest
            handles.roi1 = drawrectangle('Label', 'Region Of Interest', ....
                'LabelVisible', 'hover', 'Position', ....
                [handles.resolution(1)/2,handles.resolution(2)/2,handles.tam_roi,handles.tam_roi]);
        end
    end
guidata(hObject, handles);
% --------------------------------------------------------------------
% Others - End
% --------------------------------------------------------------------
