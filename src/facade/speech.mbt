///|
/// Re-export LPC solver result.
pub type LpcResult = @lpc.LpcResult

///|
/// Re-export biased autocorrelation.
pub fn autocorrelation(
  samples : Array[Double],
  max_lag : Int32,
) -> Array[Double] {
  @lpc.autocorrelation(samples, max_lag)
}

///|
/// Re-export Levinson-Durbin recursion.
pub fn levinson_durbin(
  r : Array[Double],
  order : Int32,
) -> Result[@lpc.LpcResult, @types.MelError] {
  @lpc.levinson_durbin(r, order)
}

///|
/// Re-export LPC analysis on audio samples.
pub fn lpc(
  samples : Array[Double],
  order : Int32,
) -> Result[@lpc.LpcResult, @types.MelError] {
  @lpc.lpc(samples, order)
}

///|
/// Re-export LPC to LPCC conversion.
pub fn lpc_to_lpcc(
  lpc_coeffs : Array[Double],
  prediction_error : Double,
  n_lpcc : Int32,
) -> Array[Double] {
  @lpc.lpc_to_lpcc(lpc_coeffs, prediction_error, n_lpcc)
}

///|
/// Re-export LPC residual filtering.
pub fn lpc_residual(
  samples : Array[Double],
  lpc_coeffs : Array[Double],
) -> Array[Double] {
  @lpc.lpc_residual(samples, lpc_coeffs)
}

///|
/// Re-export frame-wise LPC feature extraction.
pub fn lpc_features(
  samples : Array[Double],
  order : Int32,
  frame_length : Int32,
  hop_length : Int32,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @lpc.lpc_features(samples, order, frame_length, hop_length)
}

///|
/// Re-export frame-wise LPCC feature extraction.
pub fn lpcc_features(
  samples : Array[Double],
  order : Int32,
  n_lpcc : Int32,
  frame_length : Int32,
  hop_length : Int32,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @lpc.lpcc_features(samples, order, n_lpcc, frame_length, hop_length)
}

///|
/// Re-export YIN pitch tracking configuration.
pub type YinConfig = @pitch.YinConfig

///|
/// Re-export Pitch tracking result.
pub type PitchTrack = @pitch.PitchTrack

///|
/// Re-export YIN difference function.
pub fn difference_function(
  frame : Array[Double],
  tau_max : Int32,
) -> Array[Double] {
  @pitch.difference_function(frame, tau_max)
}

///|
/// Re-export Cumulative Mean Normalized Difference Function (CMNDF).
pub fn cumulative_mean_normalized_difference(
  d : Array[Double],
) -> Array[Double] {
  @pitch.cumulative_mean_normalized_difference(d)
}

///|
/// Re-export single-frame YIN pitch estimation.
pub fn yin_frame(
  frame : Array[Double],
  sample_rate : Int32,
  f_min~ : Double = 65.0,
  f_max~ : Double = 2093.0,
  threshold~ : Double = 0.1,
) -> (Double, Double, Double) {
  @pitch.yin_frame(frame, sample_rate, f_min, f_max, threshold)
}

///|
/// Re-export YIN pitch tracking on audio samples.
pub fn pitch_yin(
  samples : Array[Double],
  sample_rate~ : Int32 = 16000,
  config~ : @pitch.YinConfig = @pitch.YinConfig::default(),
) -> Result[@pitch.PitchTrack, @types.MelError] {
  match @types.AudioBuffer::new(samples, sample_rate) {
    Ok(audio) => @pitch.pitch_yin(audio, config~)
    Err(e) => Err(e)
  }
}

///|
/// Re-export Formant types and configuration.
pub type Formant = @formant.Formant

///|
pub type FormantFrame = @formant.FormantFrame

///|
pub type FormantConfig = @formant.FormantConfig

///|
/// Re-export Durand-Kerner polynomial root solver.
pub fn durand_kerner(
  coeffs : Array[Double],
  max_iters~ : Int32 = 80,
  tol~ : Double = 1.0e-9,
) -> Array[@types.Complex] {
  @formant.durand_kerner(coeffs, max_iters~, tol~)
}

///|
/// Re-export Formant extraction on single audio frame.
pub fn formants_frame(
  frame : Array[Double],
  sample_rate : Int32,
  config~ : @formant.FormantConfig = @formant.FormantConfig::default(),
) -> Result[@formant.FormantFrame, @types.MelError] {
  @formant.formants_frame(frame, sample_rate, config~)
}

///|
/// Re-export Formant tracking across entire audio signal.
pub fn formant_track(
  samples : Array[Double],
  sample_rate~ : Int32 = 16000,
  config~ : @formant.FormantConfig = @formant.FormantConfig::default(),
) -> Result[Array[@formant.FormantFrame], @types.MelError] {
  @formant.formant_track(samples, sample_rate, config~)
}

///|
/// Re-export formant frequencies track extractor.
pub fn formant_frequencies(
  frames : Array[@formant.FormantFrame],
  formant_idx : Int32,
  fallback~ : Double = 0.0,
) -> Array[Double] {
  @formant.formant_frequencies(frames, formant_idx, fallback~)
}
