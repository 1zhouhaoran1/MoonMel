///|
/// PI constant
pub let pi : Double = 3.14159265358979323846264338327950288

///|
/// Generate a window array of length `n` based on WindowType.
pub fn create_window(kind : @types.WindowType, n : Int) -> Array[Double] {
  if n <= 0 {
    return []
  }
  if n == 1 {
    return [1.0]
  }

  let out : Array[Double] = Array::make(n, 0.0)
  match kind {
    Rectangular => {
      for i in 0..<n {
        out[i] = 1.0
      }
      out
    }
    PeriodicHann => {
      let denom = n.to_double()
      for i in 0..<n {
        let x = 2.0 * pi * i.to_double() / denom
        out[i] = 0.5 - 0.5 * @math.cos(x)
      }
      out
    }
    SymmetricHann => {
      let denom = (n - 1).to_double()
      for i in 0..<n {
        let x = 2.0 * pi * i.to_double() / denom
        out[i] = 0.5 - 0.5 * @math.cos(x)
      }
      out
    }
    Hamming => {
      let denom = n.to_double()
      for i in 0..<n {
        let x = 2.0 * pi * i.to_double() / denom
        out[i] = 0.54 - 0.46 * @math.cos(x)
      }
      out
    }
    Blackman => {
      let denom = n.to_double()
      for i in 0..<n {
        let x = 2.0 * pi * i.to_double() / denom
        out[i] = 0.42 - 0.5 * @math.cos(x) + 0.08 * @math.cos(2.0 * x)
      }
      out
    }
  }
}

///|
/// Helper to map an out-of-bounds index using reflect mode (d c b a | a b c d | c b a).
/// O(1) modulo mapping to handle arbitrarily large padding widths with zero iteration overhead.
pub fn reflect_index(idx : Int, len : Int) -> Int {
  if len <= 1 {
    return 0
  }
  let period = 2 * (len - 1)
  let mut m = idx % period
  if m < 0 {
    m = m + period
  }
  if m < len {
    m
  } else {
    period - m
  }
}

///|
/// Pad audio samples using reflect padding, matching librosa center=True.
pub fn pad_reflect(samples : Array[Double], pad_width : Int) -> Array[Double] {
  let len = samples.length()
  if pad_width <= 0 || len == 0 {
    return samples.copy()
  }
  let total_len = len + 2 * pad_width
  let out : Array[Double] = Array::make(total_len, 0.0)
  for i in 0..<total_len {
    let original_idx = i - pad_width
    let ref_idx = reflect_index(original_idx, len)
    out[i] = samples[ref_idx]
  }
  out
}
