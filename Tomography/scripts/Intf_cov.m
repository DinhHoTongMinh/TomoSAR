function [Coh, reference_ind] = Intf_cov(mlistack,mlilist,infstack,inflist,SHP)
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

[nlines,nwidths,npages]=size(infstack);

% normalize 
infstack(infstack~=0) = infstack(infstack~=0)./abs(infstack(infstack~=0));

[~,idx]=ismember(inflist,mlilist);

reference_ind = idx(1);

if reference_ind > 1
    temp(:,:,[1:reference_ind-1,reference_ind+1:npages+1]) = infstack;
    temp(:,:,reference_ind) = abs(mlistack(:,:,reference_ind-1));
else
    temp(:,:,1) = abs(mlistack(:,:,1));
    temp(:,:,[2:npages+1]) = infstack;
end   
infstack = temp; clear temp

CalWin =SHP.CalWin;
RadiusRow=(CalWin(1)-1)/2;
RadiusCol=(CalWin(2)-1)/2;   

tic
%Coherence matrix estimate
Coh=zeros(npages+1,npages+1,nlines,nwidths,'single');
for ii=1:npages+1
    m1_intial = mlistack(:,:,ii);
    for ss = ii+1:npages+1           
        m2_intial = mlistack(:,:,ss);          
        Dphi = exp(1i*(angle(infstack(:,:,ii).*conj(infstack(:,:,ss)))));
            
        Intf= sqrt(m1_intial.*m2_intial).*Dphi;

        %Edge process
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
    fprintf('Coherence progress: %d / %d is finished...\n',ii,npages);
end

% Make mirror operator
for jj = 1:nwidths
    for kk= 1:nlines       
        W = Coh(:, :,kk,jj) ;
        temp = ones(1,npages+1) ;        
        Coh(:, :,kk,jj) = W + (W - diag(temp))';       
    end
end

t=toc;
disp(['Coherence matrix estimation operation completed in ',num2str(t/60),' minute(s).']);
disp('Done!');    
