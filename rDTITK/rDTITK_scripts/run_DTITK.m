%% PREPARATION DES FICHIERS POUR LANCER UNE ETUDE
%
% DOSSIER s_XXX : Tout les resultats y seront stock�s
%     DOSSIER Brains : avec les dossiers .fid
%     [DOSSIER Masks : Pour l'etape 2]
%         [DOSSIER Native  : avec les masques d'origines]
%     DOSSIER Atlas : avec l'atlas et sa segmentation

clear ;clc;

mac=1; %debug var
if mac
    HOMEDIR='/Users/ldealmei/Desktop/Edu/EPM/M.ScA. Biomedical/rDTITK';
    cd(HOMEDIR);
    addpath('/Users/ldealmei/Documents/MATLAB/z_nifti')
end

version ='1.0';

%-----------------------------------------------------------------
%----------------------------DEBUG--------------------------------
%for debug purposes
P1=0;
P2=1;
P3_DTITK=0;

%-----------------------------------------------------------------
%for debug purposes : PI
dw_bool=1;
tensor_bool=1;
dotmap_bool=0;
%-----------------------------------------------------------------

params_p1 =[];
info_p1 =[];
params_p2 =[];
info_p2 =[];
params_p3 =[];
info_p3 =[];
if mac
    prompt='Study?';
    study_name=input(prompt,'s');
    
    cd(study_name)
    
end
start_global=tic;
FLAG=0;
diary on
mail_notif=0;
%% PHASE I : SCALAR MAPS CREATION
if P1
    fprintf('PHASE I : SCALAR MAPS CREATION\n');
    
    start_P1=tic;
    
    params_p1=struct; %structure array of parameters for the phase I
    
    %----------------------------------------------------------------------
    %----------------------------Parameters--------------------------------
    prompt='Please enter zfill. Just press Enter if you do not want to zero-fill the data.';
    zf=input(prompt);
    zfill=[zf,zf];
    
    params_p1.zfill=zf;
    params_p1.n4_corr=0;
    params_p1.ec_corr=0;
    params_p1.tensor_est_method=3; % method 3 = method 2 + masquage
    
    params_p1.nii_outlist ={'B0','RAD','FA','MD','L1','residual','tensor','RGB'};
    
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
        
        
        [ud, fid2]=deriveDWVolumes(fiddir,zfill,dw_bool);
        
        
        mask_path=strrep(fiddir,'Brains',['Masks' filesep 'Native']);
        mask_path=strrep(mask_path,'.fid','_mask.nii.gz');
        
        if tensor_bool
            deriveTensorandScalarMaps(fiddir,params_p1.tensor_est_method,ud,fid2,mask_path, params_p1.nii_outlist,dotmap_bool);
        end
    end
    dur_P1=toc(start_P1)
    
    info_p1=struct; %structure array contening info relative to the execution of phase I
    info_p1.brains=brains;
    info_p1.dur=dur_P1;
end
%% PHASE II : SCALAR MAPS PROCESSING
if P2
    fprintf('PHASE II : SCALAR MAPS PROCESSING\n');
    start_P2=tic;
    
    params_p2=struct; %structure array of parameters for the phase II
    
    %----------------------------------------------------------------------
    %----------------------------Parameters--------------------------------
    params_p2.iso=0;
    params_p2.mask=0; %tjs appliquer pr corriger les effets de l'interpolation
    params_p2.rescale=0; %fais buguer pour le tenseur(ptet plus!)
    params_p2.newdim=[0.072 0.072 0.072];
    params_p2.box=0;
    params_p2.orient=1;
    params_p2.interpol_method=0; 
%     0. linear (default)
%     1. nn 
%     2. gaussian [sigma=imageSpacing] [alpha=1.0]
%     3. windowedSinc [type = 'c'osine, 'w'elch, 'b'lackman, 'l'anczos, 'h'amming]
%     4. B-Spline [order=3]
    params_p2.res=0.0729167; %Change selon le zfill!
    params_p2.dims=[184 181 162];
    params_p2.cur_orient=[4 6 5];% in vivo :[4 3 2]; %ex-vivo :[4 6 5]
    %	Element value:	1 - Left to Right; 2 - Posterior to Anterior;
%			3 - Inferior to Superior; 4 - Right to Left;
%			5 - Anterior to Posterior; 6 - Superior to Inferior;
    params_p2.scmap_type={'tensor'};
    
    
    %----------------------------------------------------------------------
    
    params_p2.new_dim=[]; %DO NOT CHANGE!
    low_idxs=[];
    high_idxs=[];
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    for i=1:length(params_p2.scmap_type)
        %Other var
        cur_scmap_type=params_p2.scmap_type{i};
        
        scmaps_folder=['ScMaps' filesep 'Native' filesep cur_scmap_type];
        excluded_files='';
        % Run Steps
        fprintf(['\tTreating  ' cur_scmap_type ' images...\n'])
        
        if params_p2.iso
            fprintf(['\t\tIsotropising maps to a resolution of ' num2str(params_p2.res) ' ...\n'])
            if strcmp(cur_scmap_type,'tensor')
                scmaps_pre01_iso_tensor(scmaps_folder,params_p2.res,params_p2.dims)
            else
            %scmaps_pre01_iso(scmaps_folder,params_p2.res,params_p2.interpol_method)
            %scmaps_pre01_iso_ants(scmaps_folder,params_p2.res,params_p2.interpol_method)
            scmaps_pre01_iso_dtitk(scmaps_folder,params_p2.res,params_p2.dims)
            end
        end
        if params_p2.mask
            fprintf('\t\tMasking files...\n')
            
            excluded_files=scmaps_pre02_mask(scmaps_folder,['Masks' filesep 'Native']);
        end
        if params_p2.rescale
            fprintf('\t\tRescaling by a factor of XXX ...\n')
            scmaps_pre03_rescale(scmaps_folder,params_p2.newdim)
        end
        if params_p2.box
            fprintf('\t\tFinding smallest bounding box ...\n')
            [params_p2.new_dim, low_idxs, high_idxs]= scmaps_pre04_box(scmaps_folder,params_p2.new_dim, low_idxs, high_idxs);
        end
        if params_p2.orient  %must be the last step conducted (problem with qform not being correctly established within MATLAB z_nifti's framework)
            fprintf('\t\tReorienting scalar maps ...\n')
            scmaps_pre05_orient(scmaps_folder,params_p2.cur_orient);
        end
    end
    dur_P2=toc(start_P2)
    
    info_p2=struct; %structure array contening info relative to the execution of phase I
    info_p2.dur=dur_P2;
    info_p2.ex=excluded_files;
    
end
%% PHASE III : DTI-TK PIPELINE
if P3_DTITK
    params_p3=struct; %structure array of parameters for the phase III
    
    params_p3.preprocessing_bool=1;
    params_p3.preRegistration_bool=1;
    params_p3.templateBootstrap_bool=1;
    params_p3.templateConstruction_bool=1;
    params_p3.group_registration_bool=1;
    
    %----------------------------------------------------------------------
    %----------------------------Parameters--------------------------------
    
    %Prereg
    params_p3.regex='*.nii.gz';
    params_p3.model_sbjt='X02_tensor.nii.gz';
    params_p3.vox_sample_factors=[2 2 2];
    params_p3.metric='EDS';
    
    %template bootstrap
    regex_bootstrap='*_tensor_aff.nii.gz';
    %model_sbjt
    
    %template construction
    params_p3.rig_it=3;
    params_p3.aff_it=3;
    params_p3.diffeo_tol=0.002;
    %regex
    %metric
    
    %Other group registration
    params_p3.group_regex='*_tensor.nii.gz';
    %diffeo_tol
    %metric
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    start_P3=tic;
    %Preprocessing
    if params_p3.preprocessing_bool
        fprintf('\n----------------------------------------------------------------------')
        fprintf('\n-----------------------------PREPROCESSING----------------------------')
        fprintf('\n----------------------------------------------------------------------\n\n')
        preprocess_DTIVolumes();
        
    end
    
    %PreRegistration
    if params_p3.preRegistration_bool
        fprintf('\n------------------------------------------------------------------------')
        fprintf('\n-----------------------------PREREGISTRATION----------------------------')
        fprintf('\n------------------------------------------------------------------------\n\n')
        
        preRegistration(params_p3.regex, params_p3.model_sbjt,params_p3.vox_sample_factors,params_p3.metric);
        %preRegistration_sn
    end
    
    %Template Bootstrap
    if params_p3.templateBootstrap_bool
        fprintf('\n--------------------------------------------------------------------------')
        fprintf('\n----------------------------TEMPLATE BOOTSTRAP----------------------------')
        fprintf('\n--------------------------------------------------------------------------\n\n')
        
        template_bootstrap(params_p3.model_sbjt,regex_bootstrap);
        
    end
    
    %Template Construction
    if params_p3.templateConstruction_bool
        fprintf('\n---------------------------------------------------------------------------')
        fprintf('\n----------------------------TEMPLATE CONSTRUCTION--------------------------')
        fprintf('\n---------------------------------------------------------------------------\n\n')
        
        %Change path pour ce script
        cd ('DTITK_Template')
        
        template_construction(params_p3.regex,params_p3.metric,params_p3.rig_it,params_p3.aff_it,params_p3.diffeo_tol);
        
        cd('..')
    end
    %Other Group Registration
    if params_p3.group_registration_bool
        fprintf('\n---------------------------------------------------------------------------')
        fprintf('\n-------------------------------OTHER GROUP REG-----------------------------')
        fprintf('\n---------------------------------------------------------------------------\n\n')
        
        group_registration( params_p3.group_regex,params_p3.metric,params_p3.diffeo_tol );
        apply_warps();
    end
    
    dur_P3=toc(start_P3)
    
    info_p3=struct; %structure array contening info relative to the execution of phase I
    info_p3.dur=dur_P3;
    
end



%% FIN
dur_global=toc(start_global)

diary off

%% Write study info file
output_study_info_DTITK(version,study_name, params_p1, info_p1,params_p2, info_p2,params_p3, info_p3)

clear;