# MoonMel Engineering Roadmap

[English](./ROADMAP.md) | [中文说明](../zh/ROADMAP.md)

This document tracks planned milestones and feature expansions for MoonMel.

---

## Milestones

### Phase 1: 0.1.0 MVP (Current — 2026 Hackathon)
- [x] Pure MoonBit in-place Radix-2 Cooley-Tukey FFT.
- [x] Periodic and symmetric Hann windowing with reflect boundary padding.
- [x] Slaney Mel scale triangular filterbank with area normalization.
- [x] Power-to-dB Log-Mel compression with `amin` and `top_db` dynamic range protection.
- [x] Orthogonal DCT-II and MFCC feature extraction.
- [x] Pure MoonBit PCM WAV decoder (8-bit, 16-bit, stereo to mono).
- [x] Numerical parity verification against Python `librosa 1.0.0` (15/15 passed).
- [x] Layered decoupled package hierarchy (`src/core/types`, `src/dsp/*`, `src/features/*`, `src/codec/*`).
- [x] Interactive browser playground with Vite and TailwindCSS.

---

### Phase 2: 0.2.0 Algorithmic Expansions
- [x] **Delta & Delta-Delta Coefficients**: First and second temporal cepstral derivatives.
- [x] **Pre-emphasis & De-emphasis Filters**: High frequency spectral compensation and exact inverse reconstruction.
- [x] **RMS & Frame Energy Extraction**: Time-domain and spectral frame root-mean-square energy.
- [x] **High-Fidelity Audio Resampler**: Bandlimited windowed-sinc antialiasing and fast linear interpolation.
- [x] **Streaming Feature Extraction**: Rolling-buffer streaming extraction for live audio (StreamingExtractor).
- [x] **Live Microphone Input**: Real-time microphone capture via Web Audio API with animated spectrogram.
- [x] **Spectral Descriptors**: Spectral Centroid, Spectral Rolloff, Spectral Flatness, and Zero-Crossing Rate (ZCR).
- [x] **Multi-Channel Extraction**: Parallel processing for multichannel arrays and spatial acoustics (ILD & IPD).

---

### Phase 3: 0.3.0 Vectorization, Chroma & Arbitrary FFT
- [x] **12-Semitone Chroma STFT (Chromagram)**: Pitch class extraction, Gaussian filterbanks, and L1/L2/Max frame normalizations.
- [x] **Arbitrary-length Padded FFT / RFFT**: Automatic zero-padding eliminating $2^k$ input size restrictions.
- [ ] **WebAssembly 128-bit SIMD**: SIMD acceleration for butterfly operations and filter projection.
- [ ] **Bluestein's FFT Algorithm**: Fast-convolution discrete Fourier transform for arbitrary prime lengths.
- [ ] **Polyphase Resampler**: High-fidelity Sinc-based audio resampling engine.

---

### Phase 4: 1.0.0 Production Ecosystem Release
- [ ] Official release to Mooncakes package registry.
- [ ] Interoperability wrappers for ONNX Runtime Web and Transformers.js.
- [ ] Standardized feature extraction pipelines for open-source speech models (Whisper, Wav2Vec2).
