function [ output_args ] = output_tbss_deproj_results( all_fa_path, deproj_stat_path,thresh,outfolder,out_type )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


if ~exist(outfolder,'dir')
    mkdir(outfolder);
end

%% Load data
all_fa=load_nii_gz(all_fa_path);
deproj_stat=load_nii_gz(deproj_stat_path);



%% Loop over images in all_FA and deproj image

for i=1:size(all_fa.img,4)
    
    % output single subject data
    all_fa_3d_tmp=make_nii(squeeze(all_fa.img(:,:,:,i)));
    data_out=[outfolder filesep 'data_tmp.nii.gz'];
    save_nii_gz(all_fa_3d_tmp,data_out);
    
    
    switch out_type
        case 'mosaic'
            % Red-Yellow image
            deproj_stat_rgb=zeros(size(deproj_stat.img,1),size(deproj_stat.img,2),size(deproj_stat.img,3),3);
            mask=squeeze(deproj_stat.img(:,:,:,i)>=thresh);
            
            deproj_stat_rgb(:,:,:,1)=255;
            deproj_stat_rgb(:,:,:,2)=255/(1-thresh)*((squeeze(deproj_stat.img(:,:,:,i)))-thresh);
            deproj_stat_rgb(:,:,:,3)=0;
            
            deproj_stat_rgb(:,:,:,1)=deproj_stat_rgb(:,:,:,1).*mask;
            deproj_stat_rgb(:,:,:,2)=deproj_stat_rgb(:,:,:,2).*mask;
            deproj_stat_rgb(:,:,:,3)=deproj_stat_rgb(:,:,:,3).*mask;
            
            deproj_stat_rgb_nii=make_nii(deproj_stat_rgb,[],[],128);
            
            stat_out=[outfolder filesep 'stat_tmp.nii.gz'];
            save_nii_gz(deproj_stat_rgb_nii,stat_out);
            
            % Pour cadrer l'output sur la zone d'interet
            min_slc=0;
            max_slc=0;
            for k=1:size(mask,2);
                tmp=squeeze(mask(:,k,:))==1;
                if find(tmp)
                    if min_slc==0
                        min_slc=k;
                        break;
                    end
                end
            end
            
            for k=size(mask,2):-1:1;
                tmp=squeeze(mask(:,k,:))==1;
                if find(tmp)
                    if max_slc==0
                        max_slc=k;
                        break;
                    end
                end
            end
            
            sbj=num2str(1000+i);
            output=[outfolder filesep 'subj' sbj(2:end) '.tiff'];
            commandR=['source ~/.bash_profile;CreateTiledMosaic -i ' data_out ' -r ' stat_out ' -a 0.5 -d 1 -s [3,' num2str(min_slc) ',' num2str(max_slc) '] -o ' output];
            system(commandR);
            
        case 'gif'
            stat_3d_tmp=make_nii(squeeze(deproj_stat.img(:,:,:,i)));
            stat_out=[outfolder filesep 'stat_tmp.nii.gz'];
            save_nii_gz(stat_3d_tmp,stat_out);
            
            sbj=num2str(1000+i);
            output=[outfolder filesep 'subj' sbj(2:end) '.gif'];
            nii_to_gif_overlay(data_out,stat_out,output,0.05,'gray','red-yellow',[],[thresh 1])
    end
    
    delete(data_out,stat_out);
    
end




end

