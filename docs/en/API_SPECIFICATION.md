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
