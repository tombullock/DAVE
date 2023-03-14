function runextinction_repex3(sjNum,practice,session)
%===========================================
% Purpose: run extinction
% Inputs: subject number, practice
% Author: Mary, Anne
%===========================================
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','Verbosity',0);

eyetracker = 0; %are you eye tracking? 1 = yes
writeCodes = 0; %are you sending triggers for EEG? 1 = yes
dual = 0; %are you using a dual screen display set up? 1 = yes

black = [0 0 0];

% Open up a window on the screen(s).
thisScreen = max(Screen('Screens'));ctr = 0;
error_ctr = 0;
while error_ctr == ctr
    try
        [window,thisRect] = Screen('OpenWindow',thisScreen,black);
    catch
        error_ctr = error_ctr+1;
    end
    ctr = ctr+1;
end
if dual == 1
    otherScreen = min(Screen('Screens'));
    error_ctr = 0;
    while error_ctr == ctr
        try
            [window2,~] = Screen('OpenWindow',otherScreen,black);
        catch
            error_ctr = error_ctr+1;
        end
        ctr = ctr+1;
    end
else
    window2 = 0;
end
%===========================================
% PRACTICE
%===========================================
HideCursor;
ListenChar(2);
if practice==1 && session ==1
    practice = 1;                 % 1 = yes
    nBlocks = 1;                    % no of total blocks
    nTrials = 50;                    % no. of reps (trials) per block 
    extinction_repex3(sjNum,practice,session,nTrials,nBlocks,window,thisRect,window2,eyetracker,writeCodes,dual);
end

if practice==1 && session ==2
    practice = 1;                 % 1 = yes
    nBlocks = 1;                    % no of total blocks
    nTrials = 20;                    % no. of reps (trials) per block 
    extinction_repex3(sjNum,practice,session,nTrials,nBlocks,window,thisRect,window2,eyetracker,writeCodes,dual);
end

%===========================================
% MAIN EXPERIMENT - Training
%===========================================
if practice==0 && session==1
    nBlocks = 5;                    % no of total blocks
    nTrials = 80;                    % no. of reps (trials) per block
    extinction_repex3(sjNum,practice,session,nTrials,nBlocks,window,thisRect,window2,eyetracker,writeCodes,dual);
    ShowCursor;
end
    
%===========================================
% MAIN EXPERIMENT - Extinction
%===========================================
if practice==0 && session==2
    nBlocks = 20;                    % no of total blocks
    nTrials = 80;                    % no. of reps (trials) per block
    extinction_repex3(sjNum,practice,session,nTrials,nBlocks,window,thisRect,window2,eyetracker,writeCodes,dual);
    ShowCursor;
end
     
end
