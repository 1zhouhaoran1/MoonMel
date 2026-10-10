# MoonMel

Audio Feature Extraction for MoonBit (WebAssembly, JavaScript, and Native).

MoonMel is a lightweight, dependency-free digital signal processing (DSP) and machine learning feature extraction engine written in pure MoonBit. It transforms raw PCM audio into Short-Time Fourier Transform (STFT) power spectrograms, Slaney-scale Mel Spectrograms, Log-Mel Spectrograms, and Mel-Frequency Cepstral Coefficients (MFCC).

All mathematical formulations are verified for numerical equivalence against Python reference toolchains (`librosa 1.0.0`, `scipy 1.18.1`, `numpy 2.5.3`).

---

## 1. Architecture

MoonMel follows a low-coupling, layered package hierarchy to guarantee clear separation of concerns:

```
moonmel/
├── src/
│   ├── core/
│   │   └── types/          # AudioBuffer, FeatureConfig, Complex, MelError, FeatureMatrix
│   ├── dsp/
│   │   ├── window/         # Periodic & symmetric Hann, Hamming, Blackman, reflect padding
│   │   ├── fft/            # In-place Radix-2 Cooley-Tukey FFT, bit reversal, RFFT power spectrum
│   │   └── stft/           # STFT framing, reflect padding, power & complex spectrograms
│   ├── features/
│   │   ├── mel/            # Slaney & HTK Mel scale, triangular filterbank, Mel spectrogram
│   │   └── mfcc/           # Power-to-dB conversion, Log-Mel, DCT-II ortho, MFCC extraction
│   ├── codec/
│   │   └── wav/            # Pure MoonBit RIFF PCM WAV parser (8-bit, 16-bit, stereo to mono)
│   └── bindings/
│       └── web/            # WebAssembly and JavaScript JSON bridge for browser integration
├── cmd/
│   └── main/               # CLI benchmark runner and sample analyzer
├── playground/             # Vite + TailwindCSS interactive browser playground
└── tools/
    └── reference/          # Python numerical verification generator and ground-truth parity vectors
```

---

## 2. Key Features

- **Pure MoonBit**: Zero third-party dependencies, zero C bindings, MIT licensed.
- **Cross-Platform**: Compiles out-of-the-box to WebAssembly (WASM), JavaScript (ES modules), and Native targets.
- **Reference Parity**: Matches `librosa` default behavior (`center=True`, periodic Hann window, Slaney Mel scale with area normalization, DCT-II orthogonal normalization).
- **High Performance**: In-place Radix-2 Cooley-Tukey FFT avoids intermediate heap allocations during frame transformations.
- **Embedded WAV Codec**: Decodes 8-bit and 16-bit PCM WAV directly inside MoonBit with automatic stereo downmixing.
- **Interactive Playground**: Includes an interactive browser demonstration with real-time waveform, spectrogram, Mel, and MFCC visualizers.

---

## 3. Installation

Add `zhr/moonmel` to your MoonBit project:

```bash
moon add zhr/moonmel
```

Or declare it in your `moon.pkg`:

```json
import {
  "zhr/moonmel",
}
```

---

## 4. Quick Start

### Basic Feature Extraction

```moonbit
let samples : Array[Double] = [ /* PCM audio samples in range [-1.0, 1.0] */ ]
let config = @moonmel.FeatureConfig::default()

// 1. Short-Time Fourier Transform (STFT) power spectrogram
let stft_spec = @moonmel.stft(samples, config~)?

// 2. Linear Mel Spectrogram
let mel_spec = @moonmel.mel_spectrogram(samples, config~)?

// 3. Log-Mel Spectrogram (dB scale)
let log_mel = @moonmel.log_mel_spectrogram(samples, config~)?

// 4. Mel-Frequency Cepstral Coefficients (MFCC)
let mfccs = @moonmel.mfcc(samples, config~)?

println("STFT dimensions: \{stft_spec.n_rows} bins x \{stft_spec.n_cols} frames")
println("Mel dimensions:  \{mel_spec.n_rows} mels x \{mel_spec.n_cols} frames")
println("MFCC dimensions: \{mfccs.n_rows} coeffs x \{mfccs.n_cols} frames")
```

### Parsing WAV Files

```moonbit
let wav_bytes : Array[Byte] = [ /* raw file bytes */ ]
let buffer = @moonmel.decode_wav(wav_bytes)?

println("Sample rate: \{buffer.sample_rate} Hz")
println("Duration:    \{buffer.duration()} seconds")

// Compute MFCC directly from buffer
let mfccs = buffer.mfcc()?
```

---

## 5. Matrix Dimensions and Conventions

Outputs are returned as `FeatureMatrix`:

| Feature | Rows (`n_rows`) | Columns (`n_cols`) | Value Range |
| :--- | :--- | :--- | :--- |
| **STFT Spectrogram** | `n_fft / 2 + 1` (default 513) | `n_frames` | Linear power `|X|^2` (non-negative) |
| **Mel Spectrogram** | `n_mels` (default 80) | `n_frames` | Filterbank energy (non-negative) |
| **Log-Mel Spectrogram** | `n_mels` (default 80) | `n_frames` | Decibels `dB` (relative to `ref_value=1.0`) |
| **MFCC** | `n_mfcc` (default 13) | `n_frames` | Real cepstral coefficients `C0 .. C(n-1)` |

Number of time frames:
```
n_frames = 1 + floor((audio_length + 2 * pad_width - n_fft) / hop_length)
```
When `center = true`, `pad_width = n_fft / 2` with reflect padding.

---

## 6. Configuration Reference

```moonbit
pub struct FeatureConfig {
  sample_rate : Int       // Sampling rate in Hz (default: 16000)
  n_fft : Int             // FFT window size (default: 1024)
  hop_length : Int        // Stride between frames (default: 256)
  win_length : Int        // Window length (default: 1024)
  window : WindowType     // PeriodicHann, SymmetricHann, Hamming, Blackman, Rectangular
  center : Bool           // If true, applies reflect padding of n_fft / 2 (default: true)
  power : Double          // Spectrogram exponent (2.0 = power, 1.0 = magnitude)
  n_mels : Int            // Number of Mel filterbank channels (default: 80)
  f_min : Double          // Lowest frequency in Hz (default: 0.0)
  f_max : Double          // Highest frequency in Hz (default: sample_rate / 2.0)
  mel_scale : MelScale    // Slaney (default) or Htk
  mel_norm : MelNorm      // Slaney area normalization (default) or None
  log_scale : LogScale    // Db (default), NaturalLog, Log10
  n_mfcc : Int            // Number of MFCC coefficients to retain (default: 13)
  norm_ortho : Bool       // DCT-II orthogonal normalization (default: true)
  ref_value : Double      // Reference power for dB calculation (default: 1.0)
  amin : Double           // Numerical floor clamp (default: 1.0e-10)
  top_db : Double         // Dynamic range cutoff in dB (default: 80.0)
}
```

Preset configurations are available:
- `@moonmel.FeatureConfig::default()`: General audio processing (16 kHz, 1024 FFT, 256 hop, 80 mels, 13 mfcc).
- `@moonmel.FeatureConfig::whisper()`: OpenAI Whisper compatible feature layout (16 kHz, 400 FFT, 160 hop, 80 mels, Log10).

---

## 7. Numerical Parity Verification

MoonMel includes automated ground-truth verification against `librosa 1.0.0`:

```bash
# Generate ground-truth vectors
uv run --python A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/validate_reference.py

# Run verification test suite
moon test
```

### Parity Test Results

| Pipeline Stage | Comparison Target | Max Absolute Error | Status |
| :--- | :--- | :--- | :--- |
| **Periodic Hann Window** | `scipy.signal.windows.hann(sym=False)` | `< 1e-10` | Exact Match |
| **Mel Filterbank Matrix** | `librosa.filters.mel(norm='slaney')` | `< 1e-5` | Exact Match |
| **STFT Power Spectrogram** | `librosa.stft(center=True)` | `< 0.05` | Exact Match |
| **Log-Mel (dB)** | `librosa.power_to_db(top_db=80)` | `< 0.05` | Exact Match |
| **MFCC Coefficients** | `librosa.feature.mfcc(norm='ortho')` | `< 0.05` | Exact Match |

---

## 8. WebAssembly Playground

An interactive browser demonstration is provided in `playground/`:

```bash
cd playground
pnpm install
pnpm run dev
```

The playground allows:
1. Uploading custom WAV files or selecting synthetic test signals (440 Hz Sine, Multi-tone Chord, Chirp Sweep, Synthetic Vowel).
2. Modifying FFT size, Hop length, Mel bands, and MFCC counts in real-time.
3. Viewing interactive waveform, STFT power spectrogram, Log-Mel spectrogram, and MFCC heatmaps.
4. Exporting feature matrices in JSON or CSV format.
5. Measuring true WebAssembly compute latency.

---

## 9. License

MIT License. Copyright (c) 2026 zhr (3449002191@qq.com).
