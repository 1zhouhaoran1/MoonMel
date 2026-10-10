///|
/// Extract Root Mean Square (RMS) frame energy from AudioBuffer.
/// Matches librosa.feature.rms(y=y, frame_length=frame_length, hop_length=hop_length, center=center).
pub fn compute_rms(
  audio : @types.AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  if frame_length <= 0 {
    return Err(InvalidFftSize(frame_length))
  }
  if hop_length <= 0 {
    return Err(InvalidHopLength(hop_length))
  }
  let samples = audio.samples
  if samples.is_empty() {
    return Err(EmptyAudio)
  }

  let padded = if center {
    let pad_width = frame_length / 2
    @window.pad_reflect(samples, pad_width)
  } else {
    samples
  }

  let total_len = padded.length()
  if total_len < frame_length {
    return Err(DimensionMismatch("Audio length shorter than frame length"))
  }

  let n_frames = (total_len - frame_length) / hop_length + 1
  let out = @types.FeatureMatrix::zeros(1, n_frames)
  let inv_l = 1.0 / frame_length.to_double()

  for f in 0..<n_frames {
    let start = f * hop_length
    let mut sum_sq = 0.0
    for i in 0..<frame_length {
      let x = padded[start + i]
      sum_sq = sum_sq + x * x
    }
    let rms = (sum_sq * inv_l).sqrt()
    out.set(0, f, rms)
  }
  Ok(out)
}

///|
/// Extract total sum-of-squares frame energy from AudioBuffer.
pub fn compute_energy(
  audio : @types.AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  if frame_length <= 0 {
    return Err(InvalidFftSize(frame_length))
  }
  if hop_length <= 0 {
    return Err(InvalidHopLength(hop_length))
  }
  let samples = audio.samples
  if samples.is_empty() {
    return Err(EmptyAudio)
  }

  let padded = if center {
    let pad_width = frame_length / 2
    @window.pad_reflect(samples, pad_width)
  } else {
    samples
  }

  let total_len = padded.length()
  if total_len < frame_length {
    return Err(DimensionMismatch("Audio length shorter than frame length"))
  }

  let n_frames = (total_len - frame_length) / hop_length + 1
  let out = @types.FeatureMatrix::zeros(1, n_frames)

  for f in 0..<n_frames {
    let start = f * hop_length
    let mut sum_sq = 0.0
    for i in 0..<frame_length {
      let x = padded[start + i]
      sum_sq = sum_sq + x * x
    }
    out.set(0, f, sum_sq)
  }
  Ok(out)
}
