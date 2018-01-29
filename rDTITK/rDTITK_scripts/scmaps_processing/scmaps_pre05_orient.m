function scmaps_pre05_orient(scmapsFolder,ori)

pathout=strrep(scmapsFolder,'Native','Processed');

if ~isdir(pathout);
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii.gz'));

for i=1:length(brains)
    
    nii=load_nii_gz([scmapsFolder,filesep,brains(i).name]);
    
    if nii.hdr.dime.dim(1)==5
        %load_nii ne supporte pas le format nifti tensor, la fonction suivante y
        %remedie
        nii=load_tensor_gz_LA([scmapsFolder,filesep,brains(i).name]);
    end
    
    [new_nii,~]=rri_orient_LA(nii,ori);
    save_nii_gz(new_nii,[pathout,filesep,brains(i).name])
    
    %set qform
    qform = set_qform( nii, orient );
    system(['source ~/.bash_profile;fslorient -setqform ' num2str(qform) ' ' [pathout,filesep,brains(i).name]]);
    
end

end

