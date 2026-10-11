///|
/// Short-Time Fourier Transform (STFT) returning 2D FeatureMatrix.
pub fn stft_spectrogram(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[@types.FeatureMatrix, @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  let n_fft = config.n_fft
  let hop_length = config.hop_length
  let win_length = config.win_length

  let audio = if config.center {
    let pad_width = n_fft / 2
    @window.pad_reflect(samples, pad_width)
  } else {
    samples.copy()
  }

  let audio_len = audio.length()
  if audio_len < n_fft {
    return Err(
      DimensionMismatch("Audio length after padding is shorter than n_fft"),
    )
  }

  let n_frames = 1 + (audio_len - n_fft) / hop_length
  let n_bins = n_fft / 2 + 1
  let result = @types.FeatureMatrix::zeros(n_bins, n_frames)

  let win = @window.create_window(config.window, win_length)
  let frame_buf : Array[Double] = Array::make(n_fft, 0.0)

  for frame_idx in 0..<n_frames {
    let start = frame_idx * hop_length
    let pad_offset = (n_fft - win_length) / 2
    for i in 0..<n_fft {
      frame_buf[i] = 0.0
    }
    for j in 0..<win_length {
      let s_idx = start + j
      if s_idx < audio_len {
        frame_buf[pad_offset + j] = audio[s_idx] * win[j]
      }
    }

    match @fft.rfft_spectrum(frame_buf, n_fft, config.power) {
      Ok(spec) =>
        for bin_idx in 0..<n_bins {
          result.set(bin_idx, frame_idx, spec[bin_idx])
        }
      Err(e) => return Err(e)
    }
  }

  Ok(result)
}

///|
/// STFT returning full complex frames across time.
pub fn stft_complex(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[Array[Array[@types.Complex]], @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  let n_fft = config.n_fft
  let hop_length = config.hop_length
  let win_length = config.win_length

  let audio = if config.center {
    let pad_width = n_fft / 2
    @window.pad_reflect(samples, pad_width)
  } else {
    samples.copy()
  }

  let audio_len = audio.length()
  if audio_len < n_fft {
    return Err(
      DimensionMismatch("Audio length after padding is shorter than n_fft"),
    )
  }

  let n_frames = 1 + (audio_len - n_fft) / hop_length
  let n_bins = n_fft / 2 + 1
  let frames : Array[Array[@types.Complex]] = Array::make(n_frames, [])

  let win = @window.create_window(config.window, win_length)
  let re : Array[Double] = Array::make(n_fft, 0.0)
  let im : Array[Double] = Array::make(n_fft, 0.0)

  for frame_idx in 0..<n_frames {
    let start = frame_idx * hop_length
    let pad_offset = (n_fft - win_length) / 2
    for i in 0..<n_fft {
      re[i] = 0.0
      im[i] = 0.0
    }
    for j in 0..<win_length {
      let s_idx = start + j
      if s_idx < audio_len {
        re[pad_offset + j] = audio[s_idx] * win[j]
      }
    }

    @fft.fft_in_place(re, im, n_fft, false)
    let f : Array[@types.Complex] = Array::make(n_bins, @types.Complex::{
      re: 0.0,
      im: 0.0,
    })
    for k in 0..<n_bins {
      f[k] = { re: re[k], im: im[k], }
    }
    frames[frame_idx] = f
  }

  Ok(frames)
}

///|
/// Inverse Short-Time Fourier Transform (ISTFT) reconstructing real time-domain audio.
/// Implements Weighted Overlap-Add (WOLA) synthesis with window power normalization.
/// `length`: Target audio length in samples (if <= 0, automatically determined).
pub fn istft(
  frames : Array[Array[@types.Complex]],
  config : @types.FeatureConfig,
  length : Int,
) -> Result[Array[Double], @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let n_frames = frames.length()
  if n_frames == 0 {
    return Err(EmptyAudio)
  }
  let n_fft = config.n_fft
  let hop_length = config.hop_length
  let win_length = config.win_length
  let expected_bins = n_fft / 2 + 1

  for idx in 0..<n_frames {
    if frames[idx].length() != expected_bins {
      return Err(DimensionMismatch("Expected frame with \{expected_bins} bins"))
    }
  }

  let pad_offset = (n_fft - win_length) / 2
  let win = @window.create_window(config.window, win_length)

  let total_len = (n_frames - 1) * hop_length + win_length
  let y_buf : Array[Double] = Array::make(total_len, 0.0)
  let w_sum : Array[Double] = Array::make(total_len, 0.0)

  let re : Array[Double] = Array::make(n_fft, 0.0)
  let im : Array[Double] = Array::make(n_fft, 0.0)

  for frame_idx in 0..<n_frames {
    let start = frame_idx * hop_length
    let f = frames[frame_idx]

    // Hermitian symmetry reconstruction for real-valued inverse FFT
    for k in 0..<expected_bins {
      re[k] = f[k].re
      im[k] = f[k].im
    }
    for k in 1..<(n_fft / 2) {
      re[n_fft - k] = f[k].re
      im[n_fft - k] = -f[k].im
    }

    @fft.fft_in_place(re, im, n_fft, true)

    for j in 0..<win_length {
      let syn = re[pad_offset + j] * win[j]
      let idx = start + j
      y_buf[idx] = y_buf[idx] + syn
      w_sum[idx] = w_sum[idx] + win[j] * win[j]
    }
  }

  // Window normalization
  for t in 0..<total_len {
    if w_sum[t] > 1.0e-8 {
      y_buf[t] = y_buf[t] / w_sum[t]
    }
  }

  // Remove center padding if center was enabled in STFT
  let crop_start = if config.center { n_fft / 2 } else { 0 }
  let target_len = if length > 0 {
    length
  } else if config.center {
    let unpadded = total_len - 2 * (n_fft / 2)
    if unpadded > 0 {
      unpadded
    } else {
      total_len - crop_start
    }
  } else {
    total_len
  }

  let out : Array[Double] = Array::make(target_len, 0.0)
  for i in 0..<target_len {
    let src_idx = crop_start + i
    if src_idx < total_len && src_idx >= 0 {
      out[i] = y_buf[src_idx]
    }
  }

  Ok(out)
}
