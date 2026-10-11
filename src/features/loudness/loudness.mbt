///|
/// Biquad second-order IIR filter coefficients.
pub(all) struct BiquadCoeffs {
  b0 : Double
  b1 : Double
  b2 : Double
  a1 : Double
  a2 : Double
} derive(Debug)

///|
/// Direct Form II Transposed Biquad Filter state.
pub(all) struct BiquadFilter {
  coeffs : BiquadCoeffs
  mut d1 : Double
  mut d2 : Double
} derive(Debug)

///|
/// Create a new Biquad filter instance.
pub fn BiquadFilter::new(coeffs : BiquadCoeffs) -> BiquadFilter {
  { coeffs, d1: 0.0, d2: 0.0, }
}

///|
/// Process a single sample through the biquad filter.
pub fn BiquadFilter::process_sample(self : BiquadFilter, x : Double) -> Double {
  let y = self.coeffs.b0 * x + self.d1
  self.d1 = self.coeffs.b1 * x - self.coeffs.a1 * y + self.d2
  self.d2 = self.coeffs.b2 * x - self.coeffs.a2 * y
  y
}

///|
/// Filter an array of samples through the biquad filter.
pub fn BiquadFilter::filter_array(
  self : BiquadFilter,
  samples : Array[Double],
) -> Array[Double] {
  let len = samples.length()
  let out : Array[Double] = Array::make(len, 0.0)
  for i in 0..<len {
    out[i] = self.process_sample(samples[i])
  }
  out
}

///|
/// Reset filter internal memory states.
pub fn BiquadFilter::reset(self : BiquadFilter) -> Unit {
  self.d1 = 0.0
  self.d2 = 0.0
}

///|
/// Helper log10 function.
fn log10(x : Double) -> Double {
  @math.ln(x) / @math.ln(10.0)
}

///|
/// Compute Stage 1 High-Shelf (Pre-filter) coefficients for given sample rate (ITU-R BS.1770-4).
pub fn pre_filter_coeffs(sample_rate : Int) -> BiquadCoeffs {
  if sample_rate == 48000 {
    return {
      b0: 1.53512485958697,
      b1: -2.69169618940638,
      b2: 1.19839281085285,
      a1: -1.69065929318241,
      a2: 0.73248077421585,
    }
  }
  let fs = sample_rate.to_double()
  let db = 3.99984385397
  let f0 = 1681.9744509555319
  let q = 0.7071752369278436
  let k = @math.tan(@math.PI * f0 / fs)
  let vh = @math.pow(10.0, db / 20.0)
  let vb = @math.pow(vh, 0.499666774155)
  let a0 = 1.0 + k / q + k * k
  let b0 = (vh + vb * k / q + k * k) / a0
  let b1 = 2.0 * (k * k - vh) / a0
  let b2 = (vh - vb * k / q + k * k) / a0
  let a1 = 2.0 * (k * k - 1.0) / a0
  let a2 = (1.0 - k / q + k * k) / a0
  { b0, b1, b2, a1, a2, }
}

///|
/// Compute Stage 2 High-Pass (RLB weighting) coefficients for given sample rate (ITU-R BS.1770-4).
pub fn rlb_filter_coeffs(sample_rate : Int) -> BiquadCoeffs {
  if sample_rate == 48000 {
    return {
      b0: 1.0,
      b1: -2.0,
      b2: 1.0,
      a1: -1.99004745483398,
      a2: 0.99007225034606,
    }
  }
  let fs = sample_rate.to_double()
  let f0 = 38.13547087602444
  let q = 0.5003270373253953
  let k = @math.tan(@math.PI * f0 / fs)
  let a0 = 1.0 + k / q + k * k
  let b0 = 1.0
  let b1 = -2.0
  let b2 = 1.0
  let a1 = 2.0 * (k * k - 1.0) / a0
  let a2 = (1.0 - k / q + k * k) / a0
  { b0, b1, b2, a1, a2, }
}

///|
/// Apply cascaded K-weighting filters (Pre-filter then RLB weighting filter) to audio samples.
pub fn apply_k_weighting(
  samples : Array[Double],
  sample_rate : Int,
) -> Array[Double] {
  let stage1 = BiquadFilter::new(pre_filter_coeffs(sample_rate))
  let stage2 = BiquadFilter::new(rlb_filter_coeffs(sample_rate))
  let temp = stage1.filter_array(samples)
  stage2.filter_array(temp)
}

///|
/// Comprehensive ITU-R BS.1770-4 / EBU R128 Loudness Result.
pub(all) struct LoudnessResult {
  integrated : Double
  loudness_range : Double
  momentary_max : Double
  short_term_max : Double
  true_peak : Double
} derive(Debug)

///|
/// Calculate empirical percentile from sorted array (0.0 to 100.0).
fn percentile(sorted : Array[Double], p : Double) -> Double {
  let n = sorted.length()
  if n == 0 {
    return 0.0
  }
  if n == 1 {
    return sorted[0]
  }
  let pos = (n - 1).to_double() * p / 100.0
  let idx = pos.to_int()
  let frac = pos - idx.to_double()
  if idx >= n - 1 {
    sorted[n - 1]
  } else {
    sorted[idx] * (1.0 - frac) + sorted[idx + 1] * frac
  }
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
/// Calculate True Peak in dBFS via 4x oversampling.
pub fn true_peak_db(
  samples : Array[Double],
  sample_rate : Int,
) -> Result[Double, @types.MelError] {
  if sample_rate <= 0 || sample_rate > 536870911 {
    return Err(InvalidSampleRate(sample_rate))
  }
  if samples.is_empty() {
    return Ok(-70.0)
  }
  let oversampled_sr = sample_rate * 4
  let oversampled = match
    @resample.resample(samples, sample_rate, oversampled_sr) {
    Ok(s) => s
    Err(e) => return Err(e)
  }
  let mut peak = 0.0
  for s in oversampled {
    let abs_s = s.abs()
    if abs_s > peak {
      peak = abs_s
    }
  }
  if peak < 1.0e-7 {
    Ok(-140.0)
  } else {
    Ok(20.0 * log10(peak))
  }
}

///|
/// Measure ITU-R BS.1770-4 Loudness for a single-channel AudioBuffer.
pub fn loudness_meter(
  audio : @types.AudioBuffer,
) -> Result[LoudnessResult, @types.MelError] {
  let sr = audio.sample_rate
  if sr <= 0 {
    return Err(InvalidSampleRate(sr))
  }
  let n_samples = audio.length()
  if n_samples == 0 {
    return Err(EmptyAudio)
  }

  // 1. Apply K-weighting
  let filtered = apply_k_weighting(audio.samples, sr)

  // 2. Compute momentary blocks (400ms rectangular window, 100ms step = 75% overlap)
  let block_len = (0.4 * sr.to_double()).to_int()
  let step = (0.1 * sr.to_double()).to_int()
  if block_len <= 0 || step <= 0 {
    return Err(InvalidSampleRate(sr))
  }

  let powers : Array[Double] = []
  let mut start = 0
  let mut max_momentary = -140.0

  while start + block_len <= n_samples {
    let mut sum_sq = 0.0
    for i in 0..<block_len {
      let s = filtered[start + i]
      sum_sq = sum_sq + s * s
    }
    let p = sum_sq / block_len.to_double()
    powers.push(p)

    let l = if p > 1.0e-12 { -0.691 + 10.0 * log10(p) } else { -140.0 }
    if l > max_momentary {
      max_momentary = l
    }
    start = start + step
  }

  // If audio is shorter than 400ms, compute full-buffer power
  if powers.is_empty() {
    let mut sum_sq = 0.0
    for s in filtered {
      sum_sq = sum_sq + s * s
    }
    let p = sum_sq / n_samples.to_double()
    powers.push(p)
    let l = if p > 1.0e-12 { -0.691 + 10.0 * log10(p) } else { -140.0 }
    max_momentary = l
  }

  // 3. Compute short-term blocks (3.0s rectangular window, 1.0s step)
  let st_len = (3.0 * sr.to_double()).to_int()
  let st_step = (1.0 * sr.to_double()).to_int()
  let st_powers : Array[Double] = []
  let mut st_start = 0
  let mut max_short_term = -140.0

  while st_start + st_len <= n_samples {
    let mut sum_sq = 0.0
    for i in 0..<st_len {
      let s = filtered[st_start + i]
      sum_sq = sum_sq + s * s
    }
    let p = sum_sq / st_len.to_double()
    st_powers.push(p)
    let l = if p > 1.0e-12 { -0.691 + 10.0 * log10(p) } else { -140.0 }
    if l > max_short_term {
      max_short_term = l
    }
    st_start = st_start + st_step
  }
  if st_powers.is_empty() {
    max_short_term = max_momentary
  }

  // 4. Integrated loudness with ITU-R BS.1770 two-stage gating
  // Stage 1: Absolute threshold Gamma_a = -70.0 LKFS
  let gamma_a = -70.0
  let g1_powers : Array[Double] = []
  for p in powers {
    let l = if p > 1.0e-12 { -0.691 + 10.0 * log10(p) } else { -140.0 }
    if l >= gamma_a {
      g1_powers.push(p)
    }
  }

  let integrated = if g1_powers.is_empty() {
    -70.0
  } else {
    let mut sum_g1 = 0.0
    for p in g1_powers {
      sum_g1 = sum_g1 + p
    }
    let avg_g1 = sum_g1 / g1_powers.length().to_double()
    // Stage 2: Relative threshold Gamma_r = -0.691 + 10 * log10(avg_g1) - 10.0
    let gamma_r = -0.691 + 10.0 * log10(avg_g1) - 10.0
    let g2_powers : Array[Double] = []
    for p in g1_powers {
      let l = -0.691 + 10.0 * log10(p)
      if l >= gamma_r {
        g2_powers.push(p)
      }
    }
    if g2_powers.is_empty() {
      -70.0
    } else {
      let mut sum_g2 = 0.0
      for p in g2_powers {
        sum_g2 = sum_g2 + p
      }
      let avg_g2 = sum_g2 / g2_powers.length().to_double()
      -0.691 + 10.0 * log10(avg_g2)
    }
  }

  // 5. Loudness Range (LRA) based on short-term loudness distribution
  let lra_loudness : Array[Double] = []
  let mut absolute_power = 0.0
  let mut absolute_count = 0
  for p in st_powers {
    if p > 1.0e-12 && -0.691 + 10.0 * log10(p) >= -70.0 {
      absolute_power = absolute_power + p
      absolute_count = absolute_count + 1
    }
  }
  let relative_gate = if absolute_count > 0 {
    -0.691 + 10.0 * log10(absolute_power / absolute_count.to_double()) - 20.0
  } else {
    -70.0
  }
  for p in st_powers {
    let l = if p > 1.0e-12 { -0.691 + 10.0 * log10(p) } else { -140.0 }
    if l >= -70.0 && l >= relative_gate {
      lra_loudness.push(l)
    }
  }
  let loudness_range = if lra_loudness.length() < 2 {
    0.0
  } else {
    sort_doubles(lra_loudness)
    let p10 = percentile(lra_loudness, 10.0)
    let p95 = percentile(lra_loudness, 95.0)
    p95 - p10
  }

  // 6. True Peak in dBFS
  let true_peak = match true_peak_db(audio.samples, sr) {
    Ok(tp) => tp
    Err(e) => return Err(e)
  }

  Ok({
    integrated,
    loudness_range,
    momentary_max: max_momentary,
    short_term_max: max_short_term,
    true_peak,
  })
}

///|
pub extend BiquadCoeffs with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend BiquadFilter with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend LoudnessResult with @moonbitlang/core/debug.Debug::{to_repr}
