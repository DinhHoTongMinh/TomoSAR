function [slcstack] = SLC_filt(mlistack,slcstack,SHP,Coh_cal,BroNumthre,Cohthre_slc_filt)
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

[~,~,n_slc] = size(slcstack);

mask_coh = Coh_cal > Cohthre_slc_filt;
mask_PS = SHP.BroNum>BroNumthre;    
mask = and(mask_PS,mask_coh);  
mask = repmat(mask,[1,1,n_slc]);
 
slcstack(mask) = abs(mlistack(mask)).*exp(1i*angle(slcstack(mask)));
    
    