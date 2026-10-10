<p align="center">
  <img src="docs/banner.jpg" alt="MoonMel: Audio Feature Extraction for MoonBit" width="960" />
</p>

<p align="center">
  <img alt="版本 0.1.0" src="https://img.shields.io/badge/版本-0.1.0-amber?style=flat-square" />
  <img alt="运行目标: WASM | JS | Native" src="https://img.shields.io/badge/运行目标-WASM%20%7C%20JS%20%7C%20Native-2b384a?style=flat-square" />
  <img alt="零外部依赖" src="https://img.shields.io/badge/依赖-纯原生零依赖-2b384a?style=flat-square" />
  <img alt="数值对齐: librosa 1.0.0" src="https://img.shields.io/badge/数值真值对齐-librosa_1.0.0-emerald?style=flat-square" />
  <a href="LICENSE"><img alt="许可证: MIT" src="https://img.shields.io/badge/许可证-MIT-2b384a?style=flat-square" /></a>
</p>

<p align="center">
  基于纯 MoonBit 实现的轻量级、确定性音频数字信号处理（DSP）与机器学习特征提取引擎，支持 WebAssembly、JavaScript 与 Native 运行时。
</p>

<p align="center">
  <a href="README.md"><strong>English Version</strong></a> ·
  <a href="#快速上手">快速上手</a> ·
  <a href="docs/zh/API_SPECIFICATION.md">接口说明</a> ·
  <a href="docs/zh/ARCHITECTURE.md">架构设计</a> ·
  <a href="docs/zh/SPEC.md">形式化规范</a> ·
  <a href="playground/">在线演示</a>
</p>

---

## 核心能力矩阵

| 阶段 | 核心算法与数学变换 | 对齐标准 |
| :--- | :--- | :--- |
| **时域处理** | Periodic Hann、Symmetric Hann、Hamming、Blackman 窗函数，两端镜像反射填充 | `scipy.signal.windows.hann(sym=False)` |
| **傅里叶变换** | 原地 Radix-2 Cooley-Tukey FFT 蝶形算法，单边功率谱输出 | 连续频域正交投影 |
| **Mel 滤波器组** | Slaney 与 HTK 刻度三角滤波器组，支持面积归一化 | `librosa.filters.mel(norm='slaney')` |
| **对数压缩** | 分贝标度转换（dB），支持 `amin=1e-10` 与 `top_db=80.0` 截断保护 | `librosa.power_to_db` |
| **倒谱提取** | 离散余弦变换（DCT-II）正交归一化，MFCC 特征提取 | `librosa.feature.mfcc(norm='ortho')` |
| **音频解码** | 纯 MoonBit 实现的 RIFF 8-bit / 16-bit PCM WAV 解析器，声道自动下混 | 原生字节流解析 |

---

## 模块分层与解耦架构

MoonMel 拒绝扁平单目录，坚持按职责清晰解耦：

```
moonmel/
├── src/
│   ├── core/
│   │   └── types/          # 核心音频容器、FeatureConfig、Complex、MelError、FeatureMatrix
│   ├── dsp/
│   │   ├── window/         # 周期性与对称性窗函数、反射填充
│   │   ├── fft/            # 原地 Radix-2 Cooley-Tukey FFT、位反转置换、单边功率谱
│   │   └── stft/           # 短时傅里叶变换分帧、加窗、单边复数谱与功率谱
│   ├── features/
│   │   ├── mel/            # Slaney 与 HTK Mel 刻度、三角滤波器组、Mel 谱投影
│   │   └── mfcc/           # 功率转分贝（dB）、Log-Mel、DCT-II 正交变换、MFCC
│   ├── codec/
│   │   └── wav/            # 纯 MoonBit PCM WAV 解码器（8-bit、16-bit，双声道转单声道）
│   └── bindings/
│       └── web/            # 供浏览器与前端调用的 WebAssembly / JavaScript JSON 桥接层
├── cmd/
│   └── main/               # CLI 性能基准测试与命令行特征分析工具
├── playground/             # 基于 Vite + TailwindCSS 的浏览器可视化演练场
├── tools/
│   └── reference/          # Python 权威真值生成与数值对齐测试脚本
└── docs/                   # 形式化技术规范、接口文档与系统设计说明
```

---

## 快速上手

### 安装与引入

```bash
moon add zhr/moonmel
```

### 基础特征提取代码

```moonbit
let samples : Array[Double] = [ /* 单声道 PCM 浮点音频采样，幅值 [-1.0, 1.0] */ ]
let config = @moonmel.FeatureConfig::default()

// 1. 计算 STFT 功率谱
let stft_spec = @moonmel.stft(samples, config~)?

// 2. 计算线性 Mel 频谱
let mel_spec = @moonmel.mel_spectrogram(samples, config~)?

// 3. 计算对数 Mel 频谱（分贝标度）
let log_mel = @moonmel.log_mel_spectrogram(samples, config~)?

// 4. 计算 MFCC 倒谱系数
let mfccs = @moonmel.mfcc(samples, config~)?

println("STFT 维度:   \{stft_spec.n_rows} 频带 x \{stft_spec.n_cols} 帧")
println("Mel 维度:    \{mel_spec.n_rows} 通道 x \{mel_spec.n_cols} 帧")
println("MFCC 维度:   \{mfccs.n_rows} 阶数 x \{mfccs.n_cols} 帧")
```

### 解析 WAV 字节流

```moonbit
let wav_bytes : Array[Byte] = [ /* 读取的 WAV 二进制数据 */ ]
let buffer = @moonmel.decode_wav(wav_bytes)?

println("采样率: \{buffer.sample_rate} Hz")
println("时长:   \{buffer.duration()} 秒")

// 直接从解码后的 AudioBuffer 提取 MFCC
let mfccs = buffer.mfcc()?
```

---

## 输出矩阵维度约定

特征统一封装于 `FeatureMatrix` 二维结构中：

| 特征类型 | 行数（`n_rows`） | 列数（`n_cols`） | 取值范围与物理含义 |
| :--- | :--- | :--- | :--- |
| **STFT 频谱图** | `n_fft / 2 + 1`（默认 513） | `n_frames` | 线性功率 `|X|^2`（非负） |
| **Mel 频谱图** | `n_mels`（默认 80） | `n_frames` | 滤波器组加权能量（非负） |
| **Log-Mel 频谱图** | `n_mels`（默认 80） | `n_frames` | 分贝值 `dB`（相对基准 `ref_value=1.0`） |
| **MFCC 倒谱系数** | `n_mfcc`（默认 13） | `n_frames` | 实数倒谱系数 `C0 .. C(n-1)` |

---

## 数值精度验证报告

与 Python `librosa 1.0.0`、`scipy 1.18.1`、`numpy 2.5.3` 官方真值全自动化严格比对：

| 验证项 | 对比基准 | 最大绝对误差 | 验证结论 |
| :--- | :--- | :--- | :--- |
| **周期性 Hann 窗** | `scipy.signal.windows.hann(sym=False)` | `< 1e-10` | 完全一致 |
| **Mel 滤波器组权重** | `librosa.filters.mel(norm='slaney')` | `< 1e-5` | 完全一致 |
| **STFT 功率谱采样** | `librosa.stft(center=True)` | `< 0.05` | 完全一致 |
| **Log-Mel（dB）** | `librosa.power_to_db(top_db=80)` | `< 0.05` | 完全一致 |
| **MFCC 倒谱系数** | `librosa.feature.mfcc(norm='ortho')` | `< 0.05` | 完全一致 |

---

## WebAssembly 交互式演练场

前端演示位于 `playground/` 目录：

```bash
cd playground
pnpm install
pnpm run dev
```

特性包含：
1. 本地直接拖拽加载真实 WAV 文件并解析。
2. 内置合成音频预设（440 Hz 单频正弦波、三和弦、扫频 Chirp、合成元音）。
3. 实时调节 FFT 大小、帧移步长、Mel 通道数及 MFCC 阶数。
4. 高清 Canvas 绘制波形图、STFT 功率谱图、Log-Mel 谱图及 MFCC 热力图。
5. 一键导出 JSON 与 CSV 格式矩阵数据。
6. 实时测量纯 MoonBit 算法在浏览器端的执行毫秒耗时。

---

## 详细技术文档导航

- [产品规格说明书 (Product Specification)](docs/zh/PRODUCT.md)
- [形式化技术规范 (Formal Specification)](docs/zh/SPEC.md)
- [系统架构设计 (Architecture)](docs/zh/ARCHITECTURE.md)
- [API 详细接口手册 (API Specification)](docs/zh/API_SPECIFICATION.md)
- [开发者指南与测试 (Development Guide)](docs/zh/DEVELOPMENT.md)
- [项目演进路线图 (Roadmap)](docs/zh/ROADMAP.md)

---

## 开源许可证

本项目基于 MIT License 开源。版权所有 (c) 2026 zhr (3449002191@qq.com)。
