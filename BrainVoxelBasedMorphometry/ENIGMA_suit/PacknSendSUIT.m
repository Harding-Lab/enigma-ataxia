function PacknSendSUIT

list=spm_select(inf,'dir','Select Subject DIRECTORIES',{},pwd,'...._..');
numsubjs=size(list,1);
for i=1:numsubjs
[dir,name,~,~]=spm_fileparts(list(i,:));
files(i,:)={[dir, '/', name, '/wd', name ,'_t1_seg1.nii']};
files(i+numsubjs,:)={[dir, '/', name, '/wd', name ,'_t1_seg2.nii']};

end

files((numsubjs*2)+1,:)={[dir,'/boxplot*']};
gzip(files,dir);
cd(dir);
tar('SUIT_Final_All',[dir, '/*.gz']);
delete([dir, '/*.gz']);

end
