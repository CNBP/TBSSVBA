function img_smoothed = gaussian_smooth_dtitk_tools(nii_file, fwhm )
%gaussian_smooth_dtitk_tools Applies smoothing with a gaussian linear
%filter

% nii_file    : File to process
% fwhm :   Vector of the FWHm in all directions


% ATENTION OVERWRITES THE ORIGINAL FILE!!


system(['source ~/.bash_profile; SVGaussianSmoothing -in ' nii_file ' -fwhm ' num2str(fwhm)]);


nii=load_nii_gz(nii_file);

img_smoothed=nii.img;

end

