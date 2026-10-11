///|
test "streaming respects power and short windows" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 8,
    win_length: 4,
    hop_length: 4,
    n_mels: 4,
    n_mfcc: 2,
    center: false,
    power: 1.0,
  }
  let samples = [0.1, -0.2, 0.8, 0.4, -0.6, 0.3, 0.2, -0.7]
  let ext = @streaming.StreamingExtractor::new(config=cfg).unwrap()
  ext.push_samples(samples)
  let actual = ext.pop_mel_frames()
  let expected = @mel.mel_spectrogram(samples, cfg).unwrap()
  for r in 0..<actual.n_rows {
    assert_true((actual.at(r, 0) - expected.at(r, 0)).abs() < 1.0e-10)
  }
}

///|
test "streaming hop larger than fft keeps the gap across chunks" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 8,
    win_length: 8,
    hop_length: 12,
    n_mels: 4,
    n_mfcc: 2,
    center: false,
  }
  let ext = @streaming.StreamingExtractor::new(config=cfg).unwrap()
  ext.push_samples(Array::make(8, 1.0))
  assert_eq(ext.pop_mel_frames().n_cols, 1)
  ext.push_samples(Array::make(4, 1.0))
  assert_eq(ext.available_frames(), 0)
  ext.push_samples(Array::make(8, 1.0))
  assert_eq(ext.pop_mel_frames().n_cols, 1)
}

///|
test "streaming mfcc respects log scale and dct normalization" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 16,
    win_length: 16,
    hop_length: 8,
    n_mels: 4,
    n_mfcc: 2,
    center: false,
    log_scale: NaturalLog,
    amin: 0.001,
    norm_ortho: false,
  }
  let samples = Array::make(32, 0.0)
  for i in 0..<samples.length() {
    samples[i] = @math.sin(i.to_double() * 0.5)
  }
  let ext = @streaming.StreamingExtractor::new(config=cfg).unwrap()
  ext.push_samples(samples)
  let actual = ext.pop_mfcc_frames()
  let expected = @mfcc.mfcc(samples, cfg).unwrap()
  for r in 0..<actual.n_rows {
    for c in 0..<actual.n_cols {
      assert_true((actual.at(r, c) - expected.at(r, c)).abs() < 1.0e-10)
    }
  }
}

///|
test "streaming arbitrary fft agrees with offline mel" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 5,
    win_length: 3,
    hop_length: 2,
    n_mels: 4,
    n_mfcc: 2,
    center: false,
  }
  let samples = [0.1, -0.3, 0.5, 0.8, -0.7, 0.4, 0.2]
  let ext = @streaming.StreamingExtractor::new(config=cfg).unwrap()
  ext.push_samples(samples)
  let actual = ext.pop_mel_frames()
  let expected = @mel.mel_spectrogram(samples, cfg).unwrap()
  assert_eq(actual.n_cols, expected.n_cols)
  for r in 0..<actual.n_rows {
    for c in 0..<actual.n_cols {
      assert_true((actual.at(r, c) - expected.at(r, c)).abs() < 1.0e-10)
    }
  }
}
