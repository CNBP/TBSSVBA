function templateConstruction_server( dataFolder,masksFolder, scriptsFolder )
%templateConstruction Summary of this function goes here
%   Detailed explanation goes here
% 
%% Connect to server
disp('Configuring connection...')
ssh_conn = ssh2_config('64.18.68.105','lakakpo','JeMeSouviens');

%% Check existence and create folders
disp('Installing workspace...')
install_remote_workspace(ssh_conn);

%% Transfer data to server
disp('Transfering data...')
%Scalar maps
trfFiles=dir(fullfile(dataFolder,'*.nii.gz'));
remoteDataPath='rDTIDA/data/scmaps';
for fileno=1:length(trfFiles)
    ssh_conn=scp_put(ssh_conn,trfFiles(fileno).name,remoteDataPath,dataFolder);
end

% Masks : Si la pre registration est faite en local pas besoin de passer
% les masques
% trfFiles=dir(fullfile(masksFolder,'*.nii'));
% remoteMasksPath='rDTIDA/data/masks';
% for fileno=1:length(trfFiles)
%     ssh_conn=scp_put(ssh_conn,trfFiles(fileno).name,remoteMasksPath,masksFolder);
% end

%Scripts
scripts=dir(fullfile(scriptsFolder,'server_*.sh'));
remoteScriptsPath='rDTIDA/scripts';
for fileno=1:length(scripts)
    ssh_conn=scp_put(ssh_conn,scripts(fileno).name,remoteScriptsPath,scriptsFolder);
    ssh_conn=ssh2_command(ssh_conn,['chmod +x ',remoteScriptsPath,filesep,scripts(fileno).name]);
end

%% Create template
disp('starting template construction...')
%Execute script
ssh_conn=ssh2_command(ssh_conn,['./',remoteScriptsPath,filesep,'server_TemplateConstruction.sh']);

%% Close connection
ssh_conn = ssh2_close(ssh_conn);


%% Install local workspace 

mkdir('segmentation/transfos_to_template');
mkdir('segmentation/template');

%% Get results from remote server

%Si tt s'est bien pass� il faut redistribuer les fichiers produts par la
%template construction dans les dossiers en local. Il faut r�cup�rer le
%template et les transfos vers le template. (pas besoin des images warp�es)

end