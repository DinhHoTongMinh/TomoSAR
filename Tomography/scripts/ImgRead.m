function Data=ImgRead(imgpath,suffixname,nline,bkformat,machinefmt)
%Read data stack from a specified directory.
%   Usage:
%       Data=ImgRead(imgpath,suffixname,nline,bkformat,machinefmt);
%   
%
%   Inputs:
%   - imgpath:      The path of image set
%   - suffixname:   The suffix of all files in image set, e.g., mli 
%   - nline:        The image height
%   - bkformat:     See freadbkj.m for details
%   - machinefmt:   See freadbkj.m for details
%
%   Outputs:
%   - Data.datastack:   A height by width by page matrix where each page
%                       corresponds to a 2D image
%   - Data.filename:    The file name list. 
%
%   Examples:
%   To read a batch of intensity series in float32 format with Big-endian 
%   ordering machinefmt, which has a height of 200 lines,use:
%   Data=ImgRead('/home/user/INSAR/COHEST/MLI','mli',200,'float32');
%
%   For complex differential interferogram with height 1800, use: 
%   Data=ImgRead('/home/user/INSAR/COHEST/DIFF','diff',1800,'cpxfloat32');
%
%
%   Mi JIANG, Hohai University/The Hong Kong Polytechnic University, 

if nargin < 5
    machinefmt='b'; % b - GAMMA software, for example
end

if nargin < 4
    bkformat='float32'; %for *mli,*cc file
end

if nargin < 3
    help ImgRead
    return;
end

if isempty(strmatch(imgpath(end),filesep))
    imgpath=[imgpath,filesep];
end

tag_files = dir([imgpath,'*',suffixname]);
img_num = length(tag_files);
disp(['The number of the ', suffixname,' images:' num2str(img_num)]);

for ii=1:img_num
    tic;
    Data.datastack(:,:,ii)=single(freadbkj([imgpath,tag_files(ii).name],nline,bkformat,machinefmt));
    temp=regexp(tag_files(ii).name,'\d+','match');
    if length(temp)==1     %mli
        Data.filename(ii,1)=str2double(temp{1});
    elseif length(temp)==2 %intf
        Data.filename(ii,1)=str2double(temp{1});
        Data.filename(ii,2)=str2double(temp{2});
    else
        error('The format of file name should be: <yyyymmdd> or <yyyymmdd_yyyymmdd>.')
    end
    time=toc;
    fprintf('Reading Img %d / %d, time = %.0f sec\n',ii,img_num,time);      
end



