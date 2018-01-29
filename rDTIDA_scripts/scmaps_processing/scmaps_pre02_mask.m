function excluded_files=scmaps_pre02_mask(scmapsFolder,masksFolder)

pathout=strrep(scmapsFolder,'Native','Processed');

if ~exist(['./' pathout],'dir') 
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii'));

excluded_files=zeros(length(brains)); %contains indexes of files excluded from the study
cnt=0;
for i=1:length(brains)
    
    brainname = brains(i).name;
    idx = strfind(brainname,'_');
    mask = brainname(1:idx-1);
    
    try
        niimask = load_nii([masksFolder,filesep,mask,'_mask.nii']);
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
    
    nii=load_nii([scmapsFolder,filesep,brains(i).name]);
    
    %Verification que le masque et l'image ont la meme resolution
    mask_pixdim = niimask.hdr.dime.pixdim(2:4);
    img_pixdim = nii.hdr.dime.pixdim(2:4);
    
    if ~isequal(mask_pixdim,img_pixdim)
        fprintf(['\t\tIsotropising masks to ' num2str(img_pixdim(1)) '...\n'])
        new_masksFolder=strrep(masksFolder,'Native',['Iso_' num2str(img_pixdim(1))]);
        
        if ~exist([new_masksFolder,filesep,mask,'_mask.nii'],'file');
            if ~exist(['./' new_masksFolder],'dir')
                mkdir(new_masksFolder);
            end
            niimask=change_res_nii([masksFolder,filesep,mask,'_mask.nii'], img_pixdim,'nearest',[new_masksFolder,filesep,mask,'_mask.nii']);
        else
            niimask=load_nii([new_masksFolder,filesep,mask,'_mask.nii']);
        end
    end
    
    
    
    %Application du masque
    id  = (niimask.img==0);
    nii.img(id)=0;
    
    save_nii(nii,[pathout,filesep,brains(i).name]);
    
end
excluded_files = excluded_files(excluded_files~=0); %on supprime les zeros du vecteur
end