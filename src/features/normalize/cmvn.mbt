///|
/// Utterance-level mean and optional population-variance normalization per row.
/// Input layout is [feature][frame]. The variance floor is in squared input units.
/// This is offline CMVN, not a sliding-window or speaker-statistics estimator.
pub fn cmvn(
  matrix : @types.FeatureMatrix,
  normalize_variance~ : Bool = true,
  variance_floor~ : Double = 1.0e-10,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match matrix.validate() {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  if !@types.is_finite(variance_floor) || variance_floor <= 0.0 {
    return Err(
      DimensionMismatch("CMVN variance floor must be finite and positive"),
    )
  }
  let output = @types.FeatureMatrix::zeros(matrix.n_rows, matrix.n_cols)
  if matrix.n_cols == 0 {
    return Ok(output)
  }
  let floor_sd = variance_floor.sqrt()
  for row in 0..<matrix.n_rows {
    // Scale before accumulating moments to avoid overflow on large finite input.
    let mut scale = 0.0
    for value in matrix.data[row] {
      if !@types.is_finite(value) {
        return Err(DimensionMismatch("CMVN input contains non-finite features"))
      }
      if value.abs() > scale {
        scale = value.abs()
      }
    }
    if scale == 0.0 {
      continue
    }
    let origin = matrix.at(row, 0)
    let mut mean = 0.0
    let mut sum_squares = 0.0
    for col in 0..<matrix.n_cols {
      // Subtract a reference first to retain small differences on a large DC
      // offset. If that subtraction overflows, divide the operands first.
      let difference = matrix.at(row, col) - origin
      let value = if @types.is_finite(difference) {
        difference / scale
      } else {
        matrix.at(row, col) / scale - origin / scale
      }
      output.set(row, col, value)
      let delta = value - mean
      mean = mean + delta / (col + 1).to_double()
      sum_squares = sum_squares + delta * (value - mean)
    }
    let variance = sum_squares / matrix.n_cols.to_double()
    let sd = if variance > 0.0 { variance.sqrt() } else { 0.0 }
    for col in 0..<matrix.n_cols {
      let centered = output.at(row, col) - mean
      let value = if !normalize_variance {
        centered * scale
      } else if scale * sd >= floor_sd {
        centered / sd
      } else {
        centered * scale / floor_sd
      }
      if !@types.is_finite(value) {
        return Err(
          DimensionMismatch("CMVN centered value exceeds finite range"),
        )
      }
      output.set(row, col, value)
    }
  }
  Ok(output)
}
