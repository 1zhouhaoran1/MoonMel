///|
/// Unit tests for audio resampling algorithms.
test "resample_identity" {
  let sig = [1.0, 2.0, 3.0, 4.0, 5.0]
  let res_lin = @resample.resample_linear(sig, 16000, 16000).unwrap()
  let res_sinc = @resample.resample_sinc(sig, 16000, 16000).unwrap()
  assert_eq(res_lin.length(), 5)
  assert_eq(res_sinc.length(), 5)
  for i in 0..<5 {
    assert_eq(res_lin[i], sig[i])
    assert_eq(res_sinc[i], sig[i])
  }
}

///|
test "resample_empty_and_invalid" {
  let empty : Array[Double] = []
  assert_eq(@resample.resample_linear(empty, 16000, 8000).unwrap().length(), 0)
  assert_eq(@resample.resample_sinc(empty, 16000, 8000).unwrap().length(), 0)

  assert_true(@resample.resample_linear([1.0], 0, 16000) is Err(_))
  assert_true(@resample.resample_linear([1.0], 16000, -1) is Err(_))
  assert_true(@resample.resample_sinc([1.0], 0, 16000) is Err(_))
}

///|
test "resample_sine_downsample_48k_to_16k" {
  // Generate 440Hz pure tone at 48kHz
  let n_samples = 4800 // 0.1s
  let orig_sr = 48000
  let target_sr = 16000
  let sig = Array::make(n_samples, 0.0)
  let f0 = 440.0
  let pi = @math.PI

  for i in 0..<n_samples {
    let t = i.to_double() / orig_sr.to_double()
    sig[i] = @math.sin(2.0 * pi * f0 * t)
  }

  let downsampled_sinc = @resample.resample_sinc(
    sig,
    orig_sr,
    target_sr,
    filter_size=16,
  ).unwrap()
  assert_eq(downsampled_sinc.length(), 1600)

  // Verify that the reconstructed downsampled signal matches expected 440Hz tone at 16kHz
  // (Skip the boundary edge region of the sinc filter)
  let mut max_err = 0.0
  for i in 50..<1550 {
    let t = i.to_double() / target_sr.to_double()
    let expected = @math.sin(2.0 * pi * f0 * t)
    let err = (downsampled_sinc[i] - expected).abs()
    if err > max_err {
      max_err = err
    }
  }
  // Sinc interpolation on bandlimited sine should have < 0.05 error
  assert_true(max_err < 0.05)
}

///|
test "resample_sine_upsample_16k_to_48k" {
  // Generate 200Hz pure tone at 16kHz
  let n_samples = 1600 // 0.1s
  let orig_sr = 16000
  let target_sr = 48000
  let sig = Array::make(n_samples, 0.0)
  let f0 = 200.0
  let pi = @math.PI

  for i in 0..<n_samples {
    let t = i.to_double() / orig_sr.to_double()
    sig[i] = @math.sin(2.0 * pi * f0 * t)
  }

  let upsampled_sinc = @resample.resample_sinc(
    sig,
    orig_sr,
    target_sr,
    filter_size=16,
  ).unwrap()
  assert_eq(upsampled_sinc.length(), 4800)

  let mut max_err = 0.0
  for i in 100..<4700 {
    let t = i.to_double() / target_sr.to_double()
    let expected = @math.sin(2.0 * pi * f0 * t)
    let err = (upsampled_sinc[i] - expected).abs()
    if err > max_err {
      max_err = err
    }
  }
  assert_true(max_err < 0.05)
}
