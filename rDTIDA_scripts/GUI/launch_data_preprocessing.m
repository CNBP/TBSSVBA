function launch_data_preprocessing(fiddir,zfill,method,N4_bool,EC_bool,scmaps_bool)
%launch_data_preprocessing Runs the steps of the raw data preprocessing
%   Detailed explanation goes here
fiddir
zfill
method
N4_bool
EC_bool
scmaps_bool

%DWFolder = deriveDWVolumes(fiddir,zfill);

if N4_bool
    disp('Correcting field inhomogeneities...')
    %fieldInhomogeneityCorrection(DWFolder,maskfile);
end

if EC_bool
    disp('Correcting Eddy Currents and motion artifacts...')
    %ECandMotionCorrection();
end

if scmaps_bool
    disp('Estimating Tensor and deriving scalar maps...')
    %deriveTensorandScalarMaps(fiddir,zfill,method,DWFolder);
end


