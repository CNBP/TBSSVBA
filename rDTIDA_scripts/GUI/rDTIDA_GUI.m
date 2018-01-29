function varargout = rDTIDA_GUI(varargin)
% RDTIDA_GUI MATLAB code for rDTIDA_GUI.fig
%      RDTIDA_GUI, by itself, creates a new RDTIDA_GUI or raises the existing
%      singleton*.
%
%      H = RDTIDA_GUI returns the handle to a new RDTIDA_GUI or the handle to
%      the existing singleton*.
%
%      RDTIDA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RDTIDA_GUI.M with the given input arguments.
%
%      RDTIDA_GUI('Property','Value',...) creates a new RDTIDA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rDTIDA_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rDTIDA_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rDTIDA_GUI

% Last Modified by GUIDE v2.5 15-Aug-2015 11:35:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @rDTIDA_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @rDTIDA_GUI_OutputFcn, ...
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

%%         GENERAL  FUNCTIONS
% --- Executes just before rDTIDA_GUI is made visible.
function rDTIDA_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rDTIDA_GUI (see VARARGIN)

% Choose default command line output for rDTIDA_GUI
handles.output = hObject;

% My Variables

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rDTIDA_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rDTIDA_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in panel_phase_select.
function panel_phase_select_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panel_phase_select
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if get(handles.radiobutton_dataPreprocess,'Value')==1
    set(handles.panel_dataPreprocess,'Visible','on');
    set(handles.panel_scmaps,'Visible','off');
    set(handles.panel_segment,'Visible','off');
    set(handles.panel_morph,'Visible','off');
elseif get(handles.radiobutton_scmaps,'Value')==1
    set(handles.panel_dataPreprocess,'Visible','off');
    set(handles.panel_scmaps,'Visible','on');
    set(handles.panel_segment,'Visible','off');
    set(handles.panel_morph,'Visible','off');
elseif get(handles.radiobutton_segment,'Value')==1
    set(handles.panel_dataPreprocess,'Visible','off');
    set(handles.panel_scmaps,'Visible','off');
    set(handles.panel_segment,'Visible','on');
    set(handles.panel_morph,'Visible','off');
elseif get(handles.radiobutton_morph,'Value')==1
    set(handles.panel_dataPreprocess,'Visible','off');
    set(handles.panel_scmaps,'Visible','off');
    set(handles.panel_segment,'Visible','off');
    set(handles.panel_morph,'Visible','on');
end

%%         PANEL DATA PROCESSING
% --- Executes on button press in pushbutton_fiddir.
function pushbutton_fiddir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fiddir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fiddir=uigetdir('','Select directory with fid folders');
set(handles.text_fiddir,'String',fiddir)


% --- Executes on button press in checkbox_N4.
function checkbox_N4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_N4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_N4

% --- Executes on button press in checkbox_ec.
function checkbox_ec_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ec


% --- Executes on button press in checkbox_sc.
function checkbox_sc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sc


% --- Executes on selection change in popupmenu_method.
function popupmenu_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_method


% --- Executes during object creation, after setting all properties.
function popupmenu_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_zfill_Callback(hObject, eventdata, handles)
% hObject    handle to edit_zfill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_zfill as text
%        str2double(get(hObject,'String')) returns contents of edit_zfill as a double


% --- Executes during object creation, after setting all properties.
function edit_zfill_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_zfill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_datapreprocess.
function pushbutton_datapreprocess_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_datapreprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


zfill=get(handles.edit_zfill,'String');
%Change string to mat
tmp=strsplit(zfill,',');
tmp{1}=str2num(tmp{1});
tmp{2}=str2num(tmp{2});
zfill=cell2mat(tmp);

fiddir=get(handles.text_fiddir,'String');

contents=get(handles.popupmenu_method,'String');
method = contents{get(handles.popupmenu_method,'Value')};

if strcmp(method,'dtiLeastSquaresW')
    method=1;
elseif strcmp(method,'dtiLeastSquaresW2')
    method=2;
elseif strcmp(method,'dtiLeastSquares2')
    method=0;
end

N4_bool=get(handles.checkbox_N4,'Value');
EC_bool=get(handles.checkbox_ec,'Value');
scmaps_bool=get(handles.checkbox_sc,'Value');


launch_data_preprocessing(fiddir,zfill,method,N4_bool,EC_bool,scmaps_bool);
%%     PANEL SCALAR MAPS PREPROCESSING
% --- Executes on button press in pushbutton_scmaps.
function pushbutton_scmaps_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scmaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scmapsdir=uigetdir('','Select directory with fid folders');
set(handles.text_scmapsdir,'String',scmapsdir)

% --- Executes on button press in pushbutton_maskdir.
function pushbutton_maskdir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_maskdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maskdir=uigetdir('','Select directory with fid folders');
set(handles.text_maskdir,'String',maskdir)

% --- Executes on button press in checkbox_mask.
function checkbox_mask_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mask
if get(handles.checkbox_mask,'Value')==1
    set(handles.pushbutton_maskdir,'Visible','on');
    set(handles.text_maskdir,'Visible','on');
else
    set(handles.pushbutton_maskdir,'Visible','off');
    set(handles.text_maskdir,'Visible','off');
end


% --- Executes on button press in checkbox_iso.
function checkbox_iso_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_iso (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox_iso,'Value')==1
    set(handles.edit_iso,'Visible','on');
else
    set(handles.edit_iso,'Visible','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_iso


% --- Executes on button press in checkbox_rescale.
function checkbox_rescale_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox_rescale,'Value')==1
    set(handles.edit_rescale,'Visible','on');
else
    set(handles.edit_rescale,'Visible','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_rescale



function edit_iso_Callback(hObject, eventdata, handles)
% hObject    handle to edit_iso (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_iso as text
%        str2double(get(hObject,'String')) returns contents of edit_iso as a double


% --- Executes during object creation, after setting all properties.
function edit_iso_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_iso (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rescale_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rescale as text
%        str2double(get(hObject,'String')) returns contents of edit_rescale as a double


% --- Executes during object creation, after setting all properties.
function edit_rescale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_process_scmaps.
function pushbutton_process_scmaps_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_process_scmaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%            PANEL PROCESSING - TEMPLATE CONSTRUCTION & SEGMENTATION
% --- Executes on button press in pushbutton_datadir.
function pushbutton_datadir_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_datadir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datadir=uigetdir('','Select directory with fid folders');
set(handles.text_data,'String',datadir)

% --- Executes on button press in pushbutton_scripts.
function pushbutton_scripts_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scripts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scriptsdir=uigetdir('','Select directory with fid folders');
set(handles.text_scriptsdir,'String',scriptsdir)

% --- Executes on selection change in popupmenu_run.
function popupmenu_run_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents=get(hObject,'String');
run = contents{get(hObject,'Value')};

if strcmp(run,'Run Locally')
    set(handles.text_host,'Visible','off');
    set(handles.edit_host,'Visible','off');
    set(handles.text_usr,'Visible','off');
    set(handles.edit_usr,'Visible','off');
    set(handles.text_pwd,'Visible','off');
    set(handles.edit_pwd,'Visible','off');
else
    set(handles.text_host,'Visible','on');
    set(handles.edit_host,'Visible','on');
    set(handles.text_usr,'Visible','on');
    set(handles.edit_usr,'Visible','on');
    set(handles.text_pwd,'Visible','on');
    set(handles.edit_pwd,'Visible','on');
end
% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_run contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_run


% --- Executes during object creation, after setting all properties.
function popupmenu_run_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_host_Callback(hObject, eventdata, handles)
% hObject    handle to edit_host (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_host as text
%        str2double(get(hObject,'String')) returns contents of edit_host as a double


% --- Executes during object creation, after setting all properties.
function edit_host_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_host (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_usr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_usr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_usr as text
%        str2double(get(hObject,'String')) returns contents of edit_usr as a double


% --- Executes during object creation, after setting all properties.
function edit_usr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_usr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pwd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pwd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pwd as text
%        str2double(get(hObject,'String')) returns contents of edit_pwd as a double


% --- Executes during object creation, after setting all properties.
function edit_pwd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pwd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_preReg.
function checkbox_preReg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_preReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_preReg


% --- Executes on button press in pushbutton_template.
function pushbutton_template_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_template (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
