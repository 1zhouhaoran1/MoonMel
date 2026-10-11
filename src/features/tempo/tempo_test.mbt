///|
test "tempogram_periodic_clicks_120bpm" {
  let sr = 10000
  let hop = 100
  let len = 400
  let env : Array[Double] = Array::make(len, 0.0)

  // 120 BPM -> 2 beats per sec -> click every 50 frames
  let period_frames = 50
  let mut i = 0
  while i < len {
    env[i] = 1.0
    i = i + period_frames
  }

  let res = @tempo.tempogram_from_onset(env, sr, hop, config={
    min_bpm: 60.0,
    max_bpm: 240.0,
    start_bpm: 120.0,
    std_bpm: 1.0,
    win_length: 150,
    hop_length: 10,
  })

  assert_true(res.tempogram.n_rows > 0)
  assert_true(res.tempogram.n_cols > 0)
  // Estimated BPM should be close to 120.0
  assert_true((res.bpm - 120.0).abs() < 5.0)
}

///|
test "tempogram_audio_pipeline" {
  let sr = 16000
  let n_samples = 32000 // 2 seconds
  let samples : Array[Double] = Array::make(n_samples, 0.0)

  // Periodic clicks at 0.5s intervals (120 BPM)
  let click_period = 8000
  let mut idx = 0
  while idx < n_samples {
    for j in 0..<200 {
      if idx + j < n_samples {
        samples[idx + j] = 1.0
      }
    }
    idx = idx + click_period
  }

  let audio = @types.AudioBuffer::new(samples, sr).unwrap()
  let f_cfg = @types.FeatureConfig::default()
  let res = @tempo.tempogram(audio, f_cfg).unwrap()

  assert_true(res.bpm >= 30.0 && res.bpm <= 300.0)
  assert_true(res.tempogram.n_rows > 0)
}
