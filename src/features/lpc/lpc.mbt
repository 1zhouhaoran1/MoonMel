///|
/// Result of Levinson-Durbin LPC solver.
pub(all) struct LpcResult {
  coeffs : Array[Double] // Linear prediction filter coefficients [a_1, ..., a_order]
  reflection : Array[Double] // Reflection / PARCOR coefficients [k_1, ..., k_order]
  prediction_error : Double // Residual error energy
} derive(Debug)

///|
/// Compute biased autocorrelation sequence up to max_lag.
pub fn autocorrelation(
  samples : Array[Double],
  max_lag : Int32,
) -> Array[Double] {
  let len = samples.length()
  if max_lag < 0 {
    return []
  }
  let lag_count = if max_lag < len { max_lag + 1 } else { len }
  let r : Array[Double] = Array::make(lag_count, 0.0)
  if len == 0 {
    return r
  }

  for k in 0..<lag_count {
    let mut sum = 0.0
    for n in 0..<(len - k) {
      sum = sum + samples[n] * samples[n + k]
    }
    r[k] = sum / len.to_double()
  }
  r
}

///|
/// Solve LPC all-pole filter via Levinson-Durbin recursion algorithm.
pub fn levinson_durbin(
  r : Array[Double],
  order : Int32,
) -> Result[LpcResult, @types.MelError] {
  if order <= 0 {
    return Err(DimensionMismatch("LPC order must be positive: \{order}"))
  }
  if r.length() < order + 1 {
    return Err(
      DimensionMismatch("Autocorrelation length must be at least order + 1"),
    )
  }

  let e0 = r[0]
  if e0 <= 1.0e-12 {
    let zeros : Array[Double] = Array::make(order, 0.0)
    return Ok({
      coeffs: zeros.copy(),
      reflection: zeros,
      prediction_error: 0.0,
    })
  }

  let a : Array[Double] = Array::make(order + 1, 0.0)
  let prev_a : Array[Double] = Array::make(order + 1, 0.0)
  let k_coeffs : Array[Double] = Array::make(order, 0.0)
  let mut err = e0

  for i in 1..<=order {
    let mut lambda = r[i]
    for j in 1..<i {
      lambda = lambda - prev_a[j] * r[i - j]
    }

    let k = lambda / err
    // Guard stability of all-pole reflection coefficients
    let clamped_k = if k > 0.999999 {
      0.999999
    } else if k < -0.999999 {
      -0.999999
    } else {
      k
    }

    k_coeffs[i - 1] = clamped_k
    a[i] = clamped_k

    for j in 1..<i {
      a[j] = prev_a[j] - clamped_k * prev_a[i - j]
    }

    err = err * (1.0 - clamped_k * clamped_k)
    if err <= 1.0e-12 {
      err = 1.0e-12
    }

    for j in 1..<=i {
      prev_a[j] = a[j]
    }
  }

  let result_coeffs : Array[Double] = Array::make(order, 0.0)
  for i in 0..<order {
    result_coeffs[i] = a[i + 1]
  }

  Ok({ coeffs: result_coeffs, reflection: k_coeffs, prediction_error: err, })
}

///|
/// Direct LPC analysis on a frame of audio samples.
pub fn lpc(
  samples : Array[Double],
  order : Int32,
) -> Result[LpcResult, @types.MelError] {
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  if order <= 0 || order >= samples.length() {
    return Err(DimensionMismatch("LPC order must be in [1, sample length)"))
  }
  let r = autocorrelation(samples, order)
  levinson_durbin(r, order)
}

///|
/// Convert LPC filter coefficients to Linear Prediction Cepstral Coefficients (LPCC).
pub fn lpc_to_lpcc(
  lpc_coeffs : Array[Double],
  prediction_error : Double,
  n_lpcc : Int32,
) -> Array[Double] {
  let p = lpc_coeffs.length()
  if n_lpcc <= 0 {
    return []
  }
  let c : Array[Double] = Array::make(n_lpcc, 0.0)
  if n_lpcc == 0 {
    return c
  }

  // c[0] = ln(prediction_error)
  let safe_err = if prediction_error > 1.0e-12 {
    prediction_error
  } else {
    1.0e-12
  }
  c[0] = @math.ln(safe_err)
  if n_lpcc == 1 {
    return c
  }

  // c[1] = a[0]
  if p > 0 {
    c[1] = lpc_coeffs[0]
  }

  // Recursive computation for 2 <= m <= p
  let min_len = if n_lpcc - 1 < p { n_lpcc - 1 } else { p }
  for m in 2..<=min_len {
    let mut sum = 0.0
    for k in 1..<m {
      let frac = k.to_double() / m.to_double()
      sum = sum + frac * c[k] * lpc_coeffs[m - k - 1]
    }
    c[m] = lpc_coeffs[m - 1] + sum
  }

  // Recursive computation for m > p
  if n_lpcc - 1 > p {
    for m in (p + 1)..<n_lpcc {
      let mut sum = 0.0
      for k in 1..<=p {
        let frac = (m - k).to_double() / m.to_double()
        sum = sum + frac * c[m - k] * lpc_coeffs[k - 1]
      }
      c[m] = sum
    }
  }

  c
}

///|
/// Compute linear prediction residual (inverse filtering): e[n] = x[n] - sum_{k=1}^p a_k * x[n-k].
pub fn lpc_residual(
  samples : Array[Double],
  lpc_coeffs : Array[Double],
) -> Array[Double] {
  let len = samples.length()
  let p = lpc_coeffs.length()
  let res : Array[Double] = Array::make(len, 0.0)

  for n in 0..<len {
    let mut pred = 0.0
    let k_max = if n < p { n } else { p }
    for k in 1..<=k_max {
      pred = pred + lpc_coeffs[k - 1] * samples[n - k]
    }
    res[n] = samples[n] - pred
  }
  res
}

///|
/// Extract frame-wise LPC feature matrix [order x n_frames].
pub fn lpc_features(
  samples : Array[Double],
  order : Int32,
  frame_length : Int32,
  hop_length : Int32,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let len = samples.length()
  if len == 0 {
    return Err(EmptyAudio)
  }
  if frame_length <= 0 || hop_length <= 0 {
    return Err(InvalidHopLength(hop_length))
  }
  if order <= 0 {
    return Err(DimensionMismatch("LPC order must be positive"))
  }

  let n_frames = if len >= frame_length {
    (len - frame_length) / hop_length + 1
  } else {
    1
  }

  let mat = @types.FeatureMatrix::zeros(order, n_frames)
  let frame_buf : Array[Double] = Array::make(frame_length, 0.0)

  for f in 0..<n_frames {
    let start = f * hop_length
    for i in 0..<frame_length {
      let idx = start + i
      frame_buf[i] = if idx < len { samples[idx] } else { 0.0 }
    }
    match lpc(frame_buf, order) {
      Ok(lpc_res) =>
        for r in 0..<order {
          mat.set(r, f, lpc_res.coeffs[r])
        }
      Err(e) => return Err(e)
    }
  }

  Ok(mat)
}

///|
/// Extract frame-wise Linear Prediction Cepstral Coefficients (LPCC) matrix [n_lpcc x n_frames].
pub fn lpcc_features(
  samples : Array[Double],
  order : Int32,
  n_lpcc : Int32,
  frame_length : Int32,
  hop_length : Int32,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let len = samples.length()
  if len == 0 {
    return Err(EmptyAudio)
  }
  if frame_length <= 0 || hop_length <= 0 {
    return Err(InvalidHopLength(hop_length))
  }
  if order <= 0 || n_lpcc <= 0 {
    return Err(DimensionMismatch("Order and n_lpcc must be positive"))
  }

  let n_frames = if len >= frame_length {
    (len - frame_length) / hop_length + 1
  } else {
    1
  }

  let mat = @types.FeatureMatrix::zeros(n_lpcc, n_frames)
  let frame_buf : Array[Double] = Array::make(frame_length, 0.0)

  for f in 0..<n_frames {
    let start = f * hop_length
    for i in 0..<frame_length {
      let idx = start + i
      frame_buf[i] = if idx < len { samples[idx] } else { 0.0 }
    }
    match lpc(frame_buf, order) {
      Ok(lpc_res) => {
        let lpcc = lpc_to_lpcc(lpc_res.coeffs, lpc_res.prediction_error, n_lpcc)
        for r in 0..<n_lpcc {
          mat.set(r, f, lpcc[r])
        }
      }
      Err(e) => return Err(e)
    }
  }

  Ok(mat)
}

///|
pub extend LpcResult with @moonbitlang/core/debug.Debug::{to_repr}
