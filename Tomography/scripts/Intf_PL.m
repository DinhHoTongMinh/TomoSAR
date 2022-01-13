function [phi_PL,Coh_cal,v_PL] =  Intf_PL(Coh, N_iter,reference)
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

if not(exist('reference', 'var'))
     reference=1;
end

[n_slc,~,nlines,nwidths] = size(Coh);

num=1;
p=1;
all = nlines*nwidths;
all_step = floor(all/10);

phi_PL = zeros(nlines,nwidths,n_slc,'single');
v_PL = zeros(nlines,nwidths,n_slc,'single');
Coh_cal = zeros(nlines,nwidths,'single');
for jj = 1:nwidths
    for kk= 1:nlines       
        W = squeeze(Coh(:, :,kk,jj)) ;
        test_nan_inf = find(or(isnan(W),isinf(W))); 
        if ~isempty(test_nan_inf)                                 
            continue            
        end         
        [phi_PL(kk,jj,:), temp_coh, v_PL(kk,jj,:) ] = phase_linking(W,N_iter,reference);               
        Coh_cal(kk,jj) = (sum(abs(temp_coh(:))) - n_slc)/(n_slc^2 - n_slc);          
        num=num+1;
        if num == all_step * p
            disp(['Phase linking progress: ', num2str(10*p),'%']);
            p = p+1;
        end
    end
end

return




