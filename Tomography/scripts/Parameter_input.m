%%%%%%%%%%%%%%%%%%%%%%%%% For SHP analysis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% CalWin - based on azimuth and range spacing to have rough square window in real world 
% row x col is expected to much greater than number of images to better invert covariance matrix.  
% i.e., for 100 Sentinel-1 images, 7x25 or 9x35 is a good one.
CalWin = [7 25]; % - [row col]  

% These follow parameters can be good for most areas.
Alpha = 0.05;  % significance level. 0.05 for 5% significance.
BroNumthre = 20; % less than 20 is likely PS
Cohthre = 0.25; % threshold to select DS in which its phase variance is mostly less than 20 degree.    
Cohthre_slc_filt = 0.05; % less than 0.05 is mostly water 

%%%%%%%%%%%%%%%%%%%%%%%%% For ComSAR analysis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% PSDSInSAR is heavy on memory use due to full covariance estimation. A rough approximation for
% PSDSInSAR RAM requirement is 1.5*Nslc*Nslc*Nline*Nwidth/2.7e8 (GB)
% ComSAR is much friendly Big Data processing. A rough approximation for
% ComSAR RAM requirement is 5*Nslc*Nline*Nwidth/2.7e8 (GB)
% i.e., 200 images of 1000x5000 size, 1 TB is for PSDS, but for ComSAR it requires only 18.5 GB.  
ComSAR_flag = true; % true is for ComSAR, false is for PSDSInSAR
miniStackSize = 5; % 5 (or 10) can help to reduce up to 80% (or 90%) computation. 
Unified_flag = true; % true is for full time series ComSAR, false is just for compressed version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

InSAR_processor = 'snap'; % snap or isce 
switch InSAR_processor
    case 'snap' % 
        % Define path - expect the SNAP export STAMPS structure
        % check out a tutorial here https://youtu.be/HzvvJoDE8ic 
        InSAR_path = 'X:\0_ComSAR\Vauvert\INSAR_20190919';
        reference_date = '20190919';

        file_par = [InSAR_path,'/rslc/',reference_date,'.rslc.par'];
        par_getline = regexp(fileread(file_par),['[^\n\r]+','zimuth_lines','[^\n\r]+'],'match');
        nlines  = str2num([par_getline{1}(15:end)]);

        slcstack = ImgRead([InSAR_path,'/rslc'],'rslc',nlines,'cpxfloat32');
        interfstack = ImgRead([InSAR_path,'/diff0'],'diff',nlines,'cpxfloat32');       
    case 'isce'
        % Define path - expect the 'make_single_reference_stack_isce' structure
        % check out a tutorial  - to be prepare 
        InSAR_path = 'X:\Accra\isce\INSAR_20180103';
        reference_date = '20180103';
        
        nlines = load([InSAR_path,'/len.txt']);        
        slcslist = load([InSAR_path,'/slcs.list']);    
        [slcstack,  interfstack] = ImgRead_isce(InSAR_path,nlines,str2num(reference_date),slcslist);      
    otherwise
        disp('not yet support')
end



