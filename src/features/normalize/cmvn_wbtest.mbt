///|
test "CMVN centers rows and uses population variance without mutating input" {
  let input = @types.FeatureMatrix::new([[1.0, 2.0, 3.0], [7.0, 7.0, 7.0]])
  let output = cmvn(input).unwrap()
  let expected = 1.5.sqrt()
  assert_true((output.at(0, 0) + expected).abs() < 1.0e-12)
  assert_true(output.at(0, 1).abs() < 1.0e-12)
  assert_true((output.at(0, 2) - expected).abs() < 1.0e-12)
  assert_eq(output.get_row(1), [0.0, 0.0, 0.0])
  assert_eq(input.data, [[1.0, 2.0, 3.0], [7.0, 7.0, 7.0]])
  let centered = cmvn(input, normalize_variance=false).unwrap()
  assert_true((centered.at(0, 0) + 1.0).abs() < 1.0e-12)
}

///|
test "CMVN handles huge finite values and floors nearly constant rows" {
  let offset = cmvn(
    @types.FeatureMatrix::new([[1.0e12 + 1.0, 1.0e12 + 2.0, 1.0e12 + 3.0]]),
  ).unwrap()
  assert_true((offset.at(0, 0) + 1.5.sqrt()).abs() < 1.0e-9)
  assert_true(offset.at(0, 1).abs() < 1.0e-9)
  let huge = cmvn(@types.FeatureMatrix::new([[-1.0e300, 1.0e300]])).unwrap()
  assert_eq(huge.get_row(0), [-1.0, 1.0])
  let floored = cmvn(
    @types.FeatureMatrix::new([[-1.0e-8, 1.0e-8]]),
    variance_floor=1.0e-4,
  ).unwrap()
  assert_true((floored.at(0, 0) + 1.0e-6).abs() < 1.0e-14)
  assert_eq(cmvn(@types.FeatureMatrix::new([[3.0]])).unwrap().at(0, 0), 0.0)
}

///|
test "CMVN validates matrix values floors and empty frame shapes" {
  assert_eq(cmvn(@types.FeatureMatrix::zeros(3, 0)).unwrap().n_rows, 3)
  assert_eq(cmvn(@types.FeatureMatrix::zeros(0, 4)).unwrap().n_cols, 4)
  assert_true(cmvn(@types.FeatureMatrix::new([[1.0], []])) is Err(_))
  assert_true(cmvn(@types.FeatureMatrix::new([[0.0 / 0.0]])) is Err(_))
  assert_true(cmvn(@types.FeatureMatrix::new([[1.0 / 0.0]])) is Err(_))
  for floor in [0.0, -1.0, 0.0 / 0.0, 1.0 / 0.0] {
    assert_true(
      cmvn(@types.FeatureMatrix::new([[1.0]]), variance_floor=floor) is Err(_),
    )
  }
}
