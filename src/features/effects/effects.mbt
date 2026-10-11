///|
/// Audio Effects: Phase Vocoder, Time Stretching, and Pitch Shifting
let pi : Double = 3.14159265358979323846264338327950288

///|
let two_pi : Double = 2.0 * pi

///|
/// Phase Vocoder time stretching on complex STFT frames.
/// Given STFT frames of shape [n_frames][n_bins], stretches time by `rate > 0`.
/// Preserves spectral magnitude envelope and tracks instantaneous frequency progression.
pub fn phase_vocoder(
  frames : Array[Array[@types.Complex]],
  rate : Double,
  hop_length : Int,
  n_fft : Int,
) -> Result[Array[Array[@types.Complex]], @types.MelError] {
  if !@types.is_finite(rate) || rate <= 0.0 {
    return Err(
      @types.MelError::DimensionMismatch("Vocoder rate must be positive"),
    )
  }
  let n_frames = frames.length()
  if n_fft <= 0 {
    return Err(InvalidFftSize(n_fft))
  }
  if hop_length <= 0 {
    return Err(InvalidHopLength(hop_length))
  }
  if n_frames == 0 {
    return Err(EmptyAudio)
  }
  let n_bins = n_fft / 2 + 1
  for f in 0..<n_frames {
    if frames[f].length() != n_bins {
      return Err(DimensionMismatch("Expected frame with \{n_bins} bins"))
    }
  }

  // Exact 1.0 rate fast-path
  if (rate - 1.0).abs() < 1.0e-9 {
    let copy_frames : Array[Array[@types.Complex]] = Array::make(n_frames, [])
    for i in 0..<n_frames {
      let f = Array::make(n_bins, @types.Complex::{ re: 0.0, im: 0.0, })
      for k in 0..<n_bins {
        f[k] = frames[i][k]
      }
      copy_frames[i] = f
    }
    return Ok(copy_frames)
  }

  // Output frame count
  let n_out = (n_frames.to_double() / rate).ceil().to_int()
  let out_frames_count = if n_out <= 0 { 1 } else { n_out }
  let out_frames : Array[Array[@types.Complex]] = Array::make(
    out_frames_count,
    [],
  )

  // Phase advance expected per hop for each frequency bin
  let dphi_exp : Array[Double] = Array::make(n_bins, 0.0)
  for k in 0..<n_bins {
    dphi_exp[k] = two_pi *
      k.to_double() *
      hop_length.to_double() /
      n_fft.to_double()
  }

  // Phase accumulator initialized from first frame
  let phase_acc : Array[Double] = Array::make(n_bins, 0.0)
  let first_frame = Array::make(n_bins, @types.Complex::{ re: 0.0, im: 0.0, })
  for k in 0..<n_bins {
    let re = frames[0][k].re
    let im = frames[0][k].im
    phase_acc[k] = @math.atan2(im, re)
    first_frame[k] = frames[0][k]
  }
  out_frames[0] = first_frame

  // Synthesis loop for subsequent frames
  for m in 1..<out_frames_count {
    let t = m.to_double() * rate
    let f0 = t.to_int()
    let mut f1 = f0 + 1
    let mut alpha = t - f0.to_double()

    let safe_f0 = if f0 >= n_frames - 1 {
      f1 = n_frames - 1
      alpha = 0.0
      n_frames - 1
    } else {
      if f1 >= n_frames {
        f1 = n_frames - 1
      }
      f0
    }

    let frame_m : Array[@types.Complex] = Array::make(n_bins, @types.Complex::{
      re: 0.0,
      im: 0.0,
    })

    for k in 0..<n_bins {
      let re0 = frames[safe_f0][k].re
      let im0 = frames[safe_f0][k].im
      let re1 = frames[f1][k].re
      let im1 = frames[f1][k].im

      let mag0 = (re0 * re0 + im0 * im0).sqrt()
      let mag1 = (re1 * re1 + im1 * im1).sqrt()
      let mag = (1.0 - alpha) * mag0 + alpha * mag1

      let theta0 = @math.atan2(im0, re0)
      let theta1 = @math.atan2(im1, re1)
      let delta_theta = theta1 - theta0

      // Instantaneous frequency deviation unwrapped to [-pi, pi]
      let dphase = delta_theta - dphi_exp[k]
      let wrapped = dphase - two_pi * (dphase / two_pi + 0.5).floor()
      let freq_dev = dphi_exp[k] + wrapped

      phase_acc[k] = phase_acc[k] + freq_dev

      let syn_re = mag * @math.cos(phase_acc[k])
      let syn_im = mag * @math.sin(phase_acc[k])
      frame_m[k] = { re: syn_re, im: syn_im, }
    }

    out_frames[m] = frame_m
  }

  Ok(out_frames)
}

///|
/// Time-stretch audio signal by factor `rate > 0` without altering pitch.
/// - `rate > 1.0`: speeds up audio (shorter duration).
/// - `rate < 1.0`: slows down audio (longer duration).
pub fn time_stretch(
  samples : Array[Double],
  rate : Double,
  config : @types.FeatureConfig,
) -> Result[Array[Double], @types.MelError] {
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  if !@types.is_finite(rate) || rate <= 0.0 {
    return Err(
      @types.MelError::DimensionMismatch("time_stretch rate must be positive"),
    )
  }
  if (rate - 1.0).abs() < 1.0e-9 {
    let out = Array::make(samples.length(), 0.0)
    for i in 0..<samples.length() {
      out[i] = samples[i]
    }
    return Ok(out)
  }

  let frames = match @stft.stft_complex(samples, config) {
    Ok(f) => f
    Err(e) => return Err(e)
  }

  let stretched_frames = match
    phase_vocoder(frames, rate, config.hop_length, config.n_fft) {
    Ok(sf) => sf
    Err(e) => return Err(e)
  }

  let target_len = (samples.length().to_double() / rate + 0.5).to_int()
  @stft.istft(stretched_frames, config, target_len)
}

///|
/// Pitch-shift audio signal by `n_steps` semitones without altering duration or tempo.
/// `n_steps > 0`: pitch shifts up (e.g. +12 = 1 octave higher).
/// `n_steps < 0`: pitch shifts down (e.g. -12 = 1 octave lower).
pub fn pitch_shift(
  samples : Array[Double],
  sr : Int,
  n_steps : Double,
  config : @types.FeatureConfig,
) -> Result[Array[Double], @types.MelError] {
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  if sr <= 0 {
    return Err(InvalidSampleRate(sr))
  }
  if !@types.is_finite(n_steps) {
    return Err(DimensionMismatch("Pitch shift must be finite"))
  }
  if n_steps.abs() < 1.0e-6 {
    let out = Array::make(samples.length(), 0.0)
    for i in 0..<samples.length() {
      out[i] = samples[i]
    }
    return Ok(out)
  }

  // Pitch scale factor s = 2^(n_steps / 12)
  let s = @math.pow(2.0, n_steps / 12.0)
  if s <= 0.0 {
    return Err(@types.MelError::DimensionMismatch("Invalid pitch shift step"))
  }

  // 1. Time stretch by rate = 1.0 / s (scales duration to L * s)
  let stretched = match time_stretch(samples, 1.0 / s, config) {
    Ok(res) => res
    Err(e) => return Err(e)
  }

  // 2. Resample back to original length L (which multiplies frequency by s)
  let orig_len = samples.length()
  @resample.resample_to_length(stretched, orig_len)
}
