function export_masks(path, implant_flag)
% -----------------------------------------------------------------------------------
% Author: Neerav Goswami (Sommer Lab), 2023
%
% Splits the manually corrected whole head segmentation file into
% individual tissue masks. Each mask is processed and outputted into its
% own .nii file, which can then be used to create surface meshes. The
% script assumes the white matter was labeled 1, gray matter was labeled 2,
% CSF was labeled 3, the skull was labeled 4, and the scalp was labeled 5.
% Optionally, the implant may be labeled as 6.
%
% inputs:
%
% path - full path to whole head segmentation file
% Ex: 'D:\NHP_MRIs\NHP_T_Segmentation.nii.gz'
%
% implant_flag - flag indicating whether or not the segmentation includes a
% separate code for the implant. Must be 0 or 1.
% -----------------------------------------------------------------------------------

% Get the full path for the segmentation file
[filepath,~,~] = fileparts(path);

% Separate the segmentation into tissues
disp('Separating segmentation into tissues...')
nii_info = niftiinfo(path);
seg = niftiread(nii_info);
if implant_flag
    implant = seg == 6;
end
wm = seg == 1;
gm = seg == 2 | wm;
if implant_flag
    csf = seg == 3 | seg > 6 | gm;
else
    csf = seg == 3 | seg > 5 | gm;
end
skull = seg == 4 | csf;
scalp = seg == 5 | skull;

% Remove extraneous islands with pixels size less than 1000000
disp('Removing voxel islands...')
scalp = bwareaopen(scalp,1000000);
skull = bwareaopen(skull,1000000);
csf = bwareaopen(csf,100000);
gm = bwareaopen(gm,100000);
wm = bwareaopen(wm,100000);

% Fill holes in each tissue
disp('Filling holes in the tissues...')
scalp = imfill(scalp,'holes');
skull = imfill(skull,'holes');
csf = imfill(csf,'holes');
gm = imfill(gm,'holes');
wm = imfill(wm,'holes');
if implant_flag
    implant = imfill(implant,'holes');
end

% Smooth tissue masks with gaussian
disp('Gaussian smoothing...')
scalp = imgaussfilt3(double(scalp),3);
skull = imgaussfilt3(double(skull),3);
csf = imgaussfilt3(double(csf),1);
gm = imgaussfilt3(double(gm),1);
wm = imgaussfilt3(double(wm),1);
if implant_flag
    implant = imgaussfilt3(double(implant),1);
end

% Binarize each tissue msak
disp('Binarizing masks...')
for i = 1:size(scalp,3)
    scalp(:,:,i) = imbinarize(scalp(:,:,i),0.5);
    skull(:,:,i) = imbinarize(skull(:,:,i),0.5);
    csf(:,:,i) = imbinarize(csf(:,:,i),0.5);
    gm(:,:,i) = imbinarize(gm(:,:,i),0.5);
    wm(:,:,i) = imbinarize(wm(:,:,i),0.5);
    if implant_flag
        implant(:,:,i) = imbinarize(implant(:,:,i),0.5);
    end
end

% Fill any holes that may have appeared due to smoothing
disp('Filling any new holes...')
scalp = imfill(scalp,'holes');
skull = imfill(skull,'holes');
csf = imfill(csf,'holes');
gm = imfill(gm,'holes');
wm = imfill(wm,'holes');
if implant_flag
    implant = imfill(implant,'holes');
end

% Remove extra islands that may have appeared due to smoothing
disp('Removing any new islands...')
scalp = bwareaopen(scalp,2000000);
skull = bwareaopen(skull,1000000);
csf = bwareaopen(csf,100000);
gm = bwareaopen(gm,100000);
wm = bwareaopen(wm,100000);

% Save each tissue as its own file
disp('Saving each tissue file...')
nii_info.Datatype = 'double';
niftiwrite(double(scalp), [filepath '\Scalp.nii'], nii_info, 'Compressed', true)
niftiwrite(double(skull), [filepath '\Skull.nii'], nii_info, 'Compressed', true)
niftiwrite(double(csf), [filepath '\CSF.nii'], nii_info, 'Compressed', true)
niftiwrite(double(gm), [filepath '\GM.nii'], nii_info, 'Compressed', true)
niftiwrite(double(wm), [filepath '\WM.nii'], nii_info, 'Compressed', true)
if implant_flag
    niftiwrite(double(implant), [filepath '\Implant.nii'], nii_info, 'Compressed', true)
end

disp('Done!')

end