% For SHP analysis
CalWin = [3 15]; %[row col] 
Alpha = 0.05;  % significance level. 0.05 for 5% significance.
BroNumthre = 20;
Cohthre = 0.25;
miniStackSize = 3; 
Unified_flag = true; % true is for full time series ComSAR

Cohthre_slc_filt = 0.05; % less than 0.05 is mostly water 

InSAR_processor = 'isce'; % snap or isce 

switch InSAR_processor
    case 'snap' % 
        % Define path - expect the SNAP export STAMPS structure
        % check out a tutorial here https://youtu.be/HzvvJoDE8ic 
        InSAR_path = 'X:\0_ComSAR\Vauvert\INSAR_20190919';

        % Data input
        nlines = 377; % azimuth_lines in *.par file
        slcstack = ImgRead([InSAR_path,'/rslc'],'rslc',nlines,'cpxfloat32');
        interfstack = ImgRead([InSAR_path,'/diff0'],'diff',nlines,'cpxfloat32');
        
    case 'isce'
        % Define path - expect the 'make_single_reference_stack_isce' structure
        % check out a tutorial  - to be prepare 
        InSAR_path = 'X:\Accra\isce\INSAR_20180103';

        % Data input
        nlines = 264; % value in len.txt file
        reference_date = '20180103';
        
        slcslist = load([InSAR_path,'/slcs.list']);    
        [slcstack,  interfstack] = ImgRead_isce(InSAR_path,nlines,str2num(reference_date),slcslist);
       
    otherwise
        disp('not yet support')
end



