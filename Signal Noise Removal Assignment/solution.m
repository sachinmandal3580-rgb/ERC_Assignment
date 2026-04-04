%Load the audio
[x, Fs] = audioread('Signals_corrupted.wav');
N = length(x);
t = (0:N-1) / Fs;

%Time Domain Frequency waveform 
figure;
plot(t, x);
xlabel('Time (s)'); ylabel('Amplitude');
title('Stage 1 — Corrupted Signal: Time Domain');
grid on;

%STAGE-1
%FFT
X  = fft(x, N);
f  = (0:N-1) * (Fs/N);
X_mag = abs(X(1:N/2+1))/N*2;

%frequency domain plot
figure;
plot(f(1:N/2+1), X_mag);
xlabel('Frequency (Hz)'); ylabel('Magnitude ');
title('Stage 1 — Corrupted Signal: FFT');
grid on;


%STAGE-2
%Amplitude Demodulation
%Carrier frequency calculation
[~, peak] = max(X_mag);
f_c = f(peak);
fprintf('Dominant energy at: %.1f Hz\n', f_c);

%amdemod through mul by carrier wave
t = (0:N-1)'/ Fs;
carrier  = cos(2*pi*f_c*t);
x_mixed  = x .* carrier;   % frequency shift back to baseband

%Filtering using low pass filter
cutoff_freq = 4000;  %Speech lives up to ~4000 Hz, so use a 4000 Hz cutoff.

% 6th order Butterworth low-pass filter
[b_lp, a_lp] = butter(6, cutoff_freq / (Fs/2), 'low');

% filtfilt applies the filter forwards and backwards for zero phase distortion
x_baseband = filtfilt(b_lp, a_lp, x_mixed);

X_base_fft = fft(x_baseband, N);
X_base_mag = abs(X_base_fft(1:N/2+1))/N*2;
figure;
plot(f(1:N/2+1), X_base_mag);
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('Stage 2 — Baseband Recovered Signal: FFT');
xlim([0, 5000]); % Zoom in on speech range
grid on;

%STAGE-3
%Notch filters for spikes removal

search_idx = f(1:N/2+1) < 4500; %to remove the spikes around 4000 Hz freq
f_search = f(search_idx);
mag_search = X_base_mag(search_idx);

% Define a dynamic threshold (spikes will stand out highly above the mean)
threshold = mean(mag_search) + 6 * std(mag_search);
[pks, locs] = findpeaks(mag_search, 'MinPeakHeight', threshold, ...
                        'MinPeakProminence', threshold/2);
spike_freqs = f_search(locs);
fprintf('Stage 3: Found %d potential interference spikes.\n', length(spike_freqs));

x_clean = x_baseband;
for i = 1:length(spike_freqs)
    f_notch = spike_freqs(i);
    fprintf('   -> Applying notch filter at: %.1f Hz\n', f_notch);
    w0 = f_notch / (Fs/2);  % Normalized frequency
    bw = w0 / 35;           % Bandwidth (Quality factor Q ~ 35 for sharp notch)
    [b_notch, a_notch] = iirnotch(w0, bw);
    x_clean = filtfilt(b_notch, a_notch, x_clean);
end

% 4th order Butterworth high-pass filter at 50 Hz
[b_hp, a_hp] = butter(4, 50 / (Fs/2), 'high');
x_clean = filtfilt(b_hp, a_hp, x_clean);

% Spike-free FFT
X_clean_fft = fft(x_clean, N);
X_clean_mag = abs(X_clean_fft(1:N/2+1))/N*2;
figure;
plot(f(1:N/2+1), X_clean_mag);
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title('Stage 3 — Spike-Free Signal: FFT');
xlim([0, 5000]);
grid on;

% Time-domain waveform
figure;
t_clean=(0:length(x_clean)-1)/Fs;
plot(t_clean, x_clean);
xlabel('Time (seconds) '); ylabel('Frequency');
title('Stage 3 - frequency waveform');
grid on;

disp('Playing recovered audio...');
sound(x_clean, Fs);

audiowrite('Recovered_signal.wav',x_clean,Fs);
disp('Sucessfully Saved!')


