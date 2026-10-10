# MoonMel API Specification

[English](./API_SPECIFICATION.md) | [中文说明](../zh/API_SPECIFICATION.md)

This document provides detailed function signatures, constructors, and usage contracts for the public API of MoonMel.

---

## 1. Core Data Structures

### 1.1 `AudioBuffer`
Container for single-channel float PCM audio.

```moonbit
pub struct AudioBuffer {
  samples : Array[Double]
  sample_rate : Int
}
```

- `AudioBuffer::new(samples : Array[Double], sample_rate : Int) -> Result[AudioBuffer, MelError]`
  - Validates and constructs an audio container.
- `AudioBuffer::length(self : AudioBuffer) -> Int`
  - Returns total sample count.
- `AudioBuffer::duration(self : AudioBuffer) -> Double`
  - Returns audio duration in seconds.
- `AudioBuffer::from_wav_bytes(bytes : Array[Byte]) -> Result[AudioBuffer, MelError]`
  - Parses and constructs an `AudioBuffer` from raw WAV file bytes.

### 1.2 `FeatureConfig`
Hyperparameter configuration for STFT, Mel, and MFCC pipelines.

```moonbit
pub struct FeatureConfig {
  sample_rate : Int       // Sample rate in Hz (default: 16000)
  n_fft : Int             // FFT size (default: 1024)
  hop_length : Int        // Stride between frames (default: 256)
  win_length : Int        // Window length (default: 1024)
  window : WindowType     // PeriodicHann, SymmetricHann, Hamming, Blackman, Rectangular
  center : Bool           // If true, applies reflect padding of n_fft / 2 (default: true)
  power : Double          // Spectrogram exponent (2.0 = power, 1.0 = magnitude)
  n_mels : Int            // Number of Mel filterbank channels (default: 80)
  f_min : Double          // Lowest frequency in Hz (default: 0.0)
  f_max : Double          // Highest frequency in Hz (default: sample_rate / 2.0)
  mel_scale : MelScale    // Slaney (default) or Htk
  mel_norm : MelNorm      // Slaney (default) or None
  log_scale : LogScale    // Db (default), NaturalLog, Log10
  n_mfcc : Int            // Number of MFCC coefficients to retain (default: 13)
  norm_ortho : Bool       // DCT-II orthogonal normalization (default: true)
  ref_value : Double      // Reference power for dB calculation (default: 1.0)
  amin : Double           // Numerical floor clamp (default: 1.0e-10)
  top_db : Double         // Dynamic range cutoff in dB (default: 80.0)
}
```

Constructors:
- `FeatureConfig::default() -> FeatureConfig`
- `FeatureConfig::whisper() -> FeatureConfig`
- `FeatureConfig::validate(self : FeatureConfig) -> Result[Unit, MelError]`

### 1.3 `FeatureMatrix`
Two-dimensional matrix representing extracted features `[n_rows][n_cols]`.

- `FeatureMatrix::zeros(n_rows : Int, n_cols : Int) -> FeatureMatrix`
- `FeatureMatrix::at(self : FeatureMatrix, row : Int, col : Int) -> Double`
- `FeatureMatrix::set(self : FeatureMatrix, row : Int, col : Int, val : Double) -> Unit`
- `FeatureMatrix::get_row(self : FeatureMatrix, row : Int) -> Array[Double]`
- `FeatureMatrix::get_col(self : FeatureMatrix, col : Int) -> Array[Double]`
- `FeatureMatrix::transpose(self : FeatureMatrix) -> FeatureMatrix`
- `FeatureMatrix::flatten(self : FeatureMatrix) -> Array[Double]`

---

## 2. Feature Extraction Functions

### 2.1 `stft`
Computes the short-time Fourier transform power or magnitude spectrogram.

```moonbit
pub fn stft(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **Output shape**: `[n_fft / 2 + 1, n_frames]`

### 2.2 `mel_spectrogram`
Computes the linear energy Mel Spectrogram.

```moonbit
pub fn mel_spectrogram(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **Output shape**: `[n_mels, n_frames]`

### 2.3 `log_mel_spectrogram`
Computes the Log-Mel Spectrogram (dB, ln, or log10).

```moonbit
pub fn log_mel_spectrogram(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **Output shape**: `[n_mels, n_frames]`

### 2.4 `mfcc`
Computes Mel-Frequency Cepstral Coefficients.

```moonbit
pub fn mfcc(
  samples : Array[Double],
  config~ : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- **Output shape**: `[n_mfcc, n_frames]`

### 2.5 `decode_wav`
Parses raw PCM WAV file bytes.

```moonbit
pub fn decode_wav(bytes : Array[Byte]) -> Result[AudioBuffer, MelError]
```
- Supports 8-bit and 16-bit PCM; automatically averages stereo down to mono.

### 2.6 `preemphasis` / `deemphasis`
High-pass pre-emphasis filtering and exact inverse reconstruction.

```moonbit
pub fn preemphasis(samples : Array[Double], alpha? : Double = 0.97) -> Array[Double]
pub fn deemphasis(samples : Array[Double], alpha? : Double = 0.97) -> Array[Double]
```
- $y[n] = x[n] - \alpha x[n-1]$ compensates high frequencies and spectral roll-off.

### 2.7 `compute_delta`
Calculates first-order (Delta) and second-order (Delta-Delta) temporal dynamic features.

```moonbit
pub fn compute_delta(
  matrix : FeatureMatrix,
  width? : Int = 9,
  order? : Int = 1
) -> Result[FeatureMatrix, MelError]
```
- Implements standard HTK / librosa polynomial approximation derivative; retains input matrix dimensions.

### 2.8 `compute_rms` / `compute_energy`
Extracts framed root-mean-square (RMS) energy and sum-of-squares total energy.

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
- Output shape: `[1, n_frames]`.

### 2.9 `resample` / `resample_linear`
High-fidelity audio resampling (Windowed-Sinc bandlimited interpolation & fast linear interpolation).

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
- Applies windowed-sinc interpolation with automatic Nyquist antialiasing low-pass filtering.

### 2.10 `StreamingExtractor`
Zero-allocation rolling buffer streaming feature extractor for live audio feeds.

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
- Reuses internal FFT, power spectrum, and filterbank buffers; emits frames incrementally.

### 2.11 `spectral_centroid`
Extracts Spectral Centroid across frames, representing spectral center of mass and perceived brightness.

```moonbit
pub fn spectral_centroid(
  samples : Array[Double],
  config? : FeatureConfig = FeatureConfig::default()
) -> Result[FeatureMatrix, MelError]
```
- Output shape: `[1, n_frames]`, in Hz.

### 2.12 `spectral_rolloff`
Extracts Spectral Rolloff frequency below which 85% of total spectral energy is contained.

```moonbit
pub fn spectral_rolloff(
  samples : Array[Double],
  config? : FeatureConfig = FeatureConfig::default(),
  roll_percent? : Double = 0.85
) -> Result[FeatureMatrix, MelError]
```
- Output shape: `[1, n_frames]`.

### 2.13 `spectral_flatness`
Extracts Spectral Flatness (Wiener entropy), measuring noise-like versus tone-like spectral character.

```moonbit
pub fn spectral_flatness(
  samples : Array[Double],
  config? : FeatureConfig = FeatureConfig::default(),
  amin? : Double = 1.0e-10
) -> Result[FeatureMatrix, MelError]
```
- Output shape: `[1, n_frames]`, range `[0.0, 1.0]`.

### 2.14 `zero_crossing_rate`
Extracts Zero-Crossing Rate (ZCR) across framed audio signals.

```moonbit
pub fn zero_crossing_rate(
  audio : AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true
) -> Result[FeatureMatrix, MelError]
```
- Output shape: `[1, n_frames]`.

### 2.15 `multichannel_stft` / `multichannel_mel` / `multichannel_mfcc`
Parallel independent feature extraction for multi-channel audio buffers.

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
- Returns an array of FeatureMatrix instances, one per channel.

### 2.16 `interchannel_level_difference` (ILD) / `interchannel_phase_difference` (IPD)
Spatial acoustic descriptors for stereo / multi-mic arrays.

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
- ILD shape: `[n_bins, n_frames]`, in decibels (dB).
- IPD shape: `[n_bins, n_frames]`, in radians `[-PI, PI]`, evaluated from complex cross-spectrum angle.



