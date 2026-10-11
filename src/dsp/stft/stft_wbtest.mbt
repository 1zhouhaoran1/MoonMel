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

///|
test "stft_istft_reconstruction_sine" {
  let sr = 16000.0
  let n = 2048
  let freq = 440.0
  let samples : Array[Double] = Array::make(n, 0.0)
  for i in 0..<n {
    let t = i.to_double() / sr
    samples[i] = @math.sin(2.0 * @window.pi * freq * t)
  }

  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 512,
    win_length: 512,
    hop_length: 128,
    center: true,
  }
  let frames = match stft_complex(samples, cfg) {
    Ok(f) => f
    Err(_) => {
      assert_true(false)
      return
    }
  }
  let recon = match istft(frames, cfg, n) {
    Ok(r) => r
    Err(_) => {
      assert_true(false)
      return
    }
  }
  assert_eq(recon.length(), n)
  let mut max_err = 0.0
  for i in 128..<(n - 128) {
    let diff = (samples[i] - recon[i]).abs()
    if diff > max_err {
      max_err = diff
    }
  }
  assert_true(max_err < 1.0e-3)
}
