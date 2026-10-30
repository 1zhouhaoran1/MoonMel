# MoonMel Engineering Roadmap

[中文](../zh/ROADMAP.md)

This roadmap separates implementation status from validation and release work. The first tagged release is v0.1.0; subsequent changes are recorded in the [changelog](../../CHANGELOG.md). The groups below are capability inventories, not claims that v0.2.0 or v0.3.0 has been released.

Version 0.1.6 combines six development increments. See the [development series](DEVELOPMENT_SERIES.md) for the changes and local evidence.

## Implemented core

- [x] Framing/windows/reflect padding, radix-2 and arbitrary-length Bluestein FFT, STFT and inverse STFT.
- [x] Slaney/HTK Mel, configurable log compression and DCT-II MFCC with shared analysis intermediates.
- [x] PCM 8/16/24/32-bit integer WAV decoding, channel-preserving entry point, layered packages, unified facade and runnable examples.
- [x] Eight deterministic core reference cases, four-target CI and a browser demo running generated MoonBit JS in a Web Worker.

The [parity report](../../tools/reference/parity_report.json) checks all Mel/Log-Mel/MFCC cells and up to 64 indexed STFT bins per frame. It is not whole-library certification. WASM/WASM-GC are compilation targets; they are not the current browser engine.

## Implemented extensions

| Family | Available behavior and boundary |
| --- | --- |
| Delta, filtering, energy | Repeated HTK deltas with nearest-edge padding, pre/de-emphasis, time-domain frame energy and RMS |
| Resampling | Linear, windowed-sinc, rational-factor polyphase and exact-length paths; no SciPy-default-filter parity claim |
| Streaming | Complete frames, hop gaps, checked chunks, aligned Mel/Log-Mel/MFCC and frame concatenation; dB clipping remains per batch |
| Normalization | Offline utterance row-wise CMVN, optional variance normalization; no online-window or complete-model frontend claim |
| Browser audio | WAV playback and AudioWorklet microphone capture; microphone analysis uses rolling offline windows |
| Spectral/multichannel | Centroid, rolloff, flatness, ZCR, per-channel extraction and ILD/IPD; no parallel-execution guarantee |
| Chroma/CQT | Pitch-class projection/normalization and direct CQT kernels |
| HPSS/contrast | Median masks and empirical peak/valley quantiles, with documented margin and unit conventions |
| Onset/tempo | Spectral flux, SuperFlux, local peak picking, autocorrelation tempogram and BPM estimation |
| Speech features | LPC/LPCC, residuals, YIN pitch and formants |
| Loudness/effects | K-weighting, loudness gates, LRA, oversampled peak estimation and time/pitch effects; no complete standards-compliance or perceptual certification |

These implementations have unit/regression coverage but not the same external reference coverage as the core pipeline. See the [health report](HEALTH.md) for algorithm-specific limits.

## Next evidence priorities

- [ ] Add one independently useful downstream example based on a maintainer-confirmed need, using real audio and a reproducible expected outcome.
- [ ] Expand external reference signals and parameter coverage for advanced features; add a compliance suite before making loudness-standard claims.
- [ ] Establish reproducible device/input/parameter benchmarks before claiming latency targets or competitor rankings.
- [ ] Measure streaming allocation and clipping behavior before promising real-time deployment properties.

## Deferred or exploratory work

- [x] Publish to Mooncakes: version 0.1.0 released on 2026-10-28.
- [ ] Evaluate WASM browser execution and SIMD using measurements; retain the current JS engine until an alternative is implemented and verified.
- [ ] Evaluate model-specific frontends/adapters only against an explicit model contract and end-to-end checks. Whisper-size framing alone is insufficient.

No future version or completion date is promised by this inventory.
