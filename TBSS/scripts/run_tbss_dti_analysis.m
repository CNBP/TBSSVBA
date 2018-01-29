function run_tbss_dti_analysis( FA_FOLDER, TBSS_FOLDER,NATIVE_IM_FOLDER, TRANS_FOLDER, fa_thresh,g1,g2,perm)
%run_tbss_dti_analysis Runs classic TBSS analysis
%
%  FA_FOLDER  : folder with co-registered(!) FA images
%  TBSS_FOLDER: folder with all results
%  NATIVE_IM_FOLDER : Folder with images in native space
%  TRANS_FOLDER : Folder with the trasnformations to the template space (InverseWarps and .mat needed)
%  fa_thresh  : fa threshold
%  g1         : number of subjects in group 1
%  g2         : number of subjects in group 2
%  perm       : number of permutation of statistical test

% Luis Akakpo


if ~exist(TBSS_FOLDER,'dir')
    mkdir(TBSS_FOLDER)
end

skel_bool=1;
proj_bool=1;
stat_bool=0;
deproj_all_bool=0;
deproj_native_bool=0;

%% Save call

fileID=fopen([TBSS_FOLDER filesep 'call_params.txt'],'w');

fprintf(fileID,[ 'FA_FOLDER\t: ' FA_FOLDER '\n']);
fprintf(fileID,[ 'TBSS_FOLDER\t: ' TBSS_FOLDER '\n']);
fprintf(fileID,[ 'NATIVE_IM_FOLDER: ' NATIVE_IM_FOLDER '\n']);
fprintf(fileID,[ 'TRANS_FOLDER\t: ' TRANS_FOLDER '\n']);

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
%% Data Projection
% IN_FOLDER=$1
% THRESH=$2
if proj_bool
    scriptR='scripts/tbss_project_FAdata.sh';
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

%% Back-project into template space (and ultimately native space)
% STAT_IM=$1
% THRESH=$2
% OUTFILE=$3

if deproj_all_bool
    % First copy mean_FA and all_FA in stat_folder because it is needed
    
    system(['cp ' TBSS_FOLDER filesep 'mean_FA.nii.gz' ' ' STAT_FOLDER ] );
    system(['cp ' TBSS_FOLDER filesep 'all_FA.nii.gz' ' ' STAT_FOLDER ] );
    
    %G1>G2
    fileout='deproj_stat1';
    stat_img=[num2str(perm) '_tfce_corrp_tstat1'];
    scriptR='scripts/tbss_res_deproj.sh';
    argsR=[' ' STAT_FOLDER ' ' stat_img ' ' num2str(0.95) ' ' fileout ' '];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
    
    if deproj_native_bool
        % To native space
        
        deproj_to_all_image=[STAT_FOLDER filesep fileout '_to_all_FA.nii.gz'];
        out_folder_name=[STAT_FOLDER filesep 'native_' fileout];
        deproj_to_native( deproj_to_all_image,STAT_FOLDER,NATIVE_IM_FOLDER,TRANS_FOLDER,out_folder_name, 0);
        
    end
    
    %G1<G2
    fileout='deproj_stat2';
    stat_img=[ num2str(perm) '_tfce_corrp_tstat2'];
    argsR=[' ' STAT_FOLDER ' ' stat_img ' ' num2str(0.95) ' ' fileout ' '];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
    
    if deproj_native_bool
        % To native space
        
        deproj_to_all_image=[STAT_FOLDER filesep fileout '_to_all_FA.nii.gz'];
        out_folder_name=[STAT_FOLDER filesep 'native_' fileout];
        deproj_to_native( deproj_to_all_image,STAT_FOLDER,NATIVE_IM_FOLDER,TRANS_FOLDER,out_folder_name, 0);
        
    end
    
    system(['rm ' STAT_FOLDER filesep 'mean_FA.nii.gz'] );
    system(['rm ' STAT_FOLDER filesep 'all_FA.nii.gz'] );
    
end

% 
% WARNING='SUPPRIMER LES COMMENTAIRES LIGNES 106 et 123 !!!!!1'
% WARNING='SUPPRIMER LES COMMENTAIRES LIGNES 106 et 123 !!!!!1'
% WARNING='SUPPRIMER LES COMMENTAIRES LIGNES 106 et 123 !!!!!1'

end
