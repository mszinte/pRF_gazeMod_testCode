function [expDes,stim] = getStaircase(const,expDes,stim,current_time,t)
% ----------------------------------------------------------------------
% [expDes,stim] = getStaircase(const,expDes,stim,current_time,t)
% ----------------------------------------------------------------------
% Goal of the function :
% Get the quest staricase value
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% expDes : struct containg experimental design
% stim: struct containing all stimuli configurations
% current_time : last time
% t = trial number
% ----------------------------------------------------------------------
% Output(s):
% expDes : experimental trial config
% stim : struct of the stimuli
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

if const.typeTask == 2
    % determine eccentricity bin
    barLeftEnd          = (([-const.stim_rad,-stim.midpoint]) * stim.rotation_matrix) + const.stimCtr(stim.cond1+1,:);
    barRightEnd         = (([const.stim_rad,-stim.midpoint]) * stim.rotation_matrix) + const.stimCtr(stim.cond1+1,:);
    meanDist            = mean([sqrt((barLeftEnd(1)-stim.fixPos(1))^2+(barLeftEnd(2)-stim.fixPos(2))^2),...
        sqrt((barRightEnd(1)-stim.fixPos(1))^2+(barRightEnd(2)-stim.fixPos(2))^2)]);
    
    for tBin = 1:const.nr_staircases_ecc
        if tBin < const.nr_staircases_ecc
            if meanDist >= const.valBin(stim.cond1+1,tBin) && meanDist < const.valBin(stim.cond1+1,tBin+1)
                stim.eccentricity_bin = tBin-1;
            end
        else
            % last bin
            if meanDist >= const.valBin(stim.cond1+1,tBin) && meanDist <= const.valBin(stim.cond1+1,tBin+1)
                stim.eccentricity_bin = tBin-1;
            end
        end
    end
    stim.MC_ratio         = const.MC_ratio;
    stim.BY_ratio         = const.BY_ratio;
    
    if stim.pulse
        % color task
        expDes.stair_sample_color       = expDes.stairColor{stim.eccentricity_bin+1};
        if expDes.stair_sample_color < const.stair_grain;expDes.stair_sample_color = const.stair_grain;end
        expDes.color_1_ratio            = 1 - (1/(exp(1)^expDes.stair_sample_color+1));
        expDes.color_2_ratio            = 1 - expDes.color_1_ratio;
        expDes.present_color_task_sign  = sign(randn);
        switch expDes.present_color_task_sign
            case -1;stim.MC_ratio     = expDes.color_1_ratio;
                stim.BY_ratio     = expDes.color_2_ratio;
            case  1;stim.MC_ratio     = expDes.color_2_ratio;
                stim.BY_ratio     = expDes.color_1_ratio;
        end
        log_txt = sprintf('signal in feature: Color ecc bin: %i phase: %1.3f value: %f at %f',stim.eccentricity_bin,stim.current_phase,expDes.stair_sample_color,current_time);
        fprintf(const.log_text_fid,'%s\n',log_txt);                                                                         % write in log
        if const.tracker;Eyelink('message','%s',log_txt);end                                                                % write in edf
        
        % save data
        expDes.resColor = [expDes.resColor;expDes.expMat(t,:),stim.eccentricity_bin,expDes.stair_sample_color,current_time,NaN,NaN];
        % rows  = pulse occurences
        % col1  = block number
        % col2  = trial number
        % col3  = fixation position (0 = right, 1 = left)
        % col4  = orientation of the stim
        % col5  = type of task (0 = color; 1 = fix no stim)
        % col6  = eccentricity bin (0 = 0->1/3, 1 = 1/3->2/3; 2 = 2/3 -> 1 of stim rad)
        % col7  = staircase color value
        % col8  = signal time
        % col9  = response (NaN if no response before next signal)
        % col10 = response/update time (NaN if no response before next signal)
        expDes.last_sampled_staircase = [stim.var2,stim.eccentricity_bin];
    end
elseif const.typeTask == 3
    stim.fixation_color         = const.fixation_rim_color;
    
    
    if stim.pulse
        % color task
        expDes.stair_sample_fix         = expDes.stairFix;
        if expDes.stair_sample_fix < const.stair_grain;expDes.stair_sample_fix = const.stair_grain;end
        expDes.fix_value                = ((1 - (1/(exp(1)^expDes.stair_sample_fix+1)))- 0.5) * 2.0;
        expDes.present_fix_task_sign    = sign(randn);
        expDes.fix_gray_value           = ones(1,3) * expDes.fix_value * expDes.present_fix_task_sign;
        expDes.fix_gray_value_RGB       = (expDes.fix_gray_value+1)*127.5;
        stim.fixation_color             = expDes.fix_gray_value_RGB;
        
        log_txt = sprintf('signal in feature: Fix value: %f at %f',expDes.stair_sample_fix,current_time);
        fprintf(const.log_text_fid,'%s\n',log_txt);                                                                         % write in log
        if const.tracker;Eyelink('message','%s',log_txt);end                                                                % write in edf
        
        % save data
        expDes.resFix = [expDes.resFix;expDes.expMat(t,:),expDes.stair_sample_fix,current_time,NaN,NaN];
        % rows = pulse occurences
        % col1 = block number
        % col2 = trial number
        % col3 = type of task (0 = fixation; 1 = fixation no stim)
        % col4 = pulse presence (0 = present; 1 = absent)
        % col5 = staircase fixation color value
        % col6 = signal time
        % col7 = response (NaN if no response before next signal)
        % col8 = response/update time (NaN if no response before next signal)
        expDes.last_sampled_staircase = [stim.var1];
    end
end

end