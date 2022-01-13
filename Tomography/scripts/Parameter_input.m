% For SHP analysis
CalWin = [9 35]; %[row col] 
Alpha = 0.05;  % significance level. 0.05 for 5% significance.
BroNumthre = 20;
Cohthre = 0.25;
miniStackSize = 5; 

Cohthre_slc_filt = 0.05; % less than 0.05 is mostly water 

% Define path - expect the SNAP export STAMPS structure
% check out a tutorial here https://youtu.be/HzvvJoDE8ic 
InSAR_path = '/home/hotongminhd/scratch/Vauvert/INSAR_20190919';

% Data input
nlines = 377;
slcstack = ImgRead([InSAR_path,'/rslc'],'rslc',nlines,'cpxfloat32');
interfstack = ImgRead([InSAR_path,'/diff0'],'diff',nlines,'cpxfloat32');
