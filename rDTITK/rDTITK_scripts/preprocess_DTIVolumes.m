function preprocess_DTIVolumes()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% TENSOR_FOLDER=$1
% OUTFOLDER=$2
% DTI_TENSORS=(`ls $TENSOR_FOLDER/*.nii.gz`)
% TENSOR_OUT=$3

%% Manage folders
in_folder=['ScMaps' filesep 'Processed' filesep 'tensor'];
tensor_folder=['DTITK_Template' filesep 'tensor'];
if ~exist(tensor_folder,'dir')
    mkdir(tensor_folder)
end
output_folder=['DTITK_Template' filesep 'pre_output' ];
if ~exist(output_folder,'dir')
    mkdir(output_folder)
end

%% Execute shell script
[~]=system(['cd ' in_folder ';gzip *']);

scriptR = ['..' filesep 'rDTITK_scripts'  filesep 'dtitk_preprocessing.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');

argsR=[' ' in_folder ' ' output_folder ' ' tensor_folder];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');
end

