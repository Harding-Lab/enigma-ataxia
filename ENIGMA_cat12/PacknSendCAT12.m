function PacknSendCAT12

list=spm_select(inf,'dir','Select Subject DIRECTORIES',{},pwd,'...._..');
numsubjs=size(list,1);
for i=1:numsubjs
[dir,name,~,~]=spm_fileparts(list(i,:));
files(i,:)={[list(i,:),'/mri']};
files(i+numsubjs,:)={[list(i,:),'/report']};
end

files((numsubjs*2)+1,:)={[dir,'/boxplot*']};
gzip(files,dir);
cd(dir)
tar('CAT12_Final_All',[dir, '/*.gz']);
delete([dir, '/*.gz']);

end