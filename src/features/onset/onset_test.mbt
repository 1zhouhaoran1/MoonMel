///|
test "spectral_flux_synthetic" {
  let spec = @types.FeatureMatrix::zeros(5, 4)
  // col 0: 0.0
  // col 1: all 1.0 -> positive diff = 5.0
  for r in 0..<5 {
    spec.set(r, 1, 1.0)
  }
  // col 2: all 1.0 -> diff = 0.0
  for r in 0..<5 {
    spec.set(r, 2, 1.0)
  }
  // col 3: all 0.0 -> diff = -5.0 -> rectified = 0.0
  for r in 0..<5 {
    spec.set(r, 3, 0.0)
  }

  let flux = spectral_flux(spec)
  assert_eq(flux.length(), 4)
  assert_eq(flux[0], 0.0)
  assert_eq(flux[1], 5.0)
  assert_eq(flux[2], 0.0)
  assert_eq(flux[3], 0.0)
}

///|
test "peak_pick_adaptive" {
  let envelope = [0.0, 0.05, 0.85, 0.1, 0.0, 0.02, 0.95, 0.15, 0.0, 0.0]
  let peaks = peak_pick(envelope, pre_max=2, post_max=2, delta=0.1, wait=2)
  assert_eq(peaks.length(), 2)
  assert_eq(peaks[0], 2)
  assert_eq(peaks[1], 6)
}

///|
test "onset_audio_bursts" {
  let sr = 16000
  let n_samples = 16000 // 1 second
  let samples : Array[Double] = Array::make(n_samples, 0.0)
  let pi2 = 2.0 * @math.PI

  // First burst at 0.1s (sample 1600 to 3200)
  for i in 1600..<3200 {
    let t = i.to_double() / sr.to_double()
    samples[i] = @math.sin(pi2 * 440.0 * t)
  }
  // Second burst at 0.6s (sample 9600 to 11200)
  for i in 9600..<11200 {
    let t = i.to_double() / sr.to_double()
    samples[i] = @math.sin(pi2 * 880.0 * t)
  }

  let audio = @types.AudioBuffer::new(samples, sr).unwrap()
  let cfg = @types.FeatureConfig::default()
  let onsets = onset_detect_audio(audio, cfg, delta=0.1, wait=5).unwrap()

  // Should detect onsets near start of each burst
  assert_true(onsets.length() >= 2)
}
