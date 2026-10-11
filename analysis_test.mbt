///|
test "shared pipeline preserves every standalone feature" {
  let samples = Array::make(1200, 0.0)
  for i in 0..<samples.length() {
    samples[i] = @math.sin(i.to_double() * 0.17)
  }
  let cfg = @moonmel.FeatureConfig::default()
  let result = @moonmel.analyze(samples, config=cfg).unwrap()
  let expected_mel = @moonmel.mel_spectrogram(samples, config=cfg).unwrap()
  let expected_log = @moonmel.log_mel_spectrogram(samples, config=cfg).unwrap()
  let expected_mfcc = @moonmel.mfcc(samples, config=cfg).unwrap()
  for r in 0..<expected_mel.n_rows {
    for c in 0..<expected_mel.n_cols {
      assert_true((result.mel.at(r, c) - expected_mel.at(r, c)).abs() < 1.0e-9)
      assert_true(
        (result.log_mel.at(r, c) - expected_log.at(r, c)).abs() < 1.0e-9,
      )
    }
  }
  for r in 0..<expected_mfcc.n_rows {
    for c in 0..<expected_mfcc.n_cols {
      assert_true(
        (result.mfcc.at(r, c) - expected_mfcc.at(r, c)).abs() < 1.0e-9,
      )
    }
  }
}
