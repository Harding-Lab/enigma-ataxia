function varargout = ENIGMA_sctGUI(varargin)
% ENIGMA_SCTGUI MATLAB code for ENIGMA_sctGUI.fig
%      ENIGMA_SCTGUI, by itself, creates a new ENIGMA_SCTGUI or raises the existing
%      singleton*.
%
%      H = ENIGMA_SCTGUI returns the handle to a new ENIGMA_SCTGUI or the handle to
%      the existing singleton*.
%
%      ENIGMA_SCTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENIGMA_SCTGUI.M with the given input arguments.
%
%      ENIGMA_SCTGUI('Property','Value',...) creates a new ENIGMA_SCTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ENIGMA_sctGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ENIGMA_sctGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ENIGMA_sctGUI

% Last Modified by GUIDE v2.5 15-Jul-2020 13:40:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ENIGMA_sctGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ENIGMA_sctGUI_OutputFcn, ...
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


% --- Executes just before ENIGMA_sctGUI is made visible.
function ENIGMA_sctGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ENIGMA_sctGUI (see VARARGIN)

% Choose default command line output for ENIGMA_sctGUI
handles.output = hObject;
axes(handles.axes1)
imgLOGO = imread('enigma_logo.png');
imshow(imgLOGO, []);
axis('image','off');


if isunix==1
    LD_LIBRARY_PATH="/usr/local/lib:/usr/lib32";
    setenv LD_LIBRARY_PATH;
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ENIGMA_sctGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ENIGMA_sctGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global pathSCT

f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)

path1 = getenv('PATH');
path1 = [path1 ':' pathSCT '/bin'];
setenv('PATH', path1);

try
    
    file = uipickfiles('Output','cell','Prompt','Add all volunteers folders','REFilter','');
    file = sort(file);
    
    f = waitbar(0,'Spinal Cord Segmentation', 'Name', 'ENIGMA-Automatic Spinal Cord Segmentation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',1);
    
    for i=1:size(file,2)
        
        cd(file{i});
        
        [filepath,name,~] = fileparts(file{i});
        
        %Spinal Cord Segmentation
        command1 = ['sct_deepseg_sc -i ' name '_t1.nii.gz -c t1 -qc ' name '_scQC'];
        
        [status1, commandOut1] = system(command1);
        
        if status1==0
            fprintf('%s\n',commandOut1);
            
            %To create QC pictures, axial and sagittal
            gunzip([name '_t1.nii.gz']);
            gunzip([name '_t1_seg.nii.gz']);
            
            SliceView_uf2c([name '_t1.nii'],[name '_t1_seg.nii'],0.2,10,'Axial','red',[-130:2:-50],'QC of Spinal Cord Segmentation',[name '_SCaxial.png'],file{i});
            SliceView_uf2c([name '_t1.nii'],[name '_t1_seg.nii'],0.2,10,'Sagittal','red',[-20:2:20],'QC of Spinal Cord Segmentation',[name '_SCsagittal.png'],file{i});
            
            delete([name '_t1.nii']);
            delete([name '_t1_seg.nii']);
            
            fprintf('To view results, type:\n\nfslview %s -l Greyscale %s_seg.nii.gz -l Red -t 0.7 &\n', file{i},name(1:end-4));
            
            %Report of all processing for each subject
            rp = [name '_scSEG.txt'];
            fileID = fopen(rp,'w');
            fprintf(fileID,'%s\n', commandOut1);
            fclose(fileID);
            
        else
            
            if exist('fail','var')==0
                fail = fopen(['fail_SC_seg.txt'],'w');
                fprintf(fail, 'List of subjects that failed to running\n');
                fprintf(fail,'%s\n', name);
                
            else
                fprintf(fail,'%s\n', name);
                
            end
            
        end
        
        %Update waitbar and message
        waitbar(i/size(file,2),f,sprintf('%d of %d subjects',i,size(file,2)));
        
        cd (filepath);
        
        clear filepath name status1 commandOut1 rp
        
    end
    
    if exist('fail','var')==1
        fclose(fail);
    end
    
    delete(f);
    
    disp(sprintf('\nThe processing is done.\n\nPlease, check the segmentations and, if necessary, perform manual correction.\n'));
    
catch ME
    if (strcmp(ME.identifier,'MATLAB:catenate:dimensionMismatch'))
        msg = ['Please, check the filenames and folder names.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
    end
    
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f);
    rethrow(ME)
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)

try
    [file, fpath] = uigetfile('*_t1.nii.gz','Enter with SC images','MultiSelect','on');
    file = cellstr(file);
    file = sort(file);
    
    cd(fpath); cd('../');
    mkdir('spine');
    %Waitbar
    f = waitbar(0,'Preparing folders', 'Name', 'ENIGMA-Automatic Spinal Cord Segmentation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    
    for i=1:size(file,2)
        
        %Creating and moving files
        mkdir(['spine' filesep file{i}(1:end-10)]);
        copyfile(['input' filesep file{i}],['spine' filesep file{i}(1:end-10) filesep file{i}]);
        
        %Update waitbar and message
        waitbar(i/size(file,2),f,sprintf('%d of %d subjects',i,size(file,2)));
        
    end
    
    delete(f);
    
    disp(sprintf('\nThe processing is done.\n'));
    
catch ME
    if (strcmp(ME.identifier,'MATLAB:catenate:dimensionMismatch'))
        msg = ['Not valid files. Please, enter witth all files converted in nii.gz ',...
            'and with the correct filename format.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
    end
    
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f);
    rethrow(ME)
    
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
global pathSCT

f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)

try
    path1 = getenv('PATH');
    path1 = [path1 ':' pathSCT '/bin'];
    setenv('PATH', path1);
    
    ta = ['template2anat.nii.gz'];
    at = ['anat2template.nii.gz'];
    w1 = ['warp_template2anat.nii.gz'];
    w2 = ['warp_anat2template.nii.gz'];
    
    file = uipickfiles('Output','cell','Prompt','Add all volunteers folders','REFilter','');
    file = sort(file);
    
    f = waitbar(0,'Spinal Cord Processing', 'Name', 'ENIGMA-Automatic Spinal Cord Segmentation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    
    for i=1:size(file,2)
        
        cd(file{i})
        
        [filepath,name,~] = fileparts(file{i});
        
        %Calculating the warping fields to register the template in the subject's image
        
        command4 = ['sct_register_to_template -i ' name '_t1.nii.gz -s ' name '_t1_seg.nii.gz -ldisc ' name...
            '_t1_labels_disc.nii.gz -param step=1,type=seg,algo=centermassrot:step=2,type=seg,algo=bsplinesyn,slicewise=1 -c t1 -qc ' name '_quantQC'];
        
        [status4, commandOut4] = system(command4);
        
        if status4==0
            fprintf('%s\n',commandOut4);
        end
        
        if status4==0
            
            %Changing name of warping field files and registered images
            tac = [name '_template2anat.nii.gz'];
            atc = [name '_anat2template.nii.gz'];
            w1c = ['warp_' name '_template2anat.nii.gz'];
            w2c = ['warp_' name '_anat2template.nii.gz'];
            
            movefile(ta,tac);
            movefile(at,atc);
            movefile(w1,w1c);
            movefile(w2,w2c);
            
            fprintf('To view results, type:\n\nfslview %s warp_%s_template2anat.nii.gz &\n', file{i},name(1:end-4));
            
            %Warp template to the subject's image
            command5 = ['sct_warp_template -d ' name '_t1.nii.gz -w ' w1c ' -ofolder ' name '_label -qc ' name '_quantQC'];
            [status5, commandOut5] = system(command5);
            
            if status5==0
                fprintf('%s\n',commandOut5);
                
            end
            
            fprintf('To view results, type:\n\nfslview %s -l Greyscale -t 1 %s_label/template/PAM50_t2.nii.gz -l Grayscale -b 0,4000 -t 1 %s_label/template/PAM50_gm.nii.gz -l Red-Yellow -b 0.4,1 -t 0.5 %s_label/template/PAM50_wm.nii.gz -l Blue-Lightblue -b 0.4,1 -t 0.5 &\n', file{i},name(1:end-4),name(1:end-4),name(1:end-4));
            
            rp = [name '_scQUANTsemi.txt'];
            
            %Create report
            %Report of all processing for each subject
            fileID = fopen(rp,'w');
            
            if exist('commandOut4','var')==1
                fprintf(fileID,'%s\n', commandOut4);
            end
            
            fprintf(fileID,'%s\n', commandOut5);
            fclose(fileID);
            
            gm = [name '_label' filesep 'template' filesep 'PAM50_gm.nii.gz'];
            wm = [name '_label' filesep 'template' filesep 'PAM50_wm.nii.gz'];
            lev = [name '_label' filesep 'template' filesep 'PAM50_levels.nii.gz'];
            
            gmc = [name '_PAM50_gm.nii.gz'];
            wmc = [name '_PAM50_wm.nii.gz'];
            levc = [name '_PAM50_levels.nii.gz'];
            
            movefile(gm,gmc);
            movefile(wm,wmc);
            movefile(lev,levc);
            
            gunzip([name '_t1.nii.gz']);
            gunzip([name '_template2anat.nii.gz']);
            
            SliceView_uf2c([name '_t1.nii'],[name '_template2anat.nii'],300,1000,'Sagittal','hsv',[-20:2:20],'QC of Spinal Cord Segmentation',[name '_regisQC.png'],file{i});
            
            delete([name '_t1.nii']);
            delete([name '_template2anat.nii']);
            
            
        else
            %report of all subjects that did not run
            if exist('fail','var')==0
                fail = fopen([filepath filesep 'failSUBJECTS.txt'],'w');
                fprintf(fail, 'List of subjects that failed to running\n');
                fprintf(fail,'%s\n', name);
                nf = 1;
                
            else
                fprintf(fail,'%s\n', name);
                nf = nf +1;
            end
            
        end
        
        
        %Update waitbar and message
        waitbar(i/size(file,2),f,sprintf('%d of %d subjects',i,size(file,2)));
        
        cd(filepath);
        
        clear command2 command3 command4 command5 commandOut2 commandOut3 commandOut4...
            commandOut5 filepath name status2 status3 status4 status5 w1c w2c rp gm wm gmc wmc tac atc
        
        
    end
    
    if exist('fail','var')==1
        fclose(fail);
    end
    
    delete(f);
    if exist('nf','var')==1
        disp(sprintf('\nThe processing is done.\n\n%d subjects were successfully processed and %d failed.\n',...
            (size(file,2)-nf),nf));
    else
        nf = 0;
        
        disp(sprintf('\nThe processing is done.\n\n%d subjects were successfully processed and %d failed.\n',...
            (size(file,2)-nf),nf));
    end
catch ME
        
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f);
    rethrow(ME)
end



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)

f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)

try
    
    file = uipickfiles('Output','cell','Prompt','Add all volunteers folders','REFilter','');
    file = sort(file);
    
    %Waitbar
    f = waitbar(0,'Spinal Cord Segmentation', 'Name', 'ENIGMA-Automatic Spinal Cord Segmentation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    
    for i=1:size(file,2)
        
        cd(file{i})
        
        [filepath,name,~] = fileparts(file{i});
        
        %Packing files for each subject
        zip(['pack_' name],{'*_anat2template.nii.gz','*_template2anat.nii.gz',...
            '*_T1_seg.nii.gz','*PAM50_gm.nii.gz','*PAM50_wm.nii.gz',...
            '*PAM50_levels.nii.gz','*.png','*.txt', [name '_label'], [name '_scQC'],...
            [name '_quantQC'],'*_seg_labeled_discs.nii.gz','*_seg_labeled.nii.gz',...
            '*_labels_vert.nii.gz',});
        
        %Update waitbar and message
        waitbar(i/size(file,2),f,sprintf('%d of %d subjects',i,size(file,2)));
        
        cd(filepath);
        
        clear name filepath
        
    end
    
    delete(f);
    
    mkdir('ENIGMA_files');
    
    for i=1:size(file,2)
        
        [filepath,name,~] = fileparts(file{i});
        
        copyfile([name filesep 'pack_' name '.zip'],'ENIGMA_files');
        
        clear name filepath
        
    end
    
    [filepath,~,~] = fileparts(file{1});
    
    %Creating the final file to be send
    if exist('failSUBJECTS.txt','file')==2
        copyfile('failSUBJECTS.txt','ENIGMA_files');
        
        cd ('ENIGMA_files');
        
        zip('filesPACKED',{'*.zip','failSUBJECTS.txt'});
        
    else
        cd ('ENIGMA_files');
        zip('filesPACKED',{'*.zip'});
        
    end
    
    cd(filepath);
    
    copyfile(['ENIGMA_files' filesep 'filesPACKED.zip'],filepath);
    
    rmdir('ENIGMA_files','s');
    
    disp(sprintf('\nThe processing is done.\n\nPlease, contact Dr. Thiago Rezende to send the file filesPACKED.zip.\n'));
catch ME
    rethrow(ME)
    try
        f = findall(0,'type','figure','tag','TMWWaitbar');
        delete(f);
    end
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
global pathSCT

f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)

try
    pathSCT = uigetdir();
    set(handles.text2, 'String',pathSCT);
    
    if get(handles.pushbutton6,'Value')==1
        
        set(handles.pushbutton1,'Enable','on');
        set(handles.pushbutton2,'Enable','on');
        set(handles.pushbutton3,'Enable','on');
        set(handles.pushbutton4,'Enable','on');
        set(handles.pushbutton7,'Enable','on');
        
    else
        
        set(handles.pushbutton1,'Enable','off');
        set(handles.pushbutton2,'Enable','off');
        set(handles.pushbutton3,'Enable','off');
        set(handles.pushbutton4,'Enable','off');
        set(handles.pushbutton7,'Enable','off');
        
    end
    
catch ME
    if (strcmp(ME.identifier,'MATLAB:catenate:dimensionMismatch'))
        msg = ['Not valid SCT path. Please, enter a valid path.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
    end
    
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f)
    rethrow(ME)
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
global pathSCT

f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)

try
    path1 = getenv('PATH');
    path1 = [path1 ':' pathSCT '/bin'];
    setenv('PATH', path1);
    
    file = uipickfiles('Output','cell','Prompt','Add all volunteers folders','REFilter','');
    file = sort(file);
    
    f = waitbar(0,'Spinal Cord Processing', 'Name', 'ENIGMA-Automatic Spinal Cord Segmentation',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(f,'canceling',0);
    
    for i=1:size(file,2)
        
        cd(file{i})
        
        [filepath,name,~] = fileparts(file{i});
        
        command2 = ['sct_label_utils -i ' name '_t1.nii.gz -create-viewer 3,4 -o ' name...
            '_t1_labels_disc.nii.gz -msg "Place label at the posterior tip of each inter-vertebral disc. E.g. label 3: C2/C3."'];
        
        [status2, commandOut2] = system(command2);
        
        if status2==0
            fprintf('%s\n',commandOut2);
            
            gunzip([name '_t1.nii.gz']);
            gunzip([name '_t1_labels_disc.nii.gz']);
            
            rawNII = [name '_t1.nii'];
            discNII = [name '_t1_labels_disc.nii'];
            
            rawNII = niftiread(rawNII);
            discNII = niftiread(discNII);
            
            %find non-zero indices in disc imaging
            ind = find(discNII);
            [i1, i2, i3] = ind2sub(size(discNII), ind);
            
            if size(i1,1)==2
                
                %saving disc coordinations
                di = [name '_discCOORD.txt'];
                diTXT = fopen(di,'w');
                fprintf(diTXT,'Coordinates of disc labels are:\nX:[%d,%d]\nY:[%d,%d]\nZ:[%d,%d]\n',i3(:),i1(:),i2(:));
                fclose(diTXT);
                
                if i1(1) == i1(2)
                    rawOVL1 = squeeze(rawNII(i1(1),:,:));
                    discOVL1 = squeeze(discNII(i1(1),:,:));
                    
                    rawOVL2 = squeeze(rawNII(:,:,i3(1)));
                    discOVL2 = squeeze(discNII(:,:,i3(1)));
                    
                    rawOVL3 = squeeze(rawNII(:,:,i3(1)));
                    discOVL3 = squeeze(discNII(:,:,i3(1)));
                    
                elseif i2(1) == i2(2)
                    rawOVL1 = squeeze(rawNII(:,i2(1),:));
                    discOVL1 = squeeze(discNII(:,i2(1),:));
                    
                    rawOVL2 = squeeze(rawNII(i1(1),:,:));
                    discOVL2 = squeeze(discNII(i1(1),:,:));
                    
                    rawOVL3 = squeeze(rawNII(:,:,i3(1)));
                    discOVL3 = squeeze(discNII(:,:,i3(1)));
                    
                else
                    rawOVL1 = squeeze(rawNII(:,:,i3(1)));
                    discOVL1 = squeeze(discNII(:,:,i3(1)));
                    
                    rawOVL2 = squeeze(rawNII(:,i2(1),:));
                    discOVL2 = squeeze(discNII(:,i2(1),:));
                    
                    rawOVL3 = squeeze(rawNII(:,i2(2),:));
                    discOVL3 = squeeze(discNII(:,i2(2),:));
                    
                end
                
                rawOVL1 = imrotate(rawOVL1,90);
                discOVL1 = imrotate(discOVL1,90);
                h1 = figure;
                h1 = imshowpair(rawOVL1,discOVL1);
                saveas(h1,[name '_SC_Sagittal_labeling.png'],'png');
                close
                
                rawOVL2 = imrotate(rawOVL2,90);
                discOVL2 = imrotate(discOVL2,90);
                h2 = figure;
                h2 = imshowpair(rawOVL2,discOVL2);
                saveas(h2,[name '_SC_Axial_label3.png'],'png');
                close
                
                rawOVL3 = imrotate(rawOVL3,90);
                discOVL3 = imrotate(discOVL3,90);
                h3 = figure;
                h3 = imshowpair(rawOVL3,discOVL3);
                saveas(h3,[name '_SC_Axial_label4.png'],'png');
                close
                
            else
                di = [name '_discCOORD.txt'];
                diTXT = fopen(di,'w');
                fprintf(diTXT,'Coordinates of disc labels are:\nX:[%d]\nY:[%d]\nZ:[%d]\n',i3(:),i1(:),i2(:));
                fclose(diTXT);
                
                rawOVL1 = squeeze(rawNII(i1(1),:,:));
                discOVL1 = squeeze(discNII(i1(1),:,:));
                h1 = figure;
                h1 = imshowpair(rawOVL1,discOVL1);
                saveas(h1,[name '_SC_View1_labeling.png'],'png');
                close
                
                rawOVL2 = squeeze(rawNII(:,:,i3(1)));
                discOVL2 = squeeze(discNII(:,:,i3(1)));
                h2 = figure;
                h2 = imshowpair(rawOVL2,discOVL2);
                saveas(h2,[name '_SC_View2_labeling.png'],'png');
                close
                
                rawOVL3 = squeeze(rawNII(:,i2(1),:));
                discOVL3 = squeeze(discNII(:,i2(1),:));
                h3 = figure;
                h3 = imshowpair(rawOVL3,discOVL3);
                saveas(h3,[name '_SC_View3_labeling.png'],'png');
                close
            end
            
            delete([name '_t1.nii']);
            delete([name '_t1_labels_disc.nii']);
            
        end
        
        %Update waitbar and message
        waitbar(i/size(file,2),f,sprintf('%d of %d subjects',i,size(file,2)));
        
        cd(filepath);
        
        clear rawNII discNII command2 commandOut2 filepath name status2 i1 i2...
            fileID i3 ind di diTXT discOVL rawOVL h
        
    end
    
    delete(f);
    
    disp(sprintf('\nThe processing is done.\n'));
    
catch ME
    
    f = findall(0,'type','figure','tag','TMWWaitbar');
    delete(f);
    rethrow(ME)
    
end


% --------------------------------------------------------------------
function misc_Callback(hObject, eventdata, handles)
% hObject    handle to misc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function misc_data_Callback(hObject, eventdata, handles)
ENIGMA_sctGUIdataextract


% --------------------------------------------------------------------
function misc_tut_Callback(hObject, eventdata, handles)

try
    if isunix==1
        pathSTR = regexp(path,pathsep,'split');
        ind=strfind(pathSTR(1,:),[filesep 'ENIGMA_sct']);
        ind = cellfun('isempty',ind);
        foundPATH = pathSTR(~ind);
        system(['evince ' foundPATH{1} filesep 'Manual_ENIGMAsct.pdf']);
    else
        open('Manual_ENIGMAsct.pdf')
        
    end
catch ME
    if (strcmp(ME.identifier,'MATLAB:catenate:dimensionMismatch'))
        msg = ['Please, rename the folder of Enigma_sctGUI pipeline to Enigma_sct.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
    end
    rethrow(ME)
end


% --- Executes when uipanel1 is resized.
function uipanel1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function imgREO_Callback(hObject, eventdata, handles)

try
    
    ImageReorientation
    
catch ME
    if (strcmp(ME.identifier,'MATLAB:catenate:dimensionMismatch'))
        msg = ['Please, add the folder shared to your MATLAB path.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
    end
    rethrow(ME)
end

