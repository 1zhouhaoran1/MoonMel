<p align="center"><img src="docs/banner.png" alt="MoonMel — Audio Into Features" width="960" /></p>
<p align="center"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-b63a25?style=flat-square" /> <img alt="MoonBit 0.10.16+" src="https://img.shields.io/badge/moonc-0.10.16+-24211d?style=flat-square" /> <img alt="Targets" src="https://img.shields.io/badge/targets-JS%20%7C%20WASM%20%7C%20Native-24211d?style=flat-square" /></p>
<p align="center">Pure MoonBit audio feature extraction with reusable STFT, Mel, Log-Mel and MFCC stages.</p>
<p align="center"><a href="README_zh.md">中文</a> · <a href="https://1zhouhaoran1.github.io/MoonMel/">Live demo</a> · <a href="CHANGELOG.md">Changelog</a> · <a href="#run-from-source">Run</a> · <a href="docs/en/API_SPECIFICATION.md">API</a> · <a href="docs/en/ARCHITECTURE.md">Architecture</a> · <a href="docs/en/HEALTH.md">Health report</a></p>

## Run from source

Install [MoonBit](https://www.moonbitlang.com/download/) with `moonc >= 0.10.16`. Node.js 22.12+ or 24+ and pnpm 11 are needed only for the browser demo. Version 0.1.0 is published on mooncakes.io: `moon add 1zhouhaoran1/moonmel` adds it to an existing project.

```sh
git clone https://github.com/1zhouhaoran1/MoonMel.git
cd MoonMel
moon run examples/basic --target js
```

Expected output for the included one-second 440 Hz signal:

```text
STFT: 513 x 63
Mel: 80 x 63
Log-Mel: 80 x 63
MFCC: 13 x 63
```

On the project's Windows workstation, select the installed isolated compiler first:

```powershell
. ./tools/dev/activate.ps1
```

## Browser demonstration

```sh
pnpm --dir playground install --frozen-lockfile
pnpm --dir playground run dev
```

Open `http://localhost:5173`. `predev` and `prebuild` regenerate the browser bindings from current MoonBit sources, so compiler output is not maintained by hand. The page executes generated **JavaScript in a Web Worker**; WASM is a supported library build target. Audio stays on the device.

| Action | Result |
| --- | --- |
| Select a synthetic tone, sweep, mixture or silence | See an actual MoonBit spectrogram and waveform |
| Upload an 8/16-bit PCM WAV | Decode with MoonMel, downmix channels and preview up to ten seconds |
| Change FFT/hop/Mel/MFCC parameters | Recompute the currently selected audio |
| Select Log-Mel, STFT or MFCC | Inspect values by pointer or left/right keys on the plot |
| Play, capture a microphone, export | Hear input, analyze a rolling one-second window, download JSON/CSV |

Microphone capture requires HTTPS or localhost and explicit browser permission. It uses AudioWorklet; it is a rolling-window demo, not the incremental streaming library API. The page caps uploaded files at 10 MB and preview analysis at 2,000 frames. Shorten audio or increase hop length when a limit is reached.

## API

```moonbit
let cfg = @moonmel.FeatureConfig::default()
let result = @moonmel.analyze(samples, config=cfg).unwrap()
println(result.mfcc.n_cols)
```

`analyze` computes one shared STFT and filterbank, then derives Mel, Log-Mel and MFCC in order. Standalone `stft`, `mel_spectrogram`, `log_mel_spectrogram`, `mfcc` and the existing feature APIs remain available. WAV input uses `@moonmel.decode_wav(bytes)`; then analyze `audio.samples` with a config whose `sample_rate` and `f_max` match the decoded rate.

All feature matrices use `[feature row][time frame]`. The complex STFT uses `[time frame][frequency bin]`. Results use `Result[T, MelError]`; handle errors for user-controlled input rather than unwrapping. Public raw matrices and low-level kernels retain documented preconditions.

## Numerical evidence and limitations

[The machine-readable report](tools/reference/parity_report.json) is produced by `tools/reference/check_parity.py` using librosa 1.0.0, NumPy 2.5.3 and SciPy 1.18.1. It compares eight deterministic cases, including short windows, arbitrary/odd FFTs and single-sample input. All Mel/Log-Mel/MFCC cells are compared; STFT checks up to 64 explicitly indexed bins in each frame. The comparison aligns periodic Hann, reflect padding, float64 Slaney filters and orthonormal DCT-II, with `atol=rtol=1e-7`. Observed maximum error across checked values is about `2.3e-12`.

This is not whole-library parity or a competitor speed ranking. In particular, librosa's default STFT padding is constant, whereas MoonMel uses reflect. HTK-style deltas, direct CQT, Chroma, HPSS, loudness and effects have their own documented conventions and are not claimed as drop-in equivalents. The Whisper configuration is a framing preset, not a complete model frontend.

| Library | Implementation / fit | Difference relevant to this project |
| --- | --- | --- |
| MoonMel | Pure MoonBit; compiled JS/WASM/Native | Native MoonBit integration, inspectable core pipeline; external coverage of advanced features is still limited |
| [librosa](https://github.com/librosa/librosa) | Python / NumPy / SciPy research ecosystem | Reference for this project's aligned core numerical checks |
| [Meyda](https://meyda.js.org/audio-features) | JavaScript and Web Audio features | Established browser feature integration |
| [Essentia.js](https://github.com/MTG/essentia.js) | Essentia C++ through WASM with JS/TS API | Broader music algorithms and model integration |

## Checks and continuous integration

```sh
node tools/quality/check-toolchain.mjs
node tools/quality/check-architecture.mjs
moon check --deny-warn
moon test --deny-warn
moon test --target js --deny-warn
pnpm --dir playground run build
pnpm --dir playground test
```

[Project CI](.github/workflows/ci.yml) runs check/build/test and the basic example for WASM, WASM-GC, JS and Native, plus a fresh playground build and binding integration tests. CI validates compiler minimum version. A configured workflow is not evidence that a remote run has passed; consult GitHub Actions for that state.

For Windows native validation, run `pwsh -File tools/quality/test-native.ps1`; it uses an available MinGW GCC when no compiler override is set and restores its environment afterward. The local MSVC discovery points to missing headers, so it cannot be used as-is.

Optional independent Python validation, using the prepared project environment:

```powershell
& A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/check_parity.py
```

See [Development](docs/en/DEVELOPMENT.md) for a portable `uv` setup, [Acceptance](docs/en/ACCEPTANCE.md) for the nine-item acceptance guide, and [Health](docs/en/HEALTH.md) for reviewed packages and remaining limits. The module is published on mooncakes.io as `1zhouhaoran1/moonmel` 0.1.0.

## License

[MIT](LICENSE), copyright 2026 zhr. Runtime algorithms are implemented in MoonBit; NumPy/SciPy/librosa are development reference dependencies. See [third-party notices](THIRD_PARTY_NOTICES.md) for fonts and reference sources.
