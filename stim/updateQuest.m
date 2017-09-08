function [expDes] = updateQuest(const,expDes,response,current_time)
% ----------------------------------------------------------------------
% [expDes] = updateQuest(const,expDes,response,current_time)
% ----------------------------------------------------------------------
% Goal of the function :
% Update the quest value in function of the response
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
    quest_sample = QuestQuantile(expDes.quest_qColor{expDes.last_sampled_staircase(2)+1});
    if quest_sample < const.quest_grain;quest_sample = const.quest_grain;end
    expDes.quest_qColor{expDes.last_sampled_staircase(2)+1}= ...
        QuestUpdate(expDes.quest_qColor{expDes.last_sampled_staircase(2)+1},quest_sample,(response+1)/2);
    expDes.resColor(end,end-1) = (response+1)/2;
    expDes.resColor(end,end)   = current_time;
    % rows = pulse occurences
    % col9 = response
    % col10 = response/ quest update time
    
    log_txt = sprintf('staircase %s bin %i updated from %f after response %1.1f at %f',const.task{expDes.last_sampled_staircase(1)+1},expDes.last_sampled_staircase(2),quest_sample,(response+1)/2,current_time);
    fprintf(const.log_text_fid,'%s\n',log_txt);
    if const.tracker; Eyelink('message','%s',log_txt);end
    
    expDes.last_sampled_staircase = [NaN,NaN];

elseif const.typeTask == 3
    
    response = response*expDes.present_fix_task_sign;
    quest_sample = QuestQuantile(expDes.quest_qFix);
    if quest_sample < const.quest_grain;quest_sample = const.quest_grain;end
    expDes.quest_qFix = QuestUpdate(expDes.quest_qFix,quest_sample,(response+1)/2);
    expDes.resFix(end,end-1) = (response+1)/2;
    expDes.resFix(end,end)   = current_time;
    % rows = pulse occurences
    % col8 = response
    % col9 = response/ quest update time
    
    log_txt = sprintf('staircase Fix updated from %f after response %1.1f at %f',quest_sample,(response+1)/2,current_time);
    fprintf(const.log_text_fid,'%s\n',log_txt);
    if const.tracker; Eyelink('message','%s',log_txt);end
    
    expDes.last_sampled_staircase = NaN;

end