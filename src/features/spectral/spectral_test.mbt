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

///|
test "zero_crossing_rate_negative_dc_no_false_crossings" {
  // Negative DC signal must have strictly 0.0 zero-crossings across all frames
  let sig_neg = Array::make(1024, -1.0)
  let audio = @types.AudioBuffer::new(sig_neg, 16000).unwrap()
  let zcr = @spectral.zero_crossing_rate(
    audio,
    frame_length=256,
    hop_length=128,
    center=true,
  ).unwrap()
  assert_true(zcr.n_cols > 0)
  for col in 0..<zcr.n_cols {
    assert_eq(zcr.at(0, col), 0.0)
  }
}

///|
test "spectral rolloff rejects nonfinite and out-of-range fractions" {
  let samples = [1.0, 0.0, 0.0, 0.0]
  for fraction in [-0.1, 1.1, 0.0 / 0.0, 1.0 / 0.0, -1.0 / 0.0] {
    assert_true(
      @spectral.spectral_rolloff(samples, roll_percent=fraction)
      is Err(DimensionMismatch(_)),
    )
  }
}

///|
test "spectral flatness rejects nonpositive and nonfinite floors" {
  let samples = [1.0, 0.0, 0.0, 0.0]
  for floor in [0.0, -1.0, 0.0 / 0.0, 1.0 / 0.0, -1.0 / 0.0] {
    assert_true(
      @spectral.spectral_flatness(samples, amin=floor)
      is Err(DimensionMismatch(_)),
    )
  }
}

///|
test "spectral parameter validation preserves fraction endpoints and flat spectra" {
  let samples = [1.0, 0.0, 0.0, 0.0]
  let config = {
    ..@types.FeatureConfig::default(),
    n_fft: 4,
    win_length: 4,
    hop_length: 4,
    window: Rectangular,
    center: false,
  }
  for fraction in [0.0, 0.5, 1.0] {
    let rolloff = @spectral.spectral_rolloff(
      samples,
      config~,
      roll_percent=fraction,
    ).unwrap()
    assert_eq(rolloff.n_rows, 1)
    assert_eq(rolloff.n_cols, 1)
    assert_eq(rolloff.at(0, 0), fraction * 8000.0)
  }
  for floor in [1.0e-200, 1.0e-10] {
    let flatness = @spectral.spectral_flatness(samples, config~, amin=floor).unwrap()
    assert_true((flatness.at(0, 0) - 1.0).abs() < 1.0e-12)
  }
}
