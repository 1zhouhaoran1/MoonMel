# Third-party notices

[中文](THIRD_PARTY_NOTICES_zh.md)

MoonMel's project source is licensed under [MIT](LICENSE). No third-party DSP implementation is linked into the runtime; the standard MoonBit core library is provided by the toolchain. Numerical formulas are implemented in MoonBit and the project's reference scripts call external libraries to compare results. This notice does not relicense those libraries.

| Item | Use | License / source |
| --- | --- | --- |
| Manrope font | Self-hosted browser typography, via @fontsource-variable/manrope | Copyright 2019 The Manrope Project Authors; SIL Open Font License 1.1; full text in [Manrope-OFL.txt](docs/licenses/Manrope-OFL.txt), also shipped in playground/public |
| librosa | Optional development/reference computation | [ISC license](https://github.com/librosa/librosa/blob/main/LICENSE.md) |
| NumPy | Optional reference arrays | [BSD license](https://github.com/numpy/numpy/blob/main/LICENSE.txt) |
| SciPy | Optional reference FFT/window calculations | [BSD license](https://github.com/scipy/scipy/blob/main/LICENSE.txt) |
| New MoonMel brand artwork | Banner and transparent logo | Generated for this project with imagegen; exact prompts retained beside the canonical images in docs |

Meyda and Essentia.js are linked only as comparison sources and are not bundled. Their licenses apply to their own projects. Build dependencies retain their respective package licenses.
