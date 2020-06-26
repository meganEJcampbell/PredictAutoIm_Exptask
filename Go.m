%% Go_predict_exp SRC likelihood changes by block; response always predefined
%%% New experiment script built around Chase's formtrials function and RC's functions for playing videos in PTB
%%% Version1 Megan 4th May 2017

%%%%%% !!!! IMPORTANT NOTE FOR PC: must open matlab without the gui interface i.e. in no java mode
%%%%%% to do this, open command prompt and type > matlab -nojvm
%%%%%% this starts up matlab in a bare-bones black-and-white screen with just the command window displayed. (

%%% !!! Check display monitor is set to 60Hz

%%% Functions required to run this script:

    %%% --- init_Psychtoolbox --- %%%
    % %   opens screens for psychtoolbox
    % %   WindowNum = reference to window opened for display; automatically checks for dual displays and uses display 2 if available
    
    %%% --- formtrials.m --- %%%
    % %     
    % %     forms a block variable that holds all the information for individual trials and orders them 
    % %     according to necessary rules/counter-balancing.
    
    %%% --- ShuffleIt.m --- %%%
    % %     Shuffles elements - need this because PC set-up doesn't recognise shuffle(X,X)
    % %     for elements in a structure... 
    
    %%% --- PlayMovie_responses --- %%%
    % % function [StartTime, EndTime, ResponseTime] = PlayMovie_responses(moviename, movieduration, window)
    % % Plays video and monitors for keyboard releases  %%(NB.1)%%
    % % returns precise start time for 1st video frame and precise duration, detection of keyboard keys only accurate to nearest screen refresh!! (not ms precision!)

    %%% --- WaitforScanner --- %%%
    % % KeyTime=WaitforScanner(OnsetTime, Keys, fid)       % Waits for scanner trigger (key 5) and logs other keyboard presses

    %%% --- WaitandMonitor --- %%%
    % % [ResponseTime, Response] = WaitandMonitor(TargetTime, OnsetTime, Keys, fid)   % Waits until clock = TargetTime and logs keyboard presses

    %%% --- WriteLog --- %%%
    % % WriteLog(fid, trial, type, time, text)

%% Make a structure with details for the environment parameters
%%%  Environment.refresh .displays .filesep (if Unix / if Windows \)
% CHECK FILE-SEPARATORS - only used for designating movie clip directory
% for PlayMovie_responses.m fx????
    % for QBI EEG dual-display PC 
    % refresh rate on display PC is set to 60Hz
%remember to use 'filesep' to specify directory paths with correct \ or /

%% preliminary stuff - clear, enter SubID
clear all
clc
close('all')
rng('shuffle'); % to shuffle the rand number generator everytime (if not 'random' order starts from the same point everytime Matlab is restarted
pwd

disp('CHECK EEG IS RECORDING!') 
disp('')
subj_id=input('subject code: ','s');
subj_id=strrep(subj_id,' ','_');        % replace any spaces with _ for creating filename
disp(' ');
datafilename = [pwd , filesep, 'logs', filesep, subj_id, '_SRCpredict.txt'];     % creates a filename for the results with the subject's code
matfilename =  [pwd , filesep, 'logs', filesep, subj_id, '_SRCpredict.mat'];  % filename to save block.trial structure to.

x=1;
while exist(datafilename, 'file')   %add a number to end of filename if it already exists
    datafilename = [subj_id, '_', '-SRCpredict.', num2str(x), '.txt'];
    x=x+1;
end
x=1;
while exist(matfilename, 'file')   %add a number to end of filename if it already exists
    matfilename = [subj_id, '_', '-SRCpredict.', num2str(x), '.mat'];
    x=x+1;
end

% % myfilename = [subj_id, '_', test_id '-counterimsummary.txt']; %%% !!!!! need to define the bits that this file logs.
% % x=1;
% % while exist(myfilename, 'file')
% %     myfilename = [subj_id, '_', test_id '-counterimsummary_', num2str(x), '.txt'];    %add a number to end of filename if it already exists
% %     x=x+1;
% % end

fid = fopen(datafilename, 'wt');       %opens file for writing results

%% experiment variables
trialn = 40; %fourty trials per block (20 also works well, needs to be divisible by four
match = [.50 .90 .10 .90 .30 .70 .30 .70 .10 .50];  % order of block conditions (doesn't vary by Pp. but trials within gets randomised)
% levels for p(match) above are arranged so there is 2 blocks for each p-level, and ~one of each possible change in level:  
% steps: na +40 -80 +80 -60 +40 -40 +40 -60 +40 (missing a step of +60) no steps of 0% or -/+ 20% to keep 'volititly high'
blockn = length(match); %number of blocks

vidsO = {'OF1', 'OM1', 'OF2', 'OM2'}; % Video names '0F#' open action, female hand; 'CM#' close action, male hand 1 = 1000ms delay, 2 = 2000ms delay
vidsC = {'CF1', 'CM1', 'CF2', 'CM2'};

ITI = 2; % <----- !!!! make variable 'jittered' for fMRI !!!!! e.g.  ITI =[2, 4, 6, 8];
delay = [1, 1, 2, 2]; % in seconds, matches with vids arrays
viddur = [2, 2, 3, 3]; % expected duration of videos, matches with vids array above
CueDur = 1.500; % duration of prep cue
% Int1 = 12.000;  % interval before 1st trial (s) - so that 1st slices aren't during task
% Int2 = 10.000;   % interval after ISI after last trial (s) - so last slices aren't taken during task

%response keys
KbName('UnifyKeyNames'); % makes sure key names used will work across PC and mac etc
scanner_key = KbName('5%'); % !!! NB scanner key is removed from Keys within the WaitandMonitor fx so that 5% aren't logged as responses
%escape_key = KbName('ESCAPE'); % include so that you can always quite by pressing 'esc'
response_key=KbName('space'); % change for fMRI to button box '1!'


Keys=[scanner_key, response_key];

% EEG trigger stuff
trigger.length =5  ;   % duration for the eeg trigger ms
trigger.port = hex2dec('D050') ; % parallel port address
trigger.ioObj = io32;% create an instance of the io32 object; was io64 but changed to io32 for Matlab2012b32-bit (needed for eyetracker)
status = io32(trigger.ioObj);       % initialize the system driver
io32(trigger.ioObj,trigger.port,0);    % set port to 0 to start

% get details for each trial and each block using 'formtrials.m' to build them

for a = 1:blockn %for each block
    block(a) = formtrials(match(a),trialn, vidsO, vidsC, delay); %this will make block a struct variable, so each (a) will be each block
end
for bb= 1:blockn % write the p(match) for each block - check order.
    block(bb).match = match(bb);
end

save(matfilename, 'block')  % save trail details so far incase of crash
fprintf(fid, 'Subject: %s', subj_id);     %write subject code into header for log file

%-----------------------------------------------------------------------------------------
%% EYETRACKER STUFF
fname = [subj_id, '_eyetrack_b'];
dataDirectory = [cd, filesep, 'eyetrackerlogs'];   

MON.num = 1; %(0 = main display, windows menubar; 1= secondary monitor)
   
profile.setupName = int8( 'DRP_custom' ); % a profile name
profile.stimX = int32(355); % Visible Screen width [mm]  MEASURED for station1
profile.stimY = int32(284); % Visible Screen height [mm] MEASURED for station1
profile.redStimDistHeight = int32(10); % Vertical distance RED-m to stimulus screen [mm]  MEASURED for station1
profile.redStimDistDepth = int32(45); % Horizontal distance RED-m to stimulus screen [mm]  MEASURED for station1
profile.redInclAngle = int32(22); % off horizontal RED-m inclination angle [degree]  MEASURED for station1

mon.ref = 120; % 120 - classroom; 60 office

Screen('Preference', 'SkipSyncTests', MON.num); % Psychtoolbox           
iview_calibrate_validate_DRP; % calibrate and validate!
% sca % screen closed for my convenience         

%%%% Possible solutation if needed - calibrate with inbuilt software then
%%%% use these 2 lines to start turnon eyetracker. 
% REDm_info = SMI_Redm_Init_DP( profile ); % starts iviewX software server and initiates data structures.
% connected = SMI_Redm_ConnectEyetracker(REDm_info, [ fname '\' fname '.txt' ] );


% % start recording
% 
% calllib('iViewXAPI', 'iV_ClearRecordingBuffer'); % clear recording buffer
% calllib('iViewXAPI', 'iV_StartRecording'); % start recording

% within experiment send triggers like so:            
% SMI_Redm_SendMessage( num2str( TRIALNUM ) )
% list of triggers used here:
%   SMI_Redm_SendMessage( [num2str(a) , '_START'] ) % block start e.g. 1_START, 2_START etc
%   SMI_Redm_SendMessage( [num2str(a) '_' num2str(i) '_', 'FIX'] ) %  fixation e.g. 1_1_FIX (first block,first trial) 1_2_FIX (first block, 2nd trial)
%   SMI_Redm_SendMessage( [num2str(a) '_' num2str(i) '_C', num2str(block(a).trial(i).cuetrig)] ) % Cue e.g. 1_1_C11 = block,trial1, open cue (11 for open, 12 for close)
%   SMI_Redm_SendMessage( [num2str(a) '_' num2str(i) '_V', num2str(block(a).trial(i).vidtrig)] ) % Video e.g. 1_1_V21 =block,trial1, open video  (21 for open, 22 for close)
%------------------------------------------------------------------------------------

%------------------------------------------------------------------------------------




%% open PTB, preload videos - Init_psychtoolbox.m debug option?
% Initialize with unified keynames and normalized colorspace:
% PsychDefaultSetup(2) % 2 = the AssertOpenGL command, KbName('UnifyKeyNames') and imply the execution of Screen('ColorRange', window, 1, [], 1); immediately after and whenever

window = init_psychtoolbox; %define and open windows within init_PTB function

%% Start experiment
%     DrawFormattedText(window, 'Please wait, scanner starting', 'Center', 'Center', [225 255 255]);      % write text in centre of screen, colour white
%     Screen('Flip', window);
% add ScannerStart time log; use Int1 for delay -> WaitforScanner function %%%% <---- !!!! fMRI version
%%% !! use WaitforScanner and manually type '5%' in to get start of run
%%% trigger to EEG for ECG traces 
%%%%% Start Scanner Trigger '%5' use this key to label start of run for
%%%%% EEG-ECG triggers too

% get ready to start warning
DrawFormattedText(window, 'Ready to start...?', 'Center', 'Center', [225 255 255]);      % write text in centre of screen, colour white
Screen('Flip', window);
WaitSecs(2);

%KEY press needed to continue to start trial 1
 Screen('Flip',window) % flip to blank screen
        RespKeys = Keys(2:end); % redefine Keys to exclude scanner_key ('5%' key number 41)?
        Pressed=ones(1, length(RespKeys)); % set to 'ones' first means key must be detected as released before registers as pressed again
        StopNow = 0;
        PressedKey = NaN;
        PressTime = NaN;
        while (StopNow == 0) % conditions for loop to continue: will only stop with StopNow = 1
            [~, KeyTime, KeyPressed] = KbCheck;
            for x=1:length(RespKeys)
                if KeyPressed(RespKeys(x)) == 1 && Pressed(x) == 0      % new key press
                    PressTime = KeyTime;
                    WriteLog(fid, 0, 0, 'StartKeyPress', PressTime, KbName(RespKeys(x)));  % !!! problem that this also logs all scanner_key (5)
                    PressedKey = RespKeys(x);
                    Pressed(x)=1;
%                     EEG trigger for KEY PRESS = 999
%                     io32(trigger.ioObj, trigger.port, 999); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0);
%                     WriteLog(fid, 0, 0, 'StartKeyTrig', GetSecs, num2str(999)); % log the trigger 
        
                    StopNow=1;  % force loop to stop on detecting first button press
                elseif KeyPressed(RespKeys(x)) == 0 && Pressed(x) == 1  % ensure no keys pressed at start
                    Pressed(x)=0;
                end
            end
        end


%% Running trials for set of blocks (1 run) 
RunOnset = GetSecs;
fprintf(fid, '\nRunOnset: %d', RunOnset);

io32(trigger.ioObj, trigger.port, 369); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0); % trigger 369 = start of run
WriteLog(fid, 0, 0, 'RstartTrig', GetSecs-RunOnset, num2str(369)); % log EKG trigger start block.
%%% changed to a, i, to 0, 0 

for a = 1:blockn % loop each block
    
    
    BlockTime = GetSecs;
    WriteLog(fid, a, 0, 'Blockstart', BlockTime-RunOnset, ['block ', num2str(a) ' start']);
        %%% changed i to 0
        
    %---------------------------% start EYETRACKER recording

    calllib('iViewXAPI', 'iV_ClearRecordingBuffer'); % clear recording buffer
    calllib('iViewXAPI', 'iV_StartRecording'); % start recording
    
    %--------------------------------------% EYETRACKER TRIGGER
    SMI_Redm_SendMessage( [num2str(a) , '_START'] ) % Eyetracker trigger (text strings no spacing)
    blocktrig = 101*a;
    
    io32(trigger.ioObj, trigger.port, blocktrig); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0); % trigger 101 = start of block
    WriteLog(fid, a, 0, 'BstartTrig', GetSecs-RunOnset, num2str(blocktrig)); % log EKG trigger start block.
    % WriteLog(fid, block, trial, event-type, time, text-detail) % for logging 'events'
    
    
    for i=1:length(block(a).trial) % loop each trail in block(a)
                
        %%%%%%%%%%%%%%%%%%%%%%%%
        % % % FIXATION ITI % % %
        DrawFormattedText(window, '+', 'Center', 'Center', [255 255 255]); % show + for .5 before first trail cue
        FlipTime = Screen('Flip', window);       
        %--------------------------------------% EYETRACKER TRIGGER
        SMI_Redm_SendMessage( [num2str(a) '_' num2str(i) '_', 'FIX'] ); % Eyetracker trigger (text strings no spacing)
        
        % Trigger for fixation = start of each trial with fixation = 111
        io32(trigger.ioObj, trigger.port, 111); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0);
        WriteLog(fid, a, i, 'FixTrig', FlipTime-RunOnset, num2str(111)); % log EKG trigger fixation starts trial
        
        WaitSecs(ITI); % set ITI in parameters at top of script
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % % % PRESENT CUE % % %           
        DrawFormattedText(window, block(a).trial(i).cue,  'Center', 'Center'); % cue as per block.trial structure
        FlipTime = Screen('Flip', window);
        WriteLog(fid, a, i, 'CueOn', FlipTime-RunOnset, block(a).trial(i).cue);% write cue time and type to logfile
        %WriteLog(fid, block, trial, type, time, text)
        
        %-----------% EYETRACKER TRIGGER (using EEG trigger code numbers for cue, 11 for open, 12 for close
        SMI_Redm_SendMessage( [num2str(a) '_' num2str(i) '_C', num2str(block(a).trial(i).cuetrig)] ); % Eyetracker trigger (text strings no spacing)
        
        % EEG trigger for CUE set in formttrials.m = block.trial(a).cuetrig = 11 for open, 12 for close
        io32(trigger.ioObj, trigger.port, (block(a).trial(i).cuetrig)); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0);
        WriteLog(fid, a, i, 'CueTrig', GetSecs-RunOnset, num2str(block(a).trial(i).cuetrig)); % log EKG trigger 11 = 'open' 12 = 'close'
               
        WaitSecs(CueDur);
        
        %%%%%%%%%%%%%%%%%%%%%%%
        % % % PLAY VIDEO  % % %      
        moviefile = [pwd, filesep , 'videos', filesep , block(a).trial(i).vid, '.mov'];
        movieduration =  block(a).trial(i).viddur; 
        VidTrig = (block(a).trial(i).vidtrig);
        VidTrig = VidTrig*10+(a-1); % make EEG triggers 210+block number (open) and 220+block number (close)
        %-----------% EYETRACKER TRIGGER (using EEG trigger code numbers for video,  21 for open, 22 for close
        SMI_Redm_SendMessage( [num2str(a) '_' num2str(i) '_V', num2str(block(a).trial(i).vidtrig)] ); % Eyetracker trigger (text strings no spacing)
        
        [PlayTime, EndTime, ResponseTime, TriggerTime] = PlayMovie_responses(moviefile, VidTrig, movieduration, window, trigger); % FlipTime for first frame of movie - for VideoOn log
        
        % ResponseTime output from PlayMove_responses is relative to the %starttime 
        % log outputs from PlayMovie_responses.m:
        WriteLog(fid, a, i, 'VideoOn', PlayTime-RunOnset, char(block(a).trial(i).vid)); % log writes time relative to run onset
        WriteLog(fid, a, i, 'VideoOff', EndTime-RunOnset, char(block(a).trial(i).vid)); % log writes time relative to run onset
        block(a).trial(i).playdur = EndTime-PlayTime; % actural run time add to block structure
        WriteLog(fid, a, i, 'VidendTrig', TriggerTime-RunOnset, num2str(block(a).trial(i).vidtrig)); % log for EKG trigger for end of movie
        WriteLog(fid, a, i, 'Response', ResponseTime, 'Key released'); % relative to playtime

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % % %  GET RESPONSE TIME  % % %
        
        block(a).trial(i).responded = ResponseTime; % log 'raw' response time recorded by Playmovie_responses and to compare with 'actual duration'
        % label as valid/invlaid and add to block.trial structure 
         
        if isnan(ResponseTime) %check response time isn't a NaN already (= late/ no response)
            disp(' '); disp('late or no response!!!'); disp(' ')
            RT = ResponseTime;
            valid = 0; % not valid
            invalid = 2; % 2 for late, 1 for early, 0 for valid
 
        else %calculate RT relative to stimulus-onset delay
         delay = block(a).trial(i).delay;
         RT = ResponseTime-delay; % Get RT relative to actual moving hand (less the delay in action onset)
         RT = RT*1000; % convert to milliseconds before saving in to block structure
        end
    
        %save RT (should be a number in milliseconds, or a NaN)
        block(a).trial(i).RT = RT; %  add RT to block.trial structure
%         %block(a).trial(i).valid  %%% leave these as placeholders for RT coding/analysis later
%         %block(a).trial(i).invalid
       
        save(matfilename, 'block') % save mat file with responses from this trail % mat file gets overwritten each trail
        disp(' ')
        disp('mat file saved')
        
        % % % PRESS TO START NEXT TRIAL - need to press space bar&hold to continue to fixation and then next trial
        Screen('Flip',window); % flip to blank screen
        RespKeys = Keys(2:end); % redefine Keys to exclude scanner_key ('5%' key number 41)?
        Pressed=zeros(1, length(RespKeys)); % set to 'ones' first means key must be detected as released before registers as pressed again
        StopNow = 0;
        PressedKey = NaN;
        PressTime = NaN;
        while (StopNow == 0) % conditions for loop to continue: will only stop with StopNow = 1
            [~, KeyTime, KeyPressed] = KbCheck;
            for x=1:length(RespKeys)
                if KeyPressed(RespKeys(x)) == 1 && Pressed(x) == 0      % new key press
                    PressTime = KeyTime-RunOnset;
                    WriteLog(fid, a, i, 'Press', PressTime, KbName(RespKeys(x)));  
                    PressedKey = RespKeys(x);
                    Pressed(x)=1;
      
                    StopNow=1;  % force loop to stop on detecting first button press
                elseif KeyPressed(RespKeys(x)) == 0 && Pressed(x) == 1  % ensure no keys pressed at start
                    Pressed(x)=0;
                end
            end
        end
        
        
    end % end of trial loop
    %% End Block
    save(matfilename, 'block') % to be sure it's saved for all blocks
    disp('')
    disp('final mat file saved')
    % %------------------------------------------------------------------------
    % %% EYETRACKER STUFF stop recording & save file

    calllib('iViewXAPI', 'iV_StopRecording');
    fullfilename = [dataDirectory '\' fname num2str(a) '.idf' ]; description = 'description'; user = 'user'; ovr = int32(1);
    calllib('iViewXAPI', 'iV_SaveData', fullfilename, description, user, ovr)
    % %------------------------------------------------------------------------

    endtrig = a*1000; % use block number *1000 e.g block 9 code = 9000
    io32(trigger.ioObj, trigger.port, (endtrig)); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0); %102 for end of block
    WriteLog(fid, a, i, 'BlockendTrig', GetSecs-RunOnset, endtrig); % log EKG trigger for end of each block (##block#)

    %%%% BREAK EVERY 2ND BLOCK
    if a == 2 || a == 4 || a == 6 || a == 8 
        disp('even block so give a BREAK')

        DrawFormattedText(window, ' Well done. Take a brief break...',  'Center', 'Center'); % End of Block message
        FlipTime = Screen('Flip', window);
        WriteLog(fid, a, i, 'Blkend', FlipTime-RunOnset, ['Block ', num2str(a), 'finished']);
        
        input('Ready to continue? Press ENTER: ','s');
        DrawFormattedText(window, 'Ready for the next block...' ,  'Center', 'Center'); % GetReady for next block
        Screen('Flip', window); % buffer time with '+' before next block starts
        WaitSecs(2);
   end      

%     end

end % end of block loop
%% End Run & close display window
DrawFormattedText(window, 'Task complete, well done!',  'Center', 'Center'); % End of run message
FlipTime = Screen('Flip', window);

io32(trigger.ioObj, trigger.port, 963); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0); % trigger 963 = start of run
WriteLog(fid, a, i, 'RunendTrig', GetSecs-RunOnset, (num2str(963))); % log EKG trigger for end of each block (##block#) 

WaitSecs(2);
WriteLog(fid, a, i, 'Runend', FlipTime-RunOnset, ['Block ', num2str(a), 'finished']);
disp(['Run ended at: ' ,num2str(FlipTime), 'run time (mins) was: ', num2str((FlipTime-RunOnset)/60)])

%%%% Save fid and close it

%close things
Screen('CloseAll')
ShowCursor

% %------------------------------------------------------------------------
% %% EYETRACKER STUFF % moved this inside block loop to save per block.
% % stop recording
% 
% calllib('iViewXAPI', 'iV_StopRecording');
% fullfilename = [dataDirectory '\' fname '.idf' ]; description = 'description'; user = 'user'; ovr = int32(1);
% calllib('iViewXAPI', 'iV_SaveData', fullfilename, description, user, ovr)
% %--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NOTES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Need GStreamer to play videos - check setup with PlayMoviesDemo.m 
