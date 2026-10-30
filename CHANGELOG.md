# Changelog

[中文](CHANGELOG_zh.md)

## [0.1.6] - 2026-10-30

This release combines six development increments since 0.1.0. Versions 0.1.1–0.1.5 were internal milestones, not separate published releases. See the [development record](docs/en/DEVELOPMENT_SERIES.md) for validation and boundaries.

### 0.1.6 — Composable frame batches

- Add checked `FeatureMatrix::concat_frames` with independent output storage, shape matching and frame-count overflow protection.
- Add the stereo WAV → streaming MFCC → CMVN example with numerical offline assertions; run both examples in four-target CI.

### 0.1.5 — Offline feature normalization

- Add a layered `features/normalize` package and root `cmvn` API with optional variance normalization, population variance, positive floor, finite-input validation and scaled moment accumulation.

### 0.1.4 — Aligned streaming outputs

- Add atomic checked chunk append, retained-sample inspection and shared Mel/Log-Mel/MFCC batches, preserving existing streaming entry points.

### 0.1.3 — Channel-preserving input

- Add `decode_wav_multichannel` through codec, facade and root, sharing validated layouts with mono decoding.

### 0.1.2 — Wider integer PCM

- Decode 24/32-bit integer PCM with signed full-scale normalization alongside 8/16-bit. Test codec and browser transport; float/extensible encodings remain unsupported.

### 0.1.1 — Engineering checks

- Fix architecture checking after the namespace migration: read `moon.mod`, count current internal imports and exercise negative graph cases. Add CI format and architecture regression gates alongside the 0.10.18/Native repair below.

### Changed

- Normalize source and generated interfaces with the MoonBit 0.10.18 formatter (`Int32`, optional-parameter spelling and layout); formatting and four-target functional checks pass.
- Raise the declared compiler floor to `moonc 0.10.16` and verify the project on `moonc v0.10.18+6c83a7f62`: `moon check --deny-warn`, `moon build --release` and `moon test --deny-warn` pass on wasm, wasm-gc, js and native with no source changes. `tools/dev/activate.ps1` now selects the `latest-20261030` SDK and reads publishing credentials from the environment instead of embedding a token.

### Documentation

- Record the 2026-10-30 acceptance check on moonc 0.10.18, baseline CI, independent Mooncakes package consumption and a fresh eight-case numerical rerun. Update Windows Native instructions and record successful local MSVC checks, release build, 145 tests and example execution after repairing the C++/SDK installation.
- Rewrite the bilingual project proposal for reassessment, acknowledging the shared moon-certified baseline and documenting existing incremental extraction, frame synthesis, antialias resampling and multichannel analysis with pinned comparison sources and scoped test evidence.
- Align bilingual product, proposal, roadmap and documentation indexes with the generated-JS demo and eight-case core reference scope. Remove unsupported production/privacy/latency and competitor claims; distinguish implemented extensions from externally validated behavior and record downstream integration as pending evidence.

### Fixed

- Make the Mooncakes profile switch update the selected `MOON_HOME` SDK so publishing does not retain another account's credentials in the isolated toolchain.
- Remove the Native helper's incompatible MinGW fallback on Windows; let Moon select the supported compiler while preserving explicit caller settings.
- Tempogram candidates now respect inclusive BPM limits using ceiling/floor lag bounds intersected with the analysis window. Empty or unrepresentable lag intervals return no tempo instead of an out-of-range estimate; exact endpoints and tiny finite BPM bounds have regressions.
- SuperFlux filter sizes of one or less now use ordinary spectral flux instead of spreading across neighboring bins and suppressing real increases. Wider-window suppression and degenerate spectrogram shapes retain regression coverage.
- Chroma spectrogram extraction returns errors for non-finite tuning and invalid frequency cutoffs before filterbank access, preventing an out-of-bounds failure. Cutoffs at zero and Nyquist and zero-frame matrix shapes remain supported.
- Spectral rolloff rejects non-finite fractions and values outside `[0, 1]`; spectral flatness rejects non-finite or nonpositive floors. Validation runs before the STFT, with valid endpoint and flat-spectrum regressions.
- YIN keeps pitch, period and voicing confidence consistent when periodic audio is attenuated. CMNDF now normalizes every positive difference sum instead of treating quiet signals as silence; zero-difference frames remain unvoiced.
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
