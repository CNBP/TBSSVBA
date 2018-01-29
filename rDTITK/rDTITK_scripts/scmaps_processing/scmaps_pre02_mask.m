function excluded_files=scmaps_pre02_mask(scmapsFolder,masksFolder)

pathout=strrep(scmapsFolder,'Native','Processed');

if ~exist(['./' pathout],'dir')
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii.gz'));

excluded_files=zeros(length(brains)); %contains indexes of files excluded from the study
cnt=0;
for i=1:length(brains)
    
    brainname = brains(i).name;
    idx = strfind(brainname,'_');
    mask = brainname(1:idx-1);
    
    try
        niimask = load_nii_gz([masksFolder,filesep,mask,'_mask.nii.gz']);
    catch
        warning(['Could not find mask for ',brainname, '. Deleting it from analysis...']);
        %To prevent to include that file into the analysis, it is deleted
        %from the Processed folder. The Native folder remains intact
        if strfind(scmapsFolder,'Processed')
            delete([scmapsFolder,filesep,brains(i).name]);
            cnt=cnt+1;
            excluded_files(cnt)=i;
        end
        continue; %jumps to the next iteration
    end
    
    nii=load_nii_gz([scmapsFolder,filesep,brains(i).name]);
    
    %Verification que le masque et l'image ont la meme resolution
    mask_pixdim = niimask.hdr.dime.pixdim(2:4);
    img_pixdim = nii.hdr.dime.pixdim(2:4);
    
    if ~isequal(mask_pixdim,img_pixdim)
        fprintf(['\t\tIsotropising masks to ' num2str(img_pixdim(1)) '...\n'])
        new_masksFolder=strrep(masksFolder,'Native',['Iso_' num2str(img_pixdim(1))]);
        
        if ~exist([new_masksFolder,filesep,mask,'_mask.nii.gz'],'file');
            if ~exist(['./' new_masksFolder],'dir')
                mkdir(new_masksFolder);
            end
            niimask=change_res_nii([masksFolder,filesep,mask,'_mask.nii.gz'], img_pixdim,'nearest',[new_masksFolder,filesep,mask,'_mask.nii']);
        else
            niimask=load_nii_gz([new_masksFolder,filesep,mask,'_mask.nii.gz']);
        end
    end
    
    
    
    %Application du masque
    id  = (niimask.img==0);
    
    if nii.hdr.dime.dim(1)==5
        %load_nii ne supporte pas le format nifti tensor, la fonction suivante y
        %remedie
        nii=load_tensor_gz_LA([scmapsFolder,filesep,brains(i).name]);
    end
    
    
    if nii.hdr.dime.dim(1)==4 || nii.hdr.dime.dim(1)==5
        
        for m=1:size(nii.img,4)
            temp=nii.img(:,:,:,m);
            temp(id)=0;
            
            nii.img(:,:,:,m)=temp;
        end
    else
        nii.img(id)=0;
    end
    save_nii_gz(nii,[pathout,filesep,brains(i).name]);
    
    
end
excluded_files = excluded_files(excluded_files~=0); %on supprime les zeros du vecteur
end