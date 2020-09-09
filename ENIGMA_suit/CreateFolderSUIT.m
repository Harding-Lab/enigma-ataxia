function CreateFolderSUIT
clear all
images=spm_select(inf,'any','Select T1 images from INPUT directory to include in SUIT analysis',{},pwd,'t1');

%Set Directories
[input_dir,~,~,~]=spm_fileparts(images(1,:));
suit_dir=strrep(input_dir,'input','suit/');
ceres_dir=strrep(input_dir,'input','ceres/');

for i=1:size(images,1);
    
%Unzip T1 to SUIT Directory
[~,gz_name,~,~]=spm_fileparts(images(i,:));
name=strrep(gz_name,'_t1.nii','');
gunzip(images(i,:),[suit_dir,name]);

%Check for a T2 image, and Unzip to SUIT Directory
if exist([input_dir,'/',name,'_t2.nii.gz'], 'file');
    gunzip([input_dir,'/',name,'_t2.nii.gz'],[suit_dir,name]);
end
    
%Check if a CERES directory exists, and unzip CERES Mask to SUIT Directory
if ~isempty(dir([ceres_dir,'native_',name,'*.zip']))
    unzip(strtrim(ls([ceres_dir,'native_',name,'*.zip'])),[suit_dir,name]);
    movefile(strtrim(ls([suit_dir,name,'/native_tissue*'])),[suit_dir,name,'/',name,'_ceresmask.nii']);
    delete([suit_dir,name,'/*job*.nii']);
    delete([suit_dir,name,'/*.pdf']);
end 

end

display('SUIT folders have been prepared')

end 