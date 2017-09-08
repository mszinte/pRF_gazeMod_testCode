function [const] = dirSaveFile(const)
% ----------------------------------------------------------------------
% [const]=dirSaveFile(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Make directory and saving files name and fid.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 21 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

% Create directory
if ~isdir(sprintf('data/%s/%s/',const.sjct,const.taskName))
    mkdir(sprintf('data/%s/%s/',const.sjct,const.taskName))
end

% Define directory
now = clock;
opfn = sprintf('%1.0f-%1.0f-%1.0f_%1.0f.%1.0f.%1.0f',now);
const.output_file = sprintf('data/%s/%s/%s_%i_%s',const.sjct,const.taskName,const.sjct,const.fromBlock,opfn);

% Eyelink file
const.eyelink_temp_file     = 'XX.edf';
const.eyelink_local_file    = sprintf('%s.edf',const.output_file);

% Color matching file
const.colRatio_text         = sprintf('data/%s/Color_Matcher/%s_color_ratios.txt',const.sjct,const.sjct);
if const.expStart
    if const.typeTask == 1;const.colRatio_fid = fopen(const.colRatio_text,'w');
    else
        const.colRatio_fid = fopen(const.colRatio_text,'r');
        if const.colRatio_fid == -1;error('NO COLOR RATIO TEXT FILE PRESENT!!!!!!!!');end
    end
else
    const.colRatio_fid = fopen(const.colRatio_text,'w');
end



% pRF block order file
const.block_order_mat       = sprintf('data/%s/pRF_exp/%s_block_order.mat',const.sjct,const.sjct);

% Staircase file
if const.typeTask == 2
    % pRF staircase file
    const.staircase_mat     = sprintf('data/%s/%s/%s_prf_staircase.mat',const.sjct,const.taskName,const.sjct);
elseif const.typeTask == 3
    % HRF staircase file
    const.staircase_mat     = sprintf('data/%s/%s/%s_hrf_staircase.mat',const.sjct,const.taskName,const.sjct);
end

% Log file
const.log_text              = sprintf('%s_log.txt',const.output_file);
const.log_text_fid          = fopen(const.log_text,'a+');

% Define .mat saving file
const.exp_file_mat    = sprintf('%s.mat',const.output_file);

end