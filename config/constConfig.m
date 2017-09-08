function [const]=constConfig(scr,const)
% ----------------------------------------------------------------------
% [const]=constConfig(scr,const,aud)
% ----------------------------------------------------------------------
% Goal of the function :
% Define all constant configurations
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

% Randomization
rng('default');rng('shuffle');

%% Colors;
const.white                         = [255,255,255];                                                        % define white color
const.black                         = [0,0,0];                                                              % define black color
const.gray                          = round([127.5,127.5,127.5]);                                           % define gray color
const.background_color              = round(([0.5,0.5,0.5]+1)*127.5);                                       % define background color
const.fixation_outer_rim_color      = (([-0.75,-0.75,-0.75]+1)*127.5);                                      % color fixation outer circle
const.fixation_rim_color            = (([1,1,1]+1)*127.5);                                                  % color fixation intermediate cirlce
const.fixation_color                = (([-0.75,-0.75,-0.75]+1)*127.5);                                      % color fixation inner circle
const.aperture_color                = round(([-0.75,-0.75,-0.75]+1)*127.5);                                 % color of the edge of the stimuli aperture
const.no_vision_color               = (([1,-1,-1]+1)*127.5);                                                % color of the area hidden by the tracker (for debug mode)

%% Standard parameters
% Across tasks parameters
const.stim_radVal                   = 3;                                                                    % stimulus radius in degrees
const.stimOffsetVal                 = [4,-1.75;-4,-1.75];                                                   % stimulus x/y offset in degrees in pRF and colormatcher task
[const.stimOffset,~]                = vaDeg2pix(const.stimOffsetVal,scr);                                   % stimulus x/y offset in pixels in pRF and colormatcher task
const.stimOffsetHRFVal              = [0,-1.75];                                                            % stimulus x/y offset in degrees in HRF task
[const.stimOffsetHRF,~]             = vaDeg2pix(const.stimOffsetHRFVal,scr);                                % stimulus x/y offset in pixels in HRF task
const.stimCtr                       = [scr.mid+const.stimOffset(1,:);scr.mid+const.stimOffset(2,:)];        % stimulus center in pixel in the color matcher and pRF task
const.stimCtrHRF                    = [scr.mid+const.stimOffsetHRF];                                        % stimulus center in pixel in the HRF task
const.TR                            = 0.944;                                                                % repetition time: time between successive pulse sequences applied to the same slice
const.element_sizeVal               = 14/60;                                                                % radius size of the elements in degrees
[const.element_size,~]              = vaDeg2pix(const.element_sizeVal,scr);                                 % radius size of the elements in pixels
const.element_sd_sizeVal            = 2.5/60;                                                               % SD rad of gabors in degrees
[const.element_sd_size,~]           = vaDeg2pix(const.element_sd_sizeVal,scr);                              % SD of gabors in pixels
const.bar_width_ratio               = 0.1;                                                                  % ratio of the circlular window
const.stim_rad                      = vaDeg2pix(const.stim_radVal,scr);                                     % stimulus radius in pixel
const.num_elements                  = 250;                                                                  % amount of elements in a bar
const.redraws_per_TR                = 3;                                                                    % TR/redraws_per_TR is the duration of a transient
const.speed                         = 4;                                                                    % speed of the fast elements
[const.pixel_per_degree,~]          = vaDeg2pix(1,scr);                                                     % one degree in pixel
const.low_spatial_frequency         = const.pixel_per_degree/(8);                                           % low spatial frequency of the elements
const.high_spatial_frequency        = const.pixel_per_degree/(16);                                          % high spatial frequency of the elements
const.time_steps                    = const.TR/const.redraws_per_TR;                                        % duration before redraw
const.MC_ratio                      = 0.5;                                                                  % ratio of red/green gabors
const.BY_ratio                      = 0.5;                                                                  % ratio of blue/yellow gabors

%% Stimuli parameters
% Fixation target
const.fix_offsetVal                 = const.stim_radVal/2;                                                  % fixation offset from center in degrees
const.fix_offset                    = vaDeg2pix(const.fix_offsetVal,scr);                                   % fixation offset from center in pixels
const.fixation_pos                  = const.stimCtr;                                                        % coordinate of the fixation target right and left
const.fixationHRF_pos               = const.stimCtrHRF;                                                     % coordinate of the fixation target in HRF exp
const.fixation_outer_rim_radVal     = 10/60;                                                                % radius of outer circle of fixation bull's eye
const.fixation_rim_radVal           = 7.5/60;                                                               % radius of intermediate circle of fixation bull's eye in degree
const.fixation_radVal               = 3.75/60;                                                              % radius of inner circle of fixation bull's eye in degrees
const.fixation_outer_rim_rad        = vaDeg2pix(const.fixation_outer_rim_radVal,scr);                       % radius of outer circle of fixation bull's eye in pixels
const.fixation_rim_rad              = vaDeg2pix(const.fixation_rim_radVal,scr);                             % radius of intermediate circle of fixation bull's eye in pixels
const.fixation_rad                  = vaDeg2pix(const.fixation_radVal,scr);                                 % radius of inner circle of fixation bull's eye in pixels

% Stimuli aperture
const.rCosine_grain                 = 40;                                                                   % grain of the radius cosine steps
const.aperture_radVal               = const.stim_radVal;                                                    % radius of the stimulus apperture
const.aperture_rad                  = vaDeg2pix(const.aperture_radVal,scr);                                 % radius of the stimulus apperture
const.aperture_blur                 = 0.1;                                                                  % ratio of the apperture that is blured following an raised cosine
const.aperture_pos                  = const.stimCtr;                                                        % coordinate of mask center right/left
const.aperture_posHRF               = const.stimCtrHRF;                                                     % coordinate of mask center in HRF experiment
const.aperture_right                = rCosMask(scr,const,const.aperture_color,const.stimCtr(1,:));          % define aperture matrix
const.aperture_left                 = rCosMask(scr,const,const.aperture_color,const.stimCtr(2,:));          % define aperture matrix
const.aperture_HRF                  = rCosMask(scr,const,const.aperture_color,const.stimCtrHRF);            % define aperture matrix in HRF exp
const.aperture_rect                 = [0;0;scr.scr_sizeX;scr.scr_sizeY];                                    % rect of the aperture

% Eyelink no vision zone
const.no_vision_widthVal            = 8;                                                                    % width of the area hiden by the tracker in degrees
const.no_vision_width               = vaDeg2pix(const.no_vision_widthVal,scr);                              % width of the area hiden by the tracker in degrees
const.no_vision_heightVal           = 3.5;                                                                  % height of the area hiden by the tracker in pixel
const.no_vision_height              = vaDeg2pix(const.no_vision_heightVal,scr);                             % height of the area hiden by the tracker in pixel
const.no_vision_rect                = [0,scr.scr_sizeY-const.no_vision_height,...                           % rect of the area hiden by the tracker
                                       0+const.no_vision_width,scr.scr_sizeY];                              
                                   
% Eyelink calibration value
const.maxX                          = scr.scr_sizeX*0.75;                                                   % maximum horizontal amplitude of the screen
const.maxY                          = (scr.scr_sizeY*0.75)-const.no_vision_height;                          % maximum vertical amplitude of the screen

const.calib_maxX                    = const.maxX/2;
const.calib_maxY                    = const.maxY/2;
const.calib_center                  = [scr.scr_sizeX/2,const.stimCtr(1,2)];


const.calibCoord                    = round([const.calib_center(1),                     const.calib_center(2),...                       % 01.  center center
                                             const.calib_center(1),                     const.calib_center(2)-const.calib_maxY,...      % 02.  center up
                                             const.calib_center(1),                     const.calib_center(2)+const.calib_maxY,...      % 03.  center down
                                             const.calib_center(1)-const.calib_maxX,    const.calib_center(2),....                      % 04.  left center
                                             const.calib_center(1)+const.calib_maxX,    const.calib_center(2),...                       % 05.  right center
                                             const.calib_center(1)-const.calib_maxX,    const.calib_center(2)-const.calib_maxY,....     % 06.  left up
                                             const.calib_center(1)+const.calib_maxX,    const.calib_center(2)-const.calib_maxY,...      % 07.  right up
                                             const.calib_center(1)-const.calib_maxX,    const.calib_center(2)+const.calib_maxY,....     % 08.  left down
                                             const.calib_center(1)+const.calib_maxX,    const.calib_center(2)+const.calib_maxY,...      % 09.  right down
                                             const.calib_center(1)-const.calib_maxX/2,  const.calib_center(2)-const.calib_maxY/2,....   % 10.  mid left mid up 
                                             const.calib_center(1)+const.calib_maxX/2,  const.calib_center(2)-const.calib_maxY/2,....   % 11.  mid right mid up 
                                             const.calib_center(1)-const.calib_maxX/2,  const.calib_center(2)+const.calib_maxY/2,....   % 12.  mid left mid down 
                                             const.calib_center(1)+const.calib_maxX/2,  const.calib_center(2)+const.calib_maxY/2]);     % 13.  mid right mid down

% close all                                         
% hold on;
% coordX = [1:2:numel(const.calibCoord)-1];
% coordY = [2:2:numel(const.calibCoord)];
% for t = 1:numel(const.calibCoord)/2;
%     set(gca,'XLim',[0,scr.scr_sizeX],'YLim',[0,scr.scr_sizeY],'YDir','reverse');
%     plot(const.calibCoord(coordX(t)),const.calibCoord(coordY(t)),'o');pause(1);
% end
                                         
const.valid_maxX                    = const.calib_maxX * 0.9;
const.valid_maxY                    = const.calib_maxY * 0.9;
const.valid_center                  = const.calib_center;

const.validCoord                    = round([const.valid_center(1),                     const.valid_center(2),...                       % 01.  center center
                                             const.valid_center(1),                     const.valid_center(2)-const.valid_maxY,...      % 02.  center up
                                             const.valid_center(1),                     const.valid_center(2)+const.valid_maxY,...      % 03.  center down
                                             const.valid_center(1)-const.valid_maxX,    const.valid_center(2),....                      % 04.  left center
                                             const.valid_center(1)+const.valid_maxX,    const.valid_center(2),...                       % 05.  right center
                                             const.valid_center(1)-const.valid_maxX,    const.valid_center(2)-const.valid_maxY,....     % 06.  left up
                                             const.valid_center(1)+const.valid_maxX,    const.valid_center(2)-const.valid_maxY,...      % 07.  right up
                                             const.valid_center(1)-const.valid_maxX,    const.valid_center(2)+const.valid_maxY,....     % 08.  left down
                                             const.valid_center(1)+const.valid_maxX,    const.valid_center(2)+const.valid_maxY,...      % 09.  right down
                                             const.valid_center(1)-const.valid_maxX/2,  const.valid_center(2)-const.valid_maxY/2,....   % 10.  mid left mid up 
                                             const.valid_center(1)+const.valid_maxX/2,  const.valid_center(2)-const.valid_maxY/2,....   % 11.  mid right mid up 
                                             const.valid_center(1)-const.valid_maxX/2,  const.valid_center(2)+const.valid_maxY/2,....   % 12.  mid left mid down 
                                             const.valid_center(1)+const.valid_maxX/2,  const.valid_center(2)+const.valid_maxY/2]);     % 13.  mid right mid down
                                         
% coordX = [1:2:numel(const.validCoord)-1];
% coordY = [2:2:numel(const.validCoord)];
% for t = 1:numel(const.validCoord)/2;
%     set(gca,'XLim',[0,scr.scr_sizeX],'YLim',[0,scr.scr_sizeY],'YDir','reverse');
%     plot(const.validCoord(coordX(t)),const.validCoord(coordY(t)),'+');pause(1);
% end
                                         
%% Task parameters                          
% Color matching task parameters
if const.typeTask == 1
    % Trial parameters (duration, phases, number of trials)
    const.phase_duration            = [-0.0001,...                                                          % phase 0: instrutions (seconds)
                                       -0.0001,...                                                          % phase 1: empty
                                        1    ,...                                                           % phase 2: fixation (seconds)
                                       -0.0001,...                                                          % phase 3: color adjustment until response
                                       0.001];                                                              % phase 4: after response time (seconds)
    const.num_trials_colMatcher     = 20;                                                                   % number of color matching task
    
    % Stim parameters
    const.numGab                    = const.num_elements * (1/const.bar_width_ratio);                       % number of gabor to draw
    const.MC_offsets                = rand(1,const.num_trials_colMatcher);                                  % offset of the red-green colors on each trials
    const.positionOrdered           = repmat([0,1], 1,const.num_trials_colMatcher/2);                       % ordered position for the color matching stimulus
    const.positionRandom            = const.positionOrdered(randperm(const.num_trials_colMatcher));         % randomized position for the color matching stimulus
    const.color_step                = 0.02;                                                                 % color step
    const.BY_comparison_color       = 0.5;                                                                  % color level to compare to
    const.yellow_colMatcher         = ([const.BY_comparison_color,const.BY_comparison_color,...             % define yellow of gabor in color matcher task
                                        -const.BY_comparison_color]+1)*(127.5);
    const.blue_colMatcher           = ([-const.BY_comparison_color,-const.BY_comparison_color,...           % define yellow of gabor in color matcher task
                                        const.BY_comparison_color]+1)*(127.5);
    const.magenta_colMatcher        = ([const.BY_comparison_color,-const.BY_comparison_color,0]+1)*(127.5); % define magenta of gabor in color matcher task
    const.cyan_colMatcher           = ([-const.BY_comparison_color,const.BY_comparison_color,0]+1)*(127.5); % define cyan of gabor in color matcher task
    
    
    % pre-define the color gabors
    const.MC_gab_low_sfq            = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,0,const.magenta_colMatcher,const.cyan_colMatcher);
    const.CM_gab_low_sfq            = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,0,const.cyan_colMatcher,const.magenta_colMatcher);
    const.MC_gab_high_sfq           = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,0,const.magenta_colMatcher,const.cyan_colMatcher);
    const.CM_gab_high_sfq           = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,0,const.cyan_colMatcher,const.magenta_colMatcher);
    
    const.BY_gab_low_sfq            = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,0,const.blue_colMatcher,const.yellow_colMatcher);
    const.YB_gab_low_sfq            = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,0,const.yellow_colMatcher,const.blue_colMatcher);
    const.BY_gab_high_sfq           = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,0,const.blue_colMatcher,const.yellow_colMatcher);
    const.YB_gab_high_sfq           = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,0,const.yellow_colMatcher,const.blue_colMatcher);
    
    
	% parameters draw in log/edf files
    const.parameter{01,1} = 'bar_width_ratio';                     const.parameter{01,2} = const.bar_width_ratio;
    const.parameter{02,1} = 'stim_size';                           const.parameter{02,2} = const.stim_radVal*2;
    const.parameter{03,1} = 'low_spatial_frequency';               const.parameter{03,2} = const.low_spatial_frequency;
    const.parameter{04,1} = 'high_spatial_frequency';              const.parameter{04,2} = const.high_spatial_frequency;
    const.parameter{05,1} = 'num_elements';                        const.parameter{05,2} = const.num_elements;
    const.parameter{06,1} = 'element_size';                        const.parameter{06,2} = const.element_size;
    const.parameter{07,1} = 'element_sd';                          const.parameter{07,2} = const.element_sd_size;
    const.parameter{08,1} = 'TR';                                  const.parameter{08,2} = const.TR;
    const.parameter{09,1} = 'num_trials';                          const.parameter{09,2} = const.num_trials_colMatcher;
    const.parameter{10,1} = 'BY_comparison_color';                 const.parameter{10,2} = const.BY_comparison_color;
    const.parameter{11,1} = 'MC_offset';                           const.parameter{11,2} = NaN;
end

% pRF task parameters
if const.typeTask == 2
    % Trial parameters
    const.task                      = {'Color','Fix_no_stim'};                                              % task name
    const.pRF_period_in_TR          = 32;                                                                   % stim period step (32*TR = 30.2 seconds)
    const.pRF_ITI_in_TR             = 0.5;                                                                  % inter trial interval per TR (0.5*TR = 0.47s)
    const.phase_duration            = [-0.0001,...                                                          % phase 0: instrutions (seconds)
                                       -0.0001,...                                                          % phase 1: empty
                                       -0.0001,...                                                          % phase 2: wait for TR (seconds)
                                       const.pRF_period_in_TR*const.TR,...                                  % phase 3: stimulation time (seconds)
                                       const.pRF_ITI_in_TR*const.TR];                                       % phase 4: inter-trial interval (seconds)
	if const.practice
    	const.subtasks              = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];                                    % task (0 = color; 1 = fix no stim)
    	const.subdirections         = [0,1,5,4,7,6,3,2,0,1,5,4,7,6,3,2];                                    % mapper direction (0 = 0 deg, 1 = 45 deg, 2 =  90 deg, 3 = 135 deg, 4 = 180 deg, 5 = 225 deg, 6 = 270 deg, 7 = 315 deg)
    else
    	const.subtasks              = [1,0,1,0,0,1,0,0,1,0,0,1,0,1];                                        % task (0 = color; 1 = fix no stim)
        const.subdirections         = [0,0,0,1,6,0,7,4,0,3,2,0,5,0];                                        % mapper direction (0 = 0 deg, 1 = 45 deg, 2 =  90 deg, 3 = 135 deg, 4 = 180 deg, 5 = 225 deg, 6 = 270 deg, 7 = 315 deg)
	end
    
    % Stimuli parameters
    const.numGab                    = const.num_elements;                                                   % number of gabor to draw
    const.full_width                = const.stim_rad*2 * (1+const.bar_width_ratio);                         % width of the mapper bar in pixel
	const.period                    = const.pRF_period_in_TR*const.TR;                                      % stimulus period
    const.directions                = 0:pi/4:2*pi-pi/4;                                                     % pRF mapper directions (radian)
    const.refresh_frequency         = const.redraws_per_TR/const.TR;                                        % redraw of color, orientation and position of single elements
    if const.expStart
        const.line                  = fgetl(const.colRatio_fid);                                            % read color file
        const.MC_BY_ratio           = str2double(const.line(end-3:end));                                    % get MC/BY ratio
    else
        const.MC_BY_ratio           = 1;                                                                    % define default MC/BY ratio for debug mode
    end
    if const.MC_BY_ratio > 1
        const.MC_col                = 1;                                                                    % MC color value in psychopy color scale
        const.BY_col                = 1/const.MC_BY_ratio;                                                  % BY color value in psychopy color scale
    else
        const.MC_col                = 1/const.MC_BY_ratio;                                                  % MC color value in psychopy color scale
        const.BY_col                = 1;                                                                    % BY color value in psychopy color scale
    end
    if const.MC_col >1;             const.MC_col = 1;end
    if const.BY_col >1;             const.BY_col = 1;end
    
    const.MCBY_mean                 = mean([const.MC_col,const.BY_col]);                                    % mean MC BY color for gray gabors
    if const.MCBY_mean > 1;         const.MCBY_mean = 1;end
    
    const.colPulseMagenta           = ([const.MC_col,-const.MC_col,0]+1)*127.5;                             % define magenta during pulse redraw
    const.colPulseCyan              = ([-const.MC_col,const.MC_col,0]+1)*127.5;                             % define cyan during pulse redraw
    const.colPulseYellow            = ([const.BY_col,const.BY_col,-const.BY_col]+1)*127.5;                  % define yellow during pulse redraw
    const.colPulseBlue              = ([-const.BY_col,-const.BY_col,const.BY_col]+1)*127.5;                 % define blue during pulse redraw
    const.colNoPulseWhite           = ([const.MCBY_mean,const.MCBY_mean,const.MCBY_mean]+1)*127.5;          % white color during no pulse redraw
    const.colNoPulseBlack           = ([-const.MCBY_mean,-const.MCBY_mean,-const.MCBY_mean]+1)*127.5;       % black color during no pulse redraw

    % Staircase parameters
    
    % compute distance between fixation position and both end of the bar
    const.nr_staircases_ecc         = 3;                                                                    % number of eccentricity separate staircase
    for tFixPos = 1:size(const.fixation_pos,1)
        const.meanDistAll = [];
        for tOri = 1:size(const.directions,2);
            for possible_phase = linspace(0,1,const.pRF_period_in_TR)
                midpoint            = possible_phase * const.full_width - 0.5 * const.full_width;
                rotation_matrix     = [cos(const.directions(tOri)),sin(const.directions(tOri));sin(const.directions(tOri)),-cos(const.directions(tOri))];
                barLeftEnd          = (([-const.stim_rad,-midpoint]) * rotation_matrix) + const.stimCtr(tFixPos,:);
                barRightEnd         = (([const.stim_rad,-midpoint]) * rotation_matrix) + const.stimCtr(tFixPos,:);
                distFixBarLeftEnd   = sqrt((barLeftEnd(1)-const.fixation_pos(tFixPos,1))^2+(barLeftEnd(2)-const.fixation_pos(tFixPos,2))^2);
                distFixBarRightEnd  = sqrt((barRightEnd(1)-const.fixation_pos(tFixPos,1))^2+(barRightEnd(2)-const.fixation_pos(tFixPos,2))^2);
                meanDist            = mean([distFixBarLeftEnd,distFixBarRightEnd]);
                const.meanDistAll   = [const.meanDistAll;tFixPos,tOri,possible_phase,meanDist];
            end
        end
        const.valBin(tFixPos,:)     = prctile(const.meanDistAll(:,4),...                                    % mean distance values between each bin
                                                linspace(0,100,const.nr_staircases_ecc+1));
    end

    if const.staircaseType == 1
        const.quest_pThreshold          = 0.83;                                                             % color quest: threshold criterion expressed as probability of response
        const.quest_beta                = 3.5;                                                              % color quest: steepness of the Weibull psychometric function
        const.quest_gamma               = 0;                                                                % color quest: fraction of trials that will generate response 1 when intensity==-inf.
        const.quest_grain               = 0.01;                                                             % color quest: quantization (step size) of the internal table. E.g. 0.01.
        const.quest_range               = [];                                                               % color quest: intensity difference between the largest and smallest intensity that the internal table can store
        const.quest_delta               = 0.05;                                                             % color quest: fraction of trials on which observer presses blindly
        const.quest_qColor_tGuess       = 2.5;                                                              % color quest: threshold estimate
        const.quest_qColor_tGuessSd     = const.quest_qColor_tGuess * 0.5;                                  % color quest: standard deviation of the threshold estimate
    elseif const.staircaseType == 2
        const.stair_pThreshold          = 0.794;                                                            % color staircase: convergence threshold value
        const.stair_color_startVal      = 1;                                                                % color staircase: starting point
        const.stair_grain               = 0.10;
        const.good_trial_for_harder     = 3;                                                                % color staircase: amount of trials before (harder) staircase update
    	const.bad_trial_for_easier      = 1;                                                                % color staircase: amount of trials before (easier) staircase update
    end
    
    % parameters draw in log/edf files
    const.parameter{01,1} = 'bar_width_ratio';                     const.parameter{01,2} = const.bar_width_ratio;
    const.parameter{02,1} = 'stim_size';                           const.parameter{02,2} = const.stim_radVal*2;
    const.parameter{03,1} = 'low_spatial_frequency';               const.parameter{03,2} = const.low_spatial_frequency;
    const.parameter{04,1} = 'high_spatial_frequency';              const.parameter{04,2} = const.high_spatial_frequency;
    const.parameter{05,1} = 'num_elements';                        const.parameter{05,2} = const.num_elements;
    const.parameter{06,1} = 'element_size';                        const.parameter{06,2} = const.element_size;
    const.parameter{07,1} = 'element_sd';                          const.parameter{07,2} = const.element_sd_size;
    const.parameter{08,1} = 'MC_color';                            const.parameter{08,2} = const.MC_col;
    const.parameter{09,1} = 'BY_color';                            const.parameter{09,2} = const.BY_col;
    const.parameter{10,1} = 'TR';                                  const.parameter{10,2} = const.TR;
    const.parameter{11,1} = 'PRF_period_in_TR';                    const.parameter{11,2} = const.pRF_period_in_TR;
    const.parameter{12,1} = 'PRF_ITI_in_TR';                       const.parameter{12,2} = const.pRF_ITI_in_TR;
    const.parameter{13,1} = 'redraws_per_TR';                      const.parameter{13,2} = const.redraws_per_TR;
    const.parameter{14,1} = 'fixation';                            const.parameter{14,2} = NaN;
    const.parameter{15,1} = 'orientation';                         const.parameter{15,2} = NaN;
    const.parameter{16,1} = 'task_index';                          const.parameter{16,2} = NaN;
    
end

% HRF mapper
if const.typeTask == 3
    % Trial parameters
    const.task                      = {'Fix','Fix_no_stim'};                                                % task name
    const.HRF_stim_in_TR            = 1;                                                                    % HRF mapper stimulus per TR
    const.HRF_ITI_in_TR             = 0.5;                                                                  % inter trial interval per TR (0.5*TR giving 1TR)
    const.phase_duration            = [-0.0001,...                                                          % phase 0: instrutions (seconds)
                                       -0.0001,...                                                          % phase 1: empty
                                       -0.0001,...                                                          % phase 2: wait for TR (seconds)
                                       const.HRF_stim_in_TR*const.TR,...                                    % phase 3: stimulation time (seconds)
                                       const.HRF_ITI_in_TR*const.TR];                                       % phase 4: inter-trial interval (seconds)
	const.numTrialsMainSeq          = 120;                                                                  % number of trials of the main sequence
	const.mainSeq                   = repmat([1,1,0],1,const.numTrialsMainSeq/3);                           % main sequence trial order not randomized (0 = Fix; 1 = Fix no stim)
	const.subtasks                  = [1,1,1,1,1,const.mainSeq(randperm(numel(const.mainSeq))),1,1,1,1,1];  % all trial randomized with no stim at the start and end
    const.fixtask                   = round(rand(1,numel(const.subtasks)));                                 % occurence of the fixation color change (0 = yes, 1 = no)
    
    % Stimuli parameters
    const.numGab                    = const.num_elements * (1/const.bar_width_ratio);                       % number of gabor to draw
    const.period                    = const.HRF_stim_in_TR*const.TR;                                        % stimulus period
    const.refresh_frequency         = const.redraws_per_TR/const.TR;                                        % redraw of color, orientation and position of single elements
    if const.expStart
        const.line                  = fgetl(const.colRatio_fid);                                            % read color file
        const.MC_BY_ratio           = str2double(const.line(end-3:end));                                    % get MC/BY ratio
    else
        const.MC_BY_ratio           = 1;                                                                    % define default MC/BY ratio for debug mode
    end
    if const.MC_BY_ratio > 1
        const.MC_col                = 1;                                                                    % MC color value in psychopy color scale
        const.BY_col                = 1/const.MC_BY_ratio;                                                  % BY color value in psychopy color scale
    else
        const.MC_col                = 1/const.MC_BY_ratio;                                                  % MC color value in psychopy color scale
        const.BY_col                = 1;                                                                    % BY color value in psychopy color scale
    end
    if const.MC_col >1;             const.MC_col = 1;end
    if const.BY_col >1;             const.BY_col = 1;end
    
    const.MCBY_mean                 = mean([const.MC_col,const.BY_col]);                                    % mean MC BY color for gray gabors
    if const.MCBY_mean > 1;         const.MCBY_mean = 1;end
    
    const.colPulseMagenta           = ([const.MC_col,-const.MC_col,0]+1)*127.5;                             % define magenta during pulse redraw
    const.colPulseCyan              = ([-const.MC_col,const.MC_col,0]+1)*127.5;                             % define cyan during pulse redraw
    const.colPulseYellow            = ([const.BY_col,const.BY_col,-const.BY_col]+1)*127.5;                  % define yellow during pulse redraw
    const.colPulseBlue              = ([-const.BY_col,-const.BY_col,const.BY_col]+1)*127.5;                 % define blue during pulse redraw

    % Staircase parameters
    % compute distance between fixation position and both end of the bar
    if const.staircaseType == 1
        const.quest_pThreshold          = 0.83;                                                             % fix quest: threshold criterion expressed as probability of response
        const.quest_beta                = 3.5;                                                              % fix quest: steepness of the Weibull psychometric function
        const.quest_gamma               = 0;                                                                % fix quest: fraction of trials that will generate response 1 when intensity==-inf.
        const.quest_grain               = 0.01;                                                             % fix quest: quantization (step size) of the internal table. E.g. 0.01.
        const.quest_range               = [];                                                               % fix quest: intensity difference between the largest and smallest intensity that the internal table can store
        const.quest_delta               = 0.05;                                                             % fix quest: fraction of trials on which observer presses blindly
        const.quest_qFix_tGuess         = 0.4;                                                              % fix quest: threshold estimate
        const.quest_qFix_tGuessSd       = const.quest_qFix_tGuess * 0.35;                                   % fix quest: standard deviation of the threshold estimate
    elseif const.staircaseType == 2
        const.stair_pThreshold          = 0.794;                                                            % fix staircase: convergence threshold value
        const.stair_fix_startVal        = 0.4;                                                              % fix staircase: starting point
        const.stair_grain               = 0.10;
        const.good_trial_for_harder     = 3;                                                                % fix staircase: amount of trials before (harder) staircase update
    	const.bad_trial_for_easier      = 1;                                                                % fix staircase: amount of trials before (easier) staircase update
    end
    
    % parameters draw in log/edf files
    const.parameter{01,1} = 'stim_size';                           const.parameter{01,2} = const.stim_radVal*2;
    const.parameter{02,1} = 'low_spatial_frequency';               const.parameter{02,2} = const.low_spatial_frequency;
    const.parameter{03,1} = 'high_spatial_frequency';              const.parameter{03,2} = const.high_spatial_frequency;
    const.parameter{04,1} = 'num_elements';                        const.parameter{04,2} = const.num_elements;
    const.parameter{05,1} = 'element_size';                        const.parameter{05,2} = const.element_size;
    const.parameter{06,1} = 'element_sd';                          const.parameter{06,2} = const.element_sd_size;
    const.parameter{07,1} = 'MC_color';                            const.parameter{07,2} = const.MC_col;
    const.parameter{08,1} = 'BY_color';                            const.parameter{08,2} = const.BY_col;
    const.parameter{09,1} = 'TR';                                  const.parameter{09,2} = const.TR;
    const.parameter{10,1} = 'HRF_stim_in_TR';                      const.parameter{10,2} = const.HRF_stim_in_TR;
    const.parameter{11,1} = 'HRF_ITI_in_TR';                       const.parameter{11,2} = const.HRF_ITI_in_TR;
    const.parameter{12,1} = 'pulse_index';                         const.parameter{12,2} = NaN;
    const.parameter{13,1} = 'task_index';                          const.parameter{13,2} = NaN;
    
end