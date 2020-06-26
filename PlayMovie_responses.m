 function [StartTime, EndTime, ResponseTime, TriggerTime] = PlayMovie_responses(moviefile, VidTrig, movieduration, window, trigger) % FlipTime for first frame of movie - for VideoOn log       
%  edited to include triggers for EKG via BioSemi EEG system
% MEJC: function to play movies from scratch, based on PTB SimpleMovieDemo.m  IT WORKS!
% inputs: moviename, windowdowrect
% response recording added by David Lloyd - simple check Keys and output
% all..



% % following were defined in here to test it out: (but will come from calling this fx in the main script)
% moviename = [pwd, '/videos/OM1.mov'];
% windowdowrect = []; % [] = default
% movieduration = 2; % secs
% refrate = 60; % Hz  - frames per second
% screenid = max(Screen('Screens'));
% window = init_psychtoolbox;
% % !! also need to remove 'screen close all at bottom when called from exp script!

iframe = 0; % index to mark first frame and get StartTime for the movie
refrate = 60; %%%%????? got 75 hertz from control-panel, display advanced settings

% Open movie file:
movie = Screen('OpenMovie', window, moviefile);

KeyArray = ones( (movieduration +1) * refrate  , 2); % preallocating the memory of the array (for every screenrefresh during movie +1sec extra worth)
% set to ones so that when the key is lifted that's the first 0 and this accurately reflects responses

GoTime = GetSecs; % timer to get movieduration

% Start playback engine:
Screen('PlayMovie', movie, 1);
% Select screen for display of movie:

% Playback loop: Runs until end of movie or keypress:
while GetSecs-GoTime < movieduration % play movie for the expected duration, or until last frame
    % Wait for next movie frame, retrieve texture handle to it
    tex = Screen('GetMovieImage', window, movie);
    
    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop and end movie
        break;
    end
    
    % Draw the new texture immediately to screen:
    Screen('DrawTexture', window, tex);
    % Update display:
    DrawFormattedText(window, '+', 'Center', 'Center', [0 0 255]); % blue cross
    FlipTime = Screen('Flip', window);
    
    if iframe == 0 % check if it's for first frame
        StartTime = FlipTime; % get accurate starttime for first frame
    end
    
    iframe = iframe +1;
    
    
    % Release texture:
    Screen('Close', tex);
    
    
    % looking for key release
    [KeyDown, KeyTime ] = KbCheck;
    
    KeyArray(iframe, 1:2) = [KeyDown, KeyTime];
    % keyIsDown, secs, keyCode, deltaSecs] = KbCheck([deviceNumber])
end

% Stop playback:
Screen('PlayMovie', movie, 0);

% % % %% need EEG trigger for end of movie:
TriggerTime = GetSecs; % output this to log trigger on
io32(trigger.ioObj, trigger.port, VidTrig); wait(trigger.length/1000); io32(trigger.ioObj, trigger.port, 0);


% % % io32(ioObj,trig_port,XX);    % EEG trigger ON (XX = movie played = 1 open, 2 close)
% % % pause(trig_length/1000);
% % % io32(ioObj,trig_port,0);    % EEG trigger OFF - back to zero



% Close movie:
Screen('CloseMovie', movie);
EndTime = GetSecs;

Screen('Flip',window) % just to fix occasional last frame being displayed a little too long
Screen('Flip',window) 
%%%Screen('CloseAll');  %%%%% get rid of this for actual thing only needed to debugging this function 
    
%key index (DL coded this)    
k_idx = find(KeyArray(:,1) == 0 , 1); % array of all keys for all frames so find the key that was released

%check that there's a response (if no response make it NaN)

if min(KeyArray(:,1)) == 0
    ResponseTime = KeyArray(k_idx,2)-StartTime; % save the key release time to RT variable for fx output
else
    ResponseTime = NaN;
end

Screen('Flip',window) 

end
