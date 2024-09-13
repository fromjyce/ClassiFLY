% Simulation Parameters
range = 10; % Range in meters
dwell_time = 0.5; % Dwell time in seconds
sampling_rate = 12000; % Sampling rate in Hz (12 ksps)
num_rotors = 4; % Number of rotors
blades_per_rotor = 2; % Number of blades per rotor
rotation_rate = 56; % Blade rotation rate in rps
blade_length = 0.1; % Blade length in meters
radar_cross_section = 0.3; % Radar cross section in m^2
frequency = 10e9; % Radar frequency in Hz (10 GHz)
transmit_power = 70.79e-3; % Transmit power in Watts (70.79 mW)
gain_tx = 22; % Transmit gain in dB
gain_rx = 19; % Receive gain in dB
noise_figure = 1.7; % Receiver noise figure in dB
c = 3e8; % Speed of light in m/s

% Derived Parameters
lambda = c / frequency; % Wavelength

% Time vector
t = 0:1/sampling_rate:dwell_time-1/sampling_rate;

% Generate a continuous waveform signal
signal = cos(2 * pi * frequency * t);

% Blade velocity
velocity_blades = rotation_rate * blade_length / 2; % m/s

% Simulate Doppler shift
doppler_shift = 2 * velocity_blades / lambda; % Frequency shift in Hz

% Apply Doppler shift to the signal
doppler_signal = cos(2 * pi * (frequency + doppler_shift) * t);

% Add noise
noise = randn(size(doppler_signal)) * 0.1; % Adjust noise level as needed
received_signal = doppler_signal + noise;

% Perform FFT
n = length(received_signal);
fft_signal = fft(received_signal);
f = (0:n-1)*(sampling_rate/n); % Frequency vector

% Plot the frequency response
figure;
plot(f, abs(fft_signal));
title('Frequency Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% Generate the spectrogram
window_size = 128; % Adjust as needed
overlap = 120; % Adjust as needed
spectrogram(received_signal, window_size, overlap, [], sampling_rate, 'yaxis');
title('Spectrogram');
