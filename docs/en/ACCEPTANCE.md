# Hackathon acceptance

[中文](../zh/ACCEPTANCE.md)

This checklist maps the owner's supplied nine requirements to verifiable artifacts. It does not assert that an unrun remote workflow has passed.

| Requirement | Evidence / action | State |
| --- | --- | --- |
| 1. MoonBit primary implementation, moonc >= 0.10.16 | `src/**/*.mbt`, compiler version gate; isolated local 0.10.18 toolchain | Implemented; check, build and tests pass on 0.10.18 |
| 2. Public GitHub, clear commits | https://github.com/1zhouhaoran1/MoonMel; Conventional Commit history | Public repository verified; implementation commits pushed as 1zhouhaoran1 |
| 3. Clear structure, declared core functionality | Layered packages and dependency checker; core pipeline regressions/reference | Implemented and locally verified within stated numerical scope |
| 4. Reproducible README | English/Chinese root READMEs, source install and exact example output | Included |
| 5. CI covering check/build/test | `.github/workflows/ci.yml`, four-target matrix and playground job | Passed on the pushed implementation commit; see the verified run below |
| 6. Runnable example | `moon run examples/basic --target js` | Local output and all four CI targets verified |
| 7. Core path tests | MoonBit regressions, Node binding tests, eight-case Python reference | Included; run commands in DEVELOPMENT.md |
| 8. Publish on mooncakes.io | `1zhouhaoran1/moonmel` version 0.1.0 with repository and MIT metadata | Published 2026-10-28 |
| 9. OSI-recognized license and reference compliance | MIT LICENSE, third-party notices, full Manrope OFL | Included; no competitor runtime code bundled |

## Verified remote evidence

[Project CI run 40652475112](https://github.com/1zhouhaoran1/MoonMel/actions/runs/40652475112) passed for release commit `1c710303e463a8b8b7b83e0fe745c5a99b722b60`. WASM, WASM-GC, JS and Native each completed check/build/test/example; the playground completed its fresh build and binding tests. Publishing credentials are supplied through environment variables.

## Judge walkthrough

Run the basic example, then `pnpm --dir playground run dev`. In the page, switch sweep to sine, choose a 400-point FFT, upload a PCM WAV, change a parameter and export its matrix. Inspect differences against the three linked libraries and download the raw numerical report. Show CI results from GitHub Actions once the pushed commit has actually completed.

Do not call generated-JS execution WASM, per-case core parity whole-library parity, or current-browser timing a competitor benchmark. Registry publication and externally hosted demo deployment are separate release steps, not substitutes for source/tests.
