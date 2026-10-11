///|
/// Mask calculation mode for Harmonic-Percussive Source Separation.
pub(all) enum MaskMode {
  Soft
  Hard
} derive(Eq, Debug)

///|
/// Configuration parameters for Harmonic-Percussive Source Separation (HPSS).
pub(all) struct HpssConfig {
  kernel_harm : Int
  kernel_perc : Int
  power : Double
  margin_harm : Double
  margin_perc : Double
  mask_mode : MaskMode
} derive(Eq, Debug)

///|
/// Default HPSS configuration (librosa-aligned default sizes: 31 time frames, 31 freq bins, power 2.0).
pub fn HpssConfig::default() -> HpssConfig {
  {
    kernel_harm: 31,
    kernel_perc: 31,
    power: 2.0,
    margin_harm: 1.0,
    margin_perc: 1.0,
    mask_mode: Soft,
  }
}

///|
/// Result of Harmonic-Percussive Source Separation.
pub(all) struct HpssResult {
  harmonic : @types.FeatureMatrix
  percussive : @types.FeatureMatrix
  harmonic_mask : @types.FeatureMatrix
  percussive_mask : @types.FeatureMatrix
} derive(Debug)

///|
/// In-place insertion sort on double array slice [0..<len].
fn sort_in_place(buf : Array[Double], len : Int) -> Unit {
  for i in 1..<len {
    let key = buf[i]
    let mut j = i - 1
    while j >= 0 && buf[j] > key {
      buf[j + 1] = buf[j]
      j = j - 1
    }
    buf[j + 1] = key
  }
}

///|
/// 1D median filter with edge clamping boundary conditions.
pub fn median_filter_1d(
  arr : Array[Double],
  kernel_size : Int,
) -> Array[Double] {
  let len = arr.length()
  if len <= 1 || kernel_size <= 1 {
    return arr.copy()
  }
  let mut k = kernel_size
  if k % 2 == 0 {
    k = k + 1
  }
  if k > len {
    k = if len % 2 == 1 { len } else { len - 1 }
  }
  if k <= 1 {
    return arr.copy()
  }
  let radius = k / 2
  let window_buf : Array[Double] = Array::make(k, 0.0)
  let out : Array[Double] = Array::make(len, 0.0)

  for i in 0..<len {
    for j in 0..<k {
      let mut idx = i - radius + j
      if idx < 0 {
        idx = 0
      } else if idx >= len {
        idx = len - 1
      }
      window_buf[j] = arr[idx]
    }
    sort_in_place(window_buf, k)
    out[i] = window_buf[radius]
  }
  out
}

///|
/// Median filter along time axis (each frequency row filtered across time columns).
pub fn median_filter_time(
  matrix : @types.FeatureMatrix,
  kernel_size : Int,
) -> @types.FeatureMatrix {
  let n_rows = matrix.n_rows
  let n_cols = matrix.n_cols
  let res = @types.FeatureMatrix::zeros(n_rows, n_cols)
  for r in 0..<n_rows {
    let row_data = matrix.get_row(r)
    let filtered = median_filter_1d(row_data, kernel_size)
    for c in 0..<n_cols {
      res.set(r, c, filtered[c])
    }
  }
  res
}

///|
/// Median filter along frequency axis (each time frame filtered across frequency bins).
pub fn median_filter_freq(
  matrix : @types.FeatureMatrix,
  kernel_size : Int,
) -> @types.FeatureMatrix {
  let n_rows = matrix.n_rows
  let n_cols = matrix.n_cols
  let res = @types.FeatureMatrix::zeros(n_rows, n_cols)
  let col_data : Array[Double] = Array::make(n_rows, 0.0)
  for c in 0..<n_cols {
    for r in 0..<n_rows {
      col_data[r] = matrix.at(r, c)
    }
    let filtered = median_filter_1d(col_data, kernel_size)
    for r in 0..<n_rows {
      res.set(r, c, filtered[r])
    }
  }
  res
}

///|
/// Perform Harmonic-Percussive Source Separation (HPSS) on a magnitude spectrogram.
pub fn hpss(spec : @types.FeatureMatrix, config : HpssConfig) -> HpssResult {
  let n_rows = spec.n_rows
  let n_cols = spec.n_cols
  let h_med = median_filter_time(spec, config.kernel_harm)
  let p_med = median_filter_freq(spec, config.kernel_perc)

  let harmonic = @types.FeatureMatrix::zeros(n_rows, n_cols)
  let percussive = @types.FeatureMatrix::zeros(n_rows, n_cols)
  let mask_h = @types.FeatureMatrix::zeros(n_rows, n_cols)
  let mask_p = @types.FeatureMatrix::zeros(n_rows, n_cols)

  let eps = 1.0e-12

  for r in 0..<n_rows {
    for c in 0..<n_cols {
      let s = spec.at(r, c)
      let h_val = h_med.at(r, c) * config.margin_harm
      let p_val = p_med.at(r, c) * config.margin_perc

      let (mh, mp) = match config.mask_mode {
        Soft => {
          let h_pow = if h_val <= 0.0 {
            0.0
          } else {
            @math.pow(h_val, config.power)
          }
          let p_pow = if p_val <= 0.0 {
            0.0
          } else {
            @math.pow(p_val, config.power)
          }
          let total_pow = h_pow + p_pow
          if total_pow <= eps {
            (0.5, 0.5)
          } else {
            (h_pow / total_pow, p_pow / total_pow)
          }
        }
        Hard => if h_val >= p_val { (1.0, 0.0) } else { (0.0, 1.0) }
      }

      mask_h.set(r, c, mh)
      mask_p.set(r, c, mp)
      harmonic.set(r, c, s * mh)
      percussive.set(r, c, s * mp)
    }
  }

  { harmonic, percussive, harmonic_mask: mask_h, percussive_mask: mask_p, }
}

///|
/// High-level HPSS directly from single-channel AudioBuffer.
pub fn hpss_from_audio(
  audio : @types.AudioBuffer,
  config : @types.FeatureConfig,
  hpss_config : HpssConfig,
) -> Result[HpssResult, @types.MelError] {
  match @stft.stft_spectrogram(audio.samples, config) {
    Ok(spec) => Ok(hpss(spec, hpss_config))
    Err(e) => Err(e)
  }
}

///|
/// Compute frame-wise harmonic energy ratio: E_harm / (E_harm + E_perc).
pub fn harmonic_energy_ratio(result : HpssResult) -> Array[Double] {
  let n_rows = result.harmonic.n_rows
  let n_cols = result.harmonic.n_cols
  let ratios : Array[Double] = Array::make(n_cols, 0.0)
  let eps = 1.0e-12

  for c in 0..<n_cols {
    let mut eh = 0.0
    let mut ep = 0.0
    for r in 0..<n_rows {
      let h = result.harmonic.at(r, c)
      let p = result.percussive.at(r, c)
      eh = eh + h * h
      ep = ep + p * p
    }
    ratios[c] = eh / (eh + ep + eps)
  }
  ratios
}

///|
/// Compute frame-wise percussive energy ratio: E_perc / (E_harm + E_perc).
pub fn percussive_energy_ratio(result : HpssResult) -> Array[Double] {
  let n_rows = result.percussive.n_rows
  let n_cols = result.percussive.n_cols
  let ratios : Array[Double] = Array::make(n_cols, 0.0)
  let eps = 1.0e-12

  for c in 0..<n_cols {
    let mut eh = 0.0
    let mut ep = 0.0
    for r in 0..<n_rows {
      let h = result.harmonic.at(r, c)
      let p = result.percussive.at(r, c)
      eh = eh + h * h
      ep = ep + p * p
    }
    ratios[c] = ep / (eh + ep + eps)
  }
  ratios
}
