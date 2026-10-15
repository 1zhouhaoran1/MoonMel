# MoonMel Proposal and Engineering Choices

[中文](../zh/PROPOSAL.md)

## Problem and scope

Audio visualization, speech analysis and sound classifiers consume spectral or cepstral features. Libraries such as [librosa](https://librosa.org/doc/main/api/generated/librosa.feature.mfcc.html), [Meyda](https://meyda.js.org/audio-features) and [Essentia.js](https://mtg.github.io/essentia.js/) provide established references for this problem.

MoonMel implements a scoped MoonBit-native path from PCM to STFT, Mel, Log-Mel and MFCC. Its value proposition is integration through MoonBit packages and targets, with inspectable numerical checks. This proposal does not establish that the MoonBit ecosystem has no alternatives, or that MoonMel outperforms them.

## Engineering choices

| Decision | Reason and boundary |
| --- | --- |
| Implement DSP algorithms in MoonBit | Expose ordinary MoonBit APIs across supported targets without a foreign DSP library; this does not remove toolchain or browser-glue dependencies |
| Use layered packages | Separate core types, DSP, codecs, feature stages, orchestration, facade and browser transport; enforce dependency direction with the architecture checker |
| Reuse intermediates | Share STFT and filterbank in `analyze`; reuse numerical buffers where implemented, without a zero-allocation claim |
| Keep reference tools separate | Use Python libraries for development-time comparisons rather than the production extraction path |

The repository is MIT-licensed. Reference sources and redistributed assets are recorded in the [third-party notices](../../THIRD_PARTY_NOTICES.md). Dependency decisions do not require unverified claims about other projects' performance or licensing obligations.

## Numerical reference

The current [report](../../tools/reference/parity_report.json) records eight deterministic core cases against librosa 1.0.0, NumPy 2.5.3 and SciPy 1.18.1. Parameters explicitly align periodic Hann, reflect padding, float64 Slaney filters and orthonormal DCT-II. Centering is case-specific; `center=true` alone does not select reflect padding in librosa.

The checker covers all Mel/Log-Mel/MFCC cells and up to 64 indexed STFT bins per frame, with `atol=rtol=1e-7`. It does not certify all configurations, advanced algorithms, model frontends or competitor speed.

## Evidence still needed

The minimal example and browser playground demonstrate reusable features. An independent downstream example based on an actual maintainer need remains to be added. Performance and advanced-algorithm claims need reproducible measurements or external suites before promotion.

Current implementation and release boundaries are maintained in the [product specification](PRODUCT.md), [health report](HEALTH.md) and [roadmap](ROADMAP.md).
