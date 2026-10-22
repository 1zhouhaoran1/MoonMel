# MoonMel Project Proposal

[中文](../zh/PROPOSAL.md)

## Basic information

- Project: MoonMel
- Participant and contact: Zhou Haoran (zhr), 3449002191@qq.com
- Repository: https://github.com/1zhouhaoran1/MoonMel
- Category: MoonBit audio feature extraction, incremental analysis and spectral transformation library
- Port/reference status: MoonBit implementations and engineering adaptations of established DSP algorithms; references, ecosystem overlap and implementation differences are detailed below

## Project overview

MoonMel is an audio-analysis library for MoonBit. Its baseline covers PCM WAV decoding and STFT, Mel, Log-Mel and MFCC extraction. Beyond that baseline, it implements a persistent incremental extractor, phase-preserving complex STFT and ISTFT, phase-vocoder time/pitch effects, resampling with antialias filtering, and channel-preserving ILD/IPD analysis. DSP algorithms are implemented in MoonBit and exposed through layered packages and a unified facade for JS, WASM/WASM-GC and Native.

The project acknowledges that the existing MoonBit library `moon-certified` already covers WAV, framing, power spectra, Mel, MFCC, Delta and linear resampling. This resubmission does not rely on Slaney scales, normalization, parameter defaults or boundary compatibility as the principal independent scope. It documents the implemented incremental processing, frame-level analysis/synthesis, antialias resampling and multichannel analysis, together with their use cases and validation limits. It claims neither original DSP algorithms nor whole-library numerical equivalence, production certification or performance leadership.

## Core scope

- **Shared feature pipeline**: Configurable STFT, Slaney/HTK Mel, Log-Mel and DCT-II MFCC; `analyze` reuses one STFT and filterbank for multiple outputs. This overlaps the existing ecosystem and serves as the integration baseline, not a standalone independence claim.
- **Incremental extraction and state**: `StreamingExtractor` exposes push, ready-frame counts, consuming Mel/MFCC pops and reset. It retains samples, overlap and large-hop gaps across chunks, precomputes windows/filterbanks and reuses FFT buffers. Output matrices and some paths still allocate; no zero-GC or hard-real-time guarantee is made.
- **Phase-preserving analysis and synthesis**: Complex STFT, ISTFT and frame overlap-add support radix-2 and arbitrary-length Bluestein transforms. Phase-vocoder, time-stretch and pitch-shift APIs extend analysis to waveform transformation. Reconstruction depends on window, hop and valid coverage; arbitrary configurations are not guaranteed lossless.
- **Antialias resampling**: Beyond linear interpolation, windowed-sinc, rational-factor polyphase FIR and exact-output-length paths adjust low-pass cutoff and filter support for downsampling. These currently process complete arrays, not stateful resampling chunks, and do not claim SciPy-default-filter equivalence.
- **Multichannel magnitude/phase relationships**: In addition to arithmetic downmixing, the library exposes per-channel STFT/Mel/MFCC, power-ratio ILD and complex-cross-spectrum IPD. These features are not a complete localization, distance estimation or beamforming system.

Chroma, direct CQT, HPSS, LPC/LPCC, YIN, formants, onset/tempo, spectral contrast and loudness are also available as modules. This scope argument does not depend on their count or treat unit tests as full external certification.

## Intended use cases

1. **Incremental consumption of arriving audio**: A MoonBit application pushes sample chunks, consumes complete ready frames and retains the samples/window position needed for subsequent chunks, instead of repeatedly analyzing its full history. The current browser microphone demo uses rolling offline windows and is not presented as a downstream integration of this API.
2. **Offline analysis and waveform tools**: Resample with antialias filtering, inspect complex spectra, synthesize waveforms under valid reconstruction conditions, or invoke time/pitch effects. Synthetic signals and regressions exist; perceptual validation and independent tool integrations remain to be added.
3. **Stereo/multichannel relationship inspection**: Preserve channel features and inspect ILD/IPD for identical, amplitude-scaled and in-phase inputs. Tests exist, but no real microphone-array calibration or independent business adoption is claimed.

These are intended uses, not claims of production users. The immediately runnable deliverables are the library, minimal example, tests and browser demo.

## Port and reference information

### Algorithm and engineering references

FFT/Bluestein, STFT/ISTFT, Mel, DCT-II, windowed sinc, polyphase filters and phase vocoders are established techniques, not claimed as original algorithms. Engineering/numerical references include [librosa](https://github.com/librosa/librosa), [Meyda](https://meyda.js.org/audio-features) and [Essentia.js](https://github.com/MTG/essentia.js). The project uses [MIT](../../LICENSE); sources and redistributed assets are recorded in the [third-party notices](../../THIRD_PARTY_NOTICES.md). Their DSP implementations are not linked at runtime.

### Same-ecosystem comparison

The comparison is with [Juwan-Hwang/moon-certified](https://github.com/Juwan-Hwang/moon-certified/tree/94dd850ce24db5610e720035d5bdb1ecb2923e43), pinned to `94dd850ce24db5610e720035d5bdb1ecb2923e43`. It examines [audio features](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/audio_processing/features/features.mbt), [general FFT](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/math/fft/fft.mbt), [filter design](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/signal_processing/filter_design/filter_design.mbt) and [WAV](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/audio_processing/wav/wav.mbt), rather than only the README.

| Area | Existing comparison-library capability | MoonMel implementation and evidence |
| --- | --- | --- |
| Baseline | WAV, framing, power spectra, HTK Mel, MFCC, Delta and linear resampling | Core overlap is acknowledged; Slaney, normalization and boundary compatibility alone are not the substantive scope argument |
| Incremental processing | Audio-feature APIs receive full arrays and build frame sequences; inspected APIs do not expose a corresponding persistent audio extractor | [Extractor](../../src/features/streaming/streaming.mbt) retains samples/cursors, overlap and cross-chunk gaps; [tests](../../src/features/streaming/streaming_test.mbt) and [regressions](../../src/features/streaming/regression_test.mbt) cover chunked frame counts, short windows, arbitrary FFT and large-hop gaps |
| Analysis/synthesis | General forward/inverse FFT and windows already exist; the audio-feature package primarily produces power/cepstral outputs | [Complex STFT/ISTFT](../../src/dsp/stft/stft.mbt) retains frame phase and synthesizes waveforms; [effects](../../src/features/effects/effects.mbt) adds phase-vocoder processing, with [reconstruction](../../src/dsp/stft/stft_wbtest.mbt), [odd FFT](../../src/dsp/stft/regression_wbtest.mbt) and [phase-advance regressions](../../src/features/effects/regression_test.mbt) |
| Resampling | Audio features provides linear interpolation; separate FIR/IIR filter design is also available | [Resampling](../../src/dsp/resample/resample.mbt) integrates downsampling low-pass filtering, windowed sinc and polyphase fractional phases; [tests](../../src/dsp/resample/resample_test.mbt) cover 48/16 kHz sine signals and lengths, with a [fractional-phase regression](../../src/dsp/resample/regression_test.mbt) |
| Multichannel analysis | WAV retains interleaved channels and supports downmix; inspected audio-feature APIs do not expose corresponding ILD/IPD functions | [Multichannel code](../../src/features/multichannel/multichannel.mbt) retains channel features and computes power ratios and cross-spectrum phases; [tests](../../src/features/multichannel/multichannel_test.mbt) and [regressions](../../src/features/multichannel/regression_test.mbt) cover phase, silence, amplitude ratios and invalid metadata |

These differences concern supplied interfaces and execution state; they do not imply the other library could not be extended or combined to provide similar behavior. It already supplies general FFT, filter design, Welch PSD and wavelets, and its WAV encoding/bit-depth coverage is broader. MoonMel currently decodes only 8/16-bit PCM WAV and does not claim container decoding as an advantage.

## Boundaries and evidence

- **Reproducible engineering checks**: The [CI record](https://github.com/1zhouhaoran1/MoonMel/actions/runs/39132207959) for source commit `457f9bf78904bc4b45d67c5c41e8aeae0883111c` passes 147 tests on each of WASM/WASM-GC/JS, 145 on Native and five browser-binding tests. Native excludes two tests within the browser binding package. Counts describe engineering coverage, not independent project value.
- **Scoped numerical comparison**: The [eight-case report](../../tools/reference/parity_report.json), generated by the [checker](../../tools/reference/check_parity.py), aligns periodic Hann, reflect padding, float64 Slaney and orthonormal DCT-II. It checks all Mel/Log-Mel/MFCC cells and up to 64 indexed STFT bins per frame, with `atol=rtol=1e-7` and recorded maximum absolute error about `2.3e-12`. It is not a complete external comparison of streaming, effects, multichannel or resampling.
- **Runnable delivery**: `moon run examples/basic --target js` reports `STFT 513×63 / Mel 80×63 / Log-Mel 80×63 / MFCC 13×63`. The [online demo](https://1zhouhaoran1.github.io/MoonMel/) runs generated MoonBit JS in a Worker on synthetic signals or uploaded PCM WAV, with numerical inspection and export. It does not demonstrate every extension or claim WASM execution.
- **Remaining evidence**: There is no direct performance comparison with `moon-certified`, independent downstream adoption or complete advanced-algorithm external certification. Streaming emits left-aligned complete frames without automatic tail flush or timestamps; batch-local dB clipping can differ from offline global clipping, and all random-chunk MFCC matrices have not been proven equivalent.
- **Submission limits**: No fixed millisecond latency, zero allocation, hard real-time, complete Whisper frontend or broadcast-loudness compliance is promised. Mooncakes publication is deferred under the maintainer's plan. Source, examples, interfaces and tests are independently inspectable; the license is MIT.

This resubmission requests reassessment of the already implemented incremental analysis, frame synthesis, antialias resampling and multichannel analysis scope against the linked code and checks. Unimplemented or insufficiently validated capabilities are not reported as completed deliverables.
