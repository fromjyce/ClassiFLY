% Radar parameters
fc = 10e9;                   % Carrier frequency (Hz)
c = 3e8;                     % Speed of light (m/s)
lambda = c / fc;             % Wavelength (m)
P_tx = 70.79e-3;             % Transmit power (W)
G_tx = 22;                   % Transmit gain (dB)
G_rx = 19;                   % Receive gain (dB)
NF_rx = 1.7;                 % Noise figure (dB)
range = 10;                  % Distance to target (m)
sample_rate = 44.1e3;        % Sampling rate (Hz)
PRF = sample_rate;           % Pulse Repetition Frequency (Hz)
pulse_width = 1 / PRF;       % Pulse width (s)
num_samples = sample_rate * 0.5; % Number of samples for 0.5 seconds

% Drone parameters
num_blades = 4;              % Number of blades per rotor
rotor_speed_rps = 56;        % Rotational speed (revolutions per second)
blade_length = 0.1;          % Blade length (m)
RCS_body = 0.3;              % Radar cross-section of the body (m^2)
velocity_max = 35.2;         % Maximum blade tip velocity (m/s)
doppler_max = 2 * velocity_max / lambda; % Maximum Doppler shift (Hz)

% Create time vector
t = (0:num_samples - 1) / sample_rate;  % Time vector (s)

% Simulate the time-domain radar signal with improved accuracy
signal = zeros(1, num_samples); 
for i = 1:num_samples
    % Blade position factor for Doppler shift (sawtooth to simulate periodic motion)
    blade_pos_factor = sawtooth(2 * pi * rotor_speed_rps * t(i), 0.5); 
    vr = velocity_max * blade_pos_factor; % Blade tip radial velocity
    doppler_shift = 2 * vr / lambda;      % Doppler shift (Hz)
    
    % Add signal contribution from each blade tip with modulated Doppler
    for blade = 1:num_blades
        signal(i) = signal(i) + cos(2 * pi * doppler_shift * t(i) + blade * pi/num_blades);
    end
end

% Short-Time Fourier Transform (Spectrogram)
window_size = 128;       % Window size for spectrogram (adjusted to match reference)
overlap = 120;           % Overlap for spectrogram (adjusted to match reference)
[S, F, T] = spectrogram(signal, window_size, overlap, [], sample_rate, 'yaxis');

% Plot spectrogram
figure;
imagesc(T * 1e3, F, 20 * log10(abs(S)));
axis xy;
title('Microdoppler Signature - Spectrogram');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
colormap('jet');
colorbar;
