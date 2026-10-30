# Hackathon acceptance check

[中文](../zh/ACCEPTANCE.md)

Checked on 2026-10-30 against source baseline `74b10bdf5ae88392ab2175193df97f778cc4e06d`. The repository identity and module namespace are `1zhouhaoran1`.

This record checks engineering evidence against the nine supplied requirements; it does not replace the organizer's review or acceptance decision. Local results include the 0.10.18 formatting migration, Native repair and [0.1.6 increments](DEVELOPMENT_SERIES.md) after the baseline; remote evidence applies only to the baseline. This audit preceded the 0.1.6 release. Publication status is tracked by its GitHub Release; no application form was submitted.

## Nine requirements

| Requirement | Evidence checked | Conclusion |
| --- | --- | --- |
| 1. MoonBit primary implementation, moonc >= 0.10.16 | Algorithms/facade/CLI in MoonBit; local `moonc v0.10.18+6c83a7f62`, `moon 0.1.20261028`, isolated SDK `A:/DevEnv/SDKs/MoonBit/latest-20261030`; current-commit CI uses 0.10.18 too | Meets requirement; actually checked on the requested 0.10.18 |
| 2. Public GitHub, clear commits | GitHub API confirms public/main/MIT; current author and committer are 1zhouhaoran1; conventional functional/fix/documentation commits | Meets requirement |
| 3. Clear structure and implemented core | Architecture namespace matching repaired: 34 local packages, 88 internal imports, no cycles/upward dependencies; local four-target checks and baseline four-target CI pass | Meets within declared implementation/validation limits |
| 4. Reproducible README | Bilingual goals, installation, calls and expected shapes; basic example and independent Mooncakes consumer actually run | Meets, subject to the Windows Native environment requirement below |
| 5. CI checks/builds/tests | Current-commit four-target check/build/test/example, plus playground build and binding tests | Meets; current-commit remote evidence exists |
| 6. Runnable example | Basic example runs locally on WASM/WASM-GC/JS/Native; published-package consumer also runs | Meets |
| 7. Core-path tests | Locally 159 each on WASM/WASM-GC/JS, 157 on Windows Native, 11 Node (six binding, five architecture); baseline CI has 147/145 and five binding tests; malformed inputs, WAV, framing, FFT, Mel/MFCC and extension regressions | Core-path evidence exists; no exhaustive-input or advanced-standard certification claim |
| 8. Published on mooncakes.io | Registry lists 1zhouhaoran1/moonmel 0.1.0; a new consumer refreshes metadata, resolves/installs and runs its public API | Meets; no republication needed |
| 9. OSI license and reference notices | MIT LICENSE/metadata, bilingual notices, complete Manrope OFL text and distribution copy exist | Materials present; repository-material inspection, not legal certification |

## Current-commit remote evidence

[Project CI 41029437824](https://github.com/1zhouhaoran1/MoonMel/actions/runs/41029437824) passes on the source baseline above. Logs explicitly show `moonc v0.10.18+6c83a7f62 (2026-10-28)`: 147 tests each on WASM/WASM-GC/JS, 145 Native tests and five binding tests pass. Native excludes two browser-only package tests.

[Pages deployment 41029437856](https://github.com/1zhouhaoran1/MoonMel/actions/runs/41029437856) passes for the same commit. The [public demo](https://1zhouhaoran1.github.io/MoonMel/) and [Mooncakes page](https://mooncakes.io/docs/1zhouhaoran1/moonmel) both return HTTP 200 during this check; accessibility alone is not a rerun of every browser interaction.

CI currently downloads an available toolchain and gates the minimum at 0.10.16. It does not pin future runs to 0.10.18. Current logs prove the baseline passed on 0.10.18, not that every future run will use that version.

## Local reproduction

| Check | Result |
| --- | --- |
| `moon check --target <wasm/wasm-gc/js> --deny-warn` | All three pass without warnings |
| `moon build --target <wasm/wasm-gc/js> --release` | All three pass |
| `moon test --target <wasm/wasm-gc/js> --deny-warn` | 159/159 each |
| Basic example on WASM/WASM-GC/JS | All report STFT 513×63, Mel 80×63, Log-Mel 80×63, MFCC 13×63 |
| `pnpm --dir playground install --frozen-lockfile` | Pass |
| `pnpm --dir playground run build --base /MoonMel/` | Fresh MoonBit bindings and production build pass |
| `pnpm --dir playground test` | 11/11 pass: six binding and five architecture cases |
| Independent consumer of `1zhouhaoran1/moonmel@0.1.0` | Check/run pass on 0.10.18 with output-shape assertions |
| `moon check --target native --deny-warn` | Pass without warnings |
| `pwsh -File tools/quality/test-native.ps1 -Build` | Windows MSVC Native release build passes |
| `moon test --target native --deny-warn` | Local Native: 157/157 pass; the repair-stage helper run passed 145/145 earlier |
| `moon run examples/basic --target native` | Same output shapes as the other three targets |
| `moon fmt --check` | Pass after the 0.10.18 formatting migration |
| Streaming example on WASM/WASM-GC/JS/Native | All pass: stereo WAV→streaming MFCC agrees numerically with offline 13×17, then CMVN |

The independent consumer, artifacts and new numerical output are under ignored `_build/acceptance-20261030/`. The previous formatting migration normalized 62 source/interface files without logic changes. This series also adds functionality; the complete diff is no longer formatting-only. New CMVN has analytic regressions, not coverage in the original eight-case librosa report.

## Local issues and boundaries

- **Windows Native toolchain**: The 0.10.18 runtime requires MSVC on Windows. The existing Visual Studio C++ tools and Windows SDK were repaired through Microsoft's installer. Standard C headers come from the SDK's UCRT; absence of `stdio.h` in the VC include directory alone does not establish a broken installation. The Native helper now delegates compiler selection to Moon, removes the incompatible MinGW fallback and preserves explicit caller settings. Local Windows Native check, release build, 145 tests and example execution actually pass. MoonBit SDK sources were not modified.
- **Python reference environment**: NumPy/SciPy/librosa metadata existed but module files were incomplete. Reinstallation uses uv and the repository requirements in the dedicated environment. Actual numerical rerun evidence is recorded below.
- **Formatting migration**: Type/optional-parameter spelling and layout are normalized for 0.10.18; `moon fmt --check` passes. All four targets' checks/builds/tests/examples, playground build/binding tests and eight numerical cases pass after migration.

## Numerical rerun

After repairing the dedicated environment, the current JS bindings were rebuilt with 0.10.18 and the checker was actually rerun:

```powershell
& A:/DevEnv/Envs/moonmel_py/Scripts/python.exe tools/reference/check_parity.py --output _build/acceptance-20261030/parity-0.1.6.json
```

All eight cases pass against NumPy 2.5.3, SciPy 1.18.1 and librosa 1.0.0: tone, silence, noise, short window, 400-point FFT, odd FFT, magnitude spectrum and a single sample. Scope is all Mel/Log-Mel/MFCC cells and up to 64 indexed STFT bins per frame, with `atol=rtol=1e-7` and maximum absolute error about `2.3e-12`. This does not certify the whole library or advanced algorithms. Librosa warns that the single-sample case has an FFT larger than the signal; it still passes under explicit reflect padding.

## Judge walkthrough

1. Show the 0.10.18 compiler output and run the basic example.
2. Open current-commit CI and show all four targets plus playground binding checks.
3. Show the Mooncakes page and independent installed-package invocation.
4. Open the demo, select sweep/sine and a 400-point FFT, upload PCM WAV, change parameters and export matrices.
5. Explain the pinned ecosystem/source comparisons and boundaries for incremental processing, frame synthesis, antialias resampling and multichannel analysis.

Do not call generated JS WASM, per-case parity whole-library certification, or local timing a competitor benchmark. Advanced-algorithm and real-downstream-adoption limits in the proposal remain in force.
