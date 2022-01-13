function [H]= BWStest(Xarray,Yarray,Alpha)
%Simpler but accelerated version of BWStest
%Compute the Baumgartner-weiB-Schindler test statistic for two-sample case.
%      
%
%
%   Inputs:
%   - Xarray: A height by width matrix, each column corresponds to a sample
%             for each obs.
%   - Yarray: A height by width matrix, each column corresponds to a sample 
%             for each obs.
%   - Alpha:  Significance level, only .05 (Default) and 0.01 are supported.
%
%   Output:
%   - H:      0 => Accept the null hypothesis at significance level ALPHA
%             1 => Reject the null hypothesis at significance level ALPHA
%
%   [1] A Nonparametric Test for the General Two-Sample Problem, W. Baumgartner, P. Weiß and H. Schindler
%   Biometrics Vol. 54, No. 3 (Sep., 1998), pp. 1129-1135 
%
%
% 
%   This toolbox can be used only for research purposes, you should cite 
%   the aforementioned papers in any resulting publication.
%
%   Mi JIANG, Hohai University,  

if nargin < 3
    Alpha = .05;
end

if nargin < 2
    help BWStest
end

[n,m] = size(Xarray);
ranks = tiedrank(cat(1,Xarray, Yarray));
xrank = sort(ranks(1:n,:));
yrank = sort(ranks((n+1):end,:));
temp  = (1:n)'*ones(1,m);
tempx = (xrank - 2.*temp).^2;
tempy = (yrank - 2.*temp).^2;
temp  = temp/(n+1).*(1-temp/(n+1))*2*n;
BX    = 1/n*sum(tempx./temp,1);
BY    = 1/n*sum(tempy./temp,1);

% test statistic
B = 1/2*(BX + BY);

if Alpha ==.05
    if n==5
        b = 2.533;
    elseif n==6
        b = 2.552;
    elseif n==7
        b = 2.620;
    elseif n==8
        b = 2.564;   
    elseif n==9
        b = 2.575;       
    elseif n==10
        b = 2.583; 
    else
        b = 2.493; %Ref.[1] Table 1
    end
else %(Alpha =.01)
    b = 3.880; %Ref.[1] Table 1
end
H = (B >=b);