%% Class Definition: displayInfo
% Description: This class handles the display settings and stimuli for a 
% visual experiment, including contrasts, colors, positions, and other 
% graphical properties. It uses the Psychtoolbox functions for drawing and 
% presenting visual stimuli.
%
% Properties:
%   Public:
%       highContrast - The high contrast value.
%       lowContrast - The low contrast value.
%       contrastChange - The change in contrast value.
%       fixColor - The fixation point color.
%       cueColor - The cue color.
%       textColor - The text color.
%       focusColor - The focus point color.
%       lcStartColor - The load cell guide start color.
%       lcMidColor - The load cell guide middle color.
%       lcEndColor - The load cell guide end color.
%       lcPointerColor - The load cell guide pointer color.
%       BLcontrast - The baseline contrast.
%       lcPointSize - The size of points in load cell guides.
%       fixSize - The size of the fixation point.
%       stimpos - The position of the stimulus.
%       spatFreq - The spatial frequency, in cycles per degree.
%       bgColor - The background color.
%       centre - The center of the screen.
%       ycenter - The y-coordinate of the screen center.
%       xcenter - The x-coordinate of the screen center.
%   
%   Hidden:
%       (many hidden properties used internally by the methods)
%
% Methods:
%   displayInfo(par) - Constructor that initializes the display settings 
%   based on provided parameters object.
%
%   showGuides(ips, flip) - Displays guides on the screen, where ips is a 
%   2x1 element array that determines the position of the guide points on
%   each side, and flip is a boolean value to flip screen after showing guides.
%
%   showBLGrating(framephase) - Displays baseline grating on the screen, 
%   framephase determines which frame in the 4 frame cycle is being shown.
%
%   showCueGrating(framephase) - Displays cue grating on the screen.
%   showEvGrating(framephase, stimType, LR) - Displays evidence grating 
%   on the screen, where stimType, 1-5 determines the trial condition and 
%   LR determines the higher brightness direction.
%
%   showPertGrating(framephase, stimType, LR) - Displays perturbed grating 
%   on the screen.
%
%   showEmpty() - Displays an empty screen with only the fixation point.
%
%   showText(strings, yOffset) - Displays text on the screen with optional 
%   y-offset for positioning.
%
%   Example:
%       di = displayInfo(par, lc); % Create a new displayInfo object
%       showGuides(di, [0.1, 0.1], 0)
%       showEmpty(di)
%
%
% Author: Oisín Hogan
% Date: 2024-07-09

classdef displayInfo
    properties
        % Existing properties
        highContrast = 0.5 
        lowContrast = 0.2
        contrastChange = -0.5
        fixColor = [215 215 215]
        cueColor = [215 0 0]
        textColor = [255 255 255]
        focusColor = [255 255 255]
        lcStartColor = [0 0 0]
        lcMidColor = [255 255 0]
        lcEndColor = [0 255 0]
        lcPointerColor = [100 100 100]
        BLcontrast = 0.5
        lcPointSize = 3
        fixSize = .2        
        stimpos = [0,0]
        spatFreq = 2 % spatial freq, in cycles per degree
        bgColor 
        centre
        ycenter
        xcenter
    end
    properties (Hidden)
        focuspoint
        rect2
        rect3
        rect4
        rect5
        rect6
        rect7
        stimrect
        colourRect 
        fixRect
        deg2px  
        whichscreen
        left
        right
        xout
        xin
        window
        ypt0
        ypt4
        BLstimL
        BLstimR
        stimL
        stimR

    end
    methods
        function displayInfo = displayInfo(par)
            % Constructs object that stores all display information using
            % the stored values in the parameters and the specified values 
            % in properties. This is used to generate specified stimuli.
            
            oriL = 135 * pi/180;
            oriR = 45 * pi/180;
            tmp = load(par.gammaFunct);
            outerrad_deg = 4;
            innerrad_deg = .05;
    
            deltaC = [displayInfo.highContrast displayInfo.lowContrast displayInfo.lowContrast displayInfo.lowContrast displayInfo.lowContrast];
            perturbationHigh = [0 0 displayInfo.contrastChange 0 0];
            perturbationLow = [0 0 0 displayInfo.contrastChange 0];
            swap = [1 1 1 1 -1]; % -1 means swap, 1 means not
    
            % Par Values
            displayInfo.whichscreen = par.whichscreen;
            displayInfo.deg2px = par.viewingDist *(screenInfo(displayInfo.whichscreen).pixels(1)/par.monitorWcm)*pi/180;
             
            % Derived Values
            nConds = par.numConds;
            fixSizePx = round(displayInfo.deg2px*displayInfo.fixSize);
            displayInfo.centre = screenInfo(par.whichscreen).pixels/2;
	        displayInfo.fixRect = [displayInfo.centre-floor(fixSizePx/2) displayInfo.centre+(fixSizePx-floor(fixSizePx/2)-1)];
            
            maxLum = grey2lum(255,tmp.gf); % maximum luminance achievable on the monitor (level 255)
            displayInfo.bgColor = lum2grey(maxLum/2,tmp.gf); % set the background color to the gray level corresponding to half the max luminance
            midLum = grey2lum(displayInfo.bgColor,tmp.gf);   % The very middle luminance on the monitor in cd/m^2
            lumAmpl = floor(midLum);   % luminance amplitude (divergence from midLum) in cd/m^2
    
            Rout = round(displayInfo.deg2px * outerrad_deg);
            Rin = round(displayInfo.deg2px * innerrad_deg);
            D = Rout * 2 + 1;

            displayInfo.stimrect = round([-1 -1 1 1]*(D-1)/2); % specification of stimulus area centred on middle of the screen, in pixels (PTB(Psychtoolbox) needs this to drawtexture later)
    
            [x,y] = meshgrid((1:D)-(D+1)/2,(1:D)-(D+1)/2); % specifies a coordinate system on an x/y axis. Below specifies points on the axis
            GL = sin(displayInfo.spatFreq/displayInfo.deg2px*2*pi*(x.*cos(oriL)+y.*sin(oriL))); % range -1 to 1 (needs to be transformed to brightness scale)
            GR = sin(displayInfo.spatFreq/displayInfo.deg2px*2*pi*(x.*cos(oriR)+y.*sin(oriR))); % range -1 to 1 (needs to be transformed to brightness scale)
        
            GL(GL>0) = lumAmpl; 
            GL(GL<0) = -lumAmpl; % convert sinusoidal luminance modulation of the spatial pattern to square wave
            GR(GR>0) = lumAmpl; 
            GR(GR<0) = -lumAmpl;
            
            % Cut out annulus shape 
            for j=1:D
                for k=1:D
                    [~,r]=cart2pol(x(j,k),y(j,k)); % cartesian to polar
                    if r < Rin || r > Rout
                        GL(j,k)= 0; 
                        GR(j,k)= 0;
                    end
                end
            end
            
            while 1 % Keep trying till it does it
                try
                    [displayInfo.window] = Screen('Openwindow', displayInfo.whichscreen, displayInfo.bgColor);
                    break
                catch
                end
            end
    
            tockp = [];
            tic;
            for i=1:100
                Screen('flip',displayInfo.window);
                tockp = [tockp; toc];
            end
            if abs(1/(median(diff(tockp))) - screenInfo(par.whichscreen).refreshrate) > 1
                error('refresh rate off - try restarting matlab or the computer')
            end
               
            displayInfo.BLstimL = Screen('MakeTexture', displayInfo.window, lum2grey(midLum + displayInfo.BLcontrast*GL, tmp.gf));
            displayInfo.BLstimR = Screen('MakeTexture', displayInfo.window, lum2grey(midLum + displayInfo.BLcontrast*GR, tmp.gf));

            displayInfo.left = par.left;
            displayInfo.right = par.right;
            
            for c=1:nConds
                % 1 and 2 => initial states, 1 left hand first, 2 right handfirst. 
                % 3, 4 => final states of 1/2
                displayInfo.stimL(c,displayInfo.left) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast + deltaC(c))*GL, tmp.gf)); 
                % Initial left brightness if left brighter
                displayInfo.stimL(c,displayInfo.right) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast - deltaC(c))*GL, tmp.gf));
                % Initial left brightness if right brighter
                displayInfo.stimL(c,displayInfo.left+2) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast + deltaC(c)*swap(c) + perturbationHigh(c))*GL, tmp.gf));
                % Final left brightness if left brighter
                displayInfo.stimL(c,displayInfo.right+2) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast + deltaC(c)*swap(c) - perturbationLow(c))*GR, tmp.gf));
                % Final left brightness if right brighter

                displayInfo.stimR(c,displayInfo.left) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast - deltaC(c))*GR, tmp.gf));  
                % Initial right brightness if left brighter
                displayInfo.stimR(c,displayInfo.right) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast + deltaC(c))*GR, tmp.gf));  
                % Initial right brightness if right brighter
                displayInfo.stimR(c,displayInfo.left+2) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast - deltaC(c)*swap(c) - perturbationLow(c))*GR, tmp.gf)); 
                % Final right brightness if left brighter
                displayInfo.stimR(c,displayInfo.right+2) = Screen('MakeTexture', displayInfo.window, ...
                    lum2grey(midLum + (displayInfo.BLcontrast - deltaC(c)*swap(c) + perturbationHigh(c))*GL, tmp.gf)); 
                % Final right brightness if right brighter

                % vector of 4 stimuli with 2 final stage
            end
            
            displayInfo.ycenter = displayInfo.centre(2);
            displayInfo.xcenter = displayInfo.centre(1);
        
            thresh1 = par.thresholds(1);
            thresh2 = par.thresholds(2);
            thresh3 = par.thresholds(3);
            thresh4 = par.thresholds(4);
        
            displayInfo.lcPointSize = 3;
            displayInfo.ypt0 = displayInfo.ycenter + D/4;
            displayInfo.ypt4 = displayInfo.ycenter - D/4;
            ypt1 = displayInfo.ypt0 + (displayInfo.ypt4 - displayInfo.ypt0)*thresh1;
            ypt2 = displayInfo.ypt0 + (displayInfo.ypt4 - displayInfo.ypt0)*thresh2;
            ypt3 = displayInfo.ypt0 + (displayInfo.ypt4 - displayInfo.ypt0)*thresh3;
            ypt4 = displayInfo.ypt0 + (displayInfo.ypt4 - displayInfo.ypt0)*thresh4;
            
            displayInfo.xout = 1.4*D/2;
            displayInfo.xin = 1.1*D/2;
            
            displayInfo.focuspoint = [displayInfo.centre-2 displayInfo.centre+2];
            displayInfo.rect2 = [displayInfo.xcenter-displayInfo.xout ypt1 displayInfo.xcenter-displayInfo.xin ypt2];
            displayInfo.rect3 = [displayInfo.xcenter+displayInfo.xout ypt1 displayInfo.xcenter+displayInfo.xin ypt2];
            displayInfo.rect4 = [displayInfo.xcenter-displayInfo.xout ypt1 displayInfo.xcenter-displayInfo.xin ypt2];
            displayInfo.rect5 = [displayInfo.xcenter+displayInfo.xout ypt1 displayInfo.xcenter+displayInfo.xin ypt2];
            displayInfo.rect6 = [displayInfo.xcenter-displayInfo.xout ypt3 displayInfo.xcenter-displayInfo.xin ypt4];
            displayInfo.rect7 = [displayInfo.xcenter+displayInfo.xout ypt3 displayInfo.xcenter+displayInfo.xin ypt4];
            
            displayInfo.colourRect = [displayInfo.focusColor;
                                     displayInfo.lcStartColor; % start
                                     displayInfo.lcStartColor;
                                     displayInfo.lcMidColor; % mid
                                     displayInfo.lcMidColor;
                                     displayInfo.lcEndColor; % end
                                     displayInfo.lcEndColor;
                                     displayInfo.lcPointerColor; % pointer
                                     displayInfo.lcPointerColor]';
        end

        function showGuides(displayInfo, ips, flip)
            % Show guides for the loadCell force values on either side of
            % the screen, of colours and position specified in dispayInfo 
            % object, two pointers on each guide are displayed, with their
            % position dictated by the recorded force values, ips, this
            % function can be displayed on the screen using the flip
            % boolean variable, or not for use to be shown with another
            % function.

            pointR =[displayInfo.xcenter-(displayInfo.xout+displayInfo.xin)/2-displayInfo.lcPointSize,...
                    displayInfo.ypt0+(displayInfo.ypt4-displayInfo.ypt0)*ips(displayInfo.left)-displayInfo.lcPointSize,...
                    displayInfo.xcenter-(displayInfo.xout+displayInfo.xin)/2+displayInfo.lcPointSize,...
                    displayInfo.ypt0+(displayInfo.ypt4-displayInfo.ypt0)*ips(displayInfo.left)+displayInfo.lcPointSize]; 
    
            PointL =[displayInfo.xcenter+(displayInfo.xout+displayInfo.xin)/2-displayInfo.lcPointSize,...
                    displayInfo.ypt0+(displayInfo.ypt4-displayInfo.ypt0)*ips(displayInfo.right)-displayInfo.lcPointSize,...
                    displayInfo.xcenter+(displayInfo.xout+displayInfo.xin)/2+displayInfo.lcPointSize,...
                    displayInfo.ypt0+(displayInfo.ypt4-displayInfo.ypt0)*ips(displayInfo.right)+displayInfo.lcPointSize];
    
            rects = [displayInfo.focuspoint;displayInfo.rect2;displayInfo.rect3;displayInfo.rect4;displayInfo.rect5;displayInfo.rect6;displayInfo.rect7;pointR;PointL]';
            
            Screen('FillRect',displayInfo.window , (displayInfo.colourRect) ,(rects));

            Screen('FillRect',displayInfo.window, displayInfo.fixColor, displayInfo.fixRect); 
            if flip == 1
                Screen('Flip', displayInfo.window);
            end
        end

        function showBLGrating(displayInfo, framephase)
            % Shows the baseline contrast grating, using the values in the
            % displayInfo object and the framephase to specify which frame
            % in the 4-frame cycle is being shown

            switch(framephase)
                case(1)
                case(2)
                    Screen('DrawTexture',displayInfo.window,displayInfo.BLstimL,[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
                case(3)
                case(0)
                    Screen('DrawTexture',displayInfo.window,displayInfo.BLstimR,[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
            end
            Screen('FillRect',displayInfo.window, displayInfo.fixColor, displayInfo.fixRect);
            Screen('Flip',displayInfo.window);
        end

        function showCueGrating(displayInfo, framephase)
            % Shows the baseline contrast grating, with the fixation point 
            % color changed to the cue color using the values in the
            % displayInfo object and the framephase to specify which frame
            % in the 4-frame cycle is being shown

            switch(framephase)
                case(1)
                case(2)
                    Screen('DrawTexture',displayInfo.window,displayInfo.BLstimL,[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
                case(3)
                case(0)
                    Screen('DrawTexture',displayInfo.window,displayInfo.BLstimR,[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
            end
            Screen('FillRect',displayInfo.window, displayInfo.cueColor, displayInfo.fixRect);
            Screen('Flip',displayInfo.window);
        end
        
        function showEvGrating(displayInfo, framephase, stimType, LR)
            % Show the evidence contrast grating, using the values in the
            % displayInfo object, the framePhase to specify the frame in
            % the 4-frame cycle, stimType to specify the condition (1-5),
            % and LR to specify the brighter grating direction (1 or 2)

            if stimType > 2
                stimType = 2;
            end
            switch(framephase)
                case(1)
                case(2)
                    Screen('DrawTexture',displayInfo.window,displayInfo.stimL(stimType, LR),[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
                case(3)
                case(0)
                    Screen('DrawTexture',displayInfo.window,displayInfo.stimR(stimType, LR),[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
            end
            Screen('FillRect',displayInfo.window, displayInfo.cueColor, displayInfo.fixRect);
            Screen('Flip',displayInfo.window);
        end

        function showPertGrating(displayInfo, framephase, stimType, LR)
            % Show the perturbation contrast grating, using the values in 
            % the displayInfo object, the framePhase to specify the frame 
            % in the 4-frame cycle, stimType to specify the condition (1-5),
            % and LR to specify the brighter grating direction (1 or 2).
            % No change for stimType 1 and 2, perturbations for stimType 3
            % and 4, and a swap in contrast level for stimType 5.

            switch(framephase)
                case(1)
                case(2)
                    Screen('DrawTexture',displayInfo.window,displayInfo.stimL(stimType, LR+2),[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
                case(3)
                case(0)
                    Screen('DrawTexture',displayInfo.window,displayInfo.stimR(stimType, LR+2),[],[displayInfo.xcenter displayInfo.ycenter displayInfo.xcenter displayInfo.ycenter] + round([1 0 1 0]*displayInfo.stimpos(1)*displayInfo.deg2px) + round([0 -1 0 -1]*displayInfo.stimpos(2)*displayInfo.deg2px) + displayInfo.stimrect);
            end
            Screen('FillRect',displayInfo.window, displayInfo.cueColor, displayInfo.fixRect);

            Screen('Flip',displayInfo.window);
        end

        function showEmpty(displayInfo)
            % Show an empty screen, except for the fixation point using the
            % values in displayInfo

            Screen('FillRect',displayInfo.window, displayInfo.fixColor, displayInfo.fixRect);
            Screen('Flip',displayInfo.window);
        end

        function showText(displayInfo, strings, yOffset)
            % Show text in strings in the horizontal centre of the screen 
            % using the values in the displayInfo object, and y offset 
            % to position the text at the desired vertical location

            Screen('FillRect',displayInfo.window, displayInfo.fixColor, displayInfo.fixRect);
            % Calculate total text height
            totalTextHeight = 0;
            for i = 1:numel(strings)
                if(ischar(strings)~=1)
                    textBounds = Screen('TextBounds', displayInfo.window, strings{i});
                else
                    textBounds = Screen('TextBounds', displayInfo.window, strings);
                end
                totalTextHeight = totalTextHeight + (textBounds(4) - textBounds(2));
                if(ischar(strings))
                    break
                end
            end
            
            % Calculate starting y-position for centering
            startYPos = ((screenInfo(displayInfo.whichscreen).pixels(2) - totalTextHeight) / 2)-yOffset;
        
            % Draw each text string
            currentYPos = startYPos;
            for i = 1:numel(strings)
                % Calculate text size
                if(ischar(strings)~=1)
                    textBounds = Screen('TextBounds', displayInfo.window, strings{i});
                else
                    textBounds = Screen('TextBounds', displayInfo.window, strings);
                end
                textWidth = textBounds(3) - textBounds(1);
                textHeight = textBounds(4) - textBounds(2);
        
                % Calculate x-position for centering
                xPos = (screenInfo(displayInfo.whichscreen).pixels(1)  - textWidth) / 2;
                
                % Draw text
                if(ischar(strings)~=1)
                    Screen('DrawText', displayInfo.window, strings{i}, xPos, currentYPos, displayInfo.textColor );
                    currentYPos = currentYPos + textHeight;
                else
                    Screen('DrawText', displayInfo.window, strings, xPos, currentYPos, displayInfo.textColor );
                    break
                end
            end
        
            % Flip the screen
            Screen('Flip', displayInfo.window);
        end

    end
end


