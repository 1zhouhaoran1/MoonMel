///|
/// Normalization mode for Chroma feature vectors across time frames.
pub(all) enum ChromaNorm {
  None
  L1
  L2
  Max
} derive(Eq, Debug)

///|
/// Returns standard pitch class name for index 0..=11 (0 = C, 9 = A, etc.).
pub fn pitch_class_name(idx : Int) -> String {
  let note_idx = (idx % 12 + 12) % 12
  match note_idx {
    0 => "C"
    1 => "C#"
    2 => "D"
    3 => "D#"
    4 => "E"
    5 => "F"
    6 => "F#"
    7 => "G"
    8 => "G#"
    9 => "A"
    10 => "A#"
    11 => "B"
    _ => "?"
  }
}

///|
/// Generates a 12-bin Chroma filterbank projecting frequency bins to 12 semitones.
/// Returns a FeatureMatrix of shape [12, n_bins].
pub fn chroma_filterbank(
  sample_rate : Int,
  n_fft : Int,
  tuning : Double,
  f_min : Double,
) -> @types.FeatureMatrix {
  if sample_rate <= 0 ||
    n_fft <= 0 ||
    !@types.is_finite(tuning) ||
    !@types.is_finite(f_min) {
    return @types.FeatureMatrix::zeros(12, 0)
  }
  let n_bins = n_fft / 2 + 1
  let n_chroma = 12
  let filterbank = @types.FeatureMatrix::zeros(n_chroma, n_bins)
  let delta_f = sample_rate.to_double() / n_fft.to_double()
  let ln2 = 0.6931471805599453

  for k in 1..<n_bins {
    let freq = k.to_double() * delta_f
    if freq >= f_min && freq >= 1.0 {
      // Fractional MIDI note: A440 = 69
      let midi = 12.0 * (@math.ln(freq / 440.0) / ln2) + 69.0 - tuning
      let mut pitch_class = midi % 12.0
      if pitch_class < 0.0 {
        pitch_class = pitch_class + 12.0
      }

      // Project onto 12 circular pitch classes using Gaussian octave profiles
      let sigma = 0.5
      let mut col_sum = 0.0
      for c in 0..<12 {
        let mut diff = (pitch_class - c.to_double()).abs()
        if diff > 6.0 {
          diff = 12.0 - diff
        }
        let weight = @math.exp(-0.5 * (diff / sigma) * (diff / sigma))
        filterbank.set(c, k, weight)
        col_sum = col_sum + weight
      }

      // Column-normalize across the 12 chroma bins
      if col_sum > 1.0e-12 {
        let inv_sum = 1.0 / col_sum
        for c in 0..<12 {
          filterbank.set(c, k, filterbank.at(c, k) * inv_sum)
        }
      }
    }
  }

  filterbank
}

///|
/// Extracts 12-bin Chroma representation from a 2D power/magnitude spectrogram.
pub fn chroma_from_spectrogram(
  spectrogram : @types.FeatureMatrix,
  sample_rate : Int,
  n_fft : Int,
  norm : ChromaNorm,
  tuning : Double,
  f_min : Double,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  if sample_rate <= 0 {
    return Err(InvalidSampleRate(sample_rate))
  }
  if n_fft <= 0 {
    return Err(InvalidFftSize(n_fft))
  }
  match spectrogram.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let n_bins = n_fft / 2 + 1
  if spectrogram.n_rows != n_bins {
    return Err(
      DimensionMismatch(
        "Spectrogram frequency bins (\{spectrogram.n_rows}) do not match n_fft/2+1 (\{n_bins})",
      ),
    )
  }
  let n_frames = spectrogram.n_cols
  let n_chroma = 12
  let filterbank = chroma_filterbank(sample_rate, n_fft, tuning, f_min)
  let result = @types.FeatureMatrix::zeros(n_chroma, n_frames)

  // Matrix multiplication: [12, n_bins] x [n_bins, n_frames] -> [12, n_frames]
  for frame_idx in 0..<n_frames {
    for c in 0..<n_chroma {
      let mut sum = 0.0
      for k in 0..<n_bins {
        sum = sum + filterbank.at(c, k) * spectrogram.at(k, frame_idx)
      }
      result.set(c, frame_idx, sum)
    }

    // Frame-level normalization
    match norm {
      None => ()
      Max => {
        let mut max_val = 0.0
        for c in 0..<n_chroma {
          let v = result.at(c, frame_idx)
          if v > max_val {
            max_val = v
          }
        }
        if max_val > 1.0e-12 {
          let inv = 1.0 / max_val
          for c in 0..<n_chroma {
            result.set(c, frame_idx, result.at(c, frame_idx) * inv)
          }
        }
      }
      L1 => {
        let mut sum_val = 0.0
        for c in 0..<n_chroma {
          sum_val = sum_val + result.at(c, frame_idx).abs()
        }
        if sum_val > 1.0e-12 {
          let inv = 1.0 / sum_val
          for c in 0..<n_chroma {
            result.set(c, frame_idx, result.at(c, frame_idx) * inv)
          }
        }
      }
      L2 => {
        let mut sum_sq = 0.0
        for c in 0..<n_chroma {
          let v = result.at(c, frame_idx)
          sum_sq = sum_sq + v * v
        }
        let norm_val = sum_sq.sqrt()
        if norm_val > 1.0e-12 {
          let inv = 1.0 / norm_val
          for c in 0..<n_chroma {
            result.set(c, frame_idx, result.at(c, frame_idx) * inv)
          }
        }
      }
    }
  }

  Ok(result)
}

///|
/// End-to-end 12-bin Chroma STFT feature extraction pipeline.
pub fn chroma_stft(
  samples : Array[Double],
  config : @types.FeatureConfig,
  norm : ChromaNorm,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match @stft.stft_spectrogram(samples, config) {
    Ok(spec) =>
      chroma_from_spectrogram(
        spec,
        config.sample_rate,
        config.n_fft,
        norm,
        0.0,
        config.f_min,
      )
    Err(e) => Err(e)
  }
}

///|
pub extend ChromaNorm with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ChromaNorm with Eq::{not_equal, equal}
