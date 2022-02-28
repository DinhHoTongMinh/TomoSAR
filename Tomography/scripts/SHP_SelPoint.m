function [SHP]=SHP_SelPoint(mlistack,CalWin,Alpha)
%
%   Inputs:
%   - mlistack: A height by width by page matrix
%   - CalWin:   Fixed boxcar window size
%   - Alpha:    A value between 0 and 1 specifying the
%               significance level. Default is 0.05 for 5% significance.
%   Outputs:
%   - SHP.PixelInd: A CalWin(1)*CalWin(2) by size(mlistack,1)*size(mlistack,2) array with elements of type logical, containing a SHPs set per pixel 
%   - SHP.BroNum:   The SHP number per pixel (reference pixel is not included) 
%   - SHP.CalWin:   Fixed boxcar window size

% Author:  Mi JIANG, Hohai University 

if nargin < 3
    Alpha = 0.05;
end

if nargin < 2
    CalWin = [15 15];
end

if nargin < 1
    help SHP_SelPoint
    return;
end


if length(size(mlistack))~=3
    error('Please input 3D matrix...');
end

[nlines,nwidths,npages] = size(mlistack);
mlistack=single(mlistack);

%Parameter prepare:
RadiusRow=(CalWin(1)-1)/2;
RadiusCol=(CalWin(2)-1)/2;
InitRow=(CalWin(1)+1)/2; % InitRow is CenterRow
InitCol=(CalWin(2)+1)/2; % InitCol is CenterCol


%Edeg mirror-image
mlistack = padarray(mlistack,[RadiusRow RadiusCol],'symmetric');
meanmli = mean(mlistack,3);
[nlines_EP,nwidths_EP]= size(meanmli);
SHP.PixelInd=false(CalWin(1)*CalWin(2),nlines*nwidths);

%estimate SHPs
num = 1;
p=1;
all = nlines*nwidths;
all_step = floor(all/10);

for kk=InitCol:nwidths_EP-RadiusCol
    for ll=InitRow:nlines_EP-RadiusRow       
        Matrix = mlistack(ll-RadiusRow:ll+RadiusRow,kk-RadiusCol:kk+RadiusCol,:);
        Ref = Matrix(InitRow,InitCol,:);
        % fastest two-Sample test: Baumgartner - Weiß - Schindler algorithm 
        T = BWStest(repmat(Ref(:),[1,CalWin(1)*CalWin(2)])...
                ,reshape(Matrix,[CalWin(1)*CalWin(2),npages])',Alpha);   
        SeedPoint=reshape(~T,[CalWin(1),CalWin(2)]);
        % connection component
        LL = bwlabel(SeedPoint);
        SHP.PixelInd(:,num)=LL(:)==LL(InitRow,InitCol);    
        num=num+1;
        if num == all_step * p
            disp(['SHP family progress: ', num2str(10*p),'%']);
            p = p+1;
        end
    end
end


%SHPs map            
SHP.BroNum = sum(SHP.PixelInd,1);
SHP.BroNum = reshape(SHP.BroNum(:),[nlines,nwidths]);
SHP.BroNum = single((SHP.BroNum-1));          
SHP.CalWin = CalWin;            

       
