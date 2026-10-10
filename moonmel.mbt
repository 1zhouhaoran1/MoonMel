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
/// Re-export audio resampler (windowed-sinc bandlimited by default).
pub fn resample(
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
