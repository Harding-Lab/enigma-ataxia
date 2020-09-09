function RunSuitT1andT2

%Segment & Create Cerebellar Mask with T1w & T2w images.

%This script currently expects to find three files in the selected
%directories: <name>_t1.nii, <name>_t2.nii, <name>_ceresmask.nii

clear all
spm fmri

%Select Directories
dir_list=spm_select(inf,'dir','Select Subject DIRECTORIES in the SUIT folder',{},pwd,'\w');
for i=1:size(dir_list,1)
[~,name,~,~]=spm_fileparts(dir_list(i,:));
t1 = [dir_list(i,:),'/',name,'_t1.nii'];
t2 = [dir_list(i,:),'/',name,'_t2.nii'];
rt2 = [dir_list(i,:),'/r',name,'_t2.nii'];

%Coregister T2 --> T1
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {t1};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {t2};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
spm_jobman('run',matlabbatch);
clear matlabbatch

%Run SUIT Segment
suit_isolate_seg({t1 
    rt2});
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