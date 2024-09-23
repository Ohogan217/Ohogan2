function saveFiles(par, disp, Lcc)
    % saveFiles Saves load cell decision making trial data into a 
    % structured .mat file.
    %
    %   Inputs:
    %       par     - parameters object.
    %       disp    - displayInfo object.
    %       Lcc     - loadCell object.
    %
    %   Example:
    %       par = parameters();   
    %       disp = displayInfo();    
    %       Lcc = loadCell();    
    %       saveFiles(par, disp, Lcc);
    %
    %   This function extracts fields from objects par, disp, and Lcc into
    %   structures and saves them into a .mat file named according to par.fileName
    %   in the specified results folder (par.resultsFolder).
    
    % Extract fields into structures
    parFields = fieldnames(par);  % Get field names of par
    for i = 1:numel(parFields)
        parStruct.(parFields{i}) = par.(parFields{i});  % Assign each field to the structure
    end
    
    dispFields = fieldnames(disp);  % Get field names of disp
    for i = 1:numel(dispFields)
        dispStruct.(dispFields{i}) = disp.(dispFields{i});  % Assign each field to the structure
    end
    
    LccFields = fieldnames(Lcc);  % Get field names of Lcc
    for i = 1:numel(LccFields)
        LccStruct.(LccFields{i}) = Lcc.(LccFields{i});  % Assign each field to the structure
    end
    
    % Combine into a single data structure
    data.parameters = parStruct;
    data.displayInformation = dispStruct;
    data.loadCellCalibration = LccStruct;
    
    filename = sprintf('%s.mat', par.fileName);
    
    % Save the data structure
    save(fullfile(pwd, par.resultsFolder, filename), 'data');

end