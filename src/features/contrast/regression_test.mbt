///|
test "contrast reports decibels and linear differences" {
  let spec = @types.FeatureMatrix::new([[1.0], [100.0]])
  let cfg = {
    ..@contrast.ContrastConfig::default(),
    n_bands: 0,
    quantile: 0.0,
  }
  assert_true(
    (@contrast.spectral_contrast(spec, 16000, 2, config=cfg).at(0, 0) - 20.0).abs() <
    1.0e-9,
  )
  assert_true(
    (@contrast.spectral_contrast(spec, 16000, 2, config={ ..cfg, linear: true, }).at(
      0, 0,
    ) -
    99.0).abs() <
    1.0e-9,
  )
  assert_eq(@contrast.quantile_sorted([1.0, 2.0], -1.0), 1.0)
}
