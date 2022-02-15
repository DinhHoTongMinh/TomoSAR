% Main program for PSDSInSAR and ComSAR processing

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


%Parameters load
Parameter_input

% SHP family selection 
SHP = SHP_SelPoint(abs(slcstack.datastack),CalWin,Alpha);

% Coherence matrix estimation
[Coh_matrix,reference_ind] = Intf_cov(abs(slcstack.datastack),...
    slcstack.filename,interfstack.datastack,interfstack.filename,SHP);

% NoCompressed version
PSDSInSAR_estimator(Coh_matrix, slcstack.datastack,slcstack.filename, ...
    interfstack.datastack, interfstack.filename, SHP, reference_ind, ...
                InSAR_path, BroNumthre, Cohthre, Cohthre_slc_filt)

% Compressed version 
ComSAR_estimator(Coh_matrix, slcstack.datastack,slcstack.filename,...
        interfstack.datastack,interfstack.filename, SHP, InSAR_path, BroNumthre, ...
                       Cohthre, miniStackSize, Cohthre_slc_filt, Unified_flag)
             