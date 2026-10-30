# MoonMel Product Specification

[中文](../zh/PRODUCT.md)

## Positioning

MoonMel is a MoonBit-native audio feature extraction library with a verifiable STFT, Mel, Log-Mel and MFCC pipeline. It makes established audio-analysis operations available through MoonBit packages and compilation targets.

The intended users are MoonBit developers integrating audio features and hackathon judges inspecting the implementation and reproducible results. Visualization and feature preparation for downstream classifiers are intended uses; a complete classifier or speech recognizer is not included. The repository demonstrates feature extraction, not adoption by an independent downstream application.

## Core value

1. **MoonBit integration**: DSP algorithms are implemented in MoonBit, with a unified facade and layered packages. This is an independently maintained library, not an official standard library.
2. **Shared computation**: `analyze` computes one STFT and filterbank, then derives Mel, Log-Mel and MFCC matrices.
3. **Inspectable evidence**: Deterministic core cases are compared with librosa under explicitly aligned parameters. Advanced algorithms have separate validation limits.
4. **Local demonstration**: The browser demo executes generated MoonBit JavaScript in a Web Worker. Analysis does not require an audio-upload service. This does not establish a general privacy or latency guarantee.

## Targets and demonstration

| Target | Current scope |
| --- | --- |
| JS | Library compilation target and the actual engine used by the browser demo |
| WASM / WASM-GC | Library compilation targets covered by CI; the current demo does not execute these artifacts |
| Native | Core library and example target covered by CI; browser transport is excluded |

The [online demo](https://1zhouhaoran1.github.io/MoonMel/) supports synthetic signals, PCM WAV input, parameter changes, matrix inspection and JSON/CSV export. Microphone capture uses AudioWorklet and analyzes rolling windows; it is distinct from the library's incremental streaming extractor.

## Core capabilities

| Module | Scope and conventions |
| --- | --- |
| Framing | Periodic/symmetric Hann, Hamming, Blackman and rectangular windows; centered short windows; reflect padding when centered |
| STFT | Radix-2 or arbitrary-length Bluestein transforms; `floor(n_fft / 2) + 1` one-sided bins; configurable spectrum power |
| Mel | Slaney/HTK triangular filters and optional Slaney area normalization |
| Log-Mel | dB, natural log or log10; configured floor/reference and dB clipping |
| MFCC | DCT-II, with configurable orthonormal scaling |
| WAV | RIFF format-tag 1 integer PCM 8/16/24/32-bit; mono downmix or preserved channels |

Resampling, streaming, spectral descriptors and other implemented extensions are listed in the [roadmap](ROADMAP.md). Availability is not a claim of whole-library numerical equivalence or standards compliance.

## Evidence and completion boundaries

1. **Reproducible core**: `moon run examples/basic --target js` analyzes a one-second signal and reports STFT/Mel/Log-Mel/MFCC shapes. The four-target CI checks, builds, tests and runs the example.
2. **Scoped reference comparison**: The [recorded report](../../tools/reference/parity_report.json) covers eight deterministic cases against librosa 1.0.0, NumPy 2.5.3 and SciPy 1.18.1. It checks all Mel/Log-Mel/MFCC cells and up to 64 indexed STFT bins per frame, with `atol=rtol=1e-7`; the recorded maximum absolute error is about `2.3e-12`.
3. **Explicit conventions**: The reference aligns periodic Hann, reflect padding, float64 Slaney filters and orthonormal DCT-II. Different library defaults can produce different results.
4. **Performance boundary**: There is no comparable-device competitor benchmark or fixed latency guarantee. Browser timing covers feature computation, JSON serialization/parsing and worker-side preparation; it excludes startup, transfer and rendering.

The core deliverable is a reusable extraction API, a working example/demo and reproducible checks. Production suitability and compliance of advanced algorithms require further evidence; see the [health report](HEALTH.md).

## Non-goals and release status

- Full ASR/model inference or a model-compatible frontend inferred solely from the Whisper-size framing preset.
- Lossy codec implementations such as MP3, AAC or Opus; resampling is already implemented.
- Cloud AI services or a claim to replace the entire librosa/Meyda/Essentia.js ecosystem.
- Distribution runs through mooncakes.io, source checkout, GitHub releases and Pages hosting.
