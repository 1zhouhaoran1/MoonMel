///|
test "autocorrelation_impulse" {
  let sig = [1.0, 0.0, 0.0, 0.0]
  let r = autocorrelation(sig, 3)
  assert_eq(r.length(), 4)
  assert_eq(r[0], 0.25)
  assert_eq(r[1], 0.0)
  assert_eq(r[2], 0.0)
  assert_eq(r[3], 0.0)
}

///|
test "levinson_durbin_ar1_recovery" {
  // Pure AR(1) process with a = 0.7: x[n] = 0.7 * x[n-1]
  // R[0] = 1.0, R[1] = 0.7, R[2] = 0.49
  let r = [1.0, 0.7, 0.49]
  let res = levinson_durbin(r, 1).unwrap()
  assert_eq(res.coeffs.length(), 1)
  assert_true((res.coeffs[0] - 0.7).abs() < 1.0e-5)
  // Residual error = 1 - 0.7^2 = 0.51
  assert_true((res.prediction_error - 0.51).abs() < 1.0e-5)
}

///|
test "lpc_residual_energy_reduction" {
  // Generate strongly correlated AR(1) signal
  let n = 200
  let sig : Array[Double] = Array::make(n, 0.0)
  sig[0] = 1.0
  for i in 1..<n {
    sig[i] = 0.85 * sig[i - 1]
  }

  let lpc_res = lpc(sig, 2).unwrap()
  assert_eq(lpc_res.coeffs.length(), 2)
  assert_true((lpc_res.coeffs[0] - 0.85).abs() < 0.1)

  let residual = lpc_residual(sig, lpc_res.coeffs)
  let mut orig_energy = 0.0
  let mut res_energy = 0.0
  for i in 2..<n {
    orig_energy = orig_energy + sig[i] * sig[i]
    res_energy = res_energy + residual[i] * residual[i]
  }
  // Residual energy should be dramatically smaller than original energy
  assert_true(res_energy < orig_energy * 0.05)
}

///|
test "lpc_and_lpcc_feature_matrices" {
  let sig = Array::make(1024, 0.5)
  let order = 8
  let n_lpcc = 12
  let lpc_mat = lpc_features(sig, order, 256, 128).unwrap()
  assert_eq(lpc_mat.n_rows, 8)
  assert_true(lpc_mat.n_cols > 0)

  let lpcc_mat = lpcc_features(sig, order, n_lpcc, 256, 128).unwrap()
  assert_eq(lpcc_mat.n_rows, 12)
  assert_eq(lpcc_mat.n_cols, lpc_mat.n_cols)
}
