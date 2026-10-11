# 第三方声明

[English](THIRD_PARTY_NOTICES.md)

项目源码采用 [MIT](LICENSE)。运行时不链接第三方 DSP 实现，MoonBit 标准库由工具链提供。公式在 MoonBit 中实现，参考脚本调用外部库进行数值比较；此声明不改变外部库许可证。

| 项目 | 用途 | 许可与来源 |
| --- | --- | --- |
| Manrope | 通过 @fontsource-variable/manrope 自托管字体 | Copyright 2019 The Manrope Project Authors，SIL OFL 1.1；[完整许可证](docs/licenses/Manrope-OFL.txt)，同时包含在演示页 public 目录 |
| librosa | 可选开发与数值参考 | [ISC](https://github.com/librosa/librosa/blob/main/LICENSE.md) |
| NumPy | 可选参考数组 | [BSD](https://github.com/numpy/numpy/blob/main/LICENSE.txt) |
| SciPy | 可选 FFT、窗函数参考 | [BSD](https://github.com/scipy/scipy/blob/main/LICENSE.txt) |
| 新 MoonMel 品牌图 | 横幅与透明标志 | 本项目通过 imagegen 生成，精确提示词保存在 docs 的规范图片旁 |

Meyda、Essentia.js 只作为对比来源链接，不打包到项目。各项目及构建依赖保持各自许可证。
