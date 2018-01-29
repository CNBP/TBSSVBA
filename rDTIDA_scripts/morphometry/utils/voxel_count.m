function label_counts = voxel_count(seg,nbr_lbls)
%UNTITLED Decompte du nombrwe de vxls pour chaque label existant
%   Detailed explanation goes here

label_counts=zeros(nbr_lbls,1);

for i=1:nbr_lbls
    lbl_vxl=(seg==i);
    label_counts(i,1)=length(find(lbl_vxl));
end

return 

end

