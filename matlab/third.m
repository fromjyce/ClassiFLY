% Define parameters
f_c = 10e9; % Carrier frequency (10 GHz)
lambda = 3e8 / f_c; % Wavelength
sampling_rate = 12e3; % Sampling rate in Hz (12 ksps)
dwell_time = 0.5; % Dwell time in seconds
num_samples = dwell_time * sampling_rate;

% Time Vector
t = (0:num_samples-1) / sampling_rate;

% Object Parameters for Drone
num_blades = 4; % Number of blades for drone
v_blade = 30; % Blade rotation rate in rps (more realistic)

% Object Parameters for Bird
num_wings = 2; % Number of wings for bird
v_wing = 2; % Wing beat rate in Hz (more realistic)

% Generate Micro-Doppler for Drone (Rotating Blades)
omega_blade = 2 * pi * v_blade; % Angular velocity
vr_blade = 0.2 * sin(omega_blade * t); % Radial velocity
doppler_shift_blade = 2 * vr_blade / lambda;
signal_blade = cos(2 * pi * f_c * t);
received_signal_blade = signal_blade .* (1 + 0.1 * cos(omega_blade * t)) .* cos(2 * pi * (f_c + doppler_shift_blade)) + 0.2 * randn(size(signal_blade));

% Generate Micro-Doppler for Bird (Flapping Wings)
omega_wing = 2 * pi * v_wing; % Wing beat frequency
vr_wing = 0.05 * sin(omega_wing * t); % Radial velocity
doppler_shift_wing = 2 * vr_wing / lambda;
signal_wing = cos(2 * pi * f_c * t);
received_signal_wing = signal_wing .* (1 + 0.05 * cos(omega_wing * t)) .* cos(2 * pi * (f_c + doppler_shift_wing)) + 0.2 * randn(size(signal_wing));

% FFT Analysis Function
function [power_spectrum, f] = compute_fft(signal, sampling_rate)
    N = length(signal);
    Y = fft(signal);
    f = (0:N-1) * (sampling_rate / N);
    power_spectrum = abs(Y).^2 / N;
    f = f(1:floor(N/2)); % Keep only positive frequencies
    power_spectrum = power_spectrum(1:floor(N/2)); % Keep only positive frequencies
end

% Compute FFT for Drone and Bird
[power_spectrum_blade, f_blade] = compute_fft(received_signal_blade, sampling_rate);
[power_spectrum_wing, f_wing] = compute_fft(received_signal_wing, sampling_rate);

% Convert frequency to velocity
v_blade = (f_blade * lambda) / 2;
v_wing = (f_wing * lambda) / 2;

% Plot Power Spectrum
figure;
subplot(2,1,1);
plot(f_blade, 10*log10(power_spectrum_blade));
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title('Power Spectrum - Drone');

subplot(2,1,2);
plot(f_wing, 10*log10(power_spectrum_wing));
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title('Power Spectrum - Bird');

% Spectrogram Analysis Function
function plot_spectrogram(signal, sampling_rate)
    window_size = 128;
    overlap = 120;
    nfft = 1024;
    [S, F, T] = spectrogram(signal, window_size, overlap, nfft, sampling_rate);
    imagesc(T, F, 10*log10(abs(S)));
    axis xy;
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title('Spectrogram');
    colorbar;
end

% Plot Spectrogram for Drone and Bird
figure;
subplot(2,1,1);
plot_spectrogram(received_signal_blade, sampling_rate);
title('Spectrogram - Drone');

subplot(2,1,2);
plot_spectrogram(received_signal_wing, sampling_rate);
title('Spectrogram - Bird');
