function compute_eccBin
% ----------------------------------------------------------------------
% compute_eccBin
% ----------------------------------------------------------------------
% Goal of the function :
% Plot ecc bin
% ----------------------------------------------------------------------
% Input(s) :
% none
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 21/ 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.0
% ----------------------------------------------------------------------
close all
clear all
start_X = 0;
start_Y = 0;
sizeX = 1920;
sizeY = 1080;
f = figure;

set(f,'Name');
const.stim_rad          = 500;
const.bar_width_ratio   = 0.1;
const.full_width        = const.stim_rad*2 * (1+const.bar_width_ratio);
const.directions        = 0:pi/4:2*pi-pi/4;
const.stimCtr           = [sizeX/2,sizeY/2];
const.fix               = [(const.stimCtr(1)-const.stim_rad/2),const.stimCtr(2);...
                           (const.stimCtr(1)+const.stim_rad/2),const.stimCtr(2);...
                           const.stimCtr(1),const.stimCtr(2)];
const.numBin            = 4;
meanDistAll             = [];
for tPos = 1:size(const.fix,1)
    for tOri = 1:8;
        for current_phase = linspace(0,1,32)
            stim.current_phase          = current_phase;
            stim.midpoint               = stim.current_phase * const.full_width - 0.5 * const.full_width;
            stim.mapper_orientation     = const.directions(tOri);
            stim.rotation_matrix        = [cos(stim.mapper_orientation),sin(stim.mapper_orientation);sin(stim.mapper_orientation),-cos(stim.mapper_orientation)];
            barLeftEnd = (([-const.stim_rad,-stim.midpoint]) * stim.rotation_matrix) + const.stimCtr;
            barRightEnd = (([const.stim_rad,-stim.midpoint]) * stim.rotation_matrix) + const.stimCtr;
            distFixLeftEnd  = sqrt((barLeftEnd(1)-const.fix(tPos,1))^2+(barLeftEnd(2)-const.fix(tPos,2))^2);
            distFixRightEnd = sqrt((barRightEnd(1)-const.fix(tPos,1))^2+(barRightEnd(2)-const.fix(tPos,2))^2);
            meanDist = mean([distFixLeftEnd,distFixRightEnd]);
            meanDistAll = [meanDistAll;tPos,tOri,current_phase,meanDist];
        end
    end
end
    
valBin = prctile(meanDistAll(:,4),[0,100/const.numBin,200/const.numBin,300/const.numBin,100]);

% plot it
xCircle=const.stim_rad*cos(0:0.01:2*pi);
yCircle=const.stim_rad*sin(0:0.01:2*pi);
for tPos = 1:size(const.fix,1)
    for tOri = 1:8;
        hold off;plot(sizeX/2+xCircle,sizeY/2+yCircle);
        hold on;
        plot(const.fix(tPos,1),const.fix(tPos,2),'r+');
        for current_phase = linspace(0,1,32)
            stim.current_phase  = current_phase;
            stim.midpoint = stim.current_phase * const.full_width - 0.5 * const.full_width;
            var1 = tOri-1;
            stim.mapper_orientation     = const.directions(var1+1);
            stim.rotation_matrix        = [cos(stim.mapper_orientation),sin(stim.mapper_orientation);sin(stim.mapper_orientation),-cos(stim.mapper_orientation)];
            
            barLeftEnd = (([-const.stim_rad,-stim.midpoint]) * stim.rotation_matrix) + const.stimCtr;
            barRightEnd = (([const.stim_rad,-stim.midpoint]) * stim.rotation_matrix) + const.stimCtr;
            distFixLeftEnd  = sqrt((barLeftEnd(1)-const.fix(tPos,1))^2+(barLeftEnd(2)-const.fix(tPos,2))^2);
            distFixRightEnd = sqrt((barRightEnd(1)-const.fix(tPos,1))^2+(barRightEnd(2)-const.fix(tPos,2))^2);
            meanDist = mean([distFixLeftEnd,distFixRightEnd]);
            
            p = plot(linspace(barLeftEnd(1),barRightEnd(1),10),linspace(barLeftEnd(2),barRightEnd(2),10));
            
            for tBin = 1:const.numBin
                if tBin < const.numBin
                    if meanDist >= valBin(tBin) && meanDist < valBin(tBin+1)
                        set(p,'Color',[tBin/const.numBin,0.4,0.4],'LineWidth',3);
                    end
                else
                    if meanDist >= valBin(tBin) && meanDist <= valBin(tBin+1)
                        set(p,'Color',[tBin/const.numBin,0.4,0.4],'LineWidth',3);
                    end
                end
            end
            
            set(gca,'XLim',[0,sizeX],'YLim',[0,sizeY],'yDir','reverse');
            axis equal
            
            pause(0.01)
        end
        pause(0.4)
    end
end

end
