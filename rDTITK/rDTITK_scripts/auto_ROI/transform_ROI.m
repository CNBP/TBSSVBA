function transform_ROI(roi,target,infolder)
%transform_ROI Cree les segmentations de chaque sujet en appliquant inversement les
%transformations mappant chaque sujet sur l'atlas
% Akakpo Luis - 02/02/2016

%% Applications des transformees inverses
roi_folder=[infolder filesep 'roi_native']
mkdir(roi_folder)
%Pour l'instant nous considerons l'image preReg comme destination finale
%pour la segmentation
% ROI=$1
% TRANSFORM_MAT_TEMP=$2
% INV_TRANSFORM_TEMP=$3
% TARGET=$4
% OUTFOLDER = $5


temp_aff_folder=[infolder filesep 'transforms'];
temp_df_field_folder=[infolder filesep 'transforms'];


scriptA = ['rDTITK_scripts' filesep 'auto_ROI' filesep 'dtitk_template_to_native_space.sh'];

commandE = ['chmod +x ' scriptA];
[~,~] = system(commandE,'-echo');

argsA=[' ' roi ' ' temp_aff_folder ' ' temp_df_field_folder  ' ' target ' ' roi_folder];
commandA = [scriptA argsA];
[~,~] = system(commandA,'-echo');

end

