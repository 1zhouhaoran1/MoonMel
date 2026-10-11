///|
/// YIN algorithm configuration for fundamental frequency (F0) pitch tracking.
pub(all) struct YinConfig {
  f_min : Double
  f_max : Double
  threshold : Double
  frame_length : Int
  hop_length : Int
} derive(Debug)

///|
/// Default YIN configuration (65 Hz to 2093 Hz, threshold 0.1, 2048 frame, 512 hop).
pub fn YinConfig::default() -> YinConfig {
  {
    f_min: 65.0,
    f_max: 2093.0,
    threshold: 0.1,
    frame_length: 2048,
    hop_length: 512,
  }
}

///|
/// Output of pitch tracking analysis.
pub(all) struct PitchTrack {
  f0 : Array[Double] // Fundamental frequency in Hz (0.0 indicates unvoiced)
  voiced_prob : Array[Double] // Voiced confidence in range [0.0, 1.0]
  periods : Array[Double] // Period in fractional samples
} derive(Debug)

///|
/// Compute difference function d_t(tau) for a frame of samples.
pub fn difference_function(
  frame : Array[Double],
  tau_max : Int,
) -> Array[Double] {
  let len = frame.length()
  let win_len = if len > tau_max { len - tau_max } else { len / 2 }
  let d : Array[Double] = Array::make(tau_max + 1, 0.0)

  for tau in 0..<=tau_max {
    let mut sum = 0.0
    for j in 0..<win_len {
      let diff = frame[j] - frame[j + tau]
      sum = sum + diff * diff
    }
    d[tau] = sum
  }
  d
}

///|
/// Compute Cumulative Mean Normalized Difference Function (CMNDF) d'_t(tau).
pub fn cumulative_mean_normalized_difference(
  d : Array[Double],
) -> Array[Double] {
  let len = d.length()
  let cmndf : Array[Double] = Array::make(len, 0.0)
  if len == 0 {
    return cmndf
  }
  cmndf[0] = 1.0
  let mut running_sum = 0.0

  for tau in 1..<len {
    running_sum = running_sum + d[tau]
    if running_sum <= 1.0e-12 {
      cmndf[tau] = 1.0
    } else {
      cmndf[tau] = d[tau] * tau.to_double() / running_sum
    }
  }
  cmndf
}

///|
/// Analyze F0 pitch and voicing confidence for a single frame.
pub fn yin_frame(
  frame : Array[Double],
  sample_rate : Int,
  f_min : Double,
  f_max : Double,
  threshold : Double,
) -> (Double, Double, Double) {
  let fs = sample_rate.to_double()
  let tau_min_raw = (fs / f_max).to_int()
  let tau_max_raw = (fs / f_min).to_int() + 1
  let tau_min = if tau_min_raw >= 2 { tau_min_raw } else { 2 }
  let max_possible = frame.length() / 2
  let tau_max = if tau_max_raw < max_possible {
    tau_max_raw
  } else {
    max_possible
  }

  if tau_max <= tau_min {
    return (0.0, 0.0, 0.0)
  }

  let d = difference_function(frame, tau_max)
  let cmndf = cumulative_mean_normalized_difference(d)

  // Step 3: Absolute threshold search
  let mut chosen_tau = -1
  let mut tau = tau_min
  while tau <= tau_max {
    if cmndf[tau] < threshold {
      while tau + 1 <= tau_max && cmndf[tau + 1] < cmndf[tau] {
        tau = tau + 1
      }
      chosen_tau = tau
      break
    }
    tau = tau + 1
  }

  // Fallback: Global minimum if threshold not reached
  let mut is_voiced = true
  if chosen_tau == -1 {
    let mut min_val = cmndf[tau_min]
    chosen_tau = tau_min
    for t in (tau_min + 1)..<=tau_max {
      if cmndf[t] < min_val {
        min_val = cmndf[t]
        chosen_tau = t
      }
    }
    is_voiced = false
  }

  // Step 4: Parabolic interpolation
  let mut refined_tau = chosen_tau.to_double()
  if chosen_tau > 0 && chosen_tau < tau_max {
    let y0 = cmndf[chosen_tau - 1]
    let y1 = cmndf[chosen_tau]
    let y2 = cmndf[chosen_tau + 1]
    let denom = 2.0 * (y0 - 2.0 * y1 + y2)
    if denom.abs() > 1.0e-12 {
      let delta = (y0 - y2) / denom
      if delta.abs() <= 1.0 {
        refined_tau = refined_tau + delta
      }
    }
  }

  if refined_tau <= 0.0 {
    return (0.0, 0.0, 0.0)
  }

  let f0 = fs / refined_tau
  let raw_prob = 1.0 - cmndf[chosen_tau]
  let voiced_prob = if raw_prob < 0.0 {
    0.0
  } else if raw_prob > 1.0 {
    1.0
  } else {
    raw_prob
  }

  if f0 < f_min || f0 > f_max || !is_voiced {
    (0.0, voiced_prob, refined_tau)
  } else {
    (f0, voiced_prob, refined_tau)
  }
}

///|
/// Extract frame-wise pitch track from single-channel AudioBuffer using YIN.
pub fn pitch_yin(
  audio : @types.AudioBuffer,
  config? : YinConfig = YinConfig::default(),
) -> Result[PitchTrack, @types.MelError] {
  let len = audio.length()
  if len == 0 {
    return Err(EmptyAudio)
  }
  let sr = audio.sample_rate
  let frame_len = config.frame_length
  let hop_len = config.hop_length
  if frame_len <= 0 || hop_len <= 0 {
    return Err(InvalidHopLength(hop_len))
  }

  let n_frames = if len >= frame_len {
    (len - frame_len) / hop_len + 1
  } else {
    1
  }

  let f0_arr : Array[Double] = Array::make(n_frames, 0.0)
  let prob_arr : Array[Double] = Array::make(n_frames, 0.0)
  let period_arr : Array[Double] = Array::make(n_frames, 0.0)
  let frame_buf : Array[Double] = Array::make(frame_len, 0.0)

  for f in 0..<n_frames {
    let start = f * hop_len
    for i in 0..<frame_len {
      let idx = start + i
      frame_buf[i] = if idx < len { audio.samples[idx] } else { 0.0 }
    }
    let (f0, prob, per) = yin_frame(
      frame_buf,
      sr,
      config.f_min,
      config.f_max,
      config.threshold,
    )
    f0_arr[f] = f0
    prob_arr[f] = prob
    period_arr[f] = per
  }

  Ok({ f0: f0_arr, voiced_prob: prob_arr, periods: period_arr, })
}
