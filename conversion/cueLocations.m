close all
clear all
sca

Screen('Preference','SkipSyncTests',2);
warning off;
'HideMouse';

scr.all = Screen('Screens');
scr.num = max(scr.all);
[scr.scr,rectRect] = Screen('OpenWindow',scr.num);

scrSize = get(0,'screensize');

center = [scrSize(3)/2; scrSize(4)/2];

angleDegOut = 0;
angleDegIn = 15;

outerCueLocVec = zeros(2,12);
innerCueLocVec = zeros(2,12);

for i = 1:12
    outerCueLocVec(1,i) = center(1) + sin(angleDegOut/180*pi)*200
    outerCueLocVec(2,i) = center(2) + cos(angleDegOut/180*pi)*200
    innerCueLocVec(1,i) = center(1) + sin(angleDegIn/180*pi)*160
    innerCueLocVec(2,i) = center(2) + cos(angleDegIn/180*pi)*160
    angleDegOut = angleDegOut + 30;
    angleDegIn = angleDegIn + 30;
end

allCueLocVec = [center outerCueLocVec innerCueLocVec]

fixCol = [127 127 127]';
cueCol = [0 0 0]';

allColVec = [fixCol repmat(cueCol,1,24)];

Screen('DrawDots',scr.scr, allCueLocVec,10,allColVec,[],2);
Screen('Flip',scr.scr)

KbName('UnifyKeyNames');
myKey.escape = KbName('Escape');
pushbutton = 0
    while pushbutton ==  0
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck
        if keyCode(myKey.escape)
           pushbutton == 1
           Screen('CloseAll')
           clear all
        end
    end
    

    
    


    
