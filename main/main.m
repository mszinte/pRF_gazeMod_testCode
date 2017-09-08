function main(const)
% ----------------------------------------------------------------------
% main(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Launch all function of the experiment
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing a lot of constant configuration
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

% File director
% -------------
[const] = dirSaveFile(const);

% Network settings for Eyelink
% ----------------------------
if ismac
    if const.tracker
        [~,~] = system('echo osimande | sudo -S networksetup -switchtolocation "Eyelink"');
    else
        [~,~] = system('echo osimande | sudo -S networksetup -switchtolocation "Web"');
    end
    pause(5);
end

% Screen configurations
% ---------------------
[scr] = scrConfig(const);

% Keyboard configurations
% -----------------------
tic;[my_key] = keyConfig;

% Experimental constant
% ---------------------
[const] = constConfig(scr,const);

% Experimental design
% -------------------
[expDes] = designConfig(const);

% Open screen window
% ------------------
[scr.main,scr.rect] = Screen('OpenWindow',scr.scr_num,const.background_color,[], scr.clr_depth,2);
Screen('BlendFunction', scr.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
priorityLevel = MaxPriority(scr.main);Priority(priorityLevel);

% Initialise eye tracker
% ----------------------
if const.tracker;[el] = initEyeLink(scr,const);
else el = [];end

% Trial runner
% ------------
ListenChar(2);
runTrials(scr,const,expDes,el,my_key);

% End
% ---
overDone(const);

end