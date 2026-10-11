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

///|
test "facade_spectral_features" {
  let sig = Array::make(3200, 0.5)
  let cfg = @moonmel.FeatureConfig::default()
  let centroid = @moonmel.spectral_centroid(sig, config=cfg).unwrap()
  let rolloff = @moonmel.spectral_rolloff(sig, config=cfg).unwrap()
  let flatness = @moonmel.spectral_flatness(sig, config=cfg).unwrap()
  let audio = @moonmel.AudioBuffer::new(sig, 16000).unwrap()
  let zcr = @moonmel.zero_crossing_rate(audio).unwrap()

  assert_eq(centroid.n_rows, 1)
  assert_eq(rolloff.n_rows, 1)
  assert_eq(flatness.n_rows, 1)
  assert_eq(zcr.n_rows, 1)
  assert_true(centroid.n_cols > 0)
  assert_true(rolloff.n_cols > 0)
}

///|
test "facade_multichannel_pipeline" {
  let ch0 = Array::make(2048, 0.3)
  let ch1 = Array::make(2048, 0.6)
  let multi = @moonmel.MultiChannelAudioBuffer::new([ch0, ch1], 16000).unwrap()
  assert_eq(multi.num_channels(), 2)

  let cfg = {
    ..@moonmel.FeatureConfig::default(),
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
    n_mels: 20,
    n_mfcc: 13,
  }

  let mels = @moonmel.multichannel_mel(multi, config=cfg).unwrap()
  assert_eq(mels.length(), 2)
  assert_eq(mels[0].n_rows, 20)

  let ild = @moonmel.interchannel_level_difference(multi, 1, 0, config=cfg).unwrap()
  assert_eq(ild.n_rows, 257)
  let ipd = @moonmel.interchannel_phase_difference(multi, 0, 1, config=cfg).unwrap()
  assert_eq(ipd.n_rows, 257)
}

///|
test "facade_chroma_and_padded_fft" {
  // Test pitch class name
  assert_eq(@moonmel.pitch_class_name(0), "C")
  assert_eq(@moonmel.pitch_class_name(9), "A")

  // Test chroma filterbank
  let fb = @moonmel.chroma_filterbank(16000, 1024)
  assert_eq(fb.n_rows, 12)
  assert_eq(fb.n_cols, 513)

  // Test chroma STFT on audio
  let sig = Array::make(2048, 0.0)
  for i in 0..<2048 {
    sig[i] = @math.sin(i.to_double() * 0.1)
  }
  let chroma = @moonmel.chroma_stft(sig).unwrap()
  assert_eq(chroma.n_rows, 12)
  assert_true(chroma.n_cols > 0)

  // Test padded FFT
  let non_pow2 = [
    @moonmel.Complex::{ re: 1.0, im: 0.0, },
    @moonmel.Complex::{ re: 2.0, im: 0.0, },
    @moonmel.Complex::{ re: 3.0, im: 0.0, },
  ]
  let padded_fft_res = @moonmel.fft_padded(non_pow2).unwrap()
  assert_eq(padded_fft_res.length(), 4)

  // Test padded RFFT
  let non_pow2_real = [1.0, 2.0, 3.0]
  let padded_rfft_res = @moonmel.rfft_padded(non_pow2_real).unwrap()
  assert_eq(padded_rfft_res.length(), 3) // 4/2 + 1
}

///|
test "facade_bluestein_arbitrary_dft" {
  // Prime length 3 exact test
  let prime3 = [
    @moonmel.Complex::{ re: 1.0, im: 0.0, },
    @moonmel.Complex::{ re: 2.0, im: 0.0, },
    @moonmel.Complex::{ re: 3.0, im: 0.0, },
  ]
  let res3 = @moonmel.dft(prime3).unwrap()
  assert_eq(res3.length(), 3)
  assert_true((res3[0].re - 6.0).abs() < 1.0e-7)

  // Prime length 5 roundtrip
  let prime5 = [
    @moonmel.Complex::{ re: 2.0, im: 1.0, },
    @moonmel.Complex::{ re: -1.0, im: 3.0, },
    @moonmel.Complex::{ re: 0.0, im: -2.0, },
    @moonmel.Complex::{ re: 4.0, im: 0.5, },
    @moonmel.Complex::{ re: -2.5, im: -1.5, },
  ]
  let spec5 = @moonmel.dft(prime5).unwrap()
  let rec5 = @moonmel.idft(spec5).unwrap()
  assert_eq(rec5.length(), 5)
  for i in 0..<5 {
    assert_true((rec5[i].re - prime5[i].re).abs() < 1.0e-7)
    assert_true((rec5[i].im - prime5[i].im).abs() < 1.0e-7)
  }
}

///|
test "facade_cqt" {
  let cfg = @moonmel.CqtConfig::default()
  let freqs = @moonmel.cqt_frequencies(cfg)
  assert_eq(freqs.length(), 84)

  let sig = Array::make(3200, 0.0)
  for i in 0..<3200 {
    sig[i] = @math.sin(i.to_double() * 0.1)
  }
  let cqt_mat = @moonmel.cqt(sig, config=cfg).unwrap()
  assert_eq(cqt_mat.n_rows, 84)
  assert_true(cqt_mat.n_cols > 0)
}

///|
test "facade_resample" {
  let sig = Array::make(4800, 0.5)
  let down = @moonmel.resample(sig, 48000, 16000).unwrap()
  assert_eq(down.length(), 1600)

  let down_poly = @moonmel.resample_polyphase(sig, 48000, 16000).unwrap()
  assert_eq(down_poly.length(), 1600)

  let down_sinc = @moonmel.resample_sinc(sig, 48000, 16000).unwrap()
  assert_eq(down_sinc.length(), 1600)

  let down_lin = @moonmel.resample_linear(sig, 48000, 16000).unwrap()
  assert_eq(down_lin.length(), 1600)
}

///|
test "facade_hpss" {
  let sig = Array::make(3200, 0.0)
  for i in 0..<3200 {
    sig[i] = @math.sin(i.to_double() * 0.2)
  }
  let hpss_res = @moonmel.hpss_from_audio(sig).unwrap()
  assert_eq(hpss_res.harmonic.n_rows, 513)
  assert_true(hpss_res.harmonic.n_cols > 0)

  let h_ratio = @moonmel.harmonic_energy_ratio(hpss_res)
  let p_ratio = @moonmel.percussive_energy_ratio(hpss_res)
  assert_eq(h_ratio.length(), hpss_res.harmonic.n_cols)
  assert_eq(p_ratio.length(), hpss_res.harmonic.n_cols)

  let med1d = @moonmel.median_filter_1d([1.0, 50.0, 2.0], 3)
  assert_eq(med1d[1], 2.0)
}

///|
test "facade_loudness" {
  let sr = 48000
  let n_samples = 4800
  let sig = Array::make(n_samples, 0.0)
  for i in 0..<n_samples {
    sig[i] = @math.sin(i.to_double() * 0.1) * 0.5
  }
  let res = @moonmel.loudness_meter(sig, sample_rate=sr).unwrap()
  assert_true(res.integrated < 0.0)
  assert_true(res.true_peak < 0.0)

  let kw = @moonmel.apply_k_weighting(sig, sr)
  assert_eq(kw.length(), n_samples)
}

///|
test "facade_onset" {
  let sig = Array::make(4000, 0.0)
  for i in 1000..<2000 {
    sig[i] = 1.0
  }
  let env = @moonmel.onset_strength_audio(sig).unwrap()
  assert_true(env.length() > 0)

  let onsets = @moonmel.onset_detect_audio(sig).unwrap()
  assert_true(onsets.length() > 0)
}

///|
test "facade_lpc" {
  let sig = Array::make(500, 0.3)
  let lpc_res = @moonmel.lpc(sig, 4).unwrap()
  assert_eq(lpc_res.coeffs.length(), 4)

  let lpcc = @moonmel.lpc_to_lpcc(lpc_res.coeffs, lpc_res.prediction_error, 8)
  assert_eq(lpcc.length(), 8)

  let lpc_mat = @moonmel.lpc_features(sig, 4, 128, 64).unwrap()
  assert_eq(lpc_mat.n_rows, 4)
  assert_true(lpc_mat.n_cols > 0)
}

///|
test "facade_pitch" {
  let sr = 16000
  let n = 3200
  let sig = Array::make(n, 0.0)
  let pi2 = 2.0 * @math.PI
  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    sig[i] = @math.sin(pi2 * 440.0 * t)
  }
  let track = @moonmel.pitch_yin(sig, sample_rate=sr).unwrap()
  assert_true(track.f0.length() > 0)
  assert_true((track.f0[0] - 440.0).abs() < 2.0)
}

///|
test "facade_tempo" {
  let env = Array::make(200, 0.5)
  let res = @moonmel.tempogram_from_onset(env, 16000, 512)
  assert_true(res.tempogram.n_rows > 0)
  assert_true(res.bpm > 0.0)
}
