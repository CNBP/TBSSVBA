function templateConstruction_local(scmap_type,temp_cons_params)
%templateConstruction Summary of this function goes here
%   Detailed explanation goes here
%% Install local workspace

mkdir(['segmentation' filesep 'transfos_to_template']);
mkdir(['segmentation' filesep 'template']);
mkdir(['segmentation' filesep 'template_construction']);


%% Start template construction
% SCMAP_TYPE=$1
% REGEX=$2
% 
% INIT_RIG=$3
% METRIC=$4
% UPDATE_IT=$5
% 
% INIT_RIG_IT=$6
% INIT_RIG_CONV=$7
% 
% RIG_IT=$8
% RIG_CONV=$9
% 
% AFF_IT=${10}
% AFF_CONV=${11}
% 
% SyN_IT=${12}
% SyN_CONV=${13} #NON USED FOR NOW
scriptT = ['..' filesep 'Scripts' filesep 'Segmentation' filesep 'Shell_Scripts' filesep 'local_TemplateConstruction.sh'];

commandE = ['chmod +x ' scriptT];
[status,cmdout] = system(commandE,'-echo');

if strcmp(temp_cons_params.metric,'CC')
       temp_cons_params.metric=[temp_cons_params.metric '[' num2str(temp_cons_params.metric_param) ']'];
end

if temp_cons_params.isdefault
    argT=[' ' scmap_type ' ' temp_cons_params.regex ' ' num2str(temp_cons_params.init_rig) ' ' ...
        temp_cons_params.metric ' ' num2str(temp_cons_params.update_it)];
else
    argT=[' ' scmap_type ' ' temp_cons_params.regex ' ' ...
        num2str(temp_cons_params.init_rig) ' ' temp_cons_params.metric ' '...
        num2str(temp_cons_params.update_it) ' ' ...
        temp_cons_params.init_rig_it ' ' temp_cons_params.init_rig_conv ' ' ...
        temp_cons_params.rig_it ' ' temp_cons_params.rig_conv ' '...
        temp_cons_params.aff_it ' ' temp_cons_params.aff_conv ' '...
        temp_cons_params.SyN_it ' ' temp_cons_params.SyN_conv ];
end

commandT = [scriptT argT];
[status,cmdout] = system(commandT,'-echo');

%% Move files to correct folder
%moving template related files
movefile(['.' filesep 'segmentation' filesep 'template_construction' filesep 'template0.nii.gz'],['.' filesep 'segmentation' filesep 'template']);
movefile(['.' filesep 'segmentation' filesep 'template_construction' filesep 'template0warp.nii.gz'],['.' filesep 'segmentation' filesep 'template'])
movefile(['.' filesep 'segmentation' filesep 'template_construction' filesep 'template0GenericAffine.mat'],['.' filesep 'segmentation' filesep 'template'])

movefile(['.' filesep 'segmentation' filesep 'template_construction' filesep '*.mat'],['.' filesep 'segmentation' filesep 'transfos_to_template']);
movefile(['.' filesep 'segmentation' filesep 'template_construction' filesep '*Warp.nii.gz'],['.' filesep 'segmentation' filesep 'transfos_to_template']);

end