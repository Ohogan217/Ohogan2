classdef screenInfo
   properties
      pixels 
      refreshrate {mustBeNumeric}
      whichscreen {mustBeNumeric}
   end
   methods     
       function obj = screenInfo(whichscreen)
            obj.whichscreen = whichscreen;
            [h, v] = Screen('WindowSize',whichscreen);
            obj.pixels = [h, v];
            obj.refreshrate = Screen('FrameRate', whichscreen);
       end
       function showinfo(obj)
            disp(['SCREEN RESOLUTION ' num2str(obj.pixels(1)) ' x ' num2str(obj.pixels(2))])
            disp(['MONITOR REFRESH RATE ' num2str(obj.refreshrate) ' Hz']);
       end
   end
end