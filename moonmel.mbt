///|
pub type AudioBuffer = @types.AudioBuffer

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
