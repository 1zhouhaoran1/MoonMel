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

### 2.6 `preemphasis` / `deemphasis`
高频预加重滤波与逆滤波恢复。

```moonbit
pub fn preemphasis(samples : Array[Double], alpha? : Double = 0.97) -> Array[Double]
pub fn deemphasis(samples : Array[Double], alpha? : Double = 0.97) -> Array[Double]
```
- $y[n] = x[n] - \alpha x[n-1]$，补偿高频分量并消除唇辐射效应。

### 2.7 `compute_delta`
计算一阶差分（Delta）或二阶差分（Delta-Delta）时序动态特征。

```moonbit
pub fn compute_delta(
  matrix : FeatureMatrix,
  width? : Int = 9,
  order? : Int = 1
) -> Result[FeatureMatrix, MelError]
```
- 严格遵循 HTK / librosa 多项式求导近似公式，输出矩阵与输入保持一致形状。

### 2.8 `compute_rms` / `compute_energy`
提取时域分帧均方根能量与总能量。

```moonbit
pub fn compute_rms(
  audio : AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true
) -> Result[FeatureMatrix, MelError]

pub fn compute_energy(
  audio : AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true
) -> Result[FeatureMatrix, MelError]
```
- 输出形状：`[1, n_frames]`。

### 2.9 `resample` / `resample_linear`
高保真音频重采样（Windowed-Sinc 抗混叠滤波与快速线性插值）。

```moonbit
pub fn resample(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
  filter_size? : Int = 16
) -> Result[Array[Double], MelError]

pub fn resample_linear(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int
) -> Result[Array[Double], MelError]
```
- 默认采用加窗 Sinc 频带受限插值算法，降采样自动施加 Nyquist 低通抗混叠滤波。

### 2.10 `StreamingExtractor`
基于环形缓冲与预分配中间态的实时流式特征提取器。

```moonbit
pub fn create_streaming_extractor(
  config? : FeatureConfig
) -> Result[StreamingExtractor, MelError]

pub fn StreamingExtractor::push_samples(self : StreamingExtractor, chunk : Array[Double]) -> Unit
pub fn StreamingExtractor::available_frames(self : StreamingExtractor) -> Int
pub fn StreamingExtractor::pop_mel_frames(self : StreamingExtractor) -> FeatureMatrix
pub fn StreamingExtractor::pop_mfcc_frames(self : StreamingExtractor) -> FeatureMatrix
pub fn StreamingExtractor::reset(self : StreamingExtractor) -> Unit
```
- 零额外堆分配，内部重用 FFT 与功率谱缓冲区，支持边采集边分帧输出。

### 2.11 `spectral_centroid`
计算时频谱质心（Spectral Centroid），表征声音明亮度与频率能量重心。

```moonbit
pub fn spectral_centroid(
  samples : Array[Double],
  config? : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- 输出形状：`[1, n_frames]`，单位 Hz。

### 2.12 `spectral_rolloff`
计算频谱能量滚降截止频率（Spectral Rolloff）。

```moonbit
pub fn spectral_rolloff(
  samples : Array[Double],
  config? : FeatureConfig = FeatureConfig::default(),
  roll_percent? : Double = 0.85
) -> Result[FeatureMatrix, MelError]
```
- 输出形状：`[1, n_frames]`，默认计算累积能量达 85% 的截止频率点。

### 2.13 `spectral_flatness`
计算谱平坦度（Spectral Flatness / Wiener 熵），量化频谱白噪声度。

```moonbit
pub fn spectral_flatness(
  samples : Array[Double],
  config? : FeatureConfig = FeatureConfig::default(),
  amin? : Double = 1.0e-10
) -> Result[FeatureMatrix, MelError]
```
- 输出形状：`[1, n_frames]`，取值范围 `[0.0, 1.0]`（纯音接近 0，白噪接近 1）。

### 2.14 `zero_crossing_rate`
计算时域分帧过零率（ZCR），区分清音/浊音与瞬态边界。

```moonbit
pub fn zero_crossing_rate(
  audio : AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true
) -> Result[FeatureMatrix, MelError]
```
- 输出形状：`[1, n_frames]`。

### 2.15 `multichannel_stft` / `multichannel_mel` / `multichannel_mfcc`
多声道音频特征并行独立抽取。

```moonbit
pub fn multichannel_stft(
  buffer : MultiChannelAudioBuffer,
  config? : FeatureConfig = FeatureConfig::default()
) -> Result[Array[FeatureMatrix], MelError]

pub fn multichannel_mel(
  buffer : MultiChannelAudioBuffer,
  config? : FeatureConfig = FeatureConfig::default()
) -> Result[Array[FeatureMatrix], MelError]

pub fn multichannel_mfcc(
  buffer : MultiChannelAudioBuffer,
  config? : FeatureConfig = FeatureConfig::default()
) -> Result[Array[FeatureMatrix], MelError]
```
- 返回数组长度与输入声道数严格一致，每个声道独立对应一个 `FeatureMatrix`。

### 2.16 `interchannel_level_difference` (ILD) / `interchannel_phase_difference` (IPD)
双声道/多麦克风空间声学特征（声级差与相位差）。

```moonbit
pub fn interchannel_level_difference(
  buffer : MultiChannelAudioBuffer,
  ch1 : Int,
  ch2 : Int,
  config? : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]

pub fn interchannel_phase_difference(
  buffer : MultiChannelAudioBuffer,
  ch1 : Int,
  ch2 : Int,
  config? : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- ILD 输出形状：`[n_bins, n_frames]`，单位分贝（dB）。
- IPD 输出形状：`[n_bins, n_frames]`，取值范围 `[-PI, PI]` 弧度，通过复数互谱相位角求得。

### 2.17 `chroma_stft` 与 `chroma_filterbank`
12 音级色度图（Chromagram）与色度滤波器组，用于音高类分类与音乐和弦分析。

```moonbit
pub fn chroma_filterbank(
  sample_rate : Int,
  n_fft : Int,
  tuning? : Double = 0.0,
  f_min? : Double = 0.0
) -> FeatureMatrix

pub fn chroma_stft(
  samples : Array[Double],
  config? : FeatureConfig = FeatureConfig::default(),
  norm? : ChromaNorm = ChromaNorm::None
) -> Result[FeatureMatrix, MelError]
```
- 输出形状：`[12, n_frames]`，对应 12 个半音音级：C, C#, D, D#, E, F, F#, G, G#, A, A#, B。
- 归一化选项：`ChromaNorm::None`、`ChromaNorm::L1`、`ChromaNorm::L2`、`ChromaNorm::Max`。

### 2.18 `fft_padded` 与 `rfft_padded`
针对任意非 2 幂次长度信号的自动零填充快速傅里叶变换。

```moonbit
pub fn fft_padded(
  signal : Array[Complex]
) -> Result[Array[Complex], MelError]

pub fn rfft_padded(
  frame : Array[Double],
  power? : Double = 2.0
) -> Result[Array[Double], MelError]
```
- 自动将信号向后补零至最近的 $2^k$ 长度，无缝支持任意长度采样输入。

### 2.19 `dft`、`idft` 与 `bluestein_fft`、`bluestein_ifft`
基于 Bluestein 算法（Chirp Z-Transform）的高性能通用任意长度离散傅里叶变换。

```moonbit
pub fn dft(
  signal : Array[Complex]
) -> Result[Array[Complex], MelError]

pub fn idft(
  spectrum : Array[Complex]
) -> Result[Array[Complex], MelError]

pub fn bluestein_fft(
  signal : Array[Complex]
) -> Result[Array[Complex], MelError]

pub fn bluestein_ifft(
  spectrum : Array[Complex]
) -> Result[Array[Complex], MelError]
```
- **复杂度**：严格 $O(N \log N)$，支持任意长度 $N$（包括素数如 3, 5, 7, 13 等）。
- 当 $N$ 为 2 的幂次时，`dft` 自动路由至原地 Radix-2 Cooley-Tukey FFT；非 2 幂次时自动应用 Bluestein 快速卷积。

### 2.20 `cqt` 与 `cqt_frequencies` (Constant-Q Transform)
常量 Q 变换，在对数几何频带上以恒定品质因数 $Q$ 提取高保真时频表示。

```moonbit
pub struct CqtConfig {
  sample_rate : Int       // 采样率（默认 16000）
  hop_length : Int        // 帧移步长（默认 512）
  f_min : Double          // 最低基准频率（默认 32.703 Hz / C1）
  n_bins : Int            // 频带总数（默认 84 / 7个八度）
  bins_per_octave : Int   // 每八度频带数（默认 12）
  tuning : Double         // 调音偏置（默认 0.0）
  power : Double          // 功率谱指数（默认 2.0）
}

pub fn cqt_frequencies(config : CqtConfig) -> Array[Double]

pub fn cqt(
  samples : Array[Double],
  config? : CqtConfig = CqtConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- 输出形状：`[n_bins, n_frames]`，频点满足几何级数倍增：$f_k = f_{min} \cdot 2^{k / B}$。
- 品质因数恒定：$Q = 1 / (2^{1/B} - 1)$，支持音乐和弦与音高分析。
