///|
test "phase_vocoder_rate_1" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 256,
    win_length: 256,
    hop_length: 64,
  }
  let signal : Array[Double] = Array::make(1024, 0.0)
  for i in 0..<1024 {
    signal[i] = @math.sin(2.0 * @math.PI * 440.0 * i.to_double() / 16000.0)
  }
  let frames = match @stft.stft_complex(signal, cfg) {
    Ok(f) => f
    Err(_) => {
      assert_true(false)
      return
    }
  }
  let voc = match
    @effects.phase_vocoder(frames, 1.0, cfg.hop_length, cfg.n_fft) {
    Ok(v) => v
    Err(_) => {
      assert_true(false)
      return
    }
  }
  assert_eq(voc.length(), frames.length())
}

///|
test "time_stretch_half_and_double" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 256,
    win_length: 256,
    hop_length: 64,
    center: true,
  }
  let n = 1024
  let signal : Array[Double] = Array::make(n, 0.0)
  for i in 0..<n {
    signal[i] = @math.sin(2.0 * @math.PI * 440.0 * i.to_double() / 16000.0)
  }

  // Double speed (half duration: ~512)
  let faster = match @effects.time_stretch(signal, 2.0, cfg) {
    Ok(s) => s
    Err(_) => {
      assert_true(false)
      return
    }
  }
  assert_eq(faster.length(), 512)

  // Half speed (double duration: ~2048)
  let slower = match @effects.time_stretch(signal, 0.5, cfg) {
    Ok(s) => s
    Err(_) => {
      assert_true(false)
      return
    }
  }
  assert_eq(slower.length(), 2048)
}

///|
test "pitch_shift_preserves_length" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 256,
    win_length: 256,
    hop_length: 64,
    center: true,
  }
  let n = 1024
  let signal : Array[Double] = Array::make(n, 0.0)
  for i in 0..<n {
    signal[i] = @math.sin(2.0 * @math.PI * 440.0 * i.to_double() / 16000.0)
  }

  // Shift +4 semitones (major third up)
  let up = match @effects.pitch_shift(signal, 16000, 4.0, cfg) {
    Ok(s) => s
    Err(_) => {
      assert_true(false)
      return
    }
  }
  assert_eq(up.length(), n)

  // Shift -5 semitones (fourth down)
  let down = match @effects.pitch_shift(signal, 16000, -5.0, cfg) {
    Ok(s) => s
    Err(_) => {
      assert_true(false)
      return
    }
  }
  assert_eq(down.length(), n)
}
