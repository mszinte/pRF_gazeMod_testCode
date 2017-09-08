function [expDes] = updateStaircase(const,expDes,response,current_time)
% ----------------------------------------------------------------------
% [expDes] = updateStaircase(const,expDes,response,current_time)
% ----------------------------------------------------------------------
% Goal of the function :
% Update the staircase value in function of the response
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% expDes : struct containg experimental design
% response: response returned by participant
% current_time : last GetSecs (clock)
% ----------------------------------------------------------------------
% Output(s):
% expDes : experimental trial config
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

if const.typeTask == 2
    response = response*expDes.present_color_task_sign;
    eccentricity_bin = expDes.last_sampled_staircase(2)+1;
    stair_sample = expDes.stairColor{eccentricity_bin};
    if response == 1
        expDes.corRespCount{eccentricity_bin} = expDes.corRespCount{eccentricity_bin} + 1;
        if expDes.corRespCount{eccentricity_bin} == const.good_trial_for_harder
            expDes.stairColor{eccentricity_bin} = expDes.stairColor{eccentricity_bin} - const.stair_grain;
            expDes.corRespCount{eccentricity_bin} = 0;
            expDes.incorRespCount{eccentricity_bin} = 0;
        end
    elseif response == -1
        expDes.incorRespCount{eccentricity_bin} = expDes.incorRespCount{eccentricity_bin} + 1;
        if expDes.incorRespCount{eccentricity_bin} == const.bad_trial_for_easier
            expDes.stairColor{eccentricity_bin}  = expDes.stairColor{eccentricity_bin} + const.stair_grain;
            expDes.incorRespCount{eccentricity_bin} = 0;
            expDes.corRespCount{eccentricity_bin} = 0;
        end
    end
    
    % save results
    expDes.resColor(end,end-1) = (response+1)/2;
    expDes.resColor(end,end)   = current_time;
    % rows = pulse occurences
    % col9 = response
    % col10 = response / staircase update time
    
    log_txt = sprintf('staircase %s bin %i updated from %f after response %1.1f at %f',const.task{expDes.last_sampled_staircase(1)+1},expDes.last_sampled_staircase(2),stair_sample,(response+1)/2,current_time);
    fprintf(const.log_text_fid,'%s\n',log_txt);
    if const.tracker; Eyelink('message','%s',log_txt);end
    
    expDes.last_sampled_staircase = [NaN,NaN];

elseif const.typeTask == 3

    response = response*expDes.present_fix_task_sign;
    stair_sample = expDes.stairFix;
    if response == 1
        expDes.corRespCountFix = expDes.corRespCountFix + 1;
        if expDes.corRespCountFix == const.good_trial_for_harder
            expDes.stairFix = expDes.stairFix - const.stair_grain;
            expDes.corRespCountFix = 0;
            expDes.incorRespCountFix = 0;
        end
    elseif response == -1
        expDes.incorRespCountFix = expDes.incorRespCountFix + 1;
        if expDes.incorRespCountFix == const.bad_trial_for_easier
            expDes.stairFix  = expDes.stairFix + const.stair_grain;
            expDes.incorRespCountFix = 0;
            expDes.corRespCountFix = 0;
        end
    end
    
    % save results
    expDes.resFix(end,end-1) = (response+1)/2;
    expDes.resFix(end,end)   = current_time;
    % rows = pulse occurences
    % col8 = response
    % col9 = response / staircase update time
    
    log_txt = sprintf('staircase Fix updated from %f after response %1.1f at %f',stair_sample,(response+1)/2,current_time);
    fprintf(const.log_text_fid,'%s\n',log_txt);
    if const.tracker; Eyelink('message','%s',log_txt);end
    
    expDes.last_sampled_staircase = NaN;
end

end