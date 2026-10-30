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
```

On this Windows workstation, use `pwsh -File tools/quality/test-native.ps1` for native tests. It adapts the available MinGW GCC runtime declaration without editing SDK sources and restores `MOON_CC`/`MOON_AR`. The default MSVC installation has missing headers. Linux/macOS CI uses its normal native compiler.

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

`.github/workflows/ci.yml` performs check, build, test and example execution for all four targets, then builds the demo and tests its bindings. The minimum compiler gate runs in each job. See GitHub Actions for actual remote results. Version 0.1.0 is published on mooncakes.io as `1zhouhaoran1/moonmel`; `moon publish` releases subsequent versions.

To build release Native artifacts with the same Windows adapter: `pwsh -File tools/quality/test-native.ps1 -Build`.

## GitHub Pages

The live demo is https://1zhouhaoran1.github.io/MoonMel/. `.github/workflows/pages.yml` rebuilds MoonBit bindings, verifies browser bindings and deploys the Vite output after relevant main-branch changes. Its base URL comes from the Pages metadata; local dev stays at `/`. To inspect a matching local build, run `pnpm --dir playground run build --base /MoonMel/`.
