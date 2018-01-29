function auto_ROI(roi,infolder,target)
% Back-projects ROIs delineated on a template to the subjects registered to
% that same template using the inverse transforms. Then displays the
% results of the measures in these ROIs according to the user specified
% classification of the subjects (group comparison).

%ATTENTION SCRIPTS NON MODULABLES AUTOMATIQUEMENT POUR PLUS DE GROUPES, IL
%FAUT MODIFIER LE CODE
%addpath('/Users/ldealmei/Documents/MATLAB/z_nifti')

%% USER PARAMETERS

% GROUPS
name_gr={'CTL','LPS'};
gr_list{1}={'SALI02','SALI04','SALK01','SALK02','SALK04','SALK05','SALK06','SALL01','SALL02','SALL03','SALL04'};
gr_list{2}={'LPSI07','LPSI09','LPSI10','LPSJ02','LPSJ04','LPSJ05','LPSJ06','LPSJ07','LPSL05','LPSL07','LPSL08'};
nbr_gr=length(name_gr);

im_types={'FA','RAD','MD','L1'}; %B0

alpha =0.05;

template_roi_nii=load_nii(roi);
csv_outputfolder = 'results';
if ~exist(csv_outputfolder)
    mkdir(csv_outputfolder)
end

do_back_transform=1;
get_res=0;
do_stats=0;
%% run auto_ROI

nbr_roi=1:max(max(max(template_roi_nii.img)));
if do_back_transform
    transform_ROI(roi,target,infolder);
end
if get_res
    struct_ROI_res=struct_ROI_data(name_gr,gr_list,im_types,nbr_roi);
    
    output_roi_to_csv(csv_outputfolder,struct_ROI_res,nbr_roi,im_types,nbr_gr)
    
    display_results(struct_ROI_res, name_gr, im_types, nbr_roi);
end
if do_stats
    stats_tests( struct_ROI_res , name_gr, im_types, nbr_roi , alpha )
end

end


