///|
/// Re-export Mel Filterbank constructor.
pub fn mel_filterbank(
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @mel.mel_filterbank(config)
}

///|
/// Re-export Mel Spectrogram extraction.
pub fn mel_spectrogram(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @mel.mel_spectrogram(samples, config)
}

///|
/// Re-export Log-Mel Spectrogram extraction.
pub fn log_mel_spectrogram(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @mfcc.log_mel_spectrogram(samples, config)
}

///|
/// Re-export MFCC extraction.
pub fn mfcc(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @mfcc.mfcc(samples, config)
}

///|
/// Re-export power to decibel conversion.
pub fn power_to_db(
  matrix : @types.FeatureMatrix,
  ref_val : Double,
  amin : Double,
  top_db : Double,
) -> @types.FeatureMatrix {
  @mfcc.power_to_db(matrix, ref_val, amin, top_db)
}

///|
/// Re-export DCT-II calculation.
pub fn dct_ii(
  input : Array[Double],
  n_out : Int32,
  norm_ortho : Bool,
) -> Array[Double] {
  @mfcc.dct_ii(input, n_out, norm_ortho)
}

///|
/// Re-export Delta / Delta-Delta dynamic feature calculation.
pub fn compute_delta(
  matrix : @types.FeatureMatrix,
  width~ : Int32 = 9,
  order~ : Int32 = 1,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @delta.compute_delta(matrix, width~, order~)
}

///|
/// Re-export Root Mean Square (RMS) frame energy extraction.
pub fn compute_rms(
  audio : @types.AudioBuffer,
  frame_length~ : Int32 = 2048,
  hop_length~ : Int32 = 512,
  center~ : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @energy.compute_rms(audio, frame_length~, hop_length~, center~)
}

///|
/// Re-export total frame sum-of-squares energy extraction.
pub fn compute_energy(
  audio : @types.AudioBuffer,
  frame_length~ : Int32 = 2048,
  hop_length~ : Int32 = 512,
  center~ : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @energy.compute_energy(audio, frame_length~, hop_length~, center~)
}

///|
/// Re-export Spectral Centroid extraction.
pub fn spectral_centroid(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.spectral_centroid(samples, config~)
}

///|
/// Re-export Spectral Rolloff extraction.
pub fn spectral_rolloff(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  roll_percent~ : Double = 0.85,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.spectral_rolloff(samples, config~, roll_percent~)
}

///|
/// Re-export Spectral Flatness extraction.
pub fn spectral_flatness(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  amin~ : Double = 1.0e-10,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.spectral_flatness(samples, config~, amin~)
}

///|
/// Re-export Zero-Crossing Rate extraction.
pub fn zero_crossing_rate(
  audio : @types.AudioBuffer,
  frame_length~ : Int32 = 2048,
  hop_length~ : Int32 = 512,
  center~ : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.zero_crossing_rate(audio, frame_length~, hop_length~, center~)
}

///|
/// Re-export Chroma normalization enum.
pub type ChromaNorm = @chroma.ChromaNorm

///|
/// Re-export pitch class name mapping.
pub fn pitch_class_name(idx : Int32) -> String {
  @chroma.pitch_class_name(idx)
}

///|
/// Re-export Chroma filterbank generation.
pub fn chroma_filterbank(
  sample_rate : Int32,
  n_fft : Int32,
  tuning~ : Double = 0.0,
  f_min~ : Double = 0.0,
) -> @types.FeatureMatrix {
  @chroma.chroma_filterbank(sample_rate, n_fft, tuning, f_min)
}

///|
/// Re-export Chroma from spectrogram.
pub fn chroma_from_spectrogram(
  spectrogram : @types.FeatureMatrix,
  sample_rate : Int32,
  n_fft : Int32,
  norm~ : @chroma.ChromaNorm = @chroma.ChromaNorm::None,
  tuning~ : Double = 0.0,
  f_min~ : Double = 0.0,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @chroma.chroma_from_spectrogram(
    spectrogram, sample_rate, n_fft, norm, tuning, f_min,
  )
}

///|
/// Re-export 12-bin Chroma STFT feature extraction.
pub fn chroma_stft(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  norm~ : @chroma.ChromaNorm = @chroma.ChromaNorm::None,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @chroma.chroma_stft(samples, config, norm)
}

///|
/// Re-export Constant-Q Transform config.
pub type CqtConfig = @cqt.CqtConfig

///|
/// Re-export CQT center frequencies calculation.
pub fn cqt_frequencies(config : @cqt.CqtConfig) -> Array[Double] {
  @cqt.cqt_frequencies(config)
}

///|
/// Re-export Constant-Q Transform (CQT) feature extraction.
pub fn cqt(
  samples : Array[Double],
  config~ : @cqt.CqtConfig = @cqt.CqtConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @cqt.cqt(samples, config~)
}

///|
/// Re-export HPSS mask mode.
pub type MaskMode = @hpss.MaskMode

///|
/// Re-export HPSS configuration.
pub type HpssConfig = @hpss.HpssConfig

///|
/// Re-export HPSS separation result.
pub type HpssResult = @hpss.HpssResult

///|
/// Re-export 1D median filter.
pub fn median_filter_1d(
  arr : Array[Double],
  kernel_size : Int32,
) -> Array[Double] {
  @hpss.median_filter_1d(arr, kernel_size)
}

///|
/// Re-export 2D median filter along time axis.
pub fn median_filter_time(
  matrix : @types.FeatureMatrix,
  kernel_size : Int32,
) -> @types.FeatureMatrix {
  @hpss.median_filter_time(matrix, kernel_size)
}

///|
/// Re-export 2D median filter along frequency axis.
pub fn median_filter_freq(
  matrix : @types.FeatureMatrix,
  kernel_size : Int32,
) -> @types.FeatureMatrix {
  @hpss.median_filter_freq(matrix, kernel_size)
}

///|
/// Re-export Harmonic-Percussive Source Separation (HPSS) on spectrogram.
pub fn hpss(
  spec : @types.FeatureMatrix,
  config~ : @hpss.HpssConfig = @hpss.HpssConfig::default(),
) -> @hpss.HpssResult {
  @hpss.hpss(spec, config)
}

///|
/// Re-export HPSS directly from PCM audio samples.
pub fn hpss_from_audio(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  hpss_config~ : @hpss.HpssConfig = @hpss.HpssConfig::default(),
) -> Result[@hpss.HpssResult, @types.MelError] {
  match @types.AudioBuffer::new(samples, config.sample_rate) {
    Ok(audio) => @hpss.hpss_from_audio(audio, config, hpss_config)
    Err(e) => Err(e)
  }
}

///|
/// Re-export frame harmonic energy ratio.
pub fn harmonic_energy_ratio(result : @hpss.HpssResult) -> Array[Double] {
  @hpss.harmonic_energy_ratio(result)
}

///|
/// Re-export frame percussive energy ratio.
pub fn percussive_energy_ratio(result : @hpss.HpssResult) -> Array[Double] {
  @hpss.percussive_energy_ratio(result)
}

///|
/// Re-export Onset method enum.
pub type OnsetMethod = @onset.OnsetMethod

///|
/// Re-export Onset configuration.
pub type OnsetConfig = @onset.OnsetConfig

///|
/// Re-export spectral flux computation.
pub fn spectral_flux(spec : @types.FeatureMatrix) -> Array[Double] {
  @onset.spectral_flux(spec)
}

///|
/// Re-export SuperFlux computation.
pub fn super_flux(
  spec : @types.FeatureMatrix,
  filter_size : Int32,
) -> Array[Double] {
  @onset.super_flux(spec, filter_size)
}

///|
/// Re-export onset strength envelope computation.
pub fn onset_strength(
  spec : @types.FeatureMatrix,
  config~ : @onset.OnsetConfig = @onset.OnsetConfig::default(),
) -> Array[Double] {
  @onset.onset_strength(spec, config)
}

///|
/// Re-export adaptive peak picking.
pub fn peak_pick(
  envelope : Array[Double],
  pre_max~ : Int32 = 3,
  post_max~ : Int32 = 3,
  pre_avg~ : Int32 = 3,
  post_avg~ : Int32 = 3,
  delta~ : Double = 0.05,
  wait~ : Int32 = 3,
) -> Array[Int32] {
  @onset.peak_pick(
    envelope,
    pre_max~,
    post_max~,
    pre_avg~,
    post_avg~,
    delta~,
    wait~,
  )
}

///|
/// Re-export onset strength envelope directly from audio samples.
pub fn onset_strength_audio(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  onset_config~ : @onset.OnsetConfig = @onset.OnsetConfig::default(),
) -> Result[Array[Double], @types.MelError] {
  match @types.AudioBuffer::new(samples, config.sample_rate) {
    Ok(audio) => @onset.onset_strength_audio(audio, config, onset_config~)
    Err(e) => Err(e)
  }
}

///|
/// Re-export onset frame detection directly from audio samples.
pub fn onset_detect_audio(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  onset_config~ : @onset.OnsetConfig = @onset.OnsetConfig::default(),
  delta~ : Double = 0.05,
  wait~ : Int32 = 3,
) -> Result[Array[Int32], @types.MelError] {
  match @types.AudioBuffer::new(samples, config.sample_rate) {
    Ok(audio) =>
      @onset.onset_detect_audio(audio, config, onset_config~, delta~, wait~)
    Err(e) => Err(e)
  }
}

///|
/// Re-export Tempo configuration.
pub type TempoConfig = @tempo.TempoConfig

///|
/// Re-export Tempogram analysis result.
pub type TempogramResult = @tempo.TempogramResult

///|
/// Re-export tempogram from onset envelope.
pub fn tempogram_from_onset(
  onset_env : Array[Double],
  sample_rate : Int32,
  hop_length : Int32,
  config~ : @tempo.TempoConfig = @tempo.TempoConfig::default(),
) -> @tempo.TempogramResult {
  @tempo.tempogram_from_onset(onset_env, sample_rate, hop_length, config~)
}

///|
/// Re-export tempogram and tempo estimation on audio samples.
pub fn tempogram(
  samples : Array[Double],
  feature_config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  tempo_config~ : @tempo.TempoConfig = @tempo.TempoConfig::default(),
) -> Result[@tempo.TempogramResult, @types.MelError] {
  match @types.AudioBuffer::new(samples, feature_config.sample_rate) {
    Ok(audio) => @tempo.tempogram(audio, feature_config, tempo_config~)
    Err(e) => Err(e)
  }
}

///|
/// Re-export Octave Spectral Contrast configuration.
pub type ContrastConfig = @contrast.ContrastConfig

///|
/// Re-export Octave Spectral Contrast from magnitude spectrogram.
pub fn spectral_contrast(
  spec : @types.FeatureMatrix,
  sample_rate : Int32,
  n_fft : Int32,
  config~ : @contrast.ContrastConfig = @contrast.ContrastConfig::default(),
) -> @types.FeatureMatrix {
  @contrast.spectral_contrast(spec, sample_rate, n_fft, config~)
}

///|
/// Re-export Octave Spectral Contrast directly from audio samples.
pub fn spectral_contrast_audio(
  samples : Array[Double],
  feature_config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  contrast_config~ : @contrast.ContrastConfig = @contrast.ContrastConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match @types.AudioBuffer::new(samples, feature_config.sample_rate) {
    Ok(audio) =>
      @contrast.spectral_contrast_audio(audio, feature_config, contrast_config~)
    Err(e) => Err(e)
  }
}
