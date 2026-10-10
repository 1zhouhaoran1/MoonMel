///|
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

///|
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
        -382.8412, 49.6230, 34.3304, 12.5705, -10.9932, -31.4456, -44.7312, -48.5245,
        -42.6553, -29.0133, -10.9842, 7.4128, 22.4587,
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

///|
test "facade_preemphasis_and_deemphasis" {
  let sig = [0.1, -0.4, 0.7, -0.2, 0.9, -0.5]
  let filtered = @moonmel.preemphasis(sig, alpha=0.97)
  let restored = @moonmel.deemphasis(filtered, alpha=0.97)
  for i in 0..<sig.length() {
    assert_true((restored[i] - sig[i]).abs() < 1.0e-12)
  }
}

///|
test "facade_delta_and_delta_delta" {
  let samples : Array[Double] = Array::make(3200, 0.0)
  for i in 0..<3200 {
    samples[i] = @math.sin(i.to_double() * 0.05)
  }
  let mfccs = @moonmel.mfcc(samples).unwrap()
  let deltas = @moonmel.compute_delta(mfccs, width=5, order=1).unwrap()
  let delta_deltas = @moonmel.compute_delta(mfccs, width=5, order=2).unwrap()
  assert_eq(deltas.n_rows, 13)
  assert_eq(deltas.n_cols, mfccs.n_cols)
  assert_eq(delta_deltas.n_rows, 13)
  assert_eq(delta_deltas.n_cols, mfccs.n_cols)
}

///|
test "facade_rms_and_energy" {
  let samples = Array::make(2048, 1.5)
  let audio = @moonmel.AudioBuffer::new(samples, 16000).unwrap()
  let rms = @moonmel.compute_rms(audio, frame_length=512, hop_length=256).unwrap()
  let energy = @moonmel.compute_energy(audio, frame_length=512, hop_length=256).unwrap()
  assert_eq(rms.n_rows, 1)
  assert_eq(rms.n_cols, energy.n_cols)
  for c in 0..<rms.n_cols {
    let r = rms.at(0, c)
    assert_true((r - 1.5).abs() < 1.0e-10)
  }
}

///|
test "facade_resampling" {
  let sig = Array::make(4800, 1.0)
  let down = @moonmel.resample(sig, 48000, 16000).unwrap()
  let lin = @moonmel.resample_linear(sig, 48000, 16000).unwrap()
  assert_eq(down.length(), 1600)
  assert_eq(lin.length(), 1600)
}

///|
test "facade_streaming_pipeline" {
  let cfg = {
    ..@moonmel.FeatureConfig::default(),
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
    n_mels: 20,
    n_mfcc: 13,
  }
  let ext = @moonmel.create_streaming_extractor(config=cfg).unwrap()
  ext.push_samples(Array::make(512, 0.5))
  assert_eq(ext.available_frames(), 1)
  let mel = ext.pop_mel_frames()
  assert_eq(mel.n_rows, 20)
  assert_eq(mel.n_cols, 1)
}
