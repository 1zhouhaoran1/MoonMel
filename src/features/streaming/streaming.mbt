///| Real-time streaming audio feature extractor.
/// Implements rolling sample buffer and precomputed filterbanks for zero-allocation streaming inference.

///|
pub(all) struct StreamingExtractor {
  config : @types.FeatureConfig
  window : Array[Double]
  filterbank : @types.FeatureMatrix
  mut buffer : Array[Double]
  fft_re : Array[Double]
  fft_im : Array[Double]
  spec_buffer : Array[Double]
}

///|
/// Create a new streaming extractor with precomputed window and filterbank.
pub fn StreamingExtractor::new(
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[StreamingExtractor, @types.MelError] {
  match config.validate() {
    Ok(_) => ()
    Err(e) => return Err(e)
  }

  let n_fft = config.n_fft
  let n_bins = n_fft / 2 + 1
  let win = @window.create_window(config.window, config.win_length)
  let fb = match @mel.mel_filterbank(config) {
    Ok(f) => f
    Err(e) => return Err(e)
  }

  Ok({
    config,
    window: win,
    filterbank: fb,
    buffer: [],
    fft_re: Array::make(n_fft, 0.0),
    fft_im: Array::make(n_fft, 0.0),
    spec_buffer: Array::make(n_bins, 0.0),
  })
}

///|
/// Push newly arrived audio samples to the streaming buffer.
pub fn StreamingExtractor::push_samples(
  self : StreamingExtractor,
  chunk : Array[Double],
) -> Unit {
  let old_len = self.buffer.length()
  let add_len = chunk.length()
  let new_buf = Array::make(old_len + add_len, 0.0)
  for i in 0..<old_len {
    new_buf[i] = self.buffer[i]
  }
  for i in 0..<add_len {
    new_buf[old_len + i] = chunk[i]
  }
  self.buffer = new_buf
}

///|
/// Returns the number of ready full frames available for extraction.
pub fn StreamingExtractor::available_frames(self : StreamingExtractor) -> Int {
  let n_fft = self.config.n_fft
  let hop = self.config.hop_length
  let len = self.buffer.length()
  if len < n_fft {
    0
  } else {
    (len - n_fft) / hop + 1
  }
}

///|
/// Process and consume ready frames, returning a Mel Spectrogram matrix [n_mels][n_frames].
pub fn StreamingExtractor::pop_mel_frames(
  self : StreamingExtractor,
) -> @types.FeatureMatrix {
  let n_frames = self.available_frames()
  let n_mels = self.config.n_mels
  if n_frames == 0 {
    return @types.FeatureMatrix::zeros(n_mels, 0)
  }

  let n_fft = self.config.n_fft
  let hop = self.config.hop_length
  let n_bins = n_fft / 2 + 1
  let out = @types.FeatureMatrix::zeros(n_mels, n_frames)

  for frame = 0; frame < n_frames; frame = frame + 1 {
    let offset = frame * hop

    // Apply window to frame
    for i in 0..<n_fft {
      self.fft_re[i] = self.buffer[offset + i] * self.window[i]
      self.fft_im[i] = 0.0
    }

    // In-place FFT
    @fft.fft_in_place(self.fft_re, self.fft_im, n_fft, false)

    // Compute power spectrum
    for i in 0..<n_bins {
      let r = self.fft_re[i]
      let im = self.fft_im[i]
      self.spec_buffer[i] = r * r + im * im
    }

    // Dot product with Mel filterbank
    for m in 0..<n_mels {
      let mut mel_energy = 0.0
      for k in 0..<n_bins {
        let weight = self.filterbank.at(m, k)
        if weight > 0.0 {
          mel_energy = mel_energy + weight * self.spec_buffer[k]
        }
      }
      out.set(m, frame, mel_energy)
    }
  }

  // Advance sliding buffer by consumed samples
  let consumed = n_frames * hop
  let remaining = self.buffer.length() - consumed
  let new_buf = Array::make(remaining, 0.0)
  for i in 0..<remaining {
    new_buf[i] = self.buffer[consumed + i]
  }
  self.buffer = new_buf

  out
}

///|
/// Process and consume ready frames, returning an MFCC matrix [n_mfcc][n_frames].
pub fn StreamingExtractor::pop_mfcc_frames(
  self : StreamingExtractor,
) -> @types.FeatureMatrix {
  let mel_mat = self.pop_mel_frames()
  let n_frames = mel_mat.n_cols
  let n_mels = mel_mat.n_rows
  let n_mfcc = self.config.n_mfcc
  if n_frames == 0 {
    return @types.FeatureMatrix::zeros(n_mfcc, 0)
  }

  let log_mel = @types.FeatureMatrix::zeros(n_mels, n_frames)
  let amin = 1.0e-10

  for r in 0..<n_mels {
    for c in 0..<n_frames {
      let v = mel_mat.at(r, c)
      let safe_v = if v > amin { v } else { amin }
      log_mel.set(r, c, 10.0 * @math.log10(safe_v))
    }
  }

  let out = @types.FeatureMatrix::zeros(n_mfcc, n_frames)
  let col_buf = Array::make(n_mels, 0.0)

  for c in 0..<n_frames {
    for r in 0..<n_mels {
      col_buf[r] = log_mel.at(r, c)
    }
    let cepstra = @mfcc.dct_ii(col_buf, n_mfcc, true)
    for k in 0..<n_mfcc {
      out.set(k, c, cepstra[k])
    }
  }

  out
}

///|
/// Clear remaining samples in buffer.
pub fn StreamingExtractor::reset(self : StreamingExtractor) -> Unit {
  self.buffer = []
}
