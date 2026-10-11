///|
/// Onset strength computation method.
pub(all) enum OnsetMethod {
  SpectralFlux
  SuperFlux(Int) // Frequency filter window size (radius = size / 2)
  Energy
} derive(Eq, Debug)

///|
/// Configuration for onset strength envelope extraction.
pub(all) struct OnsetConfig {
  mode : OnsetMethod
  normalize : Bool // Normalize envelope to [0.0, 1.0]
} derive(Eq, Debug)

///|
/// Default configuration: Spectral flux with normalization.
pub fn OnsetConfig::default() -> OnsetConfig {
  { mode: SpectralFlux, normalize: true, }
}

///|
/// Standard spectral flux: half-wave rectified difference across successive frames.
pub fn spectral_flux(spec : @types.FeatureMatrix) -> Array[Double] {
  let n_rows = spec.n_rows
  let n_cols = spec.n_cols
  let flux : Array[Double] = Array::make(n_cols, 0.0)
  if n_cols <= 1 {
    return flux
  }

  for c in 1..<n_cols {
    let mut sum = 0.0
    for r in 0..<n_rows {
      let diff = spec.at(r, c) - spec.at(r, c - 1)
      if diff > 0.0 {
        sum = sum + diff
      }
    }
    flux[c] = sum
  }
  flux
}

///|
/// SuperFlux: spectral difference relative to maximum-filtered previous frame (Boeck & Widmer 2013).
pub fn super_flux(
  spec : @types.FeatureMatrix,
  filter_size : Int,
) -> Array[Double] {
  let n_rows = spec.n_rows
  let n_cols = spec.n_cols
  let flux : Array[Double] = Array::make(n_cols, 0.0)
  if n_cols <= 1 {
    return flux
  }

  let radius = if filter_size > 1 { filter_size / 2 } else { 1 }

  for c in 1..<n_cols {
    let mut sum = 0.0
    for r in 0..<n_rows {
      // Find local maximum in previous frame along frequency axis
      let r_min = if r - radius > 0 { r - radius } else { 0 }
      let r_max = if r + radius < n_rows - 1 { r + radius } else { n_rows - 1 }
      let mut max_prev = spec.at(r_min, c - 1)
      for k in (r_min + 1)..<=r_max {
        let v = spec.at(k, c - 1)
        if v > max_prev {
          max_prev = v
        }
      }
      let diff = spec.at(r, c) - max_prev
      if diff > 0.0 {
        sum = sum + diff
      }
    }
    flux[c] = sum
  }
  flux
}

///|
/// Compute onset strength envelope from spectrogram.
pub fn onset_strength(
  spec : @types.FeatureMatrix,
  config : OnsetConfig,
) -> Array[Double] {
  let raw = match config.mode {
    SpectralFlux => spectral_flux(spec)
    SuperFlux(size) => super_flux(spec, size)
    Energy => {
      let n_cols = spec.n_cols
      let n_rows = spec.n_rows
      let out : Array[Double] = Array::make(n_cols, 0.0)
      if n_cols > 1 {
        let mut prev_energy = 0.0
        for r in 0..<n_rows {
          let v = spec.at(r, 0)
          prev_energy = prev_energy + v * v
        }
        for c in 1..<n_cols {
          let mut curr_energy = 0.0
          for r in 0..<n_rows {
            let v = spec.at(r, c)
            curr_energy = curr_energy + v * v
          }
          let diff = curr_energy - prev_energy
          out[c] = if diff > 0.0 { diff } else { 0.0 }
          prev_energy = curr_energy
        }
      }
      out
    }
  }

  if config.normalize {
    let mut max_val = 0.0
    for v in raw {
      if v > max_val {
        max_val = v
      }
    }
    if max_val > 1.0e-12 {
      let inv = 1.0 / max_val
      for i in 0..<raw.length() {
        raw[i] = raw[i] * inv
      }
    }
  }
  raw
}

///|
/// Adaptive local threshold peak picking for onset detection (librosa.util.peak_pick aligned).
pub fn peak_pick(
  envelope : Array[Double],
  pre_max? : Int = 3,
  post_max? : Int = 3,
  pre_avg? : Int = 3,
  post_avg? : Int = 3,
  delta? : Double = 0.05,
  wait? : Int = 3,
) -> Array[Int] {
  let len = envelope.length()
  let peaks : Array[Int] = []
  if len == 0 {
    return peaks
  }

  let mut last_onset = -wait - 1

  for i in 0..<len {
    let val = envelope[i]
    if val <= 0.0 {
      continue
    }

    // 1. Check local maximum in [i - pre_max, i + post_max]
    let start_max = if i - pre_max > 0 { i - pre_max } else { 0 }
    let end_max = if i + post_max < len - 1 { i + post_max } else { len - 1 }
    let mut is_max = true
    for j in start_max..<=end_max {
      if j != i && envelope[j] >= val {
        is_max = false
        break
      }
    }
    if !is_max {
      continue
    }

    // 2. Check local average threshold in [i - pre_avg, i + post_avg]
    let start_avg = if i - pre_avg > 0 { i - pre_avg } else { 0 }
    let end_avg = if i + post_avg < len - 1 { i + post_avg } else { len - 1 }
    let count = end_avg - start_avg + 1
    let mut sum = 0.0
    for j in start_avg..<=end_avg {
      sum = sum + envelope[j]
    }
    let local_mean = sum / count.to_double()

    if val < local_mean + delta {
      continue
    }

    // 3. Check wait interval
    if i - last_onset >= wait {
      peaks.push(i)
      last_onset = i
    }
  }

  peaks
}

///|
/// Extract onset strength envelope directly from AudioBuffer.
pub fn onset_strength_audio(
  audio : @types.AudioBuffer,
  config : @types.FeatureConfig,
  onset_config? : OnsetConfig = OnsetConfig::default(),
) -> Result[Array[Double], @types.MelError] {
  match @stft.stft_spectrogram(audio.samples, config) {
    Ok(spec) => Ok(onset_strength(spec, onset_config))
    Err(e) => Err(e)
  }
}

///|
/// Detect onset event frame indices directly from AudioBuffer.
pub fn onset_detect_audio(
  audio : @types.AudioBuffer,
  config : @types.FeatureConfig,
  onset_config? : OnsetConfig = OnsetConfig::default(),
  delta? : Double = 0.05,
  wait? : Int = 3,
) -> Result[Array[Int], @types.MelError] {
  match onset_strength_audio(audio, config, onset_config~) {
    Ok(env) => Ok(peak_pick(env, delta~, wait~))
    Err(e) => Err(e)
  }
}
