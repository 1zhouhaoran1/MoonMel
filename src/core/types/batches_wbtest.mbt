///|
test "frame concatenation preserves chronological columns and owns its data" {
  let first = FeatureMatrix::new([[1.0, 2.0], [3.0, 4.0]])
  let last = FeatureMatrix::new([[5.0], [6.0]])
  let combined = FeatureMatrix::concat_frames([
    first,
    FeatureMatrix::zeros(2, 0),
    last,
  ]).unwrap()
  assert_eq(combined.data, [[1.0, 2.0, 5.0], [3.0, 4.0, 6.0]])
  combined.set(0, 0, 99.0)
  assert_eq(first.at(0, 0), 1.0)
  first.set(1, 0, 77.0)
  assert_eq(combined.at(1, 0), 3.0)
}

///|
test "frame concatenation rejects ragged and mismatched batches" {
  assert_true(
    FeatureMatrix::concat_frames([FeatureMatrix::new([[1.0], []])]) is Err(_),
  )
  assert_true(
    FeatureMatrix::concat_frames([
      FeatureMatrix::zeros(2, 0),
      FeatureMatrix::zeros(3, 0),
    ])
    is Err(_),
  )
  assert_eq(FeatureMatrix::concat_frames([]).unwrap().n_rows, 0)
  assert_eq(
    FeatureMatrix::concat_frames([FeatureMatrix::zeros(4, 0)]).unwrap().n_rows,
    4,
  )
  assert_eq(
    FeatureMatrix::concat_frames([
      FeatureMatrix::zeros(0, 3),
      FeatureMatrix::zeros(0, 2),
    ]).unwrap().n_cols,
    5,
  )
  assert_true(
    FeatureMatrix::concat_frames([
      FeatureMatrix::zeros(0, 2147483647),
      FeatureMatrix::zeros(0, 1),
    ])
    is Err(_),
  )
}
