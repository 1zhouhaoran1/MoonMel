# MoonMel — Project Agent Directives & Engineering Standards

Follows global directives from `C:/Users/www17/AGENT.md`.

## 1. Project Information
- **Project**: MoonMel — Audio Feature Extraction for MoonBit
- **Module**: `1zhouhaoran1/moonmel`
- **License**: MIT (Copyright 2026 zhr)
- **Author**: zhr (3449002191@qq.com)
- **Target Platforms**: WebAssembly (WASM), JavaScript (JS), Native
- **Primary Toolchain**:
  - MoonBit: minimum `moonc 0.10.16`; locally verified `moon 0.1.20261028`, `moonc v0.10.18+6c83a7f62`. Isolated SDK: `A:\DevEnv\SDKs\MoonBit\latest-20261030`; activate with `. ./tools/dev/activate.ps1`.
  - Node / Web: `pnpm` exclusively (`A:\DevEnv\PackageManagers\pnpm\bin`), Vite + TailwindCSS
  - Python (Reference): `A:\DevEnv\Envs\moonmel_py` via `uv` (`numpy 2.5.3`, `scipy 1.18.1`, `librosa 1.0.0`)

---

## 2. Low-Coupling Hierarchical Architecture (Anti-Flat)
The project strictly rejects flat single-folder architecture and maintains clear separation of concerns across layered packages:

```
moonmel/
├── src/
│   ├── core/
│   │   └── types/          # Core audio models, FeatureConfig, Complex, MelError, FeatureMatrix
│   ├── dsp/
│   │   ├── window/         # Periodic & symmetric windows, reflect padding
│   │   ├── fft/            # In-place Radix-2 Cooley-Tukey FFT, bit reversal, RFFT power spectrum
│   │   └── stft/           # STFT framing, windowing, magnitude & power spectrograms
│   ├── features/
│   │   ├── mel/            # Slaney & HTK Mel scale, triangular filterbank, Mel spectrogram
│   │   └── mfcc/           # Power-to-dB, Log-Mel, DCT-II ortho, MFCC coefficients
│   ├── codec/
│   │   └── wav/            # Pure MoonBit PCM WAV parser (8-bit, 16-bit, stereo to mono)
│   └── facade/             # High-level ergonomic re-exports & pipeline abstractions
├── cmd/
│   └── main/               # CLI analyzer and execution benchmarks
├── playground/             # Vite + TailwindCSS + WASM interactive audio playground
└── tools/
    └── reference/          # Python numerical ground-truth generation and parity verification
```

### Dependency Rules Between Packages:
1. `core/types` has zero internal dependencies.
2. `dsp/window` depends on `core/types` and `moonbitlang/core/math`.
3. `dsp/fft` depends on `core/types` and `moonbitlang/core/math`.
4. `dsp/stft` depends on `core/types`, `dsp/window`, `dsp/fft`.
5. `features/mel` depends on `core/types`, `dsp/stft`.
6. `features/mfcc` depends on `core/types`, `features/mel`.
7. `codec/wav` depends on `core/types`.
8. Root / `facade` re-exports clean unified API for end users.

---

## 3. MoonBit Tooling & Coding Conventions
- MoonBit code is organized in block style, separated by `///|`.
- Run `moon check` to verify syntax and type correctness across all packages.
- Run `moon info && moon fmt` to update `.mbti` interfaces and format code.
- Run `moon test` (and `moon test --target js`) to run all tests.
- Prefer `assert_eq` and `assert_true` for numerical assertions.
- Use `derive(Debug)` instead of deprecated `derive(Show)`.
- Use pattern matching for `Result` error propagation.

---

## 4. Communication & Professional Invariants (ADHD-First)
- Response style: strictly 3-5 bullet lines maximum. Zero emotional filler.
- Lead with commands, paths, or code changes.
- Number multi-step work; one bounded action per step.
- State progress each turn ("step X of Y done").
- Errors: state location, cause, and fix. No drama, zero apologies.
