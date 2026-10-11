///|
/// Center a short analysis window inside a full FFT frame.
/// The sample position and window position share the same offset.
pub fn window_frame(
  samples : Array[Double],
  start : Int,
  window : Array[Double],
  output : Array[Double],
) -> Unit {
  output.fill(0.0)
  let offset = (output.length() - window.length()) / 2
  for j in 0..<window.length() {
    output[offset + j] = samples[start + offset + j] * window[j]
  }
}

///|
/// Validate and prepare one shared framing convention for offline transforms.
pub fn prepare(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[Array[Double], @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  match @types.validate_samples(samples) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let audio = if config.center {
    @window.pad_reflect(samples, config.n_fft / 2)
  } else {
    samples
  }
  if audio.length() < config.n_fft {
    return Err(
      DimensionMismatch("Audio length after padding is shorter than n_fft"),
    )
  }
  Ok(audio)
}
