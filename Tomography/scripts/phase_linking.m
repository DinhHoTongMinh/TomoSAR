function [phi,W_cal,v_ml] = phase_linking(W, N_iter, reference, method)
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

% Use EMI as a PL estimator, DHTM, Mar. 27th, 2023
% Use spectral regularization, DHTM, Mar. 28th, 2023

if not(exist('N_iter', 'var'))
     N_iter = 10;
end
[~,N] = size(W);
 
% check reference index
if not(exist('reference', 'var'))
     reference = 1;
end

% check Phase Linking method
if not(exist('method', 'var'))
     method = 2; % 1 - EMI ; 2 - MLE
end

% spectral regularization
beta = 0.5; 
W = (1-beta)*W + beta*eye(size(W, 1));
    
R = W.*abs(inv(W + 1e-14)); 

% avoid contain NaN or Inf data
R(isinf(R)) = 1e-14;
R(isnan(R)) = 1e-14;

if method == 1
    % reference: 
    % H. Ansari, F. De Zan and R. Bamler, "Efficient Phase Estimation for Interferogram Stacks," 
    % in IEEE TGRL, vol. 56, no. 7, pp. 4109-4125, July 2018

    [Avl,S] = eig(R);
    [~,ind] = min(diag(real(S)));

    % take minimum eigen value and its vector
    phi_emi = angle(Avl(:,ind)); 
    phi = phi_emi-phi_emi(reference);   
end

if method == 2    
    % reference: 
    % Guarnieri, A.M.; Tebaldini, S. On the Exploitation of Target Statistics for SAR
    % Interferometry Applications. Geoscience and Remote Sensing, IEEE Transactions on
    % 2008, 46, 3436–3443.

    % phase triangluation
    [Avl,~,~] = svdecon(W + 1e-14); 
    phi_initial = angle(Avl(:,1)/Avl(reference,1));
    phi_mle = phi_initial;
	% interferogram pairs with stronger signals are given higher influence 
	% in the phase estimation of their neighbors - robustness against decorrelation
    R = W.*abs(W);  
    for k = 1:N_iter 
         for p = 1:N
             not_p=[[1:p-1] [p+1:N]]';
             S = R(not_p,p).*exp(-1i*phi_initial(not_p));
             phi_mle(p) = -angle(sum(S));
             phi_initial = phi_mle;
         end
    end
    phi = phi_mle-phi_mle(reference);
end

phi = angle(exp(1i*phi));

% normalize estimated phases for compression
v_ml = exp(1i*phi)/norm(exp(1i*phi));
 
O = diag(exp(1i*phi));
W_cal = O'*W*O;


return
