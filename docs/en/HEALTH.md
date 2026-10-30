# Project health review

[中文](../zh/HEALTH.md)

## Assessment

The project has a useful research implementation and a now-verified core pipeline, rather than broad external numerical certification. The initial source checkout had 105 passing tests on WASM and JS, but short-window alignment, arbitrary complex FFTs, streaming windows/hops and error envelopes were not covered. Five failing regressions were reproduced; the arbitrary complex path could hang, and was interrupted before repair. The default Windows MSVC installation could not compile because its configured headers were missing. That environmental failure is distinct from a source defect.

The 0.1.6 release source was checked on moonc 0.10.18 on 2026-10-30: 159 tests each on WASM/WASM-GC/JS, 157 on Windows Native, 11 Node cases and two examples on all four targets pass. The MSVC/SDK environment is repaired. Architecture checking previously missed imports after the namespace migration; it now reads the module name, checks 34 packages/88 internal imports and tests invalid graphs. The playground build and original eight-case core reference pass. Earlier browser interaction evidence is not a fresh UI audit. Updated CI includes format, architecture regressions and the streaming example; consult the matching GitHub Actions run for remote status.

New 24/32-bit integer PCM, preserved WAV channels, atomic checked streaming input, shared batches, offline CMVN and frame concatenation are recorded in the [development series](DEVELOPMENT_SERIES.md). CMVN uses analytic regressions rather than extending the eight-case external reference scope. These additions require package version 0.1.6.

## Package review coverage

| Area | Files/behavior examined | Improvement or explicit boundary |
| --- | --- | --- |
| core/types | All audio/config/error/matrix/complex contracts | Split by responsibility; finite config/PCM and reusable matrix validation; public raw matrices keep indexing preconditions |
| dsp/window | All window and reflect helpers | Retained tested O(1) reflect indexing; documented reflect vs default librosa padding |
| dsp/framing + stft | Preparation, short/full/odd windows, STFT/ISTFT | Shared centered window offsets; exact arbitrary FFT grid; odd Hermitian reconstruction; full-frame synthesis; reusable FFT buffers |
| dsp/fft | Radix-2, padding, Bluestein, dispatch | Checked dispatcher, unsafe raw-kernel guard; radix-2 APIs retain their original size contract |
| dsp/filter | Pre/de-emphasis and in-place variant | Retained tested recurrences; no cosmetic rewrite |
| dsp/resample | Linear, sinc, polyphase, length conversion | Correct fractional-phase direction and source-grid anti-alias cutoff; reject nonpositive filters; no SciPy-default-filter equivalence claim |
| codec/wav | Headers, chunks, layout, samples | Bounded arithmetic before access; reject hostile lengths/missing formats/incomplete PCM; duplicate policy explicit |
| mel + mfcc | Scale/filterbank/projection/log/DCT | Reusable matrix stages, sparse zero-weight skip, cached per-matrix DCT basis; preserve eight-case external evidence |
| energy + spectral | Frame sums/RMS, centroid/rolloff/flatness/ZCR | Reuse energy for RMS; avoid single-sample ZCR divide-by-zero; configurable spectral-power conventions explicit |
| streaming + multichannel | Buffer consumption, outputs, per-channel/ILD/IPD paths | Shared framing/FFT, gap cursor and config-respecting MFCC; streaming allocation/batch clipping limits explicit; validate channel lengths and metadata/config rates, use power for ILD regardless of display power; external spatial reference validation remains limited |
| delta + chroma + cqt | Derivatives, projection/normalization, direct kernels | Ragged-shape checks, invalid dimension guards, CQT Nyquist validation; direct/HTK conventions stated rather than inventing librosa parity |
| hpss + contrast | Median masks/margins, band quantiles | Margin suppression and residual fixed; contrast dB and linear-difference units fixed; median/quantile conventions are not a whole-library parity claim |
| onset + tempo | Flux, SuperFlux, peaks, lag scoring | Silence/empty envelopes yield no detected tempo; onset is a local-threshold implementation, not independently proven equivalent to librosa |
| lpc + pitch + formant | Recurrences, YIN differences, root solving | Guard negative/invalid parameters; correct predictor-to-polynomial sign; known all-pole formant frequency/bandwidth regression |
| loudness + effects | K-weighting, gates, oversampling, phase/length paths | Relative LRA gate, invalid rate/step guards, phase-vocoder phase ordering and tail interpolation; effect/true-peak compliance still needs broader reference signals |
| pipeline + facade + bindings | Every exposed adapter and transport | Separate orchestration/ergonomics/JSON; one shared STFT; truthful failure envelopes; generated compiler interfaces |
| cmd + tools + playground | Examples, reference generation, build sync, all UI modules | Runnable minimal example; full-matrix checks vs old spot values; worker, AudioWorklet, decoded-audio reuse, stale-load protection, actual report rendering |

## Correctness changes that callers should notice

Short windows now analyze the center of the complete FFT frame. Arbitrary STFT sizes preserve their actual bin spacing. Formants use the denominator of the positive predictor coefficients. Spectral contrast's logarithmic result is dB and its linear result is peak-minus-valley. Larger HPSS margins suppress components and can leave residuals. Silence has no detected BPM. ILD remains a power ratio even with magnitude display configuration; malformed or rate-mismatched channel metadata returns errors. The phase vocoder advances phase after emitting each synthesis step and interpolates its tail toward zero. Streaming honors configuration and preserves large-hop gaps. Polyphase fractional phases no longer interpolate toward the wrong side.

These fix incorrect results and therefore can change numeric output. They are covered by dedicated regressions; preserving the old incorrect values is not a compatibility objective.

## Remaining limits

The eight-case comparison checks the core numerical pipeline only. Advanced algorithms need broader reference datasets and perceptual/compliance checks before production or standards claims. Direct CQT and YIN are computationally heavier than FFT-only core features. Raw constructors/arrays and low-level numerical helpers have preconditions; checked high-level boundaries do not imply every raw helper handles arbitrary malformed state. Streaming allocates and clips dB per emitted matrix. The browser microphone is a rolling offline preview. The package is published on mooncakes.io; GitHub write access and remote CI results are external acceptance state, not numerical health.

No comparable-device competitor benchmark has been run. Current-browser timing includes feature computation, JSON serialization/parsing and worker-side preparation; it excludes startup and transfer/render time.
