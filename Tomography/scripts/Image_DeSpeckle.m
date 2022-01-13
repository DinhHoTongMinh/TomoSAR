function Mliimg = Image_DeSpeckle(mlistack,SHP)

%   Inputs:
%   - mlistack: A height by width by page (real) matrix,e.g., SAR single-look
%               intensity series
%   - SHP:      See script "SHP_SelPoint.m" for details
%   Outputs:
%   - Mliimg:   filtered intensity images 
%


if nargin < 1
    help DeSpeckling
    return
end

tic;
[nlines,nwidths,npages]=size(mlistack);
Mliimg = mlistack;

CalWin =SHP.CalWin;
RadiusRow=(CalWin(1)-1)/2;
RadiusCol=(CalWin(2)-1)/2;  
mlistack = padarray(mlistack,[RadiusRow RadiusCol],'symmetric');

%Despeckling
for ii=1:npages
    temp = mlistack(:,:,ii);
    num=1;
    for jj = 1:nwidths
        for kk= 1:nlines
            x_global  = jj+RadiusCol;
            y_global  = kk+RadiusRow;
            MliValue  = temp(y_global-RadiusRow:y_global+RadiusRow,x_global-RadiusCol:x_global+RadiusCol);
            MliValue  = MliValue(SHP.PixelInd(:,num));
            Mliimg(kk,jj,ii) = mean(MliValue);
            num=num+1;
        end
    end         
    fprintf(' ADP. DESPECKLING: %d / %d is finished...\n',ii,npages);
end    



t=toc;
disp(['DeSpeckling operation completed in ',num2str(t/60),' minute(s).']);
disp('Done!');      
        
   
