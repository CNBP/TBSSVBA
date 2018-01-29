function varargout = ROI_Analysis_gui(varargin)
% ROI_ANALYSIS_GUI MATLAB code for ROI_Analysis_gui.fig
%      ROI_ANALYSIS_GUI, by itself, creates a new ROI_ANALYSIS_GUI or raises the existing
%      singleton*.
%
%      H = ROI_ANALYSIS_GUI returns the handle to a new ROI_ANALYSIS_GUI or the handle to
%      the existing singleton*.
%
%      ROI_ANALYSIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_ANALYSIS_GUI.M with the given input arguments.
%
%      ROI_ANALYSIS_GUI('Property','Value',...) creates a new ROI_ANALYSIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_Analysis_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_Analysis_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_Analysis_gui

% Last Modified by GUIDE v2.5 25-Jan-2016 17:36:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ROI_Analysis_gui_OpeningFcn, ...
    'gui_OutputFcn',  @ROI_Analysis_gui_OutputFcn, ...
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


% --- Executes just before ROI_Analysis_gui is made visible.
function ROI_Analysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_Analysis_gui (see VARARGIN)

% Choose default command line output for ROI_Analysis_gui
handles.output = hObject;

%Mes Variables
handles.study_folder=''; %Folder de l'etude en cours
handles.toprocess_list={}; %liste des sjts a traiter
handles.processed_list={}; %liste des sjts deja traites dasn l'etude
handles.params={'zfill' ; 'N4C' ; 'ECC'}; %study parameters

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROI_Analysis_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_Analysis_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_adds.
function pushbutton_adds_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_adds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_data=uigetfile_n_dir(); %mathe_xchange function to allow the selection of multiple folders.

for i=1:length(new_data)
    copyfile([cell2mat(new_data(i)) '*'],[handles.study_folder filesep 'Brains']);
end

data=dir(fullfile(handles.study_folder,'Brains','*.fid'));
set(handles.listbox_data,'string',{data.name});

for i=1:length(data)
    
    idx=length(handles.toprocess_list)+1;
    handles.toprocess_list(idx)={[handles.study_folder filesep 'Brains' filesep data(i).name]};
end

if ~isempty(handles.toprocess_list)
    set(handles.pushbutton_run,'visible','on');
end

guidata(hObject, handles);


% --- Executes on button press in pushbutton_opens.
function pushbutton_opens_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_opens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.study_folder=uigetdir();
cd(handles.study_folder)

[~,filename,~]=fileparts(handles.study_folder);
data=dir(fullfile(handles.study_folder,'Brains','*.fid'));

for i=1:length(data)
    idx=length(handles.processed_list)+1;
    handles.processed_list(idx)={data(i).name};
end
%Set rest of GUI
set(handles.listbox_data,'string',{data.name});
set(handles.text_study,'string',filename);

%Set visible
set(handles.text_study,'visible','on');
set(handles.pushbutton_adds,'visible','on');
set(handles.listbox_data,'visible','on');
set(handles.uipanel_studyparam,'visible','on');

guidata(hObject, handles);

% --- Executes on button press in pushbutton_news.
function pushbutton_news_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_news (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.study_folder=uigetdir();
cd(handles.study_folder)
mkdir('Brains')

[~,filename,~]=fileparts(handles.study_folder);


%Make rest of GUI visible
set(handles.text_study,'string',filename);
set(handles.text_study,'visible','on');
set(handles.pushbutton_adds,'visible','on');
set(handles.listbox_data,'visible','on');
set(handles.uipanel_studyparam,'visible','on');
set(handles.pushbutton_setparams,'visible','on');

guidata(hObject, handles);


% --- Executes on selection change in listbox_data.
function listbox_data_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_data


% --- Executes during object creation, after setting all properties.
function listbox_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_run.
function pushbutton_run_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(cell2mat(handles.params_val(2)),'y')
    N4C=1;
else
    N4C=0;
end
if isequal(cell2mat(handles.params_val(3)),'y')
    ECC=1;
else
    ECC=0;
end
run_ROI(handles.toprocess_list,str2num(cell2mat(handles.params_val(1))),N4C,ECC);


% --- Executes on button press in pushbutton_setparams.
function pushbutton_setparams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.params_val = inputdlg({'zfill?','N4 correction [y/n]','Eddy-current correction? [y/n]'},...
    'Study Parameters', [1 10; 1 20; 1 20],{'128' ; 'n' ; 'n'});

fileID = fopen('par.txt','w');
for i=1:length(handles.params)
    fprintf(fileID,'%s : %s\n',cell2mat(handles.params(i)),cell2mat(handles.params_val(i)));
end
fclose(fileID);

set(handles.text_zfillVAL,'string',cell2mat(handles.params_val(1))); %zfill
set(handles.text_N4VAL,'string',cell2mat(handles.params_val(2))); %N4C
set(handles.text_ECCVAL,'string',cell2mat(handles.params_val(3))); %ECC

set(hObject,'visible','off')

guidata(hObject, handles);

