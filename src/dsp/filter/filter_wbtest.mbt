///|
test "preemphasis: identity when alpha is zero" {
  let sig = [1.0, 2.0, 3.0, 4.0, 5.0]
  let filtered = preemphasis(sig, alpha=0.0)
  for i in 0..<sig.length() {
    assert_eq(filtered[i], sig[i])
  }
}

///|
test "preemphasis: first order difference calculation" {
  let sig = [1.0, 2.0, 3.0, 4.0]
  let filtered = preemphasis(sig, alpha=0.5)
  assert_eq(filtered[0], 1.0)
  assert_eq(filtered[1], 2.0 - 0.5 * 1.0) // 1.5
  assert_eq(filtered[2], 3.0 - 0.5 * 2.0) // 2.0
  assert_eq(filtered[3], 4.0 - 0.5 * 3.0) // 2.5
}

///|
test "preemphasis: in-place matches out-of-place" {
  let sig1 = [0.5, -0.2, 0.8, -0.9, 0.3, 0.1]
  let sig2 = sig1.copy()
  let filtered = preemphasis(sig1, alpha=0.97)
  preemphasis_inplace(sig2, 0.97)
  for i in 0..<sig1.length() {
    let diff = (filtered[i] - sig2[i]).abs()
    assert_true(diff < 1.0e-12)
  }
}

///|
test "preemphasis and deemphasis: exact roundtrip reconstruction" {
  let sig = [0.12, -0.45, 0.89, -0.34, 0.67, -0.11, 0.95]
  let filtered = preemphasis(sig, alpha=0.95)
  let reconstructed = deemphasis(filtered, alpha=0.95)
  for i in 0..<sig.length() {
    let err = (reconstructed[i] - sig[i]).abs()
    assert_true(err < 1.0e-12)
  }
}
