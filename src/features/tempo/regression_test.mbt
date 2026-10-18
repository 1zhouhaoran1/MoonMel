///|
test "silence has no detected tempo" {
  assert_eq(
    @tempo.tempogram_from_onset(Array::make(200, 0.0), 16000, 256).bpm,
    0.0,
  )
  assert_eq(@tempo.tempogram_from_onset([], 16000, 256).bpm, 0.0)
}

///|
test "tempo candidates stay inside fractional BPM bounds" {
  let env = Array::make(400, 0.0)
  for frame in 0..<env.length() {
    if frame % 21 == 0 {
      env[frame] = 1.0
    }
  }
  let result = @tempo.tempogram_from_onset(env, 10000, 100, config={
    ..@tempo.TempoConfig::default(),
    min_bpm: 280.0,
    max_bpm: 290.0,
    start_bpm: 285.0,
    win_length: 126,
    hop_length: 21,
  })
  assert_eq(result.tempi.length(), 1)
  assert_eq(result.tempogram.n_rows, 1)
  assert_true(result.tempogram.at(0, 0) > 0.0)
  assert_true((result.bpm - 6000.0 / 21.0).abs() < 1.0e-12)
  for bpm in result.tempi {
    assert_true(bpm >= 280.0 && bpm <= 290.0)
  }
}

///|
test "tempo returns empty when no integer lag fits BPM bounds and the window" {
  for
    bounds in [
      (290.0, 299.0, 200),
      (30.0, 40.0, 8),
      (100000.0, 100001.0, 200),
      (1.0e-300, 1.0e-299, 200),
    ] {
    let (min_bpm, max_bpm, length) = bounds
    let result = @tempo.tempogram_from_onset(
      Array::make(length, 1.0),
      10000,
      100,
      config={ ..@tempo.TempoConfig::default(), min_bpm, max_bpm, },
    )
    assert_eq(result.bpm, 0.0)
    assert_eq(result.tempi.length(), 0)
    assert_eq(result.tempogram.n_rows, 0)
    assert_eq(result.tempogram.n_cols, 0)
  }
}

///|
test "tempo preserves exact BPM endpoints and periodic-click detection" {
  let env = Array::make(400, 0.0)
  for frame in 0..<env.length() {
    if frame % 50 == 0 {
      env[frame] = 1.0
    }
  }
  let result = @tempo.tempogram_from_onset(env, 10000, 100, config={
    ..@tempo.TempoConfig::default(),
    min_bpm: 120.0,
    max_bpm: 240.0,
    win_length: 150,
    hop_length: 10,
  })
  assert_eq(result.tempi.length(), 26)
  assert_eq(result.tempogram.n_rows, 26)
  assert_eq(result.tempogram.n_cols, 26)
  assert_eq(result.tempi[0], 240.0)
  assert_eq(result.tempi[25], 120.0)
  assert_true((result.bpm - 120.0).abs() < 1.0e-12)
}
