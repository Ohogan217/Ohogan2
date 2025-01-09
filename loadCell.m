% loadCell - Object for setting up and recording a pair of load cells 
% for force measurement
%
%   This class represents two load cells used for force measurement 
%   response. It provides methods for initialisation, reading force values, 
%   setting calibration values, calibrating the load cells, and 
%   normalising force readings.
%
%   Properties:
%       maxCal - Maximum calibration values
%       minCal - Minimum calibration values
%       MVCs   - Maximum Voluntary Contractions
%       maxScale - Maximum scale values
%       force  - Force readings
%       left   - Identifier for the left load cell
%       right  - Identifier for the right load cell
%
%   Hidden Properties:
%       d       - Data acquisition object
%       rightCh - Channel for the right load cell
%       leftCh  - Channel for the left load cell
%
%   Methods:
%       loadCell - Constructor method to create a new loadCell object
%       readForce - Reads the force value from the load cells
%       setLCCVals - Sets maximum and minimum calibration  (Testing only)
%       calibrateLC - Calibrates the load cells
%       normLCReadings - Normalizes the force readings
%       readCalForce - Reads and normalizes force readings
%
%   Example:
%       lc = loadCell(1); % Create a new loadCell object, specifying the
%       left load cell is channel 1
%       lc = calibrateLC(lc, display, parameters); % Calibrate the load cells
%       forces = readCalForce(lc); % Read and normalize force readings
%
%   Author: Oisín Hogan
%   Created: 2024-07-09
classdef loadCell
    properties
        maxCal
        minCal
        MVCs
        maxScale = [0.2, 0.2]
    end 
    properties(Hidden)
        d 
        rightCh
        leftCh
        left
        right
        force
    end
    methods   
        function loadCells = loadCell(left)
            % Creates new Loac cell object, set up using the National 
            % Instruments DAQ. It calls the channels ai0 and ai1 and sets
            % them to single Ended input. Also specifies the left and right
            % load cell channels based on the input left (equal to 1 or 2).

            loadCells.left = left;
            loadCells.right = 3 - loadCells.left;
            loadCells.d = daq("ni");
            loadCells.leftCh = addinput(loadCells.d,"Dev1","ai0","Voltage");
            loadCells.rightCh = addinput(loadCells.d,"Dev1","ai1","Voltage"); 
            loadCells.leftCh.TerminalConfig = 'SingleEnded';
            loadCells.rightCh.TerminalConfig = 'SingleEnded';

            % Assignes a value (1 or 2) to each of the load cells
        end 
        
        function loadCells = readForce(loadCells)
            % Reads one sample of force value in from the load cells
            
            data = read(loadCells.d,1);
            loadCells.force = data.Variables;
        end

        function lc = setLCCVals(lc, max, min)
            % Set the calibration values for the load cell object, with a
            % 2x1 array to specify the maximum value for each cell and and
            % 2x1 array to specift the minimum value for each cell.

            lc.maxCal = max;
            lc.minCal = min;
        end

       

        function calForces = normLCReadings(loadCells)
            % Scales the recorded forces based on the maximum and minimum
            % calibration values that have been specified

            calForces = (loadCells.force - loadCells.minCal) ./ (loadCells.maxCal - loadCells.minCal);
        end 

        function calForces = readCalForce(loadCells)
            % Records and calibrated the forces for the load cells for use
            % in trials

            loadCells = readForce(loadCells);
            calForces = normLCReadings(loadCells);
        end 

        function loadCells = calibrateLC(loadCells, display, parameters)
            % Checks for pre existing calibration values for the same
            % session, if no values exist, begins a calibration procedure.
            % Calibration procedure is based on the participant placing the
            % maximum force they can on each side 3 times, this can be used
            % to record the Maximum Voluntary Contraction if recording EMG.
            % The maximum recorded force values can be scaled to a
            % specified value to determine the maximum acceptable force for
            % a response, this is determined by the maxScale property

            folder = fullfile(pwd, parameters.resultsFolder);
            pattern = sprintf('%s_%s_1.mat', parameters.pID, parameters.sessionNo);
            files = dir(fullfile(folder, pattern));
            % Check if calibration has already been completed in current
            % session
            holdtime = 300;
            hold = 0;
            if (isempty(files))
                %If no calibration has been completed, carry out
                %calibration procedure
                vals = [];
                for i = 1:100
                    showEmpty(display)
                end
                for i = 1:40
                    showText(display, 'Remove all force from sensors.', 0)
                    loadCells = readForce(loadCells);
                    vals = [vals; loadCells.force];
                end
                loadCells.minCal = min(vals, [], 1);
    
                while(1)
                    showText(display, 'Place fingers on sensors.',0);
                    loadCells = readForce(loadCells);
                    if abs(loadCells.force(1)) > loadCells.minCal(1) && ...
                        abs(loadCells.force(2)) > loadCells.minCal(2)
                        hold = hold+1;
                    else
                        hold = 0;
                    end
                    if hold == 100
                        break
                    end
                end


                for i = 1:holdtime
                    showText(display, 'Put Max Force with Right Finger',0);
                end
                for i = 1:holdtime
                    showText(display, 'Put Max Force with Left Finger',0);
                end
                for i = 1:holdtime
                    showText(display, 'Put Max Force with Right Finger',0);
                end
                for i = 1:holdtime
                    showText(display, 'Put Max Force with Left Finger',0);
                end

                vals = [];
                for i = 1:holdtime
                    showText(display, 'Put Max Force with Right Finger',0);
                    loadCells = readForce(loadCells);
                    vals = [vals; loadCells.force];
                end
                loadCells.MVCs(loadCells.right) = max(vals(:,loadCells.right));
                vals = [];
                for i = 1:holdtime
                    showText(display, 'Put Max Force with Left Finger',0);
                    loadCells = readForce(loadCells);
                    vals = [vals; loadCells.force];
                end
                loadCells.MVCs(loadCells.left) = max(vals(:,loadCells.left));
            else
                %If calibrated previously, use those values
                load(fullfile(parameters.resultsFolder, pattern));
                loadCells.minCal =  data.loadCellCalibration.minCal;
                loadCells.MVCs =  data.loadCellCalibration.MVCs;

            end
                loadCells.maxCal = loadCells.maxScale .* loadCells.MVCs;
                % Scale the MVC by the maxScale property
        end 
    end
end
