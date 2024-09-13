% Define parameters
f_c = 10e9; % Carrier frequency (10 GHz)
lambda = 3e8 / f_c; % Wavelength
sampling_rate = 12e3; % Sampling rate in Hz (12 ksps)
dwell_time = 0.5; % Dwell time in seconds
num_samples = dwell_time * sampling_rate;

% Time Vector
t = (0:num_samples-1) / sampling_rate;

% Object Parameters
num_blades = 4; % Number of blades for drone
num_wings = 2; % Number of wings for bird
v_blade = 56; % Blade rotation rate in rps
v_wing = 5; % Wing beat rate in Hz

% Generate Micro-Doppler for Drone (Rotating Blades)
omega_blade = 2 * pi * v_blade; % Angular velocity
vr_blade = 0.1 * sin(omega_blade * t); % Radial velocity
doppler_shift_blade = 2 * vr_blade / lambda;
signal_blade = cos(2 * pi * f_c * t);
received_signal_blade = signal_blade .* cos(2 * pi * (f_c + doppler_shift_blade)) + 0.1 * randn(size(signal_blade));

% Generate Micro-Doppler for Bird (Flapping Wings)
omega_wing = 2 * pi * v_wing; % Wing beat frequency
vr_wing = 0.1 * sin(omega_wing * t); % Radial velocity
doppler_shift_wing = 2 * vr_wing / lambda;
signal_wing = cos(2 * pi * f_c * t);
received_signal_wing = signal_wing .* cos(2 * pi * (f_c + doppler_shift_wing)) + 0.1 * randn(size(signal_wing));


% FFT Analysis Function
function [power_spectrum, f] = compute_fft(signal, sampling_rate)
    N = length(signal);
    Y = fft(signal);
    f = (0:N-1) * (sampling_rate / N);
    power_spectrum = abs(Y).^2 / N;
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
plot(v_blade, 10*log10(power_spectrum_blade));
xlabel('Velocity (m/s)');
ylabel('Power (dB)');
title('Power Spectrum - Drone');

subplot(2,1,2);
plot(v_wing, 10*log10(power_spectrum_wing));
xlabel('Velocity (m/s)');
ylabel('Power (dB)');
title('Power Spectrum - Bird');

% Spectrogram Analysis Function
% Spectrogram Analysis Function
function plot_spectrogram(signal, sampling_rate, lambda)
    window_size = 128;
    overlap = 120;
    nfft = 1024;
    [S, F, T] = spectrogram(signal, window_size, overlap, nfft, sampling_rate);
    v = (F * lambda) / 2;
    imagesc(T, v, 10*log10(abs(S)));
    axis xy;
    xlabel('Time (s)');
    ylabel('Velocity (m/s)');
    title('Spectrogram');
    colorbar;
end


% Plot Spectrogram for Drone and Bird% Plot Spectrogram for Drone and Bird
figure;
subplot(2,1,1);
plot_spectrogram(received_signal_blade, sampling_rate, lambda);
title('Spectrogram - Drone');

subplot(2,1,2);
plot_spectrogram(received_signal_wing, sampling_rate, lambda);
title('Spectrogram - Bird');

