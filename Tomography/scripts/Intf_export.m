function [] = Intf_export(infstack,inflist, Path,extention, InSAR_processor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file is part of TomoSAR.
%
%   TomoSAR is distributed in the hope that it will be useful,
%   but without warranty of any kind; without even the implied 
%   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%   See the Apache License for more details.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author : Dinh Ho Tong Minh (INRAE) and Yen Nhi Ngo, Jan. 2022 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if not(exist('InSAR_processor', 'var'))
     InSAR_processor = 'snap';
end

[nlines,nwidths,n_interf] = size(infstack);

real_index = 1:2:nwidths*2-1;
imag_index = 2:2:nwidths*2;
line_cpx = zeros(2*nwidths, 1); 

for i = 1:n_interf  
    switch InSAR_processor
    case 'snap' % 
        filename = [Path,'/',num2str(inflist(i,1)),'_',num2str(inflist(i,2)),extention];
        fid = fopen(filename, 'wb', 'ieee-be');
    case 'isce'
        filename = [Path,'/',num2str(inflist(i,2)),'/','isce_minrefdem.int',extention];
        fid = fopen(filename, 'wb');                    
    otherwise
        disp('not yet support')
    end

    data = squeeze(infstack(:,:,i));
    for k=1:nlines
        line_cpx(real_index) = real(data(k,:));
        line_cpx(imag_index) = imag(data(k,:));
        line_count = fwrite(fid, line_cpx, 'float32');
    end
    fclose(fid);
end

