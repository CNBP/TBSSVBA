function scmaps_pre04_orient(scmapsFolder,ori)

pathout=strrep(scmapsFolder,'Native','Processed');

if ~isdir(pathout);
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii'));

for i=1:length(brains)
    
    nii=load_nii([scmapsFolder,filesep,brains(i).name]);
    [new_nii,~]=rri_orient_LA(nii,ori);
    save_nii(new_nii,[pathout,filesep,brains(i).name])
    
end

end