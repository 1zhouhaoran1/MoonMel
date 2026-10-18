///|
test "chroma rejects nonfinite tuning without indexing an empty filterbank" {
  let spec = @types.FeatureMatrix::new([[0.0], [0.0], [1.0]])
  for tuning in [0.0 / 0.0, 1.0 / 0.0, -1.0 / 0.0] {
    assert_true(
      @chroma.chroma_from_spectrogram(spec, 16000, 4, None, tuning, 0.0)
      is Err(DimensionMismatch(_)),
    )
  }
}

///|
test "chroma rejects invalid frequency cutoffs" {
  let spec = @types.FeatureMatrix::new([[0.0], [0.0], [1.0]])
  for cutoff in [-1.0, 8001.0, 0.0 / 0.0, 1.0 / 0.0, -1.0 / 0.0] {
    assert_true(
      @chroma.chroma_from_spectrogram(spec, 16000, 4, None, 0.0, cutoff)
      is Err(InvalidFrequencyRange(_, _)),
    )
  }
}

///|
test "chroma accepts cutoff endpoints and preserves empty frame shape" {
  let spec = @types.FeatureMatrix::new([[0.0], [0.0], [1.0]])
  for cutoff in [0.0, 8000.0] {
    let result = @chroma.chroma_from_spectrogram(
      spec,
      16000,
      4,
      L1,
      0.0,
      cutoff,
    ).unwrap()
    assert_eq(result.n_rows, 12)
    assert_eq(result.n_cols, 1)
    let mut sum = 0.0
    for value in result.get_col(0) {
      assert_true(@types.is_finite(value) && value >= 0.0)
      sum = sum + value
    }
    assert_true((sum - 1.0).abs() < 1.0e-12)
  }
  let empty = @chroma.chroma_from_spectrogram(
    @types.FeatureMatrix::zeros(3, 0),
    16000,
    4,
    None,
    0.0,
    0.0,
  ).unwrap()
  assert_eq(empty.n_rows, 12)
  assert_eq(empty.n_cols, 0)
  assert_eq(spec.at(2, 0), 1.0)
}
