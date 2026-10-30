# Development and testing

[中文](../zh/DEVELOPMENT.md)

## Toolchain

Require `moonc >= 0.10.16`, Node.js 22.12+ or 24+, pnpm 11.14.0. Verify with `node tools/quality/check-toolchain.mjs`. The acceptance workstation's isolated SDK is `A:/DevEnv/SDKs/MoonBit/latest-20261030` (moonc 0.10.18); select it with `. ./tools/dev/activate.ps1`, or point `MOONMEL_MOON_HOME` at another toolchain. This does not change the system installation.

```sh
moon info
moon fmt
moon check --deny-warn
node tools/quality/check-architecture.mjs
moon test --target wasm --deny-warn
moon test --target wasm-gc --deny-warn
moon test --target js --deny-warn
moon test --target native --deny-warn
moon run examples/basic --target js
moon run examples/streaming --target js
```

On Windows, the MoonBit 0.10.18 runtime requires complete Visual Studio C++ tools and Windows SDK headers/libraries. Use the Native commands above, or `pwsh -File tools/quality/test-native.ps1` for tests and add `-Build` for a release build. The helper now lets Moon select its supported compiler rather than forcing MinGW, and preserves explicit caller compiler settings. The [acceptance record](ACCEPTANCE.md) records local and remote results separately.

The source and generated interfaces have been normalized with the 0.10.18 formatter: `Int32` type spelling, current optional-parameter syntax and layout. `moon fmt --check` passes. Run it after formatting and regenerating interfaces to verify consistency.

The [0.1.6 development series](DEVELOPMENT_SERIES.md) documents the new WAV, streaming, CMVN and frame-batch APIs. CI also runs `node --test tools/quality/check-architecture.test.mjs`; architecture checks read the current module namespace and count actual internal imports.

## Browser

```sh
pnpm --dir playground install --frozen-lockfile
pnpm --dir playground run dev
pnpm --dir playground run build
pnpm --dir playground test
```

`predev` and `prebuild` run `tools/build/sync-web.mjs`. Generated JS lives under ignored `playground/src/generated`; do not edit it. Production output is `playground/dist`. The Node binding tests exercise failed inputs, malicious WAV lengths, decoded audio recomputation, arbitrary FFTs and short-window alignment.

## Independent numerical reference

Use `uv`; do not install into a shared base interpreter. On Windows all new environments belong under `A:/DevEnv/Envs`:

```powershell
uv venv A:\DevEnv\Envs\moonmel_py --python 3.13
uv pip install --python A:\DevEnv\Envs\moonmel_py\Scripts\python.exe -r tools/reference/requirements.txt
& A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/check_parity.py
```

If this environment already exists, skip creation and use it. On Linux/macOS choose an isolated development environment in the host's approved environment directory and pass its interpreter to `uv pip install --python`. The script builds current JS, compares complete Mel/Log-Mel/MFCC matrices plus selected STFT bins and records actual package versions and tolerances. `validate_reference.py` only generates older spot-check vectors; generating those vectors does not itself prove MoonMel parity.

## CI and publishing

`.github/workflows/ci.yml` performs check, build, test and example execution for all four targets, then builds the demo and tests its bindings. The minimum compiler gate runs in each job. See GitHub Actions for actual remote results. Version 0.1.6 is released on mooncakes.io as `1zhouhaoran1/moonmel`; `moon publish` releases subsequent versions.

For Windows Native release artifacts on 0.10.18, use `moon build --target native --release` in a complete MSVC developer environment; do not use the legacy MinGW adapter.

## GitHub Pages

The live demo is https://1zhouhaoran1.github.io/MoonMel/. `.github/workflows/pages.yml` rebuilds MoonBit bindings, verifies browser bindings and deploys the Vite output after relevant main-branch changes. Its base URL comes from the Pages metadata; local dev stays at `/`. To inspect a matching local build, run `pnpm --dir playground run build --base /MoonMel/`.
