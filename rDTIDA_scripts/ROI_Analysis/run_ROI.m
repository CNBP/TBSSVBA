%% PREPARATION DES FICHIERS POUR LANCER UNE ETUDE
%
% DOSSIER s_XXX : Tout les resultats y seront stock�s
%     DOSSIER Brains : avec les dossiers .fid
%     [DOSSIER Masks : Pour l'etape 2]
%         [DOSSIER Native  : avec les masques d'origines]
%     DOSSIER Atlas : avec l'atlas et sa segmentation

%clear all;clc;
HOMEDIR='/Users/ldealmei/Desktop/Edu/EPM/M.ScA. Biomedical/rDTIDA';
cd(HOMEDIR);
addpath('/Users/ldealmei/Documents/MATLAB/z_nifti')
version ='1.5.ROI';

%-----------------------------------------------------------------
%----------------------------DEBUG--------------------------------
%for debug purposes
P1=1;

%-----------------------------------------------------------------
params_p1 =[];
info_p1 =[];
params_p2 =[];
info_p2 =[];
params_p3  =[];
info_p3 =[];
params_p4 =[];
info_p4 =[];

prompt='Study?\n';
study_name=input(prompt,'s');

cd(study_name)

start_global=tic;

%% PHASE I : SCALAR MAPS CREATION
if P1
    fprintf('PHASE I : SCALAR MAPS CREATION\n');
    
    start_P1=tic;
    
    params_p1=struct; %structure array of parameters for the phase I
    
    %----------------------------------------------------------------------
    %----------------------------Parameters--------------------------------
    %Perhaps not good to use zfill as introduces ripples into image; better to upsample later (in ImageJ)
    prompt='Please enter zfill. Just press Enter if you do not want to zero-fill the data.\n';
    zf=input(prompt);
    zfill=[zf,zf]; %in vivo [128,128] et exvivo [256,256]
    
    params_p1.n4_corr=0;
    params_p1.ec_corr=0;
    params_p1.tensor_est_method=2;
    params_p1.zfill=zf;
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    
    maindir='Brains';
    brains = dir(fullfile(maindir,'*.fid'));
    
    fprintf([num2str(length(brains)) ' folder(s) have been found.\n'])
    
    for i=1:size(brains,1)
        
        fprintf(['\tStarting treatement of ', brains(i).name,'\n'])
        
        fiddir = strcat(maindir,filesep,brains(i).name);
        dwdir=strrep(fiddir,'Brains',['DWVolumes' filesep 'no_corr']);
        dwdir=strrep(dwdir,'.fid','');
        
        fprintf(['SCRIPT EN DVLPT! CONTINUER?'])
        pause
        deriveMaps_CCseg( fiddir, zfill )
        
%         [ud, fid2]=deriveDWVolumes(fiddir,zfill);
%         deriveTensorandScalarMaps_ROI(fiddir,params_p1.tensor_est_method,dwdir,ud,fid2);
        
    end
    dur_P1=toc(start_P1)
    
    info_p1=struct; %structure array contening info relative to the execution of phase I
    info_p1.brains=brains;
    info_p1.dur=dur_P1;
end


%% FIN
dur_global=toc(start_global)


%% Write study info file
output_study_info(version,study_name, params_p1, info_p1,params_p2, info_p2, params_p3, info_p3, params_p4, info_p4 )


