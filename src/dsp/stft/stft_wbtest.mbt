///|
test "stft_sine_peak" {
  let sr = 16000.0
  let n = 1024
  let freq = 250.0
  let samples : Array[Double] = Array::make(n, 0.0)
  for i in 0..<n {
    let t = i.to_double() / sr
    samples[i] = @math.sin(2.0 * @window.pi * freq * t)
  }

  let cfg = {
    ..@types.FeatureConfig::default(),
    center: false,
    window: Rectangular,
    hop_length: 512,
  }
  match stft_spectrogram(samples, cfg) {
    Ok(spec) => {
      assert_eq(spec.n_rows, 513)
      let p16 = spec.at(16, 0)
      let p0 = spec.at(0, 0)
      let p50 = spec.at(50, 0)
      assert_true(p16 > p0)
      assert_true(p16 > p50)
      assert_true(p16 > 1000.0)
    }
    Err(_) => assert_true(false)
  }
}
