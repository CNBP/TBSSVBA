function run_vbm_dti_analysis_wm_v2( FA_FOLDER,fa_thresh,fwhm,g1,g2,perm,VBM_FOLDER )
%run_vbm_dti_analysis Runs Voxel-based Morphometry style analysis

% FA_FOLDER     : folder with co-registered FA images
% fa_thresh     : FA Threshold to separqte WM from GM.
% fwhm          : Gaussian filtering fwhm vector [ d1 d2 d3 ]
% g1            : number of subjects in group 1
% g2            : number of subjects in group 2
% perm          : number of permutation of statistical test
% VBM_FOLDER    : folder for results output

if ~exist(VBM_FOLDER,'dir')
    mkdir(VBM_FOLDER)
end

diary([VBM_FOLDER filesep 'diary.txt'])
diary on
%%
fa_imgs = dir(fullfile(FA_FOLDER,'*.nii.gz'));

%% save call parameters to file
fileID=fopen([VBM_FOLDER filesep 'call_params.txt'],'w');

fprintf(fileID,[ 'FA_FOLDER\t: ' FA_FOLDER '\n']);
fprintf(fileID,[ 'fa_thresh\t: ' num2str(fa_thresh) '\n']);
fprintf(fileID,[ 'fwhm\t\t: ' num2str(fwhm) '\n']);
fprintf(fileID,[ 'g1\t\t: ' num2str(g1) '\n']);
fprintf(fileID,[ 'g2\t\t: ' num2str(g2) '\n']);
fprintf(fileID,[ 'perm\t\t: ' num2str(perm) '\n']);
fprintf(fileID,[ 'VBM_FOLDER\t: ' VBM_FOLDER '\n']);


fclose(fileID);

%% Mean FA and white matter mask

scriptR='scripts/vbm_make_wm_mask.sh';
argsR=[' ' FA_FOLDER ' ' '*.nii.gz' ' ' num2str(fa_thresh) ' ' VBM_FOLDER];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

%% Mask images then smooth
copyfile(FA_FOLDER,[FA_FOLDER '_wm_smooth'])

fileout_mask=[VBM_FOLDER filesep 'wm_mask.nii.gz'];

for i=1:length(fa_imgs)
    infile=[FA_FOLDER '_wm_smooth' filesep fa_imgs(i).name];
    %system(['source ~/.bash_profile ; fslmaths ' infile ' -mas ' fileout_mask ' ' infile]);
system(['fsl4.1-fslmaths ' infile ' -mas ' fileout_mask ' ' infile]);
    gaussian_smooth_dtitk_tools([FA_FOLDER '_wm_smooth' filesep fa_imgs(i).name],fwhm);
    
end
data_4d_file=[VBM_FOLDER filesep 'all_wm_FA_smooth'];
%system(['source ~/.bash_profile ; fslmerge -t ' data_4d_file  ' `imglob ' FA_FOLDER '_wm_smooth' filesep '*.nii.gz`']);
system(['fsl4.1-fslmerge -t ' data_4d_file  ' `fsl4.1-imglob ' FA_FOLDER '_wm_smooth' filesep '*.nii.gz`']);
%% Carry out voxel wise statistics
% IMG_ALL=$1
% MASK=$2
% DESIGN_G1_SZ=$3
% DESIGN_G2_SZ=$4
% PERMUTATIONS=$5
% OUT_FOLDER=$6

scriptR='scripts/vbm_randomise_T.sh';
argsR=[' ' data_4d_file ' ' fileout_mask ' ' num2str(g1) ' ' num2str(g2) ' ' num2str(perm) ' ' VBM_FOLDER ' '];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

%%
diary off
end

