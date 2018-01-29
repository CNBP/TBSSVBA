function scmaps_pre01_iso_ants(scmapsFolder,res,interpolMethod)

% NOT RECOMMENDED - as it doesnt respect the interval of values

pathout=strrep(scmapsFolder,'Native','Processed');

if ~exist(['./' pathout],'dir')
    mkdir(pathout);
else
    scmapsFolder=pathout; %Pour que si d'autres etapes de preprocessing ont deja ete effectuee, celle-ci se fasse a la suite.
end

brains = dir(fullfile(scmapsFolder,'*.nii.gz'));

for i=1:length(brains)
    commandR=['ResampleImage 3 ' scmapsFolder,filesep,brains(i).name ' ' [pathout,filesep,brains(i).name] ' ' num2str(res) 'x' num2str(res) 'x' num2str(res) ' 0 ' num2str(interpolMethod)];
    
    system(['source ~/.bash_profile;' commandR]);
end

end
