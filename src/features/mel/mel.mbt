///|
/// Slaney Mel conversion constants
let slaney_f_sp : Double = 200.0 / 3.0

///|
let slaney_min_log_hz : Double = 1000.0

///|
let slaney_min_log_mel : Double = 15.0

///|
/// Convert frequency in Hertz to Mel scale.
pub fn hz_to_mel(freq : Double, scale : @types.MelScale) -> Double {
  match scale {
    Slaney => {
      let logstep = @math.ln(6.4) / 27.0
      if freq >= slaney_min_log_hz {
        slaney_min_log_mel + @math.ln(freq / slaney_min_log_hz) / logstep
      } else {
        freq / slaney_f_sp
      }
    }
    Htk => 2595.0 * @math.log10(1.0 + freq / 700.0)
  }
}

///|
/// Convert Mel scale value back to frequency in Hertz.
pub fn mel_to_hz(mel : Double, scale : @types.MelScale) -> Double {
  match scale {
    Slaney => {
      let logstep = @math.ln(6.4) / 27.0
      if mel >= slaney_min_log_mel {
        slaney_min_log_hz * @math.exp(logstep * (mel - slaney_min_log_mel))
      } else {
        slaney_f_sp * mel
      }
    }
    Htk => 700.0 * (@math.pow(10.0, mel / 2595.0) - 1.0)
  }
}

///|
/// Construct Mel Filterbank matrix of shape [n_mels][n_fft / 2 + 1].
pub fn mel_filterbank(
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }

  let n_mels = config.n_mels
  let n_fft = config.n_fft
  let n_bins = n_fft / 2 + 1
  let sr = config.sample_rate.to_double()

  let mel_min = hz_to_mel(config.f_min, config.mel_scale)
  let mel_max = hz_to_mel(config.f_max, config.mel_scale)
  let mel_step = (mel_max - mel_min) / (n_mels + 1).to_double()

  let f_pts : Array[Double] = Array::make(n_mels + 2, 0.0)
  for i in 0..<(n_mels + 2) {
    let m = mel_min + i.to_double() * mel_step
    f_pts[i] = mel_to_hz(m, config.mel_scale)
  }

  let fft_freqs : Array[Double] = Array::make(n_bins, 0.0)
  for k in 0..<n_bins {
    fft_freqs[k] = k.to_double() * sr / n_fft.to_double()
  }

  let fb = @types.FeatureMatrix::zeros(n_mels, n_bins)

  for i in 0..<n_mels {
    let f_left = f_pts[i]
    let f_center = f_pts[i + 1]
    let f_right = f_pts[i + 2]

    let enorm = match config.mel_norm {
      Slaney => 2.0 / (f_right - f_left)
      None => 1.0
    }

    for k in 0..<n_bins {
      let f = fft_freqs[k]
      let mut weight = 0.0
      if f >= f_left && f <= f_center && f_center > f_left {
        weight = (f - f_left) / (f_center - f_left)
      } else if f >= f_center && f <= f_right && f_right > f_center {
        weight = (f_right - f) / (f_right - f_center)
      }
      fb.set(i, k, weight * enorm)
    }
  }

  Ok(fb)
}

///|
/// Compute Mel Spectrogram from audio PCM samples.
pub fn mel_spectrogram(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let spec = match @stft.stft_spectrogram(samples, config) {
    Ok(s) => s
    Err(e) => return Err(e)
  }
  let fb = match mel_filterbank(config) {
    Ok(f) => f
    Err(e) => return Err(e)
  }

  let n_mels = config.n_mels
  let n_frames = spec.n_cols
  let n_bins = spec.n_rows

  let mel_spec = @types.FeatureMatrix::zeros(n_mels, n_frames)

  for m in 0..<n_mels {
    for t in 0..<n_frames {
      let mut sum = 0.0
      for k in 0..<n_bins {
        sum = sum + fb.at(m, k) * spec.at(k, t)
      }
      mel_spec.set(m, t, sum)
    }
  }

  Ok(mel_spec)
}
