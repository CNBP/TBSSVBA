function run_vbm_dti_analysis( FA_FOLDER,template_file,fwhm,g1,g2,perm,VBM_FOLDER )
%run_vbm_dti_analysis Runs Voxel-based Morphometry style analysis

% FA_FOLDER     : folder with co-registered FA images
% template_file : template image to which images are coregistered (for masking artefacts, might be not always useful)
% fwhm          : Gaussian filtering fwhm vector [ d1 d2 d3 ]
% g1            : number of subjects in group 1
% g2            : number of subjects in group 2
% perm          : number of permutation of statistical test
% VBM_FOLDER    : folder for results output

if ~exist(VBM_FOLDER,'dir')
    mkdir(VBM_FOLDER)
end

diary([VBM_FOLDER filesep 'diary.txt'])
diary on

%%
fa_imgs = dir(fullfile(FA_FOLDER,'*.nii.gz'));

template=load_nii_gz(template_file);


%% save call parameters to file
fileID=fopen([VBM_FOLDER filesep 'call_params.txt'],'w');

fprintf(fileID,[ 'FA_FOLDER\t: ' FA_FOLDER '\n']);
fprintf(fileID,[ 'template_file\t: ' template_file '\n']);
fprintf(fileID,[ 'fwhm\t\t: ' num2str(fwhm) '\n']);
fprintf(fileID,[ 'g1\t\t: ' num2str(g1) '\n']);
fprintf(fileID,[ 'g2\t\t: ' num2str(g2) '\n']);
fprintf(fileID,[ 'perm\t\t: ' num2str(perm) '\n']);
fprintf(fileID,[ 'VBM_FOLDER\t: ' VBM_FOLDER '\n']);


fclose(fileID);
%% Smooth images and  Create 4D image (images will be appended in alphabetical order)

img_all=zeros(length(template.img(:,1,1)),length(template.img(1,:,1)),length(template.img(1,1,:)),length(fa_imgs));
%erreur avec la fonction size que je ne comprends pas -> raccourci avec
%length

copyfile(FA_FOLDER,[FA_FOLDER '_smooth'])

for i=1:length(fa_imgs)
    img_smooth=gaussian_smooth_dtitk_tools([FA_FOLDER '_smooth' filesep fa_imgs(i).name],fwhm);
    
    %     img_smooth=gaussian_smooth_nii([FA_FOLDER filesep fa_imgs(i).name], size, sd ,0);
    img_all(:,:,:,i)=img_smooth;
    
end

img_all_nii=template; %copie header et tt..
img_all_nii.img=img_all;

img_all_nii.hdr.dime.dim(1)=4;
img_all_nii.hdr.dime.dim(5)=length(fa_imgs);

fileout=[VBM_FOLDER filesep 'vbm_fa_all.nii.gz'];
save_nii_gz(img_all_nii,fileout);
%% Derive mask
min_img=min(img_all,[],4);
mask=min_img>0;
mask_nii=template;
mask_nii.img=mask;

fileout_mask=[ VBM_FOLDER filesep 'whole_brain_mask.nii.gz'];
save_nii_gz(mask_nii,fileout_mask);


%% Carry out voxel wise statistics
% IMG_ALL=$1
% MASK=$2
% DESIGN_G1_SZ=$3
% DESIGN_G2_SZ=$4
% PERMUTATIONS=$5
% OUT_FOLDER=$6

scriptR='scripts/vbm_randomise.sh';
argsR=[' ' fileout ' ' fileout_mask ' ' num2str(g1) ' ' num2str(g2) ' ' num2str(perm) ' ' VBM_FOLDER ' '];

commandR = [scriptR argsR];
[~,~] = system(commandR,'-echo');

%%
diary off
end

