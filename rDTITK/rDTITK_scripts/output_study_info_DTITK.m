function output_study_info_DTITK( version,study_name, params_p1, info_p1,params_p2, info_p2, params_p3, info_p3, params_p4, info_p4 )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

study_file=fopen([study_name '_info.txt'],'w');

fprintf(study_file,['\nPIPELINE VERSION : ' version '\n']);
fprintf(study_file,[date '\n']);

%% PHASE I
if ~isempty(params_p1)
    fprintf(study_file,'\nPHASE I : SCALAR MAPS CREATION\n');
    
    fprintf(study_file,'\nPARAMETERS\n');
    fprintf(study_file,['\tZero-filling : ' num2str(params_p1.zfill) '\n']);
    fprintf(study_file,['\tN4 Correction : ' num2str(params_p1.n4_corr) '\n']);
    fprintf(study_file,['\tEddy-Currents Correction : ' num2str(params_p1.ec_corr) '\n']);
    if params_p1.tensor_est_method==3
        fprintf(study_file,['\tTensor Estimation method : ' num2str(params_p1.tensor_est_method) ' (includes masking)\n']);
    else
        fprintf(study_file,['\tTensor Estimation method : ' num2str(params_p1.tensor_est_method) '\n']);
    end
    
    fprintf(study_file,'\tNifti Outputs : ');
    for i=1:length(params_p1.nii_outlist)
        fprintf(study_file, upper(cell2mat(params_p1.nii_outlist(i))));
        if i<length(params_p1.nii_outlist)
            fprintf(study_file,' - ');
        end
    end
    fprintf(study_file,'\n');
    
    brains=info_p1.brains;
    dur_P1=info_p1.dur;
    
    fprintf(study_file,'\nLOG\n');
    fprintf(study_file,['\t# files : ' num2str(length(brains)) '\n']);
    for i=1:length(brains)
        fprintf(study_file,['\t\t' brains(i).name '\n']);
    end
    fprintf(study_file,['\tDuration of phase I : ' datestr(dur_P1/86400,'HH:MM:SS.FFF')  '\n']);
else
    fprintf(study_file,'\nPHASE I : SCALAR MAPS CREATION\n');
    fprintf(study_file,'\nNOT RUN\n');
end
%% PHASE II
%	Element value:	1 - Left to Right; 2 - Posterior to Anterior;
%			3 - Inferior to Superior; 4 - Right to Left;
%			5 - Anterior to Posterior; 6 - Superior to Inferior;
if ~isempty(params_p2)
    str_orient=['' '' ''];
    for i=1:length(params_p2.cur_orient)
        switch params_p2.cur_orient(i)
            case 1
                str_orient(i)='L';
            case 2
                str_orient(i)='P';
            case 3
                str_orient(i)='I';
            case 4
                str_orient(i)='R';
            case 5
                str_orient(i)='A';
            case 6
                str_orient(i)='S';
        end
    end
    
    fprintf(study_file,'\nPHASE II : SCALAR MAPS PROCESSING\n');
    fprintf(study_file,'\nPARAMETERS\n');
    fprintf(study_file,['\tFile Type : ']);
    
    for i=1:length(params_p2.scmap_type)
        fprintf(study_file, cell2mat(params_p2.scmap_type(i)) );
        if i<length(params_p2.scmap_type)
            fprintf(study_file,' - ');
        end
    end
    
    fprintf(study_file,'\n');
    fprintf(study_file,['\tIsotropisation : ' num2str(params_p2.iso) '\n']);
    if(params_p2.iso)
        fprintf(study_file,['\t\tNew voxel dimension : ' num2str(params_p2.res) '\n']);
        fprintf(study_file,['\t\tInterpolation Method : ' num2str(params_p2.interpol_method) '\n']);
    end
    fprintf(study_file,['\tMask : ' num2str(params_p2.mask) '\n']);
    fprintf(study_file,['\tReorient : ' num2str(params_p2.orient) '\n']);
    fprintf(study_file,['\t\tCurrent orientation : ' str_orient '\n']);
    fprintf(study_file,['\tSmallest bounding box : ' num2str(params_p2.box) '\n']);
    fprintf(study_file,['\t\tNew dimension  : ' num2str(params_p2.new_dim) '\n']);
    
    
    fprintf(study_file,'\nLOG\n');
    
    ex=info_p2.ex; %idxs of deleted files in the var 'brains'
    cnt=length(ex);
    
    fprintf(study_file,['\t# Files taken out of the study : ' num2str(cnt) '\n']);
    for i=1:cnt
        fprintf(study_file,['\t\t' brains(ex(i)).name ' : No mask available\n']);
    end
    
    
    fprintf(study_file,['\tDuration of phase II : ' datestr(info_p2.dur/86400,'HH:MM:SS.FFF') ' seconds\n']);
else
    fprintf(study_file,'\nPHASE II : SCALAR MAPS PROCESSING\n');
    fprintf(study_file,'\nNOT RUN\n');
end
%% PHASE III
if ~isempty(params_p3)
    
    fprintf(study_file,'\nPHASE III : DTITK REGISTRATION AND SEGMENTATION\n');
    
    %III-1 Preprocessing
    
    if params_p3.preprocessing_bool
        fprintf(study_file,'\nPRE-PROCESSING \n');
    end
    
    if params_p3.preRegistration_bool
        fprintf(study_file,'\nPRE-REGISTRATION \n');
        
        fprintf(study_file,['\tFiles : ' params_p3.regex '\n']');
        fprintf(study_file,['\tTarget : ' params_p3.model_sbjt '\n']');
        fprintf(study_file,['\tVoxel step : ' num2str(params_p3.vox_sample_factors) '\n']');
        fprintf(study_file,['\tMetric : ' params_p3.metric '\n']');
        
    end
    
    if params_p3.templateBootstrap_bool
        fprintf(study_file,'\nTEMPLATE BOOTSTRAP \n');
        fprintf(study_file,['\tTarget : ' params_p3.model_sbjt '\n']');
        
    end
    
    if params_p3.templateConstruction_bool
        fprintf(study_file,'\nTEMPLATE CONSTRUCTION \n');
        fprintf(study_file,['\tFiles : ' params_p3.regex '\n']');
        fprintf(study_file,['\tMetric : ' params_p3.metric '\n']');
        fprintf(study_file,['\t# Rigid iterations : ' num2str(params_p3.rig_it) '\n']');
        fprintf(study_file,['\t# Affine iterations : ' num2str(params_p3.aff_it) '\n']');
        fprintf(study_file,['\tDiffeomorphic tolerance threshold : ' num2str(params_p3.diffeo_tol) '\n']');
    end
    
    if params_p3.group_registration_bool
        fprintf(study_file,'\nOTHER GROUP REG \n');
        fprintf(study_file,['\tFiles : ' params_p3.group_regex '\n']');
        fprintf(study_file,['\tMetric : ' params_p3.metric '\n']');
        fprintf(study_file,['\tDiffeomorphic tolerance threshold : ' num2str(params_p3.diffeo_tol) '\n']');
    end
    
    %%
    fclose(study_file);
end

