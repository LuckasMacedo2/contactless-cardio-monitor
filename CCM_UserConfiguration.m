function varargout = CCM_UserConfiguration(varargin)
% CCM_USERCONFIGURATION MATLAB code for CCM_UserConfiguration.fig
%      CCM_USERCONFIGURATION, by itself, creates a new CCM_USERCONFIGURATION or raises the existing
%      singleton*.
%
%      H = CCM_USERCONFIGURATION returns the handle to a new CCM_USERCONFIGURATION or the handle to
%      the existing singleton*.
%
%      CCM_USERCONFIGURATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CCM_USERCONFIGURATION.M with the given input arguments.
%
%      CCM_USERCONFIGURATION('Property','Value',...) creates a new CCM_USERCONFIGURATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CCM_UserConfiguration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CCM_UserConfiguration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CCM_UserConfiguration

% Last Modified by GUIDE v2.5 27-Jan-2021 14:32:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CCM_UserConfiguration_OpeningFcn, ...
    'gui_OutputFcn',  @CCM_UserConfiguration_OutputFcn, ...
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


function CCM_UserConfiguration_OpeningFcn(hObject, eventdata, handles, varargin)
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
    
    mainHandles = guidata(handles.CCMMain);
    id = mainHandles.userID;
    
    id = num2str(id);
    
    set(handles.textUserID, 'string', id);
    
    handles.userMass = '0';
    handles.userHeight = 1.7;
        
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
    disp('   CCM_UserConfiguration(''CCM_main'', x)');
    disp('-----------------------------------------------------');
else
    uiwait(hObject);
end


% UIWAIT makes CCM_UserConfiguration wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = CCM_UserConfiguration_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.CCMMain;% [];
delete(hObject);

% --- Executes during object creation, after setting all properties.
function editChangeMe_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(groot,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function userNameBox_Callback(hObject, eventdata, handles)
handles.userName = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function userNameBox_CreateFcn(hObject, eventdata, handles)
handles.userName = 'User1';
set(hObject,'string',handles.userName);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);



% --- Executes on selection change in popupUserGender.
function popupUserGender_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.userGender = str{val};
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupUserGender_CreateFcn(hObject, eventdata, handles)
str = {'Male' 'Female'};
set(hObject,'string',str);
handles.userGender = str{1};
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on selection change in popupUserAge.
function popupUserAge_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.userAge = str{val};
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupUserAge_CreateFcn(hObject, eventdata, handles)
str = {};
for ii = 0:100
    str = cat(2, str, num2str(ii));
end
set(hObject, 'string', str);
set(hObject, 'value', 26);
handles.userAge = str{26};
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on selection change in popupUserSkin.
function popupUserSkin_Callback(hObject, eventdata, handles)
val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.userSkin = str{val};
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupUserSkin_CreateFcn(hObject, eventdata, handles)
str = {'1' '2' '3' '4' '5' '6'};
set(hObject,'string',str);
handles.userSkin = str{1};
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on selection change in popupHeight.
function popupHeight_Callback(hObject, eventdata, handles)
str = get(hObject, 'string');
val = get(hObject, 'value');
handles.userHeight = str2double(str{val});

BMI = str2double(handles.userMass) / (handles.userHeight)^2;
handles.userBMI = BMI;
set(handles.userBMIBox, 'String', '');
set(handles.userBMIBox, 'String', num2str(BMI));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupHeight_CreateFcn(hObject, eventdata, handles)
str = createStrFreqLowUp(.3, 2.2, 0.01);
val = 141;
set(hObject, 'string', str);
set(hObject, 'value', val);
handles.userHeight = str2double(str{val});
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);



function userMassBox_Callback(hObject, eventdata, handles)
handles.userMass = get(hObject,'String');

BMI = str2double(handles.userMass) / (handles.userHeight)^2;
handles.userBMI = BMI;
set(handles.userBMIBox, 'String', '');
set(handles.userBMIBox, 'String', num2str(BMI));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function userMassBox_CreateFcn(hObject, eventdata, handles)
handles.userMass = '0';
set(hObject,'string',handles.userBMI);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

function userBMIBox_Callback(hObject, eventdata, handles)
% hObject    handle to userBMIBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userBMIBox as text
%        str2double(get(hObject,'String')) returns contents of userBMIBox as a double


% --- Executes during object creation, after setting all properties.
function userBMIBox_CreateFcn(hObject, eventdata, handles)
handles.userBMI = 0;
set(hObject, 'string', num2str(handles.userBMI));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);



% --- Executes on button press in buttonOK.
function buttonOK_Callback(hObject, eventdata, handles)
if(ishandle(handles.CCMMain))
    mainHandles = guidata(handles.CCMMain);
    mainHandles.userAge = handles.userAge;              % Age
    mainHandles.userGender = handles.userGender;        % Gender
    mainHandles.userName = handles.userName;            % Name
    mainHandles.userHeight = handles.userHeight;        % Height
    mainHandles.userMass = handles.userMass;            % Mass
    mainHandles.userSkin = handles.userSkin;            % Skin Color
    mainHandles.userBMI = handles.userBMI;              % Body Mass Index
%     mainHandles.userBirthday = handles.userBirthday;    % Birthday
    mainHandles.userBirthday = handles.userBirthdayBox.String; % Birthday
end
guidata(handles.CCMMain, mainHandles);
uiresume(handles.figure1);


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);

% --- Executes when user attempts to close figure.
function figure_CloseRequestFcn(hObject, eventdata, handles)
uiresume(hObject);


function userBirthdayBox_Callback(hObject, eventdata, handles)
handles.userBirthday = get(hObject,'String'); 
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function userBirthdayBox_CreateFcn(hObject, eventdata, handles)
handles.userBirthday = string(date);
set(hObject,'string',handles.userBirthday);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

% --- Executes on button press in buttonBirthday.
function buttonBirthday_Callback(hObject, eventdata, handles)
    uicalendar('Weekend', [1 0 0 0 0 0 1], ...  
    'SelectionType', 1, ...  
    'DestinationUI', handles.userBirthdayBox);
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
