function extinction_repex3(sjNum,practice,session,nTrials,nBlocks,window,thisRect,window2,eyetracker,writeCodes,dual)
%% Trial log
trialLog = struct(...
    'experiment','',...
    'subNum',{},...
    'grpNum',{},...
    'date','',...
    'trialInfo',struct('block',{},...
    'trial',{},...
    'rewardcondition',{},...
    'targetcolor', {},...
    'distractcolor',{},...
    'correctresp',{},...
    'response',{},...
    'accuracy',{},...
    'rt',{},...
    'totalreward',{},...
    'dist1_color',{},...
    'dist2_color',{},...
    'dist3_color', {},...
    'dist4_color',{},...
    'dist5_color',{},...
    'distreward_color',{},...
    'target_color',{},...
    'dist1_loc',{},...
    'dist2_loc',{},...
    'dist3_loc',{},...
    'dist4_loc',{},...
    'dist5_loc', {},...
    'distreward_loc',{},...
    'target_loc',{},...
    'targetShape',{},...
    'rewardprob',{}));

trialLog(1).subNum = sjNum;
trialLog(1).date = datestr(now);
trialLog(1).experiment = 'Extinction - Anderson Rep Take 3';


%% Set-Up
rng default
rng shuffle

group = [1:2:120; 2:2:120];
[R,~] = find(group==sjNum);
grpNum = R;

% get colors
white=[255 255 255];
black=[0 0 0];

% Get center points
centerX = thisRect(3)/2;
centerY = thisRect(4)/2;

% Set timing
if session == 1
    waittime = .8;
elseif session == 2
    waittime = 1;
end

% Stim sizing etc.
circlerad = visAngleToPixels(5,window); %distance of circles (center) to fixation (center), 5 degrees
stimsize = visAngleToPixels(2.3,window); %size of stim circles in pixels, 3 degrees
diamcor = visAngleToPixels(.40,window); %correction for diamond size .42
fixSize = visAngleToPixels(.25,window); %size of fixation point, .25 degrees
fixRect = [centerX-(fixSize/2) centerY-(fixSize/2) centerX+(fixSize/2) centerY+(fixSize/2)];
gazeSize = visAngleToPixels(1.5,window);

% Stim locations
loccenterX = round(centerX + circlerad * cosd(0:60:360))';%creates list of x coordinates for eight locations
loccenterY = round(centerY + circlerad * sind(0:60:360))';%creates list of y coordincates for eight locations

% Determine initial placeholder locations for search task
for i = 1:6
    LocationMatrix(i,:) = [loccenterX(i,1)-stimsize/2 loccenterY(i,1)-stimsize/2 loccenterX(i,1)+stimsize/2 loccenterY(i,1)+stimsize/2];
end

% Angles for stim
verticaltarget = [90 270];
horizontaltarget = [0 180];
lefttilt = [315 135];
righttilt = [45 225];

%Create stim 
colorlist = [22 128 109; 199 40 154; 140 111 78; 115 115 115; 169 60 203; 166 97 100; 186 93 16; 63 129 45; 146 111 16; 122 122 0];
blue = [17 103 241];
red = [233 0 0];

if grpNum == 1
    highColor = red;
    noColor = blue;
elseif grpNum == 2
    highColor = blue;
    noColor = red;
end

trialLog(1).grpNum = grpNum;
trialLog(1).highColor = highColor;
trialLog(1).noColor = noColor;
trialLog(1).disColors = colorlist;

%create trial matrix
if session == 1
    rewardcondition = repmat([1 2]',40,1); % 1 = reward 2 = no reward
    targettype = repmat([1 1 2 2 ]',20,1); % 1 = vertical 2 = horizontal
    trialSequence = [rewardcondition targettype];
end

if session == 2
    rewardcondition = repmat([1 2 3 3]',20,1); % 1 = reward 2 = no reward 3 = absent
    targettype = repmat([1 1 2 2 ]',20,1); % 1 = vertical 2 = horizontal
        if session == 2 && practice ==1
        rewardcondition = repmat([3 3]',40,1);
        end
    trialSequence = [rewardcondition targettype];
end


% Do port-related initialization for sending codes
if writeCodes == 1
    lj = labJack('verbose',true);
    lj.setDIO([0,0,0])
end

%% Eye tracking stuff
if eyetracker == 1
    EyelinkInit([], 1);
    edfFile = [num2str(sjNum) '_' 'RTR' '.edf']; % Name of eyetracking data file - has to be in the working directory unfortunately
    el=EyelinkInitDefaults(window);
    [~, vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    % Open file to record data to
    if(length(edfFile) > 12)
        sca
        error('EDF file name must conform to DOS 8.3 naming standard!')
    end
    i = Eyelink('Openfile', edfFile);
    if i~=0
        printf('Cannot create EDF file ''%s'' ', edfFile);
        Eyelink( 'Shutdown');
        return;
    end
    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox for Visual Search Experiment''');
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, thisRect(3)-1, thisRect(4)-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, thisRect(3)-1, thisRect(4)-1);
    % Set calibration type
    Eyelink('command', 'calibration_type = HV9');
    % Set EDF file contents
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS');
    % Set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');
    % Set eye to be tracked
    Eyelink('command', 'active_eye = RIGHT') % NORMALLY RIGHT
    % Make sure we're still connected
    if Eyelink('IsConnected')~=1
        return;
    end;
    % Setup the proper calibration foreground and background colors
    el.backgroundcolour = 127;
    el.foregroundcolour = 0;
    % Hide the mouse cursor
    Screen('HideCursorHelper', window);
    if dual == 1
        [normBoundsRect]=Screen('TextBounds',window2,'Calibrate eye tracker');
        Screen('DrawText',window2,'Calibrate eye tracker',centerX-round(normBoundsRect(3)/2),centerY,white, black);
        Screen('Flip',window2);
    end
    EyelinkDoTrackerSetup(el);
end

% Make screen black
Screen(window, 'FillRect', black);
 
% introduction screens for experiment, practice, main trials

if practice==0
    Screen('TextSize',window,40);
    [normBoundsRect]=Screen('TextBounds',window,'Please press space bar to begin...');
    Screen('DrawText',window,'Please press space bar to begin...',centerX-round(normBoundsRect(3)/2),centerY+150,white, black);
    [normBoundsRect]=Screen('TextBounds',window,'Main experiment!');
    Screen('DrawText',window,'Main experiment!',centerX-round(normBoundsRect(3)/2),centerY,white, black);
    Screen('Flip',window);
    
    KbWait([],2);
        
elseif practice==1
    Screen('TextSize',window,40);
    [normBoundsRect]=Screen('TextBounds',window,'Please press space bar to begin the practice...');
    Screen('DrawText',window,'Please press space bar to begin the practice...',centerX-round(normBoundsRect(3)/2),centerY+150,white, black);
    [normBoundsRect]=Screen('TextBounds',window,'Practice trials');
    Screen('DrawText',window,'Practice trials',centerX-round(normBoundsRect(3)/2),centerY,white, black);
    Screen('Flip',window);
    
    KbWait([],2);
end
% Start eyetracker recording
if eyetracker == 1
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);
    Eyelink('StartRecording', 1, 1, 1, 1);
    WaitSecs(0.1);
end
%% Block loop
thisBlock = 1;
while thisBlock <= nBlocks
    % shuffle trial sequence                                      % this part basically just cycles the following process seven times for randomisation purposes
        newOrder = randperm(size(trialSequence,1));     % newOrder = row vector with random perm of the total no. of factor combinations specified by trialSquence 
        trialSequence = trialSequence(newOrder,:);      % applies newOrder to trialSequence and spits out randomized trial sequence (column vector)


    trialcount = nTrials*(thisBlock-1);
    
    % block message 
    Screen('TextSize',window,40);
    blockMessage = sprintf('This is Block %d of %d blocks',thisBlock,nBlocks);
    [normBoundsRect]=Screen('TextBounds',window,blockMessage);
    Screen('DrawText',window,blockMessage,centerX-round(normBoundsRect(3)/2),centerY,white,black);
    [normBoundsRect]=Screen('TextBounds',window,'Press Space to Start the Block');
    Screen('DrawText',window,'Press Space to Start the Block',centerX-round(normBoundsRect(3)/2),centerY+150,white,black);
    Screen('Flip',window);
    
    KbWait([],2);
    
    fixbreaktotal = 0;
                
    for trial=1:nTrials
        
        % Draw fixation circle
        Screen ('FillOval',window, white,fixRect);
        Screen (window,'Flip');
        
        elSampleTime =[];
        pa = [];
        xyDrift = [];
        distXY = [];
        driftTotal = [];
        
        %Write a message to the experimenter's screen updating which trial
        %and block participants are completing
        
        if dual == 1
            trialMessage = sprintf('This is trial %d of %d ',trial,nTrials);
            [normBoundsRect]=Screen('TextBounds',window2,trialMessage);
            Screen('DrawText',window2,trialMessage,centerX-round(normBoundsRect(3)/2),centerY,white, black);
            blockMessage = sprintf('This is block %d of %d ',thisBlock,nBlocks);
            [normBoundsRect]=Screen('TextBounds',window2,blockMessage);
            Screen('DrawText',window2,blockMessage,centerX-round(normBoundsRect(3)/2),centerY+normBoundsRect(4)*2,white, black);
            Screen('Flip',window2);
        end
        
        %if practice == 0
        trialLog.trialInfo(trial+trialcount).block = thisBlock;
        trialLog.trialInfo(trial+trialcount).trial = trial+trialcount;
        %end
        
        thisTargetType = trialSequence(trial,2);
        thisRewardSize = trialSequence(trial,1);
        if thisRewardSize == 1
            probs = [1 1 1 1 0];
        else
            probs = [0 0 0 0 0];
        end
        thisRewardProb = probs(:,randi(5));
                                                 
        newOrder = randperm(size(colorlist,1));     
        colorlist = colorlist(newOrder,:); 

if session == 1
        if  thisRewardSize==1 
            color1 = colorlist(1,:);
            color2 = colorlist(2,:);
            color3 = colorlist(3,:);
            color4 = highColor;
            color5 = colorlist(5,:);
            color6 = colorlist(6,:);
            rewardcond = 1; 
            targetColor = color4;
        elseif  thisRewardSize==2
            color1 = colorlist(1,:);
            color2 = colorlist(2,:);
            color3 = colorlist(3,:);
            color4 = noColor;
            color5 = colorlist(5,:);
            color6 = colorlist(6,:);
            rewardcond = 2;
            targetColor = color4; 
        end 
end

if session == 2
        if  thisRewardSize==1 
            color1 = colorlist(1,:);
            color2 = colorlist(2,:);
            color3 = colorlist(3,:);
            color4 = colorlist(4,:);
            color5 = colorlist(5,:);
            color6 = highColor;
            rewardcond = 1;
            targetColor = color4;
            distractColor = color6;
        elseif  thisRewardSize==2
            color1 = colorlist(1,:);
            color2 = colorlist(2,:);
            color3 = colorlist(3,:);
            color4 = colorlist(4,:);
            color5 = colorlist(5,:);
            color6 = noColor;
            rewardcond = 2;
            targetColor = color4;
            distractColor = color6;
        elseif thisRewardSize==3
            color1 = colorlist(1,:);
            color2 = colorlist(2,:);
            color3 = colorlist(3,:);
            color4 = colorlist(4,:);
            color5 = colorlist(5,:);
            color6 = colorlist(6,:);
            rewardcond = 3;
            targetColor = color4;
            distractColor = color6;
        end
end

        newOrder = randperm(size(LocationMatrix,1)); 
        LocationMatrix = LocationMatrix(newOrder,:);     
        
        
        if thisTargetType == 1
            targetLoc = [(LocationMatrix(4,1)+stimsize/2)+(stimsize/2-4)*cosd(verticaltarget(1,1)) (LocationMatrix(4,2)+stimsize/2)+(stimsize/2-4)*sind(verticaltarget(1,1));...
                (LocationMatrix(4,1)+stimsize/2)+(stimsize/2-4)*cosd(verticaltarget(1,2)) (LocationMatrix(4,2)+stimsize/2)+(stimsize/2-4)*sind(verticaltarget(1,2))]';
            cResp =1;
        else
            targetLoc = [(LocationMatrix(4,1)+stimsize/2)+(stimsize/2-4)*cosd(horizontaltarget(1,1)) (LocationMatrix(4,2)+stimsize/2)+(stimsize/2-4)*sind(horizontaltarget(1,1));...
                (LocationMatrix(4,1)+stimsize/2)+(stimsize/2-4)*cosd(horizontaltarget(1,2)) (LocationMatrix(4,2)+stimsize/2)+(stimsize/2-4)*sind(horizontaltarget(1,2))]';
            cResp =2;
        end
        
        distracters = randi([1 2]);
        if distracters == 1 %three right two left
            distLoc1 = [(LocationMatrix(1,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,1)) ...
                (LocationMatrix(1,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,1));...
                (LocationMatrix(1,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,2))...
                (LocationMatrix(1,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,2))]';
            distLoc2 = [(LocationMatrix(2,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,1)) ...
                (LocationMatrix(2,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,1));...
                (LocationMatrix(2,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,2))...
                (LocationMatrix(2,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,2))]';
            distLoc3 = [(LocationMatrix(3,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,1)) ...
                (LocationMatrix(3,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,1));...
                (LocationMatrix(3,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,2))...
                (LocationMatrix(3,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,2))]';
            distLoc4 = [(LocationMatrix(5,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,1)) ...
                (LocationMatrix(5,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,1));...
                (LocationMatrix(5,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,2))...
                (LocationMatrix(5,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,2))]';
            distLoc5 = [(LocationMatrix(6,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,1)) ...
                (LocationMatrix(6,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,1));...
                (LocationMatrix(6,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,2))...
                (LocationMatrix(6,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,2))]';
        else %two right three left
            distLoc1 = [(LocationMatrix(1,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,1)) ...
                (LocationMatrix(1,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,1));...
                (LocationMatrix(1,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,2))...
                (LocationMatrix(1,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,2))]';
            distLoc2 = [(LocationMatrix(2,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,1)) ...
                (LocationMatrix(2,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,1));...
                (LocationMatrix(2,1)+stimsize/2)+(stimsize/2-4)*cosd(righttilt(1,2))...
                (LocationMatrix(2,2)+stimsize/2)+(stimsize/2-4)*sind(righttilt(1,2))]';
            distLoc3 = [(LocationMatrix(3,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,1)) ...
                (LocationMatrix(3,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,1));...
                (LocationMatrix(3,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,2))...
                (LocationMatrix(3,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,2))]';
            distLoc4 = [(LocationMatrix(5,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,1)) ...
                (LocationMatrix(5,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,1));...
                (LocationMatrix(5,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,2))...
                (LocationMatrix(5,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,2))]';
            distLoc5 = [(LocationMatrix(6,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,1)) ...
                (LocationMatrix(6,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,1));...
                (LocationMatrix(6,1)+stimsize/2)+(stimsize/2-4)*cosd(lefttilt(1,2))...
                (LocationMatrix(6,2)+stimsize/2)+(stimsize/2-4)*sind(lefttilt(1,2))]';
        end
        
        %Draw line segments
        Screen('DrawLines',window,targetLoc,2);
        Screen('DrawLines',window,distLoc1,3);
        Screen('DrawLines',window,distLoc2,3);
        Screen('DrawLines',window,distLoc3,3);
        Screen('DrawLines',window,distLoc4,3);
        Screen('DrawLines',window,distLoc5,3);
        
        diamonds = randi([1 2]);
        if session ==2 
            if diamonds == 1 %diamond among circles 
                %diamond coordinates
                xCoord = [LocationMatrix(4,1) + (stimsize/2), LocationMatrix(4,1) - diamcor, LocationMatrix(4,1) + (stimsize/2), LocationMatrix(4,1) + stimsize + diamcor]';
                yCoord = [LocationMatrix(4,2) + stimsize + diamcor, LocationMatrix(4,2) + (stimsize/2), LocationMatrix(4,2)- diamcor, LocationMatrix(4,2) + (stimsize/2)]';
                polyCoords = [xCoord yCoord];
        
                %Draw colored ovals
                Screen('FrameOval',window, color1, LocationMatrix(1,1:4),4); 
                Screen('FrameOval',window, color2, LocationMatrix(2,1:4),4); 
                Screen('FrameOval',window, color3, LocationMatrix(3,1:4),4);
                Screen('FramePoly',window, color4, polyCoords,4); %target 
                Screen('FrameOval',window, color5, LocationMatrix(5,1:4),4); 
                Screen('FrameOval',window, color6, LocationMatrix(6,1:4),4); %crit distracter
                shape = 1; %diamond
            else %circle among diamonds
                xCoord = [LocationMatrix(1,1) + (stimsize/2), LocationMatrix(1,1) - diamcor, LocationMatrix(1,1) + (stimsize/2), LocationMatrix(1,1) + stimsize + diamcor]';
                yCoord = [LocationMatrix(1,2) + stimsize + diamcor, LocationMatrix(1,2) + (stimsize/2), LocationMatrix(1,2)- diamcor, LocationMatrix(1,2) + (stimsize/2)]';
                polyCoords1 = [xCoord yCoord];
                
                xCoord = [LocationMatrix(2,1) + (stimsize/2), LocationMatrix(2,1) - diamcor, LocationMatrix(2,1) + (stimsize/2), LocationMatrix(2,1) + stimsize + diamcor]';
                yCoord = [LocationMatrix(2,2) + stimsize + diamcor, LocationMatrix(2,2) + (stimsize/2), LocationMatrix(2,2)- diamcor, LocationMatrix(2,2) + (stimsize/2)]';
                polyCoords2 = [xCoord yCoord];
                
                xCoord = [LocationMatrix(3,1) + (stimsize/2), LocationMatrix(3,1) - diamcor, LocationMatrix(3,1) + (stimsize/2), LocationMatrix(3,1) + stimsize + diamcor]';
                yCoord = [LocationMatrix(3,2) + stimsize + diamcor, LocationMatrix(3,2) + (stimsize/2), LocationMatrix(3,2)- diamcor, LocationMatrix(3,2) + (stimsize/2)]';
                polyCoords3 = [xCoord yCoord];
                
                xCoord = [LocationMatrix(5,1) + (stimsize/2), LocationMatrix(5,1) - diamcor, LocationMatrix(5,1) + (stimsize/2), LocationMatrix(5,1) + stimsize + diamcor]';
                yCoord = [LocationMatrix(5,2) + stimsize + diamcor, LocationMatrix(5,2) + (stimsize/2), LocationMatrix(5,2)- diamcor, LocationMatrix(5,2) + (stimsize/2)]';
                polyCoords5 = [xCoord yCoord];
                
                xCoord = [LocationMatrix(6,1) + (stimsize/2), LocationMatrix(6,1) - diamcor, LocationMatrix(6,1) + (stimsize/2), LocationMatrix(6,1) + stimsize + diamcor]';
                yCoord = [LocationMatrix(6,2) + stimsize + diamcor, LocationMatrix(6,2) + (stimsize/2), LocationMatrix(6,2)- diamcor, LocationMatrix(6,2) + (stimsize/2)]';
                polyCoords6 = [xCoord yCoord];
                shape = 2; %circle
        %Draw colored ovals
            Screen('FramePoly',window, color1, polyCoords1,4); 
            Screen('FramePoly',window, color2, polyCoords2,4); 
            Screen('FramePoly',window, color3, polyCoords3,4);
            Screen('FrameOval',window, color4, LocationMatrix(4,1:4),4); %target 
            Screen('FramePoly',window, color5, polyCoords5,4); 
            Screen('FramePoly',window, color6, polyCoords6,4); %crit distracter
            end
        end
        
        if session == 1
            %Draw colored ovals
            Screen('FrameOval',window, color1, LocationMatrix(1,1:4),4); 
            Screen('FrameOval',window, color2, LocationMatrix(2,1:4),4); 
            Screen('FrameOval',window, color3, LocationMatrix(3,1:4),4);
            Screen('FrameOval',window, color4, LocationMatrix(4,1:4),4); %target 
            Screen('FrameOval',window, color5, LocationMatrix(5,1:4),4); 
            Screen('FrameOval',window, color6, LocationMatrix(6,1:4),4); %crit distracter
        end 
        

        % Draw fixation circle
        Screen ('FillOval',window, white,fixRect);
        
        WaitSecs (randi([5 8])*.1);    
        
        [Timing] = Screen(window, 'Flip');    % starts recording RT from moment of search display screen flip
        
        if writeCodes == 1
            sendTrigger(lj,thisRewardSize);
        end
        
        kc_z = KbName('z');
        kc_m = KbName('m');
        
        thisCheck=1;
        while 1
            [~, secs, keycodes] = KbCheck();
            % Check that pressed keycodes and the desired codes overlap
            % If so, then exit loop
            if keycodes(kc_z)
                break
            elseif keycodes(kc_m)
                break
            elseif GetSecs()-Timing > waittime
                break
            end
            WaitSecs(.002);
            if eyetracker == 1
            [fixbreak,fixbreaktotal,elSampleTime,pa,xyDrift,distXY,driftTotal,thisCheck] = eyetracking(eyetracker,thisCheck,gazeSize,writeCodes,practice,centerX,centerY,fixbreaktotal,window2,lj,window,black,white,elSampleTime,pa,xyDrift,distXY,driftTotal);
            end
         end   
         
        if size(find(keycodes),2) ==1          % these additional commands prevent matlab crashing if ps press x and n simultaneously
            if KbName(keycodes)=='z'
                resp=1;
            elseif KbName(keycodes)=='m'
                resp=2;
            end
        elseif size(find(keycodes),2) > 1
            resp=3;
        elseif size (find(keycodes),2) < 1
            resp=4;
        end

        reactionTime = (secs - Timing)*1000;

        if resp==cResp
            Acc = 1;
        else Acc = 0;
        end;
       
            
        %%calculate running total
        if practice==0 && session==1
            if thisBlock==1 && trial==1
                balance=0;
                total=0;
            end;
            if Acc==1 && rewardcond==1 && thisRewardProb ==1
                total=balance+.05;
                balance=balance+.05;
                dispTotal=num2str(total);
            else
                total=balance;
                dispTotal=num2str(total);
            end
        end
         
        if practice == 0 && session==1
        trialLog.trialInfo(trial+trialcount).rewardcondition = rewardcond;
        trialLog.trialInfo(trial+trialcount).targettype = thisTargetType;
        trialLog.trialInfo(trial+trialcount).correctresp = cResp;
        trialLog.trialInfo(trial+trialcount).response = resp;
        trialLog.trialInfo(trial+trialcount).accuracy = Acc;
        trialLog.trialInfo(trial+trialcount).rt = reactionTime;
        trialLog.trialInfo(trial+trialcount).totalreward = total;
        trialLog.trialInfo(trial+trialcount).rewardprob = thisRewardProb;
        trialLog.trialInfo(trial+trialcount).dist1_color = color1;
        trialLog.trialInfo(trial+trialcount).dist2_color = color2;
        trialLog.trialInfo(trial+trialcount).dist3_color = color3;
        trialLog.trialInfo(trial+trialcount).dist4_color = color5;
        trialLog.trialInfo(trial+trialcount).dist5_color = color6;
        trialLog.trialInfo(trial+trialcount).target_color = targetColor;
        trialLog.trialInfo(trial+trialcount).dist1_loc = distLoc1;
        trialLog.trialInfo(trial+trialcount).dist2_loc = distLoc2;
        trialLog.trialInfo(trial+trialcount).dist3_loc = distLoc3;
        trialLog.trialInfo(trial+trialcount).dist4_loc = distLoc4;
        trialLog.trialInfo(trial+trialcount).dist5_loc = distLoc5;
        trialLog.trialInfo(trial+trialcount).target_loc = targetLoc;
        end
        
        if practice == 0 && session==2
        trialLog.trialInfo(trial+trialcount).rewardcondition = rewardcond;
        trialLog.trialInfo(trial+trialcount).targettype = thisTargetType;
        trialLog.trialInfo(trial+trialcount).correctresp = cResp;
        trialLog.trialInfo(trial+trialcount).response = resp;
        trialLog.trialInfo(trial+trialcount).accuracy = Acc;
        trialLog.trialInfo(trial+trialcount).rt = reactionTime;
        trialLog.trialInfo(trial+trialcount).rewardprob = thisRewardProb;
        trialLog.trialInfo(trial+trialcount).dist1_color = color1;
        trialLog.trialInfo(trial+trialcount).dist2_color = color2;
        trialLog.trialInfo(trial+trialcount).dist3_color = color3;
        trialLog.trialInfo(trial+trialcount).dist4_color = color5;
        trialLog.trialInfo(trial+trialcount).distreward_color = distractColor;
        trialLog.trialInfo(trial+trialcount).target_color = targetColor;
        trialLog.trialInfo(trial+trialcount).dist1_loc = distLoc1;
        trialLog.trialInfo(trial+trialcount).dist2_loc = distLoc2;
        trialLog.trialInfo(trial+trialcount).dist3_loc = distLoc3;
        trialLog.trialInfo(trial+trialcount).dist4_loc = distLoc4;
        trialLog.trialInfo(trial+trialcount).distreward_loc = distLoc5;
        trialLog.trialInfo(trial+trialcount).target_loc = targetLoc;
        trialLog.trialInfo(trial+trialcount).targetShape = shape;
        end
        
        if practice == 1
        trialLog.trialInfo(trial+trialcount).response = resp;
        trialLog.trialInfo(trial+trialcount).accuracy = Acc;
        trialLog.trialInfo(trial+trialcount).rt = reactionTime;
        end
        
        if practice == 0 && eyetracker == 1
        trialLog.trialInfo(trial+trialcount).fixbreak = fixbreak;
        trialLog.trialInfo(trial+trialcount).fixbreaktotal = fixbreaktotal;
        trialLog.trialInfo(trial+trialcount).elSampleTime = elSampleTime;
        trialLog.trialInfo(trial+trialcount).pa = pa;
        trialLog.trialInfo(trial+trialcount).xyDrift = xyDrift;
        trialLog.trialInfo(trial+trialcount).distXY = distXY;
        trialLog.trialInfo(trial+trialcount).driftTotal = driftTotal;
        end

        % Write to file
        if practice == 0 && session ==1
            save(sprintf('s%02d_RewardTraining_repex3', sjNum),'trialLog');
        elseif practice == 0 && session ==2
            save(sprintf('s%02d_RewardExtinction_repex3', sjNum), 'trialLog');
        end 
        
        % feedback displays
        
        if practice==0 && session==1
            dispTotal = sprintf('Total $%s',dispTotal);
            if Acc==1 && rewardcond == 1 && thisRewardProb == 1
                Screen('TextSize',window,40);
                [normBoundsRect]=Screen('TextBounds',window,'+$.05');
                width = normBoundsRect(3);
                Screen('DrawText',window,'+$.05', centerX-round(width/2),centerY-30, white,black);
                [normBoundsRect] = Screen('TextBounds', window,dispTotal);
                width = normBoundsRect(3);
                Screen('DrawText',window,dispTotal,centerX-round(width/2),centerY+30, white,black);
                Screen(window, 'Flip');
                WaitSecs(1.5);
            else
                Screen('TextSize',window,40);
%                 [normBoundsRect]=Screen('TextBounds',window,'No reward');
                [normBoundsRect]=Screen('TextBounds',window,'$+$.00');
                width = normBoundsRect(3);
                Screen('DrawText',window,'+$.00', centerX-round(width/2),centerY-30, white,black);
                [normBoundsRect] = Screen('TextBounds', window,dispTotal);
                width = normBoundsRect(3);
                Screen('DrawText',window,dispTotal,centerX-round(width/2),centerY+30, white,black);
                Screen(window, 'Flip');
                WaitSecs(1.5);
            end
        else
            Screen(window,'Flip');
            WaitSecs(1.5);
        end      
       
        % after exiting the trial loop for the first loop start the next block if appropriate
    end
    
thisBlock = thisBlock+1;
if practice ==0 && session==1
    balance = total;
end

end   
if eyetracker == 1
    Screen('TextSize',window,32);
    [normBoundsRect]=Screen('TextBounds',window,'TRANSFERRING EYE DATA.');
    Screen('DrawText',window,'TRANSFERRING EYE DATA.',centerX-round(normBoundsRect(3)/2),centerY,[255 255 255]);
    Screen('Flip', window);
    Eyelink('Stoprecording')
    WaitSecs(0.5);
    Eyelink('CloseFile');
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end
    Eyelink('ShutDown');
end       
% reactivates keyboard for use in matlab windows
if practice == 0 && session==1
    fprintf('%s', dispTotal);
    Screen closeall
elseif practice == 0 && session==2
    Screen closeall
    return
elseif practice == 1 && session==1
    accuracy = [trialLog.trialInfo.accuracy];
    overallAcc = mean(accuracy);
    overallAcc = overallAcc*100;
    fprintf('%d', overallAcc);
    Screen closeall 
    return
elseif practice == 1 && session==2
    accuracy = [trialLog.trialInfo.accuracy];
    overallAcc = mean(accuracy);
    overallAcc = overallAcc*100;
    fprintf('%d', overallAcc);
    Screen closeall
    return
end
end

%% Sub-functions
%send labjack triggers and eyetracker messages
function sendTrigger(lj,stim)
    lj.setDIO([0,stim,0]) % set FIO EIO and CIO channel 0 and 3 high
    pause(.005);
    lj.setDIO([0,0,0]) % set FIO EIO and CIO channel 0 and 3 high
    Eyelink('Message', ['TRIGGER ' sprintf('%d',stim)]); %sent stim to ET   
end
% Function to convert from visual angle to pixels
function [pixels] = visAngleToPixels(visAngle,window)
    d = 110; %viewing distance in cm

    h = 27; %monitor height in cm
    w = 36; %monitor width in cm

    [widthpix, heightpix] = Screen('WindowSize', window); %in pixels
    rh = heightpix; %vertical resolution of monitor
    rw = widthpix; %horizontal resolution of monitor

    pixelsPerDeg = 1/(2*atand(1/(2*d)))*((((rw/w)+(rh/h))/2)); %calculates number of pixels in 1 degree of visual angle

    pixels = pixelsPerDeg*visAngle;
end
%eye tracking
function [fixbreak,fixbreaktotal,elSampleTime,pa,xyDrift,distXY,driftTotal,thisCheck] = eyetracking(eyetracker,thisCheck,gazeSize,writeCodes,~,centerX,centerY,fixbreaktotal,~,lj,~,~,~,elSampleTime,pa,xyDrift,distXY,driftTotal)
    if eyetracker == 1
        evt=Eyelink('NewestFloatSample');   % get sample
        x=evt.gx(2);    % x-position
        y=evt.gy(2);    % y-position
        [~,r] = cart2pol(x-centerX,y-centerY);
        if r > gazeSize || x == 0 && y == 0
            fixbreak = 1;
            fixbreaktotal = fixbreaktotal+1;
        else
            fixbreak = 0;
        end
        elSampleTime(thisCheck,:) = evt.time;  % gets sample times
        pa(thisCheck,:)=evt.pa; % gets pupil areas
        xyDrift(thisCheck,:)=[evt.gx(2) evt.gy(2)];
        distXY(thisCheck,:)=[centerX-evt.gx(2) centerY-evt.gy(2)];
        driftTotal(thisCheck,:)=r-gazeSize;
        thisCheck = thisCheck+1;
    else
        elSampleTime(thisCheck,:) = 0;  % gets sample times
        pa(thisCheck,:)=0; % gets pupil areas
        xyDrift(thisCheck,:)=[0 0];
        distXY(thisCheck,:)=[0 0];
        driftTotal(thisCheck,:)=0;
        fixbreak = 0;
        fixbreaktotal = 0;
        thisCheck = thisCheck+1;
    end
end
