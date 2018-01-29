function register_template_to_atlas( atlas,template,reg_to_atlas )
%UNTITLED Register template to Atlas
%   Detailed explanation goes here


% FIXEDIMAGE=$1
% MOVINGIMAGE=$2
% 
% RIG_IT=$3
% RIG_CONV=$4
% 
% AFF_IT=$5
% AFF_CONV=$6
% 
% SyN_IT=$7
% SyN_CONV=$8
% 
% METRIC=${9}
% METRIC_PARAM=${10}


% make script executable
scriptR = ['..' filesep 'Scripts' filesep 'Segmentation' filesep 'Shell_Scripts' filesep 'registerTemplateToAtlas.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');

argsR=[' ' atlas ' ' template ' '...
    reg_to_atlas.rig_it ' ' reg_to_atlas.rig_conv ' '...
    reg_to_atlas.aff_it ' ' reg_to_atlas.aff_conv ' '...
    reg_to_atlas.SyN_it ' ' reg_to_atlas.SyN_conv ' '...
    reg_to_atlas.metric ' ' num2str(reg_to_atlas.metric_param)];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');


end

