function  boxnii_v2( file, fileout )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%% Find samllest bounding box
x_min=0;
x_max=0;

y_min=0;
y_max=0;

z_min=0;
z_max=0;


nii=load_nii_gz(file);

if nii.hdr.dime.dim(1)==5
    %load_nii ne supporte pas le format nifti tensor, la fonction suivante y
    %remedie
    nii=load_tensor_gz_LA(file);
end

img=nii.img;
sz=size(img);

if x_min==0 && y_min==0 && z_min==0
    x_min=sz(1);
    y_min=sz(2);
    z_min=sz(3);
end

for z=1:sz(3)
    section=img(:,:,z);
    idx=(section>0);
    len=length(find(idx));
    if(len>50 || z>=z_min)
        if (z<z_min)
            z_min=z;
        end
        break;
    end
end

for z=sz(3):-1:1
    section=img(:,:,z);
    idx=(section>0);
    len=length(find(idx));
    if(len>50 || z<=z_max)
        if (z>z_max)
            z_max=z;
        end
        break;
    end
end
for y=1:sz(2)
    section=img(:,y,:);
    idx=(section>0);
    len=length(find(idx));
    if(len>50 || y>=y_min) %au cas o� il y aurait du bruit
        if (y<y_min)
            y_min=y;
        end
        break;
    end
end
for y=sz(2):-1:1
    section=img(:,y,:);
    idx=(section>0);
    len=length(find(idx));
    if(len>50 || y<=y_max)
        if (y>y_max)
            y_max=y;
        end
        break;
    end
end
for x=1:sz(1)
    section=img(x,:,:);
    idx=(section>0);
    len=length(find(idx));
    if(len>50 || x>=x_min)
        if (x<x_min)
            x_min=x;
        end
        break;
    end
end
for x=sz(1):-1:1
    section=img(x,:,:);
    idx=(section>0);
    len=length(find(idx));
    if(len>50 || x<=x_max)
        if (x>x_max)
            x_max=x;
        end
        break;
    end
end


new_dim=[(x_max-x_min)+1,(y_max-y_min)+1,(z_max-z_min)+1];
low_idxs=[x_min y_min z_min];
high_idxs=[x_max y_max z_max];

new_nii.hdr = nii.hdr;
new_nii.hdr.dime.dim(2:4) = new_dim;
new_nii.filetype = nii.filetype;
new_nii.fileprefix = ' ';
new_nii.machine = nii.machine;
new_nii.original=nii.original;

if nii.hdr.dime.dim(1)==5 || nii.hdr.dime.dim(1)==4
    new_nii.img=nii.img(low_idxs(1):high_idxs(1),low_idxs(2):high_idxs(2),low_idxs(3):high_idxs(3),:);
else
    new_nii.img=nii.img(low_idxs(1):high_idxs(1),low_idxs(2):high_idxs(2),low_idxs(3):high_idxs(3));
    
end


save_nii_gz(new_nii,fileout)

end

