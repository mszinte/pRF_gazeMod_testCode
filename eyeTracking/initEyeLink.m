function [el]=initEyeLink(scr,const)
% ----------------------------------------------------------------------
% [el]=initEyeLink(scr,const)
% ----------------------------------------------------------------------
% Goal of the function :
% Initializes eyeLink-connection, creates edf-file
% and writes experimental parameters to edf-file
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% el : struct containing eyelink configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 30 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

%% Modify different defaults settings :
el=EyelinkInitDefaults(scr.main);
el.msgfontcolour                = WhiteIndex(el.window);
el.imgtitlecolour               = WhiteIndex(el.window);
el.targetbeep                   = 0;
el.feedbackbeep                 = 0;
el.eyeimgsize                   = 50;
el.displayCalResults            = 1;
el.backgroundcolour             = const.background_color;
el.fixation_outer_rim_rad       = const.fixation_outer_rim_rad;
el.fixation_rim_rad             = const.fixation_rim_rad;
el.fixation_rad                 = const.fixation_rad;
el.fixation_outer_rim_color     = const.fixation_outer_rim_color;
el.fixation_rim_color           = const.fixation_rim_color;
el.fixation_color               = const.fixation_color;
el.txtCol                       = 15;
el.bgCol                        = 0;
EyelinkUpdateDefaults(el);

%% Initialization of the connection with the Eyelink Gazetracker.
if ~EyelinkInit(0)
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

%% open file to record data to
res = Eyelink('Openfile', const.eyelink_temp_file);
if res~=0
    fprintf('Cannot create EDF file ''%s'' ', const.eyelink_temp_file);
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

% make sure we're still connected.
if Eyelink('IsConnected')~=1 
    fprintf('Not connected. exiting');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

%% Set up tracker personal configuration :
% Set parser
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,AREA,GAZERES,STATUS,HTARGET');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,FIXUPDATE,SACCADE,BLINK');
Eyelink('command', 'link_sample_data  = GAZE,GAZERES,AREA,HREF,VELOCITY,FIXAVG,STATUS');

% Scree settings
Eyelink('command','screen_pixel_coords = %d %d %d %d', 0, 0, scr.scr_sizeX-1, scr.scr_sizeY-1);
Eyelink('command','screen_phys_coords = %d %d %d %d',scr.disp_sizeLeft,scr.disp_sizeTop,scr.disp_sizeRight,scr.disp_sizeBot);
Eyelink('command','screen_distance = %d %d', scr.distTop, scr.distBot);
Eyelink('command','simulation_screen_distance = %d', scr.dist*10);
% Tracking mode and settings
Eyelink('command','enable_automatic_calibration = NO');
Eyelink('command','pupil_size_diameter = YES');
Eyelink('command','heuristic_filter = 1 1');
Eyelink('command','saccade_velocity_threshold = 30');
Eyelink('command','saccade_acceleration_threshold = 9500');
Eyelink('command','saccade_motion_threshold = 0.15');
Eyelink('command','use_ellipse_fitter =  NO');
Eyelink('command','sample_rate = %d',500);

% Initial log
message_log = sprintf('degrees per pixel %1.4f',const.pixel_per_degree);
Eyelink('message','%s',message_log);

% % Personal calibrations
rng('default');rng('shuffle');
Eyelink('command', 'calibration_type = HV13');
Eyelink('command', 'generate_default_targets = NO');

Eyelink('command', 'randomize_calibration_order 1');
Eyelink('command', 'randomize_validation_order 1');
Eyelink('command', 'cal_repeat_first_target 1');
Eyelink('command', 'val_repeat_first_target 1');

Eyelink('command', 'calibration_samples=14');
Eyelink('command', 'calibration_sequence=0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
Eyelink('command', sprintf('calibration_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',const.calibCoord));

Eyelink('command', 'validation_samples=14');
Eyelink('command', 'validation_sequence=0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
Eyelink('command', sprintf('validation_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',const.validCoord));

%% make sure we're still connected.
if Eyelink('IsConnected')~=1
    fprintf('Not connected. exiting');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

end