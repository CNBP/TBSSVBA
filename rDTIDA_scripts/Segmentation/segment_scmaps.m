function segment_scmaps()
%UNTITLED2 Cree les segmentations de chaque sujet en appliquant inversement les
%transformations mappant chaque sujet sur l'atlas
%   Detailed explanation goes here

%% Applications des transformees inverses
mkdir(['segmentation' filesep 'scmaps_seg'])
%Pour l'instant nous considerons l'image preReg comme destination finale
%pour la segmentation
% SEGMENTATION=$1
% TRANSFORM_MAT_TEMP=$2
% TRANSFROM_MAT_ATLAS=$3
% INV_TRANSFORM_TEMP=$4
% INV_TRANSFORM_ATLAS=$5
% REF=$6

atlas_seg=['Atlas' filesep 'atlas_segmentation_p14.nii'];
temp_mats_folder=['segmentation' filesep 'transfos_to_template'];
atlas_mat=['segmentation' filesep 'template' filesep 'template_to_atlas_0GenericAffine.mat'];
temp_inv_warps_folder=['segmentation' filesep 'transfos_to_template'];
atlas_inv_warp=['segmentation' filesep 'template' filesep 'template_to_atlas_1InverseWarp.nii.gz'];
template=['segmentation' filesep 'template' filesep 'template0.nii.gz'];

scriptA = ['..' filesep 'Scripts' filesep 'Segmentation' filesep 'Shell_Scripts' filesep 'applyTransformToSegmentation.sh'];

commandE = ['chmod +x ' scriptA];
[status,cmdout] = system(commandE,'-echo');

argsA=[' ' atlas_seg ' ' temp_mats_folder ' ' atlas_mat ' ' temp_inv_warps_folder ' ' atlas_inv_warp ' ' template];
commandA = [scriptA argsA];
[status,cmdout] = system(commandA,'-echo');

end

