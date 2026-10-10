///|
test "types_audio_buffer" {
  let buf = AudioBuffer::new([0.1, 0.2, 0.3], 16000)
  match buf {
    Ok(b) => {
      assert_eq(b.length(), 3)
      assert_eq(b.sample_rate, 16000)
      assert_true((b.duration() - 3.0 / 16000.0).abs() < 1.0e-7)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "types_feature_matrix_transpose" {
  let mat = FeatureMatrix::zeros(2, 3)
  mat.set(0, 1, 42.0)
  let transposed = mat.transpose()
  assert_eq(transposed.n_rows, 3)
  assert_eq(transposed.n_cols, 2)
  assert_eq(transposed.at(1, 0), 42.0)
}

///|
test "types_complex_math" {
  let a = complex(1.0, 2.0)
  let b = complex(3.0, 4.0)
  let c = a.mul(b) // (1*3 - 2*4) + i(1*4 + 2*3) = -5 + 10i
  assert_eq(c.re, -5.0)
  assert_eq(c.im, 10.0)
  assert_eq(a.abs2(), 5.0)
}
