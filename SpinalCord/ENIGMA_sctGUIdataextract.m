function varargout = ENIGMA_sctGUIdataextract(varargin)
% ENIGMA_SCTGUIDATAEXTRACT MATLAB code for ENIGMA_sctGUIdataextract.fig
%      ENIGMA_SCTGUIDATAEXTRACT, by itself, creates a new ENIGMA_SCTGUIDATAEXTRACT or raises the existing
%      singleton*.
%
%      H = ENIGMA_SCTGUIDATAEXTRACT returns the handle to a new ENIGMA_SCTGUIDATAEXTRACT or the handle to
%      the existing singleton*.
%
%      ENIGMA_SCTGUIDATAEXTRACT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENIGMA_SCTGUIDATAEXTRACT.M with the given input arguments.
%
%      ENIGMA_SCTGUIDATAEXTRACT('Property','Value',...) creates a new ENIGMA_SCTGUIDATAEXTRACT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ENIGMA_sctGUIdataextract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ENIGMA_sctGUIdataextract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ENIGMA_sctGUIdataextract

% Last Modified by GUIDE v2.5 04-Jul-2019 12:18:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ENIGMA_sctGUIdataextract_OpeningFcn, ...
                   'gui_OutputFcn',  @ENIGMA_sctGUIdataextract_OutputFcn, ...
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


% --- Executes just before ENIGMA_sctGUIdataextract is made visible.
function ENIGMA_sctGUIdataextract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ENIGMA_sctGUIdataextract (see VARARGIN)

% Choose default command line output for ENIGMA_sctGUIdataextract
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ENIGMA_sctGUIdataextract wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ENIGMA_sctGUIdataextract_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in subj2.
function subj2_Callback(hObject, eventdata, handles)
global output file tname

file = uipickfiles('Output','cell','Prompt','Add all volunteers folders','REFilter','');
file = sort(file);
[fold,~,~] = fileparts(file{1});

set(handles.text4, 'String',fold);

if ~isempty(output) && ~isempty(file) && ~isempty(tname)
    
    set(handles.run2,'Enable','on');
    
else
    
    set(handles.run2,'Enable','off');
    
end


% --- Executes on button press in outp.
function outp_Callback(hObject, eventdata, handles)
global output file tname

output = uigetdir();
set(handles.text3, 'String',output);


if ~isempty(output) && ~isempty(file) && ~isempty(tname)
    
    set(handles.run2,'Enable','on');
    
else
    
    set(handles.run2,'Enable','off');
    
end

% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit1_Callback(hObject, eventdata, handles)
global output file tname

tname = get(handles.edit1,'String');

if ~isempty(output) && ~isempty(file) && ~isempty(tname)
    
    set(handles.run2,'Enable','on');
    
else
    
    set(handles.run2,'Enable','off');
    
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run2.
function run2_Callback(hObject, eventdata, handles)
global output file tname

for i=1:size(file,2)
    
    cd(file{i});
    
    [filepath,name,~] = fileparts(file{i});
    tabCSAsubj = csvimport([name '_CSA.csv']);
    
    
    if i==1
        tabC2{1,1} = 'ID';
        tabC3{1,1} = 'ID';
        tabC2(1,2:size(tabCSAsubj,2)+1) = tabCSAsubj(1,:);
        tabC3(1,2:size(tabCSAsubj,2)+1) = tabCSAsubj(1,:);
                
    end
    
    if tabCSAsubj{2,5} == 3
        
        tabC3{i+1,1} = name;
        tabC3(i+1,2:size(tabCSAsubj,2)+1) = (tabCSAsubj(2,:));
        
        tabC2{i+1,1} = name;
        tabC2(i+1,2:size(tabCSAsubj,2)+1) = (tabCSAsubj(3,:));
        
        
    else
        
        tabC3{i+1,1} = name;
        tabC3(i+1,2:size(tabCSAsubj,2)+1) = (tabCSAsubj(3,:));
        
        tabC2{i+1,1} = name;
        tabC2(i+1,2:size(tabCSAsubj,2)+1) = (tabCSAsubj(2,:));
        
    end
    
    clear tabCSAsubj name filepath
    
end

tabC2 = cell2table(tabC2);
tabC3 = cell2table(tabC3);
writetable(tabC2,[output filesep tname '_C2.xlsx'],'WriteVariableNames',0);
writetable(tabC3,[output filesep tname '_C3.xlsx'],'WriteVariableNames',0);
disp(sprintf('\nThe processing is done.\n\n'));


% --- Executes on button press in pSCT.
function pSCT_Callback(hObject, eventdata, handles)
global pathSCT file

pathSCT = uigetdir();
set(handles.text1, 'String',pathSCT);


if ~isempty(pathSCT) && ~isempty(file)
    
    set(handles.run1,'Enable','on');
    
else
    
    set(handles.run1,'Enable','off');
    
end



% --- Executes on button press in subj1.
function subj1_Callback(hObject, eventdata, handles)
global pathSCT file

file = uipickfiles('Output','cell','Prompt','Add all volunteers folders','REFilter','');
file = sort(file);
[fold,~,~] = fileparts(file{1});

set(handles.text2, 'String',fold);

if ~isempty(pathSCT) && ~isempty(file)
    
    set(handles.run1,'Enable','on');
    
else
    
    set(handles.run1,'Enable','off');
    
end


% --- Executes on button press in run1.
function run1_Callback(hObject, eventdata, handles)
global pathSCT file

path1 = getenv('PATH');
path1 = [path1 ':' pathSCT '/bin'];
setenv('PATH', path1);

%Waitbar
f = waitbar(0,'Computing CSA', 'Name', 'ENIGMA-Automatic Spinal Cord Data Extraction',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0);

for i=1:size(file,2)
    
    cd(file{i});
    
    [filepath,name,~] = fileparts(file{i});
    
    command1 = ['sct_process_segmentation -i ' name...
        '_t1_seg.nii.gz -vert 2:3 -perlevel 1 -vertfile ' name '_PAM50_levels.nii.gz -o ' name '_CSA.csv'];
    
    [status1, commandOut1] = system(command1);
    
    if status1==0
        fprintf('%s\n',commandOut1);
        
        %Report of all processing for each subject
        rp = [name '_compCSA.txt'];
        fileID = fopen(rp,'w');
        fprintf(fileID,'%s\n', commandOut1);
        fclose(fileID);
        
    else
        
        if exist('fail','var')==0
            fail = fopen(['fail_compCSA.txt'],'w');
            fprintf(fail, 'List of subjects that failed to running\n');
            fprintf(fail,'%s\n', name);
            
        else
            fprintf(fail,'%s\n', name);
            
        end
        
    end
    
    %Update waitbar and message
    waitbar(i/size(file,2),f,sprintf('%d of %d subjects',i,size(file,2)));
    
    cd (filepath);
    
    clear status1 command1 commandOut1 name filepath
    
       
end

delete(f);

disp(sprintf('\nThe processing is done.\n\n'));
