function img_smoothed = gaussian_smooth_nii( nii_file, size, sd,save )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Load data
nii=load_nii_gz(nii_file);

%% Filter image
if nargin==3
    img_smoothed=smooth3(nii.img,'gaussian',size,sd);
elseif nargin ==2
    img_smoothed=smooth3(nii.img,'gaussian',size);
else
    img_smoothed=smooth3(nii.img,'gaussian');
end

nii.img=img_smoothed;


%% Save file
if save
parts=strsplit(nii_file,'.');
fileout=[parts{1} '_smoothed.nii'];

save_nii_gz(nii,fileout);

end


end

