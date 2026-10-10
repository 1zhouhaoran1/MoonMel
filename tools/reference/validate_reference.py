"""
MoonMel Numerical Reference Validation Generator
Generates reference numerical ground-truth using librosa, scipy, and numpy.
"""

import json
import os
import numpy as np
import scipy.signal
import scipy.fft
import librosa

def generate_reference_data():
    sr = 16000
    n_fft = 1024
    hop_length = 256
    win_length = 1024
    n_mels = 80
    n_mfcc = 13
    f_min = 0.0
    f_max = 8000.0

    print(f"Generating reference vectors with librosa {librosa.__version__}, numpy {np.__version__}, scipy {scipy.__version__}...")

    # 1. Periodic Hann Window
    hann_periodic = scipy.signal.windows.hann(win_length, sym=False).tolist()

    # 2. Slaney Mel Filterbank Matrix
    mel_fb = librosa.filters.mel(
        sr=sr,
        n_fft=n_fft,
        n_mels=n_mels,
        fmin=f_min,
        fmax=f_max,
        htk=False,
        norm="slaney"
    ) # shape: (80, 513)

    # 3. Test Signal 1: 440 Hz Pure Sine Wave (0.25s = 4000 samples)
    t = np.arange(4000) / sr
    sine_440 = np.sin(2 * np.pi * 440.0 * t)

    # STFT Power Spectrogram: |STFT|^2 with center=True, periodic Hann
    stft_complex = librosa.stft(
        sine_440,
        n_fft=n_fft,
        hop_length=hop_length,
        win_length=win_length,
        window="hann",
        center=True
    )
    stft_power = np.abs(stft_complex) ** 2

    # Mel Spectrogram
    mel_spec = librosa.feature.melspectrogram(
        y=sine_440,
        sr=sr,
        n_fft=n_fft,
        hop_length=hop_length,
        win_length=win_length,
        window="hann",
        center=True,
        power=2.0,
        n_mels=n_mels,
        fmin=f_min,
        fmax=f_max,
        htk=False,
        norm="slaney"
    )

    # Log-Mel Spectrogram (dB)
    log_mel = librosa.power_to_db(mel_spec, ref=1.0, amin=1e-10, top_db=80.0)

    # MFCC (norm='ortho', dct_type=2)
    mfcc_coeffs = librosa.feature.mfcc(
        S=log_mel,
        sr=sr,
        n_mfcc=n_mfcc,
        dct_type=2,
        norm="ortho"
    )

    # Select canonical probe points for numerical assertion:
    # Check shape:
    # stft_power: (513, 16)
    # mel_spec: (80, 16)
    # log_mel: (80, 16)
    # mfcc_coeffs: (13, 16)
    print("STFT shape:", stft_power.shape)
    print("Mel shape:", mel_spec.shape)
    print("LogMel shape:", log_mel.shape)
    print("MFCC shape:", mfcc_coeffs.shape)

    # Spot checks across time and frequency:
    # Frame 8 (middle of the 440Hz tone)
    # 440 Hz bin index in FFT (sr=16000, n_fft=1024): 440 * 1024 / 16000 = 28.16 -> bins 28 and 29
    ref_pack = {
        "metadata": {
            "sr": sr,
            "n_fft": n_fft,
            "hop_length": hop_length,
            "win_length": win_length,
            "n_mels": n_mels,
            "n_mfcc": n_mfcc,
            "f_min": f_min,
            "f_max": f_max,
            "librosa_version": librosa.__version__,
            "numpy_version": np.__version__,
            "scipy_version": scipy.__version__
        },
        "hann_window_samples": [hann_periodic[0], hann_periodic[1], hann_periodic[256], hann_periodic[512], hann_periodic[1023]],
        "mel_filterbank_probes": {
            # Filter 0 (lowest mel band): peak and bounds
            "filter_0_max": float(np.max(mel_fb[0])),
            "filter_0_argmax": int(np.argmax(mel_fb[0])),
            "filter_10_max": float(np.max(mel_fb[10])),
            "filter_10_argmax": int(np.argmax(mel_fb[10])),
            "filter_40_max": float(np.max(mel_fb[40])),
            "filter_40_argmax": int(np.argmax(mel_fb[40])),
        },
        "sine_440_probes": {
            "n_frames": int(stft_power.shape[1]),
            "stft_frame_8_bin_28": float(stft_power[28, 8]),
            "stft_frame_8_bin_29": float(stft_power[29, 8]),
            "stft_frame_8_bin_0": float(stft_power[0, 8]),
            "mel_frame_8_band_6": float(mel_spec[6, 8]),
            "mel_frame_8_max_band": int(np.argmax(mel_spec[:, 8])),
            "logmel_frame_8_max": float(np.max(log_mel[:, 8])),
            "logmel_frame_8_min": float(np.min(log_mel[:, 8])),
            "mfcc_frame_8": [float(x) for x in mfcc_coeffs[:, 8]]
        }
    }

    out_path = os.path.join(os.path.dirname(__file__), "reference_vectors.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(ref_pack, f, indent=2)

    print(f"Reference vectors written to {out_path}")
    print("MFCC frame 8 vector:", ref_pack["sine_440_probes"]["mfcc_frame_8"])

if __name__ == "__main__":
    generate_reference_data()
