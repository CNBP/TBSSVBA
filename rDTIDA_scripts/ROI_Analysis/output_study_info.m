function output_study_info( version,study_name, params_p1, info_p1,params_p2, info_p2, params_p3, info_p3, params_p4, info_p4 )
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
    fprintf(study_file,['\tTensor Estimation method : ' num2str(params_p1.tensor_est_method) '\n']);
    
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
    fprintf(study_file,['\tRescale : ' num2str(params_p2.rescale) '\n']);
    fprintf(study_file,['\tReorient : ' num2str(params_p2.orient) '\n']);
    fprintf(study_file,['\t\tCurrent orientation : ' str_orient '\n']);
    
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
    
    fprintf(study_file,'\nPHASE III : REGISTRATION AND SEGMENTATION\n');
    
    %III-1 TC
    params_tc=params_p3.tc; %template construction parameters
    info_tc=info_p3.tc;
    
    fprintf(study_file,'\nIII-1 : TEMPLATE CONSTRUCTION\n');
    
    fprintf(study_file,'\nPARAMETERS\n');
    fprintf(study_file,['\tOn Server : ' num2str(params_tc.temp_server) '\n']');
    %if temp_server
    %     fprintf(study_file,['\t\tHostname : ' num2str(hostname) '\n']');
    %     fprintf(study_file,['\t\tUsername : ' num2str(usrname) '\n']');
    %     fprintf(study_file,['\t\tPassword : ' num2str(pswd) '\n']');
    %end
    fprintf(study_file,['\tInitial Rigid Registration : ' num2str(params_tc.init_rig) '\n']');
    if params_tc.init_rig
        fprintf(study_file,['\t\tMETRIC : ' params_tc.metric '\n']');
        fprintf(study_file,['\t\tITERATIONS : ' params_tc.init_rig_it '\n']');
        fprintf(study_file,['\t\tCONVERGENCE : ' params_tc.init_rig_conv '\n']');
    end
    fprintf(study_file,['\tTemplate Update Steps : ' num2str(params_tc.update_it) '\n']');
    fprintf(study_file,['\tRigid\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_tc.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_tc.rig_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_tc.rig_conv '\n']');
    fprintf(study_file,['\tAffine\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_tc.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_tc.aff_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_tc.aff_conv '\n']');
    fprintf(study_file,['\tSyN\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_tc.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_tc.SyN_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_tc.SyN_conv '\n']');
    
    
    
    fprintf(study_file,'\nLOG\n');
    list_cons=info_tc.list_cons;
    fprintf(study_file,['\tFiles used to build template : ' num2str(length(list_cons)) '\n']);
    for i=1:length(list_cons)
        fprintf(study_file,['\t\t ' list_cons(i).name '\n']);
    end
    fprintf(study_file,['\tDuration of phase III-1 : ' datestr(info_tc.dur/86400,'HH:MM:SS.FFF') ' seconds\n']);
    
    %III-2 RT
    params_rt=params_p3.rt;
    info_rt=info_p3.rt;
    
    fprintf(study_file,'\nIII-2 : REGISTRATION TO TEMPLATE\n');
    fprintf(study_file,'\nPARAMETERS\n');
    fprintf(study_file,['\tRigid\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_rt.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_rt.rig_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_rt.rig_conv '\n']');
    fprintf(study_file,['\tAffine\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_rt.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_rt.aff_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_rt.aff_conv '\n']');
    fprintf(study_file,['\tSyN\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_rt.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_rt.SyN_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_rt.SyN_conv '\n']');
    
    fprintf(study_file,'\nLOG\n');
    list_reg=info_rt.list_reg;
    fprintf(study_file,['\tFiles left to register to template : ' num2str(length(list_reg)) '\n']);
    for i=1:length(list_reg)
        fprintf(study_file,['\t\t ' list_reg(i).name '\n']);
    end
    fprintf(study_file,['\tDuration of phase III-2 : ' datestr(info_rt.dur/86400,'HH:MM:SS.FFF') ' seconds\n']);
    
    
    %III-3 RTA
    params_rta=params_p3.rta;
    info_rta=info_p3.rta;
    
    fprintf(study_file,'\nIII-3 : REGISTRATION OF TEMPLATE TO ATLAS\n');
    
    fprintf(study_file,'\nPARAMETERS\n');
    fprintf(study_file,['\tRigid\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_rta.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_rta.rig_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_rta.rig_conv '\n']');
    fprintf(study_file,['\tAffine\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_rta.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_rta.aff_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_rta.aff_conv '\n']');
    fprintf(study_file,['\tSyN\n']');
    fprintf(study_file,['\t\tMETRIC : ' params_rta.metric '\n']');
    fprintf(study_file,['\t\tITERATIONS : ' params_rta.SyN_it '\n']');
    fprintf(study_file,['\t\tCONVERGENCE : ' params_rta.SyN_conv '\n']');
    
    fprintf(study_file,'\nLOG\n');
    fprintf(study_file,['\tAtlas : ' info_rta.atlas '\n']);
    % fprintf(study_file,['\t\tDimensions : ' info_rta.atlas_dim '\n']);
    % fprintf(study_file,['\t\tVoxel Dimensions : ' info_rta.atlas_voxdim '\n']);
    % fprintf(study_file,['\t\tNumber of different regions : ' info_rta.atlas_lbls '\n']);
    fprintf(study_file,['\tTemplate : ' info_rta.template '\n']);
    % fprintf(study_file,['\t\tDimensions : ' info_rta.template_dim '\n']);
    % fprintf(study_file,['\t\tVoxel Dimensions : ' info_rta.template_voxdim '\n']);
    
    fprintf(study_file,['\tDuration of phase III-3 : ' datestr(info_rta.dur/86400,'HH:MM:SS.FFF') ' seconds\n']);
    
    %III-4 SNS
    info_sns=info_p3.sns;
    
    fprintf(study_file,'\nIII-4 : SEGMENTATION IN NATIVE SPACE\n');
    fprintf(study_file,'\nLOG\n');
    fprintf(study_file,['\tDuration of phase III-4 : ' datestr(info_sns.dur/86400,'HH:MM:SS.FFF') ' seconds\n']);
else
    fprintf(study_file,'\nPHASE III : REGISTRATION AND SEGMENTATION\n');
    
    fprintf(study_file,'\nNOT RUN\n');
end
%% PHASE4
if ~isempty(params_p4)
    fprintf(study_file,'\nIV : MORPHOMETRY\n');
    fprintf(study_file,'\nLOG\n');
    fprintf(study_file,['\tFilename : ' info_p4.filename '\n']);
    fprintf(study_file,['\tDuration of phase III-4 : ' datestr(info_p4.dur/86400,'HH:MM:SS.FFF') ' seconds\n']);
else
    fprintf(study_file,'\nIV : MORPHOMETRY\n');
    fprintf(study_file,'\nNOT RUN\n');
end
%%
fclose(study_file);
end

