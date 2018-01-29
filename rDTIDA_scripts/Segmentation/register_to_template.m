function  register_to_template(template,reg_to_temp)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% SCMAPSPATH=./ScMaps/Processed/$3
% FIXEDIMAGE=$1
% MOVINGIMAGES=(`ls $SCMAPSPATH/$2`) 
% 
% RIG_IT=$4
% RIG_CONV=$5
% 
% AFF_IT=$6
% AFF_CONV=$7
% 
% SyN_IT=$8
% SyN_CONV=$9
% 
% METRIC=${10}
% METRIC_PARAM=${11}



% make script executable
scriptR = ['..' filesep 'Scripts' filesep 'Segmentation' filesep 'Shell_Scripts' filesep 'registerToTemplate.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');

argsR=[' ' template ' ' reg_to_temp.regex ' ' reg_to_temp.scmap_type ' '...
    reg_to_temp.rig_it ' ' reg_to_temp.rig_conv ' '...
    reg_to_temp.aff_it ' ' reg_to_temp.aff_conv ' '...
    reg_to_temp.SyN_it ' ' reg_to_temp.SyN_conv ' '...
    reg_to_temp.metric ' ' num2str(reg_to_temp.metric_param)];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');


end

