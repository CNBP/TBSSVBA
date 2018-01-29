function fdf_head = makeFDFheader(ud,currslice,arrayIdx)
% function fdf_head = makeFDFheader(ud,currslice,arrayIdx);
% create the fdf header with the appropriate parameters
b = [];
a = [];
b = sprintf('%s\n',['#!/usr/local/fdf/startup']);
a=[a,b];
b = sprintf('%s\n',['float  rank = 2;']);
a=[a,b];
b = sprintf('%s\n',['char  *spatial_rank = "2dfov";']);
a=[a,b];
b = sprintf('%s\n',['char  *storage = "float";']);
a=[a,b];
b = sprintf('%s\n',['float  bits =','32;']);
a=[a,b];
b = sprintf('%s\n',['char  *type = "absval";']);
a=[a,b];
b = sprintf('%s\n',['float  matrix[] = {',num2str(ud.fn),', ',num2str(ud.fn1),'};']);
a=[a,b];
b = sprintf('%s\n',['char  *abscissa[] = {"cm", "cm"};']);
a=[a,b];
b = sprintf('%s\n',['char  *ordinate[] = { "intensity" };']);
a=[a,b];
b = sprintf('%s\n',['float  span[] = {',num2str(ud.lro),',',num2str(ud.lpe),'};']);
a=[a,b];
b = sprintf('%s\n',['float  origin[] = {1.00, -0.75};']);
a=[a,b];
b = sprintf('%s\n',['char  *nucleus[] = {"H1","H1"};']);
a=[a,b];
b = sprintf('%s\n',['float  nucfreq[] = {199.347148,199.347148};']);
a=[a,b];
b = sprintf('%s\n',['float  location[] = {0.0,',num2str(ud.pro),',',num2str(ud.pss),'};']);
a=[a,b];
b = sprintf('%s\n',['int thk = ', num2str(ud.thk), ';']);
a=[a,b];
b = sprintf('%s\n',['int gap = ', num2str(ud.gap), ';']);
a=[a,b];
b = sprintf('%s\n',['float  roi[] = {',num2str(ud.lro),',',num2str(ud.lpe),',',num2str(ud.lpe2),'};']);
a=[a,b];
b = sprintf('%s\n',['float orientation[] = {-1.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,1.0};']);
a=[a,b];
b = sprintf('%s\n',['int slice_no = ',num2str(currslice),';']);
a=[a,b];
b = sprintf('%s\n',['int slices = ', num2str(ud.ns), ';']);
a=[a,b];
b = sprintf('%s\n',['int echo_no = 1;']);
a=[a,b];
b = sprintf('%s\n',['int echoes = 1;']);
a=[a,b];
b = sprintf('%s\n',['float TE = ',num2str(ud.te*1000),';']);
a=[a,b];
b = sprintf('%s\n',['float te = ',num2str(ud.te),';']);
a=[a,b];
b = sprintf('%s\n',['float  tr = ',num2str(ud.tr),';']);
a=[a,b];
b = sprintf('%s\n',['int ro_size = ',num2str(ud.nv),';',]);
a=[a,b];
b = sprintf('%s\n',['int pe_size = ',num2str(ud.np/2),';',]);
a=[a,b];
b = sprintf('%s\n',['char *sequence = "',ud.pslabel,'";',]);
a=[a,b];
if nargin < 3
    arrayIdx = 0;
end
b = sprintf('%s\n',['int array_index = ',num2str(arrayIdx),';',]);
a=[a,b];
b = sprintf('%s\n',['int checksum = 2921881303;',]);
a=[a,b];
index = length(a);
a = [a,uint8(repmat(32,1,7-mod(index,8)))];
a = [a,uint8(12)];
a = [a,uint8(repmat(10,1,7))];
%a = [a,uint8(0)];
a = [a,char(0)];

fdf_head=a;
return;