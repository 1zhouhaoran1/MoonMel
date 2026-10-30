///|
/// Re-export STFT spectrogram extraction.
pub fn stft(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
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
/// Re-export Window generator.
pub fn create_window(kind : @types.WindowType, n : Int32) -> Array[Double] {
  @window.create_window(kind, n)
}

///|
/// Re-export Reflect padding.
pub fn pad_reflect(samples : Array[Double], pad_width : Int32) -> Array[Double] {
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
  power~ : Double = 2.0,
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
/// Re-export Inverse STFT (ISTFT) time-domain audio reconstruction.
pub fn istft(
  frames : Array[Array[@types.Complex]],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
  length~ : Int32 = 0,
) -> Result[Array[Double], @types.MelError] {
  @stft.istft(frames, config, length)
}
