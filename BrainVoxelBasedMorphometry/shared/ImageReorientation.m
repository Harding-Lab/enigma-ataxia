function ImageReorientation

list=spm_select(inf,'any','Select Files to Reorient...',{},pwd);
for i=1:size(list,1)
    filename=strtrim(list(i,:));
    [dir,name,ext,~]=spm_fileparts(filename);
if strcmp(ext,'.gz')
    unzipped=gunzip(filename,[dir,'/temp']);
    resliced=spmj_reslice_LPI(unzipped{1,1});
    movefile(resliced,unzipped{1,1});
    waitfor(spmj_reorient_img('init',unzipped{1,1}));
    gzip(unzipped{1,1},dir);
    rmdir([dir,'/temp'],'s');
elseif strcmp(ext,'.nii')
    resliced=spmj_reslice_LPI(filename);
    movefile(resliced,filename);
    waitfor(spmj_reorient_img('init',filename));
else
    display('Image may not be in nifti or nifti_gz format')
end
end
display('All selected images have been reoriented') 

end