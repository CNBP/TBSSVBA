function clean_seg(scmap_type)
%UNTITLED Supprime les voxels labelises sans image sous-jacente
%   Detailed explanation goes here
nii_folder=['ScMaps' filesep 'Processed' filesep scmap_type];
seg_folder=['segmentation' filesep 'scmaps_seg'];

niis=dir(fullfile(nii_folder,'*.nii'));
segs=dir(fullfile(seg_folder,'*.nii'));

for i=1:length(segs)
    nii_file=load_nii([nii_folder,filesep,niis(i).name]);
    seg_file=load_nii([seg_folder,filesep,segs(i).name]);
    
    inter = (nii_file.img>0);
    seg=seg_file.img;
    clean_seg=inter.*seg;
    seg_file.img=clean_seg;
    
    
    save_nii(seg_file, [seg_folder,filesep,segs(i).name] );
    
end
end

