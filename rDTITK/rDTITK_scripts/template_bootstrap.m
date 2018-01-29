function template_bootstrap(model_sbjt,regex,new_matrix_sz)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% OUT_FOLDER=$1
% SUBSET_REGEX=$2
% DTI_TENSORS=(`ls $OUT_FOLDER/$SUBSET_REGEX`)
% 
% SUBSET_FILENAME=$3
% 
% SZx=$4
% SZy=$5
% SZz=$6
% 
% VOX_SZx=$7
% VOX_SZy=$8
% VOX_SZz=$9

%% Manage folders
output_folder=['DTITK_Template' filesep 'bootstrap' ];
tensor_folder=['DTITK_Template' filesep 'tensor'];

%% Manage Inputs
subset_filename='bootstrapping_subset.txt';
if nargin==3
    new_vxl_sz=get_vxl_sz(new_matrix_sz,[tensor_folder filesep model_sbjt]);
else
[new_matrix_sz,new_vxl_sz]=get_new_sz([tensor_folder filesep model_sbjt]);
end

%% Execute shell script

scriptR = ['..' filesep 'rDTITK_scripts'  filesep 'dtitk_templateBootstrap.sh'];

commandE = ['chmod +x ' scriptR];
[~,~] = system(commandE,'-echo');

argsR=[' ' output_folder ' ' regex ' ' subset_filename ' ' num2str(new_matrix_sz) ' ' num2str(new_vxl_sz) ];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

end
function new_vxl_sz=get_vxl_sz(new_matrix_sz,model_sbjt)
[~,str]=system(['source ~/.bash_profile; VolumeInfo ' model_sbjt]);

st=strfind(str,'size: ');
endpt=strfind(str,', voxel size: ');
temp=str(st(1)+length('size: '):endpt-1);
temp=strsplit(temp,'x');

S = sprintf('%s*', temp{:});  %MATHWORKS pour cell 2 double
matrix_sz = sscanf(S, '%f*')';
st=strfind(str,'voxel size: ');
endpt=strfind(str,', origin: ');
temp=str(st+length('voxel size: '):endpt-1);
temp=strsplit(temp,'x');

S = sprintf('%s*', temp{:});  %MATHWORKS pour cell 2 double
vxl_sz = sscanf(S, '%f*')';

new_vxl_sz=(vxl_sz.*matrix_sz)./new_matrix_sz;

end

function [new_matrix_sz,new_vxl_sz]=get_new_sz(model_sbjt)
%get image size and find closer higher power of 2
[~,str]=system(['source ~/.bash_profile; VolumeInfo ' model_sbjt]);

%NEW MATRIX SIZE
st=strfind(str,'size: ');
endpt=strfind(str,', voxel size: ');
temp=str(st(1)+length('size: '):endpt-1);
temp=strsplit(temp,'x');

S = sprintf('%s*', temp{:});  %MATHWORKS pour cell 2 double
matrix_sz = sscanf(S, '%f*')';
new_matrix_sz=matrix_sz;
for i=1:length(matrix_sz)
    for p=1:12
        if 2^p >= matrix_sz(i)
            new_matrix_sz(i)=2^p;
            break
        end
    end
end

%NEW VOXEL SIZE
st=strfind(str,'voxel size: ');
endpt=strfind(str,', origin: ');
temp=str(st+length('voxel size: '):endpt-1);
temp=strsplit(temp,'x');

S = sprintf('%s*', temp{:});  %MATHWORKS pour cell 2 double
vxl_sz = sscanf(S, '%f*')';

new_vxl_sz=(vxl_sz.*matrix_sz)./new_matrix_sz;

return
end

