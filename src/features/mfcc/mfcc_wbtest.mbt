///|
test "mfcc_shape_and_range" {
  let samples : Array[Double] = Array::make(4000, 0.0)
  for i in 0..<4000 {
    samples[i] = @math.sin(i.to_double() * 0.1)
  }
  let cfg = @types.FeatureConfig::default()
  match mfcc(samples, cfg) {
    Ok(mat) => {
      assert_eq(mat.n_rows, 13)
      assert_true(mat.n_cols > 0)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "mfcc_dct_ortho" {
  let input = [1.0, 2.0, 3.0, 4.0]
  let out = dct_ii(input, 4, true)
  assert_eq(out.length(), 4)
  // DCT-II zeroth coefficient with ortho norm is sum(x) / sqrt(N) = 10.0 / 2.0 = 5.0
  assert_true((out[0] - 5.0).abs() < 1.0e-7)
}
