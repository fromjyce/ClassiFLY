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
num_blades = 2;              % Number of blades per rotor
rotor_speed_rps = 56;        % Rotational speed (revolutions per second)
blade_length = 0.1;          % Blade length (m)
RCS_body = 0.3;              % Radar cross-section of the body (m^2)
velocity_max = 35.2;         % Maximum blade tip velocity (m/s)
doppler_max = 2 * velocity_max / lambda; % Maximum Doppler shift (Hz)

% Create time vector
t = (0:num_samples - 1) / sample_rate;  % Time vector (s)

% Simulate the time-domain radar signal
signal = zeros(1, num_samples); 
for i = 1:num_samples
    % Blade tip radial velocity as sinusoidal function
    vr = velocity_max * sin(2 * pi * rotor_speed_rps * t(i));
    doppler_shift = 2 * vr / lambda;    % Doppler shift (Hz)
    
    % Add signal contribution from each blade tip
    for blade = 1:num_blades
        signal(i) = signal(i) + cos(2 * pi * doppler_shift * t(i));
    end
end

% FFT for power spectral density
N = length(signal);
fft_signal = fftshift(fft(signal));
freq = linspace(-sample_rate/2, sample_rate/2, N);
power_spectral_density = abs(fft_signal).^2 / N;

% Short-Time Fourier Transform (Spectrogram)
window_size = 128;     % Window size for spectrogram
overlap = floor(window_size / 2); % Valid overlap (must be < window_size)
[S, F, T] = spectrogram(signal, window_size, overlap, [], sample_rate, 'yaxis');

% Plot time-domain signal
figure;
subplot(3, 1, 1);
plot(t * 1e3, signal);
title('Simulated Quadcopter Time Signal');
xlabel('Time (ms)');
ylabel('Amplitude');

% Plot power spectral density
subplot(3, 1, 2);
plot(freq, power_spectral_density);
title('Simulated Quadcopter Power Spectral Density');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');

% Plot spectrogram
subplot(3, 1, 3);
imagesc(T * 1e3, F, 20 * log10(abs(S)));
axis xy;
title('Simulated Quadcopter Spectrogram');
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
colormap('jet');
colorbar;

% Adjust simulation parameters for different conditions
window_sizes = [64, 128, 256, 512];
figure;
for idx = 1:length(window_sizes)
    % Ensure valid overlap
    window_size = window_sizes(idx);
    overlap = floor(window_size / 2); % Valid overlap (must be < window_size)
    
    [S, F, T] = spectrogram(signal, window_size, overlap, [], sample_rate, 'yaxis');
    subplot(2, 2, idx);
    imagesc(T * 1e3, F, 20 * log10(abs(S)));
    axis xy;
    title(['Spectrogram with Window Size = ', num2str(window_size)]);
    xlabel('Time (ms)');
    ylabel('Frequency (Hz)');
    colormap('jet');
    colorbar;
end
