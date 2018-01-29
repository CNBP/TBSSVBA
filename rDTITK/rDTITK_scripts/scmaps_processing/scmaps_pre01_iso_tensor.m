function scmaps_pre01_iso_tensor(scmapsFolder,res,dims)

% NOT RECOMMENDED - as it doesnt respect the interval of values

pathout=strrep(scmapsFolder,'Native','Processed');

if ~exist(['./' pathout],'dir')
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii.gz'));

for i=1:length(brains)
    commandR=['TVResample -in ' scmapsFolder,filesep,brains(i).name ' -out ' [pathout,filesep,brains(i).name] ' -size '  num2str(dims(1)) ' ' num2str(dims(2)) ' ' num2str(dims(3))    ' -vsize ' num2str(res) ' ' num2str(res) ' ' num2str(res) ];
    
    system(['source ~/.bash_profile;' commandR]);
end

end
