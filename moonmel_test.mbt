test "facade_full_pipeline" {
  let samples : Array[Double] = Array::make(3200, 0.0)
  for i in 0..<3200 {
    samples[i] = @math.sin(i.to_double() * 0.05)
  }

  let cfg = @moonmel.FeatureConfig::default()

  match @moonmel.stft(samples, config=cfg) {
    Ok(spec) => {
      assert_eq(spec.n_rows, 513)
      assert_true(spec.n_cols > 0)
    }
    Err(_) => assert_true(false)
  }

  match @moonmel.mel_spectrogram(samples, config=cfg) {
    Ok(mel) => {
      assert_eq(mel.n_rows, 80)
      assert_true(mel.n_cols > 0)
    }
    Err(_) => assert_true(false)
  }

  match @moonmel.log_mel_spectrogram(samples, config=cfg) {
    Ok(log_mel) => {
      assert_eq(log_mel.n_rows, 80)
      assert_true(log_mel.n_cols > 0)
    }
    Err(_) => assert_true(false)
  }

  match @moonmel.mfcc(samples, config=cfg) {
    Ok(mfccs) => {
      assert_eq(mfccs.n_rows, 13)
      assert_true(mfccs.n_cols > 0)
    }
    Err(_) => assert_true(false)
  }
}

test "numerical_parity_with_librosa_reference" {
  let cfg = @moonmel.FeatureConfig::default()

  // 1. Hann Window numerical check against scipy/librosa
  let win = @moonmel.create_window(PeriodicHann, 1024)
  assert_true((win[0] - 0.0).abs() < 1.0e-12)
  assert_true((win[1] - 9.412358699445456e-06).abs() < 1.0e-10)
  assert_true((win[256] - 0.5).abs() < 1.0e-10)
  assert_true((win[512] - 1.0).abs() < 1.0e-10)
  assert_true((win[1023] - 9.412358699445456e-06).abs() < 1.0e-10)

  // 2. Mel Filterbank numerical check against librosa
  match @moonmel.mel_filterbank(cfg) {
    Ok(fb) => {
      assert_eq(fb.n_rows, 80)
      assert_eq(fb.n_cols, 513)
      // Check filter 0 max ~ 0.02253456
      let mut max_0 = 0.0
      let mut argmax_0 = 0
      for c in 0..<513 {
        let v = fb.at(0, c)
        if v > max_0 {
          max_0 = v
          argmax_0 = c
        }
      }
      assert_eq(argmax_0, 2)
      assert_true((max_0 - 0.02253456).abs() < 1.0e-5)

      // Check filter 10 max ~ 0.02441513, argmax = 26
      let mut max_10 = 0.0
      let mut argmax_10 = 0
      for c in 0..<513 {
        let v = fb.at(10, c)
        if v > max_10 {
          max_10 = v
          argmax_10 = c
        }
      }
      assert_eq(argmax_10, 26)
      assert_true((max_10 - 0.02441513).abs() < 1.0e-5)
    }
    Err(_) => assert_true(false)
  }

  // 3. Sine 440 Hz STFT, Mel, Log-Mel, MFCC numerical parity
  let sr = 16000.0
  let pi = 3.14159265358979323846264338327950288
  let samples : Array[Double] = Array::make(4000, 0.0)
  for i in 0..<4000 {
    let t = i.to_double() / sr
    samples[i] = @math.sin(2.0 * pi * 440.0 * t)
  }

  // Check STFT power spectrum probe
  match @moonmel.stft(samples, config=cfg) {
    Ok(stft_mat) => {
      assert_eq(stft_mat.n_cols, 16)
      let p28 = stft_mat.at(28, 8)
      let p29 = stft_mat.at(29, 8)
      assert_true((p28 - 63403.79).abs() < 1.0)
      assert_true((p29 - 25199.78).abs() < 1.0)
    }
    Err(_) => assert_true(false)
  }

  // Check MFCC probe at frame 8
  match @moonmel.mfcc(samples, config=cfg) {
    Ok(mfcc_mat) => {
      assert_eq(mfcc_mat.n_rows, 13)
      assert_eq(mfcc_mat.n_cols, 16)
      let ref_mfcc = [
        -382.8412,
        49.6230,
        34.3304,
        12.5705,
        -10.9932,
        -31.4456,
        -44.7312,
        -48.5245,
        -42.6553,
        -29.0133,
        -10.9842,
        7.4128,
        22.4587,
      ]
      for k in 0..<13 {
        let actual = mfcc_mat.at(k, 8)
        let expected = ref_mfcc[k]
        assert_true((actual - expected).abs() < 0.05)
      }
    }
    Err(_) => assert_true(false)
  }
}
