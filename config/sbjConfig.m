function [const] = sbjConfig(const)
% ----------------------------------------------------------------------
% [const]=sbjConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define subject configurations (initials, gender...)
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 29 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.1
% ----------------------------------------------------------------------

if const.expStart
    const.sjct =  upper(strtrim(input(sprintf('\n\tYour initials: '),'s')));
    if const.tracker
        const.sjct_DomEye='L';  % for all subjects
        const.recEye = 1;
    else
        const.sjct_DomEye='DM';
        const.recEye = 1;
    end
    const.fromBlock= input(sprintf('\n\tRun numbers: '));
    if const.fromBlock == 1 && const.typeTask == 1
        const.sjct_age = input(sprintf('\n\tAge: '));
        const.sjct_gender = upper(strtrim(input(sprintf('\n\tGender (M or F): '),'s')));
    end
else
    const.sjct          = 'Anon';
    const.sjct_age      = '00';
    const.sjct_gender   = 'X';
    const.sjct_DomEye   = 'DM';
    const.recEye        = 1;
    const.fromBlock = 1;fprintf(1,'\n\tFrom Block nb: 1\n\n');
end

end