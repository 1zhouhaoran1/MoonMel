///|
/// FeatureMatrix stores 2D feature matrices [n_rows][n_cols].
/// Usually n_rows = feature dimension (n_mels or n_mfcc or n_freq_bins),
/// and n_cols = number of time frames.
pub(all) struct FeatureMatrix {
  data : Array[Array[Double]]
  n_rows : Int32
  n_cols : Int32
} derive(Debug)

///|
/// Create a new FeatureMatrix.
pub fn FeatureMatrix::new(data : Array[Array[Double]]) -> FeatureMatrix {
  let rows = data.length()
  let cols = if rows > 0 { data[0].length() } else { 0 }
  { data, n_rows: rows, n_cols: cols, }
}

///|
/// Create an empty FeatureMatrix with given dimensions initialized to 0.0.
pub fn FeatureMatrix::zeros(n_rows : Int32, n_cols : Int32) -> FeatureMatrix {
  let data : Array[Array[Double]] = Array::make(n_rows, [])
  for r in 0..<n_rows {
    data[r] = Array::make(n_cols, 0.0)
  }
  { data, n_rows, n_cols, }
}

///|
/// Get value at (row, col).
pub fn FeatureMatrix::at(
  self : FeatureMatrix,
  row : Int32,
  col : Int32,
) -> Double {
  self.data[row][col]
}

///|
/// Set value at (row, col).
pub fn FeatureMatrix::set(
  self : FeatureMatrix,
  row : Int32,
  col : Int32,
  val : Double,
) -> Unit {
  self.data[row][col] = val
}

///|
/// Get a row (e.g. one frequency or cepstral channel over all time frames).
pub fn FeatureMatrix::get_row(
  self : FeatureMatrix,
  row : Int32,
) -> Array[Double] {
  self.data[row]
}

///|
/// Get a column / time frame (all feature channels at time t).
pub fn FeatureMatrix::get_col(
  self : FeatureMatrix,
  col : Int32,
) -> Array[Double] {
  let frame : Array[Double] = Array::make(self.n_rows, 0.0)
  for r in 0..<self.n_rows {
    frame[r] = self.data[r][col]
  }
  frame
}

///|
/// Transpose matrix to [n_cols][n_rows].
pub fn FeatureMatrix::transpose(self : FeatureMatrix) -> FeatureMatrix {
  let res = FeatureMatrix::zeros(self.n_cols, self.n_rows)
  for r in 0..<self.n_rows {
    for c in 0..<self.n_cols {
      res.set(c, r, self.at(r, c))
    }
  }
  res
}

///|
/// Flatten to 1D row-major array.
pub fn FeatureMatrix::flatten(self : FeatureMatrix) -> Array[Double] {
  let total = self.n_rows * self.n_cols
  let flat : Array[Double] = Array::make(total, 0.0)
  let mut idx = 0
  for r in 0..<self.n_rows {
    for c in 0..<self.n_cols {
      flat[idx] = self.data[r][c]
      idx = idx + 1
    }
  }
  flat
}

///|
pub extend FeatureMatrix with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Check mutable, publicly constructible matrix data at a package boundary.
pub fn FeatureMatrix::validate(self : FeatureMatrix) -> Result[Unit, MelError] {
  if self.n_rows < 0 || self.n_cols < 0 || self.data.length() != self.n_rows {
    return Err(DimensionMismatch("Invalid matrix dimensions"))
  }
  for row in self.data {
    if row.length() != self.n_cols {
      return Err(DimensionMismatch("Ragged matrix"))
    }
  }
  Ok(())
}

///|
/// Join consecutive [feature][frame] batches, copying data into independent rows.
/// Empty input yields 0×0; zero-column batches retain and must match feature count.
pub fn FeatureMatrix::concat_frames(
  batches : Array[FeatureMatrix],
) -> Result[FeatureMatrix, MelError] {
  if batches.is_empty() {
    return Ok(FeatureMatrix::zeros(0, 0))
  }
  let rows = batches[0].n_rows
  let mut columns = 0
  for batch in batches {
    match batch.validate() {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    if batch.n_rows != rows {
      return Err(
        DimensionMismatch("Feature counts differ between frame batches"),
      )
    }
    if batch.n_cols > 2147483647 - columns {
      return Err(
        DimensionMismatch("Concatenated frame count exceeds Int32 range"),
      )
    }
    columns = columns + batch.n_cols
  }
  let output = FeatureMatrix::zeros(rows, columns)
  let mut offset = 0
  for batch in batches {
    for row in 0..<rows {
      for col in 0..<batch.n_cols {
        output.set(row, offset + col, batch.at(row, col))
      }
    }
    offset = offset + batch.n_cols
  }
  Ok(output)
}
