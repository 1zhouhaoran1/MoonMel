///|
test "median_filter_1d impulse suppression" {
  let signal = [2.0, 2.0, 100.0, 2.0, 2.0]
  let filtered = median_filter_1d(signal, 3)
  assert_eq(filtered.length(), 5)
  // The impulse 100.0 at index 2 should be rejected by median filter of window 3
  assert_eq(filtered[2], 2.0)
}

///|
test "hpss synthetic matrix separation" {
  // Create 9x9 spectrogram with a horizontal line (harmonic) at row 2 and vertical click (percussive) at col 6
  let spec = @types.FeatureMatrix::zeros(9, 9)
  for c in 0..<9 {
    spec.set(2, c, 10.0)
  }
  for r in 0..<9 {
    spec.set(r, 6, 10.0)
  }

  let config : HpssConfig = {
    kernel_harm: 5,
    kernel_perc: 5,
    power: 2.0,
    margin_harm: 1.0,
    margin_perc: 1.0,
    mask_mode: Soft,
  }

  let result = hpss(spec, config)
  assert_eq(result.harmonic.n_rows, 9)
  assert_eq(result.harmonic.n_cols, 9)

  // Harmonic component should dominate along row 2 away from intersection
  assert_true(result.harmonic.at(2, 1) > result.percussive.at(2, 1))

  // Percussive component should dominate along col 6 away from intersection
  assert_true(result.percussive.at(7, 6) > result.harmonic.at(7, 6))

  // Mask sum should be approximately 1.0 everywhere
  for r in 0..<9 {
    for c in 0..<9 {
      let sum_mask = result.harmonic_mask.at(r, c) +
        result.percussive_mask.at(r, c)
      assert_true((sum_mask - 1.0).abs() < 1.0e-5)
    }
  }
}

///|
test "hpss audio pipeline harmonic tone" {
  // 16kHz audio with pure 440Hz sine wave
  let sr = 16000
  let n_samples = 4096
  let samples : Array[Double] = Array::make(n_samples, 0.0)
  let freq = 440.0
  let pi2 = 2.0 * @math.PI
  for i in 0..<n_samples {
    let t = i.to_double() / sr.to_double()
    samples[i] = @math.sin(pi2 * freq * t)
  }
  let audio = @types.AudioBuffer::new(samples, sr).unwrap()
  let f_cfg = @types.FeatureConfig::default()
  let h_cfg : HpssConfig = {
    kernel_harm: 15,
    kernel_perc: 15,
    power: 2.0,
    margin_harm: 1.0,
    margin_perc: 1.0,
    mask_mode: Soft,
  }

  let hpss_res = hpss_from_audio(audio, f_cfg, h_cfg).unwrap()
  let harm_ratios = harmonic_energy_ratio(hpss_res)
  assert_true(harm_ratios.length() > 0)
  // For sustained pure sine wave, middle frames should have dominant harmonic ratio
  let mid_frame = harm_ratios.length() / 2
  assert_true(harm_ratios[mid_frame] > 0.8)
}
