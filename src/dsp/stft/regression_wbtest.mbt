///|
test "short window uses the center of each fft frame" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 8,
    win_length: 4,
    hop_length: 4,
    center: false,
    window: Rectangular,
  }
  let spec = stft_spectrogram([0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0], cfg).unwrap()
  assert_true((spec.at(0, 0) - 196.0).abs() < 1.0e-10)
}

///|
test "odd fft complex transform reconstructs every sample" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 5,
    win_length: 5,
    hop_length: 2,
    center: true,
    window: Rectangular,
  }
  let samples = [0.1, 0.3, -0.7, 0.9, 0.2, -0.4, 0.8]
  let frames = stft_complex(samples, cfg).unwrap()
  let restored = istft(frames, cfg, samples.length()).unwrap()
  for i in 0..<samples.length() {
    assert_true((restored[i] - samples[i]).abs() < 1.0e-9)
  }
}

///|
test "invalid window returns an error before indexing" {
  let cfg = { ..@types.FeatureConfig::default(), n_fft: 8, win_length: 9, }
  assert_true(stft_spectrogram(Array::make(16, 0.1), cfg) is Err(_))
}
