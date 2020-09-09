function CreateFolder

images=spm_select(inf,'any','Select T1 images from INPUT directory to include in CAT12 analysis',{},pwd,'t1');

[input_dir,~,~,~]=spm_fileparts(images(1,:));
cat12_dir=strrep(input_dir,'input','cat12/');
for i=1:size(images,1);
[~,gz_name,~,~]=spm_fileparts(images(i,:));
name=strrep(gz_name,'_t1.nii','');
gunzip(images(i,:),[cat12_dir,name]);
end

display('CAT12 folders have been prepared')

end