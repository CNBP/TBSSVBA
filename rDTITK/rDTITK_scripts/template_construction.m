function  template_construction(regex,metric,rig_it,aff_it,diffeo_tol)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% TEMPLATE=$1
% TENSOR_FOLDER=$2
% SUBJS_REGEX=$3
% DTI_TENSORS=(`ls $TENSOR_FOLDER/$SUBJS_REGEX`)
% SUBJS_FILENAME=$4
% 
% TRANSFO_FOLDER=$5
% CONSTRUCTION_FOLDER=$6
% REGISTERED_FOLDER=$7
% 
% METRIC=$8
% RIG_IT=$9
% AFF_IT=${10}
% DIFF_TOL=${11}

%% Manage Folders
tensor_folder='tensor';
bootstrap_folder='bootstrap';

transfo_folder='transforms';
construction_folder='template_construction';
registered_im_folder=[construction_folder filesep 'registered'];

if ~exist(transfo_folder,'dir')
    mkdir(transfo_folder)
end
if ~exist(construction_folder,'dir')
    mkdir(construction_folder)
end
if ~exist(registered_im_folder,'dir')
    mkdir(registered_im_folder)
end

%% Manage Inputs
template=[bootstrap_folder filesep 'mean_initial.nii.gz'];
subj_filename='subjs.txt';

%% Execute shell script
scriptR = ['..' filesep '..' filesep 'rDTITK_scripts'  filesep 'dtitk_templateConstruction.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');


argsR=[' ' template ' ' tensor_folder ' ' regex ' ' subj_filename ' ' transfo_folder ' ' construction_folder ' ' registered_im_folder ' ' metric ' ' num2str(rig_it) ' ' num2str(aff_it) ' ' num2str(diffeo_tol)];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');
end

