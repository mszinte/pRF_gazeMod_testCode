function [resMat,expDes]=runSingleTrial(scr,const,expDes,my_key,t)
% ----------------------------------------------------------------------
% [resMat,expDes]=runSingleTrial(scr,const,expDes,my_key,t)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw stimuli of each indivual trial and waiting for inputs
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : struct containg experimental design
% my_key : structure containing keyboard configurations
% t : trial number
% ----------------------------------------------------------------------
% Output(s):
% resMat : experimental results (see below)
% expDes : struct containing all the variable design configurations.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

%% Compute and simplify var and rand
%  ---------------------------------
if const.checkTrial && ~const.expStart
    fprintf(1,'\n\n\t========================  TRIAL %3.0f ========================\n',t-1);
end

if const.typeTask == 1
    % Rand 1 : MC offset
    rand1 = expDes.expMat(t,3);
    if const.checkTrial && ~const.expStart;fprintf(1,'\n\tMC offset = \t\t%1.2f',rand1);end
    
    % Rand 2 : fixation offset
    rand2 = expDes.expMat(t,4);
    txt_rand2 = {'right','left'};
    if const.checkTrial && ~const.expStart;fprintf(1,'\n\tFixation postion = \t%s',txt_rand2{rand2+1});end
    stim.fixPos = const.fixation_pos(rand2+1,:);
    stim.rand2 = rand2;
    switch rand2
        case 0; aperture = const.aperture_right;
        case 1; aperture = const.aperture_left;
    end
    
elseif const.typeTask == 2
    % Cond1 : fixation position
    cond1 = expDes.expMat(t,3);
    stim.fixPos = const.fixation_pos(cond1+1,:);
    stim.cond1 = cond1;
    txt_cond1 = {'right','left'};
    if const.checkTrial && ~const.expStart;fprintf(1,'\n\tFixation postion = \t%s',txt_cond1{cond1+1});end
    switch cond1
        case 0; aperture = const.aperture_right;
        case 1; aperture = const.aperture_left;
    end
    % Var 1 : orientation
    var1 = expDes.expMat(t,4);
    txt_var1 = {'0 deg','45 deg','90 deg','135 deg','180 deg','225 deg','270 deg','315 deg'};
    if const.checkTrial && ~const.expStart;fprintf(1,'\n\tOrientation = \t\t%s',txt_var1{var1+1});end
    
    % Var 2 : type of task
    var2 = expDes.expMat(t,5);
    txt_var2 = {'color','fixation no stim'};
    if const.checkTrial && ~const.expStart;fprintf(1,'\n\tTask = \t\t\t%s',txt_var2{var2+1});end
    
elseif const.typeTask == 3    
    stim.fixPos = const.fixationHRF_pos;
    aperture = const.aperture_HRF;
    
    % Var 1 : type of task
    var1 = expDes.expMat(t,3);stim.var1 = var1;
    txt_var1 = {'fixation','fixation no stim'};
    if const.checkTrial && ~const.expStart;fprintf(1,'\n\tTask = \t\t\t%s',txt_var1{var1+1});end
    
    % Var 2 : pulse presence
    var2 = expDes.expMat(t,4);stim.var2 = var2;
    txt_var2 = {'present','absent'};
    if const.checkTrial && ~const.expStart;fprintf(1,'\n\tPulse = \t\t\t%s',txt_var2{var2+1});end
    
end

%% Prepare stimuli
%  ---------------
stim.first_time                 = 1;    % button to avoid deleting texture not yet created
stim.computePhase               = 1;    % compute new phase based on current time
stim.genPos                     = 1;    % generate new positions (1=yes, 2=no)
stim.genOrientation             = 1;    % generate new orientations (1=yes, 2=no)
stim.genColor                   = 1;    % generate new colors (1=yes, 2=no)
stim.genSfq                     = 1;    % generate new spatial frequency (1=yes, 2=no)

% Color matching task
if const.typeTask == 1
    stim.computePhase           = 0;
    stim.MC_col                 = rand1;
    stim.tex                    = zeros(const.numGab,1);
    stim.genPhase               = 0;
    stim.MC_ratio               = const.MC_ratio;
    stim.BY_ratio               = const.BY_ratio;
    stim.BY_gabTex_low_sfq      = Screen('MakeTexture',scr.main,const.BY_gab_low_sfq);
    stim.YB_gabTex_low_sfq      = Screen('MakeTexture',scr.main,const.YB_gab_low_sfq);
    stim.BY_gabTex_high_sfq     = Screen('MakeTexture',scr.main,const.BY_gab_high_sfq);
    stim.YB_gabTex_high_sfq     = Screen('MakeTexture',scr.main,const.YB_gab_high_sfq);
    
% pRF task
elseif const.typeTask == 2
    stim.eccentricity_bin       = -1;
    stim.redraws                = 0;
    stim.mapper_orientation     = const.directions(var1+1);
    stim.rotation_matrix        = [cos(stim.mapper_orientation),sin(stim.mapper_orientation);sin(stim.mapper_orientation),-cos(stim.mapper_orientation)];
    stim.current_phase          = 0;
    stim.midpoint               = -0.5 * const.full_width;
    stim.var2                   = var2;
    stim.MC_ratio               = const.MC_ratio;
    stim.BY_ratio               = const.BY_ratio;
    stim.pulse                  = 0;

elseif const.typeTask == 3
    stim.redraws                = 0;
    stim.current_phase          = 0;
    stim.MC_ratio               = const.MC_ratio;
    stim.BY_ratio               = const.BY_ratio;
    stim.pulse                  = 0;
    stim.fixation_color         = const.fixation_rim_color;
end

% Generate stimuli aperture
aperture_tex  = Screen('MakeTexture',scr.main,aperture);
aperture_rect = const.aperture_rect;

% Set button flag to 0
key_press.y             = 0;
key_press.e             = 0;
key_press.b             = 0;
key_press.t             = 0;
key_press.escape        = 0;
trial_stop              = 0;

% Define settings for FRPS checks
if const.checkFRPS
    tstart = GetSecs;
    count = 0;
end

% Define settings for test mode of scanner
if ~const.scanner && const.scannerTest
	last_t_time = GetSecs;
end

%% Trial loop
%  ----------
while ~trial_stop
    
    %% Main clock
    %  ----------
	current_time = GetSecs;
    
    %% Phase checker
    %  -------------
    switch expDes.phase
        case 1 
            % Color matching task = Empty 
            % pRF task = Empty
            if current_time - expDes.instructTime > const.phase_duration(2)
                expDes = phase_forward(const,expDes,t);
                phase1_time_end = current_time;
            end
        case 2
            % Color matching task = Fixation time
            if const.typeTask == 1  
                if current_time - phase1_time_end > const.phase_duration(3);
                    expDes = phase_forward(const,expDes,t);
                    last_redraw_time    = current_time - 1.5*const.time_steps; % use in phase == 3
                end
            % pRF exp = wait for TR
            elseif const.typeTask == 2 || const.typeTask == 3
                if ~const.scanner && ~const.scannerTest;
                    expDes = phase_forward(const,expDes,t);
                    phase2_time_end = current_time;
                else
                    % wait for t press
                end
            end
        case 3
            % Color matching task = stim presentation until button Y press
            if const.typeTask == 1
                % none
            % pRF task = mapper stim
            elseif const.typeTask == 2 || const.typeTask == 3
                if current_time - phase2_time_end > const.phase_duration(4);
                    expDes = phase_forward(const,expDes,t);
                    phase3_time_end = current_time;
                end
            end
        case 4
            % Color matching task = end
            if const.typeTask == 1      
                if current_time - phase3_time_end > const.phase_duration(5);
                    trial_stop = 1;
                end
            % pRF task = inter-trial interval
            elseif const.typeTask == 2 || const.typeTask == 3
                if current_time - phase3_time_end > const.phase_duration(5);
                    trial_stop = 1;
                end
            end
    end

    %% Drawings
    %  --------
    % drawing background
    % ------------------
    Screen('FillRect',scr.main,const.background_color);
    
    % drawing main stimuli
    % --------------------
    if expDes.phase == 1
        % no stimuli
    elseif expDes.phase == 2
        % no stimuli
    elseif expDes.phase == 3
        if const.typeTask == 1
            if current_time-last_redraw_time >= const.time_steps;                                                               % define redraw
                last_redraw_time = current_time;
                log_txt = sprintf('stimulus redraw at %f',current_time);
                fprintf(const.log_text_fid,'%s\n',log_txt);                                                                     % write in log
                if const.tracker;Eyelink('message','%s', log_txt);end                                                           % write in edf
                [stim] = generateStim(scr,const,stim);                                                                          % generate stimuli
            end
            Screen('DrawTextures',scr.main,stim.tex,[],stim.rect,stim.orientiation);                                            % Draw stimuli
        elseif const.typeTask == 2
            stim.current_phase = max([(current_time - phase2_time_end)/const.phase_duration(4),0]);
            if stim.redraws <= (stim.current_phase * const.period * const.refresh_frequency)                
                if mod(stim.redraws,const.redraws_per_TR) == 0
                    stim.midpoint = stim.current_phase * const.full_width - 0.5 * const.full_width;
                end
                if mod(stim.redraws,const.redraws_per_TR) == 1
                    stim.pulse = 1;
                else
                    stim.pulse = 0;
                end
                if const.staircaseType == 1
                    [expDes,stim] = getQuest(const,expDes,stim,current_time,t);
                elseif const.staircaseType == 2
                    [expDes,stim] = getStaircase(const,expDes,stim,current_time,t);
                end
                stim.computePhase       = 1;                                                                                    % compute new phase based on current time
                stim.genPos             = 1;                                                                                    % generate new positions (1=yes, 2=no)
                stim.genOrientation     = 1;                                                                                    % generate new orientations (1=yes, 2=no)
                stim.genColor           = 1;                                                                                    % generate new colors (1=yes, 2=no)
                stim.genSfq             = 1;                                                                                    % generate new spatial frequency (1=yes, 2=no)
                log_txt = sprintf('stimulus draw for phase %f, at %f',stim.current_phase,current_time);
                fprintf(const.log_text_fid,'%s\n',log_txt);                                                                     % write in log
                if const.tracker;Eyelink('message','%s', log_txt);end                                                           % write in edf
                [stim] = generateStim(scr,const,stim);                                                                          % generate stimuli
                stim.redraws = stim.redraws + 1;
            else
                % Generate phase change
                stim.computePhase   = 1;                                                                                        % compute new phase based on current time
                stim.genPos         = 0;                                                                                        % generate new positions (1=yes, 2=no)
                stim.genOrientation = 0;                                                                                        % generate new orientations (1=yes, 2=no)
                stim.genColor       = 0;                                                                                        % generate new colors (1=yes, 2=no)
                stim.genSfq         = 0;                                                                                        % generate new spatial frequency (1=yes, 2=no)
                [stim] = generateStim(scr,const,stim);                                                                          % generate stimuli
            end
            if var2 ~= 1;Screen('DrawTextures',scr.main,stim.tex,[],stim.rect,stim.orientiation);end                            % Draw stimuli
        elseif const.typeTask == 3
            
            stim.current_phase = max([(current_time - phase2_time_end)/const.phase_duration(4),0]);
            if stim.redraws <= (stim.current_phase * const.period * const.refresh_frequency)
                if mod(stim.redraws,const.redraws_per_TR) == 1
                    if stim.var2 == 0
                        stim.pulse = 1;
                    elseif stim.var2 == 1
                        stim.pulse = 0;
                    end
                else
                    stim.pulse = 0;
                end
                if const.staircaseType == 1
                    [expDes,stim] = getQuest(const,expDes,stim,current_time,t);
                elseif const.staircaseType == 2
                    [expDes,stim] = getStaircase(const,expDes,stim,current_time,t);
                end
                
                stim.computePhase       = 1;                                                                                    % compute new phase based on current time
                stim.genPos             = 1;                                                                                    % generate new positions (1=yes, 2=no)
                stim.genOrientation     = 1;                                                                                    % generate new orientations (1=yes, 2=no)
                stim.genColor           = 1;                                                                                    % generate new colors (1=yes, 2=no)
                stim.genSfq             = 1;                                                                                    % generate new spatial frequency (1=yes, 2=no)
                log_txt = sprintf('stimulus draw for phase %f, at %f',stim.current_phase,current_time);
                fprintf(const.log_text_fid,'%s\n',log_txt);                                                                     % write in log
                if const.tracker;Eyelink('message','%s', log_txt);end                                                           % write in edf
                [stim] = generateStim(scr,const,stim);                                                                          % generate stimuli
                stim.redraws = stim.redraws + 1;
            else
                % Generate phase change
                stim.computePhase   = 1;                                                                                        % compute new phase based on current time
                stim.genPos         = 0;                                                                                        % generate new positions (1=yes, 2=no)
                stim.genOrientation = 0;                                                                                        % generate new orientations (1=yes, 2=no)
                stim.genColor       = 0;                                                                                        % generate new colors (1=yes, 2=no)
                stim.genSfq         = 0;                                                                                        % generate new spatial frequency (1=yes, 2=no)
                [stim] = generateStim(scr,const,stim);                                                                          % generate stimuli
            end
            if var1 ~= 1;Screen('DrawTextures',scr.main,stim.tex,[],stim.rect,stim.orientiation);end                            % Draw stimuli
        end
    elseif expDes.phase == 4
        % no stimuli
    end
    
    % drawing fixation bull's eye
    % ---------------------------
    if const.typeTask == 2
        my_circle(scr,const.fixation_outer_rim_color,stim.fixPos,const.fixation_outer_rim_rad);                                 % Draw fixation point outer rim
        my_circle(scr,const.fixation_rim_color,stim.fixPos,const.fixation_rim_rad);                                             % Draw fixation point rim
        my_circle(scr,const.fixation_color,stim.fixPos,const.fixation_rad);                                                     % Draw fixation point
    elseif const.typeTask == 3
        if stim.pulse
            my_circle(scr,const.fixation_outer_rim_color,stim.fixPos,const.fixation_outer_rim_rad);                             % Draw fixation point outer rim
            my_circle(scr,stim.fixation_color,stim.fixPos,const.fixation_rim_rad);                                              % Draw fixation point rim
        else
            my_circle(scr,const.fixation_outer_rim_color,stim.fixPos,const.fixation_outer_rim_rad);                             % Draw fixation point outer rim
            my_circle(scr,const.fixation_rim_color,stim.fixPos,const.fixation_rim_rad);                                         % Draw fixation point rim
            my_circle(scr,const.fixation_color,stim.fixPos,const.fixation_rad);                                                 % Draw fixation point
        end
        
    end
    
    % drawing stimuli aperture
    % ------------------------
    Screen('DrawTexture',scr.main,aperture_tex,[],aperture_rect);
    
    % draw hidden area by tracker (debug mode only)
    % ---------------------------
    if ~const.expStart && const.trackerBox
        Screen('FillRect',scr.main,const.no_vision_color,const.no_vision_rect);
    end
    
    % check drawing duration
    % ----------------------
    if const.checkFRPS
        [telapsed] = Screen('DrawingFinished',scr.main,[],1);
        fprintf(const.log_text_fid,'DrawingFinished phase %i = %f\n',expDes.phase,telapsed);
    end
    
    %% Screen flip
    %  -----------
    if const.checkFRPS
        vbl = Screen('Flip',scr.main);
        count = count + 1;
    else
        Screen('Flip',scr.main,[],[],1);
    end
    
    %% Check keyboard
    %  --------------
    if ~const.expStart
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if keyIsDown
            if (keyCode(my_key.escape))
                overDone(const)
            end
        end
    end
    keyIsDown = CharAvail;
    if keyIsDown
        keyCode = GetChar(1);
        if strcmp(keyCode,my_key.eVal)
            % Color matching task: less MC
            if const.typeTask == 1 && expDes.phase == 3
                stim.MC_col = stim.MC_col - const.color_step;
            end
            % pRF task = Color:
            % Color :       resp: MC => if MC_ratio > BY_ratio : less MC gabors; if MC_ratio < BY_ratio : more MC gabors
            if const.typeTask == 2 && expDes.phase == 3 && ~isnan(expDes.last_sampled_staircase(1))
                if const.staircaseType == 1;        [expDes] = updateQuest(const,expDes,-1,current_time);
                elseif const.staircaseType == 2;    [expDes] = updateStaircase(const,expDes,-1,current_time);
                end
            end
            % HRF task = Color:
            % Fix :         resp: black dot if black dot: more bright black ; if white dot: less bright black
            if const.typeTask == 3 && ~isnan(expDes.last_sampled_staircase(1))
                if const.staircaseType == 1;        [expDes] = updateQuest(const,expDes,-1,current_time);
                elseif const.staircaseType == 2;    [expDes] = updateStaircase(const,expDes,-1,current_time);
                end
            end
            % write in log/edf
            log_txt = sprintf('trial %i event e at %f',t-1,current_time);
            fprintf(const.log_text_fid,'%s\n',log_txt);
            if const.tracker; Eyelink('message','%s',log_txt);end
            
        elseif strcmp(keyCode,my_key.bVal)
            % Color matching task = more MC
            if const.typeTask == 1 && expDes.phase == 3
                key_press.b = 1;
                stim.MC_col = stim.MC_col + const.color_step;
            end
            % pRF task:
            % Color :       resp: BY => if BY_ratio > MC_ratio : less BY gabors; if BY_ratio < MC_ratio : more BY gabors
            if const.typeTask == 2 && expDes.phase == 3 && ~isnan(expDes.last_sampled_staircase(1))
                if const.staircaseType == 1;        [expDes] = updateQuest(const,expDes,1,current_time);
                elseif const.staircaseType == 2;    [expDes] = updateStaircase(const,expDes,1,current_time);
                end
            end
            % pRF task:
            % Fix :         resp: white dot. If white dot: less bright white; if black dot: more bright black
            if const.typeTask == 3 && ~isnan(expDes.last_sampled_staircase(1))
                if const.staircaseType == 1;        [expDes] = updateQuest(const,expDes,1,current_time);
                elseif const.staircaseType == 2;    [expDes] = updateStaircase(const,expDes,1,current_time);
                end
            end
            % write in log/edf
            log_txt = sprintf('trial %i event b at %f',t-1,current_time);
            fprintf(const.log_text_fid,'%s\n',log_txt);
            if const.tracker; Eyelink('message','%s',log_txt);end
            
        elseif strcmp(keyCode,my_key.yVal)
            % Color matching task = end adjustment
            if const.typeTask == 1 && expDes.phase == 3
                key_press.push_button = 1;
                expDes = phase_forward(const,expDes,t);
                phase3_time_end = current_time;
            end
            % write in log/edf
            log_txt = sprintf('trial %i event y at %f',t-1,current_time);
            fprintf(const.log_text_fid,'%s\n',log_txt);
            if const.tracker; Eyelink('message','s',log_txt);end
        elseif strcmp(keyCode,my_key.tVal)
            %  pRF task: = launch next phase (trial begin)
            if const.typeTask == 2 && expDes.phase == 2 && const.scanner
                expDes = phase_forward(const,expDes,t);
                phase2_time_end = current_time;
            end
            %  pRF task: = launch next phase (trial begin)
            if const.typeTask == 3 && expDes.phase == 2 && const.scanner
                expDes = phase_forward(const,expDes,t);
                phase2_time_end = current_time;
            end
            % write in log/edf
            log_txt = sprintf('trial %i event t at %f',t-1,current_time);
            fprintf(const.log_text_fid,'%s\n',log_txt);
            if const.tracker; Eyelink('message','%s',log_txt);end
        end
    end
    
    % dummy mode for scanner
    if ~const.scanner && const.scannerTest
        if current_time-last_t_time >= const.TR
            last_t_time = current_time;
            if (const.typeTask == 2 || const.typeTask == 3) && expDes.phase == 2
                expDes = phase_forward(const,expDes,t);
                phase2_time_end = current_time;
                last_redraw_time = current_time - 1.5*const.time_steps;
            end
            % write in log/edf
            log_txt = sprintf('trial %i event t at %f',t-1,current_time);
            fprintf(const.log_text_fid,'%s\n',log_txt);
            if const.tracker; Eyelink('message','%s',log_txt);end
        end
    end
end

%% Close opened textures
%  ---------------------
Screen('Close',aperture_tex);
Screen('Close',stim.MC_gabTex_low_sfq);     Screen('Close',stim.BY_gabTex_low_sfq);
Screen('Close',stim.CM_gabTex_low_sfq);     Screen('Close',stim.YB_gabTex_low_sfq);
Screen('Close',stim.MC_gabTex_high_sfq);    Screen('Close',stim.BY_gabTex_high_sfq);
Screen('Close',stim.CM_gabTex_high_sfq);    Screen('Close',stim.YB_gabTex_high_sfq);

%% Get results
%  -----------
if const.typeTask == 1
    resMat = stim.MC_col;
    if const.checkTrial;fprintf(1,'\n\tMC offset end = \t%1.2f',stim.MC_col);end
elseif const.typeTask == 2 || const.typeTask == 3
    resMat = 0;
end

%% Get average frame per second
%  ----------------------------
if const.checkFRPS
    avgfps = count / (vbl - tstart);
    fprintf(1,'\n\tAverage frame/s = \t%1.2f',avgfps);
end

end