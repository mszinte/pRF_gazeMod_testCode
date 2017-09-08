function [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define experimental design
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% expDes : struct containg experimental design
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

%% Experimental random variables

if const.typeTask == 1
    % Rand 1 : MC offset (0->1 value)
    % ------
    % value defined as const.MC_offsets in constConfig.m
    % 0.0 = Red = [127.5 ,127.5,127.5]    Green = [127.5,127.5, 127.5]
    % ...
    % 0.5 = Red = [191.25,127.5,127.5]    Green = [127.5,191.25,127.5]
    % ...
    % 1.0 = Red = [255  , 127.5,127.5]    Green = [127.5,127.5, 127.5]
    
    
    % Rand 2 : fixation position (2 modalities)
    % ------
    % value defined as const.positionRandom in constConfig.m
    % 00 = fixation right
    % 01 = fixation left
    
elseif const.typeTask == 2
    % Cond1 : fixation position (2 modalities)
    % ------
    expDes.cond1 = [0,1];
    % 00 = fixation right
    % 01 = fixation left
    
    if const.fromBlock == 1
        if ~const.expStart
            expDes.cond1All = expDes.cond1(randperm(2,1));
        else
            cond1All        = repmat(expDes.cond1(randperm(2)),1,const.num_tot_block_pRF/size(expDes.cond1,2));
            expDes.cond1All = cond1All;
            save(const.block_order_mat,'cond1All');
        end
    else
        load(const.block_order_mat)
        expDes.cond1All = cond1All;
    end
        
    % Var 1 : direction of pRF mapper (8 modalities)
    % ======
    % value defined as const.subdirection in constConfig.m
    % 00 =   0 deg
    % 01 =  45 deg
    % 02 =  90 deg
    % 03 = 135 deg
    % 04 = 180 deg
    % 05 = 225 deg
    % 06 = 270 deg
    % 07 = 315 deg
    
    % Var 2 : type of task [2 modalities]
    % ======
    % value defined as const.subtask in constConfig.m
    % 00 = Color task
    % 01 = fixation no stim task

elseif const.typeTask == 3
    
    % Var 1 : type of task [2 modalities]
    % ======
    % value defined as const.subtask in constConfig.m
    % 00 = fixation task
    % 01 = fixation no stim task
    
    % Var 2 : fixation pulse occurance [2 modalities]
    % ======
    % value defined as const.fixtask in constConfig.m
    % 00 = pulse present
    % 01 = pulse absent
    
end

%% Load/define staircase
% pRF exp
if const.typeTask == 2
    if const.staircaseType == 1
        if exist(const.staircase_mat,'file') && const.fromBlock ~= 1
            % load Quests of previous blocks
            load(const.staircase_mat);
            expDes.quest_qColor     = questSave.quest_qColor;
        else
            % create Quests structs for Fix no stim, Fix, color and speed
            for tEcc = 1:const.nr_staircases_ecc
                expDes.quest_qColor{tEcc} = QuestCreate(const.quest_qColor_tGuess,const.quest_qColor_tGuessSd,...
                    const.quest_pThreshold,const.quest_beta,...
                    const.quest_delta,const.quest_gamma,...
                    const.quest_grain,const.quest_range);
            end
        end
    elseif const.staircaseType == 2
        if exist(const.staircase_mat,'file') && const.fromBlock ~= 1
            % load staricaseof previous blocks
            load(const.staircase_mat);
            expDes.stairColor = staircaseSave.stairColor;
            expDes.corRespCount = staircaseSave.corRespCount;
            expDes.incorRespCount = staircaseSave.incorRespCount;
        else
            % create staircase starting value
            for tEcc = 1:const.nr_staircases_ecc
                expDes.stairColor{tEcc} = const.stair_color_startVal;
                expDes.corRespCount{tEcc} = 0;
                expDes.incorRespCount{tEcc} = 0;
            end
        end
    end
end

% HRF exp
if const.typeTask == 3
    if const.staircaseType == 1
        if exist(const.staircase_mat,'file') && const.fromBlock ~= 1
            % load Quests of previous blocks
            load(const.staircase_mat);
            expDes.quest_qFix  = questSave.quest_qFix;
        else
            % create Quests structs for Fix no stim, Fix, color and speed
            expDes.quest_qFix = QuestCreate(const.quest_qFix_tGuess,const.quest_qFix_tGuessSd,...
                                            const.quest_pThreshold,const.quest_beta,...
                                            const.quest_delta,const.quest_gamma,...
                                            const.quest_grain,const.quest_range);
        end
    elseif const.staircaseType == 2
        if exist(const.staircase_mat,'file') && const.fromBlock ~= 1
            % load staricaseof previous blocks
            load(const.staircase_mat);
            expDes.stairFix = staircaseSave.stairFix;
            expDes.corRespCountFix = staircaseSave.corRespCountFix;
            expDes.incorRespCountFix = staircaseSave.incorRespCountFix;
        else
            % create staircase starting value
            expDes.stairFix = const.stair_fix_startVal;
            expDes.corRespCountFix = 0;
            expDes.incorRespCountFix = 0;
        end
    end
end

%% Experimental configuration :
switch const.typeTask
    % Color matching task
    case 1;     expDes.nb_cond    = 0;
                expDes.nb_var     = 0;
                expDes.nb_rand    = 1;
                expDes.nb_list    = 0;
                expDes.nb_trials  = const.num_trials_colMatcher; 

	% pRF exp.
    case 2;     expDes.nb_cond    = 0;
                expDes.nb_var     = 2;
                expDes.nb_rand    = 0;
                expDes.nb_list    = 0;
                expDes.nb_trials  = size(const.subtasks,2);
	
	% HRF mapper
    case 3;     expDes.nb_cond    = 0;
                expDes.nb_var     = 2;
                expDes.nb_rand    = 0;
                expDes.nb_list    = 0;
                expDes.nb_trials  = size(const.subtasks,2);
end

%% Experimental loop
rng('default');rng('shuffle');
blockT = const.fromBlock;

for t_trial = 1:expDes.nb_trials
    switch const.typeTask
        case 1; rand_rand1 = const.MC_offsets(t_trial);
                rand_rand2 = const.positionRandom(t_trial);
                expDes.expMat(t_trial,:) = [ blockT, t_trial, rand_rand1,rand_rand2];
        case 2;
            cond1     = expDes.cond1All(blockT);
            rand_var1 = const.subdirections(t_trial);
            rand_var2 = const.subtasks(t_trial);
            expDes.expMat(t_trial,:) = [ blockT, t_trial, cond1, rand_var1, rand_var2];
        case 3;
            rand_var1 = const.subtasks(t_trial);
            rand_var2 = const.fixtask(t_trial);
            expDes.expMat(t_trial,:) = [ blockT, t_trial, rand_var1,rand_var2];
    end
end

end
