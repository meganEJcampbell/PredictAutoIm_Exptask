# PredictAutoIm_Exptask
Psychtoolbox based experiment for predictiability effect for automatic imitation behaviour

# PredictAutoIm_HGF
This repo includes the code, stimuli and example test logfiles for an experiment on automatic imitation behaviour under different conditions of predictability. 
## Experimental paradigm script: video clips with reaction-time measured by key-press/release.
 1) MATLAB2018+   2) Psychtoolbox 3  http://psychtoolbox.org/     3) GStreamer https://gstreamer.freedesktop.org/data/pkg/osx/1.16.0/

## basic instruction:
Start the trail by resting your fingers on the space-key. after a '+' is displayed for a moment, a word cue will appear for each trial, this will be either 'open' or 'close'. When the video of a hand starts to move on screen, perform as quickly as possible the cued action (opening hand or closing hand gesture) regardless of what the hand on screen is doing. 


for analysis see PredictAutoIm_HGF: Analysis focuses on computational modelling of precision weighted learning to provide insight into the behavioural effects (reaction time differences between congruent and incongruent trials), and comparing Rescorla-Wagner (RW) to hierachical perceptual-response models that incorporate beliefs about levels of uncertainty (Hierachical Gaussain Filter). HGF implemented with TAPAS toolbox: see https://github.com/translationalneuromodeling/tapas 


