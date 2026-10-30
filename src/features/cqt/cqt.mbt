///|
/// Constant-Q Transform (CQT) feature extraction.
/// Represents audio on a logarithmic frequency scale with constant Q-factor per octave.
let cqt_pi : Double = 3.14159265358979323846264338327950288

///|
/// Configuration for Constant-Q Transform.
pub(all) struct CqtConfig {
  sample_rate : Int32
  hop_length : Int32
  f_min : Double
  n_bins : Int32
  bins_per_octave : Int32
  tuning : Double
  power : Double
} derive(Eq, Debug)

///|
/// Default CqtConfig (16 kHz, 512 hop, C1 min frequency 32.7 Hz, 84 bins / 7 octaves, 12 bins/octave).
pub fn CqtConfig::default() -> CqtConfig {
  {
    sample_rate: 16000,
    hop_length: 512,
    f_min: 32.70319566257483, // C1
    n_bins: 84, // 7 octaves * 12 semitones
    bins_per_octave: 12,
    tuning: 0.0,
    power: 2.0,
  }
}

///|
/// Validate CqtConfig parameters.
pub fn CqtConfig::validate(self : CqtConfig) -> Result[Unit, @types.MelError] {
  if self.sample_rate <= 0 {
    return Err(InvalidSampleRate(self.sample_rate))
  }
  if self.hop_length <= 0 {
    return Err(InvalidHopLength(self.hop_length))
  }
  if self.n_bins <= 0 || self.bins_per_octave <= 0 {
    return Err(DimensionMismatch("n_bins and bins_per_octave must be positive"))
  }
  let nyquist = self.sample_rate.to_double() / 2.0
  if !@types.is_finite(self.f_min) ||
    self.f_min <= 0.0 ||
    self.f_min >= nyquist ||
    !@types.is_finite(self.tuning) ||
    !@types.is_finite(self.power) ||
    self.power <= 0.0 {
    return Err(InvalidFrequencyRange(self.f_min, nyquist))
  }
  let highest = self.f_min *
    @math.pow(
      2.0,
      (self.n_bins.to_double() - 1.0 - self.tuning) /
      self.bins_per_octave.to_double(),
    )
  if !@types.is_finite(highest) || highest > nyquist {
    return Err(InvalidFrequencyRange(self.f_min, highest))
  }
  Ok(())
}

///|
/// Compute center frequencies for all CQT bins.
pub fn cqt_frequencies(config : CqtConfig) -> Array[Double] {
  let freqs = Array::make(config.n_bins, 0.0)
  let b = config.bins_per_octave.to_double()
  for k in 0..<config.n_bins {
    let exponent = (k.to_double() - config.tuning) / b
    freqs[k] = config.f_min * @math.pow(2.0, exponent)
  }
  freqs
}

///|
/// Precomputed CQT filter kernel for a single frequency bin.
priv struct CqtKernel {
  n_samples : Int32
  kernel_re : Array[Double]
  kernel_im : Array[Double]
}

///|
/// Precomputes temporal filter kernels across all CQT bins.
fn build_cqt_kernels(
  config : CqtConfig,
  freqs : Array[Double],
) -> Array[CqtKernel] {
  let b = config.bins_per_octave.to_double()
  let q = 1.0 / (@math.pow(2.0, 1.0 / b) - 1.0)
  let sr = config.sample_rate.to_double()
  let kernels = Array::make(config.n_bins, CqtKernel::{
    n_samples: 0,
    kernel_re: [],
    kernel_im: [],
  })

  for k in 0..<config.n_bins {
    let fk = freqs[k]
    let raw_len = (q * sr / fk + 0.5).to_int()
    let n_k = if raw_len < 4 { 4 } else { raw_len }
    let win = @window.create_window(PeriodicHann, n_k)
    let k_re = Array::make(n_k, 0.0)
    let k_im = Array::make(n_k, 0.0)
    let inv_nk = 1.0 / n_k.to_double()

    let two_pi_fk_over_sr = 2.0 * cqt_pi * fk / sr
    for n in 0..<n_k {
      let angle = -two_pi_fk_over_sr *
        (n.to_double() - (n_k.to_double() - 1.0) / 2.0)
      let w = win[n] * inv_nk
      k_re[n] = w * @math.cos(angle)
      k_im[n] = w * @math.sin(angle)
    }

    kernels[k] = { n_samples: n_k, kernel_re: k_re, kernel_im: k_im, }
  }

  kernels
}

///|
/// Extract Constant-Q Transform (CQT) power/magnitude spectrogram.
/// Returns FeatureMatrix of shape [n_bins, n_frames].
pub fn cqt(
  samples : Array[Double],
  config~ : CqtConfig = CqtConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if samples.is_empty() {
    return Err(EmptyAudio)
  }

  let freqs = cqt_frequencies(config)
  let kernels = build_cqt_kernels(config, freqs)

  // Find max kernel length to pad signal appropriately
  let mut max_len = 0
  for k in 0..<config.n_bins {
    if kernels[k].n_samples > max_len {
      max_len = kernels[k].n_samples
    }
  }

  let pad_width = max_len / 2
  let padded = @window.pad_reflect(samples, pad_width)
  let padded_len = padded.length()

  let hop = config.hop_length
  let n_frames = if padded_len >= max_len {
    1 + (padded_len - max_len) / hop
  } else {
    0
  }

  if n_frames <= 0 {
    return Ok(@types.FeatureMatrix::zeros(config.n_bins, 0))
  }

  let out = @types.FeatureMatrix::zeros(config.n_bins, n_frames)
  let power = config.power

  for frame in 0..<n_frames {
    let center_idx = frame * hop + pad_width
    for k in 0..<config.n_bins {
      let kernel = kernels[k]
      let nk = kernel.n_samples
      let start = center_idx - nk / 2
      let mut re = 0.0
      let mut im = 0.0

      for n in 0..<nk {
        let s = padded[start + n]
        re = re + s * kernel.kernel_re[n]
        im = im + s * kernel.kernel_im[n]
      }

      let mag2 = re * re + im * im
      let val = if power == 2.0 {
        mag2
      } else if power == 1.0 {
        mag2.sqrt()
      } else {
        @math.pow(mag2, power / 2.0)
      }

      out.set(k, frame, val)
    }
  }

  Ok(out)
}

///|
pub extend CqtConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CqtConfig with Eq::{not_equal, equal}
