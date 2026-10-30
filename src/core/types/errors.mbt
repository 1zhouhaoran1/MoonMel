///|
/// MelError represents potential failure states in audio feature extraction.
pub(all) enum MelError {
  EmptyAudio
  InvalidSampleRate(Int32)
  InvalidFftSize(Int32)
  InvalidHopLength(Int32)
  InvalidMelBands(Int32)
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
/// Portable finite-number check without a target-specific FFI.
pub fn is_finite(value : Double) -> Bool {
  value == value && value - value == 0.0
}

///|
/// Validate PCM input before it reaches numerical kernels or JSON serialization.
pub fn validate_samples(samples : Array[Double]) -> Result[Unit, MelError] {
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  for i in 0..<samples.length() {
    if !is_finite(samples[i]) {
      return Err(DimensionMismatch("Non-finite PCM sample at index \{i}"))
    }
  }
  Ok(())
}

///|
pub extend MelError with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MelError with Eq::{not_equal, equal}

///|
pub extend MelError with Show::{to_string, output}
