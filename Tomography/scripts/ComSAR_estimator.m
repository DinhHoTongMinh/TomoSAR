function [] = ComSAR_estimator(slcstack, slclist, interfstack, interflist, SHP_ComSAR, InSAR_path, BroNumthre, Cohthre, miniStackSize, Cohthre_slc_filt, Unified_flag,InSAR_processor)

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
%
% DHTM - add 'Unified_flag' for full time series capability, 14 Feb. 2022 
% DHTM - calculate covariance MiniStacks for Big Data friendly, 24 Mar. 2022 
%

% This function provides the compressed SAR of PS and DS targets
% see more detail in section 3 of [1]:
% [1] Dinh Ho Tong Minh and Yen Nhi Ngo. 
% "Compressed SAR Interferometry in the Big Data Era". Remote Sensing.  
% 2022, 14, 390. https://doi.org/10.3390/rs14020390 
%
% This file can be used only for research purposes, you should cite 
% the aforementioned papers in any resulting publication.
%

% check option for full time series ComSAR
if not(exist('Unified_flag', 'var'))
     Unified_flag = false;
end

[nlines,nwidths,n_interf] = size(interfstack);
n_slc = n_interf + 1;

% normalize 
interfstack(interfstack~=0) = interfstack(interfstack~=0)./abs(interfstack(interfstack~=0));

[~,idx]=ismember(interflist,slclist);

reference_ind = idx(1);

if reference_ind > 1
    temp(:,:,[1:reference_ind-1,reference_ind+1:n_slc]) = interfstack;
    temp(:,:,reference_ind) = abs(slcstack(:,:,reference_ind-1));
else
    temp(:,:,1) = abs(slcstack(:,:,1));
    temp(:,:,[2:n_slc]) = interfstack;
end   
interfstack = temp; clear temp

interfstack = abs(slcstack).*exp(1i*angle(interfstack)); % get SLC amplitude

% assume the reference is not change, size of mini stacks and number of mini stack
% assume the reference is not belong to the last miniStackSize 
mini_ind = 1:miniStackSize:n_slc; 
[~,reference_ComSAR_ind]=ismember(reference_ind,mini_ind);
if reference_ComSAR_ind == 0
    mini_ind = sort([reference_ind mini_ind]);
    temp_diff = [miniStackSize diff(mini_ind)];
    one_image_ind = find((temp_diff<2) == 1);
    [~,reference_ComSAR_ind]=ismember(reference_ind,mini_ind);   
    % two images for calculating interferometric phase
    if not(isempty(one_image_ind))
        if (reference_ComSAR_ind ~= one_image_ind) 
            mini_ind(one_image_ind) = mini_ind(one_image_ind) + 1; 
        elseif one_image_ind > 2
            mini_ind(one_image_ind-1) = mini_ind(one_image_ind-1) - 1; 
        else
            mini_ind(one_image_ind+1) = mini_ind(one_image_ind+1) + 1; 
        end 
    end
end
if mini_ind(end) == n_slc
   mini_ind(end) = mini_ind(end) -  1; % two images for calculating interferometric phase
end

numMiniStacks = length(mini_ind);

% Compressed SLCs stack
compressed_SLCs = zeros(nlines,nwidths, numMiniStacks, 'single'); 

if Unified_flag
    Unified_ind = mini_ind(1):n_slc;
    [~,reference_UnifiedSAR_ind]=ismember(reference_ind,Unified_ind);

    N_unified_SAR = length(Unified_ind);
    Unified_SAR = zeros(nlines,nwidths,N_unified_SAR, 'single'); 
end    

for k = 1 : numMiniStacks 
    if k == numMiniStacks
        cal_ind = mini_ind(k):n_slc;  
    else    
        cal_ind = mini_ind(k):mini_ind(k+1)-1; 
    end  

    Coh_temp = SLC_cov(interfstack(:,:,cal_ind),SHP_ComSAR);

    % The transformation for the mini-stack 
    [phi_PL, ~, v_ML] = Intf_PL(Coh_temp, 10);
 
    % Compressing SLC 
    compressed_SLCs(:,:,k) = mean(v_ML.*interfstack(:,:,cal_ind),3); 
    
    if Unified_flag
       % Unified full time series SAR
        Unified_SAR(:,:,cal_ind-mini_ind(1)+1) = phi_PL;
    end 
    fprintf('Compressed SAR progress: %d/%d is finished. \n',k,numMiniStacks);
end

% If the number of compressed_SLCs > 15, SHP can be recalculated   
% [SHP_ComSAR]=SHP_SelPoint(abs(compressed_SLCs),CalWin,Alpha); 

% phase linking for Compressed SLCs 
cov_compressed_slc = SLC_cov(compressed_SLCs,SHP_ComSAR);
[phi_PL_compressed,Coh_cal] =  Intf_PL(cov_compressed_slc, 10,reference_ComSAR_ind);

if Unified_flag
    %%%%%%%%%%%%%%%%%%%%%%%%%% Update full time serie %%%%%%%%%%%%%%%%%%%%%%%%%
    for k = 1 : numMiniStacks 
        if k == numMiniStacks
            cal_ind = mini_ind(k):n_slc; 
        else    
            cal_ind = mini_ind(k):mini_ind(k+1)-1; 
        end  
        % equation 3 in [1]
        Unified_SAR(:,:,cal_ind-mini_ind(1)+1) = ...
            Unified_SAR(:,:,cal_ind-mini_ind(1)+1) + ...
            repmat(phi_PL_compressed(:,:,k),[1,1,length(cal_ind)]);
    end

    Unified_SAR(:,:,reference_UnifiedSAR_ind) = []; % the reference is removed in the differential phases

    % Phase filtering
    mask_coh = Coh_cal > Cohthre;
    mask_PS = SHP_ComSAR.BroNum>BroNumthre;   
    mask = and(mask_PS,mask_coh);  %PS keep 
    mask = repmat(mask,[1,1,N_unified_SAR-1]);

    Unified_ind_no_ref = Unified_ind; Unified_ind_no_ref(reference_UnifiedSAR_ind) = []; 
    interfstack_ComSAR = interfstack(:,:,Unified_ind_no_ref);
    interfstack_ComSAR(mask) = abs(interfstack_ComSAR(mask)).*exp(1i*Unified_SAR(mask));

    % DeSpeckle for unified SLCs
    slcstack_ComSAR = slcstack(:,:,Unified_ind);
    mli_despeckle = Image_DeSpeckle(abs(slcstack_ComSAR),SHP_ComSAR);
    mask_coh = Coh_cal > Cohthre_slc_filt;
    mask = and(mask_PS,mask_coh); %PS keep 
    mask = repmat(mask,[1,1,N_unified_SAR]);
    slcstack_ComSAR(mask) = abs(mli_despeckle(mask)).*exp(1i*angle(slcstack_ComSAR(mask)));

    % Name index for unified ComSAR
    slcstack_ComSAR_filename = slclist(Unified_ind);
    [~,idx]=ismember(interflist,slcstack_ComSAR_filename);
    interfstack_ComSAR_filename = interflist(find(idx(:,2) ~= 0),: );
    
else %%%%%%%%%%%%%%%%%%%  work only in compressed data  %%%%%%%%%%%%%%%%%%%
    phi_PL_compressed(:,:,reference_ComSAR_ind) = []; % the reference is removed in the differential phases

    % Phase filtering
    mask_coh = Coh_cal > Cohthre;
    mask_PS = SHP_ComSAR.BroNum>BroNumthre;    
    mask = and(mask_PS,mask_coh); %PS keep 
    mask = repmat(mask,[1,1,numMiniStacks-1]);
    
    %interfstack_ComSAR = compressed_SLCs;
    %interfstack_ComSAR (:,:,reference_ComSAR_ind) = [];     
    mini_ind_no_ref = mini_ind; mini_ind_no_ref(reference_ComSAR_ind) = []; 
    interfstack_ComSAR = interfstack(:,:,mini_ind_no_ref);      
    interfstack_ComSAR(mask) = abs(interfstack_ComSAR(mask)).*exp(1i*phi_PL_compressed(mask));
   
    
    % DeSpeckle for Compressed SLCs    
    slcstack_ComSAR = slcstack(:,:,mini_ind);
    mli_despeckle = Image_DeSpeckle(abs(compressed_SLCs),SHP_ComSAR);
    mask_coh = Coh_cal > Cohthre_slc_filt; 
    mask = and(mask_PS,mask_coh);
    mask = repmat(mask,[1,1,numMiniStacks]);
    slcstack_ComSAR(mask) = abs(mli_despeckle(mask)).*exp(1i*angle(compressed_SLCs(mask)));

    % Name index for ComSAR
    slcstack_ComSAR_filename = slclist(mini_ind);
    [~,idx]=ismember(interflist,slcstack_ComSAR_filename);
    interfstack_ComSAR_filename = interflist(find(idx(:,2) ~= 0),: );
end

% Export ComSAR products
switch InSAR_processor
    case 'snap' % 
        Intf_export(interfstack_ComSAR,interfstack_ComSAR_filename,[InSAR_path,'/diff0'],'.comp');
        SLC_export(slcstack_ComSAR,slcstack_ComSAR_filename,[InSAR_path,'/rslc'],'.csar');
    case 'isce'
        Intf_export(interfstack_ComSAR,interfstack_ComSAR_filename,InSAR_path,'.comp',InSAR_processor);
        SLC_export(slcstack_ComSAR,slcstack_ComSAR_filename,InSAR_path,'.csar',InSAR_processor,reference_ComSAR_ind);   
     
        TomoSAR_interflist = interfstack_ComSAR_filename(:,2);
        save([InSAR_path,'/TomoSAR_interflist'],'TomoSAR_interflist') 
    otherwise
        disp('not yet support')
end

return  



