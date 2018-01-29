function new_nii = change_res_nii( nii_file, newdim, interpolMethod,out_nii_file )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here


nii=load_nii(nii_file);

%Image Parameters Conversion
old_pixdim = nii.hdr.dime.pixdim(2:4);
new_pixdim = newdim;
ratio_pixdim = old_pixdim./new_pixdim;

old_dim = nii.hdr.dime.dim(2:4);
new_dim = round(old_dim.*ratio_pixdim);

old_img = nii.img;

%Interpolation
[X,Y,Z]=meshgrid(1:old_dim(2),1:old_dim(1),1:old_dim(3));

xsamples=linspace(1,old_dim(2),new_dim(2));
ysamples=linspace(1,old_dim(1),new_dim(1));
zsamples=linspace(1,old_dim(3),new_dim(3));

[Xq,Yq,Zq]=meshgrid(xsamples,ysamples,zsamples);

new_img = interp3(X,Y,Z,old_img,Xq,Yq,Zq,interpolMethod);

% Create new .nii file
new_nii.hdr = nii.hdr;
new_nii.hdr.dime.dim(2:4) = new_dim;
new_nii.hdr.dime.pixdim(2:4)= new_pixdim;
new_nii.filetype = nii.filetype;
new_nii.fileprefix = ' ';%??????
new_nii.machine = nii.machine;
new_nii.img = new_img;
new_nii.original=nii.original;

save_nii(new_nii,out_nii_file);
return 

end

