///|
/// Configuration for tempogram computation and tempo estimation.
pub(all) struct TempoConfig {
  min_bpm : Double // Minimum BPM bound (default 30.0)
  max_bpm : Double // Maximum BPM bound (default 300.0)
  start_bpm : Double // Prior mean tempo in BPM (default 120.0)
  std_bpm : Double // Prior standard deviation in log2-BPM space (default 1.0)
  win_length : Int32 // Analysis window in onset frames (default 192)
  hop_length : Int32 // Hop length in onset frames (default 1)
} derive(Debug)

///|
/// Default tempo configuration.
pub fn TempoConfig::default() -> TempoConfig {
  {
    min_bpm: 30.0,
    max_bpm: 300.0,
    start_bpm: 120.0,
    std_bpm: 1.0,
    win_length: 192,
    hop_length: 1,
  }
}

///|
/// Result of tempogram analysis.
pub(all) struct TempogramResult {
  tempogram : @types.FeatureMatrix // Matrix of shape [n_lags, n_frames]
  tempi : Array[Double] // BPM frequency associated with each lag row
  bpm : Double // Estimated primary global tempo in BPM
} derive(Debug)

///|
/// Log2 helper.
fn log2(x : Double) -> Double {
  @math.ln(x) / @math.ln(2.0)
}

///|
fn empty_tempogram() -> TempogramResult {
  { tempogram: @types.FeatureMatrix::zeros(0, 0), tempi: [], bpm: 0.0, }
}

///|
/// Compute autocorrelation tempogram and estimate global tempo from onset envelope.
/// Only integer lags inside the inclusive BPM range and analysis window are used.
/// Returns an empty result with bpm=0 when no such lag exists.
pub fn tempogram_from_onset(
  onset_env : Array[Double],
  sample_rate : Int32,
  hop_length : Int32,
  config~ : TempoConfig = TempoConfig::default(),
) -> TempogramResult {
  let len = onset_env.length()
  if len < 2 ||
    sample_rate <= 0 ||
    hop_length <= 0 ||
    config.win_length < 2 ||
    !@types.is_finite(config.min_bpm) ||
    !@types.is_finite(config.max_bpm) ||
    !@types.is_finite(config.start_bpm) ||
    !@types.is_finite(config.std_bpm) ||
    config.min_bpm <= 0.0 ||
    config.max_bpm <= config.min_bpm ||
    config.start_bpm <= 0.0 ||
    config.std_bpm <= 0.0 {
    return empty_tempogram()
  }
  let fps = sample_rate.to_double() / hop_length.to_double()
  let w_len = if config.win_length < len { config.win_length } else { len }

  // BPM decreases with lag: round the lower lag up and the upper lag down.
  // Intersect in floating point before converting so tiny BPM bounds cannot
  // overflow Int or invent a lag beyond the available window.
  let lower_lag = (60.0 * fps / config.max_bpm).ceil()
  let upper_lag = (60.0 * fps / config.min_bpm).floor()
  let max_possible = w_len - 1
  if lower_lag > max_possible.to_double() ||
    upper_lag < 1.0 ||
    upper_lag < lower_lag {
    return empty_tempogram()
  }
  let tau_min = if lower_lag < 1.0 { 1 } else { lower_lag.to_int() }
  let tau_max = if upper_lag >= max_possible.to_double() {
    max_possible
  } else {
    upper_lag.to_int()
  }

  let n_lags = tau_max - tau_min + 1
  let tempi : Array[Double] = Array::make(n_lags, 0.0)
  for i in 0..<n_lags {
    let tau = tau_min + i
    tempi[i] = 60.0 * fps / tau.to_double()
  }

  let step = if config.hop_length > 0 { config.hop_length } else { 1 }
  let n_frames = if len >= w_len { (len - w_len) / step + 1 } else { 1 }
  let matrix = @types.FeatureMatrix::zeros(n_lags, n_frames)

  // Precompute periodic Hann window for autocorrelation
  let pi2 = 2.0 * @math.PI
  let window : Array[Double] = Array::make(w_len, 0.0)
  for j in 0..<w_len {
    window[j] = 0.5 * (1.0 - @math.cos(pi2 * j.to_double() / w_len.to_double()))
  }

  let lag_sums : Array[Double] = Array::make(n_lags, 0.0)

  for f in 0..<n_frames {
    let start = f * step
    // Autocorrelation at lag 0 (energy normalization)
    let mut r0 = 0.0
    for j in 0..<w_len {
      let idx = start + j
      let v = (if idx < len { onset_env[idx] } else { 0.0 }) * window[j]
      r0 = r0 + v * v
    }
    let norm_factor = if r0 > 1.0e-12 { 1.0 / r0 } else { 0.0 }

    for i in 0..<n_lags {
      let tau = tau_min + i
      let mut r_tau = 0.0
      for j in 0..<(w_len - tau) {
        let idx1 = start + j
        let idx2 = start + j + tau
        let v1 = (if idx1 < len { onset_env[idx1] } else { 0.0 }) * window[j]
        let v2 = (if idx2 < len { onset_env[idx2] } else { 0.0 }) *
          window[j + tau]
        r_tau = r_tau + v1 * v2
      }
      let val = r_tau * norm_factor
      matrix.set(i, f, val)
      lag_sums[i] = lag_sums[i] + val
    }
  }

  // Estimate global tempo using prior-weighted peak picking
  let mut best_score = 0.0
  let mut best_bpm = 0.0

  for i in 0..<n_lags {
    let avg_r = lag_sums[i] / n_frames.to_double()
    let bpm_cand = tempi[i]
    let z = log2(bpm_cand / config.start_bpm) / config.std_bpm
    let prior = @math.exp(-0.5 * z * z)
    let score = avg_r * prior

    if score > best_score {
      best_score = score
      best_bpm = bpm_cand
    }
  }

  { tempogram: matrix, tempi, bpm: best_bpm, }
}

///|
/// Extract tempogram and estimate tempo directly from single-channel AudioBuffer.
pub fn tempogram(
  audio : @types.AudioBuffer,
  feature_config : @types.FeatureConfig,
  tempo_config~ : TempoConfig = TempoConfig::default(),
) -> Result[TempogramResult, @types.MelError] {
  match @onset.onset_strength_audio(audio, feature_config) {
    Ok(env) =>
      Ok(
        tempogram_from_onset(
          env,
          audio.sample_rate,
          feature_config.hop_length,
          config=tempo_config,
        ),
      )
    Err(e) => Err(e)
  }
}

///|
pub extend TempoConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TempogramResult with @moonbitlang/core/debug.Debug::{to_repr}
