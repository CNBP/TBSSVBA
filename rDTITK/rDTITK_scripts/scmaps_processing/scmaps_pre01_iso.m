function scmaps_pre01_iso(scmapsFolder,res,interpolMethod)

% NOT RECOMMENDED - as it doesnt respect the interval of values

pathout=strrep(scmapsFolder,'Native','Processed');

if ~exist(['./' pathout],'dir')
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii.gz'));

for i=1:length(brains)
    change_res_nii([scmapsFolder,filesep,brains(i).name], [res res res], interpolMethod,[pathout,filesep,brains(i).name] );
end
end
