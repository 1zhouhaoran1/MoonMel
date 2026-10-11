///|
/// Formant Estimation & Polynomial Root Solving via LPC and Durand-Kerner
let pi : Double = 3.14159265358979323846264338327950288

///|
let two_pi : Double = 2.0 * pi

///|
/// Formant represents an acoustic resonance of the vocal tract.
pub(all) struct Formant {
  frequency : Double // Center frequency in Hz (e.g. F1, F2, F3)
  bandwidth : Double // 3dB bandwidth in Hz
} derive(Debug, Eq)

///|
/// Formant analysis result for a single audio frame.
pub(all) struct FormantFrame {
  formants : Array[Formant]
} derive(Debug)

///|
/// Configuration parameters for formant extraction.
pub(all) struct FormantConfig {
  lpc_order : Int // Order of LPC all-pole model (default: 12)
  min_frequency : Double // Minimum valid formant frequency in Hz (default: 50.0)
  max_frequency : Double // Maximum valid formant frequency in Hz (default: 5000.0)
  max_bandwidth : Double // Maximum valid bandwidth in Hz (default: 2500.0)
  pre_emphasis : Double // First-order high-frequency pre-emphasis factor (default: 0.97)
  frame_length : Int // Analysis frame length in samples (default: 400, 25ms @ 16kHz)
  hop_length : Int // Frame step in samples (default: 160, 10ms @ 16kHz)
} derive(Debug)

///|
/// Default configuration for speech formant analysis at 16 kHz.
pub fn FormantConfig::default() -> FormantConfig {
  {
    lpc_order: 12,
    min_frequency: 50.0,
    max_frequency: 5000.0,
    max_bandwidth: 2500.0,
    pre_emphasis: 0.97,
    frame_length: 400,
    hop_length: 160,
  }
}

///|
/// Durand-Kerner (Weierstrass) simultaneous root-finding algorithm for monic polynomial:
/// P(z) = z^p + coeffs[0] * z^(p-1) + coeffs[1] * z^(p-2) + ... + coeffs[p-1] = 0.
pub fn durand_kerner(
  coeffs : Array[Double],
  max_iters? : Int = 80,
  tol? : Double = 1.0e-9,
) -> Array[@types.Complex] {
  let p = coeffs.length()
  if p == 0 {
    return []
  }
  if p == 1 {
    return [@types.complex(-coeffs[0], 0.0)]
  }
  if p == 2 {
    let a0 = coeffs[0]
    let a1 = coeffs[1]
    let delta = a0 * a0 - 4.0 * a1
    if delta >= 0.0 {
      let sqrt_d = delta.sqrt()
      return [
        @types.complex((-a0 + sqrt_d) / 2.0, 0.0),
        @types.complex((-a0 - sqrt_d) / 2.0, 0.0),
      ]
    } else {
      let sqrt_neg = (-delta).sqrt()
      return [
        @types.complex(-a0 / 2.0, sqrt_neg / 2.0),
        @types.complex(-a0 / 2.0, -sqrt_neg / 2.0),
      ]
    }
  }

  // Geometric initialization on complex circle with Aberth spacing
  let z : Array[@types.Complex] = Array::make(p, @types.complex(0.0, 0.0))
  for k in 0..<p {
    let theta = (two_pi * k.to_double() + 0.5) / p.to_double()
    let r = 0.8 + 0.3 * (k.to_double() / p.to_double())
    z[k] = @types.complex(r * @math.cos(theta), r * @math.sin(theta))
  }

  for _iter in 0..<max_iters {
    let mut max_step = 0.0
    for k in 0..<p {
      // Evaluate P(z[k]) using Horner's method
      let mut p_val = @types.complex(1.0, 0.0)
      for c in 0..<p {
        p_val = p_val.mul(z[k]).add(@types.complex(coeffs[c], 0.0))
      }

      // Evaluate denominator: prod_{j != k} (z[k] - z[j])
      let mut denom = @types.complex(1.0, 0.0)
      for j in 0..<p {
        if j != k {
          let diff = z[k].sub(z[j])
          denom = denom.mul(diff)
        }
      }

      if denom.abs2() > 1.0e-20 {
        let step = p_val.div(denom)
        z[k] = z[k].sub(step)
        let step_mag = step.abs()
        if step_mag > max_step {
          max_step = step_mag
        }
      }
    }
    if max_step < tol {
      break
    }
  }

  z
}

///|
/// Extract FormantFrame from LPC prediction coefficients.
pub fn formants_from_lpc(
  lpc_coeffs : Array[Double],
  sample_rate : Int,
  config : FormantConfig,
) -> FormantFrame {
  // Positive predictor coefficients map to the denominator 1 - sum(a*z^-k).
  let polynomial = lpc_coeffs.map(fn(coefficient) { -coefficient })
  let roots = durand_kerner(polynomial)
  let cand : Array[Formant] = []
  let sr_d = sample_rate.to_double()

  for k in 0..<roots.length() {
    let root = roots[k]
    // Upper half-plane roots only
    if root.im > 1.0e-7 {
      let r = root.abs()
      let theta = @math.atan2(root.im, root.re)
      let freq = theta * sr_d / two_pi
      let bw = if r < 1.0 && r > 1.0e-6 {
        -sr_d * @math.ln(r) / pi
      } else {
        0.0
      }

      if freq >= config.min_frequency &&
        freq <= config.max_frequency &&
        bw > 0.0 &&
        bw <= config.max_bandwidth {
        cand.push({ frequency: freq, bandwidth: bw, })
      }
    }
  }

  // Sort ascending by frequency
  let n = cand.length()
  for i in 0..<n {
    for j = i + 1; j < n; j = j + 1 {
      if cand[j].frequency < cand[i].frequency {
        let tmp = cand[i]
        cand[i] = cand[j]
        cand[j] = tmp
      }
    }
  }

  { formants: cand, }
}

///|
/// Estimate FormantFrame on a single audio window.
pub fn formants_frame(
  frame : Array[Double],
  sample_rate : Int,
  config? : FormantConfig = FormantConfig::default(),
) -> Result[FormantFrame, @types.MelError] {
  let flen = frame.length()
  if flen == 0 {
    return Err(EmptyAudio)
  }
  if sample_rate <= 0 {
    return Err(InvalidSampleRate(sample_rate))
  }

  // 1. Pre-emphasis filter
  if config.lpc_order <= 0 || config.lpc_order >= flen {
    return Err(DimensionMismatch("LPC order must be in [1, frame_length)"))
  }
  if !@types.is_finite(config.pre_emphasis) ||
    !@types.is_finite(config.min_frequency) ||
    !@types.is_finite(config.max_frequency) ||
    !@types.is_finite(config.max_bandwidth) ||
    config.min_frequency < 0.0 ||
    config.max_frequency <= config.min_frequency ||
    config.max_bandwidth <= 0.0 {
    return Err(
      DimensionMismatch("Invalid formant frequency range or pre-emphasis"),
    )
  }
  let pe : Array[Double] = Array::make(flen, 0.0)
  pe[0] = frame[0]
  for i in 1..<flen {
    pe[i] = frame[i] - config.pre_emphasis * frame[i - 1]
  }

  // 2. Windowing
  let win = @window.create_window(PeriodicHann, flen)
  let windowed : Array[Double] = Array::make(flen, 0.0)
  for i in 0..<flen {
    windowed[i] = pe[i] * win[i]
  }

  // 3. Autocorrelation & Levinson-Durbin LPC
  let r = @lpc.autocorrelation(windowed, config.lpc_order)
  let lpc_res = match @lpc.levinson_durbin(r, config.lpc_order) {
    Ok(res) => res
    Err(e) => return Err(e)
  }

  Ok(formants_from_lpc(lpc_res.coeffs, sample_rate, config))
}

///|
/// Extract time-varying formant tracks across an entire audio signal.
pub fn formant_track(
  samples : Array[Double],
  sample_rate : Int,
  config? : FormantConfig = FormantConfig::default(),
) -> Result[Array[FormantFrame], @types.MelError] {
  let len = samples.length()
  if len == 0 {
    return Err(EmptyAudio)
  }
  if sample_rate <= 0 {
    return Err(InvalidSampleRate(sample_rate))
  }
  let flen = config.frame_length
  let hop = config.hop_length
  if flen <= 0 {
    return Err(InvalidFftSize(flen))
  }
  if hop <= 0 {
    return Err(InvalidHopLength(hop))
  }
  if len < flen {
    return Err(DimensionMismatch("Audio length shorter than frame_length"))
  }

  let n_frames = 1 + (len - flen) / hop
  let frames : Array[FormantFrame] = Array::make(n_frames, { formants: [], })
  let frame_buf : Array[Double] = Array::make(flen, 0.0)

  for f_idx in 0..<n_frames {
    let start = f_idx * hop
    for i in 0..<flen {
      frame_buf[i] = samples[start + i]
    }
    match formants_frame(frame_buf, sample_rate, config~) {
      Ok(ff) => frames[f_idx] = ff
      Err(e) => return Err(e)
    }
  }

  Ok(frames)
}

///|
/// Extract a specific formant frequency track across frames (e.g. 0 for F1, 1 for F2, 2 for F3).
pub fn formant_frequencies(
  frames : Array[FormantFrame],
  formant_idx : Int,
  fallback? : Double = 0.0,
) -> Array[Double] {
  let n = frames.length()
  let out : Array[Double] = Array::make(n, fallback)
  for i in 0..<n {
    if formant_idx >= 0 && formant_idx < frames[i].formants.length() {
      out[i] = frames[i].formants[formant_idx].frequency
    }
  }
  out
}

///|
pub extend Formant with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Formant with Eq::{not_equal, equal}

///|
pub extend FormantConfig with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FormantFrame with @moonbitlang/core/debug.Debug::{to_repr}
