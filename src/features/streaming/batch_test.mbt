///|
test "checked streaming append rejects a whole nonfinite chunk without mutation" {
  let config = {
    ..@types.FeatureConfig::default(),
    n_fft: 8,
    win_length: 8,
    hop_length: 4,
    n_mels: 4,
    n_mfcc: 2,
    center: false,
  }
  let extractor = @streaming.StreamingExtractor::new(config~).unwrap()
  extractor.try_push_samples([0.1, 0.2]).unwrap()
  assert_true(extractor.try_push_samples([0.3, 0.0 / 0.0, 0.4]) is Err(_))
  assert_true(extractor.try_push_samples([1.0 / 0.0]) is Err(_))
  assert_eq(extractor.buffered_samples(), 2)
  extractor.try_push_samples([]).unwrap()
  assert_eq(extractor.buffered_samples(), 2)
  extractor.reset()
  assert_eq(extractor.buffered_samples(), 0)
}

///|
test "combined streaming batch shares identical frame columns with offline features" {
  let config = {
    ..@types.FeatureConfig::default(),
    n_fft: 16,
    win_length: 10,
    hop_length: 5,
    n_mels: 4,
    n_mfcc: 2,
    center: false,
    log_scale: NaturalLog,
  }
  let samples = Array::make(41, 0.0)
  for i in 0..<samples.length() {
    samples[i] = @math.sin(i.to_double() * 0.7)
  }
  let extractor = @streaming.StreamingExtractor::new(config~).unwrap()
  let expected_mel = @mel.mel_spectrogram(samples, config).unwrap()
  let expected_log = @mfcc.log_mel_from_mel(expected_mel, config).unwrap()
  let expected_mfcc = @mfcc.mfcc_from_log_mel(expected_log, config).unwrap()
  let mut column = 0
  for i in 0..<samples.length() {
    extractor.try_push_samples([samples[i]]).unwrap()
    let batch = extractor.pop_features().unwrap()
    assert_eq(batch.mel.n_cols, batch.log_mel.n_cols)
    assert_eq(batch.mel.n_cols, batch.mfcc.n_cols)
    for c in 0..<batch.mel.n_cols {
      for r in 0..<batch.mel.n_rows {
        assert_true(
          (batch.mel.at(r, c) - expected_mel.at(r, column)).abs() < 1.0e-10,
        )
        assert_true(
          (batch.log_mel.at(r, c) - expected_log.at(r, column)).abs() < 1.0e-10,
        )
      }
      for r in 0..<batch.mfcc.n_rows {
        assert_true(
          (batch.mfcc.at(r, c) - expected_mfcc.at(r, column)).abs() < 1.0e-10,
        )
      }
      column = column + 1
    }
  }
  assert_eq(column, expected_mel.n_cols)
  assert_eq(extractor.pop_features().unwrap().mfcc.n_cols, 0)
}
