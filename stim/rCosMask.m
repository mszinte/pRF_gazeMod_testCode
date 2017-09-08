function imageMatCol = rCosMask(scr,const,colorOut,pos)
% ----------------------------------------------------------------------
% imageMatCol = rCosMask(scr,const,colorOut,pos)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw a raised cosine circular mask
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% colorOut = color outside the circular mask
% pos = position
% ----------------------------------------------------------------------
% Output(s):
% imageMatCol: 3D-RGBA matrix of the rCosMask
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 21 / 11 / 2016
% Project :     pRF_exp
% Version :     2.0
% ----------------------------------------------------------------------

hamming_len = const.rCosine_grain*2;
raised_cos = hamming(hamming_len);
raised_cos = raised_cos(1:hamming_len/2);
raised_cos = (raised_cos - min(raised_cos))/(max(raised_cos)-min(raised_cos));
raised_cos = flipud(raised_cos);
cRf = const.aperture_blur*const.aperture_rad;

[x,y]=meshgrid(0:scr.scr_sizeX-1,0:scr.scr_sizeY-1);

% blury part
imageMatAlpha = ones(size(x,1),size(y,2));
imageMat = ones(size(x,1),size(y,2));
for t = 1:size(raised_cos,1)
    maxR = const.aperture_rad - (t-1)*(cRf/size(raised_cos,1));
    minR = const.aperture_rad - t*(cRf/size(raised_cos,1));
    circleFringeT = abs((y-pos(2)).^2 + (x-pos(1)).^2) <= maxR.^2 & abs((y-pos(2)).^2 + (x-pos(1)).^2) >= minR.^2;
    imageMatAlpha(circleFringeT)=raised_cos(t);
end

circleRest = abs((y-pos(2)).^2 + (x-pos(1)).^2) <= minR.^2 & abs((y-pos(2)).^2 + (x-pos(1)).^2) >= 0.^2;
imageMatAlpha(circleRest)=raised_cos(t);

imageMatCol(:,:,1) = imageMat*colorOut(1);
imageMatCol(:,:,2) = imageMat*colorOut(2);
imageMatCol(:,:,3) = imageMat*colorOut(3);
imageMatCol(:,:,4) = imageMatAlpha*255;

end