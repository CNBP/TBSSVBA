function deriveMaps_CCseg( fiddir, zfill )
% deriveMaps.m
% Luis Akakpo, Ecole Polytechnique de Montreal nov 2015.
%
% USAGE:
% deriveMaps(fiddir, zfill);
%
%
% DESCRIPTION:
% Creates .map folder which enables viewing of DTI maps and RGB map on
% ImageJ as well as the .nii images.
%
% INPUTS:
% fiddir  = filename of Varian .fid data to load.
% zfill = zerofilling of data. Ex : zfill=[128,128]; 2^N for a good RGB
% construction using BMRL ImageJ routines
%
% REFERENCES :
% - BMRL routines
% - rDTIDA - Luis Akakpo 2015
%% Initialisation de variables et de paths
if (nargin < 1 || isempty(fiddir))
    fiddir = pwd;
end

fidfile = strcat(fiddir,filesep,'fid');

if ~exist(fidfile,'file')
    error('%s could not be found, check paths');
end

[pathtobrains, fidname] = fileparts(fiddir);

method=2;
datdirname = [fidname '_vnmrj' '_algorithm' num2str(method) '.map'];

pathout = strrep(pathtobrains,'Brains','dotMap');
% if ~isdir(pathout);
%     mkdir(pathout);
% end
datdir = fullfile(pathout,datdirname);

%% Lecture du fichier procpar et initialisation de parametres (ud)
procparfile = strcat(fiddir,filesep,'procpar');

ud = readprocpar(procparfile);
ud.G = [ud.dpe;ud.dro;ud.dsl]';

ud.diffdirs = size(ud.G,1);

if nargin < 2 || isempty(zfill)
    ud.fn = ud.np/2;
    ud.fn1 = ud.nv;
else %Perhaps not good to use zfill as introduces ripples into image; better to upsample later (in ImageJ)
    ud.fn = zfill(1);
    ud.fn1= zfill(2);
    try ud.fn2 = zfill(3);catch; end %if 3D data
end

% sort bmatrices by b-value, data gets sorted later
[ud.sliceorder, ud.orderIndex] = sort(ud.pss);

if (size(ud.bvalss,2)>1)
    fprintf('\tUsing VnmrJ derived b-matrix...\n');
    [ud.sortedb,ud.bsortorder] = sort(ud.bvalue);
    ud.bmat = zeros(3,3,size(ud.bvalue,2));
    ud.bmat(1,1,:) = ud.bvalpp(ud.bsortorder);
    ud.bmat(1,2,:) = ud.bvalrp(ud.bsortorder);
    ud.bmat(1,3,:) = ud.bvalsp(ud.bsortorder);
    ud.bmat(2,1,:) = ud.bmat(1,2,:);
    ud.bmat(2,2,:) = ud.bvalrr(ud.bsortorder);
    ud.bmat(2,3,:) = ud.bvalrs(ud.bsortorder);
    ud.bmat(3,1,:) = ud.bmat(1,3,:);
    ud.bmat(3,2,:) = ud.bmat(2,3,:);
    ud.bmat(3,3,:) = ud.bvalss(ud.bsortorder);
    ud.diffdirs = size(ud.bvalue,2);
    ud.bvalue = ud.bvalue./1000;
    ud.bmat = ud.bmat./1000;
else
    fprintf('\tUsing b-matrix Computed from dsl,dro,dpe & gdiff...\n');
    [ud.sortedb,ud.bsortorder] = sort(ud.G(:,1).^2 + ud.G(:,2).^2 + ud.G(:,3).^2);
    % Units here are the gradients in G/cm, the gyromagnetic ratio in
    % rad*MHz/T, and the timings in seconds.
    %[ud.bmat] = dtiGradientsToBMatrices((diag(ud.gdiff)*ud.G(ud.bsortorder,:)).',2*pi*42.58,0,ud.tdelta,ud.tDELTA)/10;
    [ud.bmat] = dtiGradientsToBMatrices((diag(ud.gdiff)*ud.G(ud.bsortorder,:)).',2*pi*42.58,1.25e-4,ud.tdelta,ud.tDELTA)/10;
    
end

%% Get k-space data (fid2)
% Data structure varies depending on the sequence, the strucure has been
% identified for two sequences. If sequence is different, check structure by debugging
% Let's determine sequence
textfile=strcat(fiddir,filesep,'text');
SEQ=textread(textfile,'%s','delimiter','\n');

if strcmp(SEQ,'Diffusion Weighted (dual) Spin-echo Multi-slice Imaging sequence') || strcmp(SEQ,'Localized single voxel spectroscopy with LASER selection') %for lysosome preli test

    load_fidfile=fastloadj(fidfile);
    reshape_fidfile=reshape(load_fidfile,ud.np/2,ud.ns,ud.nv,ud.diffdirs);
    fid2 = permute(reshape_fidfile,[1 3 2 4]);
    
elseif strcmp(SEQ,'Spin-echo Multi-slice Imaging sequence')
    load_fidfile=fastloadj(fidfile);
    perm_fidfile = permute(load_fidfile,[1 3 2]); %192x(128x31)x72 complex double; donc l'acquisition de la machine, avec les 31 directions
    reshape_fidfile=reshape(perm_fidfile,ud.np/2,ud.diffdirs,ud.nv,ud.ns);
    %reshape_fidfile=reshape(load_fidfile,ud.np/2,ud.diffdirs,ud.nv,ud.ns);
    fid2 = permute(reshape_fidfile,[1 3 4 2]);
else
    error('Sequence is not recognized. Please complete script to take this new sequence in charge');
end

fid2 = fid2(:,:,ud.orderIndex,:); %fid2 est un "4D complex double"


%% read information from fid header (mainHdr)
fp=fopen(fidfile,'r','ieee-be');
mainHdr.nblocks = fread( fp, 1, 'int32');
mainHdr.ntraces = fread( fp, 1, 'int32');
mainHdr.np = fread( fp, 1, 'int32');
mainHdr.ebytes = fread( fp, 1, 'int32');
mainHdr.tbytes = fread( fp, 1, 'int32');
mainHdr.bbytes = fread( fp, 1, 'int32');
mainHdr.transf = fread( fp, 1, 'int16');
mainHdr.status = fread( fp, 1, 'int16');
statusbits = dec2bin(mainHdr.status,8);
% check if data is stored as int32 (vnmr) or float (vnmrj)
if str2num(statusbits(5))==1
    precision = 'float';
else
    precision = 'int32';
end

mainHdr.spare1 = fread( fp, 1, 'int32');
mainHdr.file_head = 32;
mainHdr.block_head = 28;
mainHdr.blocksize = mainHdr.ntraces*mainHdr.tbytes + mainHdr.block_head;
ud.mainHdrSize = 32;

fclose(fp); % close fid file

%% create .map sub-directories to save data
warning('off','all')
if (~mkdir(pathout,datdirname))
    error('Could not create data directory, check permissions');
end
%create the raw dwi directories
for jj = 1:ud.ns
    dirname = num2str(100+jj);
    status = mkdir(datdir,strcat('slc_',dirname(2:3)));
end
% create the calculated tensor directories
status=mkdir(datdir,'fdfs_tensor');
warning('on','all')
fdfdir = fullfile(datdir,'fdfs_tensor');

outlist = {'eigen1','eigen2','eigen3','rad','ra','tr','v1x','v1y','v1z','v2x','v2y','v2z','v3x','v3y','v3z','validity','residual'};
nii_outlist = {'B0','rad','fa','md','eigen1'};

warning('off','all')

for jj = 1:size(outlist,2)
    status = mkdir(fdfdir,strcat(outlist{jj},'.dat'));
end
warning('on','all')

%% Initialise imgs

img_FA = zeros(ud.fn1,ud.fn,size(fid2,3));
img_eigen1 = zeros(ud.fn1,ud.fn,size(fid2,3));
img_eigvec1  = zeros(ud.fn1,ud.fn,size(fid2,3),3);
img_RAD =  zeros(ud.fn1,ud.fn,size(fid2,3));
img_MD =  zeros(ud.fn1,ud.fn,size(fid2,3));
img_B0 =   zeros(ud.fn1,ud.fn,size(fid2,3));

%% Repositionnement a l'origine (LA)
%Phase-Encode direction

rpe = ud.lpe / ud.fn1 ; %Resolution dans la direction phase-encode
decalage_axsag = ud.ppe/rpe; %Decalage selon l'axe sagital

if decalage_axsag>=0
    decalage_axsag=round(decalage_axsag);
else
    decalage_axsag= round(ud.fn1 + decalage_axsag);
end
rearrang_sag = [decalage_axsag+1:ud.fn1,1:decalage_axsag];

%% Calcul B0 et tenseur
fprintf('\tCalculating tensor...\n')

for sliceno = 1:ud.ns
    fprintf(['\t\tSlice ' num2str(sliceno) '...\n'])
    
    fid = fid2(:,:,sliceno,:);
    
    dtiImages = fftshift(fftshift(fft2(fid,ud.fn,ud.fn1),1),2);
    dtiImages = dtiImages(:,rearrang_sag,:);
    
    for k=1:ud.diffdirs
        
        dirnum = find(ud.sliceorder==ud.pss(sliceno));
        dirname = num2str(100+dirnum);
        
        tmp22 = abs(dtiImages(:,:,k));
        
        % ORIENTATION A MODIFIER SELON L'ETUDE!
        %tmp22 = flipud(tmp22); %exvivo
        tmp22 = rot90(tmp22,2)';
        
        filenum = num2str(100+k);
        filename = strcat(datdir,filesep,'slc_',dirname(2:3),filesep,'image',filenum(2:3),'.fdf');
        f=fopen(filename,'w','ieee-be');
        fhead = makeFDFheader(ud,dirnum,k);
        fwrite(f,fhead,'uint8');
        fwrite(f,tmp22,'float');
        fclose(f);
    end
    
    % sort the data by b-value
    dtiImages = dtiImages(:,:,ud.bsortorder);
    
    %% Calcul des tenseurs
    switch method
        case 0
            b0Image = mean(dtiImages(:,:,1:ud.nbzero),3);
            dtiImages = dtiImages(:,:,(ud.nbzero+1):end);
            b0Matrix  = ud.bmat(:,:,1);
            b2Matrices = ud.bmat(:,:,(ud.nbzero+1):end);
            for index1 = 1:ud.diffdirs-ud.nbzero
                b2Matrices(:,:,index1) = b2Matrices(:,:,index1)-b0Matrix;
            end
            [lambdas,eigenVectors,residualImage] = dtiLeastSquares2(b0Image, permute(dtiImages(:,:,:),[3 1 2]), b2Matrices);
        case 1
            b0Image = mean(dtiImages(:,:,1:ud.nbzero),3);
            dtiImages = dtiImages(:,:,(ud.nbzero+1):end);
            b0Matrix  = ud.bmat(:,:,1);
            b2Matrices = ud.bmat(:,:,(ud.nbzero+1):end);
            for index1 = 1:ud.diffdirs-ud.nbzero
                b2Matrices(:,:,index1) = b2Matrices(:,:,index1)-b0Matrix;
            end
            [lambdas, eigenVectors,residualImage] = dtiLeastSquaresW(b0Image, permute(dtiImages(:,:,:),[3 1 2]), b2Matrices);
        case 2 %not updated for multiple nbzero values
            [lambdas, eigenVectors,residualImage] = dtiLeastSquaresW2(permute(dtiImages(:,:,:),[3 1 2]), ud.bmat);
    end
    lambdas = lambdas.*(lambdas>=0);
    

%% --------------Section Developement---------------

% DISPLAY
% L1
l1 = squeeze(lambdas(1,:,:));
l1 = fliplr(l1);
l1 = flipud(l1); %invivo
subplot(1,2,1)
imshow(l1,[])
%FA
meandiff = mean(lambdas,1);
tmp22 = sqrt(3*((lambdas(1,:,:)-meandiff).^2 + (lambdas(2,:,:)-meandiff).^2 + (lambdas(3,:,:)-meandiff).^2))...
    ./sqrt(2*(lambdas(1,:,:).^2 +lambdas(2,:,:).^2 +lambdas(3,:,:).^2));
tmp22(~isfinite(meandiff)) = 0;
tmp22(lambdas(3,:,:)<0) = 0;
fa = squeeze(tmp22);
fa = fliplr(fa);
fa = flipud(fa); %invivo
subplot(1,2,2)
imshow(fa,[])

%% TRAITEMENT

U=eigenVectors(1,1,:,:);
V=eigenVectors(2,1,:,:);
W=eigenVectors(3,1,:,:); 

U=squeeze(U);
V=squeeze(V);
W=squeeze(W);

S=abs(U)+abs(V)+abs(W);

U_rel=abs(U)./S;
V_rel=abs(V)./S;
W_rel=abs(W)./S;

figure
subplot(2,2,1)
imshow(fliplr(flipud(U_rel)))
subplot(2,2,2)
imshow(fliplr(flipud(V_rel)))
subplot(2,2,3)
imshow(fliplr(flipud(W_rel)))
    %% Writing FDF Files & NifTi files
    
     slicenum = sliceno;%find(ud.sliceorder==ud.pss(sliceno)); PQ?? Je sais pas...
    filenum = num2str(100+slicenum);
    
    %FDF Files
    for jj=1:size(outlist,2)
        filename = strcat(fdfdir,filesep,outlist{jj},'.dat',filesep,outlist{jj},'_',filenum(2:3),'.fdf');
        switch outlist{jj}
            case 'eigen1'
                tmp22 = squeeze(lambdas(1,:,:));
                img_eigen1(:,:,sliceno) =  tmp22(:,:)';
            case 'eigen2'
                tmp22 = squeeze(lambdas(2,:,:));
            case 'eigen3'
                tmp22 = squeeze(lambdas(3,:,:));
            case 'rad'
                tmp22 = squeeze(lambdas(2,:,:) + lambdas(3,:,:))./2;
            case 'ra'
                % set RA values to zero where lambda3 < 0 or lambda1, 2, or 3 is Inf
                meandiff = mean(lambdas,1);
                tmp22 = sqrt((lambdas(1,:,:)-meandiff).^2 + (lambdas(2,:,:)-meandiff).^2 + (lambdas(3,:,:)-meandiff).^2)./(sqrt(3).*meandiff);
                tmp22(find(~isfinite(meandiff))) = 0;
                tmp22(find(lambdas(3,:,:)<0)) = 0;
                tmp22 = squeeze(tmp22);
            case 'tr'
                tmp22 = squeeze(sum(lambdas,1));
            case 'v1x'
                tmp22 = squeeze(eigenVectors(1,1,:,:));
            case 'v1y'
                tmp22 = squeeze(eigenVectors(2,1,:,:));
            case 'v1z'
                tmp22 = squeeze(eigenVectors(3,1,:,:));
            case 'v2x'
                tmp22 = squeeze(eigenVectors(1,2,:,:));
            case 'v2y'
                tmp22 = squeeze(eigenVectors(2,2,:,:));
            case 'v2z'
                tmp22 = squeeze(eigenVectors(3,2,:,:));
            case 'v3x'
                tmp22 = squeeze(eigenVectors(1,3,:,:));
            case 'v3y'
                tmp22 = squeeze(eigenVectors(2,3,:,:));
            case 'v3z'
                tmp22 = squeeze(eigenVectors(3,3,:,:));
            case 'validity'
                tmp22 = squeeze((lambdas(3,:,:)>0).*isfinite(sum(lambdas,1)));
            case 'residual'
                tmp22 = squeeze(residualImage(:,:));
        end
        
        % ORIENTATION A MODIFIER SELON L'ETUDE!
        %tmp22 = flipud(tmp22); %exvivo
        tmp22 = rot90(tmp22,2)'; %Permet d'avoir la bonne orientation dans imageJ pour invivo en tt cas
        
        
        
        f2=fopen(filename,'w','ieee-be');
        fhead = makeFDFheader(ud,slicenum);
        fwrite(f2,fhead,'uint8');
        fwrite(f2,tmp22,'float');
        fclose(f2);
        
        
    end %parameter loop
    %NifTi files
    for kk=1:size(nii_outlist,2)
        switch nii_outlist{kk}
            % ORIENTATION A MODIFIER SELON L'ETUDE!
            case 'B0'
                tmp22 = abs(dtiImages(:,:,1));
                tmp22 = fliplr(tmp22);
                tmp22 = flipud(tmp22); %invivo
                
                img_B0(:,:,sliceno) =  tmp22(:,:)';
            case 'rad'
                tmp22 = squeeze(lambdas(2,:,:) + lambdas(3,:,:))./2;
                tmp22 = fliplr(tmp22);
                tmp22 = flipud(tmp22); %invivo
                
                img_RAD(:,:,sliceno) =  tmp22(:,:)';
            case 'fa' %fractional anisotropy
                meandiff = mean(lambdas,1);
                tmp22 = sqrt(3*((lambdas(1,:,:)-meandiff).^2 + (lambdas(2,:,:)-meandiff).^2 + (lambdas(3,:,:)-meandiff).^2))...
                    ./sqrt(2*(lambdas(1,:,:).^2 +lambdas(2,:,:).^2 +lambdas(3,:,:).^2));
                tmp22(~isfinite(meandiff)) = 0;
                tmp22(lambdas(3,:,:)<0) = 0;
                tmp22 = squeeze(tmp22);
                tmp22 = fliplr(tmp22);
                tmp22 = flipud(tmp22); %invivo
                
                img_FA(:,:,sliceno) =  tmp22(:,:)';
            case 'md' %mean diffusivity
                tmp22 = squeeze(sum(lambdas,1))/3;
                tmp22 = fliplr(tmp22);
                tmp22 = flipud(tmp22);%invivo
                
                img_MD(:,:,sliceno) =  tmp22(:,:)';
            case 'eigen1'
                tmp22 = squeeze(lambdas(1,:,:));
                tmp22 = fliplr(tmp22);
                tmp22 = flipud(tmp22); %invivo
                
                img_eigen1(:,:,sliceno) =  tmp22(:,:)';
        end
        img_eigvec1(:,:,sliceno,1)= squeeze(eigenVectors(1,1,:,:))';
        img_eigvec1(:,:,sliceno,2) = squeeze(eigenVectors(2,1,:,:))';
        img_eigvec1(:,:,sliceno,3) = squeeze(eigenVectors(3,1,:,:))';
    end
    
end %slice loop

%% Sauvegarde des cartes scalaires sous format NifTi (.nii) (LA, JT)
% Gestion des paths
pathout = strrep(pathtobrains,'Brains','ScMaps');

dirFA = [pathout,filesep,'FA',filesep ];
fileoutFA = [dirFA,fidname,'_FA.nii'];
dirMD = [pathout,filesep,'MD',filesep];
fileoutMD = [dirMD,fidname,'_MD.nii'];
dirL1 = [pathout,filesep,'L1',filesep];
fileoutL1 = [dirL1,fidname,'_L1.nii'];
dirRAD = [pathout,filesep,'RAD',filesep];
fileoutRAD = [dirRAD,fidname,'_RAD.nii'];
dirB0 = [pathout,filesep,'B0',filesep];
fileoutB0 = [dirB0,fidname,'_B0.nii'];
dirV1 = [pathout,filesep,'V1',filesep];
fileoutV1 = [dirV1,fidname,'_V1.nii'];


save_scalar_map(dirFA,fileoutFA,img_FA,ud);    %FA
save_scalar_map(dirMD,fileoutMD,img_MD,ud);    %MD
save_scalar_map(dirL1,fileoutL1,img_eigen1,ud);%L1
save_scalar_map(dirRAD,fileoutRAD,img_RAD,ud); %RAD
save_scalar_map(dirB0,fileoutB0,img_B0,ud);    %B0
save_scalar_map4D(dirV1,fileoutV1,img_eigvec1,ud); %V1




end

function save_scalar_map(dirout,fileout,nii_img,ud)

if ~isdir(dirout);
    mkdir(dirout);
end
fprintf(['\t\tSaving ' fileout '...\n'])
out_nii=make_nii(single(nii_img),[ud.lro/size(nii_img,1)*10,ud.lpe/size(nii_img,2)*10, ud.thk]);
save_nii(out_nii,fileout);

end
function save_scalar_map4D(dirout,fileout,nii_img,ud)

if ~isdir(dirout);
    mkdir(dirout);
end
fprintf(['\t\tSaving ' fileout '...\n'])
out_nii=make_nii(single(nii_img),[ud.lro/size(nii_img,1)*10,ud.lpe/size(nii_img,2)*10, ud.thk]);
save_nii(out_nii,fileout);

end

