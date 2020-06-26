function REDm_info = InitiViewXAPI_DP( profile )
% InitiViewXAPI.m
%
% Initializes iViewX API data structures and library pointers
%
% Original Author: SMI GmbH, 2013 (copyright notice at bottom of file)
%
% Changes:
% changed output variable list to a single data structure D.Lloyd 11/2014....
% Added in the pREDGeometryInfo to the function D.Lloyd 11/2014....
% Altered the calibration data definition D.Lloyd 11/2014....
%

%===========================
%==== RedM default comm info 
%===========================

%Default values for when using eyetracker on same PC as controlling matlab software
DefaultComms.recport = 5555;
DefaultComms.recIP = '127.0.0.1';
DefaultComms.sendport = 4444;
DefaultComms.sendIP = '127.0.0.1';
DefaultComms.logfilename = 'defaultiViewXlog.txt';

%===========================
%==== RedM setup/Geometry info
%===========================

% Note: Although attached to a screen, the geometrical set up for the Redm has to be
% regarded as "stand alone" due to advanced options for configuration.
% 1 = standalone, 0 = monitor integrated
REDGeometryData.redGeometry = int32(1);

% a profile name 
REDGeometryData.setupName = profile.setupName;  

% Visible Screen width [mm]  MEASURED for station1
REDGeometryData.stimX = profile.stimX; 

% Visible Screen height [mm] MEASURED for station1
REDGeometryData.stimY = profile.stimY; 

% Vertical distance RED-m to stimulus screen [mm]  MEASURED for station1
REDGeometryData.redStimDistHeight = profile.redStimDistHeight; 

% Horizontal distance RED-m to stimulus screen [mm]  MEASURED for station1
REDGeometryData.redStimDistDepth = profile.redStimDistDepth; 

% off horizontal RED-m inclination angle [degree]  MEASURED for station1
REDGeometryData.redInclAngle = profile.redInclAngle; 


%===========================
%==== Calibration data
%===========================

% set up the CalibrationData structure with the actual data that will be used to calibrate the eyetracker 
CalibrationData.method = int32(5); % number of data points in calibration test pattern 2,5,8,9,13 (default: 5)

% draw calibration/validation by API (default: 1) 
CalibrationData.visualization = int32(1);

% set display device [0: primary device (default), 1: secondary device] 
CalibrationData.displayDevice = int32(1); % 0 - primary, 1 - secondary

% set calibration/validation speed [0: slow (default), 1: fast] 
CalibrationData.speed = int32(0);

% set calibration/validation point acceptance [1 = automatic (default) 0 = manual] 
CalibrationData.autoAccept = int32(0);

% set calibration/validation target brightness [0..255] (default: 250) 
CalibrationData.foregroundBrightness = int32(255);

% set calibration/validation background brightness [0..255] (default: 220) 
CalibrationData.backgroundBrightness = int32(0);

% image = 0; circle = 1; circle2 (defau;t) = 2; cross = 3
CalibrationData.targetShape = int32(2);

% target size in pixels (default 20)
CalibrationData.targetSize = int32(10);

% custom calibration/validation target filename (only if targetShape = 0)
% 256 characters maximum for pathname/filename
CalibrationData.targetFilename = int8('');
% Calibration.targetFilename = int8([0:255] * 0 + 30);


%===========================
%==== System Info
%===========================

SystemInfo.samplerate = int32(0);
SystemInfo.iV_MajorVersion = int32(0);
SystemInfo.iV_MinorVersion = int32(0);
SystemInfo.iV_Buildnumber = int32(0);
SystemInfo.API_MajorVersion = int32(0);
SystemInfo.API_MinorVersion = int32(0);
SystemInfo.API_Buildnumber = int32(0);
SystemInfo.iV_ETDevice = int32(0);
pSystemInfoData = libpointer('SystemInfoStruct', SystemInfo);


%===========================
%==== Eye data
%===========================

Eye.gazeX = double(0);
Eye.gazeY = double(0);
Eye.diam = double(0);
Eye.eyePositionX = double(0);
Eye.eyePositionY = double(0);
Eye.eyePositionZ = double(0);


%===========================
%==== Online Sample data
%===========================

Sample.timestamp = int64(0);
Sample.leftEye = Eye;
Sample.rightEye = Eye;
Sample.planeNumber = int32(0);
pSampleData = libpointer('SampleStruct', Sample);


%===========================
%==== Online Event data
%===========================

Event.eventType = int8('F');
Event.eye = int8('l');
Event.startTime = double(0);
Event.endTime = double(0);
Event.duration = double(0);
Event.positionX = double(0);
Event.positionY = double(0);
pEventData = libpointer('EventStruct', Event);


%===========================
%==== Accuracy data
%===========================

Accuracy.deviationLX = double(0);
Accuracy.deviationLY = double(0);
Accuracy.deviationRX = double(0);
Accuracy.deviationRY = double(0);
pAccuracyData = libpointer('AccuracyStruct', Accuracy);


%===========================
%==== Put everything into the REDm_info data strcture
%===========================
REDm_info.DefaultComms = DefaultComms;
REDm_info.REDGeometryData = REDGeometryData;
REDm_info.CalibrationData = CalibrationData;
REDm_info.pSystemInfoData = pSystemInfoData;
REDm_info.pSampleData = pSampleData;
REDm_info.pEventData = pEventData;
REDm_info.pAccuracyData = pAccuracyData;



% -----------------------------------------------------------------------
%
% (c) Copyright 1997-2013, SensoMotoric Instruments GmbH
% 
% Permission  is  hereby granted,  free  of  charge,  to any  person  or
% organization  obtaining  a  copy  of  the  software  and  accompanying
% documentation  covered  by  this  license  (the  "Software")  to  use,
% reproduce,  display, distribute, execute,  and transmit  the Software,
% and  to  prepare derivative  works  of  the  Software, and  to  permit
% third-parties to whom the Software  is furnished to do so, all subject
% to the following:
% 
% The  copyright notices  in  the Software  and  this entire  statement,
% including the above license  grant, this restriction and the following
% disclaimer, must be  included in all copies of  the Software, in whole
% or  in part, and  all derivative  works of  the Software,  unless such
% copies   or   derivative   works   are   solely   in   the   form   of
% machine-executable  object   code  generated  by   a  source  language
% processor.
% 
% THE  SOFTWARE IS  PROVIDED  "AS  IS", WITHOUT  WARRANTY  OF ANY  KIND,
% EXPRESS OR  IMPLIED, INCLUDING  BUT NOT LIMITED  TO THE  WARRANTIES OF
% MERCHANTABILITY,   FITNESS  FOR  A   PARTICULAR  PURPOSE,   TITLE  AND
% NON-INFRINGEMENT. IN  NO EVENT SHALL  THE COPYRIGHT HOLDERS  OR ANYONE
% DISTRIBUTING  THE  SOFTWARE  BE   LIABLE  FOR  ANY  DAMAGES  OR  OTHER
% LIABILITY, WHETHER  IN CONTRACT, TORT OR OTHERWISE,  ARISING FROM, OUT
% OF OR IN CONNECTION WITH THE  SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% -----------------------------------------------------------------------





