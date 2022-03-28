function SliceView_uf2c(BackGroundImg,OverlayImg,OverlayImgThre,...
    BackgroungImgThre,FOrientation,OverlayColormap,slc_nmbr,AddtTitle,...
    OutputName,OutputDir)
%
% Brunno Machado de Campos
% University of Campinas, 2017
%
% Copyright (c) 2017, Brunno Machado de Campos
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
% INPUTS: 
% BackGroundImg: High Res T1 WI 
% OverlayImg: Image in the same matricial spatial of the 'BackGroundImg'
% OverlayImgThre: Threshold to be applied on the 'OverlayImg'
% BackgroungImgThre: Threshold to be applied on the 'BackgroungImgThre'
% FOrientation: slices orientation: 'Axial', 'Sagittal' or 'Coronal'
% OverlayColormap: overlay colormap e.g.: 'hot', 'winter'
% slc_nmbr: number of slices presented e.g.: 30
% AddtTitle: Additional Figure Title
% OutputName: name of the output .png figure
% OutputDir: directory of the output .png figure
% Visibi: String, 'on' or 'off' for the popup of the image during its
% creation


if ~exist('BackgroungImgThr','var')
    BackgroungImgThre = 0.1; % Para dar uma limpada na estrutural
end

if ~exist('OutputName','var')
    OutputName = 'SliceView.png';
end

if ~exist('OutputDir','var')
    [OutputDirTMP,bxx,cxx] = fileparts(OverlayImg);
    OutputDir = OutputDirTMP;
end

if ~exist('slc_nmbr','var')
    slc_nmbr   = 20; % numero de fatias
end

if ~exist('AddtTitle','var')
    AddtTitle = ''; % 'axial', 'sagittal' or 'coronal'
end

if ~exist('OverlayColormap','var')
    OverlayColormap = hot; % Colomap: hot ou winter...
end

if ~exist('FOrientation','var')
    FOrientation = 'axial'; % 'axial', 'sagittal' or 'coronal'
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);
threshStat = OverlayImgThre; % 

imgs       = {BackGroundImg,OverlayImg};
Sobj           = slover;
 % colorbar: vector with colobar of images index Ex: [1 2] --> background and overlay
Sobj.transform = FOrientation;

Sobj.img(1).vol   = spm_vol(imgs{1});

Sobj.img(1).prop  = 1;
Sobj.img(1).type  = 'truecolour';
Sobj.img(1).cmap  = gray(64);
Sobj.img(1).range = [BackgroungImgThre max(max(max(Sobj.img(1).vol.private.dat(:,:,:))))];

TMPstru = spm_vol(imgs{2});
matOV = TMPstru.private.dat(:,:,:);
matOV(isnan(matOV)) = 0;

if ~isequal(sum(sum(sum(matOV))),0)
    Sobj.cbar      = 2;
    Sobj.img(2).vol.imgdata = abs(matOV);
    Sobj.img(2).vol.dim = TMPstru.dim;
    Sobj.img(2).vol.mat = TMPstru.mat;

    Sobj.img(2).prop  = 1;
    Sobj.img(2).type  = 'split';
    Sobj.img(2).cmap  = OverlayColormap; 
    Sobj.img(2).range = [threshStat max(max(max(Sobj.img(2).vol.imgdata)))];
    Sobj.img(2).hold = 1;
end

if numel(slc_nmbr)>1
    Sobj.slices  = slc_nmbr;
else
    switch FOrientation
        case 'axial'
            Sobj.slices  = round(linspace(-60,60,slc_nmbr));
        case 'coronal'
            Sobj.slices  = round(linspace(-60,60,slc_nmbr));
        case 'sagittal'
            Sobj.slices  = round(linspace(-60,60,slc_nmbr));
    end
end

Sobj.figure = figure;

set(Sobj.figure,'Name','Slice View',...
    'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1).*0.6 ScreSize(1).*0.4]),...
                'Color',[0 0 0]);
            
Sobj = paint(Sobj);

set(Sobj.figure,'Position',...
    round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1).*0.6 ScreSize(1).*0.41]));

mTextBox = uicontrol('style','text','position',...
    round([(ScreSize(1).*0.5)/2.5 (ScreSize(1).*0.4) ScreSize(1)*.2 ScreSize(1)*.01]));
set(mTextBox,'String',['Slice View: Overlay thresholded at ' num2str(threshStat),'  ',AddtTitle],...
    'BackGroundColor',[0 0 0],'ForeGroundColor',[1 1 1],'FontSize',12);
set(Sobj.figure,'Name','Slice View');

% Sobj.slices(~diff(Sobj.slices)) = [];
% Sobj.figure = spm_figure('GetWin','Graphics');
% Sobj.figure.Units = 'pixels';
% set(Sobj.figure,'Name','Slice View','Color',[0 0 0]);
% Sobj = fill_defaults(Sobj);
% Sobj = paint(Sobj);

% saveas(Sobj.figure,[OutputDir filesep OutputName(1:end-3),'fig'])

drawnow
imgRR = getframe(Sobj.figure);
imwrite(imgRR.cdata, [OutputDir filesep OutputName]);
close('Slice View')

