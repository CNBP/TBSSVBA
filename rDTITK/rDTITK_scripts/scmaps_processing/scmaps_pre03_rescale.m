function scmaps_pre03_rescale(scmapsFolder,newdim)

pathout=strrep(scmapsFolder,'Native','Processed');

if ~exist(['./' pathout],'dir')
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii.gz'));

for i=1:length(brains)
    [nii] = load_nii_gz([scmapsFolder,filesep,brains(i).name]);
    
    
    if nii.hdr.dime.dim(1)==5
        %load_nii ne supporte pas le format nifti tensor, la fonction suivante y
        %remedie
        nii=load_tensor_gz_LA([scmapsFolder,filesep,brains(i).name]);
    end
    
    nii.hdr.dime.pixdim(2:4)=newdim;
    save_nii_gz(nii,[pathout,filesep,brains(i).name]);
end

end