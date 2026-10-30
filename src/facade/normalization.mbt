///|
/// Offline row-wise CMVN on [feature][frame] matrices; input is preserved.
pub fn cmvn(
  matrix : @types.FeatureMatrix,
  normalize_variance~ : Bool = true,
  variance_floor~ : Double = 1.0e-10,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @normalize.cmvn(matrix, normalize_variance~, variance_floor~)
}
