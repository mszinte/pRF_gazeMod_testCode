function [stim] = generateStim(scr,const,stim)
% ----------------------------------------------------------------------
% [stim] = generateStim(scr,const,stim)
% ----------------------------------------------------------------------
% Goal of the function :
% Generate the stimuli
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% stim: struct containing all stimuli configurations
% ----------------------------------------------------------------------
% Output(s):
% stim: stimuli configurations with added values as for example
%   stim.orientiation: stimuli orientation
%   stim.rect: stumuli rects
%   stim.tex: stumuli texture list
%   ...
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 30 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

% generate spatial frequency
if stim.genSfq
    stim.gab_sfq  = [ ones(round(const.numGab/2),1)*1;...      % low sfq
                      ones(round(const.numGab/2),1)*2];        % high sfq
    
    % randomize speed / temporal frequency
	stim.gab_sfq  = stim.gab_sfq(randperm(const.numGab));
end

% compute phase
if stim.computePhase
    stim.gab_phase = const.speed * const.period * stim.current_phase;
end

% randomized position
if stim.genPos
    if const.typeTask == 1
        stim.pos        = rand(const.numGab,2) .* [(ones(const.numGab,1)*const.stim_rad*2),(ones(const.numGab,1)*const.stim_rad*2)] - [(ones(const.numGab,1)*const.stim_rad),(ones(const.numGab,1)*const.stim_rad)] + repmat(const.stimCtr(stim.rand2+1,:),const.numGab,1);
    elseif const.typeTask == 2
        stim.pos        = ((rand(const.numGab,2) .* [(ones(const.numGab,1)*const.stim_rad*2),(ones(const.numGab,1)*const.stim_rad*2*const.bar_width_ratio)] - [(ones(const.numGab,1)*const.stim_rad),(ones(const.numGab,1)*const.stim_rad*const.bar_width_ratio)]...
                            + [zeros(const.numGab,1),ones(const.numGab,1)*-stim.midpoint]) * stim.rotation_matrix)+ repmat(const.stimCtr(stim.cond1+1,:),const.numGab,1);
	elseif const.typeTask == 3
        stim.pos        = rand(const.numGab,2) .* [(ones(const.numGab,1)*const.stim_rad*2),(ones(const.numGab,1)*const.stim_rad*2)] - [(ones(const.numGab,1)*const.stim_rad),(ones(const.numGab,1)*const.stim_rad)] + repmat(const.stimCtrHRF,const.numGab,1);
    end
    stim.rect       = [ stim.pos(:,1) - const.element_size(:,1),...
                        stim.pos(:,2) - const.element_size(:,1),...
                        stim.pos(:,1) + const.element_size(:,1),...
                        stim.pos(:,2) + const.element_size(:,1)]';
end

% randomized orientation
if stim.genOrientation
    stim.orientiation = rand(1,const.numGab) * 720 - 360;
end

% Define red/green gabors
if const.typeTask == 1
    if ~stim.first_time
        Screen('Close',stim.MC_gabTex_low_sfq);
        Screen('Close',stim.CM_gabTex_low_sfq);
        Screen('Close',stim.MC_gabTex_high_sfq);
        Screen('Close',stim.CM_gabTex_high_sfq);
    end
    
    if      stim.MC_col > 1; stim.MC_col = 1;
    elseif  stim.MC_col < 0; stim.MC_col = 0;
    end
    magenta             = ([stim.MC_col,-stim.MC_col,0]+1)*(127.5);
    cyan                = ([-stim.MC_col,stim.MC_col,0]+1)*(127.5);
    
    stim.MC_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,0,magenta,cyan);
    stim.MC_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.MC_gab_low_sfq);
    stim.CM_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,0,cyan,magenta);
    stim.CM_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.CM_gab_low_sfq);
    
    stim.MC_gab_high_sfq     = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,0,magenta,cyan);
    stim.MC_gabTex_high_sfq  = Screen('MakeTexture',scr.main,stim.MC_gab_high_sfq);
    stim.CM_gab_high_sfq     = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,0,cyan,magenta);
    stim.CM_gabTex_high_sfq  = Screen('MakeTexture',scr.main,stim.CM_gab_high_sfq);
    
elseif const.typeTask == 2
    if ~stim.first_time
        Screen('Close',stim.MC_gabTex_low_sfq);     Screen('Close',stim.BY_gabTex_low_sfq);
        Screen('Close',stim.CM_gabTex_low_sfq);     Screen('Close',stim.YB_gabTex_low_sfq);
        Screen('Close',stim.MC_gabTex_high_sfq);    Screen('Close',stim.BY_gabTex_high_sfq);
        Screen('Close',stim.CM_gabTex_high_sfq);    Screen('Close',stim.YB_gabTex_high_sfq);
    end
    
    if stim.pulse
        stim.MC_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseMagenta,const.colPulseCyan);        stim.MC_gabTex_low_sfq 	= Screen('MakeTexture',scr.main,stim.MC_gab_low_sfq);
        stim.CM_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseCyan,const.colPulseMagenta);        stim.CM_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.CM_gab_low_sfq);
        stim.MC_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseMagenta,const.colPulseCyan);       stim.MC_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.MC_gab_high_sfq);
        stim.CM_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseCyan,const.colPulseMagenta);       stim.CM_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.CM_gab_high_sfq);
        stim.BY_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseBlue,const.colPulseYellow);         stim.BY_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.BY_gab_low_sfq);
        stim.YB_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseYellow,const.colPulseBlue);         stim.YB_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.YB_gab_low_sfq);
        stim.BY_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseBlue,const.colPulseYellow);        stim.BY_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.BY_gab_high_sfq);
        stim.YB_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseYellow,const.colPulseBlue);        stim.YB_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.YB_gab_high_sfq);
    else
        stim.MC_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseWhite,const.colNoPulseBlack);     stim.MC_gabTex_low_sfq 	= Screen('MakeTexture',scr.main,stim.MC_gab_low_sfq);
        stim.CM_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseBlack,const.colNoPulseWhite);     stim.CM_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.CM_gab_low_sfq);
        stim.MC_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseWhite,const.colNoPulseBlack);    stim.MC_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.MC_gab_high_sfq);
        stim.CM_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseBlack,const.colNoPulseWhite);    stim.CM_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.CM_gab_high_sfq);
        stim.BY_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseWhite,const.colNoPulseBlack);     stim.BY_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.BY_gab_low_sfq);
        stim.YB_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseBlack,const.colNoPulseWhite);     stim.YB_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.YB_gab_low_sfq);
        stim.BY_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseWhite,const.colNoPulseBlack);    stim.BY_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.BY_gab_high_sfq);
        stim.YB_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colNoPulseBlack,const.colNoPulseWhite);    stim.YB_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.YB_gab_high_sfq);
    end
elseif  const.typeTask == 3
    if ~stim.first_time
        Screen('Close',stim.MC_gabTex_low_sfq);     Screen('Close',stim.BY_gabTex_low_sfq);
        Screen('Close',stim.CM_gabTex_low_sfq);     Screen('Close',stim.YB_gabTex_low_sfq);
        Screen('Close',stim.MC_gabTex_high_sfq);    Screen('Close',stim.BY_gabTex_high_sfq);
        Screen('Close',stim.CM_gabTex_high_sfq);    Screen('Close',stim.YB_gabTex_high_sfq);
    end
    
    stim.MC_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseMagenta,const.colPulseCyan);        stim.MC_gabTex_low_sfq 	= Screen('MakeTexture',scr.main,stim.MC_gab_low_sfq);
    stim.CM_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseCyan,const.colPulseMagenta);        stim.CM_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.CM_gab_low_sfq);
    stim.MC_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseMagenta,const.colPulseCyan);       stim.MC_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.MC_gab_high_sfq);
    stim.CM_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseCyan,const.colPulseMagenta);       stim.CM_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.CM_gab_high_sfq);
    stim.BY_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseBlue,const.colPulseYellow);         stim.BY_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.BY_gab_low_sfq);
    stim.YB_gab_low_sfq     = generateGabor(const.element_size,const.low_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseYellow,const.colPulseBlue);         stim.YB_gabTex_low_sfq  = Screen('MakeTexture',scr.main,stim.YB_gab_low_sfq);
    stim.BY_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseBlue,const.colPulseYellow);        stim.BY_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.BY_gab_high_sfq);
    stim.YB_gab_high_sfq    = generateGabor(const.element_size,const.high_spatial_frequency,0,const.element_sd_size,stim.gab_phase,const.colPulseYellow,const.colPulseBlue);        stim.YB_gabTex_high_sfq = Screen('MakeTexture',scr.main,stim.YB_gab_high_sfq);
    
end

if stim.genColor
    
    stim.color   = [ ones(round(const.numGab*stim.MC_ratio/2),1)*1;...     % 1 = R/G
                     ones(round(const.numGab*stim.MC_ratio/2),1)*2;...     % 2 = G/R
                     ones(round(const.numGab*stim.BY_ratio/2),1)*3;...     % 3 = B/Y
                     ones(round(const.numGab*stim.BY_ratio/2),1)*4;...     % 4 = Y/B
                     ];
                
    % randomized color
    stim.color        = stim.color(randperm(const.numGab));
    % 1 = magenta-cyan;
    % 2 = cyan-magenta;
    % 2 = blue-yellow
    % 2 = yellow-blue
end

% define texture list with colors and sfq
stim.tex(stim.color==1 & stim.gab_sfq == 1) = stim.MC_gabTex_low_sfq;
stim.tex(stim.color==2 & stim.gab_sfq == 1) = stim.CM_gabTex_low_sfq;
stim.tex(stim.color==3 & stim.gab_sfq == 1) = stim.BY_gabTex_low_sfq;
stim.tex(stim.color==4 & stim.gab_sfq == 1) = stim.YB_gabTex_low_sfq;
stim.tex(stim.color==1 & stim.gab_sfq == 2) = stim.MC_gabTex_high_sfq;
stim.tex(stim.color==2 & stim.gab_sfq == 2) = stim.CM_gabTex_high_sfq;
stim.tex(stim.color==3 & stim.gab_sfq == 2) = stim.BY_gabTex_high_sfq;
stim.tex(stim.color==4 & stim.gab_sfq == 2) = stim.YB_gabTex_high_sfq;

% button to specify the first time the generator is ran
stim.first_time = 0;
end