
%% Intitial stuff
close all
clc
clear
sca


Screen('Preference', 'SkipSyncTests', 1); % This should be zero for main experiment

%% Start Stuff
resultsFolder = "Results"; % set folder address for results
vals = [];
p = parameters('right', resultsFolder); % set to screen to run programme on
loadCells.right = 1;
loadCells.left = 2;
d = displayInfo(p, loadCells); % set this to screen's gamma function

showinfo(screenInfo(p.whichscreen))
% Used to record trial performance as strings 
frametimes = [];

%% Convert times to numer of 4-frame cycles
fixTime = 20;
BLtime = 20;
cueTime = 4;
evidenceTime = 100;
perturbTime = 500;
validTime = round(p.validTrialDur * p.videoFRate/4);
totalTime = 1000;
holdtime = round(p.holdTime*p.videoFRate);
noHoldTime = floor(p.noHoldTime*p.videoFRate);

for trialno = 1:p.runtrials % Cycle thorough each trial
    
    for frameNo = 1:totalTime %Cycle through each 4-frame cycle
        for framephase = 1:4 % cycle through each frame in a 4 frame cycle
            switch(true) % Switch stimulus based on trial phase
                
                case(frameNo <= evidenceTime) % evidence onset phase
                    showEvGrating(d, framephase, p.cond(trialno), p.LR(trialno));
                    
                case(frameNo <= perturbTime) % show perturbation / switch phase
                    showPertGrating(d, framephase, p.cond(trialno), p.LR(trialno));
                case(frameNo < totalTime) % Record answer, but provide late feedback
                    showEvGrating(d, framephase, p.cond(trialno), abs(p.LR(trialno) - 3*(p.cond(trialno)==5))); % do a switched version for cond = 5
                    
                case(frameNo >= (totalTime)) % time out for trial
                    showEvGrating(d, framephase, p.cond(trialno), abs(p.LR(trialno) - 3*(p.cond(trialno)==5))); % End Trial
                    response = 4; % out of time
            end
        end
    end
end