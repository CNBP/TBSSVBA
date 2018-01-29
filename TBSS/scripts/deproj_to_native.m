function deproj_to_native( deproj_to_all_image,STAT_FOLDER,NATIVE_IM_FOLDER,TRANS_FOLDER,DEPROJ_FOLDER,reg_bool)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%PROBLEM AVEC QFORM RESOLU DE FACON TEMPORAIRE -> TROUVER UNE SOLUTION PLUS
%ELEGANTE

if ~exist(DEPROJ_FOLDER,'dir')
    mkdir(DEPROJ_FOLDER);
end
%reg_bool : Registration method : 0 = ANTs ; 1= DTITK

all_image_nii=load_nii_gz(deproj_to_all_image);
nii_files=dir(fullfile([NATIVE_IM_FOLDER filesep '*.nii.gz']));

if reg_bool
    %     IM=$1
    %     TRANSFORM_AFF=$2
    %     DF_TRANSFORM=$3
    %     REF=$4
    %     OUTPUTNAME=$5
    mat_transforms=dir(fullfile([TRANS_FOLDER filesep '*_tensor.aff']));
    warps=dir(fullfile([TRANS_FOLDER filesep '*_aff_diffeo.df.nii.gz']));
    scriptR='scripts/tbss_res_deproj_native_dtitk.sh';
    
else
    % IM=$1
    % TRANSFORM_MAT=$2
    % INV_TRANSFORM=$3
    % REF=$4
    % OUTPUTNAME=$5
    mat_transforms=dir(fullfile([TRANS_FOLDER filesep '*.mat']));
    warps=dir(fullfile([TRANS_FOLDER filesep '*InverseWarp.nii.gz']));
    scriptR='scripts/tbss_res_deproj_native_ants.sh';
    
end


for i=1:size(all_image_nii.img,4)
    %% Separate image from 4D image
    indiv_nii=make_nii(all_image_nii.img(:,:,:,i));
    
    name_parts=strsplit(nii_files(i).name,'.');
    
    fileout=[STAT_FOLDER filesep name_parts{1} '_deproj_to_all_im.nii.gz'];
    save_nii_gz(indiv_nii,fileout);
     
    %set qform
    %qform = set_qform( indiv_nii, [4 6 5] )
    %system(['source ~/.bash_profile;fslorient -setqform ' num2str(qform) ' ' fileout]);
    
    
    %% Apply reverse transforms
    
    mat_transform=[TRANS_FOLDER filesep mat_transforms(i).name];
    inverse_warp=[TRANS_FOLDER filesep warps(i).name];
    native_im=[NATIVE_IM_FOLDER filesep nii_files(i).name];
    outputname=[DEPROJ_FOLDER filesep name_parts{1} '_deproj_native.nii.gz'];
    
    argsR=[' ' fileout ' ' mat_transform ' ' inverse_warp ' ' native_im ' ' outputname ];
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
    
    %% clean outputs
    system(['rm ' fileout])
    
    
end




end

