function [] = SLC_export(slcstack,slclist, Path, extention)
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

[nlines,nwidths,n_slc] = size(slcstack);

real_index = 1:2:nwidths*2-1;
imag_index = 2:2:nwidths*2;
line_cpx = zeros(2*nwidths, 1); 

for i = 1:n_slc  
    filename = [Path,'/',num2str(slclist(i)),extention];
    fid = fopen(filename, 'wb', 'ieee-be');
    data = squeeze(slcstack(:,:,i));
    for k=1:nlines
        line_cpx(real_index) = real(data(k,:));
        line_cpx(imag_index) = imag(data(k,:));
        line_count = fwrite(fid, line_cpx, 'float32');
        if (line_count ~= nwidths*2)
            error('ERROR: line %d: %d samples written instead of %d !!!', k, line_count, nwidths*2);
        end
    end
    fclose(fid);
end
                
