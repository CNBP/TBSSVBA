clear;

%Ce script détermine le parrallépipède le plus petit encadrant entièrement
%toutes les images sélectionnées
[niifile,PathName,FilterIndex] = uigetfile('.nii','MultiSelect','on');

x_min=140;
x_max=0;

y_min=140;
y_max=0;

z_min=216;
z_max=0;

for i=1:length(niifile)
    brain=niifile{i};
    nii=load_nii([PathName, brain]);
    img=nii.img;
    sz=size(img);
    
    for z=1:sz(3)
        section=img(:,:,z);
        idx=(section>1);
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
        idx=(section>1);
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
        idx=(section>1);
        len=length(find(idx));
        if(len>50 || y>=y_min) %au cas où il y aurait du bruit
            if (y<y_min)
                y_min=y;
            end
            break;
        end
    end
    for y=sz(2):-1:1
        section=img(:,y,:);
        idx=(section>1);
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
        idx=(section>1);
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
        idx=(section>1);
        len=length(find(idx));
        if(len>50 || x<=x_max)
            if (x>x_max)
                x_max=x;
            end
            break;
        end
    end
end
for i=1:length(niifile)
    brain=niifile{i};
    nii=load_nii([PathName, brain]);
    
    new_dim=[(x_max-x_min)+1,(y_max-y_min)+1,(z_max-z_min)+1]
    new_nii.hdr = nii.hdr;
    new_nii.hdr.dime.dim(2:4) = new_dim;
    new_nii.filetype = nii.filetype;
    new_nii.fileprefix = ' ';%??????
    new_nii.machine = nii.machine;
    new_nii.original=nii.original;
    
    new_nii.img=nii.img(x_min:x_max,y_min:y_max,z_min:z_max);
    
    save_nii(new_nii,['boxed_',brain,'.nii']);
    
    
end

