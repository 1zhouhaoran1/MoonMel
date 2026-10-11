///|
test "k_weighting_coefficients_48k_standards" {
  let c1 = pre_filter_coeffs(48000)
  assert_true((c1.b0 - 1.53512485958697).abs() < 1.0e-4)
  assert_true((c1.b1 - -2.69169618940638).abs() < 1.0e-4)
  assert_true((c1.b2 - 1.19839281085285).abs() < 1.0e-4)
  assert_true((c1.a1 - -1.69065929318241).abs() < 1.0e-4)
  assert_true((c1.a2 - 0.73248077421585).abs() < 1.0e-4)

  let c2 = rlb_filter_coeffs(48000)
  assert_true((c2.b0 - 1.0).abs() < 1.0e-4)
  assert_true((c2.b1 - -2.0).abs() < 1.0e-4)
  assert_true((c2.b2 - 1.0).abs() < 1.0e-4)
  assert_true((c2.a1 - -1.99004745483398).abs() < 1.0e-4)
  assert_true((c2.a2 - 0.99007225034606).abs() < 1.0e-4)
}

///|
test "loudness_meter_1khz_sine" {
  let sr = 48000
  let dur = 1.0 // 1 second
  let n_samples = (dur * sr.to_double()).to_int()
  let samples : Array[Double] = Array::make(n_samples, 0.0)
  let freq = 1000.0
  let pi2 = 2.0 * @math.PI
  for i in 0..<n_samples {
    let t = i.to_double() / sr.to_double()
    samples[i] = @math.sin(pi2 * freq * t)
  }
  let audio = @types.AudioBuffer::new(samples, sr).unwrap()
  let res = loudness_meter(audio).unwrap()

  // Theoretical 1kHz 0dBFS peak sine is approx -3.7 LUFS (ITU-R BS.1770)
  assert_true(res.integrated > -4.5 && res.integrated < -3.0)
  // True peak of amplitude 1.0 sine wave should be approx 0.0 dBFS
  assert_true(res.true_peak.abs() < 0.5)
}

///|
test "loudness_meter_silence_safety" {
  let sr = 48000
  let samples : Array[Double] = Array::make(4800, 0.0)
  let audio = @types.AudioBuffer::new(samples, sr).unwrap()
  let res = loudness_meter(audio).unwrap()

  // Gated integrated loudness for complete silence should return -70.0 LUFS
  assert_eq(res.integrated, -70.0)
  assert_true(res.true_peak < -100.0)
}
