function SuitNormaliseReslice

clear all
spm fmri
list=spm_select(inf,'dir','Select Subject DIRECTORIES in the SUIT folder',{},pwd,'\w');

for i=1:size(list,1)
[~,name,~,~]=spm_fileparts(list(i,:));
cd(list(i,:));
job.subjND.gray = {[name,'_t1_seg1.nii']};
job.subjND.white = {[name,'_t1_seg2.nii']};
job.subjND.isolation = {[name,'_t1_pcereb.nii']};
suit_normalize_dartel(job)
clear job
job.subj.affineTr = {['Affine_',name,'_t1_seg1.mat']};
job.subj.flowfield = {['u_a_',name,'_t1_seg1.nii']};
job.subj.resample = {[name,'_t1_seg1.nii'], [name,'_t1_seg2.nii']};
job.subj.mask={[name,'_t1_pcereb.nii']};
job.jactransf=1;
suit_reslice_dartel(job);
end    

cd ..

end 
