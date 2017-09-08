function [gabor] = generateGabor(imsize,lambda,theta,sigma,phase,col1,col2)
% ----------------------------------------------------------------------
% [gabor] = generateGabor(imsize,lambda,theta,sigma,phase,col1,col2)
% ----------------------------------------------------------------------
% Goal of the function :
% Generate a gabor of 2 colors
% ----------------------------------------------------------------------
% Input(s) :
% imsize = gabor rad in pixels
% lambda = wavelength of the gabor (number of pixels per cycles)
% theta = gabor orientation (in degrees)
% sigma = gaussian standard deviation (in pixels)
% phase = gabor phase (0 => 1)
% col1 = first color
% col2 = second color
% ----------------------------------------------------------------------
% Output(s):
% gabor = 4D RGBA gabor matrix
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 21 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.0
% ----------------------------------------------------------------------

X = 1:imsize;                                               % X is a vector from 1 to imageSize
X0 = (X / imsize) - .5;                                     % rescale X -> -.5 to .5
[Xm,Ym] = meshgrid(X0, X0);
freq = imsize/lambda;                                       % compute frequency from wavelength
phaseRad = (phase * 2* pi);                                 % convert to radians: 0 -> 2*pi

thetaRad = (theta / 360) * 2*pi;                            % convert theta (orientation) to radians
Xt = Xm * cos(thetaRad);                                    % compute proportion of Xm for given orientation
Yt = Ym * sin(thetaRad);                                    % compute proportion of Ym for given orientation

XYt = [ Xt + Yt ];                                          % sum X and Y components
XYf = XYt * freq * 2*pi;                                    % convert to radians and scale by frequency
grating = sin( XYf + phaseRad);                             % make 2D sinewave
grating = grating / 2 + 0.5;

gratingCol1(:, :, 1) = grating*col1(1);
gratingCol1(:, :, 2) = grating*col1(2);
gratingCol1(:, :, 3) = grating*col1(3);

gratingCol2(:, :, 1) = (1-grating)*col2(1);
gratingCol2(:, :, 2) = (1-grating)*col2(2);
gratingCol2(:, :, 3) = (1-grating)*col2(3);

gabor = gratingCol1+gratingCol2;

s = sigma / imsize;                                         % gaussian width as fraction of imageSize
gauss = exp( -(((Xm.^2)+(Ym.^2)) ./ (2* s^2)) );            % formula for 2D gaussian
gabor(:,:,4) = gauss*255;

end

