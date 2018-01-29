function group_registration( group_regex,metric,dif_ftol )
%UNTITLED4 Summary of this function goes here
% %   Detailed explanation goes here
% 
% TENSOR_FOLDER=$1
% SUBSET_REGEX=$2
% DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`)
% 
% TEMPLATE=$3
% SUBJS_FILENAME=$4
% MASK=$5
% REG_METRIC=$6
% DIF_FTOL=$7

%
%% Manage Folders
tensor_folder=['DTITK_Template' filesep 'tensor'];

%% Manage Inputs
final_template=['DTITK_Template' filesep 'template_construction' filesep 'mean_diffeomorphic_initial6.nii.gz'];
subj_filename='postreg_subjs.txt';
mask=['DTITK_Template' filesep 'template_construction' filesep 'mask.nii.gz'];

%% Execute shell script
scriptR = ['..' filesep 'rDTITK_scripts'  filesep 'dtitk_groupRegistration_sn.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');

argsR=[' ' tensor_folder ' ' group_regex  ' ' final_template ' ' subj_filename ' ' mask ' ' metric ' ' num2str(dif_ftol)];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

end

