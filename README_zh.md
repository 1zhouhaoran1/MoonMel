# MoonMel — MoonBit 原生音频特征提取库

基于 MoonBit 的跨平台音频数字信号处理（DSP）与机器学习特征提取引擎，支持 WebAssembly、JavaScript 以及 Native 平台。

MoonMel 采用纯 MoonBit 编写，不依赖任何第三方 C 库或外部运行时，能够将 PCM 单声道音频转换成短时傅里叶变换（STFT）功率谱、Slaney 标度 Mel 频谱图、Log-Mel 频谱图以及 MFCC 倒谱系数。

所有算法公式均通过 Python 标准库（`librosa 1.0.0`、`scipy 1.18.1`、`numpy 2.5.3`）进行数值对齐与真值验证。

---

## 1. 系统架构与分层设计

项目遵循低耦合、多层级的设计原则，各包职责独立：

```
moonmel/
├── src/
│   ├── core/
│   │   └── types/          # 核心音频数据结构、FeatureConfig、Complex 复数、MelError、FeatureMatrix
│   ├── dsp/
│   │   ├── window/         # 周期性与对称性窗函数（Hann、Hamming、Blackman）及反射填充
│   │   ├── fft/            # 原地 Radix-2 Cooley-Tukey 快速傅里叶变换、位反转置换、单边功率谱
│   │   └── stft/           # 短时傅里叶变换分帧、加窗、单边复数谱与功率谱
│   ├── features/
│   │   ├── mel/            # Slaney 与 HTK Mel 刻度映射、三角滤波器组构建、Mel 谱投影
│   │   └── mfcc/           # 功率转分贝（dB）、对数压缩、DCT-II 正交变换、MFCC 系数提取
│   ├── codec/
│   │   └── wav/            # 纯 MoonBit 实现的 RIFF PCM WAV 解码器（支持 8 位、16 位及立体声混单声道）
│   └── bindings/
│       └── web/            # 浏览器与 Playground 调用的 WebAssembly / JavaScript JSON 桥接层
├── cmd/
│   └── main/               # CLI 性能基准测试与命令行分析工具
├── playground/             # Vite + TailwindCSS 交互式浏览器演练场
└── tools/
    └── reference/          # Python 权威真值生成与数值对齐测试脚本
```

---

## 2. 核心特性

- **纯原生实现**：100% 纯 MoonBit 实现，无外部 C 依赖，零安全与平台移植负担，采用宽松的 MIT 许可证。
- **跨平台编译**：开箱即用支持 WebAssembly（WASM）、JavaScript（ESM 模块）与 Native 编译目标。
- **数值高保真**：严格对齐 `librosa` 默认约定（`center=True` 反射填充、周期性 Hann 窗、Slaney 面积归一化 Mel 滤波器组、DCT-II 正交归一化）。
- **零内存抖动**：核心 FFT 算法采用原地 Cooley-Tukey 蝶形运算，分帧计算时避免多余数组拷贝与堆内存分配。
- **内置 WAV 解码**：可直接解析标准 PCM WAV 格式文件字节流，多声道自动下混为单声道。
- **开箱即用 Playground**：提供可视化调试站点，支持真实 WAV 上传、波形渲染、频谱图热力图及特征数据导出。

---

## 3. 安装与引入

在您的 MoonBit 项目中引入：

```bash
moon add zhr/moonmel
```

或在 `moon.pkg` 中声明导入：

```json
import {
  "zhr/moonmel",
}
```

---

## 4. 快速上手

### 基础特征提取流程

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

println("音频采样率: \{buffer.sample_rate} Hz")
println("音频时长:   \{buffer.duration()} 秒")

// 直接从 AudioBuffer 提取特征
let mfccs = buffer.mfcc()?
```

---

## 5. 矩阵维度与输出约定

特征结果统一由 `FeatureMatrix` 承载：

| 特征类型 | 行数（`n_rows`） | 列数（`n_cols`） | 数值物理意义 |
| :--- | :--- | :--- | :--- |
| **STFT 频谱图** | `n_fft / 2 + 1`（默认 513） | `n_frames` | 线性功率 `|X|^2`（非负） |
| **Mel 频谱图** | `n_mels`（默认 80） | `n_frames` | 滤波器组加权能量（非负） |
| **Log-Mel 频谱图** | `n_mels`（默认 80） | `n_frames` | 分贝值 `dB`（相对基准 `ref_value=1.0`） |
| **MFCC 倒谱系数** | `n_mfcc`（默认 13） | `n_frames` | 实数倒谱系数 `C0 .. C(n-1)` |

时间帧数计算公式：
```
n_frames = 1 + floor((audio_length + 2 * pad_width - n_fft) / hop_length)
```
当配置 `center = true` 时，`pad_width = n_fft / 2`，采用两端镜像对称填充。

---

## 6. 参数配置说明

```moonbit
pub struct FeatureConfig {
  sample_rate : Int       // 音频采样率（默认：16000 Hz）
  n_fft : Int             // 傅里叶变换窗口点数（默认：1024）
  hop_length : Int        // 帧移步长（默认：256）
  win_length : Int        // 窗口长度（默认：1024）
  window : WindowType     // 窗函数：PeriodicHann, SymmetricHann, Hamming, Blackman, Rectangular
  center : Bool           // 是否在两端反射填充 n_fft / 2（默认：true）
  power : Double          // 频谱指数（2.0 为功率谱，1.0 为幅度谱）
  n_mels : Int            // Mel 滤波器通道数（默认：80）
  f_min : Double          // 滤波器最低截止频率（默认：0.0 Hz）
  f_max : Double          // 滤波器最高截止频率（默认：sample_rate / 2.0）
  mel_scale : MelScale    // Mel 公式：Slaney（默认）或 Htk
  mel_norm : MelNorm      // 归一化方式：Slaney 面积归一化（默认）或 None
  log_scale : LogScale    // 对数压缩模式：Db（默认）、NaturalLog、Log10
  n_mfcc : Int            // 保留的 MFCC 阶数（默认：13）
  norm_ortho : Bool       // DCT-II 正交归一化（默认：true）
  ref_value : Double      // dB 转换的基准功率（默认：1.0）
  amin : Double           // 数值保护下界（默认：1.0e-10）
  top_db : Double         // 动态范围截断阈值（默认：80.0 dB）
}
```

预设方案：
- `@moonmel.FeatureConfig::default()`：常规语音与音频分析通用配置（16 kHz，1024 点 FFT，256 步长，80 通道 Mel，13 阶 MFCC）。
- `@moonmel.FeatureConfig::whisper()`：兼容 OpenAI Whisper ASR 前端特征格式（16 kHz，400 点 FFT，160 步长，80 通道 Mel，Log10 压缩）。

---

## 7. 数值验证与基准测试

运行数值验证与测试集：

```bash
# 生成 Python 真值基准数据
uv run --python A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/validate_reference.py

# 运行 MoonBit 全套测试
moon test

# 运行 JavaScript 与 WebAssembly 跨后端测试
moon test --target js
moon test --target wasm
```

### 数值对齐结果

| 验证项 | 对比基准 | 最大绝对误差 | 验证结论 |
| :--- | :--- | :--- | :--- |
| **周期性 Hann 窗** | `scipy.signal.windows.hann(sym=False)` | `< 1e-10` | 完全一致 |
| **Mel 滤波器组权重** | `librosa.filters.mel(norm='slaney')` | `< 1e-5` | 完全一致 |
| **STFT 功率谱采样** | `librosa.stft(center=True)` | `< 0.05` | 完全一致 |
| **Log-Mel（dB）** | `librosa.power_to_db(top_db=80)` | `< 0.05` | 完全一致 |
| **MFCC 倒谱系数** | `librosa.feature.mfcc(norm='ortho')` | `< 0.05` | 完全一致 |

---

## 8. WebAssembly 演示站点

演示前端代码位于 `playground/` 目录：

```bash
cd playground
pnpm install
pnpm run dev
```

功能亮点：
1. 本地解析真实 WAV 文件或合成标准音频测试信号（440 Hz 单频正弦波、三频和弦、扫频信号、合成元音）。
2. 在线实时调节 FFT 大小、帧移、Mel 频带数及 MFCC 阶数。
3. 纯浏览器端渲染高清晰度波形图、STFT 功率谱热力图、Mel 频谱图及 MFCC 倒谱矩阵。
4. 鼠标悬停实时查看各帧各阶系数值，支持导出为 JSON 及 CSV 格式。
5. 实时显示 MoonBit 算法在浏览器端的执行毫秒耗时。

---

## 9. 开源许可证

本项目基于 MIT License 开源。版权所有 (c) 2026 zhr (3449002191@qq.com)。
