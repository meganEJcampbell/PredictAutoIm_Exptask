function WindowNum = init_psychtoolbox

% opens screens for psychtoolbox
%
% WindowNum = reference to window opened for display
% automatically checks for dual displays and uses display 2 if available

%% Preliminary stuff

AssertOpenGL;               % check for Opengl compatibility
KbName('UnifyKeyNames');    % Enable unified mode of KbName, so it'll accept identical key names on all operating systems

%% define and open windows
%%% IF DEBUGGING     
%PsychDebugWindowConfiguration([],0.4); % comment this out when finished debugging. - makes screen transperent so if coding on single-monitor set-up can see command window behind display screen.

% HideCursor; % turned off for debugging but maybe hidecursor when really
% testing/ be careful not to leave cursor on display screen (2)

if length(Screen('Screens')) >= 2 %% if there is an external monitor, 0 =main, 1 = external, 2=external2 (PC in EEG has 0,1,2)!!
    y=2; % usually set to y=1 but need y=2 for EEG_PC ?!!
else
    y=0;
end

Screen('Preference', 'SkipSyncTests', 1);   % !!!! leave on 1 for debug on mac, and change to 0 for testing on PC % sync test causes problems sometimes, so disable

box = [];
[WindowNum] = Screen('OpenWindow', y, 1);   % opens the screen : y=0for main display, y=1 for second monitory;  1 makes background black

Screen('TextFont', WindowNum, 'Arial');  % Select specific text font 
Screen('TextSize', WindowNum, 36); %changed to 24 but this was small on film; was 48s RC's original
Screen('TextStyle', WindowNum, 1);      % 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend

%% give priority to these functions
priorityLevel=MaxPriority('GetSecs','KbCheck','KbWait','GetClicks'); %Make sure responses, MRI trigger and timing are correct using the priorityLevel function          
% Priority(priorityLevel);

KbCheck;                        % Do dummy calls to make sure they are loaded and ready when we need them
WaitSecs(0.1);
GetSecs;

end
