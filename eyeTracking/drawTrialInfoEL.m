function drawTrialInfoEL(scr,const,expDes,t)
% ----------------------------------------------------------------------
% drawTrialInfoEL(scr,const,expDes,t)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw on the eyelink display the trial configuration
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : struct containg experimental design
% t : trial number
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 01 / 12 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

% o--------------------------------------------------------------------o
% | EL Color index                                                     |
% o----o----------------------------o----------------------------------o
% | Nb |  Other(cross,box,line)     | Clear screen                     |
% o----o----------------------------o----------------------------------o
% |  0 | black                      | black                            |
% o----o----------------------------o----------------------------------o
% |  1 | dark blue                  | dark dark blue                   |
% o----o----------------------------o----------------------------------o
% |  2 | dark green                 | dark blue                        |
% o----o----------------------------o----------------------------------o
% |  3 | dark turquoise             | blue                             |
% o----o----------------------------o----------------------------------o
% |  4 | dark red                   | light blue                       |
% o----o----------------------------o----------------------------------o
% |  5 | dark purple                | light light blue                 |
% o----o----------------------------o----------------------------------o
% |  6 | dark yellow (brown)        | turquoise                        |
% o----o----------------------------o----------------------------------o
% |  7 | light gray                 | light turquoise                  | 
% o----o----------------------------o----------------------------------o
% |  8 | dark gray                  | flashy blue                      |
% o----o----------------------------o----------------------------------o
% |  9 | light purple               | green                            |
% o----o----------------------------o----------------------------------o
% | 10 | light green                | dark dark green                  |
% o----o----------------------------o----------------------------------o
% | 11 | light turquoise            | dark green                       |
% o----o----------------------------o----------------------------------o
% | 12 | light red (orange)         | green                            |
% o----o----------------------------o----------------------------------o
% | 13 | pink                       | light green                      |
% o----o----------------------------o----------------------------------o
% | 14 | light yellow               | light green                      |
% o----o----------------------------o----------------------------------o
% | 15 | white                      | flashy green                     |
% o----o----------------------------o----------------------------------o

% Color config
frameCol        = 15;
stimCol         = 9;
ftCol           = 15;
textCol         = 15;
boxCol          = 12;
BGcol           = 0;

% clear screen
eyeLinkClearScreen(BGcol);

if const.typeTask == 1
    % Rand 1 : RG offset
    rand1 = expDes.expMat(t,3);
    % cond 1: fixation position
    rand2 = expDes.expMat(t,4);
elseif const.typeTask == 2
    % cond 1: fixation position
    cond1 = expDes.expMat(t,3);
    % Var 1 : orientation
    var1 = expDes.expMat(t,4);
    txt_var1 = {'0 deg','45 deg','90 deg','135 deg','180 deg','225 deg','270 deg','315 deg'};
    % Var 2 : type of task
    var2 = expDes.expMat(t,5);
    txt_var2 = {'color','fixation no stim'};
elseif const.typeTask == 3
    % Var 1 : type of task
    var1 = expDes.expMat(t,3);
    txt_var1 = {'fixation','fixation no stim'};
    
    % Var 2 : pulse occurence
    var2 = expDes.expMat(t,4);
    txt_var2 = {'present','absent'};
end

%% Draw Stimulus
% Stimuli
if const.typeTask == 1
    eyeLinkDrawBox(const.aperture_pos(rand2+1,1),const.aperture_pos(rand2+1,2),const.aperture_rad*2,const.aperture_rad*2,2,frameCol,stimCol);
elseif const.typeTask == 2
    eyeLinkDrawBox(const.aperture_pos(cond1+1,1),const.aperture_pos(cond1+1,2),const.aperture_rad*2,const.aperture_rad*2,2,frameCol,stimCol);
elseif const.typeTask == 3
    eyeLinkDrawBox(const.aperture_posHRF(1),const.aperture_posHRF(2),const.aperture_rad*2,const.aperture_rad*2,2,frameCol,stimCol);
end

% Fixation target
if const.typeTask == 2
    eyeLinkDrawBox(const.fixation_pos(cond1+1,1),const.fixation_pos(cond1+1,2),const.fixation_outer_rim_rad*2,const.fixation_outer_rim_rad*2,2,frameCol,ftCol);
elseif const.typeTask == 3
    eyeLinkDrawBox(const.fixationHRF_pos(1),const.fixationHRF_pos(2),const.fixation_outer_rim_rad*2,const.fixation_outer_rim_rad*2,2,frameCol,ftCol);
end

% No vision box
boxCtrX = (const.no_vision_rect(1)+const.no_vision_rect(3))/2;
boxCtrY = (const.no_vision_rect(2)+const.no_vision_rect(4))/2;
eyeLinkDrawBox(boxCtrX,boxCtrY,const.no_vision_width,const.no_vision_height,2,boxCol,boxCol);

% Two lines of text during trial (slow process)
remT    = size(expDes.expMat,1) - (t-1);
if const.typeTask == 1
    text0 = sprintf('RG offset = %.2f | tNum = %i | tRem=%3.0f ',rand1,t,remT);
elseif const.typeTask == 2
    text0 = sprintf('Ori.= %s | Task type = %s | tNum = %i | tRem=%3.0f ',txt_var1{var1+1},txt_var2{var2+1},t,remT);
elseif const.typeTask == 3
    text0 = sprintf('Task type = %s | Pulse = %s | tNum = %i | tRem=%3.0f ',txt_var1{var1+1},txt_var1{var2+1},t,remT);
end
eyeLinkDrawText(scr.x_mid,scr.scr_sizeY - 30,textCol,text0);
WaitSecs(0.1);

end