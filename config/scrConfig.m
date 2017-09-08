function [scr]=scrConfig(const)
% ----------------------------------------------------------------------
% [scr]=scrConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define configuration relative to the screen
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% scr : struct containing screen configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 21 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

% Number of the exp screen:
scr.all = Screen('Screens');
scr.scr_num = max(scr.all);

% Screen resolution (pixel) :
[scr.scr_sizeX, scr.scr_sizeY]=Screen('WindowSize', scr.scr_num);
if (scr.scr_sizeX ~= const.desiredRes(1) || scr.scr_sizeY ~= const.desiredRes(2)) && const.expStart
    error('Incorrect screen resolution => Please restart the program after changing the resolution to [%i,%i]',const.desiredRes(1),const.desiredRes(2));
end

% Size of the display :
scr.disp_sizeX = 698.4;scr.disp_sizeY=392.9;       % setting for BOLDScreen32'
%scr.disp_sizeX = 525;  scr.disp_sizeY=295;         % setting for VPixx 3D lite
scr.disp_sizeLeft  = round(-scr.disp_sizeX/2);     % physical size of the screen from center to left edge (mm)
scr.disp_sizeRight = round(scr.disp_sizeX/2);      % physical size of the screen from center to top edge (mm)
scr.disp_sizeTop   = round(scr.disp_sizeY/2);      % physical size of the screen from center to right edge (mm)
scr.disp_sizeBot   = round(-scr.disp_sizeY/2);     % physical size of the screen from center to bottom edge (mm)

% Pixels size:
scr.clr_depth = Screen('PixelSize', scr.scr_num);

% Frame rate : (fps)
scr.frame_duration =1/(Screen('FrameRate',scr.scr_num));
if scr.frame_duration == inf;
    scr.frame_duration = 1/60;
    Screen('Preference', 'SkipSyncTests', 1);
elseif scr.frame_duration ==0;
    scr.frame_duration = 1/60;
    Screen('Preference', 'SkipSyncTests', 1);
end

% Frame rate : (hertz)
scr.hz = 1/(scr.frame_duration);
if (scr.hz >= 1.1*const.desiredFD || scr.hz <= 0.9*const.desiredFD) && const.expStart && ~strcmp(const.sjct,'DEMO');
    error('Incorrect refresh rate => Please restart the program after changing the refresh rate to %i Hz',const.desiredFD);
end

if ~const.expStart
    warning('off');Screen('Preference', 'SkipSyncTests', 2);
end


% Subject dist
scr.dist = 225;             % setting for 7T Phillips scanner BOLD screen
%scr.dist = 60;              % setting for PhantomLab vPixx 3D Lite

% Screen distance (top and bottom from line of sight in MM !!!!)
scr.distTop = 2250;         % setting for 7T Phillips scanner BOLD screen
scr.distBot = 2250;         % setting for 7T Phillips scanner BOLD screen
%scr.distTop = 610;          % setting for PhantomLab vPixx 3D Lite
%scr.distBot = 630;          % setting for PhantomLab vPixx 3D Lite

% Center of the screen :
scr.x_mid = (scr.scr_sizeX/2.0);
scr.y_mid = (scr.scr_sizeY/2.0);
scr.mid = [scr.x_mid,scr.y_mid];

end