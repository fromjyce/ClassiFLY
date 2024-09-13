function [imfs, residual] = lmd(signal, max_imfs)
    % LMD - Local Mean Decomposition
    % signal: Input signal
    % max_imfs: Maximum number of IMFs to extract
    
    % Parameters
    n = length(signal);
    imfs = zeros(max_imfs, n);
    
    % Initial signal
    current_signal = signal;
    
    % Local Mean Decomposition
    for i = 1:max_imfs
        % Find local means using cubic spline interpolation
        local_mean = (smooth(current_signal, 5) + smooth(current_signal, 10)) / 2;
        
        % Compute IMF
        imfs(i, :) = current_signal - local_mean;
        
        % Update signal
        current_signal = local_mean;
        
        % Stop if residual is too small
        if norm(current_signal) < 1e-6
            imfs = imfs(1:i, :);
            break;
        end
    end
    
    % Residual is the last component
    residual = current_signal;
end

function smoothed_signal = smooth(signal, window_size)
    % Smooth signal using moving average
    smoothed_signal = filter(ones(1, window_size) / window_size, 1, signal);
end


function features = extract_features(signal, sampling_rate)
    % Extract features from the signal using the given extraction methods
    
    % Parameters
    [imfs, residual] = lmd(signal, 10);
    
    % Extracting features from IMFs
    P1 = imfs(1, :); % First IMF
    Pr = residual; % Residual
    
    % Feature 1: Number of zero crossings
    F11 = sum(abs(diff(sign(P1)))) / 2;
    
    % Feature 2: Normalized signal energy
    E1 = sum(P1.^2);
    Er = sum(Pr.^2);
    E = E1 + Er;
    F12 = [E1 / E, Er / E];
    
    % Feature 3: Standard deviation
    F13 = [std(P1), std(Pr)];
    
    % Feature 4: Entropy
    En1 = entropy(P1);
    Enr = entropy(Pr);
    F14 = [En1, Enr];
    
    % Feature 5: Peaks related feature
    [~, locs] = findpeaks(P1);
    num_peaks = length(locs);
    F15 = [num_peaks];
    
    % Combine features
    features = [F11, F12, F13, F14, F15];
end

function H = entropy(signal)
    % Calculate entropy of a signal
    p = abs(signal) / sum(abs(signal));
    H = -sum(p .* log2(p + eps));
end

% Parameters
sampling_rate = 12e3;
dwell_time = 0.5;
num_samples = dwell_time * sampling_rate;
t = (0:num_samples-1) / sampling_rate;

% Given received signals (example data)
received_signal_blade = cos(2 * pi * 10e9 * t) + 0.2 * randn(size(t));
received_signal_wing = cos(2 * pi * 10e9 * t) + 0.2 * randn(size(t));

% Apply LMD and extract features
[imfs_blade, residual_blade] = lmd(received_signal_blade, 10);
[imfs_wing, residual_wing] = lmd(received_signal_wing, 10);

features_blade = extract_features(received_signal_blade, sampling_rate);
features_wing = extract_features(received_signal_wing, sampling_rate);

% Display features
disp('Features for Drone (Blade):');
disp(features_blade);

disp('Features for Bird (Wing):');
disp(features_wing);

% Plot IMFs
function plot_imfs(imfs, title_str)
    num_imfs = size(imfs, 1);
    figure;
    for i = 1:num_imfs
        subplot(num_imfs, 1, i);
        plot(imfs(i, :));
        title(sprintf('%s - IMF %d', title_str, i));
    end
end

% Plot for Blade and Wing Signals
plot_imfs(imfs_blade, 'Drone (Blade)');
plot_imfs(imfs_wing, 'Bird (Wing)');
