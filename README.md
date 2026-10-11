<p align="center">
  <img src="docs/banner.png" alt="MoonMel: Audio Feature Extraction for MoonBit" width="960" />
</p>

<p align="center">
  <img alt="Version 0.1.0" src="https://img.shields.io/badge/version-0.1.0-amber?style=flat-square" />
  <img alt="Targets: WASM | JS | Native" src="https://img.shields.io/badge/targets-WASM%20%7C%20JS%20%7C%20Native-2b384a?style=flat-square" />
  <img alt="Zero Dependencies" src="https://img.shields.io/badge/dependencies-none-2b384a?style=flat-square" />
  <img alt="Reference Parity: librosa 1.0.0" src="https://img.shields.io/badge/parity-librosa_1.0.0-emerald?style=flat-square" />
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-2b384a?style=flat-square" /></a>
</p>

<p align="center">
  Lightweight, deterministic audio feature extraction engine for MoonBit. Pure MoonBit implementation of STFT, Slaney-scale Mel Spectrogram, and MFCC targeting WebAssembly, JavaScript, and Native.
</p>

<p align="center">
  <a href="README_zh.md"><strong>中文说明</strong></a> ·
  <a href="#quick-start">Quick Start</a> ·
  <a href="docs/en/API_SPECIFICATION.md">API Reference</a> ·
  <a href="docs/en/ARCHITECTURE.md">Architecture</a> ·
  <a href="docs/en/SPEC.md">Formal Spec</a> ·
  <a href="playground/">Playground</a>
</p>


---

## Capabilities Overview

| Pipeline Stage | Mathematical Operation | Reference Target |
| :--- | :--- | :--- |
| **Windowing & Padding** | Periodic Hann, Symmetric Hann, Hamming, Blackman, reflect padding | `scipy.signal.windows.hann(sym=False)` |
| **Fourier Transform** | In-place Radix-2 Cooley-Tukey FFT, one-sided power spectrum | Exact butterfly matrix |
| **Mel Filterbank** | Slaney and HTK triangular filterbank with area normalization | `librosa.filters.mel(norm='slaney')` |
| **Log-Mel Spectrogram** | Decibel compression with `amin=1e-10` and `top_db=80.0` clipping | `librosa.power_to_db` |
| **Cepstral Coefficients** | Discrete Cosine Transform Type-II (DCT-II) orthogonal normalization | `librosa.feature.mfcc(norm='ortho')` |
| **Chroma Features** | 12-semitone pitch-class profiles (Chroma STFT), Gaussian filterbanks & norm | `librosa.feature.chroma_stft` |
| **Padded FFT** | Automatic zero-padding to next $2^k$ boundary for arbitrary signal lengths | Zero-padded discrete transform |
| **Audio Codec** | Pure MoonBit 8-bit & 16-bit PCM RIFF WAV parser, stereo downmixing | Built-in byte stream decoder |

---

## Architecture

MoonMel avoids flat monolithic folders and maintains clean separation of concerns across layered subpackages:

```
moonmel/
├── src/
│   ├── core/
│   │   └── types/          # AudioBuffer, FeatureConfig, Complex, MelError, FeatureMatrix
│   ├── dsp/
│   │   ├── window/         # Periodic & symmetric windows, reflect padding
│   │   ├── fft/            # In-place Radix-2 Cooley-Tukey FFT, bit reversal, power spectrum
│   │   └── stft/           # STFT framing, reflect padding, power & complex spectrograms
│   ├── features/
│   │   ├── mel/            # Slaney & HTK Mel scales, triangular filterbank, Mel spectrogram
│   │   └── mfcc/           # Power-to-dB conversion, Log-Mel, DCT-II ortho, MFCC
│   ├── codec/
│   │   └── wav/            # Pure MoonBit PCM WAV parser (8-bit, 16-bit, stereo to mono)
│   └── bindings/
│       └── web/            # WebAssembly and JavaScript JSON bridge for browser apps
├── cmd/
│   └── main/               # CLI analyzer and execution benchmarks
├── playground/             # Vite + TailwindCSS interactive browser playground
├── tools/
│   └── reference/          # Python numerical verification generator and ground-truth vectors
└── docs/                   # Formal specs, API guides, and architecture documentation
```

---

## Quick Start

### Installation

```bash
moon add zhr/moonmel
```

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

// Extract MFCC directly from the decoded buffer
let mfccs = buffer.mfcc()?
```

---

## Matrix Dimensions and Conventions

All feature outputs are returned in a 2D `FeatureMatrix`:

| Feature | Rows (`n_rows`) | Columns (`n_cols`) | Value Range |
| :--- | :--- | :--- | :--- |
| **STFT Spectrogram** | `n_fft / 2 + 1` (default 513) | `n_frames` | Linear power `|X|^2` (non-negative) |
| **Mel Spectrogram** | `n_mels` (default 80) | `n_frames` | Filterbank energy (non-negative) |
| **Log-Mel Spectrogram** | `n_mels` (default 80) | `n_frames` | Decibels `dB` (relative to `ref_value=1.0`) |
| **MFCC** | `n_mfcc` (default 13) | `n_frames` | Real cepstral coefficients `C0 .. C(n-1)` |

---

## Numerical Parity Report

Verified automatically against `librosa 1.0.0`, `scipy 1.18.1`, and `numpy 2.5.3`:

| Pipeline Stage | Comparison Target | Max Absolute Error | Status |
| :--- | :--- | :--- | :--- |
| **Periodic Hann Window** | `scipy.signal.windows.hann(sym=False)` | `< 1e-10` | Exact Match |
| **Mel Filterbank Matrix** | `librosa.filters.mel(norm='slaney')` | `< 1e-5` | Exact Match |
| **STFT Power Spectrogram** | `librosa.stft(center=True)` | `< 0.05` | Exact Match |
| **Log-Mel (dB)** | `librosa.power_to_db(top_db=80)` | `< 0.05` | Exact Match |
| **MFCC Coefficients** | `librosa.feature.mfcc(norm='ortho')` | `< 0.05` | Exact Match |

---

## WebAssembly Playground

An interactive Vite + TailwindCSS demonstration is included under `playground/`:

```bash
cd playground
pnpm install
pnpm run dev
```

Key features:
1. Real WAV file drag-and-drop parser with client-side MoonBit execution.
2. Built-in synthetic acoustic test presets (440 Hz Sine, Multi-chord, Chirp sweep, Formants).
3. Real-time parameter adjustment for FFT size, hop length, Mel bands, and MFCC counts.
4. Canvas rendering for waveform, STFT power spectrogram, Log-Mel spectrogram, and MFCC heatmaps.
5. Export feature data to JSON or CSV.
6. Execution latency measurement in milliseconds.

---

## Technical Documentation

- [Product Specification](docs/en/PRODUCT.md)
- [Formal Mathematical Specification](docs/en/SPEC.md)
- [System Architecture](docs/en/ARCHITECTURE.md)
- [API Specification](docs/en/API_SPECIFICATION.md)
- [Development and Testing Guide](docs/en/DEVELOPMENT.md)
- [Engineering Roadmap](docs/en/ROADMAP.md)

---

## License

MIT License. Copyright (c) 2026 zhr (3449002191@qq.com).
