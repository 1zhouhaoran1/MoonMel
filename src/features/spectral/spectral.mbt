///| Spectral and temporal descriptor extraction: Spectral Centroid, Rolloff, Flatness, and ZCR.

///|
/// Extract Spectral Centroid across frames.
/// Represents the "center of mass" of the spectrum, strongly correlated with perceived brightness.
pub fn spectral_centroid(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let stft_mat = match @stft.stft_spectrogram(samples, config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }

  let n_bins = stft_mat.n_rows
  let n_frames = stft_mat.n_cols
  let sr = config.sample_rate.to_double()
  let n_fft = config.n_fft.to_double()
  let out = @types.FeatureMatrix::zeros(1, n_frames)
  let eps = 1.0e-12

  for c in 0..<n_frames {
    let mut num = 0.0
    let mut denom = 0.0
    for k in 0..<n_bins {
      let freq = k.to_double() * sr / n_fft
      let mag = stft_mat.at(k, c)
      num = num + freq * mag
      denom = denom + mag
    }
    let centroid = if denom > eps { num / denom } else { 0.0 }
    out.set(0, c, centroid)
  }

  Ok(out)
}

///|
/// Extract Spectral Rolloff across frames.
/// Frequency bin below which a specified percentage (default 85%) of total spectral energy is contained.
pub fn spectral_rolloff(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  roll_percent? : Double = 0.85,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let stft_mat = match @stft.stft_spectrogram(samples, config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }

  let n_bins = stft_mat.n_rows
  let n_frames = stft_mat.n_cols
  let sr = config.sample_rate.to_double()
  let n_fft = config.n_fft.to_double()
  let out = @types.FeatureMatrix::zeros(1, n_frames)

  for c in 0..<n_frames {
    let mut total_energy = 0.0
    for k in 0..<n_bins {
      total_energy = total_energy + stft_mat.at(k, c)
    }

    let threshold = total_energy * roll_percent
    let mut cum_energy = 0.0
    let mut rolloff_bin = 0

    for k in 0..<n_bins {
      cum_energy = cum_energy + stft_mat.at(k, c)
      if cum_energy >= threshold {
        rolloff_bin = k
        break
      }
    }

    let rolloff_hz = rolloff_bin.to_double() * sr / n_fft
    out.set(0, c, rolloff_hz)
  }

  Ok(out)
}

///|
/// Extract Spectral Flatness across frames (Wiener entropy).
/// Ratio of geometric mean to arithmetic mean of the power spectrum (1.0 = white noise, 0.0 = pure tone).
pub fn spectral_flatness(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  amin? : Double = 1.0e-10,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let stft_mat = match @stft.stft_spectrogram(samples, config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }

  let n_bins = stft_mat.n_rows
  let n_frames = stft_mat.n_cols
  let out = @types.FeatureMatrix::zeros(1, n_frames)
  let k_float = n_bins.to_double()

  for c in 0..<n_frames {
    let mut log_sum = 0.0
    let mut arith_sum = 0.0

    for k in 0..<n_bins {
      let p = stft_mat.at(k, c)
      let safe_p = if p > amin { p } else { amin }
      log_sum = log_sum + @math.ln(safe_p)
      arith_sum = arith_sum + safe_p
    }

    let geom_mean = @math.exp(log_sum / k_float)
    let arith_mean = arith_sum / k_float
    let flatness = if arith_mean > amin { geom_mean / arith_mean } else { 0.0 }
    out.set(0, c, flatness)
  }

  Ok(out)
}

///|
/// Extract Zero-Crossing Rate (ZCR) across frames.
/// The rate of sign-changes along the signal within each sliding window.
pub fn zero_crossing_rate(
  audio : @types.AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  if frame_length <= 0 || hop_length <= 0 {
    return Err(@types.MelError::InvalidHopLength(hop_length))
  }

  let raw = audio.samples
  let len = raw.length()
  if len == 0 {
    return Ok(@types.FeatureMatrix::zeros(1, 0))
  }

  // Handle center padding with edge replication (matching librosa edge mode)
  let (samples, eff_len) = if center {
    let pad = frame_length / 2
    let padded = Array::make(len + 2 * pad, 0.0)
    let first = raw[0]
    let last = raw[len - 1]
    for i in 0..<pad {
      padded[i] = first
    }
    for i in 0..<len {
      padded[pad + i] = raw[i]
    }
    for i in 0..<pad {
      padded[pad + len + i] = last
    }
    (padded, len + 2 * pad)
  } else {
    (raw, len)
  }

  if eff_len < frame_length {
    return Ok(@types.FeatureMatrix::zeros(1, 0))
  }

  let n_frames = (eff_len - frame_length) / hop_length + 1
  let out = @types.FeatureMatrix::zeros(1, n_frames)
  let denom = 2.0 * (frame_length - 1).to_double()

  for f in 0..<n_frames {
    let offset = f * hop_length
    let mut crossings = 0.0
    for i = 1; i < frame_length; i = i + 1 {
      let s_prev = samples[offset + i - 1]
      let s_curr = samples[offset + i]
      let sign_prev = if s_prev >= 0.0 { 1.0 } else { -1.0 }
      let sign_curr = if s_curr >= 0.0 { 1.0 } else { -1.0 }
      crossings = crossings + (sign_curr - sign_prev).abs()
    }
    let zcr = if denom > 0.0 { crossings / denom } else { 0.0 }
    out.set(0, f, zcr)
  }

  Ok(out)
}
