///|
/// Helper to clamp frame index to boundary [0, len - 1] (mode='nearest').
fn clamp_index(idx : Int, len : Int) -> Int {
  if idx < 0 {
    0
  } else if idx >= len {
    len - 1
  } else {
    idx
  }
}

///|
/// Compute 1D delta along time frames for a single row.
fn delta_1d(row : Array[Double], width : Int) -> Array[Double] {
  let len = row.length()
  if len == 0 {
    return []
  }
  let n = width / 2
  let mut denom = 0.0
  for i in 1..<=n {
    denom = denom + 2.0 * (i * i).to_double()
  }

  let out : Array[Double] = Array::make(len, 0.0)
  for t in 0..<len {
    let mut sum = 0.0
    for i in 1..<=n {
      let forward_idx = clamp_index(t + i, len)
      let backward_idx = clamp_index(t - i, len)
      sum = sum + i.to_double() * (row[forward_idx] - row[backward_idx])
    }
    out[t] = sum / denom
  }
  out
}

///|
/// Compute temporal Delta or Delta-Delta dynamic coefficients.
/// Matches librosa.feature.delta / HTK polynomial approximation derivative.
pub fn compute_delta(
  matrix : @types.FeatureMatrix,
  width? : Int = 9,
  order? : Int = 1,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  if width < 3 || width % 2 == 0 {
    return Err(DimensionMismatch("Delta width must be an odd integer >= 3"))
  }
  if order <= 0 {
    return Err(DimensionMismatch("Delta order must be positive"))
  }

  let mut current = matrix
  for _ in 0..<order {
    let next = @types.FeatureMatrix::zeros(current.n_rows, current.n_cols)
    for r in 0..<current.n_rows {
      let row = current.get_row(r)
      let d = delta_1d(row, width)
      for c in 0..<current.n_cols {
        next.set(r, c, d[c])
      }
    }
    current = next
  }
  Ok(current)
}
