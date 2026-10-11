///|
test "increased margins suppress both masks and leave residual" {
  let spec = @types.FeatureMatrix::new([[1.0]])
  let cfg = {
    ..@hpss.HpssConfig::default(),
    margin_harm: 2.0,
    margin_perc: 2.0,
  }
  let result = @hpss.hpss(spec, cfg)
  assert_true((result.harmonic.at(0, 0) - 0.2).abs() < 1.0e-9)
  assert_true((result.percussive.at(0, 0) - 0.2).abs() < 1.0e-9)
}
