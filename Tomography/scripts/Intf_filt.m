function [infstack] = Intf_filt(infstack,SHP,phi_PL,Coh_cal,reference_ind,BroNumthre,Cohthre)
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

if not(exist('BroNumthre', 'var'))
     BroNumthre=5;
end

if not(exist('Cohthre', 'var'))
     Cohthre=0.65;
end

[~,~,n_interf] = size(infstack);

phi_PL(:,:,reference_ind) = []; 
mask_coh = Coh_cal > Cohthre;
mask_PS = SHP.BroNum>BroNumthre;  %PS keep   

mask = and(mask_PS,mask_coh);
mask = repmat(mask,[1,1,n_interf]);
 
infstack(mask) = abs(infstack(mask)).*exp(1i*phi_PL(mask));
    
    