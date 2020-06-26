REDm_info = SMI_Redm_Init_DP( profile ); % starts iviewX software server and initiates data structures.
connected = SMI_Redm_ConnectEyetracker(REDm_info, [ fname '\' fname '.txt' ] );

if connected
    
    % define the redm environment
    REDm_info = SMI_Redm_SetGeometry(REDm_info);
    
    happy = 0; % happy will be = 1 when get a good calibration
    calibrationCount = 0;
    
    while happy == 0 || calibrationCount < 3
    
        calibrationCount = calibrationCount + 1;
        
        % calibrate eyetracker
        SMI_Redm_CalibrateEyetracker(REDm_info, MON.num) % monitor 2 = test room (REDm_info, monitorID, screensizeX, screensizeY, mode_filename)
        
        % validate eyetracker for use
        [REDm_info, accdata] = SMI_Redm_ValidateEyetracker(REDm_info);
        
        if mean([accdata.deviationLX accdata.deviationRX accdata.deviationLY accdata.deviationRY]) < 1 % in degrees (smaller the more accurate)
            happy = 1;
            disp('good calibration')
            break
        end
        
        if calibrationCount == 3
            disp('poor calibration')
            break
        end
        
    end
    
end

