///|
test "single-bin SuperFlux preserves spectral flux during frequency migration" {
  let spec = @types.FeatureMatrix::new([
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
  ])
  let expected = @onset.spectral_flux(spec)
  for width in [1, 0, -1] {
    let actual = @onset.super_flux(spec, width)
    let envelope = @onset.onset_strength(spec, {
      mode: SuperFlux(width),
      normalize: false,
    })
    for frame in 0..<expected.length() {
      assert_eq(actual[frame], expected[frame])
      assert_eq(envelope[frame], expected[frame])
    }
  }
  assert_eq(expected[1], 1.0)
  assert_eq(expected[2], 1.0)
}

///|
test "SuperFlux wider windows suppress neighboring-bin migration" {
  let spec = @types.FeatureMatrix::new([
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
  ])
  let flux = @onset.super_flux(spec, 3)
  for value in flux {
    assert_eq(value, 0.0)
  }
  let rising = @types.FeatureMatrix::new([[2.0, 0.0], [0.0, 3.0], [0.0, 0.0]])
  assert_eq(@onset.super_flux(rising, 3)[1], 1.0)
  assert_eq(spec.at(0, 0), 1.0)
}

///|
test "SuperFlux supports single-frequency and empty-frame spectrograms" {
  let spec = @types.FeatureMatrix::new([[0.0, 2.0, 1.0, 4.0]])
  let expected = [0.0, 2.0, 0.0, 3.0]
  for width in [1, 3, 31] {
    let actual = @onset.super_flux(spec, width)
    for frame in 0..<expected.length() {
      assert_eq(actual[frame], expected[frame])
    }
    assert_eq(
      @onset.super_flux(@types.FeatureMatrix::zeros(3, 0), width).length(),
      0,
    )
    let single = @onset.super_flux(@types.FeatureMatrix::new([[1.0]]), width)
    assert_eq(single.length(), 1)
    assert_eq(single[0], 0.0)
  }
}
