function output_study_info_ROI( version,study_name, params_p1, info_p1)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if exist([study_name '_info.txt'],'file')
    study_file=fopen([study_name '_info.txt'],'a');
else
    study_file=fopen([study_name '_info.txt'],'w');
end


fprintf(study_file,['\nPIPELINE VERSION : ' version '\n']);
fprintf(study_file,[date '\n']);

%% PHASE I
if ~isempty(params_p1)
    fprintf(study_file,'\nPHASE I : SCALAR MAPS CREATION\n');
    
    fprintf(study_file,'\nPARAMETERS\n');
    fprintf(study_file,['\tzfill : ' num2str(params_p1.zfill) '\n']);
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
    fprintf(study_file,'\n---------------------------------------------------------------------------\n');

fclose(study_file);
end

