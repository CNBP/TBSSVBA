function run_vbm_dti_analysis_wm_nonFA_v2( IM_FOLDER,wm_mask,fwhm,g1,g2,perm,VBM_FOLDER )
%run_vbm_dti_analysis Runs Voxel-based Morphometry style analysis

% IM_FOLDER     : folder with co-registered FA images
% wm_mask       : WM mask
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
imgs = dir(fullfile(IM_FOLDER,'*.nii.gz'));

%% save call parameters to file
fileID=fopen([VBM_FOLDER filesep 'call_params.txt'],'w');

fprintf(fileID,[ 'IM_FOLDER\t: ' IM_FOLDER '\n']);
fprintf(fileID,[ 'wm_mask\t\t: ' wm_mask '\n']);
fprintf(fileID,[ 'fwhm\t\t: ' num2str(fwhm) '\n']);
fprintf(fileID,[ 'g1\t\t: ' num2str(g1) '\n']);
fprintf(fileID,[ 'g2\t\t: ' num2str(g2) '\n']);
fprintf(fileID,[ 'perm\t\t: ' num2str(perm) '\n']);
fprintf(fileID,[ 'VBM_FOLDER\t: ' VBM_FOLDER '\n']);


fclose(fileID);
%% Mask then smooth 

copyfile(IM_FOLDER,[IM_FOLDER '_wm_smooth'])
for i=1:length(imgs)
    
    infile=[IM_FOLDER '_wm_smooth' filesep imgs(i).name];
    %system(['source ~/.bash_profile ; fslmaths ' infile ' -mas ' wm_mask ' ' infile]);
system(['fsl4.1-fslmaths ' infile ' -mas ' wm_mask ' ' infile]);
    gaussian_smooth_dtitk_tools(infile,fwhm);
    
end

parts=strsplit(IM_FOLDER,filesep);

data_4d_file=[VBM_FOLDER filesep 'all_wm_' parts{end} '_smooth'];
%system(['source ~/.bash_profile ; fslmerge -t ' data_4d_file  ' `imglob ' IM_FOLDER '_wm_smooth' filesep '*.nii.gz`']);
system(['fsl4.1-fslmerge -t ' data_4d_file  ' `fsl4.1-imglob ' IM_FOLDER '_wm_smooth' filesep '*.nii.gz`']);

%% Carry out voxel wise statistics
% IMG_ALL=$1
% MASK=$2
% DESIGN_G1_SZ=$3
% DESIGN_G2_SZ=$4
% PERMUTATIONS=$5
% OUT_FOLDER=$6

scriptR='scripts/vbm_randomise_T.sh';
argsR=[' ' data_4d_file ' ' wm_mask ' ' num2str(g1) ' ' num2str(g2) ' ' num2str(perm) ' ' VBM_FOLDER ' '];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

%%
diary off
%exit
end

