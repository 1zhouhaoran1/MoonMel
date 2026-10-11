///|
/// Configuration for Octave Spectral Contrast feature extraction.
pub(all) struct ContrastConfig {
  n_bands : Int // Number of frequency octave sub-bands (default 6)
  f_min : Double // Minimum base frequency boundary in Hz (default 200.0)
  quantile : Double // Quantile fraction for valley and peak (default 0.02)
  linear : Bool // Output linear ratio instead of logarithmic dB difference (default false)
} derive(Debug)

///|
/// Default Spectral Contrast configuration.
pub fn ContrastConfig::default() -> ContrastConfig {
  { n_bands: 6, f_min: 200.0, quantile: 0.02, linear: false, }
}

///|
/// In-place insertion sort for Double arrays.
fn sort_doubles(arr : Array[Double]) -> Unit {
  let len = arr.length()
  for i in 1..<len {
    let key = arr[i]
    let mut j = i - 1
    while j >= 0 && arr[j] > key {
      arr[j + 1] = arr[j]
      j = j - 1
    }
    arr[j + 1] = key
  }
}

///|
/// Empirical quantile estimation on sorted double array.
pub fn quantile_sorted(sorted : Array[Double], q : Double) -> Double {
  let len = sorted.length()
  if len == 0 {
    return 0.0
  }
  if len == 1 {
    return sorted[0]
  }
  let pos = (len - 1).to_double() * q
  let idx = pos.to_int()
  let frac = pos - idx.to_double()
  if idx >= len - 1 {
    sorted[len - 1]
  } else {
    sorted[idx] * (1.0 - frac) + sorted[idx + 1] * frac
  }
}

///|
/// Compute Octave Spectral Contrast matrix from magnitude spectrogram.
pub fn spectral_contrast(
  spec : @types.FeatureMatrix,
  sample_rate : Int,
  n_fft : Int,
  config? : ContrastConfig = ContrastConfig::default(),
) -> @types.FeatureMatrix {
  let n_rows = spec.n_rows
  let n_cols = spec.n_cols
  let n_bands = config.n_bands
  let num_features = n_bands + 1
  let result = @types.FeatureMatrix::zeros(num_features, n_cols)
  if n_rows == 0 || n_cols == 0 {
    return result
  }

  let nyquist = sample_rate.to_double() / 2.0
  let bin_hz = sample_rate.to_double() / n_fft.to_double()

  // Calculate octave frequency band edges
  let band_edges : Array[Int] = Array::make(num_features + 1, 0)
  band_edges[0] = 0

  let mut curr_f = config.f_min
  for b in 1..<=n_bands {
    let edge_f = if curr_f < nyquist { curr_f } else { nyquist }
    let bin = (edge_f / bin_hz + 0.5).to_int()
    let clamped_bin = if bin < n_rows { bin } else { n_rows - 1 }
    band_edges[b] = clamped_bin
    curr_f = curr_f * 2.0
  }
  band_edges[num_features] = n_rows - 1

  // Ensure monotonically non-decreasing band edges
  for b in 1..<=num_features {
    if band_edges[b] < band_edges[b - 1] {
      band_edges[b] = band_edges[b - 1]
    }
  }

  let eps = 1.0e-12
  let q_low = config.quantile
  let q_high = 1.0 - config.quantile

  for c in 0..<n_cols {
    for b in 0..<num_features {
      let start_bin = band_edges[b]
      let end_bin = band_edges[b + 1]
      let count = end_bin - start_bin + 1
      let buf : Array[Double] = Array::make(count, 0.0)

      for k in 0..<count {
        buf[k] = spec.at(start_bin + k, c)
      }
      sort_doubles(buf)

      let valley = quantile_sorted(buf, q_low)
      let peak = quantile_sorted(buf, q_high)

      let contrast_val = if config.linear {
        (peak + eps) / (valley + eps)
      } else {
        @math.ln((peak + eps) / (valley + eps))
      }

      result.set(b, c, contrast_val)
    }
  }

  result
}

///|
/// Extract Octave Spectral Contrast directly from single-channel AudioBuffer.
pub fn spectral_contrast_audio(
  audio : @types.AudioBuffer,
  feature_config : @types.FeatureConfig,
  contrast_config? : ContrastConfig = ContrastConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match @stft.stft_spectrogram(audio.samples, feature_config) {
    Ok(spec) =>
      Ok(
        spectral_contrast(
          spec,
          audio.sample_rate,
          feature_config.n_fft,
          config=contrast_config,
        ),
      )
    Err(e) => Err(e)
  }
}
