# PredictAutoIm_Exptask
This repo includes the code, stimuli and example test logfiles for an experiment on automatic imitation behaviour under different conditions of predictability. 

* Psychtoolbox based experiment manipulating the likelihood of Stimulus-Response Congruence (SRC) in an action observation-execution task. 
* Task is based on our previously published fMRI task (Campbell, Mehrkanoon & Cunninton, 2018, Neuropsychologia) but modified here to have changing ratios of congruent to incongruent trials over 10 hidden blocks with the likelihood of a congruent trial being either: 0.1, 0.3, 0.5, 0.7 or 0.9 (i.e. unpreditable or moderatly-highly predictable contexts). These are 'hidden' in that not explicitly cued so any learning of the changing regularities is implicit.
* Stimuli provided are in the 'videos.zip' and are 6 clips of 2 actors (male/female, both caucasian) making simple hand gestures. Only the hand and wrist of the actor is in frame agaist a black background. Each clip is edited to begin with a static frame of the hand resting flat, for either 1 or 2 seconds delay before the movement occurs. 
* The task script randomises stimuli (male/female/open/close/1sec/2sec) and the cued action (open/close) across the trials and blocks, while the relationship between cued and observed actions is probabilitically manipulated in a block-wise fashion.

Campbell, Mehrkanoon & Cunninton, 2018, Neuropsychologia https://www.sciencedirect.com/science/article/pii/S0028393218300435



## Experimental paradigm script: video clips with reaction-time measured by key-press/release.
 1) MATLAB2018+   
 2) Psychtoolbox 3  http://psychtoolbox.org/     
 3) GStreamer https://gstreamer.freedesktop.org/data/pkg/osx/1.16.0/

## basic task instruction:
"Start the trail by resting your fingers on the space-key. after a '+' is displayed for a moment, a word cue will appear for each trial, this will be either 'open' or 'close'. When the video of a hand starts to move on screen, as quickly as possible perform the cued action (opening hand or closing hand gesture) regardless of what the hand on screen is doing." 

Note: no explicit instruction is given about the changing likelihoods across blocks or that there are even blocks within the task design.

For analysis see PredictAutoIm_HGF: Analysis focuses on computational modelling of precision weighted learning to provide insight into the behavioural effects (reaction time differences between congruent and incongruent trials), and comparing Rescorla-Wagner (RW) to hierachical perceptual-response models that incorporate beliefs about levels of uncertainty (Hierachical Gaussain Filter). HGF implemented with TAPAS toolbox: see https://github.com/translationalneuromodeling/tapas 
