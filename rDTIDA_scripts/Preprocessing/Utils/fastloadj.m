function k_space = fastloadj(file)
% Made faster by Justin Haldar 06/12/2006
% haldar@uiuc.edu
%
% Interactively identifies a data file, loads it,
% and outputs k_space data file to be further manipulated
% with the related functions ftransform or t2transform.
%
%  k_space = fastload;
%
%
%
%
%
%cd c:\tammie\bmrgrp\fse
if nargin < 1
    [fn,pn] = uigetfile('*.*', 'Pick a Varian FID file.');
else
    [pn,fn]= fileparts(file);
    if isempty(pn)
        pn='.';
    end
end
fid=fopen(fullfile(pn,fn),'r','b');
 
% Global header
blocks             = fread(fid,1,'int32');
traces_per_block   = fread(fid,1,'int32');
elements_per_trace = fread(fid,1,'int32');
bytes_per_element  = fread(fid,1,'int32');
bytes_per_trace    = fread(fid,1,'int32');
bytes_per_block    = fread(fid,1,'int32');
version            = fread(fid,1,'int16');
status             = fread(fid,1,'int16');
block_headers      = fread(fid,1,'int32');

statusbits = dec2bin(status,8);
% check if data is stored as int32 (vnmr) or float (vnmrj)
if str2num(statusbits(5))==1
    precision = 'float';
else
    precision = 'int32';
end 

%precision = 'int32';
%PP should be 32 bit integer?

% Define matrix of 2-columns

% Read data into 2-column real/img matrix
% option = 0;
% switch option
%     case 0 %default case -- not working
%if traces_per_block == 1 %only one slice
data3d = reshape(fread(fid,7*blocks+blocks*traces_per_block*elements_per_trace*2,precision),[],blocks);
%size(data3d)
k_space = reshape(complex(data3d(8:2:end,:),data3d(9:2:end,:)),elements_per_trace/2,traces_per_block,blocks);
%size(k_space)
%     case 1
%         tmp_data3d = fread(fid,7*blocks+blocks*traces_per_block*elements_per_trace*2,precision);
%         data3d = reshape(tmp_data3d,[],blocks);
%         size(data3d)
%
%         k_space = reshape(complex(data3d(8:2:end,:),data3d(9:2:end,:)),elements_per_trace/2,traces_per_block,blocks);
% end

%make the real/imaginary data complex
%complex = data3d(1,:)-i.*data3d(2,:);
%sprintf('data made complex')

%v1 = size(data3d,2) ./ traces_per_block ./ blocks;
%k_space = reshape(complex,v1,traces_per_block,blocks);
%if this doesn't work, try transposing tra_per_blk and temp
%sprintf('data reshaped')

return;