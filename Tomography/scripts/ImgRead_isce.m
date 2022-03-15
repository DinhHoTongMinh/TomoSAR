function  [slcstack,  interfstack] = ImgRead_isce(InSAR_path,nline,reference_date,slcslist)
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
% Author : Dinh Ho Tong Minh (INRAE) and Yen Nhi Ngo, Mar. 2022 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_int = size(slcslist,1);

for ii=1:N_int
    interfstack.datastack(:,:,ii)=single(freadbkj([InSAR_path,'/',num2str(slcslist(ii)),'/isce_minrefdem.int'],nline,'cpxfloat32'));
    interfstack.filename(ii,2)=slcslist(ii);
    
    tempstack(:,:,ii)=single(freadbkj([InSAR_path,'/',num2str(slcslist(ii)),'/secondary.slc'],nline,'cpxfloat32'));
  
    fprintf('Reading slc/interferogram %d / %d \n',ii,N_int);      
end
interfstack.filename(:,1) = reference_date;

% insert reference_date in to slc list
slcslist = [reference_date; slcslist];
slcslist_datenum = sort(datenum(num2str(slcslist),'yyyymmdd'));

slcslist = datestr(slcslist_datenum,'yyyymmdd');      
N_slc = size(slcslist,1);

[~,reference_ind]=ismember(datenum(num2str(reference_date),'yyyymmdd'),slcslist_datenum);
if reference_ind > 1
    slcstack.datastack(:,:,[1:reference_ind-1,reference_ind+1:N_slc]) = tempstack;
    slcstack.datastack(:,:,reference_ind) = single(freadbkj([InSAR_path,'/',num2str(slcslist(1,:)),'/reference.slc'],nline,'cpxfloat32'));
else
    slcstack.datastack(:,:,1) = single(freadbkj([InSAR_path,'/',num2str(slcslist(2,:)),'/reference.slc'],nline,'cpxfloat32'));
    slcstack.datastack(:,:,[2:N_slc]) = tempstack;
end 

for ii = 1:N_slc
    slcstack.filename(ii,1) = str2double(slcslist(ii,:));
end






