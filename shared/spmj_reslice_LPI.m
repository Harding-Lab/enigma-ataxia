function name=spmj_reslice_LPI(VS,varargin);
% function name=spmj_reslice_LPI(VS,varargin);
% Reslices source volume into LPI orientation
% INPUT: 
%       VS: memory-mapped volume file or filename 
% VARARGIN: 
%       'voxelsize'
%       'origin'
%       'fliplr'


if (~exist('VS') | isempty(VS))
    VS=spm_select(1,'image','Image to reslice into LPI format');
end;
if ischar(VS)
    VS=spm_vol(VS);
end;

voxelsize=[]; 
fliplr=0; 
name = [];
vararginoptions(varargin,{'voxelsize','origin','fliplr','name'}); %tobi
if (isempty(voxelsize)) 
    A=VS.mat(1:3,1:3);
    [u,s,v]=svd(A);
    [dummy,indx]=max(abs(u)'); 
    voxelsize=diag(s);
    voxelsize=voxelsize(indx)'; 
    fprintf('Voxelsizes: %2.3f %2.3f %2.3f\n',voxelsize); 
end;

% Calculate new image size for new image 
% y = inv(B) * A * x 
corners=[1 1 1;1 1 VS.dim(3);1 VS.dim(2) VS.dim(3);1 VS.dim(2) 1;...
         VS.dim(1) 1 1;VS.dim(1) 1 VS.dim(3);VS.dim(1) VS.dim(2) VS.dim(3);VS.dim(1) VS.dim(2) 1];
newcorners=inv(diag([voxelsize]))* A*corners';
minP=floor(min(newcorners')); 
maxP=ceil(max(newcorners')); 
dim=maxP-minP+1; 
minWorld=min([VS.mat*[corners';ones(1,8)]]')';
origin=-diag([voxelsize])*ones(3,1)+minWorld(1:3,1);
mat=diag([voxelsize 1]);
mat(1:3,4)=origin; 
[pth,nm,xt] = fileparts(deblank(VS.fname));

if (isempty(name))
    name = fullfile(pth,['r' nm xt]);
end 
spmj_reslice_vol(VS,dim,mat,name); 
