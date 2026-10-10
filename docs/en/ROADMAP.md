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
- [ ] **Delta & Delta-Delta Coefficients**: First and second temporal cepstral derivatives.
- [ ] **Pre-emphasis High-Pass Filter**: High frequency spectral compensation ($y[n] = x[n] - \alpha x[n-1]$).
- [ ] **Multi-Channel Extraction**: Parallel processing for multichannel arrays.
- [ ] **Streaming Feature Extraction**: Rolling-buffer streaming extraction for live audio.
- [ ] **Live Microphone Input**: Real-time microphone capture via Web Audio API AudioWorklet.

---

### Phase 3: 0.3.0 Vectorization & Arbitrary FFT
- [ ] **WebAssembly 128-bit SIMD**: SIMD acceleration for butterfly operations and filter projection.
- [ ] **Chirp Z-Transform / Bluestein FFT**: Support for arbitrary non-power-of-two FFT sizes.
- [ ] **Polyphase Resampler**: High-fidelity Sinc-based audio resampling engine.

---

### Phase 4: 1.0.0 Production Ecosystem Release
- [ ] Official release to Mooncakes package registry.
- [ ] Interoperability wrappers for ONNX Runtime Web and Transformers.js.
- [ ] Standardized feature extraction pipelines for open-source speech models (Whisper, Wav2Vec2).
