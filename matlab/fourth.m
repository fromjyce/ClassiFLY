f_c = 10e9;
lambda = 3e8 / f_c;
sampling_rate = 12e3;
dwell_time = 0.5;
num_samples = dwell_time * sampling_rate;

t = (0:num_samples-1) / sampling_rate;


num_blades = 4;
v_blade = 30;


num_wings = 2;
v_wing = 2;

omega_blade = 2 * pi * v_blade;
vr_blade = 0.2 * sin(omega_blade * t);
doppler_shift_blade = 2 * vr_blade / lambda;
signal_blade = cos(2 * pi * f_c * t);
received_signal_blade = signal_blade .* (1 + 0.1 * cos(omega_blade * t)) .* cos(2 * pi * (f_c + doppler_shift_blade)) + 0.2 * randn(size(signal_blade));

v_wing_mean = 2;
irregularity_factor = 0.5;

t_variation = sin(2 * pi * 0.5 * t) + irregularity_factor * randn(size(t));
omega_wing = 2 * pi * (v_wing_mean + 0.5 * t_variation);

vr_wing = 0.05 * sin(omega_wing .* t);

doppler_shift_wing = 2 * vr_wing / lambda;
signal_wing = cos(2 * pi * f_c * t);
received_signal_wing = signal_wing .* (1 + 0.05 * cos(omega_wing .* t)) .* cos(2 * pi * (f_c + doppler_shift_wing)) + 0.2 * randn(size(signal_wing));

function plot_spectrogram(signal, sampling_rate)
    window_size = 128;
    overlap = 120;
    nfft = 1024;
    [S, F, T] = spectrogram(signal, window_size, overlap, nfft, sampling_rate);

    F = linspace(-1, 1, length(F));
    T = linspace(0.5, 2.5, length(T));

    imagesc(T, F, 10*log10(abs(S)));
    axis xy;
    xlabel('Time (s)');
    ylabel('Micro-Doppler (Hz)');
    title('Spectrogram');

    caxis([-30 30]);
    colormap(flipud(jet));
    colorbar;
end

figure;
subplot(2,1,1);
plot_spectrogram(received_signal_blade, sampling_rate);
title('Spectrogram - Drone');

subplot(2,1,2);
plot_spectrogram(received_signal_wing, sampling_rate);
title('Spectrogram - Bird');
