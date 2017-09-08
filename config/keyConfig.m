function [my_key]=keyConfig
% ----------------------------------------------------------------------
% [my_key]=keyConfig
% ----------------------------------------------------------------------
% Goal of the function :
% Unify key names and define structure containing each key names
% ----------------------------------------------------------------------
% Input(s) :
% none
% ----------------------------------------------------------------------
% Output(s):
% my_key : structure containing keyboard configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 30 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

KbName('UnifyKeyNames');

my_key.tVal     =   't';
my_key.eVal     =   'e';
my_key.bVal     =   'b';
my_key.yVal     =   'y';
my_key.spaceVal =   ' ';
my_key.escape   =   KbName('ESCAPE');
my_key.space    =   KbName('Space');
my_key.t        =   KbName('t');            % TR
my_key.e        =   KbName('e');            % top left button in scanner
my_key.b        =   KbName('b');            % top right button in scanner
my_key.y        =   KbName('y');            % middle right button in scanner

end