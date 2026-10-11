///|
pub type AudioBuffer = @types.AudioBuffer

///|
pub type MultiChannelAudioBuffer = @types.MultiChannelAudioBuffer

///|
pub type FeatureConfig = @types.FeatureConfig

///|
pub type FeatureMatrix = @types.FeatureMatrix

///|
pub type Complex = @types.Complex

///|
pub type MelError = @types.MelError

///|
pub type WindowType = @types.WindowType

///|
pub type MelScale = @types.MelScale

///|
pub type MelNorm = @types.MelNorm

///|
pub type LogScale = @types.LogScale

///|
/// Re-export STFT spectrogram extraction.
pub fn stft(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @stft.stft_spectrogram(samples, config)
}

///|
/// Re-export STFT complex frame extraction.
pub fn stft_complex(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[Array[Array[@types.Complex]], @types.MelError] {
  @stft.stft_complex(samples, config)
}

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
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @mel.mel_spectrogram(samples, config)
}

///|
/// Re-export Log-Mel Spectrogram extraction.
pub fn log_mel_spectrogram(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @mfcc.log_mel_spectrogram(samples, config)
}

///|
/// Re-export MFCC extraction.
pub fn mfcc(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
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
  n_out : Int,
  norm_ortho : Bool,
) -> Array[Double] {
  @mfcc.dct_ii(input, n_out, norm_ortho)
}

///|
/// Re-export pre-emphasis high-pass filter.
pub fn preemphasis(
  samples : Array[Double],
  alpha? : Double = 0.97,
) -> Array[Double] {
  @filter.preemphasis(samples, alpha~)
}

///|
/// Re-export de-emphasis inverse filter.
pub fn deemphasis(
  samples : Array[Double],
  alpha? : Double = 0.97,
) -> Array[Double] {
  @filter.deemphasis(samples, alpha~)
}

///|
/// Re-export Delta / Delta-Delta dynamic feature calculation.
pub fn compute_delta(
  matrix : @types.FeatureMatrix,
  width? : Int = 9,
  order? : Int = 1,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @delta.compute_delta(matrix, width~, order~)
}

///|
/// Re-export Root Mean Square (RMS) frame energy extraction.
pub fn compute_rms(
  audio : @types.AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @energy.compute_rms(audio, frame_length~, hop_length~, center~)
}

///|
/// Re-export total frame sum-of-squares energy extraction.
pub fn compute_energy(
  audio : @types.AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @energy.compute_energy(audio, frame_length~, hop_length~, center~)
}

///|
/// Re-export WAV decoder.
pub fn decode_wav(
  bytes : Array[Byte],
) -> Result[@types.AudioBuffer, @types.MelError] {
  @wav.decode_wav(bytes)
}

///|
/// Re-export Window generator.
pub fn create_window(kind : @types.WindowType, n : Int) -> Array[Double] {
  @window.create_window(kind, n)
}

///|
/// Re-export audio resampler (polyphase by default).
pub fn resample(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample(samples, orig_sr, target_sr)
}

///|
/// Re-export polyphase rational factor audio resampler.
pub fn resample_polyphase(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
  half_len? : Int = 10,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample_polyphase(samples, orig_sr, target_sr, half_len~)
}

///|
/// Re-export windowed-sinc bandlimited audio resampler.
pub fn resample_sinc(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
  filter_size? : Int = 16,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample_sinc(samples, orig_sr, target_sr, filter_size~)
}

///|
/// Re-export linear interpolation audio resampler.
pub fn resample_linear(
  samples : Array[Double],
  orig_sr : Int,
  target_sr : Int,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample_linear(samples, orig_sr, target_sr)
}

///|
/// Re-export streaming extractor type alias.
pub type StreamingExtractor = @streaming.StreamingExtractor

///|
/// Re-export constructor for StreamingExtractor.
pub fn create_streaming_extractor(
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@streaming.StreamingExtractor, @types.MelError] {
  @streaming.StreamingExtractor::new(config~)
}

///|
/// Re-export Reflect padding.
pub fn pad_reflect(samples : Array[Double], pad_width : Int) -> Array[Double] {
  @window.pad_reflect(samples, pad_width)
}

///|
/// Re-export Forward FFT.
pub fn fft(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  @fft.fft(signal)
}

///|
/// Re-export Inverse FFT.
pub fn ifft(
  spectrum : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  @fft.ifft(spectrum)
}

///|
/// Re-export Spectral Centroid extraction.
pub fn spectral_centroid(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.spectral_centroid(samples, config~)
}

///|
/// Re-export Spectral Rolloff extraction.
pub fn spectral_rolloff(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  roll_percent? : Double = 0.85,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.spectral_rolloff(samples, config~, roll_percent~)
}

///|
/// Re-export Spectral Flatness extraction.
pub fn spectral_flatness(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  amin? : Double = 1.0e-10,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.spectral_flatness(samples, config~, amin~)
}

///|
/// Re-export Zero-Crossing Rate extraction.
pub fn zero_crossing_rate(
  audio : @types.AudioBuffer,
  frame_length? : Int = 2048,
  hop_length? : Int = 512,
  center? : Bool = true,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @spectral.zero_crossing_rate(audio, frame_length~, hop_length~, center~)
}

///|
/// Re-export multi-channel STFT extraction.
pub fn multichannel_stft(
  buffer : @types.MultiChannelAudioBuffer,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  @multichannel.multichannel_stft(buffer, config~)
}

///|
/// Re-export multi-channel Mel spectrogram extraction.
pub fn multichannel_mel(
  buffer : @types.MultiChannelAudioBuffer,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  @multichannel.multichannel_mel(buffer, config~)
}

///|
/// Re-export multi-channel MFCC extraction.
pub fn multichannel_mfcc(
  buffer : @types.MultiChannelAudioBuffer,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  @multichannel.multichannel_mfcc(buffer, config~)
}

///|
/// Re-export Inter-channel Level Difference (ILD).
pub fn interchannel_level_difference(
  buffer : @types.MultiChannelAudioBuffer,
  ch1 : Int,
  ch2 : Int,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @multichannel.interchannel_level_difference(buffer, ch1, ch2, config~)
}

///|
/// Re-export Inter-channel Phase Difference (IPD).
pub fn interchannel_phase_difference(
  buffer : @types.MultiChannelAudioBuffer,
  ch1 : Int,
  ch2 : Int,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @multichannel.interchannel_phase_difference(buffer, ch1, ch2, config~)
}

///|
/// Re-export Chroma normalization enum.
pub type ChromaNorm = @chroma.ChromaNorm

///|
/// Re-export pitch class name mapping.
pub fn pitch_class_name(idx : Int) -> String {
  @chroma.pitch_class_name(idx)
}

///|
/// Re-export Chroma filterbank generation.
pub fn chroma_filterbank(
  sample_rate : Int,
  n_fft : Int,
  tuning? : Double = 0.0,
  f_min? : Double = 0.0,
) -> @types.FeatureMatrix {
  @chroma.chroma_filterbank(sample_rate, n_fft, tuning, f_min)
}

///|
/// Re-export Chroma from spectrogram.
pub fn chroma_from_spectrogram(
  spectrogram : @types.FeatureMatrix,
  sample_rate : Int,
  n_fft : Int,
  norm? : @chroma.ChromaNorm = @chroma.ChromaNorm::None,
  tuning? : Double = 0.0,
  f_min? : Double = 0.0,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @chroma.chroma_from_spectrogram(
    spectrogram, sample_rate, n_fft, norm, tuning, f_min,
  )
}

///|
/// Re-export 12-bin Chroma STFT feature extraction.
pub fn chroma_stft(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  norm? : @chroma.ChromaNorm = @chroma.ChromaNorm::None,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @chroma.chroma_stft(samples, config, norm)
}

///|
/// Re-export Forward FFT with zero-padding for arbitrary length signals.
pub fn fft_padded(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  @fft.fft_padded(signal)
}

///|
/// Re-export Real FFT spectrum with zero-padding for arbitrary length frames.
pub fn rfft_padded(
  frame : Array[Double],
  power? : Double = 2.0,
) -> Result[Array[Double], @types.MelError] {
  @fft.rfft_padded(frame, power)
}

///|
/// Re-export Arbitrary-length DFT via Bluestein's Algorithm.
pub fn bluestein_fft(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  @fft.bluestein_fft(signal)
}

///|
/// Re-export Arbitrary-length IDFT via Bluestein's Algorithm.
pub fn bluestein_ifft(
  spectrum : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  @fft.bluestein_ifft(spectrum)
}

///|
/// Re-export Universal DFT (Radix-2 FFT when power of 2, Bluestein's algorithm otherwise).
pub fn dft(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  @fft.dft(signal)
}

///|
/// Re-export Universal IDFT (Radix-2 IFFT when power of 2, Bluestein's algorithm otherwise).
pub fn idft(
  spectrum : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  @fft.idft(spectrum)
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
  config? : @cqt.CqtConfig = @cqt.CqtConfig::default(),
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
  kernel_size : Int,
) -> Array[Double] {
  @hpss.median_filter_1d(arr, kernel_size)
}

///|
/// Re-export 2D median filter along time axis.
pub fn median_filter_time(
  matrix : @types.FeatureMatrix,
  kernel_size : Int,
) -> @types.FeatureMatrix {
  @hpss.median_filter_time(matrix, kernel_size)
}

///|
/// Re-export 2D median filter along frequency axis.
pub fn median_filter_freq(
  matrix : @types.FeatureMatrix,
  kernel_size : Int,
) -> @types.FeatureMatrix {
  @hpss.median_filter_freq(matrix, kernel_size)
}

///|
/// Re-export Harmonic-Percussive Source Separation (HPSS) on spectrogram.
pub fn hpss(
  spec : @types.FeatureMatrix,
  config? : @hpss.HpssConfig = @hpss.HpssConfig::default(),
) -> @hpss.HpssResult {
  @hpss.hpss(spec, config)
}

///|
/// Re-export HPSS directly from PCM audio samples.
pub fn hpss_from_audio(
  samples : Array[Double],
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  hpss_config? : @hpss.HpssConfig = @hpss.HpssConfig::default(),
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
/// Re-export Biquad filter coefficients.
pub type BiquadCoeffs = @loudness.BiquadCoeffs

///|
/// Re-export Biquad filter state.
pub type BiquadFilter = @loudness.BiquadFilter

///|
/// Re-export ITU-R BS.1770-4 / EBU R128 Loudness result.
pub type LoudnessResult = @loudness.LoudnessResult

///|
/// Re-export K-weighting filtering.
pub fn apply_k_weighting(
  samples : Array[Double],
  sample_rate : Int,
) -> Array[Double] {
  @loudness.apply_k_weighting(samples, sample_rate)
}

///|
/// Re-export True Peak measurement in dBFS via 4x oversampling.
pub fn true_peak_db(
  samples : Array[Double],
  sample_rate : Int,
) -> Result[Double, @types.MelError] {
  @loudness.true_peak_db(samples, sample_rate)
}

///|
/// Re-export ITU-R BS.1770-4 Loudness Meter for audio samples.
pub fn loudness_meter(
  samples : Array[Double],
  sample_rate? : Int = 48000,
) -> Result[@loudness.LoudnessResult, @types.MelError] {
  match @types.AudioBuffer::new(samples, sample_rate) {
    Ok(audio) => @loudness.loudness_meter(audio)
    Err(e) => Err(e)
  }
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
  filter_size : Int,
) -> Array[Double] {
  @onset.super_flux(spec, filter_size)
}

///|
/// Re-export onset strength envelope computation.
pub fn onset_strength(
  spec : @types.FeatureMatrix,
  config? : @onset.OnsetConfig = @onset.OnsetConfig::default(),
) -> Array[Double] {
  @onset.onset_strength(spec, config)
}

///|
/// Re-export adaptive peak picking.
pub fn peak_pick(
  envelope : Array[Double],
  pre_max? : Int = 3,
  post_max? : Int = 3,
  pre_avg? : Int = 3,
  post_avg? : Int = 3,
  delta? : Double = 0.05,
  wait? : Int = 3,
) -> Array[Int] {
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
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  onset_config? : @onset.OnsetConfig = @onset.OnsetConfig::default(),
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
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
  onset_config? : @onset.OnsetConfig = @onset.OnsetConfig::default(),
  delta? : Double = 0.05,
  wait? : Int = 3,
) -> Result[Array[Int], @types.MelError] {
  match @types.AudioBuffer::new(samples, config.sample_rate) {
    Ok(audio) =>
      @onset.onset_detect_audio(audio, config, onset_config~, delta~, wait~)
    Err(e) => Err(e)
  }
}

///|
/// Re-export LPC solver result.
pub type LpcResult = @lpc.LpcResult

///|
/// Re-export biased autocorrelation.
pub fn autocorrelation(samples : Array[Double], max_lag : Int) -> Array[Double] {
  @lpc.autocorrelation(samples, max_lag)
}

///|
/// Re-export Levinson-Durbin recursion.
pub fn levinson_durbin(
  r : Array[Double],
  order : Int,
) -> Result[@lpc.LpcResult, @types.MelError] {
  @lpc.levinson_durbin(r, order)
}

///|
/// Re-export LPC analysis on audio samples.
pub fn lpc(
  samples : Array[Double],
  order : Int,
) -> Result[@lpc.LpcResult, @types.MelError] {
  @lpc.lpc(samples, order)
}

///|
/// Re-export LPC to LPCC conversion.
pub fn lpc_to_lpcc(
  lpc_coeffs : Array[Double],
  prediction_error : Double,
  n_lpcc : Int,
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
  order : Int,
  frame_length : Int,
  hop_length : Int,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @lpc.lpc_features(samples, order, frame_length, hop_length)
}

///|
/// Re-export frame-wise LPCC feature extraction.
pub fn lpcc_features(
  samples : Array[Double],
  order : Int,
  n_lpcc : Int,
  frame_length : Int,
  hop_length : Int,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @lpc.lpcc_features(samples, order, n_lpcc, frame_length, hop_length)
}
