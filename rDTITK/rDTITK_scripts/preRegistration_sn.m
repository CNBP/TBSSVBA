function preRegistration_sn(regex, model_sbjt,metric )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


% TENSOR_FOLDER=$1
% SUBSET_REGEX=$2
% DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBSET_REGEX`) 
% MODEL=$3
% REG_METRIC=$4
% OUT_FOLDER=$5
% SUBJS_FILENAME=$6


%% Manage folders
tensor_folder=['DTITK_Template' filesep 'tensor'];
output_folder=['DTITK_Template' filesep 'bootstrap' ];
if ~exist(output_folder,'dir')
    mkdir(output_folder)
end

%% Manage Inputs
model_sbjt=[tensor_folder filesep model_sbjt];
subj_filename='subjs.txt';

%% Execute shell script

scriptR = ['..' filesep 'rDTITK_scripts'  filesep 'dtitk_preRegistration.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');


argsR=[' ' tensor_folder ' ' regex ' '  model_sbjt ' ' metric ' ' output_folder ' ' subj_filename];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');
end