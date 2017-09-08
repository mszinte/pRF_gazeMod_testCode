function runTrials(scr,const,expDes,el,my_key)
% ----------------------------------------------------------------------
% runTrials(scr,const,expDes,el,my_key)
% ----------------------------------------------------------------------
% Goal of the function :
% Launch each trial, instructions and connection with eyelink
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : struct containg experimental design
% my_key : structure containing keyboard configurations
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------


% Save all config at start of the block
% -------------------------------------
config.scr = scr; config.const = const; config.expDes = expDes; config.my_key = my_key;
save(const.exp_file_mat,'config');

% First mouse config
% ------------------
if const.expStart;HideCursor;FlushEvents;end

% Initial calibrations
% -------------------
if const.tracker
    eyeLinkClearScreen(el.bgCol);eyeLinkDrawText(scr.x_mid,scr.y_mid,el.txtCol,'CALIBRATION INSTRUCTION - PRESS SPACE');
    instructionsIm(scr,const,my_key,'Calibration',0,0);
    calibresult = EyelinkDoTrackerSetup(el);
    if calibresult==el.TERMINATE_KEY
        return
    end
end

% Start Eyelink
% -------------
record = 0;
while ~record
    if const.tracker
        if ~record
            Eyelink('startrecording');key=1;
            while key ~=  0;key = EyelinkGetKey(el);end
            error=Eyelink('checkrecording');
            if error==0;    record = 1;Eyelink('message', 'RECORD_START');
            else            record = 0;Eyelink('message', 'RECORD_FAILURE');
            end
        end
    else
        record = 1;
    end
end

% special instruction and wait for T if scanner on
if const.scanner
    scanTxt = 'Scanner';
else
    scanTxt = '';
end

% Main Loop
% ---------
for t = 1:size(expDes.expMat,1);
    expDes.phase = 0;
    if t == 1
        % Instructions (Phase 0)
        if const.typeTask == 1
            if const.tracker;eyeLinkClearScreen(el.bgCol);eyeLinkDrawText(scr.x_mid,scr.y_mid,el.txtCol,'TASK INSTRUCTIONS - PRESS SPACE');end;
        else
            if ~const.scanner;if const.tracker;eyeLinkClearScreen(el.bgCol);eyeLinkDrawText(scr.x_mid,scr.y_mid,el.txtCol,'TASK INSTRUCTIONS - PRESS SPACE');end;end
            if const.scanner;if const.tracker;eyeLinkClearScreen(el.bgCol);eyeLinkDrawText(scr.x_mid,scr.y_mid,el.txtCol,'TASK INSTRUCTIONS - WAIT FOR TR');end;end
        end
        if const.typeTask == 1
            instructionsIm(scr,const,my_key,sprintf('ColorMatching'),0,0);
        elseif const.typeTask == 2
            instructionsIm(scr,const,my_key,sprintf('pRF_exp%s',scanTxt),0,1);
            expDes.last_sampled_staircase   = [NaN,NaN];                % put staircase to nan
            expDes.exp_start_time           = 0;                      	% put start time to 0
            expDes.resColor                 = [];                       % put empty the results of the staircase for color task (3 bin staircases)
        elseif const.typeTask == 3
            instructionsIm(scr,const,my_key,sprintf('HRF_exp%s',scanTxt),0,1);
            expDes.last_sampled_staircase   = NaN;                      % put staircase to nan
            expDes.exp_start_time           = 0;                      	% put start time to 0
            expDes.resFix                   = [];                       % put empty the results of the staircase for fixation task (1 bin staircase)
        end
        expDes = phase_forward(const,expDes,t);
        expDes.instructTime = GetSecs;
    else
        expDes = phase_forward(const,expDes,t);
        expDes.instructTime = GetSecs;
    end
    FlushEvents;

    % Write on eyelink screen
    if const.tracker;
        drawTrialInfoEL(scr,const,expDes,t)
    end
    
    % Write in log/edf
    log_txt = sprintf('trial %i started at %f\n',t-1,GetSecs);
    fprintf(const.log_text_fid,log_txt);
    if const.tracker;
        Eyelink('message','%s',log_txt);
        Eyelink('command', 'record_status_message ''TRIAL %d''', t-1);
    end
    
    % Run single trial
    [resMat,expDes] = runSingleTrial(scr,const,expDes,my_key,t);
    
    % write data
    if const.typeTask == 1
        expDes.all_color_values(t) = resMat;
    end
    
    % write trials parameters to log/edf
    for t_parameter = 1:size(const.parameter,1)
        if const.typeTask == 1 && t_parameter == size(const.parameter,1)
            log_txt = sprintf('trial %i parameter   %s %1.5g',t-1,const.parameter{t_parameter,1},expDes.expMat(t,3));
        elseif const.typeTask == 2 && t_parameter == size(const.parameter,1)-2
            log_txt = sprintf('trial %i parameter   %s %1.5g',t-1,const.parameter{t_parameter,1},expDes.expMat(t,3));
        elseif const.typeTask == 2 && t_parameter == size(const.parameter,1)-1
            log_txt = sprintf('trial %i parameter   %s %1.5g',t-1,const.parameter{t_parameter,1},const.directions(expDes.expMat(t,4)+1));
        elseif const.typeTask == 2 && t_parameter == size(const.parameter,1)
            log_txt = sprintf('trial %i parameter   %s %1.5g',t-1,const.parameter{t_parameter,1},expDes.expMat(t,5));
        elseif const.typeTask == 3 && t_parameter == size(const.parameter,1)-1
            log_txt = sprintf('trial %i parameter   %s %1.5g',t-1,const.parameter{t_parameter,1},expDes.expMat(t,3));
        elseif const.typeTask == 3 && t_parameter == size(const.parameter,1)
            log_txt = sprintf('trial %i parameter   %s %1.5g',t-1,const.parameter{t_parameter,1},expDes.expMat(t,4));
        else
            log_txt = sprintf('trial %i parameter   %s %1.5g',t-1,const.parameter{t_parameter,1},const.parameter{t_parameter,2});
        end
        fprintf(const.log_text_fid,'%s\n',log_txt);
        if const.tracker;
            Eyelink('message', '%s',log_txt);
        end
    end
    
    % write in log/edf
    log_txt = sprintf('trial %i stopped at %f',t-1,GetSecs);
    fprintf(const.log_text_fid,'%s\n',log_txt);
    if const.tracker;
        Eyelink('message', '%s',log_txt);
    end
    
end

%% Compute/Write mean/std behavioral data
fprintf(1,'\n\n\t========================  TRIAL END ========================\n');
if const.typeTask == 1
    % save RG/BY ratio and print results
    expDes.RGBY_ratio_mean = mean(expDes.all_color_values/const.BY_comparison_color);
    expDes.RGBY_ratio_std  = std(expDes.all_color_values/const.BY_comparison_color,1);
    fprintf(const.colRatio_fid,'Mean RG/BY ratio: %.2f\nStdev RG/BY ratio: %.2f',expDes.RGBY_ratio_mean,expDes.RGBY_ratio_std);
    
    fprintf(1,'\n\tMean RG/BY ratio = \t%.2f',expDes.RGBY_ratio_mean);
    fprintf(1,'\n\tStd RG/BY ratio = \t%.2f',expDes.RGBY_ratio_std);
    
elseif const.typeTask == 2
    if const.staircaseType == 1
        % save quests and print results
        questSave.quest_qColor = expDes.quest_qColor;
        save(const.staircase_mat,'questSave');

        for tBin = 1:const.nr_staircases_ecc
            fprintf(1,'\n\tColor Bin %i staircase mean = \t%.2f',tBin-1,QuestMean(questSave.quest_qColor{tBin}));
            fprintf(1,'\n\tColor Bin %i staircase std  = \t%.2f',tBin-1,QuestSd(questSave.quest_qColor{tBin}));
        end
    elseif const.staircaseType == 2
        staircaseSave.stairColor = expDes.stairColor;
        staircaseSave.corRespCount = expDes.corRespCount;
        staircaseSave.incorRespCount = expDes.incorRespCount;
        save(const.staircase_mat,'staircaseSave');
        for tBin = 1:const.nr_staircases_ecc
            fprintf(1,'\n\tColor Bin %i staircase mean = \t%.2f',tBin-1,nanmean(expDes.resColor(expDes.resColor(:,6)==tBin-1,end-1)));
            fprintf(1,'\n\tColor Bin %i staircase std  = \t%.2f',tBin-1,nanstd(expDes.resColor(expDes.resColor(:,6)==tBin-1,end-1)));
        end
    end
elseif const.typeTask == 3
    if const.staircaseType == 1
        % save quests and print results
        questSave.quest_qFix = expDes.quest_qFix;
        save(const.staircase_mat,'questSave');
        fprintf(1,'\n\tFix staircase mean = \t%.2f',QuestMean(questSave.quest_qFix));
        fprintf(1,'\n\tFix staircase std  = \t%.2f',QuestSd(questSave.quest_qFix));
    elseif const.staircaseType == 2
        staircaseSave.stairFix = expDes.stairFix;
        staircaseSave.corRespCountFix = expDes.corRespCountFix;
        staircaseSave.incorRespCountFix = expDes.incorRespCountFix;
        save(const.staircase_mat,'staircaseSave');
        fprintf(1,'\n\tFix staircase mean = \t%.2f',nanmean(expDes.resFix(:,end-1)));
        fprintf(1,'\n\tFix staircase std  = \t%.2f',nanstd(expDes.resFix(:,end-1)));
    end
end

% Save all config at the end of the block (overwrite start made at start)
% ---------------------------------------
config.scr = scr; config.const = const; config.expDes = expDes; config.my_key = my_key;
save(const.exp_file_mat,'config');

% Stop Eyelink
% ------------
if const.tracker
    Eyelink('command','clear_screen');
    Eyelink('command', 'record_status_message ''END''');
    WaitSecs(1);
    Eyelink('stoprecording');
    Eyelink('message', 'RECORD_STOP');
    eyeLinkClearScreen(el.bgCol);eyeLinkDrawText(scr.x_mid,scr.y_mid,el.txtCol,'THE END - PRESS SPACE OR WAIT');
end

% End messages
% ------------
if const.typeTask == 1
    instructionsIm(scr,const,my_key,'End_part',1,0);
elseif const.typeTask == 2
    if const.fromBlock == const.num_tot_block_pRF;instructionsIm(scr,const,my_key,'End',1,0);
    else instructionsIm(scr,const,my_key,'End_block',1,0);
    end
elseif const.typeTask == 3
    instructionsIm(scr,const,my_key,'End_part',1,0);
end

end