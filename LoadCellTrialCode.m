%This file uses objects and functions:..
% - displayInfo.m - Used to store monitor settings and stimulus info and
% to control what is shown on the screen. - to change contrast levels, this
% can be edited
% - grey2lum.m
% - lum2grey.m  
% - A Gamma function
% - parameters.m - stores the trial and used infomration as well as the 
% force sensor resonses
% - loadCell.m - reads and calibrates the force sensor data
% - saveFiles.m - save the parameters, load cell caibration info and
% display info
% - screenInfo.m - Reads screen info, monitor width to be manually set in
% code
% - EMGtriggers.m - sends response to emg, using the parallel port, binary 
% 1s, and 0s

%% Intitial stuff
close all
clc
clear
sca
HideCursor

Screen('Preference', 'SkipSyncTests', 0); % This should be zero for main experiment
try

%% Start Stuff
resultsFolder = "Results"; % set folder address for results
vals = [];

p = parameters('right', resultsFolder); 
% Set up trial parameters - edit in parameters.m 
d = displayInfo(p); 
% Set up display information - edit contrast values in displayInfo.m 
loadCells = loadCell(par.left);
% Set up load cell object
emgInfo = EMGtriggers(hex2dec('4FF8'));
% Set up EMG triggers

triggerEMG(emgInfo, 0);
sendOnOffEMG(emgInfo);
% Test EMG triggers
showinfo(screenInfo(p.whichscreen))
% Used to record trial performance as strings 
frametimes = [];

%% Convert times to number of 4-frame cycles
fixTime = round((p.fixDur*p.videoFRate)/4);
BLtime = round(fixTime + (p.BLDur*p.videoFRate)/4);
cueTime = round(BLtime + (p.cueDur*p.videoFRate)/4);
evidenceTime = round(cueTime + (p.evDur*p.videoFRate)/4);
perturbTime = round(evidenceTime + (p.pertDur * p.videoFRate)/4);
validTime = round(p.validTrialDur * p.videoFRate/4);
totalTime = ceil(p.totalTrialDur * p.videoFRate/4);
holdtime = round(p.holdTime*p.videoFRate);
noHoldTime = floor(p.noHoldTime*p.videoFRate);


%% Get Load cells Calibration
loadCells = calibrateLC(loadCells, d, p);
% loadCells = setLCCVals(loadCells, [2, 2], [0 0]); %TESTING
FBstr = p.instructions;

%% Start Trial
for trialno = 1:p.runtrials % Cycle thorough each trial
    showEmpty(d);
    response = 0;
    responseReady = 0;
    hold0 = 0;
    hold1 = 0;
    hold2 = 0;
    holdBoth = 0;
    holdOver = 0;
    holdStart = 0;
    hitBottom = 0;
    % Reset hold values and values between trials
    triggerEMG(emgInfo, 0)
    while(1) 
        % Stop trial from starting until participant had removed force 
        % and held force at threshold value for enough time
        fReading = readCalForce(loadCells);
        vals = [vals; fReading];
        showGuides(d, fReading, 0);
        showText(d, FBstr, 160); 
        % Show guides and instructions / trial feedback

        if(fReading(1) < p.thresholds(1) && fReading(2) < p.thresholds(1)); hitBottom = 1; end
        if(hitBottom)
            if((fReading(loadCells.left) > p.thresholds(1) && fReading(loadCells.right) > p.thresholds(1)) && ...
                    (fReading(loadCells.left) < p.thresholds(2) && fReading(loadCells.right) < p.thresholds(2)))
                holdStart = holdStart + 1;
                if holdStart == holdtime
                    p = triggerLC("StartTrial", vals, p);
                    % triggerEMG(emgInfo, 1) % set emg to 1 for duration of the trial
                    break;
                end
            else
                holdStart = 0;
            end
        end
    end
    
    for frameNo = 1:totalTime %Cycle through each 4-frame cycle
        for framephase = 1:4 % cycle through each frame in a 4 frame cycle
            tic
            fReading = readCalForce(loadCells);
            vals = [vals; fReading];
            framephase = mod(framephase + p.firstTilt(trialno), 4);
            if(p.practice)
                showGuides(d, fReading, 0);
            end

            switch(true) % Switch stimulus based on trial phase
                case(frameNo <= fixTime) % Pre-trial fixation phase
                    showGuides(d, fReading, 1)
                case(frameNo <= BLtime) % baseline phase
                    showBLGrating(d, framephase);
                case(frameNo <= cueTime) % cue phase
                    showCueGrating(d, framephase);
                case(frameNo <= evidenceTime) % evidence onset phase
                    showEvGrating(d, framephase, p.cond(trialno), p.LR(trialno));
                    if responseReady == 0
                        responseReady = 1;
                        respstart = GetSecs();
                        p = triggerLC("EvidenceStart", vals, p); 
                        % Trigger loadCells and allow for resposnes to be recorded
                    end
                case(frameNo <= perturbTime) % show perturbation / switch phase
                    showPertGrating(d, framephase, p.cond(trialno), p.LR(trialno));
                case(frameNo < validTime) % return after perturbation 
                    showEvGrating(d, framephase, p.cond(trialno), abs(p.LR(trialno) - 3*(p.cond(trialno)==5))); % do a switched version for cond = 5
                case(frameNo < totalTime) % Record answer, but provide late feedback
                    showEvGrating(d, framephase, p.cond(trialno), abs(p.LR(trialno) - 3*(p.cond(trialno)==5))); % do a switched version for cond = 5
                    responseReady = 2;
                case(frameNo >= (totalTime)) % time out for trial
                    showEvGrating(d, framephase, p.cond(trialno), abs(p.LR(trialno) - 3*(p.cond(trialno)==5))); % End Trial
                    response = 4; % out of time
            end
%% check user response w/ holding pressure
            if responseReady 
                switch true % switch based on user response
                    case fReading(loadCells.left) > p.thresholds(4) || fReading(loadCells.right) > p.thresholds(4) 
                        % Participant put too much force
                        hold1 = 0;
                        hold2 = 0;
                        holdBoth = 0;
                        holdOver = holdOver + 1;
                        hold0 = 0;
                        if holdOver == holdtime
                            response = 6;
                            p = triggerLC("Overshot", vals, p);
                        end
                    case fReading(loadCells.left) > p.thresholds(3) && fReading(loadCells.right) > p.thresholds(3) ...
                            && fReading(loadCells.left) < p.thresholds(4) && fReading(loadCells.right) < p.thresholds(4) 
                        % Participant responded with both sides                        
                        hold1 = 0;
                        hold2 = 0;
                        holdBoth = holdBoth + 1;
                        holdOver = 0;
                        hold0 = 0;
                        if holdBoth == holdtime
                            response = 5;
                            p = triggerLC("ResponseGiven", vals, p);
                        end
                    case fReading(loadCells.left) > p.thresholds(3) && fReading(loadCells.left) < p.thresholds(4) 
                        % Participant selects left
                        holdStart = 0;
                        hold2 = 0;
                        hold1 = hold1+1;
                        holdBoth = 0;
                        holdOver = 0;
                        hold0 = 0;
                        if hold1 == holdtime
                            response = loadCells.left + (responseReady-1)*6 ;
                            % this gives 1/2 or 7/8 for the responses if in validation section
                            p = triggerLC("ResponseGiven", vals, p);
                        end
                    case fReading(loadCells.right) > p.thresholds(3) && fReading(loadCells.right) < p.thresholds(4) 
                        % Participant selects right
                        holdStart = 0;
                        hold1 = 0;
                        hold2 = hold2+1;
                        holdBoth = 0;
                        holdOver = 0;
                        hold0 = 0;
                        if hold2 == holdtime
                            response = loadCells.right + (responseReady-1)*6;
                            % this gives 1/2 or 7/8 for the responses if in validation section
                            p = triggerLC("ResponseGiven", vals, p);
                        end
                    case fReading(loadCells.left) < p.thresholds(1) || fReading(loadCells.right) < p.thresholds(1) 
                        % Participant releases pressure
                        hold1 = 0;
                        hold2 = 0;
                        holdBoth = 0;
                        holdOver = 0;
                        hold0 = hold0 + 1;
                        if hold0 == noHoldTime
                            response = 3;
                            p = triggerLC("Released", vals, p);
                        end
                end
            end

%% Response Categorisation   
            if response ~= 0 % record response time and find performance
                p.response(trialno) = response;
                respgiven = GetSecs();
                triggerEMG(emgInfo, 0); % set emg to 0 after response given
                showEmpty(d);

                FBstr = "Response recorded.";
% 1:Incorrect 2:Correct 3:Force Removed 4:Time Out 5:Both Answers 
% 6:Over Shot 7:Time Out-Incorrect 8:Time Out-Correct

                switch p.response(trialno)  
                    % Caculated performance and feedback based on response
                    case 1 
                        p.performance(trialno) = 1+(((p.response(trialno) == p.LR(trialno)))==  (p.cond(trialno)~=5));
                    case 2
                        p.performance(trialno) = 1+(((p.response(trialno) == p.LR(trialno)))==  (p.cond(trialno)~=5));
                    case 3
                        FBstr = "Lifted fingers off sensors!";
                        p.performance(trialno) = response;
                    case 4 
                        FBstr = "Timed out!";
                        p.performance(trialno) = response;
                    case 5
                        FBstr = "Too many answers given!";
                        p.performance(trialno) = response;
                    case 6
                        FBstr = "Too much force used!";
                        p.performance(trialno) = response;
                    case 7 
                        FBstr = "Timed out!";
                        p.performance(trialno) = 6+((response-6 == p.LR(trialno)) ~=  (p.cond(trialno)==5));
                    case 8
                        FBstr = "Timed out!";
                        p.performance(trialno) = 6+((response-6 == p.LR(trialno)) ~=  (p.cond(trialno)==5));
                end
                
                if(mod(trialno,p.FBInterval) == 0 ) % Provide accuracy of last FBInterval trials
                    FBstr = [FBstr, sprintf("Number of correct answers in last %d = %d",p.FBInterval, sum(p.performance(trialno-p.FBInterval+1: trialno) == 2))];
                end
                FBstr = [FBstr, "Please remove and reapply force."];

                frametimes = [frametimes, toc];
                p.responseTimes(trialno) = respgiven - respstart;
                break;
            end
            frametimes = [frametimes, toc];
        end 
        if response ~= 0 % if responded, move onto next trial
            if trialno == p.runtrials
                showText(d, FBstr, 160); 
                WaitSecs(2)
            end
            break
        end
    end
end
showText(d, sprintf("Overall correct answers %d/%d", sum(p.performance==2), p.runtrials), 0);
WaitSecs(5); % show overall performance
p.completed = 1;
p.forceVals = vals; % save files
saveFiles(p, d, loadCells)
% sendOnOffEMG(emgInfo);   
sca
ShowCursor;
% stopELRecording(elInfo);
 
%% Final Error stuff
catch
    sca
    ple
    ShowCursor;
    p.completed = 0;
    p.forceVals = vals; % save files
    saveFiles(p, d, loadCells)
    % stopELRecording(elInfo);
end
