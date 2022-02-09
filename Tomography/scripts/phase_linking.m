function [phi,W_cal,v_ml] = phase_linking(W, N_iter, reference)
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

if not(exist('N_iter', 'var'))
     N_iter = 10;
end
[~,N] = size(W);
 
% check reference index
if not(exist('reference', 'var'))
     reference = 1;
end

% phase triangluation
[Avl,~,~] = svdecon(W + 1e-14); 
phi_initial = angle(Avl(:,1)/Avl(reference,1));
 
phi_mle = phi_initial;

% reference: 
% Guarnieri, A.M.; Tebaldini, S. On the Exploitation of Target Statistics for SAR
% Interferometry Applications. Geoscience and Remote Sensing, IEEE Transactions on
% 2008, 46, 3436–3443.

R = W.*abs(inv(W + 1e-14)); 
% R = W.*abs(W); % No inversion should be faster

for k = 1:N_iter 
     for p = 1:N
         not_p=[[1:p-1] [p+1:N]];
         S = R(not_p,p).*exp(-1i*phi_initial(not_p));
         phi_mle(p) = -angle(sum(S));
         phi_initial = phi_mle;
     end
end
 
phi = phi_mle-phi_mle(reference);
phi = angle(exp(1i*phi));

% normalize estimated phases for compression
v_ml = exp(1i*phi)/norm(exp(1i*phi));
 
O = diag(exp(1i*phi));
W_cal = O'*W*O;


return
