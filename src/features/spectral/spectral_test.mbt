///|
/// Unit tests for spectral descriptors.
test "spectral_centroid_pure_tone" {
  let sr = 16000
  let n = 3200
  let sig = Array::make(n, 0.0)
  let f0 = 1000.0
  let pi = 3.14159265358979323846

  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    sig[i] = @math.sin(2.0 * pi * f0 * t)
  }

  let cfg = {
    ..@types.FeatureConfig::default(),
    sample_rate: sr,
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
  }

  let centroid = @spectral.spectral_centroid(sig, config=cfg).unwrap()
  assert_eq(centroid.n_rows, 1)
  assert_true(centroid.n_cols > 0)

  // Verify that the spectral centroid of a 1000 Hz sine wave is ~1000 Hz (+- 100 Hz)
  let center_val = centroid.at(0, centroid.n_cols / 2)
  assert_true((center_val - 1000.0).abs() < 100.0)
}

///|
test "spectral_rolloff_pure_tone" {
  let sr = 16000
  let n = 3200
  let sig = Array::make(n, 0.0)
  let f0 = 1000.0
  let pi = 3.14159265358979323846

  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    sig[i] = @math.sin(2.0 * pi * f0 * t)
  }

  let cfg = {
    ..@types.FeatureConfig::default(),
    sample_rate: sr,
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
  }

  let rolloff = @spectral.spectral_rolloff(sig, config=cfg, roll_percent=0.85).unwrap()
  let center_val = rolloff.at(0, rolloff.n_cols / 2)
  assert_true((center_val - 1000.0).abs() < 100.0)
}

///|
test "spectral_flatness_tone_vs_noise" {
  let sr = 16000
  let n = 3200
  let sig_tone = Array::make(n, 0.0)
  let pi = 3.14159265358979323846

  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    sig_tone[i] = @math.sin(2.0 * pi * 800.0 * t)
  }

  let cfg = {
    ..@types.FeatureConfig::default(),
    sample_rate: sr,
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
  }

  let flatness = @spectral.spectral_flatness(sig_tone, config=cfg).unwrap()
  let center_val = flatness.at(0, flatness.n_cols / 2)
  // Pure harmonic tone has very low flatness (approaching 0)
  assert_true(center_val < 0.1)
}

///|
test "zero_crossing_rate_sine" {
  let sr = 16000
  let n = 3200
  let sig = Array::make(n, 0.0)
  let f0 = 1000.0
  let pi = 3.14159265358979323846

  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    sig[i] = @math.sin(2.0 * pi * f0 * t)
  }

  let audio = @types.AudioBuffer::new(sig, sr).unwrap()
  let zcr = @spectral.zero_crossing_rate(
    audio,
    frame_length=512,
    hop_length=256,
  ).unwrap()
  assert_eq(zcr.n_rows, 1)
  assert_true(zcr.n_cols > 0)

  // Expected theoretical ZCR for 1000 Hz at 16000 Hz sample rate is ~ 2 * 1000 / 16000 = 0.125
  let mid_val = zcr.at(0, zcr.n_cols / 2)
  assert_true((mid_val - 0.125).abs() < 0.02)
}
