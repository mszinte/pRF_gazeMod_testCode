function expDes = phase_forward(const,expDes,t)
% ----------------------------------------------------------------------
% expDes = phase_forward(const,expDes)
% ----------------------------------------------------------------------
% Goal of the function :
% Change phase number and print in the log and edf file
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% expDes : struct containg experimental design
% t : trial number
% ----------------------------------------------------------------------
% Output(s):
% expDes : experimental trial config
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 30 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

expDes.phase = expDes.phase + 1;
log_txt = sprintf('trial %i phase %i started at %f',t-1,expDes.phase,GetSecs);
fprintf(const.log_text_fid,'%s\n',log_txt);
if const.tracker;Eyelink('message','%s',log_txt);end

end