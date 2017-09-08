function plot_pRF_results(initials,numBlock,eyetracker)
% ----------------------------------------------------------------------
% plot_pRF_results(initials,numBlock,eyetracker)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute and plot results from pRF experiment (behavioral and eye tracking
% date
% ----------------------------------------------------------------------
% Input(s) :
% initials : subject initials
% numBlock : number of block to analyse
% eyetracker : eye tracking data
% ----------------------------------------------------------------------
% Output(s):
% => pdf figures /data/xx/pRF_gazeMod/xx_0_results_plot.pdf
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 23 / 11 / 2016
% Project :     pRF_gazeMod
% Version :     2.0
% ----------------------------------------------------------------------

%% Get data
% Get behavioral data
fprintf(1,'\n\tProcessing data...\n');
time_lastBlock = 0;
for tBlock = 1:numBlock
    % extract start time
    file_dir = sprintf('data/%s/pRF_exp/',initials);
    log_name = dir(sprintf('data/%s/pRF_exp/%s_%i_2016*.txt',initials,initials,tBlock));
    log_fid = fopen(sprintf('%s%s',file_dir,log_name(end).name),'r');
    first_line = fgetl(log_fid);elements = textscan(first_line,'%s');
    timeStart(tBlock) = str2double(elements{1}(7));
    % extract end time
    last_line = 0;
    while ~last_line;elements = textscan(first_line,'%s');
        first_line = fgetl(log_fid);
        if first_line == -1;last_line = 1;timeEnd(tBlock) = str2double(elements{1}(5));end
    end
    fclose(log_fid);
    
    % extract data file
    data_name = dir(sprintf('data/%s/pRF_exp/%s_%i_2016*.mat',initials,initials,tBlock));
    load(sprintf('%s%s',file_dir,data_name(end).name));
    
    % load data
    if tBlock == 1
        resAll_color        = [];
        for tBin = 1:config.const.nr_staircases_ecc
            resAll_color_bin{tBin} = [];
        end
    end
    
    resBlock_color      = config.expDes.resColor;
    for tBin = 1:config.const.nr_staircases_ecc
        resBlock_color_bin{tBin} = config.expDes.resColor(config.expDes.resColor(:,6)==tBin-1,:);
    end
    % rows = pulse occurences
    % col1 = block number
    % col2 = trial number
    % col3 = fixation position (0 = right, 1 = up, 2 = left, 3 = down)
    % col4 = orientation of the stim
    % col5 = type of task (0 = color; 1 = speed; 2 = fix; 3 = fix no stim)
    % col6 = eccentricity bin (0 = 0->1/3, 1 = 1/3->2/3; 2 = 2/3 -> 1 of stim rad)
    % col7 = staircase quest/staricase value
    % col8 = signal time
    % col9 = response (NaN if no response before next signal)
    % col10 = response/update time (NaN if no response before next signal)

    % compute time relative to start of trial and across blocks
    resBlock_color(:,8)         =   (resBlock_color(:,8)-timeStart(tBlock))+time_lastBlock;
    matMax = [];
    for tBin = 1:config.const.nr_staircases_ecc
        resBlock_color_bin{tBin}(:,8) =   (resBlock_color_bin{tBin}(:,8)-timeStart(tBlock))+time_lastBlock;
        matMax  = [matMax,resBlock_color_bin{tBin}(end,8)];
    end
    time_lastBlock = max(matMax);
    
	resAll_color        = [resAll_color;        resBlock_color];
    for tBin = 1:config.const.nr_staircases_ecc
        resAll_color_bin{tBin} = [resAll_color_bin{tBin};   resBlock_color_bin{tBin}];       
    end
end

% compute in time percentage between start and end
resAll_color(:,11)      = resAll_color(:,8)/sum(timeEnd - timeStart);
for tBin = 1:config.const.nr_staircases_ecc
    resAll_color_bin{tBin}(:,11) = resAll_color_bin{tBin}(:,8)/sum(timeEnd - timeStart);

    % compute percentage correct
    for occurence = 1:size(resAll_color_bin{tBin},1);    resAll_color_bin{tBin}(occurence,12) = nanmean(resAll_color_bin{tBin}(1:occurence,9));end
    
    % compute physical value played
    for occurence = 1:size(resAll_color_bin{tBin},1);    resAll_color_bin{tBin}(occurence,13) = 1 - (1/(exp(1).^resAll_color_bin{tBin}(occurence,7)+1));end
end

% Get eye data
zoomVal = 1;
if eyetracker
    % get fixation data across trials
    time_lastBlock      = 0;
    eye_data_allblock   = [];
    fixAccuracy         = [];
    for tBlock = 1:numBlock
        
        % extract data file
        file_dirEye = sprintf('data/%s/pRF_exp/',initials);
        data_nameEye = dir(sprintf('data/%s/pRF_exp/%s_%i_2016*.edf',initials,initials,tBlock));
        data_nameEye = data_nameEye(end).name(1:end-4);
        
        % get .msg and .dat file
        if ~exist(sprintf('%s%s.msg',file_dirEye,data_nameEye),'file') && ~exist(sprintf('%s%s.dat',file_dirEye,data_nameEye),'file')
            [~,~] = system(['edf2asc',' ', sprintf('%s%s',file_dirEye,data_nameEye),'.edf -e -y']);
            movefile(sprintf('%s%s.asc',file_dirEye,data_nameEye),sprintf('%s%s.msg',file_dirEye,data_nameEye));
            [~,~] = system(['edf2asc', ' ',sprintf('%s%s',file_dirEye,data_nameEye),'.edf -s -miss -1.0 -y']);
            movefile(sprintf('%s%s.asc',file_dirEye,data_nameEye),sprintf('%s%s.dat',file_dirEye,data_nameEye));
        end
        
        % get first and last time
        msgfid = fopen(sprintf('%s%s.msg',file_dirEye,data_nameEye),'r');
        firstlastTime   = 0;
        firstTime       = 0;
        lastTime        = 0;
        while ~firstlastTime
            line = fgetl(msgfid);
            if ~isempty(line)                           % skip empty lines
                la = textscan(line,'%s');
                % get first time
                if size(la{1},1) > 5
                    if strcmp(la{1}(3),'trial') && strcmp(la{1}(4),'0') && ~firstTime
                        timeStartEye(tBlock) = str2double(la{1}(2));
                        firstTime = 1;
                    end
                    
                    if strcmp(la{1}(3),'trial') && strcmp(la{1}(4),'13') && strcmp(la{1}(5),'stopped') && ~lastTime
                        timeEndEye(tBlock) = str2double(la{1}(2));
                        lastTime = 1;
                    end
                end
                if firstTime && lastTime
                    firstlastTime = 1;
                    fclose(msgfid);
                end
            end
        end
        
        % extract mat data file
        load(sprintf('%s%s.mat',file_dirEye,data_nameEye));
        
        % load eye coord data
        datafid = fopen(sprintf('%s%s.dat',file_dirEye,data_nameEye),'r');
        eye_dat = textscan(datafid,'%f%f%f%f%s');
        fclose(datafid);
        eye_data_block = [eye_dat{1},eye_dat{2},eye_dat{3}];
        eye_data_block = eye_data_block(eye_data_block(:,1)>=timeStartEye(tBlock) & eye_data_block(:,1)<=timeEndEye(tBlock),:);
        % col 1 = time
        % col 2 = eye x coord
        % col 3 = eye y coord
        
        % compute time relative to start of trial and across blocks
        eye_data_block(:,1) =  (eye_data_block(:,1)-timeStartEye(tBlock))+time_lastBlock;
        time_lastBlock = eye_data_block(end,1);
        
        
        % delete blink time
        blinkNum = 0;
        blink_start = 0;
        for tTime = 1:size(eye_data_block,1)
            
            if ~blink_start
                if eye_data_block(tTime,2)==-1
                    blinkNum = blinkNum + 1;
                    timeBlinkOnset = eye_data_block(tTime,1);
                    blink_start = 1;
                    blink_onset_offset(blinkNum,:) = [timeBlinkOnset,NaN];
                end
            end
            if blink_start
                if eye_data_block(tTime,2)~=-1
                    timeBlinkOfffset = eye_data_block(tTime,1);
                    blink_start = 0;
                    blink_onset_offset(blinkNum,2) = timeBlinkOfffset;
                end
            end
        end
        
        % nan record around detected blinks
        befDurBlink = 150;   % duration before blink
        aftDurBlink = 300;   % duration after blink
        for tBlink = 1:blinkNum
            blink_onset_offset(tBlink,:) = [blink_onset_offset(tBlink,1)-befDurBlink,blink_onset_offset(tBlink,1)+aftDurBlink];
            eye_data_block(eye_data_block(:,1) >= blink_onset_offset(tBlink,1) & eye_data_block(:,1) <= blink_onset_offset(tBlink,2),2) = NaN;
            eye_data_block(eye_data_block(:,1) >= blink_onset_offset(tBlink,1) & eye_data_block(:,1) <= blink_onset_offset(tBlink,2),3) = NaN;
        end
        
        eye_data_allblock = [eye_data_allblock;eye_data_block];

        % compute mean accuracy and precision
        fixRight = config.const.fixation_pos(1,:);
        fixLeft  = config.const.fixation_pos(2,:);
        cond1 = config.expDes.cond1All(tBlock);
        if cond1 == 0;          fixPos = fixRight;
        elseif cond1 == 1;      fixPos = fixLeft;
        end
        fixAccuracy = [fixAccuracy;sqrt((eye_data_block(:,2) - fixPos(1)).^2 + (eye_data_block(:,3) - fixPos(2)).^2)];
        
    end
    
    % compute in time percentage between start and end
    eye_data_allblock(:,1) = eye_data_allblock(:,1)/sum(timeEndEye - timeStartEye);
    
    % put eye coordinates in deg from center (flip y axis)
    eye_data_allblock(:,2) = (eye_data_allblock(:,2) - config.scr.x_mid)/config.const.pixel_per_degree;
    eye_data_allblock(:,3) = (-1*(eye_data_allblock(:,3) - config.scr.y_mid))/config.const.pixel_per_degree;
    
    % compute fixation heatmap
    radMaxX     = floor(config.scr.x_mid/config.const.pixel_per_degree)/zoomVal;
    radMaxY     = floor(config.scr.y_mid/config.const.pixel_per_degree)/zoomVal;
    
    [~,densityFix,xHeatMap,yHeatMap]=kde2d([eye_data_allblock(:,2),eye_data_allblock(:,3)],[-radMaxX,-radMaxY],[radMaxX,radMaxY],2^8);
    densityFix_min = min(min(densityFix));
    densityFix_max = max(max(densityFix));
    densityFix = (densityFix - densityFix_min)./(densityFix_max-densityFix_min);
    
    % compute mean fixation accuracy
    accuracyVal = nanmean(fixAccuracy/config.const.pixel_per_degree);
    % compute mean fixation precision
    precisionVal = nanstd(fixAccuracy/config.const.pixel_per_degree,1);
    
end


%% Plot figure
fprintf(1,'\n\tPlotting figure...\n');
% set figure
close all
if eyetracker;  numRow  = 2;
else            numRow  = 1;
end
numColumn               = 3;
white                   = [1,1,1];
black                   = [0,0,0];
gray                    = [0.6,0.6,0.6];
beige                   = [230,230,230]/255;
sizeX                   = 1920/4;
sizeY                   = 1080/4;
figSize_X               = sizeX*numColumn;
figSize_Y               = sizeY*numRow;
start_X                 = 0;
start_Y                 = 0;
paperSize               = [figSize_X/30,figSize_Y/30];
paperPos                = [0 0 paperSize(1) paperSize(2)];
name                    = sprintf('%s results',initials);
f                       = figure;
set(f,'Name',name,'PaperUnits','centimeters','PaperPosition',paperPos,'Color',[1 1 1],'PaperSize',paperSize);
set(f,'Position',[start_X,start_Y,figSize_X,figSize_Y]);
mapVal                  = viridis(100);
resCol                  = [mapVal(1,:);mapVal(200/4+1,:);mapVal(end,:)];
colormap(mapVal);


% plot data
xlim        = [0,1];
xtick       = 0:0.1:1;
xyscale     = sizeY/sizeX;
xtitle      = 'Time (%)';
mergin      = 0.05;
tickratio   = 0.03;

for tBin = 1:config.const.nr_staircases_ecc
    legTxt{tBin} = sprintf('Color bin %i',tBin-1);
end

for tRow = 1:numRow
    numPlot     = config.const.nr_staircases_ecc;
    resTask     = resAll_color;
    valTask     = 0;
    
    for tCol = 1:numColumn
       
        x_start = (tCol-1)/numColumn;
        y_start = (numRow-tRow)/numRow;
        x_size = 1/numColumn;
        y_size = 1/numRow;
        axes('position',[x_start,y_start,x_size,y_size]);
        
        hold on
        if tRow == 1
            if tCol == 1
                plot_column = 7;
                matMax = [];
                for tBin = 1:config.const.nr_staircases_ecc
                    matMax = [matMax;resAll_color_bin{tBin}(:,plot_column)];
                end
                valMax      = ceil(max(matMax));
                if valMax < 2;valMax = 2;end
                ylim        = [0,valMax];
                ytick       = 0:0.5:valMax;
                ytitle      = 'Staircase value';
                title       = 'Staircase value';
            elseif tCol == 2
                plot_column = 13;
                ylim  = [0.5,1];        
                ytick  = 0.5:0.1:1;                 
                ytitle      = 'RG/BY ratio';
                title       = 'Physical change';
            elseif tCol == 3
                plot_column = 12;
                ylim        = [0,1];
                ytick       = 0:0.25:1;
                ytitle      = 'Performance %';
                title       = 'Accuracy';
            end
            yrange      = ylim(2)-ylim(1);
        elseif tRow == 2
            if tCol == 1
                plot_column = 2;
                ylim        = [-radMaxX,radMaxX];
                ytick       = linspace(ylim(1),ylim(2),7);
                ytitle      = 'Eye horizontal position (deg)';
                title       = 'Eye horizontal position';
            elseif tCol == 2
                plot_column = 3;
                ylim        = [-radMaxY,radMaxY];
                ytick       = linspace(ylim(1),ylim(2),7);
                ytitle      = 'Eye vertical position (deg)';
                title       = 'Eye vertical position';
            elseif tCol == 3
                xlim        = [-radMaxX,radMaxX];
                ylim        = [-radMaxY,radMaxY];
                xtick       = linspace(xlim(1),xlim(2),7);
                ytick       = linspace(ylim(1),ylim(2),7);
                xtitle      = 'Horizontal coordinate (deg)';
                ytitle      = 'Vertical coordinate (deg)';
                title       = 'Fixation heatmap';
            end
            yrange      = ylim(2)-ylim(1);
        end
        xrange      = xlim(2)-xlim(1);
        legSize     = 0.05*xrange;
        
        
        % plot back figures
        patch([xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(2),ylim(2)],beige,'linestyle','none');
        
        % plot data
        if tRow == 1
            for tPlot = 1:numPlot
                xPlot = resAll_color_bin{tPlot}(:,11);
                yPlot = resAll_color_bin{tPlot}(:,plot_column);
                
                plot(xPlot,yPlot,'LineWidth',2,'Color',resCol(tPlot,:));
            end
        elseif tRow == 2 && tCol ~= 3
            xPlot = eye_data_allblock(:,1);
            yPlot = eye_data_allblock(:,plot_column);
            plot(xPlot,yPlot,'LineWidth',1,'Color',resCol(1,:));
            
        elseif tRow == 2 && tCol == 3
            contourf(xHeatMap,yHeatMap,densityFix,5,'linestyle','none');
        end
        
        % plot white hiders
        patch([xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(1),ylim(1),ylim(1)-yrange*2,ylim(1)-yrange*2],white,'linestyle','none');
        patch([xlim(1),xlim(2),xlim(2),xlim(1)],[ylim(2),ylim(2),ylim(2)+yrange*2,ylim(2)+yrange*2],white,'linestyle','none');
        
        % plot legend
        for tPlot = 1:numPlot
            if tRow == 1
                % plot legend
                xPlotLeg = linspace(xrange*0.8-legSize,xrange*0.8,10);
                yPlotLeg = xPlotLeg*0+ylim(2)+(yrange*mergin*(5-tPlot));
                plot(xPlotLeg,yPlotLeg,'LineWidth',2,'Color',resCol(tPlot,:));
                text(xPlotLeg(end)+xrange*0.02,yPlotLeg(1),legTxt{tPlot},'Hor','left','Ver','Middle','Color',black,'FontSize',6)
            elseif tRow == 2 && tCol == 3
                xPlotAcc = xlim(2);
                yPlotAcc = ylim(2)+(yrange*mergin*(4));
                text(xPlotAcc+xrange*0.02,yPlotAcc,sprintf('Fixation accuracy = %1.2f deg',accuracyVal),'Hor','right','Ver','Middle')
                xPlotPre = xlim(2);
                yPlotPre = ylim(2)+(yrange*mergin*(2));
                text(xPlotPre+xrange*0.02,yPlotPre,sprintf('Fixation precision = %1.2f deg',precisionVal),'Hor','right','Ver','Middle')
            end
            
            
        end
        
        % plot block time
        if ~(tRow == 2 && tCol == 3)
            for tPlot = 1:numPlot
                xPlotTask = resTask(:,11);
                xPlotTask(resTask(:,5)~=valTask) = NaN;
                xPlotTask(resTask(:,6)~=tPlot-1) = NaN;
                yPlotTask = xPlotTask*0 + ylim(1)-(yrange*mergin);
                plot(xPlotTask,yPlotTask,'LineWidth',5,'Color',resCol(tPlot,:));
            end
        end
        
        % plot fixation position
        if tRow == 2
            if tCol == 1
                xFix = xlim(2)+(xrange*mergin);
                plot(xFix,(fixRight(1)-config.scr.x_mid)/config.const.pixel_per_degree,'<','MarkerFaceColor',black,'MarkerEdgeColor','none','MarkerSize',8);
                plot(xFix,(fixLeft(1)-config.scr.x_mid)/config.const.pixel_per_degree,'<','MarkerFaceColor',black,'MarkerEdgeColor','none','MarkerSize',8);
            elseif tCol == 2
                xFix = xlim(2)+(xrange*mergin);
                plot(xFix,-1*(fixRight(2)-config.scr.y_mid)/config.const.pixel_per_degree,'<','MarkerFaceColor',black,'MarkerEdgeColor','none','MarkerSize',8);
                plot(xFix,-1*(fixLeft(2)-config.scr.y_mid)/config.const.pixel_per_degree,'<','MarkerFaceColor',black,'MarkerEdgeColor','none','MarkerSize',8);
            else
                plot(linspace(xlim(1),xlim(2),30),linspace(xlim(1),xlim(2),30)*0+-1*(fixRight(2)-config.scr.y_mid)/config.const.pixel_per_degree,'Color',white,'LineWidth',1);
                plot(linspace(xlim(1),xlim(2),30),linspace(xlim(1),xlim(2),30)*0+-1*(fixLeft(2)-config.scr.y_mid)/config.const.pixel_per_degree,'Color',white,'LineWidth',1);
                
                plot(linspace(ylim(1),ylim(2),30)*0+(fixRight(1)-config.scr.x_mid)/config.const.pixel_per_degree,linspace(ylim(1),ylim(2),30),'Color',white,'LineWidth',1);
                plot(linspace(ylim(1),ylim(2),30)*0+(fixLeft(1)-config.scr.x_mid)/config.const.pixel_per_degree,linspace(ylim(1),ylim(2),30),'Color',white,'LineWidth',1);
            end
            
        end
        
        % plot colormap
        % colorbar
        if tRow == 2 && tCol == 3
            yPlotCB = linspace(ylim(1),ylim(2),10);
            xPlotCB = yPlotCB*0 + xlim(2)+(xrange*mergin*3);
            ytickCB = linspace(ylim(1),ylim(2),5);
            ytickValCB = linspace(0,1,5);
            xPlotCBTickTxt =  xlim(2)+(xrange*mergin*5);
            xPlotCBTitleTxt =  xlim(2)+(xrange*mergin*7);
            plot(xPlotCB,yPlotCB,'Color',black,'LineWidth',1);
            for tickCB = 1:size(ytickCB,2)
                xPlotCBTick = linspace(xlim(2)+(xrange*mergin*3),xlim(2)+(xrange*mergin*3)+(xrange*tickratio*xyscale),10);
                yPlotCBTick = xPlotCBTick*0+ytickCB(tickCB);
                plot(xPlotCBTick,yPlotCBTick,'Color',black,'LineWidth',1);
                text(xPlotCBTickTxt,yPlotCBTick(1),sprintf('%1.2g',ytickValCB(tickCB)),'Hor','center','Ver','Middle')    
            end
            text(xPlotCBTitleTxt,mean(yPlotCB),'Normalized density (%)','Hor','center','Ver','Middle','Rotation',90)
            
            xGridCB = [xlim(2)+(xrange*mergin),xlim(2)+(xrange*mergin*2)];
            yGridCB = linspace(ylim(1),ylim(2),100);
            [colorPosXCB,colorPosYCB,colorPosZCB] = meshgrid(xGridCB,yGridCB,0);
            m1 = surf(colorPosXCB,colorPosYCB,colorPosZCB,[linspace(ytickValCB(1),ytickValCB(end),100)',linspace(ytickValCB(1),ytickValCB(end),100)']);
            set(m1,'LineStyle','none','FaceColor','flat')
        end
        
        % plot xaxis/xaxis tick
        xPlotxAxis = linspace(xlim(1),xlim(2),30);
        yPlotxAxis = xPlotxAxis*0 + ylim(1)-(yrange*mergin*2);
        yPlotxAxisTickTxt =  ylim(1)-(yrange*mergin*4);
        yPlotxAxisTitleTxt =  ylim(1)-(yrange*mergin*6);
        plot(xPlotxAxis,yPlotxAxis,'Color',black,'LineWidth',1);
        for tickXaxis = 1:size(xtick,2)
            yPlotxAxisTick = linspace(ylim(1)-(yrange*mergin*2),ylim(1)-(yrange*mergin*2)-(yrange*tickratio),10);
            xPlotxAxisTick = yPlotxAxisTick*0+xtick(tickXaxis);
            plot(xPlotxAxisTick,yPlotxAxisTick,'Color',black,'LineWidth',1);
            text(xPlotxAxisTick(1),yPlotxAxisTickTxt,sprintf('%1.2g',xtick(tickXaxis)),'Hor','center','Ver','Middle')
        end
        text(mean(xPlotxAxis),yPlotxAxisTitleTxt,xtitle,'Hor','center','Ver','Middle')
        
        % plot yaxis/yaxis tick
        yPlotyAxis = linspace(ylim(1),ylim(2),30);
        xPlotyAxis = yPlotxAxis*0 + xlim(1)-(xrange*mergin);
        xPlotyAxisTickTxt =  xlim(1)-(xrange*mergin*3);
        xPlotyAxisTitleTxt =  xlim(1)-(xrange*mergin*5);
        plot(xPlotyAxis,yPlotyAxis,'Color',black,'LineWidth',1);
        for tickYaxis = 1:size(ytick,2)
            xPlotyAxisTick = linspace(xlim(1)-(xrange*mergin),xlim(1)-(xrange*mergin)-(xrange*tickratio*xyscale),10);
            yPlotyAxisTick = xPlotxAxisTick*0+ytick(tickYaxis);
            plot(xPlotyAxisTick,yPlotyAxisTick,'Color',black,'LineWidth',1);
            if tRow > 2 && tCol == 2
                text(xPlotyAxisTickTxt,yPlotyAxisTick(1),sprintf('%1.0f',ytick(tickYaxis)),'Hor','center','Ver','Middle')
            else
                text(xPlotyAxisTickTxt,yPlotyAxisTick(1),sprintf('%1.2g',ytick(tickYaxis)),'Hor','center','Ver','Middle')
            end
        end
        text(xPlotyAxisTitleTxt,mean(yPlotyAxis),ytitle,'Hor','center','Ver','Middle','Rotation',90)
        
        % plot title
        xPlotTitle =  xPlotxAxis(1);
        yPlotTitle =  ylim(2)+(yrange*mergin*3);
        text(xPlotTitle,yPlotTitle,title,'Hor','left','Ver','middle','Color',black,'FontWeight','bold')
        
        % plot block lines
        if ~(tRow == 2 && tCol == 3)
            yBlock = linspace(ylim(1),ylim(2),10);
            for tBlockLine = 1:numBlock
                xBlockStart = (tBlockLine-1)/numBlock;
                xBlockEnd   = tBlockLine/numBlock;
                xBlockTxt = (xBlockStart+xBlockEnd)/2;
                plot(yBlock*0+xBlockStart,yBlock,'Color',gray,'LineWidth',1);
                plot(yBlock*0+xBlockEnd,yBlock,'Color',gray,'LineWidth',1);
                text(xBlockTxt,ylim(1)+(yrange*mergin),sprintf('Block %i',tBlockLine),'Hor','center','Ver','Middle','Color',gray,'FontSize',8)
            end
        end
        
        % plot threshold
        if tCol == 3 && tRow == 1
            xStairTh = linspace(xlim(1),xlim(2),30);
            if config.const.staircaseType == 1
                yStairTh = xStairTh*0 + config.const.quest_pThreshold;
                threVal = config.const.quest_pThreshold;
            elseif config.const.staircaseType == 2
                yStairTh = xStairTh*0 + config.const.stair_pThreshold;
                threVal = config.const.stair_pThreshold;
            end
            plot(xStairTh,yStairTh,'-','Color',black,'LineWidth',1);
            
            text(xStairTh(end),yStairTh(1)-0.05,sprintf('Threshold = %1.2f   ',threVal),'Hor','right','Ver','Middle','Color',black,'FontSize',8)
        end

        % set figure 
        set(gca,'XLim',xlim+[-xrange*0.35,xrange*0.45],'YLim',ylim+[-yrange*0.4,yrange*0.4],'XTicklabel','','YTicklabel','','XColor',white,'YColor',white)
        
    end
end

% save figure
saveas(f,sprintf('data/%s/pRF_exp/%s_results.pdf',initials,initials))

end