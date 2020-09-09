function RunSuitT1only

%Segment & Create Cerebellar Mask with T1w image only.

%This script currently expects to find two files in the selected
%directories: <name>_t1.nii, <name>_ceresmask.nii

clear all
spm fmri

%Select Directories
dir_list=spm_select(inf,'dir','Select Subject DIRECTORIES in the SUIT folder',{},pwd,'\w');
for i=1:size(dir_list,1)
[~,name,~,~]=spm_fileparts(dir_list(i,:));
t1 = [dir_list(i,:),'/',name,'_t1.nii'];

%Run SUIT Segment
suit_isolate_seg({t1});
delete([dir_list(i,:),'/c_',name,'*']);

%Define inputs for ImCalc
ceres = [dir_list(i,:),'/',name,'_ceresmask.nii'];
suit_gm = [dir_list(i,:),'/',name,'_t1_seg1.nii'];
suit_wm = [dir_list(i,:),'/',name,'_t1_seg2.nii'];

%Calculate CERES-optimised SUIT Mask: CERES * SUIT_GM + SUIT_WM
matlabbatch{1}.spm.util.imcalc.input = {ceres 
    suit_gm
    suit_wm};
matlabbatch{1}.spm.util.imcalc.output = [name,'_t1_pcereb.nii'];
matlabbatch{1}.spm.util.imcalc.outdir = {dir_list(i,:)};
matlabbatch{1}.spm.util.imcalc.expression = '(((i1>0).*i2)+i3)>0.1';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run',matlabbatch);
clear matlabbatch
end

end