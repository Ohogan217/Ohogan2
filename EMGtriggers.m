% EMGtriggers -object for handling EMG (Electromyography) triggers by 
% interfacing with an io64 object to send signals to a specified port address.
% 
% Properties:
%   ioObj - An instance of the io64 object for interfacing with hardware.
%   address - The port address for sending triggers.
%
% Methods:
%   EMGtriggers(portAddress) - Constructor that initializes the io64 object 
%                              and sets the port address, if address is 
%                              empty, defaults to hex2dec('4FF8').
%   triggerEMG(trigger) - Sends a specific trigger value to the port address.
%   sendOnOffEMG() - Sends an on-off-on sequence to the port address, with
%                    brief delays in between.
% Example:
%   emg = EMGtriggers(hex2dec('4FF8'))
%   sendOnOffEMG(emg)
%
% Author: Oisín Hogan
% Date: 2024-07-05

classdef EMGtriggers
    properties
        ioObj
        address
    end
    methods
        function emg = EMGtriggers(portAddress)
            % Sets up EMG trigger io64 object to send triggers out the port
            % address specified, if portAddress is left blank, will default
            % to hex2dec('4FF8')
            if nargin<1;portAddress = hex2dec('4FF8');end

            emg.ioObj = io64;
            %initialize the inpoutx64 system driver
            status = io64(emg.ioObj);
            if(status == 0)
                disp("EMG triggers ready")
            end
            emg.address = portAddress;
        end
        function triggerEMG(emg, trigger)
            % Sends a trigger value out the io64 object, 1 or 0
            io64(emg.ioObj, emg.address, trigger);
        end

        function sendOnOffEMG(emg)
            % Sends an on/off spike out the io64 object for EMG triggers
            triggerEMG(emg, 0)
            WaitSecs(0.1)
            triggerEMG(emg, 1)
            WaitSecs(0.1)
            triggerEMG(emg, 0)
        end
    end
end
