function [] = SLC_export(slcstack,slclist, Path, extention, InSAR_processor, reference_index)
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

if not(exist('reference_index', 'var'))
     reference_index = 1;
end

[nlines,nwidths,n_slc] = size(slcstack);

real_index = 1:2:nwidths*2-1;
imag_index = 2:2:nwidths*2;
line_cpx = zeros(2*nwidths, 1); 

for i = 1:n_slc  
     switch InSAR_processor
        case 'snap' % 
            filename = [Path,'/',num2str(slclist(i)),extention];
            fid = fopen(filename, 'wb', 'ieee-be');
        case 'isce'            
            if i == reference_index
                filename = [Path,'/reference/','reference.slc',extention];
            else
                filename = [Path,'/',num2str(slclist(i)),'/','secondary.slc',extention];    
            end
            fid = fopen(filename, 'wb'); 
        otherwise
            disp('not yet support')
    end
    
    data = squeeze(slcstack(:,:,i));
    for k=1:nlines
        line_cpx(real_index) = real(data(k,:));
        line_cpx(imag_index) = imag(data(k,:));
        line_count = fwrite(fid, line_cpx, 'float32');
    end
    fclose(fid);
end
                
