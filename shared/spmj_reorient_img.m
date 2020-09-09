function fg=spmj_reorient_img(op,varargin)
% image and header display
% FORMAT spmj_reorient_img('init','filename')
%
%_______________________________________________________________________
% Edited version of 'spm_image' to allow quick and easy reorientation of
% the origin of an image to the anterior commissure, to ensure the image is
% in rough alignment with the TPMs used for segmentation. This will prevent
% a major source of segmentation errors in later processing steps.
%
% Edited from y_spm_image.m distributed in the DPABI software package 
% Ian Harding, 2018-07-25
%_______________________________________________________________________
%
% spm_image is an interactive facility that allows orthogonal sections
% from an image volume to be displayed.  Clicking the cursor on either
% of the three images moves the point around which the orthogonal
% sections are viewed.  The co-ordinates of the cursor are shown both
% in voxel co-ordinates and millimeters within some fixed framework.
% The intensity at that point in the image (sampled using the current
% interpolation scheme) is also given. The position of the crosshairs
% can also be moved by specifying the co-ordinates in millimeters to
% which they should be moved.  Clicking on the horizontal bar above
% these boxes will move the cursor back to the origin  (analogous to
% setting the crosshair position (in mm) to [0 0 0]).
%
% The images can be re-oriented by entering appropriate translations,
% rotations and zooms into the panel on the left.  The transformations
% can then be saved by hitting the ``Reorient images...'' button.  The
% transformations that were applied to the image are saved to the
% ``.mat'' files of the selected images.  The transformations are
% considered to be relative to any existing transformations that may be
% stored in the ``.mat'' files.  Note that the order that the
% transformations are applied in is the same as in ``spm_matrix.m''.
%
% The ``Reset...'' button next to it is for setting the orientation of
% images back to transverse.  It retains the current voxel sizes,
% but sets the origin of the images to be the centre of the volumes
% and all rotations back to zero.
%
% The right panel shows miscellaneous information about the image.
% This includes:
%   Dimensions - the x, y and z dimensions of the image.
%   Datatype   - the computer representation of each voxel.
%   Intensity  - scalefactors and possibly a DC offset.
%   Miscellaneous other information about the image.
%   Vox size   - the distance (in mm) between the centres of
%                neighbouring voxels.
%   Origin     - the voxel at the origin of the co-ordinate system
%   DIr Cos    - Direction cosines.  This is a widely used
%                representation of the orientation of an image.
%
% There are also a few options for different resampling modes, zooms
% etc.  You can also flip between voxel space (as would be displayed
% by Analyze) or world space (the orientation that SPM considers the
% image to be in).  If you are re-orienting the images, make sure that
% world space is specified.  Blobs (from activation studies) can be
% superimposed on the images and the intensity windowing can also be
% changed.
%
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spmj_reorient_img.m 3691 2010-01-20 17:08:30Z guillaume $

global st
global spmj_reorient_img_Parameters %YAN Chao-Gan 101010
global fg  %YAN Chao-Gan 101010

if nargin == 0,
    spm('FnUIsetup','Display',0);
    spm('FnBanner',mfilename,'$Rev: 3691 $');

    % get the image's filename {P}
    %----------------------------------------------------------------------
    P      = spm_select(1,'image','Select image');
    spmj_reorient_img('init',P);
    return;
end;

if isstruct(op)
    % job data structure
    spmj_reorient_img('init', op.data{1});
    return;
end;

try
    if ~strcmp(op,'init') && ~strcmp(op,'reset') && isempty(st.vols{1})
        my_reset; warning('Lost all the image information');
        return;
    end;
catch
end

if strcmp(op,'repos'),
    % The widgets for translation rotation or zooms have been modified.
    %-----------------------------------------------------------------------
    fg      = spm_figure('Findwin','Graphics');
    set(fg,'Pointer','watch');
    i       = varargin{1};
    st.B(i) = eval(get(gco,'String'),num2str(st.B(i)));
    set(gco,'String',st.B(i));
    st.vols{1}.premul = spm_matrix(st.B);
    % spm_orthviews('MaxBB');
    %spmj_reorient_img('zoom_in');
    %spmj_reorient_img('update_info');
    spm_orthviews('Redraw');
    set(fg,'Pointer','arrow');
    return;
end;

if strcmp(op,'shopos'),
    % The position of the crosshairs has been moved.
    %-----------------------------------------------------------------------
    if isfield(st,'mp'),
        fg  = spm_figure('Findwin','Graphics');
        if any(findobj(fg) == st.mp),
            set(st.mp,'String',sprintf('%.1f %.1f %.1f',spm_orthviews('pos')));
            pos = spm_orthviews('pos',1);
            set(st.vp,'String',sprintf('%.1f %.1f %.1f',pos));
            set(st.in,'String',sprintf('%g',spm_sample_vol(st.vols{1},pos(1),pos(2),pos(3),st.hld)));
        else
            st.Callback = ';';
            st = rmfield(st,{'mp','vp','in'});
        end;
    else
        st.Callback = ';';
    end;
    return;
end;

if strcmp(op,'setposmm'),
    % Move the crosshairs to the specified position
    %-----------------------------------------------------------------------
    if isfield(st,'mp'),
        fg = spm_figure('Findwin','Graphics');
        if any(findobj(fg) == st.mp),
            pos = sscanf(get(st.mp,'String'), '%g %g %g');
            if length(pos)~=3,
                pos = spm_orthviews('pos');
            end;
            spm_orthviews('Reposition',pos);
        end;
    end;
    return;
end;

if strcmp(op,'setposvx'),
    % Move the crosshairs to the specified position
    %-----------------------------------------------------------------------
    if isfield(st,'mp'),
        fg = spm_figure('Findwin','Graphics');
        if any(findobj(fg) == st.vp),
            pos = sscanf(get(st.vp,'String'), '%g %g %g');
            if length(pos)~=3,
                pos = spm_orthviews('pos',1);
            end;
            tmp = st.vols{1}.premul*st.vols{1}.mat;
            pos = tmp(1:3,:)*[pos ; 1];
            spm_orthviews('Reposition',pos);
        end;
    end;
    return;
end;


if strcmp(op,'addblobs'),
    % Add blobs to the image - in full colour
    spm_figure('Clear','Interactive');
    nblobs = spm_input('Number of sets of blobs',1,'1|2|3|4|5|6',[1 2 3 4 5 6],1);
    for i=1:nblobs,
        [SPM,VOL] = spm_getSPM;
        c = spm_input('Colour','+1','m','Red blobs|Yellow blobs|Green blobs|Cyan blobs|Blue blobs|Magenta blobs',[1 2 3 4 5 6],1);
        colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
        spm_orthviews('addcolouredblobs',1,VOL.XYZ,VOL.Z,VOL.M,colours(c,:));
        set(st.blobber,'String','Remove Blobs','Callback','spmj_reorient_img(''rmblobs'');');
    end;
    spm_orthviews('addcontext',1);
    spm_orthviews('Redraw');
end;

if strcmp(op,'rmblobs'),
    % Remove all blobs from the images
    spm_orthviews('rmblobs',1);
    set(st.blobber,'String','Add Blobs','Callback','spmj_reorient_img(''addblobs'');');
    spm_orthviews('rmcontext',1); 
    spm_orthviews('Redraw');
end;

if strcmp(op,'window'),
    op = get(st.win,'Value');
    if op == 1,
        spm_orthviews('window',1);
    else
        spm_orthviews('window',1,spm_input('Range','+1','e','',2));
    end;
end;


if strcmp(op,'reorient'),
    % Time to modify the ``.mat'' files for the images.
    % I hope that giving people this facility is the right thing to do....
    %-----------------------------------------------------------------------
    %Change the Origin to the crosshair point
    posTemp = sscanf(get(st.mp,'String'), '%g %g %g');
    if ~isempty(posTemp)
        st.B(1:3)=-1*posTemp';
    end
    %Add by Sandy to get QC Score and Comment
    %{
    for i=1:5
        Value=get(st.QCScoreWidget{i}, 'Value');
        if Value
            QCScore=i;
            break;
        end
    end
    spmj_reorient_img_Parameters.QCScore=QCScore;

    QCComment=get(st.QCCommentWidget, 'String');
    spmj_reorient_img_Parameters.QCComment=QCComment;
    %}
    
    mat = spm_matrix(st.B);
    spmj_reorient_img_Parameters.ReorientMat = mat;
    %YAN Chao-Gan 101010
%     if det(mat)<=0
%         spm('alert!','This will flip the images',mfilename,0,1);
%     end;
    P = spmj_reorient_img_Parameters.ReorientFileList;
%     P = spm_select(Inf, 'image','Images to reorient');
    Mats = zeros(4,4,size(P,1));
%     spm_progress_bar('Init',size(P,1),'Reading current orientations',...
%         'Images Complete');
    for i=1:size(P,1),
        Mats(:,:,i) = spm_get_space(P{i,:});   %Mats(:,:,i) = spm_get_space(P(i,:));
%         spm_progress_bar('Set',i);
    end;
%     spm_progress_bar('Init',size(P,1),'Reorienting images',...
%         'Images Complete');
    for i=1:size(P,1),
        spm_get_space(P{i,:},mat*Mats(:,:,i));  %spm_get_space(P(i,:),mat*Mats(:,:,i));
        if ~mod(i,5)
            fprintf('.');
        end
%         spm_progress_bar('Set',i);
    end;
    fprintf('\n');
%     spm_progress_bar('Clear');
%     tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
%     if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
%         spmj_reorient_img('init',st.vols{1}.fname);
%     end;
    close(fg);
    return;
end;


if strcmp(op,'resetorient'),
    % Time to modify the ``.mat'' files for the images.
    % I hope that giving people this facility is the right thing to do....
    %-----------------------------------------------------------------------
    P = spm_select(Inf, 'image','Images to reset orientation of');
    spm_progress_bar('Init',size(P,1),'Resetting orientations',...
        'Images Complete');
    for i=1:size(P,1),
        V    = spm_vol(deblank(P(i,:)));
        M    = V.mat;
        vox  = sqrt(sum(M(1:3,1:3).^2));
        if det(M(1:3,1:3))<0, vox(1) = -vox(1); end;
        orig = (V.dim(1:3)+1)/2;
                off  = -vox.*orig;
                M    = [vox(1) 0      0      off(1)
                0      vox(2) 0      off(2)
                0      0      vox(3) off(3)
                0      0      0      1];
        spm_get_space(P(i,:),M);
        spm_progress_bar('Set',i);
    end;
    spm_progress_bar('Clear');
    tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
    if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
        spmj_reorient_img('init',st.vols{1}.fname);
    end;
    return;
end;

if strcmp(op,'reset'),
    my_reset;
end;

if strcmp(op,'init'),
global fg  %YAN Chao-Gan 101010
fg = spm_figure('GetWin','Graphics');
if isempty(fg), error('Can''t create graphics window'); end
spm_figure('Clear','Graphics');

P = varargin{1};
spmj_reorient_img_Parameters.ReorientFileList={P};
% % YAN Chao-Gan. If no images specified, then reorient itself.
% if ~isfield(spmj_reorient_img_Parameters,'ReorientFileList')
%     spmj_reorient_img_Parameters.ReorientFileList={P};
% end
if ischar(P), P = spm_vol(P); end;
P = P(1);

spm_orthviews('Reset');
spm_orthviews('Image', P, [0.0 0.45 1 0.55]);
if isempty(st.vols{1}), return; end;

spm_orthviews('MaxBB');
st.callback = 'spmj_reorient_img(''shopos'');';

st.B = [0 0 0  0 0 0  1 1 1  0 0 0];

% locate Graphics window and clear it
%-----------------------------------------------------------------------
WS = spm('WinScale');

% Widgets for re-orienting images.
%-----------------------------------------------------------------------
uicontrol(fg,'Style','Frame','Position',[60 25 200 325].*WS,'DeleteFcn','spmj_reorient_img(''reset'');');
uicontrol(fg,'Style','Text', 'Position',[75 220 100 016].*WS,'String','right  {mm}');
uicontrol(fg,'Style','Text', 'Position',[75 200 100 016].*WS,'String','forward  {mm}');
uicontrol(fg,'Style','Text', 'Position',[75 180 100 016].*WS,'String','up  {mm}');
uicontrol(fg,'Style','Text', 'Position',[75 160 100 016].*WS,'String','pitch  {rad}');
uicontrol(fg,'Style','Text', 'Position',[75 140 100 016].*WS,'String','roll  {rad}');
uicontrol(fg,'Style','Text', 'Position',[75 120 100 016].*WS,'String','yaw  {rad}');
uicontrol(fg,'Style','Text', 'Position',[75 100 100 016].*WS,'String','resize  {x}');
uicontrol(fg,'Style','Text', 'Position',[75  80 100 016].*WS,'String','resize  {y}');
uicontrol(fg,'Style','Text', 'Position',[75  60 100 016].*WS,'String','resize  {z}');

uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',1);','Position',[175 220 065 020].*WS,'String','0','ToolTipString','translate');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',2);','Position',[175 200 065 020].*WS,'String','0','ToolTipString','translate');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',3);','Position',[175 180 065 020].*WS,'String','0','ToolTipString','translate');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',4);','Position',[175 160 065 020].*WS,'String','0','ToolTipString','rotate');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',5);','Position',[175 140 065 020].*WS,'String','0','ToolTipString','rotate');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',6);','Position',[175 120 065 020].*WS,'String','0','ToolTipString','rotate');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',7);','Position',[175 100 065 020].*WS,'String','1','ToolTipString','zoom');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',8);','Position',[175  80 065 020].*WS,'String','1','ToolTipString','zoom');
uicontrol(fg,'Style','edit','Callback','spmj_reorient_img(''repos'',9);','Position',[175  60 065 020].*WS,'String','1','ToolTipString','zoom');

uicontrol(fg,'Style','Pushbutton','String','Reorient images','Callback','spmj_reorient_img(''reorient'');',...
         'Position',[70 35 100 020].*WS,'ToolTipString','modify position information of the images');
% uicontrol(fg,'Style','Pushbutton','String','Reorient images','Callback','spmj_reorient_img(''reorient'')',...
%          'Position',[70 35 125 020].*WS,'ToolTipString','modify position information of selected images');
     
% uicontrol(fg,'Style','Pushbutton','String','Define ROI','Callback','spmj_reorient_img(''DefineROI'');',...
%         'Position',[175 35 80 020].*WS,'ToolTipString','reset orientations of selected images');
% uicontrol(fg,'Style','Pushbutton','String','Reset...','Callback','spmj_reorient_img(''resetorient'')',...
%          'Position',[195 35 55 020].*WS,'ToolTipString','reset orientations of selected images');

% Crosshair position
%-----------------------------------------------------------------------
uicontrol(fg,'Style','Frame','Position',[70 250 180 90].*WS);
uicontrol(fg,'Style','Text', 'Position',[75 320 170 016].*WS,'String','Crosshair Position');
uicontrol(fg,'Style','PushButton', 'Position',[75 316 170 006].*WS,...
    'Callback','spm_orthviews(''Reposition'',[0 0 0]);','ToolTipString','move crosshairs to origin');
% uicontrol(fg,'Style','PushButton', 'Position',[75 315 170 020].*WS,'String','Crosshair Position',...
%   'Callback','spm_orthviews(''Reposition'',[0 0 0]);','ToolTipString','move crosshairs to origin');
uicontrol(fg,'Style','Text', 'Position',[75 295 35 020].*WS,'String','mm:');
uicontrol(fg,'Style','Text', 'Position',[75 275 35 020].*WS,'String','vx:');
uicontrol(fg,'Style','Text', 'Position',[75 255 65 020].*WS,'String','Intensity:');

st.mp = uicontrol(fg,'Style','edit', 'Position',[110 295 135 020].*WS,'String','','Callback','spmj_reorient_img(''setposmm'');','ToolTipString','move crosshairs to mm coordinates');
st.vp = uicontrol(fg,'Style','edit', 'Position',[110 275 135 020].*WS,'String','','Callback','spmj_reorient_img(''setposvx'');','ToolTipString','move crosshairs to voxel coordinates');
st.in = uicontrol(fg,'Style','Text', 'Position',[140 255  85 020].*WS,'String','');

% General information
%-----------------------------------------------------------------------
uicontrol(fg,'Style','Frame','Position',[305  25 280 325].*WS);
uicontrol(fg, 'Style', 'Text', 'String', '1) Place crosshairs close to the Anterior Commissure in the above image.', 'HorizontalAlignment', 'left',...
    'Position', [310 200 270 120].*WS);
uicontrol(fg, 'Style', 'Text', 'String', 'Close precision is NOT NECESSARY. Do not spend more than a few seconds', 'HorizontalAlignment', 'left',...
    'Position', [310 160 270 120].*WS);
uicontrol(fg, 'Style', 'Text', 'String', '2) Press "Reorient images" (bottom left of screen)', 'HorizontalAlignment', 'left',...
    'Position', [310 120 270 120].*WS);


uicontrol(fg,'Style','Text','Position' ,[310 330 50 016].*WS,...
     'HorizontalAlignment','right', 'String', 'File:');
uicontrol(fg,'Style','Text','Position' ,[360 330 210 016].*WS,...
     'HorizontalAlignment','left', 'String', spm_str_manip(st.vols{1}.fname,'k25'),'FontWeight','bold');
end;
return;

function QCScoreCallback(obj, eventdata)
global st

if ~get(obj, 'Value')
    set(obj, 'Value', 1);
    return
end

for i=1:5
    other_obj=st.QCScoreWidget{i};
    if other_obj~=obj
        set(other_obj, 'Value', 0);
    end
end

function my_reset
spm_orthviews('reset');
spm_figure('Clear','Graphics');
return;

