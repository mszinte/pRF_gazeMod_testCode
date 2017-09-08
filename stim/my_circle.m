function my_circle(scr,color,xy,r)
% ----------------------------------------------------------------------
% my_circle(wPtr,color,x,y,r)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw a circle at position (x,y) with radius (r).
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% color = color of the circle in RBG or RGBA        ex : color = [0 0 0]
% xy = position [x,y] of the center                 ex : xy = [550,350]
% r = radius for X (in pixel)                       ex : r = 25
% ----------------------------------------------------------------------
% Output(s):
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 21/ 11 / 2016
% Project :     pRF_gazeMod
% Version :     1.0
% ----------------------------------------------------------------------

if r>30
    Screen('FillOval',scr.main,color,[(xy(1)-r) (xy(2)-r) (xy(1)+r) (xy(2)+r)]);
else
    Screen('DrawDots', scr.main,[xy(1),xy(2)],r*2,color,[],2);
end

end