# MoonMel 接口说明书 (API Specification)

[English](../en/API_SPECIFICATION.md) | [中文说明](./API_SPECIFICATION.md)

本文档提供 MoonMel 库的所有公开类型、构建器、枚举及核心计算函数的详细签名与使用契约。

---

## 1. 核心数据类型

### 1.1 `AudioBuffer`
音频数据容器，包含单声道 PCM 样本及采样率。

```moonbit
pub struct AudioBuffer {
  samples : Array[Double]
  sample_rate : Int
}
```

- `AudioBuffer::new(samples : Array[Double], sample_rate : Int) -> Result[AudioBuffer, MelError]`
  - 构造并校验音频数据有效性（非空、采样率必须为正整数）。
- `AudioBuffer::length(self : AudioBuffer) -> Int`
  - 返回音频采样点总数。
- `AudioBuffer::duration(self : AudioBuffer) -> Double`
  - 返回音频总时长（秒）。
- `AudioBuffer::from_wav_bytes(bytes : Array[Byte]) -> Result[AudioBuffer, MelError]`
  - 从原始 WAV 文件字节流解析并构造音频容器。

### 1.2 `FeatureConfig`
特征提取超参数配置体。

```moonbit
pub struct FeatureConfig {
  sample_rate : Int       // 采样率（默认 16000）
  n_fft : Int             // FFT 点数（默认 1024）
  hop_length : Int        // 帧移步长（默认 256）
  win_length : Int        // 窗口长度（默认 1024）
  window : WindowType     // 窗函数类型
  center : Bool           // 是否应用反射居中填充（默认 true）
  power : Double          // 频谱指数（2.0 为功率谱）
  n_mels : Int            // Mel 频带数（默认 80）
  f_min : Double          // 最低频率（默认 0.0）
  f_max : Double          // 最高频率（默认 sample_rate / 2.0）
  mel_scale : MelScale    // Mel 刻度算法（Slaney / Htk）
  mel_norm : MelNorm      // 归一化策略（Slaney / None）
  log_scale : LogScale    // 对数模式（Db / NaturalLog / Log10）
  n_mfcc : Int            // 提取的 MFCC 阶数（默认 13）
  norm_ortho : Bool       // DCT 正交归一化（默认 true）
  ref_value : Double      // 分贝基准参考值（默认 1.0）
  amin : Double           // 数值保护下界（默认 1.0e-10）
  top_db : Double         // 动态截断范围（默认 80.0）
}
```

预设方案构造方法：
- `FeatureConfig::default() -> FeatureConfig`：通用音频与语音默认配置。
- `FeatureConfig::whisper() -> FeatureConfig`：OpenAI Whisper 适配配置。
- `FeatureConfig::validate(self : FeatureConfig) -> Result[Unit, MelError]`：检查参数合法性。

### 1.3 `FeatureMatrix`
二维特征矩阵容器，统一存储行（频带/阶数）与列（时间帧）。

- `FeatureMatrix::zeros(n_rows : Int, n_cols : Int) -> FeatureMatrix`
- `FeatureMatrix::at(self : FeatureMatrix, row : Int, col : Int) -> Double`
- `FeatureMatrix::set(self : FeatureMatrix, row : Int, col : Int, val : Double) -> Unit`
- `FeatureMatrix::get_row(self : FeatureMatrix, row : Int) -> Array[Double]`
- `FeatureMatrix::get_col(self : FeatureMatrix, col : Int) -> Array[Double]`
- `FeatureMatrix::transpose(self : FeatureMatrix) -> FeatureMatrix`
- `FeatureMatrix::flatten(self : FeatureMatrix) -> Array[Double]`

---

## 2. 核心特征提取 API

### 2.1 `stft`
计算短时傅里叶变换单边功率/幅度谱。

```moonbit
pub fn stft(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **输出形状**：`[n_fft / 2 + 1, n_frames]`

### 2.2 `mel_spectrogram`
计算线性能量 Mel 频谱图。

```moonbit
pub fn mel_spectrogram(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **输出形状**：`[n_mels, n_frames]`

### 2.3 `log_mel_spectrogram`
计算经过对数压缩（dB、ln 或 log10）的 Mel 频谱图。

```moonbit
pub fn log_mel_spectrogram(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **输出形状**：`[n_mels, n_frames]`

### 2.4 `mfcc`
计算 Mel 频率倒谱系数。

```moonbit
pub fn mfcc(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **输出形状**：`[n_mfcc, n_frames]`

### 2.5 `decode_wav`
纯 MoonBit 解析 PCM WAV 字节流。

```moonbit
pub fn decode_wav(bytes : Array[Byte]) -> Result[AudioBuffer, MelError]
```
- 支持 8-bit、16-bit 线性 PCM；多声道自动下混为单声道。
