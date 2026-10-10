# MoonMel Product Specification

[English](./PRODUCT.md) | [中文说明](../zh/PRODUCT.md)

This document defines product positioning, target platforms, core feature matrix, acceptance criteria, and non-goals for MoonMel (2026 MoonBit Hackathon).

---

## 1. Product Positioning & Value Proposition

MoonMel is a lightweight, cross-platform audio feature extraction engine written in pure MoonBit. It transforms raw mono PCM audio into foundational machine learning features: Short-Time Fourier Transform (STFT) power spectrograms, Slaney-scale Mel Spectrograms, Log-Mel Spectrograms, and Mel-Frequency Cepstral Coefficients (MFCC).

### Core Values

1. **Ecosystem Foundation**: Provides a production-grade digital signal processing (DSP) standard library for the MoonBit ecosystem.
2. **Edge and Browser Execution**: Computes features completely locally in browser tabs via WebAssembly (WASM), offering zero network latency and complete privacy.
3. **Deterministic & Numerically Verified**: All core mathematical transformations are numerically aligned with Python reference toolchains (`librosa 1.0.0`, `scipy 1.18.1`, `numpy 2.5.3`).
4. **Ergonomic Unified API**: Delivers both an intuitive top-level facade and modular layered subpackages.

---

## 2. Target Platforms

- **WebAssembly (WASM)**: Modern browser runtime and WebAssembly runtimes (Node.js, Wasmtime).
- **JavaScript (JS)**: Standard ES modules (ESM) for straightforward Web frontend bundling.
- **Native**: C / native machine code targets.

---

## 3. Core Capabilities Matrix

| Module | Scope | Algorithmic Conventions |
| :--- | :--- | :--- |
| **Time Domain** | PCM models, framing, windowing, reflect padding | Periodic & Symmetric Hann, Hamming, Blackman; `center=True` boundary reflection |
| **Spectral Analysis** | STFT, one-sided power & magnitude spectrum | In-place Radix-2 Cooley-Tukey FFT, returning $N/2 + 1$ bins |
| **Mel Filterbank** | Slaney and HTK scale triangular filterbanks | Slaney area normalization, linear below 1 kHz, logarithmic above |
| **Log Compression** | Log-Mel spectrogram | Power-to-dB conversion with `amin` floor and `top_db` dynamic range clamping |
| **Cepstral Analysis** | MFCC extraction | Discrete Cosine Transform Type-II with orthogonal normalization (`norm='ortho'`) |
| **Audio Codec** | Pure MoonBit WAV decoding | RIFF 8-bit / 16-bit PCM WAV parser with automatic stereo downmixing to mono |

---

## 4. Quality & Acceptance Boundaries

1. **Zero External C Bindings**: 100% pure MoonBit implementation across all supported compilation targets.
2. **Numerical Parity**: Maximum absolute error against `librosa 1.0.0` stays below 0.05 across all frequency bins and time frames.
3. **Genuine End-to-End Playground**: The interactive web demo executes actual MoonBit compilation output without simulated or mock logic.
4. **Performance Efficiency**: Processing 1 second of 16 kHz audio completes in sub-15ms latency in modern WASM/JS environments.

---

## 5. Non-Goals

The following areas are intentionally out of scope for the MVP:
- Full end-to-end Automatic Speech Recognition (ASR) neural network decoding (e.g., Whisper decoder models).
- Audio resampling or lossy audio codecs (MP3, AAC, Opus).
- Cloud AI API integrations.
