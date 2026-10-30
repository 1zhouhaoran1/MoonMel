///|
let pi : Double = 3.14159265358979323846264338327950288

///|
/// Convert a linear power feature matrix to decibels (dB), matching librosa power_to_db.
pub fn power_to_db(
  matrix : @types.FeatureMatrix,
  ref_val : Double,
  amin : Double,
  top_db : Double,
) -> @types.FeatureMatrix {
  let rows = matrix.n_rows
  let cols = matrix.n_cols
  let out = @types.FeatureMatrix::zeros(rows, cols)

  let safe_ref = if ref_val > amin { ref_val } else { amin }
  let log_ref = 10.0 * @math.log10(safe_ref)

  let mut max_val = -1.0e30

  for r in 0..<rows {
    for c in 0..<cols {
      let v = matrix.at(r, c)
      let safe_v = if v > amin { v } else { amin }
      let db = 10.0 * @math.log10(safe_v) - log_ref
      out.set(r, c, db)
      if db > max_val {
        max_val = db
      }
    }
  }

  if top_db >= 0.0 {
    let threshold = max_val - top_db
    for r in 0..<rows {
      for c in 0..<cols {
        let v = out.at(r, c)
        if v < threshold {
          out.set(r, c, threshold)
        }
      }
    }
  }

  out
}

///|
/// Compute Log-Mel Spectrogram from PCM samples.
pub fn log_mel_spectrogram(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let mel = match @mel.mel_spectrogram(samples, config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }

  log_mel_from_mel(mel, config)
}

///|
/// Apply the configured log scale to existing Mel features.
pub fn log_mel_from_mel(
  mel : @types.FeatureMatrix,
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  match mel.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let rows = mel.n_rows
  let cols = mel.n_cols

  match config.log_scale {
    Db => {
      let db_mat = power_to_db(
        mel,
        config.ref_value,
        config.amin,
        config.top_db,
      )
      Ok(db_mat)
    }
    NaturalLog => {
      let out = @types.FeatureMatrix::zeros(rows, cols)
      for r in 0..<rows {
        for c in 0..<cols {
          let v = mel.at(r, c)
          let safe_v = if v > config.amin { v } else { config.amin }
          out.set(r, c, @math.ln(safe_v))
        }
      }
      Ok(out)
    }
    Log10 => {
      let out = @types.FeatureMatrix::zeros(rows, cols)
      for r in 0..<rows {
        for c in 0..<cols {
          let v = mel.at(r, c)
          let safe_v = if v > config.amin { v } else { config.amin }
          out.set(r, c, @math.log10(safe_v))
        }
      }
      Ok(out)
    }
  }
}

///|
/// Compute Discrete Cosine Transform Type-II (DCT-II).
pub fn dct_ii(
  input : Array[Double],
  n_out : Int32,
  norm_ortho : Bool,
) -> Array[Double] {
  let n_in = input.length()
  let out : Array[Double] = Array::make(if n_out > 0 { n_out } else { 0 }, 0.0)
  if n_in == 0 || n_out == 0 {
    return out
  }

  let denom = 2.0 * n_in.to_double()
  let w0 = if norm_ortho { (1.0 / n_in.to_double()).sqrt() } else { 2.0 }
  let wk = if norm_ortho { (2.0 / n_in.to_double()).sqrt() } else { 2.0 }

  for k in 0..<n_out {
    let mut sum = 0.0
    for n in 0..<n_in {
      let angle = pi * k.to_double() * (2.0 * n.to_double() + 1.0) / denom
      sum = sum + input[n] * @math.cos(angle)
    }
    let weight = if k == 0 { w0 } else { wk }
    out[k] = sum * weight
  }

  out
}

///|
/// Compute Mel-Frequency Cepstral Coefficients (MFCC).
pub fn mfcc(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let log_mel = match log_mel_spectrogram(samples, config) {
    Ok(lm) => lm
    Err(e) => return Err(e)
  }

  mfcc_from_log_mel(log_mel, config)
}

///|
/// Reuse Log-Mel features; compute the DCT basis once for all time frames.
pub fn mfcc_from_log_mel(
  log_mel : @types.FeatureMatrix,
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  match log_mel.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if log_mel.n_rows == 0 {
    return Err(DimensionMismatch("Log-Mel matrix has no bands"))
  }
  let n_mfcc = config.n_mfcc
  let n_mels = log_mel.n_rows
  let n_frames = log_mel.n_cols
  let basis = @types.FeatureMatrix::zeros(n_mfcc, n_mels)
  for k in 0..<n_mfcc {
    let weight = if config.norm_ortho {
      if k == 0 {
        (1.0 / n_mels.to_double()).sqrt()
      } else {
        (2.0 / n_mels.to_double()).sqrt()
      }
    } else {
      2.0
    }
    for m in 0..<n_mels {
      let angle = pi *
        k.to_double() *
        (2.0 * m.to_double() + 1.0) /
        (2.0 * n_mels.to_double())
      basis.set(k, m, weight * @math.cos(angle))
    }
  }
  let result = @types.FeatureMatrix::zeros(n_mfcc, n_frames)
  for k in 0..<n_mfcc {
    for t in 0..<n_frames {
      let mut sum = 0.0
      for m in 0..<n_mels {
        sum = sum + basis.at(k, m) * log_mel.at(m, t)
      }
      result.set(k, t, sum)
    }
  }
  Ok(result)
}
