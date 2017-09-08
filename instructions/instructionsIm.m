function instructionsIm(scr,const,my_key,nameImage,exitFlag,scannerT)
% ----------------------------------------------------------------------
% instructionsIm(scr,const,my_key,text,button,exitFlag,scannerT)
% ----------------------------------------------------------------------
% Goal of the function :
% Display instructions draw in .tif file.
% ----------------------------------------------------------------------
% Input(s) :
% scr : main window pointer.
% const : struct containing all the constant configurations.
% nameImage : name of the file image to display
% exitFlag : if = 1 (quit after 5sec)
% scannerT : wait for scanner T
% ----------------------------------------------------------------------
% Output(s):
% (none)
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 22 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.0
% ----------------------------------------------------------------------
while KbCheck(-1); end
KbName('UnifyKeyNames');

dirImageFile = 'instructions/image/';
dirImage = [dirImageFile,nameImage,'.png'];
[imageToDraw,~,alpha] =  imread(dirImage);
imageToDraw(:,:,4) = alpha;

t_handle = Screen('MakeTexture',scr.main,imageToDraw);
texrect = Screen('Rect', t_handle);
push_button = 0;

t0 = GetSecs;
tEnd = 3;
while ~push_button;
    
    FlushEvents ;
    Screen('FillRect',scr.main,const.background_color);
    Screen('DrawTexture',scr.main,t_handle,texrect,[0,0,scr.scr_sizeX,scr.scr_sizeY]);
    t1 = Screen('Flip',scr.main);
    
    if exitFlag
        if t1 - t0 > tEnd;
            push_button=1;
        end
    end
    
    keyIsDown = CharAvail;
    if keyIsDown
        keyCode = GetChar(1);
        if strcmp(keyCode,my_key.spaceVal)
            push_button=1;
        elseif strcmp(keyCode,my_key.tVal) && scannerT && const.scanner
            push_button=1;
            log_txt = sprintf('trial 0 event t at %f',GetSecs);
            fprintf(const.log_text_fid,'%s\n',log_txt);
            if const.tracker; Eyelink('message','%s',log_txt);end
        end
    end
    if ~const.expStart
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if keyIsDown
            if (keyCode(my_key.escape))
                overDone(const)
            end
        end
    end
end

Screen('Close',t_handle);
end