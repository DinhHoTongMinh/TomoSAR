function [Coh] = SLC_cov(slcstack,SHP)
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

[nlines,nwidths,n_slc]=size(slcstack);

% Normalize 
slcstack(slcstack~=0) = slcstack(slcstack~=0)./abs(slcstack(slcstack~=0));

CalWin =SHP.CalWin;
RadiusRow=(CalWin(1)-1)/2;
RadiusCol=(CalWin(2)-1)/2;   

mlistack = abs(slcstack);

% Coherence matrix estimate
Coh=zeros(n_slc,n_slc,nlines,nwidths,'single');
for ii=1:n_slc
    m1_intial = mlistack(:,:,ii);
    for ss = ii+1:n_slc           
        m2_intial = mlistack(:,:,ss);          
        Dphi = exp(1i*(angle(slcstack(:,:,ii).*conj(slcstack(:,:,ss)))));            
        Intf= sqrt(m1_intial.*m2_intial).*Dphi;
        
        % Padding at edge 
        m1 = padarray(m1_intial,[RadiusRow RadiusCol],'symmetric');
        m2 = padarray(m2_intial,[RadiusRow RadiusCol],'symmetric');
        Intf= padarray(Intf,[RadiusRow RadiusCol],'symmetric');           
        nu = zeros(nlines,nwidths,'single');
        de1=nu;
        de2=nu;
        num=1;
        for jj = 1:nwidths
            for kk= 1:nlines
                x_global  = jj+RadiusCol;
                y_global  = kk+RadiusRow;
                MasterValue= m1(y_global-RadiusRow:y_global+RadiusRow,x_global-RadiusCol:x_global+RadiusCol);
                SlaveValue = m2(y_global-RadiusRow:y_global+RadiusRow,x_global-RadiusCol:x_global+RadiusCol);
                InterfValue= Intf(y_global-RadiusRow:y_global+RadiusRow,x_global-RadiusCol:x_global+RadiusCol);
                MasterValue= MasterValue(SHP.PixelInd(:,num));
                SlaveValue = SlaveValue(SHP.PixelInd(:,num));
                InterfValue= InterfValue(SHP.PixelInd(:,num));
                nu(kk,jj)  = sum(InterfValue);
                de1(kk,jj) = sum(MasterValue);
                de2(kk,jj) = sum(SlaveValue);       
                num=num+1;
            end
        end
        Coh(ii,ss,:,:) = nu./sqrt(de1.*de2);  
    end
end

% Make mirror operator
temp = ones(1,n_slc) ;
for jj = 1:nwidths
    for kk= 1:nlines       
        W = Coh(:, :,kk,jj) ;               
        Coh(:, :,kk,jj) = W + (W - diag(temp))';       
    end
end
 
return
