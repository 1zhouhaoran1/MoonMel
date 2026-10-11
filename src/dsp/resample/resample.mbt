///| High-performance audio resampling algorithms (Linear and Windowed Sinc).

///|
/// Linear interpolation audio resampler.
/// Fast and lightweight, suitable for small sample rate adjustments or low-power embedded environments.
pub fn resample_linear(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
) -> Result[Array[Double], @types.MelError] {
  if orig_sr <= 0 {
    return Err(@types.MelError::InvalidSampleRate(orig_sr))
  }
  if target_sr <= 0 {
    return Err(@types.MelError::InvalidSampleRate(target_sr))
  }
  let len = samples.length()
  if len == 0 {
    return Ok([])
  }
  if orig_sr == target_sr {
    let out = Array::make(len, 0.0)
    for i in 0..<len {
      out[i] = samples[i]
    }
    return Ok(out)
  }

  let ratio = target_sr.to_double() / orig_sr.to_double()
  let out_len = (len.to_double() * ratio + 0.5).to_int()
  if out_len == 0 {
    return Ok([])
  }

  let out : Array[Double] = Array::make(out_len, 0.0)
  let inv_ratio = orig_sr.to_double() / target_sr.to_double()

  for i in 0..<out_len {
    let src_pos = i.to_double() * inv_ratio
    let idx0 = src_pos.to_int()
    let frac = src_pos - idx0.to_double()
    if idx0 >= len - 1 {
      out[i] = samples[len - 1]
    } else {
      let s0 = samples[idx0]
      let s1 = samples[idx0 + 1]
      out[i] = s0 * (1.0 - frac) + s1 * frac
    }
  }

  Ok(out)
}

///|
/// Windowed-Sinc bandlimited antialiased audio resampler.
/// Production-grade polyphase sinc interpolation with Hann apodization window.
/// Automatically applies Nyquist antialiasing low-pass filter during downsampling.
pub fn resample_sinc(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
  filter_size? : Int = 16,
) -> Result[Array[Double], @types.MelError] {
  if orig_sr <= 0 {
    return Err(@types.MelError::InvalidSampleRate(orig_sr))
  }
  if target_sr <= 0 {
    return Err(@types.MelError::InvalidSampleRate(target_sr))
  }
  let len = samples.length()
  if len == 0 {
    return Ok([])
  }
  if orig_sr == target_sr {
    let out = Array::make(len, 0.0)
    for i in 0..<len {
      out[i] = samples[i]
    }
    return Ok(out)
  }

  let ratio = target_sr.to_double() / orig_sr.to_double()
  let out_len = (len.to_double() * ratio + 0.5).to_int()
  if out_len == 0 {
    return Ok([])
  }

  let out : Array[Double] = Array::make(out_len, 0.0)
  let inv_ratio = orig_sr.to_double() / target_sr.to_double()

  // Nyquist anti-aliasing cutoff factor
  let scale = if target_sr < orig_sr {
    target_sr.to_double() / orig_sr.to_double()
  } else {
    1.0
  }
  let cutoff = 0.5 * scale * 0.95
  let pi = @math.PI
  let radius = (filter_size.to_double() / scale + 0.5).to_int()

  for i in 0..<out_len {
    let src_pos = i.to_double() * inv_ratio
    let center_idx = src_pos.to_int()
    let start_idx = if center_idx - radius < 0 {
      0
    } else {
      center_idx - radius
    }
    let end_idx = if center_idx + radius + 1 >= len {
      len - 1
    } else {
      center_idx + radius + 1
    }

    let mut sum_val = 0.0
    let mut sum_weight = 0.0

    for j in start_idx..<=end_idx {
      let delta = src_pos - j.to_double()
      let norm_delta = delta * scale
      if norm_delta.abs() <= filter_size.to_double() {
        // Hann apodization window
        let w = 0.5 + 0.5 * @math.cos(pi * norm_delta / filter_size.to_double())
        // Sinc function
        let sinc_val = if delta.abs() < 1.0e-9 {
          2.0 * cutoff
        } else {
          @math.sin(2.0 * pi * cutoff * delta) / (pi * delta)
        }
        let weight = w * sinc_val
        sum_val = sum_val + samples[j] * weight
        sum_weight = sum_weight + weight
      }
    }

    out[i] = if sum_weight.abs() > 1.0e-9 {
      sum_val / sum_weight
    } else if center_idx < len {
      samples[center_idx]
    } else {
      samples[len - 1]
    }
  }

  Ok(out)
}

///|
/// Greatest common divisor for rational resampling factor reduction.
fn gcd(a : Int, b : Int) -> Int {
  let mut x = if a < 0 { -a } else { a }
  let mut y = if b < 0 { -b } else { b }
  while y != 0 {
    let t = y
    y = x % y
    x = t
  }
  if x == 0 {
    1
  } else {
    x
  }
}

///|
/// Polyphase rational factor audio resampler (scipy.signal.resample_poly equivalent).
/// Uses precomputed polyphase FIR filter banks for fast, artifact-free up/downsampling.
pub fn resample_polyphase(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
  half_len? : Int = 10,
) -> Result[Array[Double], @types.MelError] {
  if orig_sr <= 0 {
    return Err(@types.MelError::InvalidSampleRate(orig_sr))
  }
  if target_sr <= 0 {
    return Err(@types.MelError::InvalidSampleRate(target_sr))
  }
  let len = samples.length()
  if len == 0 {
    return Ok([])
  }
  if orig_sr == target_sr {
    let out = Array::make(len, 0.0)
    for i in 0..<len {
      out[i] = samples[i]
    }
    return Ok(out)
  }

  // Reduce to coprime rational factors P / Q = target_sr / orig_sr
  let g = gcd(target_sr, orig_sr)
  let raw_up = target_sr / g
  let raw_down = orig_sr / g

  // If factors are very large, fall back to windowed sinc resampler
  if raw_up > 64 || raw_down > 128 {
    return resample_sinc(samples, orig_sr, target_sr)
  }

  let up = raw_up
  let down = raw_down
  let out_len = (len.to_double() * up.to_double() / down.to_double() + 0.5).to_int()
  if out_len <= 0 {
    return Ok([])
  }

  let max_factor = if up > down { up } else { down }
  let cutoff = 0.5 / max_factor.to_double()
  let pi = @math.PI

  // Build polyphase filter bank: 'up' subfilters of length 2 * half_len
  let filter_len = 2 * half_len
  let poly_filters : Array[Array[Double]] = Array::make(up, [])

  for p in 0..<up {
    let sub = Array::make(filter_len, 0.0)
    let mut sum_w = 0.0
    for j in 0..<filter_len {
      let t = (j - half_len).to_double() + p.to_double() / up.to_double()
      let norm_t = t / half_len.to_double()
      if norm_t.abs() <= 1.0 {
        let w = 0.5 + 0.5 * @math.cos(pi * norm_t)
        let sinc_val = if t.abs() < 1.0e-9 {
          2.0 * cutoff
        } else {
          @math.sin(2.0 * pi * cutoff * t) / (pi * t)
        }
        let weight = w * sinc_val
        sub[j] = weight
        sum_w = sum_w + weight
      }
    }
    if sum_w.abs() > 1.0e-9 {
      let inv_sum = 1.0 / sum_w
      for j in 0..<filter_len {
        sub[j] = sub[j] * inv_sum
      }
    }
    poly_filters[p] = sub
  }

  let out = Array::make(out_len, 0.0)

  // Stream convolution across polyphase subfilters
  for n in 0..<out_len {
    let m = n * down
    let phase = m % up
    let center_k = m / up
    let sub = poly_filters[phase]
    let mut acc = 0.0

    for j in 0..<filter_len {
      let src_idx = center_k + (j - half_len)
      if src_idx >= 0 && src_idx < len {
        acc = acc + samples[src_idx] * sub[j]
      }
    }
    out[n] = acc
  }

  Ok(out)
}

///|
/// Production-grade audio resampler automatically choosing optimal algorithm.
pub fn resample(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
) -> Result[Array[Double], @types.MelError] {
  resample_polyphase(samples, orig_sr, target_sr)
}
