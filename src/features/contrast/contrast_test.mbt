///|
test "quantile_sorted_exact" {
  let arr = [1.0, 2.0, 3.0, 4.0, 5.0]
  assert_eq(@contrast.quantile_sorted(arr, 0.0), 1.0)
  assert_eq(@contrast.quantile_sorted(arr, 0.5), 3.0)
  assert_eq(@contrast.quantile_sorted(arr, 1.0), 5.0)
}

///|
test "spectral_contrast_peak_dynamics" {
  // 129 bins (n_fft=256), 5 frames
  let spec = @types.FeatureMatrix::zeros(129, 5)
  // Sub-band 2 (around 400Hz to 800Hz) has high-contrast impulse
  for c in 0..<5 {
    for r in 0..<129 {
      spec.set(r, c, 1.0) // Flat baseline
    }
    // High peak at bin 10 (approx 625 Hz at 16kHz)
    spec.set(10, c, 100.0)
  }

  let res = @contrast.spectral_contrast(spec, 16000, 256)
  assert_eq(res.n_rows, 7)
  assert_eq(res.n_cols, 5)

  // Subband 2 (400Hz to 800Hz, bins 6..13) contains bin 10 with peak 100.0
  assert_true(res.at(2, 0) > 2.0)
}

///|
test "spectral_contrast_audio_pipeline" {
  let sr = 16000
  let sig = Array::make(4000, 0.1)
  let audio = @types.AudioBuffer::new(sig, sr).unwrap()
  let f_cfg = @types.FeatureConfig::default()
  let res = @contrast.spectral_contrast_audio(audio, f_cfg).unwrap()

  assert_eq(res.n_rows, 7)
  assert_true(res.n_cols > 0)
}
