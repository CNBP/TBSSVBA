function scmaps_pre03_rescale(scmapsFolder,newdim)

pathout=strrep(scmapsFolder,'Native','Processed');

if ~exist(['./' pathout],'dir') 
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii'));

for i=1:length(brains)
    [nii] = load_nii([scmapsFolder,filesep,brains(i).name]);
    nii.hdr.dime.pixdim(2:4)=newdim;
    save_nii(nii,[pathout,filesep,brains(i).name]);
end

end