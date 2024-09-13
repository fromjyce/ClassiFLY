f_c = 10e9; % Carrier frequency (10 GHz)
lambda = 3e8 / f_c; % Wavelength
sampling_rate = 1e4; % Sampling rate in Hz (10 kHz)
dwell_time = 0.5; % Dwell time in seconds
dwell_time_t = 30; % Time for bird signal generation
num_samples = dwell_time * sampling_rate;
num_samples_t = dwell_time_t * sampling_rate;

% Time Vectors
t = (0:num_samples-1) / sampling_rate;
t_bird = (0:num_samples_t-1) / sampling_rate;

% Object Parameters for Drone
num_blades = 4; % Number of blades for drone
v_blade = 30; % Blade rotation rate in rps

% Object Parameters for Bird
num_wings = 2; % Number of wings for bird
v_wing = 2; % Wing beat rate in Hz

% Generate Micro-Doppler for Drone (Rotating Blades) with Swerling II
omega_blade = 2 * pi * v_blade; % Angular velocity
vr_blade = 0.2 * sin(omega_blade * t); % Radial velocity
doppler_shift_blade = 2 * vr_blade / lambda;
signal_blade = cos(2 * pi * f_c * t);
received_signal_blade = signal_blade .* (1 + 0.1 * cos(omega_blade * t)) .* cos(2 * pi * (f_c + doppler_shift_blade)) + 0.2 * randn(size(signal_blade));

% Apply MRC to Drone
MRC_blade = 0.5;
received_signal_blade_mrc = MRC_blade * received_signal_blade;

% Generate Micro-Doppler for Bird (Flapping Wings) with Swerling III
omega_wing = 2 * pi * v_wing; % Wing beat frequency
vr_wing = 0.05 * sin(omega_wing * t_bird); % Radial velocity
doppler_shift_wing = 2 * vr_wing / lambda;
signal_wing = cos(2 * pi * f_c * t_bird);
received_signal_wing = signal_wing .* (1 + 0.05 * cos(omega_wing * t_bird)) .* cos(2 * pi * (f_c + doppler_shift_wing)) + 0.2 * randn(size(signal_wing));

% Apply MRC to Bird
MRC_wing = 0.01;
received_signal_wing_mrc = MRC_wing * received_signal_wing;

% Swerling Model Application (Example)
% Apply Swerling II to Drone (a simple approach for demonstration)
swerling2_factor = 1.2; % Example scaling factor
received_signal_blade_swerling2 = swerling2_factor * received_signal_blade_mrc;

% Apply Swerling III to Bird (a simple approach for demonstration)
swerling3_factor = 1.5; % Example scaling factor
received_signal_wing_swerling3 = swerling3_factor * received_signal_wing_mrc;

% Spectrogram Analysis Function
function plot_spectrogram(signal, sampling_rate)
    window_size = 128;
    overlap = 120;
    nfft = 1024;
    [S, F, T] = spectrogram(signal, window_size, overlap, nfft, sampling_rate);

    % Filter frequencies and times according to requirements
    F = linspace(-1, 1, length(F)); % Scale y-axis (micro-Doppler)
    T = linspace(0.5, 2.5, length(T)); % Scale x-axis (time)

    % Generate the spectrogram plot
    imagesc(T, F, 10*log10(abs(S)));
    axis xy;
    xlabel('Time (s)');
    ylabel('Micro-Doppler (Hz)');
    title('Spectrogram');
    
    % Set color limits and color map
    caxis([-30 30]); % Color scale range
    colormap(flipud(jet)); % Red to dark blue colormap
    colorbar;
end

% Plot Spectrogram for Drone and Bird
figure;
subplot(2,1,1);
plot_spectrogram(received_signal_blade_swerling2, sampling_rate);
title('Spectrogram - Drone with Swerling II and MRC');

subplot(2,1,2);
plot_spectrogram(received_signal_wing_swerling3, sampling_rate);
title('Spectrogram - Bird with Swerling III and MRC');
