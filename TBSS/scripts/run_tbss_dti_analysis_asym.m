function run_tbss_dti_analysis_asym( DATA_FOLDER,regex, TBSS_FOLDER,fa_thresh,g1,g2,perm,skel_bool,proj_bool,stat_bool,deproj_all_bool)
%run_tbss_dti_analysis Runs classic TBSS analysis
%
%  DATA_FOLDER  : folder with co-registered(!) FA images
%  TBSS_FOLDER: folder with all results
%  fa_thresh  : fa threshold

% Luis Akakpo

%skel_proj_bool=0;
%stat_bool=1;


%%

if ~exist(TBSS_FOLDER,'dir')
    mkdir(TBSS_FOLDER)
end

parts=strsplit(DATA_FOLDER,filesep);
altim=parts{end};
if strfind(lower(altim),'fa')
    altim='FA';
end

%% Create sym skeleton
% DATA_FOLDER=$1
% REGEX=$2
% IM_TYPE=$3
% TBSS_FOLDER=$4
% THRESH=$5

if skel_bool
    scriptR='scripts/tbss_make_sym_skel.sh';
    
    argsR=[' ' DATA_FOLDER ' ' regex ' ' altim ' ' TBSS_FOLDER ' ' num2str(fa_thresh)];
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
end
%% Project data
% DATA_FOLDER=$1
% REGEX=$2
% IM_TYPE=$3
% TBSS_FOLDER=$4
% THRESH=$5

if proj_bool
    scriptR='scripts/tbss_project_asym_skel.sh';
    
    argsR=[' ' DATA_FOLDER ' ' regex ' ' altim ' ' TBSS_FOLDER ' ' num2str(fa_thresh)];
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
end

%% Voxelwise statistics
% IMG_ALL=$1
% MASK=$2
% DESIGN_G1_SZ=$3
% DESIGN_G2_SZ=$4
% PERMUTATIONS=$5
% STAT_FOLDER=$6

STAT_FOLDER=[TBSS_FOLDER filesep 'stats_' num2str(fa_thresh) '_' altim];
img_asym = [TBSS_FOLDER filesep 'all_' altim '_skeletonised_LR_diff'];
mask= [TBSS_FOLDER filesep 'mean_FA_symmetrised_skeleton_mask'];

if stat_bool
    
    if ~exist(STAT_FOLDER,'dir')
        mkdir(STAT_FOLDER);
    end
    
    scriptR='scripts/tbss_randomise.sh';
    argsR=[' ' img_asym ' ' mask ' ' num2str(g1) ' ' num2str(g2) ' ' num2str(perm) ' ' STAT_FOLDER ' '];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
end

%% Back-project into template space (and ultimately native space)
% STAT_FOLDER=$1
% STAT_IMG=$2
% FA_THRESH=$3
% STAT_THRESH=$4
deproj_thresh=0.95;

if deproj_all_bool
    
    stat_img=[num2str(perm) '_tfce_corrp_tstat1'];
    
    
    % First copy mean_FA and all_FA in stat_folder because it is needed
    
    system(['cp ' TBSS_FOLDER filesep 'mean_FA_symmetrised.nii.gz' ' ' STAT_FOLDER ] );
    system(['cp ' TBSS_FOLDER filesep 'mean_FA_symmetrised_skeleton_mask_dst.nii.gz' ' ' STAT_FOLDER ] );
    system(['cp ' TBSS_FOLDER filesep 'all_FA.nii.gz' ' ' STAT_FOLDER ] );
    
    %G1>G2
    scriptR='scripts/tbss_res_deproj_asym.sh';
    argsR=[' ' STAT_FOLDER ' ' stat_img ' ' num2str(fa_thresh) ' ' num2str(deproj_thresh) ' '];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
    
    %G1<G2
    stat_img=[num2str(perm) '_tfce_corrp_tstat2'];
    argsR=[' ' STAT_FOLDER ' ' stat_img ' ' num2str(fa_thresh) ' ' num2str(deproj_thresh) ' '];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
    
    system(['rm ' STAT_FOLDER filesep 'mean_FA_symmetrised.nii.gz'] );
        system(['rm ' STAT_FOLDER filesep 'mean_FA_symmetrised_skeleton_mask_dst.nii.gz'] );
    system(['rm ' STAT_FOLDER filesep 'all_FA.nii.gz'] );
    
end
end

