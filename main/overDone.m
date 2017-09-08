function overDone(const)
% ----------------------------------------------------------------------
% overDone(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Close screen and audio, transfer eye-link data, close files
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 30 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

% Close all fid
% ------------- 
fclose(const.log_text_fid);
if const.expStart;fclose(const.colRatio_fid);end

% Transfer .edf file
% ------------------
if const.tracker
    statRecFile = Eyelink('ReceiveFile',const.eyelink_temp_file,const.eyelink_temp_file);
    
    if statRecFile ~= 0
        fprintf(1,'\n\tEyelink EDF file correctly transfered');
    else
        fprintf(1,'\n\Error in Eyelink EDF file transfer');
        statRecFile2 = Eyelink('ReceiveFile',const.eyelink_temp_file,const.eyelink_temp_file);
        if statRecFile2 == 0
            fprintf(1,'\n\tEyelink EDF file is now correctly transfered');
        else
            fprintf(1,'\n\n\t!!!!! Error in Eyelink EDF file transfer !!!!!');
        end
    end
end

% Close link with eye tracker
% ---------------------------
if const.tracker 
    Eyelink('CloseFile');
    WaitSecs(2.0);
    Eyelink('Shutdown');
    WaitSecs(2.0); 
end

% Rename eye tracker file
% -----------------------
if const.tracker 
    oldDir = const.eyelink_temp_file;
    newDir = const.eyelink_local_file;
    movefile(oldDir,newDir);
end

% Close Psychtoolbox screen
% -------------------------
ListenChar(1);ShowCursor;
Screen('CloseAll');

% Print block duration
% --------------------
timeDur=toc/60;
fprintf(1,'\n\n\tThis part of the experiment took : %2.0f min.\n\n',timeDur);

end