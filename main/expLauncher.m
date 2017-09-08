%% General experimenter launcher %%
%  =============================  %
% By :      Martin SZINTE
% Projet :  pRF_gazeMod experiment
% With :    TOMAS KNAPEN
% Version:  2.1

% Version description
% ===================
% Experiment in which we determine pRF position/size when fixating at
% different position over the screen to determine gaze modulation effects on pRF
% => add of a HRF mapper
% => add button press collection using GetChar and Charavaible (as I noticed that some TR T were missing from the edf files)

% TR
% ==
% pRF experiment => 1 (instructions TR) + 32x14 (main seq x trials nb) + 1x14 (iti x trial nb) - 1 (last TR) = 462 TR
% HRF experiment => 1 (instructions TR) + 1x130 (main seq x trials nb) + 1x130 (iti x trial nb) - 1 (last TR) = 260 TR + 5 for safety

% First settings
% --------------
clear all;clear mex;clear functions;close all;home;ListenChar(1);
%fprintf(1,'\n\tExpLauncher line 9:Don''t forget to put it back before testing !!!\n');

% General settings
% ----------------
const.expName       = 'pRF_gazeMod';        % experiment name.
const.expStart      = 1;                    % Start of a recording exp                          0 = NO   , 1 = YES
const.checkTrial    = 0;                    % Print trial conditions (for debugging)            0 = NO   , 1 = YES
const.checkFRPS     = 0;                    % Check frame rate per second (to test screen)      0 = NO   , 1 = YES
const.staircaseType	= 2;                    % Type of staircase to use                          1 = Quest, 2 = 3-down/1-up
const.practice      = 0;                    % Run practice trials                               0 = NO   , 1 = YES

% External controls
% -----------------
const.tracker       = 1;                    % run with eye tracker                              0 = NO   , 1 = YES
const.trackerBox    = 0;                    % draw a box where the tracker is                   0 = NO   , 1 = YES
const.scanner       = 1;                    % run with MRI scanner record                       0 = NO   , 1 = YES
const.scannerTest   = 0;                    % run with T returned at TR time                    0 = NO   , 1 = YES

% Desired screen settings
% -----------------------
const.desiredFD     = 120;                  % Desired refresh rate
const.desiredRes    = [1920,1080];          % Desired resolution
 
% Path
% ----
dir = (which('expLauncher'));cd(dir(1:end-18));

% Add Matlab path
% ---------------
addpath('config','main','conversion','eyeTracking','instructions','trials','stim','stats');

% Block definition
% ----------------
if ~const.expStart
    num_run_block_colMatch          = 1;    % 1 block = 2 min in 7T scanner
    const.num_tot_block_colMatch    = 1;    % 2 min in total in 7T scanner
    num_run_block_pRF               = 1;    % 1 block = 8 min in 7T scanner
    const.num_tot_block_pRF         = 1;    % 8 min in total in 7T scanner
    num_run_block_HRF               = 1;    % 1 block = 5 min in 7T scanner
    const.num_tot_block_HRF         = 1;    % 5 min in total in 7T scanner
else
    num_run_block_colMatch          = 1;    % 1 block = 2 min in 7T scanner
    const.num_tot_block_colMatch    = 1;    % 2 min in total in 7T scanner
    num_run_block_pRF               = 1;    % 1 block = 8 min in 7T scanner
    const.num_tot_block_pRF         = 8;    % 4 repetitions x 2 fix positions => 8 x 8 min = 64 min (~1h) in total in 7T scanner
    num_run_block_HRF               = 1;    % 1 block = 5 min in 7T scanner
    const.num_tot_block_HRF         = 2;    % 5 min in total in 7T scanner
end

% Conditions selection
% --------------------
const.typeTask = input(sprintf('\n\tColor matcher task (1) or Main exp. (2) or HRF mapper (3): '));

% Subject configuration
% ---------------------
[const] = sbjConfig(const);

% Main run:
% ---------
% Task 1 = Color Matching
if const.typeTask == 1
    const.taskName = 'Color_Matcher';
    toBlock_colMatch = (const.fromBlock+num_run_block_colMatch-1);
    if toBlock_colMatch > const.num_tot_block_colMatch;toBlock_colMatch = const.num_tot_block_colMatch;end
        
    for block = const.fromBlock:toBlock_colMatch
        const.fromBlock = block;
        main(const);clear expDes;
    end
    
% Task 2 = pRF
elseif const.typeTask == 2
    const.taskName = 'pRF_exp';
    toBlock_pRF = (const.fromBlock+num_run_block_pRF-1);
    if toBlock_pRF > const.num_tot_block_pRF;toBlock_pRF = const.num_tot_block_pRF;end
    for block = const.fromBlock:toBlock_pRF
        const.fromBlock = block;
        main(const);clear expDes
        plot_pRF_results(const.sjct,toBlock_pRF,const.tracker);
    end
    
% Task 3 = HRF mapper
elseif const.typeTask == 3
    const.taskName = 'HRF_mapper';
    toBlock_HRF = (const.fromBlock+num_run_block_HRF-1);
    if toBlock_HRF > const.num_tot_block_HRF;toBlock_HRF = const.num_tot_block_HRF;end
    for block = const.fromBlock:toBlock_HRF
        const.fromBlock = block;
        main(const);clear expDes
        plot_HRF_results(const.sjct,toBlock_HRF,const.tracker);
    end
end

