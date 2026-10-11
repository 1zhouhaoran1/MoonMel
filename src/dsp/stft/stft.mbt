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
