# Changelog

[中文](CHANGELOG_zh.md)

## Unreleased

### Fixed

- Delta normalization no longer overflows 32-bit integer squares in wide windows (for example, `width=100001`). The denominator now uses a constant-time floating-point sum-of-squares formula.
- Add regression coverage for wide-window nearest-edge weights and repeated derivative padding, including input preservation.

## [0.1.0] - 2026-10-12

First tagged GitHub release of MoonMel, a pure MoonBit audio feature extraction library.

### Added

- Core STFT, Mel, Log-Mel and MFCC extraction, Slaney/HTK filterbanks and orthonormal DCT-II.
- Radix-2 and arbitrary-length Bluestein transforms, complex STFT/ISTFT, windowing, filters and resampling.
- Energy and spectral descriptors, deltas, streaming, multichannel ILD/IPD, Chroma, CQT and HPSS.
- Onset/tempo, LPC/LPCC, YIN pitch, formants, loudness and time/pitch effects; PCM 8/16-bit WAV decoding.
- A runnable minimal example, bilingual API/architecture/health/acceptance documentation, and four-target CI.

### Changed

- Separate core contracts, DSP framing, feature stages, analysis orchestration, facade and browser transport into explicit layers.
- `analyze` shares one STFT and filterbank across its core outputs; STFT buffers and each matrix's DCT basis are reused.
- Browser modules separate signal generation, worker transport, audio capture/playback and rendering; generated MoonBit JS is refreshed before dev, build and integration tests.
- Replace the brand with ivory/charcoal/vermilion artwork and add an evidence-led, accessible desktop/mobile demo on [GitHub Pages](https://1zhouhaoran1.github.io/MoonMel/).

### Fixed

- Short-window sample alignment, arbitrary-size transform dispatch, odd-size inverse reconstruction and invalid window/config handling.
- Streaming short windows, large-hop gaps, spectrum power, log settings and DCT normalization.
- RIFF/chunk bounds, missing/duplicate WAV format/data and incomplete PCM frames; browser failures now report `success:false` with escaped errors.
- Resampling fractional phase and anti-alias cutoff, LPC/formant coefficient sign, HPSS margins, spectral contrast units, silent tempo and phase-vocoder accumulation/tail interpolation.
- Multichannel metadata/rate mismatches and power-based ILD; browser WAV-loading races, silent heatmap normalization and mobile comparison discoverability.

### Validation

- WASM, WASM-GC and JS each pass 130 tests; Native passes 128 tests, with the two browser-transport tests excluded from Native.
- Five browser-binding integration tests and eight deterministic core numerical cases pass; maximum observed absolute error across checked values is about `2.3e-12`.
- The reference checks all Mel/Log-Mel/MFCC cells and up to 64 indexed STFT bins per frame, using aligned periodic Hann, reflect padding, float64 Slaney filters and orthonormal DCT-II.
- Desktop/mobile flows, worker computation, actual WAV recomputation, exports, error recovery and the published Pages deployment were verified.

### Requirements and scope

- `moonc >= 0.10.14`; the browser toolchain requires Node.js 22.12+ or 24+ and pnpm 11.
- The live demo executes generated JavaScript in a Web Worker; WASM is a library compilation target.
- Eight-case core parity does not imply whole-library equivalence or a competitor speed ranking. Advanced feature compliance remains a research validation boundary.
- GitHub source archives are available with this release. Mooncakes publication remains deferred.

[0.1.0]: https://github.com/1zhouhaoran1/MoonMel/releases/tag/v0.1.0
