function run_tbss_dti_analysis_no_proj( FA_FOLDER, TBSS_FOLDER, fa_thresh,g1,g2,perm)
%run_tbss_dti_analysis Runs classic TBSS analysis
%
%  FA_FOLDER  : folder with co-registered(!) FA images
%  TBSS_FOLDER: folder with all results
%  fa_thresh  : fa threshold
%  g1         : number of subjects in group 1
%  g2         : number of subjects in group 2
%  perm       : number of permutation of statistical test

% Luis Akakpo


if ~exist(TBSS_FOLDER,'dir')
    mkdir(TBSS_FOLDER)
end

skel_bool=1;
mask_bool=1;
stat_bool=1;

%% Save call

fileID=fopen([TBSS_FOLDER filesep 'call_params.txt'],'w');

fprintf(fileID,[ 'FA_FOLDER\t: ' FA_FOLDER '\n']);
fprintf(fileID,[ 'TBSS_FOLDER\t: ' TBSS_FOLDER '\n']);

fprintf(fileID,[ 'fa_thresh\t: ' num2str(fa_thresh) '\n']);
fprintf(fileID,[ 'g1\t\t: ' num2str(g1) '\n']);
fprintf(fileID,[ 'g2\t\t: ' num2str(g2) '\n']);
fprintf(fileID,[ 'perm\t\t: ' num2str(perm) '\n']);


fclose(fileID);
%% Mean FA and skeletonisation
% DATA_FOLDER=$1
% REGEX=$2
% OUT_FOLDER=$3

if skel_bool
    scriptR='scripts/tbss_make_skel.sh';
    argsR=[' ' FA_FOLDER ' ' '*.nii.gz' ' ' TBSS_FOLDER];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
end
%% Mask files
if mask_bool
    scriptR='scripts/tbss_noproject.sh';
    argsR=[' ' TBSS_FOLDER ' ' num2str(fa_thresh) ];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
end

%% Voxelwise statistics
% IMG_ALL=$1
% MASK=$2
% DESIGN_G1_SZ=$3
% DESIGN_G2_SZ=$4
% PERMUTATIONS=$5
% OUT_FOLDER=$6

STAT_FOLDER=[TBSS_FOLDER filesep 'stats_' num2str(fa_thresh)];
all_img = [STAT_FOLDER filesep 'all_FA_skeletonised'];
mask= [STAT_FOLDER filesep 'mean_FA_skeleton_mask'];

if stat_bool
    scriptR='scripts/tbss_randomise.sh';
    argsR=[' ' all_img ' ' mask ' ' num2str(g1) ' ' num2str(g2) ' ' num2str(perm) ' ' STAT_FOLDER ' '];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
end


end
