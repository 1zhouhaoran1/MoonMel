///|
test "delta: constant matrix produces all zeros" {
  let mat = @types.FeatureMatrix::zeros(4, 10)
  for r in 0..<4 {
    for c in 0..<10 {
      mat.set(r, c, 5.0)
    }
  }
  let d = compute_delta(mat, width=5, order=1).unwrap()
  assert_eq(d.n_rows, 4)
  assert_eq(d.n_cols, 10)
  for r in 0..<4 {
    for c in 0..<10 {
      assert_true(d.at(r, c).abs() < 1.0e-12)
    }
  }
}

///|
test "delta: linear ramp preserves slope" {
  let mat = @types.FeatureMatrix::zeros(1, 11)
  for t in 0..<11 {
    mat.set(0, t, 2.0 * t.to_double())
  }
  let d = compute_delta(mat, width=5, order=1).unwrap()
  for t in 2..<=8 {
    let err = (d.at(0, t) - 2.0).abs()
    assert_true(err < 1.0e-12)
  }
}

///|
test "delta: invalid width returns error" {
  let mat = @types.FeatureMatrix::zeros(2, 5)
  let res_even = compute_delta(mat, width=4)
  assert_true(res_even is Err(_))
  let res_small = compute_delta(mat, width=1)
  assert_true(res_small is Err(_))
}

///|
test "delta: second order on linear ramp produces zero" {
  let mat = @types.FeatureMatrix::zeros(1, 15)
  for t in 0..<15 {
    mat.set(0, t, 3.5 * t.to_double())
  }
  let d2 = compute_delta(mat, width=5, order=2).unwrap()
  for t in 4..<=10 {
    assert_true(d2.at(0, t).abs() < 1.0e-12)
  }
}

///|
test "delta: wide windows preserve nearest-edge regression weights" {
  let mat = @types.FeatureMatrix::new([[0.0, 1.0, 2.0]])
  let width = 100001
  let half = (width / 2).to_double()
  let denom = half * (half + 1.0) * (2.0 * half + 1.0) / 3.0
  let center = 3.0 / width.to_double()
  let edge = (half * (half + 1.0) - 1.0) / denom
  let d = compute_delta(mat, width~).unwrap()
  assert_true((d.at(0, 1) / center - 1.0).abs() < 1.0e-12)
  assert_true((d.at(0, 0) / edge - 1.0).abs() < 1.0e-12)
  assert_true((d.at(0, 2) / edge - 1.0).abs() < 1.0e-12)
}

///|
test "delta: nearest-edge padding applies at every derivative order" {
  let mat = @types.FeatureMatrix::new([[0.0, 2.0, 4.0]])
  let first = compute_delta(mat, width=3).unwrap()
  let second = compute_delta(mat, width=3, order=2).unwrap()
  let expected_first = [1.0, 2.0, 1.0]
  let expected_second = [0.5, 0.0, -0.5]
  for t in 0..<3 {
    assert_true((first.at(0, t) - expected_first[t]).abs() < 1.0e-12)
    assert_true((second.at(0, t) - expected_second[t]).abs() < 1.0e-12)
    assert_eq(mat.at(0, t), 2.0 * t.to_double())
  }
}
