# 0.1.1–0.1.6 development series

[中文](../zh/DEVELOPMENT_SERIES.md)

2026-10-30: six development increments are combined into release 0.1.6. Versions 0.1.1–0.1.5 below are internal milestones, not separately published releases. See the [GitHub Release](https://github.com/1zhouhaoran1/MoonMel/releases/tag/v0.1.6) and [Mooncakes](https://mooncakes.io/docs/1zhouhaoran1/moonmel) for publication status.

## Increments

| Increment | Delivery | Checkable evidence |
| --- | --- | --- |
| 0.1.1 | 0.10.18 formatting and Windows Native repair; architecture check reads the module namespace rather than silently matching old zhr paths; CI format and architecture regression gates | Five Node cases: counted imports, upward dependency, cycle, missing package and core isolation |
| 0.1.2 | 24/32-bit integer PCM WAV alongside 8/16-bit, shared bounded layout parsing | Signed extrema, half-scale, least significant bits, incomplete frames, alignment and float rejection; wide-PCM browser binding regression |
| 0.1.3 | decode_wav_multichannel preserves file channel order and sample rate | Opposite-phase stereo channels remain distinct; mono and multichannel entry points agree at all four widths |
| 0.1.4 | Streaming try_push_samples, buffered_samples, pop_features and StreamingFeatures | Non-finite chunks rejected atomically; single-sample chunks agree with offline Mel/Log-Mel/MFCC |
| 0.1.5 | Layered features/normalize package with offline utterance CMVN | Analytic population variance, constant/single/empty inputs, floor, huge finite values, small changes on a large offset, invalid values and input preservation |
| 0.1.6 | FeatureMatrix::concat_frames, WAV→streaming MFCC→CMVN example, bilingual instructions and CI example execution | Independent storage, invalid shapes, frame-count overflow; stereo 1600-sample example asserts streaming/offline 13×17 agreement |

## Reproduce

On this Windows workstation, first run `. ./tools/dev/activate.ps1` for `moonc v0.10.18+6c83a7f62`.

```sh
moon run examples/streaming --target js
node tools/quality/check-architecture.mjs
node --test tools/quality/check-architecture.test.mjs
moon fmt --check
```

Expected example output:

```text
WAV: 2 channels, 1600 samples/channel at 16000 Hz
Streaming/offline MFCC agree: 13 x 17
CMVN: 13 x 17; pending tail: 240 samples
```

Local validation passes: 159 tests each on WASM/WASM-GC/JS and 157 on Windows Native; four-target check/release build and both examples; 11 Node cases (five architecture, six binding); production playground build; the existing eight-case librosa core reference. The architecture checker counts 34 packages and 88 internal imports. New CMVN uses analytic cases and is not covered by the original eight-case librosa report.

## Boundaries

Float and WAVE_FORMAT_EXTENSIBLE are unsupported. Mono decoding still averages channels; preserved channels are for callers needing spatial information. Streaming returns complete frames only, retains overlap in its tail and applies dB clipping per batch. The example uses NaturalLog and generated deterministic audio; it is not evidence of independent downstream adoption.

CMVN uses offline utterance row statistics, not online sliding windows, speaker statistics or a full model frontend. Legacy push_samples still accepts unchecked input; prefer try_push_samples. New APIs require 0.1.6 and are absent from old 0.1.0.
