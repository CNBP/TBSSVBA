function [ output_args ] = project_4D_data( DATA_FOLDER, TBSS_FOLDER, fa_thresh )
%project_4D_data Projects along the fourth dimension
% DATA_FOLDER : Folder containing the multi-dimensional data (4D; tensor, E1, RGB,...) to
% project onto the skeleton

% TBSS_FOLDER : Folder containing the mean_FA, mean_FA_mask,
% mean_FA_skeleton_mask_dst

% The FA pipeline must have been conducted before-hand (at least until the
% skeleton creation)

%%
TEMP_FOLDER=[TBSS_FOLDER filesep 'tmp_div'];

mkdir(TEMP_FOLDER)

files=dir(fullfile([DATA_FOLDER filesep '*.nii.gz']));
%% Separate 4D image into 3D images

fprintf('Extracing 4D Components...\n')
for i=1:length(files)
    fprintf(['\tSubject ' num2str(i) '(/' num2str(length(files)) ')...\n']);
    nii=load_nii_gz([DATA_FOLDER filesep files(i).name]);
    if nii.hdr.dime.dim(1)==5
        %load_nii ne supporte pas le format nifti tensor, la fonction suivante y
        %remedie
        nii=load_tensor_gz_LA([DATA_FOLDER filesep files(i).name]);
    end
    
    for d=1:size(nii.img,4)
        el_img=squeeze(nii.img(:,:,:,d));
        el_nii=make_nii(el_img, nii.hdr.dime.pixdim(2:4));
        
        parts=strsplit(files(i).name,'.');
        basename=parts{1};
        
        save_nii_gz(el_nii,[TEMP_FOLDER filesep basename '_el' num2str(d) '.nii.gz']);
        
    end
end

%% Project each 3D image

% DATA_FOLDER=$1
% TBSS_FOLDER=$2
% REGEX=$3
% THRESH=$4
% ALTIM=$5
parts=strsplit(DATA_FOLDER,'/');

for d=1:size(nii.img,4)
    
    scriptR='scripts/tbss_analyze_nonFAdata.sh';
    argsR=[' ' TEMP_FOLDER ' ' TBSS_FOLDER ' ' ['*' num2str(d) '.nii.gz'] ' ' num2str(fa_thresh) ' ' [parts{end} num2str(d)]];
    
    commandR = [scriptR argsR];
    [~,~] = system(commandR,'-echo');
    
    
end

%% Regroup 4D skeletons into 5D skeleton

OUT_FOLDER=[TBSS_FOLDER filesep '4d_skeletonised'];
mkdir(OUT_FOLDER)

nii_4D_skel=nii;

STAT_FOLDER=[TBSS_FOLDER filesep 'stats_' num2str(fa_thresh)];

system(['gunzip ' STAT_FOLDER filesep 'all_' parts{end} '*_skeletonised*']);
skels=dir(fullfile([STAT_FOLDER filesep 'all_' parts{end} '*_skeletonised.nii']));
sk=load_nii_gz([STAT_FOLDER filesep skels(1).name]);

fprintf('Reassembling individuals 4D skeletons...\n')
%Boucles for non-optimales
for k=1:size(sk.img,4)
        fprintf(['\tSubject ' num2str(k) '(/' num2str(length(files)) ')...\n']);

    out_subj=zeros(size(sk.img,1),size(sk.img,2),size(sk.img,3),size(nii.img,4));
    
    for s=1:size(nii.img,4)
        sk=load_nii([STAT_FOLDER filesep skels(s).name]);
        
        out_subj(:,:,:,s)=sk.img(:,:,:,k);
        
    end
    nii_4D_skel.img=out_subj(:,:,:,:);
    
    save_nii_gz(nii_4D_skel,[OUT_FOLDER filesep 'sjt' num2str(k) '_' parts{end} '_skeletonised.nii.gz']);
end

%%
system(['rm -r ' TEMP_FOLDER]);
system(['rm ' TBSS_FOLDER filesep 'all_' parts{end} '*']);
system(['rm ' STAT_FOLDER filesep 'all_' parts{end} '*']);

end