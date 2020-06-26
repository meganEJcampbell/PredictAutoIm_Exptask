function REDm_info = SMI_Redm_Init_DP( profile )
% loads the various libraries needed to run the eyetracker, starts the 
% iviewX data server, and creates a REDm_info data structure that holds a 
% lot of defaults values and pointers to data structures that will be used 
% in the operation of the eyetracker.

REDm_info = [];


% Check to see if its a PC and its a 32 bit matlab - currently need both to
% run as far as my testing showed. (i.e. When using MS SDK7.1 on 64 bit OS 
% then we have loadlibrary errors when trying to run, even when using the 
% iViewXAPI64.dll. Seems the errors come from not having an appropriate 
% 64 bit .h file... maybe.....
if ~ispc
    disp('###############################################');
    disp('RedX only runs on 32/64 bit PC OS at the moment');
    disp('###############################################'); 
    return
end
if ~strcmpi(mexext,'mexw32')
   disp('#############################################');
   disp('RedX only runs on 32 bit matlab at the moment');
   disp('#############################################');
   return
end


if strcmpi(system_dependent('getos'),'Microsoft Windows 7') % set paths for 64 bit windows default install addresses
    addpath('C:\Program Files (x86)\SMI\iView X SDK\include\');
    addpath('C:\Program Files (x86)\SMI\iView X SDK\bin\')    
elseif strcmpi(system_dependent('getos'),'Microsoft Windows XP') % set paths for the 32 bit windows default install addresses
    addpath('C:\Program Files\SMI\iView X SDK\include\'); % these are the hard addresses of the .dll file and the .h file.
    addpath('C:\Program Files\SMI\iView X SDK\bin\');
else
    disp('#############################################');
    disp('### Something weird in OS recognition part ##');
    disp('#############################################');
    return
end


% load the iViewX API library
loadlibrary('iViewXAPI.dll', 'iViewXAPI.h');

% set a whole bunch of structures up for data handling and fior default
% values
REDm_info = InitiViewXAPI_DP( profile );

% start the REDm server software on the PC
calllib('iViewXAPI', 'iV_Start', int32(1));
% Starts the iView X (eyetracking-server) application. 
% Depending on the PC, it may take several seconds to start the iView X (eyetracking-server) application. 
%
% 	for iView X based devices like RED, HiSpeed, MRI, HED
% 	value = 0, 
% 	
% 	for RED-OEM based devices like RED-m or other customized RED-OEM devices
% 	value = 1
disp('pausing.... to let iviewX start server')
pause(5)
disp('done with pausing')








