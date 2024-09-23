% parameters - Object for experiment parameters for Decision Making Trials.
% This class provides functionalities to set up experimental data and store it for use in result analysis.
%
% This class is used to initialise, and access parameters needed for
% decision-making trials in experimental setups. It ensures all parameters are
% consistently managed and can be easily retrieved for analysis purposes.
%
% Properties:
%   pID - Participant ID
%   forceVals - Recorded force values during the trials
%   response - Participant responses during the trials
%   performance - Performance metrics of the participant
%   responseTimes - Times taken by participants to respond
%   practice - Indicates if the trial is a practice trial and specifies
%   which condition type is being practiced
%   runtrials - Number of trials to be run in the session
%   fixDur - Duration of fixation period in each trial
%   evDur - Duration of the evidence period in each trial 
%   pertDur - Duration of perturbation in each trial 
%   BLDur - Baseline duration before the start of each trial 
%   cueDur - Duration of the cue period in each trial 
%   totalTrialDur - Total duration of each trial 
%   validTrialDur - Valid duration of each trial for analysis
%   FBInterval - Number of trials after which to provide feedback 
%   noHoldTime - No-hold time parameter 
%   holdTime - Time participants need to hold a response 
%   thresholds - Threshold values for the user force response
%   viewingdist - Viewing distance in centimeters 
%   numconds - Number of experimental conditions 
%   practiceTrialsNo - Number of practice trials
%   numtrials - Total number of trials
%   blockNo - The current block number
%   cond - Experimental conditions
%   LR - Left/right indicator for responses or conditions
%   firstTilt - Initial tilt value for trials involving orientation
%   videoFRate - Frame rate of the video display
%   monitorWcm - Width of the monitor in centimeters
%   whichscreen - Indicates which screen is being used
%   instructions - Instructions given to participants
%   sessionNo - Session number for the current set of trials
%   lcTriggers - Event triggers used during the trials for the Load Cell
%   resultsFolder - Folder where results are stored
%   fileName - Name of the file to store results
%   boothName - Name of the experimental booth
%   gammaFunct - Gamma function for monitor calibration
%   rseed - Random seed for reproducibility
%
% Methods:
%   parameters(boothName, resultsFolder) - Constructor method to initialise 
%   the parameters object, using a string value for booth name and results 
%   folder that determine screen information and file save location.
%   readUser(par) - Collect user-specific trial data such as identifier, 
%   sessionnumber and whether it is a practice block, automatically called in 
%   constructor.
%   triggerLC(par) - Method to record a trigger for the load cell sample 
%   that an event has occurred, stores the loadCell sample and trigger 
%   string in array called lcTriggers.
%
% Example:
%   p = parameters('right', resultsFolder);
%   p = triggerLC("StartTrial", vals, p);
%
% Author: Oisín Hogan
% Date: 2024-07-05

classdef parameters
    properties
        pID                 % Participant Id 
        sessionNo           % Current session number 
        blockNo             % Current block number 
        completed           % Boolean on whether block was fully completed
        forceVals           % Array of recorded force values
        response            % Array of user response for each trial
        performance         % Array of user performance for each trial
        responseTimes       % Array of user response time for each trial
        practice            % Indicator of whether block is practice trials
                            % or actual trials
        runtrials           % Number of trials that are run in block
        fixDur              = 0.1   % Duration of fixation stage (s)
        evDur               = 1     % Duration of evidence stage (s)
        pertDur             = 1     % Duration of perturbation stage (s)
        BLDur               = 1     % Duration of baseline stage (s)
        cueDur              = 1     % Duration of cue stage (s)
        totalTrialDur       = 10    % Duration of total trial
        validTrialDur       = 3     % Duration of valid section of trial
        FBInterval          = 10    % Number of trials between feedback given
        noHoldTime          = 0.1   % Amount of time for a response of 
                                    % force being removed to be recorded
        holdTime            = 0.4   % Time participants need to hold to log 
                                    % a response
        thresholds          = [0.2, 0.4, 0.8, 1.2] %Force threshold levels
        viewingDist         = 57    % Viewing distance from screen
        numConds            = 5     % Number of trial conditions
        numTrialsPractice   = 5    % Number of trials in practice block
        numTrialsActual           % Number of trials in actual block
        left                =1  % Reference for the left channel of load 
                                % cells, grating directions and responses
        right               % Reference for the right channel of load cells,
                            % grating direction and responses
        cond                % Array of conditions for each trial
        LR                  % Array of the initially brighter contrast  
                            % direction for each trial 
        firstTilt           % Array of the first tilt direction for each 
                            % trial
        videoFRate          % Monitor frame rate
        monitorWcm          % Monitor width
        whichscreen         % Screen to display infromation on 
        instructions        % Instructions to participant
        lcTriggers          % Array of triggers and corresponding load cell 
                            % samples
        resultsFolder       % Folder to save results in 
        fileName            % File name to save results as 
        boothName           % Booth where experiment is being conducted: 
                            % left or right   
        gammaFunct          % Screen gamma function
        rseed               % Random seed for experiment
    end
    methods     
        function par = parameters(boothName, resultsFolder)
            % parameters - Constructor method to initialise the parameters object.
            % Initialises the parameters object with default values and sets up
            % experimental parameters based on the provided booth name 
            % ('left' or 'right'), results folder and the default values 
            % determined in properties.
            
            % Measurement and Equipment Used
            par.boothName = boothName;

            % Default values in popup
            par.pID = ''; 
            par.sessionNo = 1;
            par.practice = 0;
            par.right = 3-par.left;
  
            par.rseed = sum(100*clock);
            par.resultsFolder = resultsFolder;
                 
            par.numTrialsActual = par.numConds*12;

            switch par.boothName
                case 'left'
                    par.monitorWcm = 54.3;
                    par.gammaFunct = 'gammafn_UCDnew_3par.mat';
                    par.whichscreen = 0;
                case 'right'
                    par.monitorWcm = 60;
                    par.gammaFunct = 'gammafn_UCDRight_3par.mat';
                    par.whichscreen = 0;
                case 'test'
                    par.monitorWcm = 35;
                    par.gammaFunct = 'gammafn_UCDRight_3par.mat';
                    par.whichscreen = 1;
            end
            par.videoFRate = screenInfo(par.whichscreen).refreshrate;  % Gaming monitor
            par.instructions = ["Fixate on the central dot",...
                " ",...
                "You will see two stripy patterns mixed together.",...
                "When you see which pattern is stronger immediately activate", ...
                "LEFT finger if you saw that the LEFT-tilted pattern was stronger",...
                "Activate the RIGHT finger if you saw that the"...
                "RIGHT-tilted pattern was stronger",...
                " ",...
                " ",...
                " ",...
                " ",...
                "To Begin, move pointers to the Yellow region"...
                " ", ...
                " "];
            % randomise trial conditons

            par.cond = repmat(1:par.numConds,[1,par.numTrialsActual/par.numConds]);    
            par.LR = repmat([ones(1,par.numConds) 2*ones(1,par.numConds)],[1,par.numTrialsActual/(2*par.numConds)]);    
            par.firstTilt = repmat([ones(1,2*par.numConds) 3*ones(1,2*par.numConds)],[1,par.numTrialsActual/(4*par.numConds)]);
            par.runtrials = par.numTrialsActual;
            
            rng(par.rseed, "v5uniform");
            r = randperm(par.numTrialsActual); % random order of trial numbers for threshold 1
            par.cond = par.cond(r); % contrast/duration condition
            par.LR = par.LR(r); % left/right tilts
            par.firstTilt = par.firstTilt(r);
            % Get user information
            par = readUser(par); % read user specific information

        end

        function par = readUser(par)
            % readUser - Prompts user to input participant information that
            % is stored in the parameters object, par. 
            % Note: Block number is automatically created by looking at the
            % most recently saved block number in the results folder and 
            % selecting the next number.
            
            % Prompt User
            dlg_title = 'Exp Parameters';

            prompt = {'Enter PARTICIPANT', ...
                'Session Number:',...
                'Practice?'}; 

            def = {num2str(par.pID), ...
                num2str(par.sessionNo),...
                num2str(par.practice)};
            
            answer = inputdlg(prompt,dlg_title,1, def);

            par.pID = answer{1};
            par.sessionNo = answer{2};
            par.practice = str2double(answer{3});
            % set file name of results
            folder = fullfile(pwd, par.resultsFolder);
            filename = sprintf('%s_%s_*.mat', par.pID, par.sessionNo);
            files = dir(fullfile(folder, filename));
            % Set up trial conditions
            existingNumbers = zeros(1, numel(files));
            for i = 1:numel(files)
                filename = files(i).name;
                [~, name, ~] = fileparts(filename);
                parts = strsplit(name, '_');
                existingNumbers(i) = str2double(parts{end});
            end
            % Determine the next number
            if isempty(existingNumbers)
                nextNumber = 1;
            else
                nextNumber = max(existingNumbers) + 1;
            end
            par.blockNo = num2str(nextNumber);
            par.fileName = sprintf('%s_%s_%s', par.pID, par.sessionNo, par.blockNo);
            if(par.practice)
                par.runtrials = par.numTrialsPractice;
                par.cond = ones(1, par.runtrials)*par.practice;

                par.FBInterval = 1;
                par.LR = par.LR(1:par.runtrials);
                par.firstTilt = par.firstTilt(1:par.runtrials);
            end
            par.responseTimes = zeros(1, par.runtrials);
            par.performance = zeros(1, par.runtrials);
            par.response = zeros(1, par.runtrials);
        end

        function par = triggerLC(triggerType, values, par)
            % Records trigger label and load cell sample of event in
            % specific trial
            frameNo = max(size(values));
            par.lcTriggers = [par.lcTriggers;[triggerType, frameNo]];
        end
    end
end
