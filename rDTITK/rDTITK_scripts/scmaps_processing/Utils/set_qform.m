function qform = set_qform( nii, orient )
%
%  Usage: nii = set_qform(nii,[4,6,5]);
%   orient is orientation 1x3 matrix, in that:
%	Three elements represent: [x y z]
%	Element value:	1 - Left to Right; 2 - Posterior to Anterior;
%			3 - Inferior to Superior; 4 - Right to Left;
%			5 - Anterior to Posterior; 6 - Superior to Inferior;


%% ATTENTION CETTE FONCTION N'A PAS ETE ENTIEREMENT VALIDEE MEME SI OK POUR NOS DONNEES
qform=zeros(1,16);

for i=1:length(orient)
    
    switch orient(i)
        case 1
            qform(i+(5*(i-1)))=-nii.hdr.dime.pixdim(2);
        case 2
            qform(i+(5*(i-1)))=-nii.hdr.dime.pixdim(4);
        case 3
            qform(i+(5*(i-1)))=-nii.hdr.dime.pixdim(5);
        case 4
            qform(i+(5*(i-1)))=nii.hdr.dime.pixdim(2);
        case 5
             qform(i+(5*(i-1)))=nii.hdr.dime.pixdim(4);
        case 6
             qform(i+(5*(i-1)))=nii.hdr.dime.pixdim(5);
    end
end

qform(end)=1;

end

