///|
test "config rejects non finite and unsafe numerical options" {
  assert_true(
    { ..FeatureConfig::default(), f_min: 0.0 / 0.0, }.validate() is Err(_),
  )
  assert_true({ ..FeatureConfig::default(), amin: 0.0, }.validate() is Err(_))
  assert_true({ ..FeatureConfig::default(), n_mfcc: -1, }.validate() is Err(_))
  assert_true(
    { ..FeatureConfig::default(), top_db: -1.0, }.validate() is Err(_),
  )
  assert_true(!is_finite(1.0 / 0.0))
}

///|
test "ragged matrices return a shape error" {
  assert_true(FeatureMatrix::new([[1.0], [2.0, 3.0]]).validate() is Err(_))
}
