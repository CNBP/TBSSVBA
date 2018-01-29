function  apply_warps(  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% DATA_FOLDER=$1
% DTI_TENSORS=(`ls $DATA_FOLDER/*.nii.gz`)
% 
% TEMPLATE=$2
% SUBJS_FILENAME=$3
% 
% VOX_SZx=$4
% VOX_SZy=$5
% VOX_SZz=$6
% 


%% Manage folders
in_folder=['DTITK_Template' filesep 'tensor' ];
output_folder=['DTITK_Template' filesep 'postreg_to_template'];
if ~exist(output_folder,'dir')
    mkdir(output_folder)
end

%% Manage Inputs
subset_filename='subjs.txt';
final_template=['DTITK_Template' filesep 'template_construction' filesep 'mean_diffeomorphic_initial6.nii.gz'];

vxl_sz=get_vox(final_template);

%% Execute shell script

scriptR = ['..' filesep 'rDTITK_scripts'  filesep 'dtitk_applyWarps.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');

argsR=[' ' in_folder ' ' final_template ' ' subset_filename ' ' num2str(vxl_sz) ' ' output_folder];
commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

end

function vxl_sz=get_vox(model_sbjt)

    %%%
    %get voxel size and multiply by factor
    [~,str]=system(['source ~/.bash_profile; VolumeInfo ' model_sbjt]);
    st=strfind(str,'voxel size: ');
    endpt=strfind(str,', origin: ');
    temp=str(st+length('voxel size: '):endpt-1);
    temp=strsplit(temp,'x');
    
    S = sprintf('%s*', temp{:});  %MATHWORKS pour cell 2 double
    vxl_sz = sscanf(S, '%f*')';
    
    return
end