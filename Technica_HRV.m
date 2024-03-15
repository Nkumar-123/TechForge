clc;
clear;
close all;

% Specify the serial port and baud rate
port = "COM8";  % Replace "COM8" with the appropriate port name
baudrate = 115200;  % Set baud rate to 115200
s = serialport(port, baudrate);

% Define ThingSpeak channel ID and write API key
channelID = 2470870; % Replace with your ThingSpeak channel ID
writeKey = 'OPZK8BMT9QWZ0YKI'; % Replace with your ThingSpeak write API key

% Initialize variables for spectral analysis
fs = 125;
f_vlf = [0.0033 0.04];
f_lf = [5.0 8.0];
f_hf = [10 15];
num_samples = 200;  % Number of samples to collect before analysis

% Buffer to accumulate data for spectral analysis
data_buffer = [];

while true
    % Read data from the serial port
    data = readline(s);  % Read a line of data
    
    % Convert the received data to numeric format
    numericData = str2double(data);
    
    % Print input values
    disp("Received data: " + data);
    
    % Check if numericData is a valid number
    if ~isnan(numericData)
        % Calibrate the data to the range [-1, 1]
        calibratedData = (2 * numericData / 4095) - 1; % Adjust calibration as needed
        
        % Print calibrated values
        disp("Calibrated data: " + num2str(calibratedData));
        
        % Append the received data to the buffer
        data_buffer = [data_buffer, calibratedData];
    else
        % Handle NaN values (optional)
        disp("Warning: NaN value detected in received data. Skipping.");
    end
    
    % Check if the buffer has enough samples for analysis
    if numel(data_buffer) >= num_samples
        % Perform spectral analysis
        [freq, power] = pwelch(data_buffer, [], [], [], fs);
        psd = power / (0.5 * length(data_buffer));

        % Find indices for frequency bands
        ind_vlf = find(freq >= f_vlf(1) & freq <= f_vlf(2));
        ind_lf = find(freq >= f_lf(1) & freq <= f_lf(2));
        ind_hf = find(freq >= f_hf(1) & freq <= f_hf(2));

        % Calculate power in each band
        VLF = trapz(psd(ind_vlf));
        LF = trapz(psd(ind_lf));
        HF = trapz(psd(ind_hf));

        % Display the power values
        disp(['VLF Power: ', num2str(VLF)]);
        disp(['LF Power: ', num2str(LF)]);
        disp(['HF Power: ', num2str(HF)]);

        % Send data to ThingSpeak (uncomment if needed)
        % thingSpeakWrite(channelID, 'Fields', [1, 2, 3], 'Values', [VLF, LF, HF], 'WriteKey', writeKey);

        % Reset the buffer
        data_buffer = [];
    end

    % Check if the serial port object is still valid
    if ~isvalid(s)
        break;
    end
end

% Close the serial port
delete(s);  % Delete the serial port object
clear s;