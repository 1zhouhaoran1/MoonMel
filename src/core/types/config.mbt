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
/// Whisper-size framing preset (not a complete model frontend): (16 kHz, 400 n_fft, 160 hop, 80 mel bins).
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
  if self.win_length <= 0 || self.win_length > self.n_fft {
    return Err(DimensionMismatch("win_length must be in [1, n_fft]"))
  }
  if self.n_mfcc <= 0 {
    return Err(DimensionMismatch("n_mfcc must be positive"))
  }
  if !is_finite(self.power) ||
    self.power <= 0.0 ||
    !is_finite(self.amin) ||
    self.amin <= 0.0 ||
    !is_finite(self.ref_value) ||
    self.ref_value <= 0.0 ||
    !is_finite(self.top_db) ||
    self.top_db < 0.0 {
    return Err(
      DimensionMismatch(
        "power, amin and ref_value must be finite and positive; top_db must be finite and non-negative",
      ),
    )
  }
  if self.n_mels <= 0 {
    return Err(InvalidMelBands(self.n_mels))
  }
  let nyquist = self.sample_rate.to_double() / 2.0
  if !is_finite(self.f_min) ||
    !is_finite(self.f_max) ||
    self.f_min < 0.0 ||
    self.f_max <= self.f_min ||
    self.f_max > nyquist {
    return Err(InvalidFrequencyRange(self.f_min, self.f_max))
  }
  Ok(())
}

///|
pub extend FeatureConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LogScale with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LogScale with Eq::{not_equal, equal}

///|
pub extend MelNorm with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MelNorm with Eq::{not_equal, equal}

///|
pub extend MelScale with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MelScale with Eq::{not_equal, equal}

///|
pub extend WindowType with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend WindowType with Eq::{not_equal, equal}
