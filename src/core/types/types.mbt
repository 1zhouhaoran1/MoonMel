///|
/// MelError represents potential failure states in audio feature extraction.
pub(all) enum MelError {
  EmptyAudio
  InvalidSampleRate(Int)
  InvalidFftSize(Int)
  InvalidHopLength(Int)
  InvalidMelBands(Int)
  InvalidFrequencyRange(Double, Double)
  DimensionMismatch(String)
  WavParseError(String)
} derive(Eq, Debug)

///|
/// Show implementation for MelError
pub impl Show for MelError with fn output(self, logger) {
  match self {
    EmptyAudio => logger.write_string("Audio buffer is empty")
    InvalidSampleRate(sr) => logger.write_string("Invalid sample rate: \{sr}")
    InvalidFftSize(n) => logger.write_string("Invalid FFT size: \{n}")
    InvalidHopLength(h) => logger.write_string("Invalid hop length: \{h}")
    InvalidMelBands(m) => logger.write_string("Invalid mel bands count: \{m}")
    InvalidFrequencyRange(fmin, fmax) =>
      logger.write_string("Invalid frequency range: [\{fmin}, \{fmax}]")
    DimensionMismatch(msg) => logger.write_string("Dimension mismatch: \{msg}")
    WavParseError(msg) => logger.write_string("WAV parse error: \{msg}")
  }
}

///|
/// AudioBuffer stores single-channel 64-bit float PCM audio samples and metadata.
pub(all) struct AudioBuffer {
  samples : Array[Double]
  sample_rate : Int
} derive(Debug)

///|
/// Create an AudioBuffer with validation.
pub fn AudioBuffer::new(
  samples : Array[Double],
  sample_rate : Int,
) -> Result[AudioBuffer, MelError] {
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  if sample_rate <= 0 {
    return Err(InvalidSampleRate(sample_rate))
  }
  Ok({ samples, sample_rate, })
}

///|
/// Number of samples in buffer.
pub fn AudioBuffer::length(self : AudioBuffer) -> Int {
  self.samples.length()
}

///|
/// Duration in seconds.
pub fn AudioBuffer::duration(self : AudioBuffer) -> Double {
  self.samples.length().to_double() / self.sample_rate.to_double()
}

///|
/// MultiChannelAudioBuffer stores multi-channel 64-bit float PCM audio samples.
pub(all) struct MultiChannelAudioBuffer {
  channels : Array[Array[Double]]
  sample_rate : Int
} derive(Debug)

///|
/// Create a MultiChannelAudioBuffer with validation.
pub fn MultiChannelAudioBuffer::new(
  channels : Array[Array[Double]],
  sample_rate : Int,
) -> Result[MultiChannelAudioBuffer, MelError] {
  if channels.is_empty() {
    return Err(EmptyAudio)
  }
  let n_ch = channels.length()
  let len = channels[0].length()
  if len == 0 {
    return Err(EmptyAudio)
  }
  for i in 1..<n_ch {
    if channels[i].length() != len {
      return Err(DimensionMismatch("Channels have differing sample lengths"))
    }
  }
  if sample_rate <= 0 {
    return Err(InvalidSampleRate(sample_rate))
  }
  Ok({ channels, sample_rate, })
}

///|
/// Number of channels.
pub fn MultiChannelAudioBuffer::num_channels(
  self : MultiChannelAudioBuffer,
) -> Int {
  self.channels.length()
}

///|
/// Number of samples per channel.
pub fn MultiChannelAudioBuffer::length(self : MultiChannelAudioBuffer) -> Int {
  if self.channels.is_empty() {
    0
  } else {
    self.channels[0].length()
  }
}

///|
/// Duration in seconds.
pub fn MultiChannelAudioBuffer::duration(
  self : MultiChannelAudioBuffer,
) -> Double {
  self.length().to_double() / self.sample_rate.to_double()
}

///|
/// Downmix all channels to mono single-channel AudioBuffer.
pub fn MultiChannelAudioBuffer::to_mono(
  self : MultiChannelAudioBuffer,
) -> AudioBuffer {
  let len = self.length()
  let n_ch = self.channels.length()
  let mono = Array::make(len, 0.0)
  let scale = 1.0 / n_ch.to_double()
  for i in 0..<len {
    let mut sum = 0.0
    for ch in 0..<n_ch {
      sum = sum + self.channels[ch][i]
    }
    mono[i] = sum * scale
  }
  { samples: mono, sample_rate: self.sample_rate, }
}

///|
/// Extract a specific channel as a single-channel AudioBuffer.
pub fn MultiChannelAudioBuffer::channel(
  self : MultiChannelAudioBuffer,
  ch_idx : Int,
) -> Result[AudioBuffer, MelError] {
  if ch_idx < 0 || ch_idx >= self.channels.length() {
    return Err(DimensionMismatch("Channel index out of bounds: \{ch_idx}"))
  }
  let ch_samples = self.channels[ch_idx].copy()
  Ok({ samples: ch_samples, sample_rate: self.sample_rate, })
}

///|
/// Window function choices for framing.
pub(all) enum WindowType {
  PeriodicHann
  SymmetricHann
  Hamming
  Blackman
  Rectangular
} derive(Eq, Debug)

///|
/// Mel scale formula choices.
pub(all) enum MelScale {
  Slaney // Linear below 1 kHz, log above (librosa standard)
  Htk // Traditional HTK 2595 * log10(1 + f / 700)
} derive(Eq, Debug)

///|
/// Normalization options for triangular mel filters.
pub(all) enum MelNorm {
  Slaney // Area normalization: divide by bandwidth (librosa standard)
  None // Peak normalization: height = 1.0
} derive(Eq, Debug)

///|
/// Log compression representation.
pub(all) enum LogScale {
  Db // 10 * log10(power) relative to ref_value, clamped by top_db
  NaturalLog // ln(max(x, eps))
  Log10 // log10(max(x, eps))
} derive(Eq, Debug)

///|
/// FeatureConfig stores parameters for STFT, Mel, and MFCC computation.
pub(all) struct FeatureConfig {
  sample_rate : Int
  n_fft : Int
  hop_length : Int
  win_length : Int
  window : WindowType
  center : Bool
  power : Double
  n_mels : Int
  f_min : Double
  f_max : Double
  mel_scale : MelScale
  mel_norm : MelNorm
  log_scale : LogScale
  n_mfcc : Int
  norm_ortho : Bool
  ref_value : Double
  amin : Double
  top_db : Double
} derive(Debug)

///|
/// Default configuration (16 kHz, 1024 n_fft, 256 hop, 80 mel bins, 13 mfcc).
pub fn FeatureConfig::default() -> FeatureConfig {
  {
    sample_rate: 16000,
    n_fft: 1024,
    hop_length: 256,
    win_length: 1024,
    window: PeriodicHann,
    center: true,
    power: 2.0,
    n_mels: 80,
    f_min: 0.0,
    f_max: 8000.0,
    mel_scale: Slaney,
    mel_norm: Slaney,
    log_scale: Db,
    n_mfcc: 13,
    norm_ortho: true,
    ref_value: 1.0,
    amin: 1.0e-10,
    top_db: 80.0,
  }
}

///|
/// Whisper ASR standard configuration (16 kHz, 400 n_fft, 160 hop, 80 mel bins).
pub fn FeatureConfig::whisper() -> FeatureConfig {
  {
    sample_rate: 16000,
    n_fft: 400,
    hop_length: 160,
    win_length: 400,
    window: PeriodicHann,
    center: true,
    power: 2.0,
    n_mels: 80,
    f_min: 0.0,
    f_max: 8000.0,
    mel_scale: Slaney,
    mel_norm: Slaney,
    log_scale: Log10,
    n_mfcc: 13,
    norm_ortho: true,
    ref_value: 1.0,
    amin: 1.0e-10,
    top_db: 80.0,
  }
}

///|
/// Validate FeatureConfig parameters.
pub fn FeatureConfig::validate(self : FeatureConfig) -> Result[Unit, MelError] {
  if self.sample_rate <= 0 {
    return Err(InvalidSampleRate(self.sample_rate))
  }
  if self.n_fft <= 0 {
    return Err(InvalidFftSize(self.n_fft))
  }
  if self.hop_length <= 0 {
    return Err(InvalidHopLength(self.hop_length))
  }
  if self.n_mels <= 0 {
    return Err(InvalidMelBands(self.n_mels))
  }
  let nyquist = self.sample_rate.to_double() / 2.0
  if self.f_min < 0.0 || self.f_max <= self.f_min || self.f_max > nyquist {
    return Err(InvalidFrequencyRange(self.f_min, self.f_max))
  }
  Ok(())
}

///|
/// FeatureMatrix stores 2D feature matrices [n_rows][n_cols].
/// Usually n_rows = feature dimension (n_mels or n_mfcc or n_freq_bins),
/// and n_cols = number of time frames.
pub(all) struct FeatureMatrix {
  data : Array[Array[Double]]
  n_rows : Int
  n_cols : Int
} derive(Debug)

///|
/// Create a new FeatureMatrix.
pub fn FeatureMatrix::new(data : Array[Array[Double]]) -> FeatureMatrix {
  let rows = data.length()
  let cols = if rows > 0 { data[0].length() } else { 0 }
  { data, n_rows: rows, n_cols: cols, }
}

///|
/// Create an empty FeatureMatrix with given dimensions initialized to 0.0.
pub fn FeatureMatrix::zeros(n_rows : Int, n_cols : Int) -> FeatureMatrix {
  let data : Array[Array[Double]] = Array::make(n_rows, [])
  for r in 0..<n_rows {
    data[r] = Array::make(n_cols, 0.0)
  }
  { data, n_rows, n_cols, }
}

///|
/// Get value at (row, col).
pub fn FeatureMatrix::at(self : FeatureMatrix, row : Int, col : Int) -> Double {
  self.data[row][col]
}

///|
/// Set value at (row, col).
pub fn FeatureMatrix::set(
  self : FeatureMatrix,
  row : Int,
  col : Int,
  val : Double,
) -> Unit {
  self.data[row][col] = val
}

///|
/// Get a row (e.g. one frequency or cepstral channel over all time frames).
pub fn FeatureMatrix::get_row(self : FeatureMatrix, row : Int) -> Array[Double] {
  self.data[row]
}

///|
/// Get a column / time frame (all feature channels at time t).
pub fn FeatureMatrix::get_col(self : FeatureMatrix, col : Int) -> Array[Double] {
  let frame : Array[Double] = Array::make(self.n_rows, 0.0)
  for r in 0..<self.n_rows {
    frame[r] = self.data[r][col]
  }
  frame
}

///|
/// Transpose matrix to [n_cols][n_rows].
pub fn FeatureMatrix::transpose(self : FeatureMatrix) -> FeatureMatrix {
  let res = FeatureMatrix::zeros(self.n_cols, self.n_rows)
  for r in 0..<self.n_rows {
    for c in 0..<self.n_cols {
      res.set(c, r, self.at(r, c))
    }
  }
  res
}

///|
/// Flatten to 1D row-major array.
pub fn FeatureMatrix::flatten(self : FeatureMatrix) -> Array[Double] {
  let total = self.n_rows * self.n_cols
  let flat : Array[Double] = Array::make(total, 0.0)
  let mut idx = 0
  for r in 0..<self.n_rows {
    for c in 0..<self.n_cols {
      flat[idx] = self.data[r][c]
      idx = idx + 1
    }
  }
  flat
}

///|
/// Complex represents a 2D complex number with Double precision.
pub(all) struct Complex {
  re : Double
  im : Double
} derive(Eq, Debug)

///|
/// Create complex number.
pub fn complex(re : Double, im : Double) -> Complex {
  { re, im, }
}

///|
/// Complex addition.
pub fn Complex::add(self : Complex, other : Complex) -> Complex {
  { re: self.re + other.re, im: self.im + other.im, }
}

///|
/// Complex subtraction.
pub fn Complex::sub(self : Complex, other : Complex) -> Complex {
  { re: self.re - other.re, im: self.im - other.im, }
}

///|
/// Complex multiplication.
pub fn Complex::mul(self : Complex, other : Complex) -> Complex {
  {
    re: self.re * other.re - self.im * other.im,
    im: self.re * other.im + self.im * other.re,
  }
}

///|
/// Squared magnitude |z|^2 = re^2 + im^2.
pub fn Complex::abs2(self : Complex) -> Double {
  self.re * self.re + self.im * self.im
}

///|
/// Magnitude |z| = sqrt(re^2 + im^2).
pub fn Complex::abs(self : Complex) -> Double {
  (self.re * self.re + self.im * self.im).sqrt()
}
