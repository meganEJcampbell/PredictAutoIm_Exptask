function block = formtrials(match,trialn,vidsO,vidsC,delay)
%% Function for forming a 'block' variable that will hold information for individual trials.
% Input variables: 
%  match = the probability of instruction-stimulus matching
% (e.g. 0.9 would be 90% matching open/open close/close)
% trialn = number of trials *per block* - must be divisible by 4!
% orginal by Chase April 2017; edited by Megan 9/05/17 to suit fMRI prediction of SRC study

% Output variable:
% block = struct containing all trials for each experimental block.
% block.trial(a) = each individual trial (a) within a block
% block.trial(a).cue = the cue ('open' or 'close') for trial (a)
% block.trial(a).go = the go cue ('open' or 'close') for trial (a)
% block.trial(a).src = stimulus response compatibility 'match'/'mismatch'
% block.trial(a).cond = condition type / trigger code
%   11 = open cue, open stim;        12 = open cue, close stim;
%   21 = close cue, open stim;       22 = close cue, close stim;
% block.trial(a).vid = the video played (determined by .go and pulled from list of video names 'vids'
% block.trial(a).delay = delay between hand appearing and action commencing (either 1s or 2s)
% block.trial(a).viddur - expected duration of stimulus (delay +1 sec movement)
% %%% ADDED trail info EEG triggers for EKG & preallocation for RT variables
% block.trial(a).cuetrig = 11 for open, 12 for close
% block.trial(a).vidtrig = 21 for open, 22 for close -> end of video playback(called within PlayMovie_responses.m)
% block.trial(a).RT = []; %  
% block.trial(a).valid = [];
% block.trial(a).invalid = [];


%% Trial n check
A = trialn/4; B=round(A); C= A==B; %checking if trialn/4 is an integer
if C==0; 
    disp('WARNING - NUMBER OF TRIALS NOT DIVISIBLE BY FOUR. TRIALSETUP FAILED') 
    return %cancels script
end

%% calculate trial numbers depending on 'match' variable (the probability of matching stimuli)
triala1=match*trialn; %find number of trials that will match
triala=round(triala1); %round if not an integer
if triala1~=triala, disp('WARNING - number of trials not a fraction of validity probability; rounding trial numbers'); end %display error message
trialb=trialn-triala; %find number of trials that will not match

%% define trials
for a=1:triala/2, %for half the matching trials
    block.trial(a).cue='open'; block.trial(a).go='open'; %open/open
    block.trial(a).src='match'; block.trial(a).cond=11; %trial info

end
for a=a+1:a+(triala/2), %for the other half
    block.trial(a).cue='close'; block.trial(a).go='close'; %close/close
    block.trial(a).src='match'; block.trial(a).cond=22; %trial info
end
for a=a+1:a+(trialb/2), %for half the non-match trials
    block.trial(a).cue='open'; block.trial(a).go='close'; %open/close
    block.trial(a).src='mismatch'; block.trial(a).cond=12; %trial info
end
for a=a+1:a+(trialb/2), %for other half
    block.trial(a).cue='close'; block.trial(a).go='open'; %close/open
    block.trial(a).src='mismatch'; block.trial(a).cond=21; %trial info
end

%% add videos to trails
% need an index to select from list of videos e.g.  vidsO =   'OF1'  'OM1'  'OF2'  'OM2'
ii = trialn/2;
stim_idx = [ones(ii/4,1)', ((ones(ii/4,1))+1)' , ((ones(ii/4,1))+2)' , ((ones(ii/4,1))+3)', ones(ii/4,1)', ((ones(ii/4,1))+1)' , ((ones(ii/4,1))+2)' , ((ones(ii/4,1))+3)'];
% array of length= half of trialn, of 1s, 2s, 3s, and 4s, to use to call 1st, 2nd, 3rd, 4th video name of a given
% type (4 open and 4 close videos, made from 2 delays and 2 actors' hands)
% one half of trials used to call open vids;  other half used to call close vids
for a = 1:trialn
    if  strcmp(block.trial(a).go ,'open')
        block.trial(a).vid = vidsO{stim_idx(a)};  
        block.trial(a).delay = delay(stim_idx(a));
        block.trial(a).viddur = 1+delay(stim_idx(a)); % each movie = (delay + 1 sec clip)
        
    elseif strcmp(block.trial(a).go , 'close')
        block.trial(a).vid = vidsC{stim_idx(a)};
        block.trial(a).delay = delay(stim_idx(a));
        block.trial(a).viddur = 1+delay(stim_idx(a));
    end
end

%% add trigger codes for close/open cues and videos & preallocate [] for RT/valid/invalid variables
for a = 1:trialn 
    % block.trial(a).cuetrig = 11 for open, 12 for close    
    if strcmp(block.trial(a).cue ,'open') % cues
       block.trial(a).cuetrig = 11;
    elseif strcmp(block.trial(a).cue , 'close')
       block.trial(a).cuetrig = 12;
    end
end
% block.trial(a).vidtrig = 21 for open, 22 for close -> end of video playback(called within PlayMovie_responses.m)
for a = 1:trialn
    if strcmp(block.trial(a).go ,'open') % videos
        block.trial(a).vidtrig = 21;
    elseif strcmp(block.trial(a).go , 'close')
        block.trial(a).vidtrig = 22;
    end
    % preallocate empty cells for RT, valid/invalid - entered trial by trail when exp runs
    block.trial(a).responded = []; % Nan or number as output from Playmovie_responses.m
    block.trial(a).RT = []; % is valid responses times in milliseconds
    block.trial(a).valid = [];
    block.trial(a).invalid = [];
end



%% pseudo randomise according to rule - no more than three identical trials in a row
rule=0; %starts out false
while rule==0; %while false
    rule=1; %true until proven false

    
    trialc=ShuffleIt(block.trial, 2); %shuffle trial order using shuffle function
    for a=4:length(trialc), %go through the shuffled trials
        if trialc(a).cond==trialc(a-1).cond && trialc(a).cond==trialc(a-2).cond && trialc(a).cond==trialc(a-3).cond, %if all four trials are identical
            rule=0; %if there are four identical trials in a row, rule is broken - restart loop
        end
    end
end

block.trial=trialc; %assign shuffled trials into to the block variable (videos within blocks will be pseudo-random but block-order consistent)


end
% help Shuffle
%   [Y,index] = Shuffle(X)
%  
%   Randomly sorts X.
%   If X is a vector, sorts all of X, so Y = X(index).
%   If X is an m-by-n matrix, sorts each column of X, so
%  	for j=1:n, Y(:,j)=X(index(:,j),j).
%  
%   Also see SORT, Sample, Randi, and RandSample.


% function [ Y I ] = shuffle( X , DIM )
% %SHUFFLE    Shuffles elements.
% %   For vectors, SHUFFLE(X) shuffles the elements of X.
% %   For matrices, SHUFFLE(X) shuffles the rows of X.
% %   For N-D arrays, SHUFFLE(X) shuffles along the first non-singleton
% %   dimension of X.
% %
% %   SHUFFLE(X,DIM) shuffles along the dimension DIM. If DIM is 0,
% %   then all elements of X are shuffled linearly (independently of
% %   any dimension).
% % 
% %   [Y,I] = SHUFFLE(X,DIM) also returns an index vector I.
% %   If X is a vector, then Y = X(I).
% %   If X is a matrix and DIM=1, then Y = X(I,:).
% %
% %   Examples:
% %         X = [1 2 3; 4 5 6; 7 8 9]
% %         X =
% %              1     2     3
% %              4     5     6
% %              7     8     9
% %
% %         [Y,I] = shuffle(X)
% %         Y =
% %              7     8     9
% %              4     5     6
% %              1     2     3
% %         I =
% %              3     2     1
% % 
% %         [Y,I] = shuffle(X,2)
% %         Y =
% %              1     3     2
% %              4     6     5
% %              7     9     8
% %         I =
% %              1     3     2
% %   Created: Ankur Jain (encorejane@gmail.com) - 01/30/2010
% %
% 
%     error(nargchk(1,2,nargin));
% 
%     szi = size(X);
%     if nargin < 2, DIM = find(szi,1); end
% 
%     if DIM > numel(szi)
%         Y = X;
%         I = 1;
%         return
%     end
% 
%     if DIM == 0
%         Y = reshape(X(randperm(numel(X))), szi);
%         return;
%     end
% 
%     inds(1:numel(szi)) = {':'};
%     I = randperm(szi(DIM));
%     inds{DIM} = I;
%     Y = X(inds{:});
% end