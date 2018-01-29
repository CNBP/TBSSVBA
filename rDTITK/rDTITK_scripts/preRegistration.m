function preRegistration(regex, model_sbjt,vox_sample_factors,metric )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


% TENSOR_FOLDER=$1
% SUBSET_REGEX=$2
% DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`) 
% MODEL=$3
% 
% VOX_STEPx=$4
% VOX_STEPy=$5
% VOX_STEPz=$6
% 
% REG_METRIC=$7
% 
% OUT_FOLDER=$8


%% Manage folders
tensor_folder=['DTITK_Template' filesep 'tensor'];
output_folder=['DTITK_Template' filesep 'bootstrap' ];
if ~exist(output_folder,'dir')
    mkdir(output_folder)
end

%% Manage Inputs
model_sbjt=[tensor_folder filesep model_sbjt];
vox_step=get_vox_step(vox_sample_factors,model_sbjt);

%% Execute shell script

scriptR = ['..' filesep 'rDTITK_scripts'  filesep 'dtitk_preRegistration.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');


argsR=[' ' tensor_folder ' ' regex ' '  model_sbjt ' ' num2str(vox_step) ' ' metric ' ' output_folder];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

end

function vox_step=get_vox_step(vox_sample_factors,model_sbjt)

    %%%
    %get voxel size and multiply by factor
    [~,str]=system(['source ~/.bash_profile; VolumeInfo ' model_sbjt]);
    st=strfind(str,'voxel size: ');
    endpt=strfind(str,', origin: ');
    temp=str(st+length('voxel size: '):endpt-1);
    temp=strsplit(temp,'x');
    
    S = sprintf('%s*', temp{:});  %MATHWORKS pour cell 2 double
    vxl_sz = sscanf(S, '%f*')';
    vox_step=vxl_sz.*vox_sample_factors;
    
    return
end