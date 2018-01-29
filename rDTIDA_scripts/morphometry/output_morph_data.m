function output_morph_data( csvname,scmap_type )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fid= fopen(csvname,'w');
fprintf(fid, '%s,','-');

%nbre de lbls
atlas_seg=['.' filesep 'Atlas' filesep 'atlas_segmentation_p14.nii'];
atlas_seg_nii=load_nii(atlas_seg);
lbls=1:max(max(max(atlas_seg_nii.img)))';
lbls=lbls';

%boucle for sur les seg des scmaps
nii_folder=['ScMaps' filesep 'Processed' filesep scmap_type];
seg_folder=['segmentation' filesep 'scmaps_seg'];

niis=dir(fullfile(nii_folder,'*.nii'));%ATTENTION IL FAUT TROUVER UN MOYEN DE FAIRE LE DEZIPPAGE AUTOMATIQUEMENT (pr l'instant ca a ete fait manuellement)
segs=dir(fullfile(seg_folder,'seg_*.nii'));

for i=1:length(niis)
    nii_file=load_nii([nii_folder,filesep,niis(i).name]);
    parts=strsplit(nii_file.fileprefix,filesep);
    sjt=char(parts(end));
    if i~=length(niis)
        fprintf(fid,'%s,',sjt); %une fois dans la boucle, '%s\n' pour la derniere iteration sinon '%s,'
    else
        fprintf(fid,'%s\n',sjt);
    end
end
fclose(fid);

counts=zeros(length(lbls),length(niis)+1); %matrice des donnees, une colonne en plus pr l'index du lbl
counts(:,1)=lbls;


for i=1:length(segs)    
    seg_file=load_nii([seg_folder,filesep,segs(i).name]);
    seg_nii_img=seg_file.img;
    
    cnt=voxel_count(seg_nii_img,length(lbls));
    counts(:,i+1)=cnt;

end
dlmwrite(csvname,counts,'-append');

end


