///|
/// Pre-emphasis high-pass filter: y[n] = x[n] - alpha * x[n-1].
/// Standard speech processing high-frequency pre-emphasis with default alpha = 0.97.
pub fn preemphasis(
  samples : Array[Double],
  alpha? : Double = 0.97,
) -> Array[Double] {
  let len = samples.length()
  if len == 0 {
    return []
  }
  let out : Array[Double] = Array::make(len, 0.0)
  out[0] = samples[0]
  for i in 1..<len {
    out[i] = samples[i] - alpha * samples[i - 1]
  }
  out
}

///|
/// In-place pre-emphasis filter to avoid allocations in streaming workflows.
pub fn preemphasis_inplace(samples : Array[Double], alpha : Double) -> Unit {
  let len = samples.length()
  if len <= 1 {
    return
  }
  let mut prev = samples[0]
  for i in 1..<len {
    let curr = samples[i]
    samples[i] = curr - alpha * prev
    prev = curr
  }
}

///|
/// De-emphasis inverse filter: x[n] = y[n] + alpha * x[n-1].
/// Reconstructs original spectral balance after speech synthesis or processing.
pub fn deemphasis(
  samples : Array[Double],
  alpha? : Double = 0.97,
) -> Array[Double] {
  let len = samples.length()
  if len == 0 {
    return []
  }
  let out : Array[Double] = Array::make(len, 0.0)
  out[0] = samples[0]
  for i in 1..<len {
    out[i] = samples[i] + alpha * out[i - 1]
  }
  out
}
