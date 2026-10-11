///| Real-time streaming audio feature extractor.
/// Reuses FFT buffers and a filterbank; returned matrices and arbitrary-size transforms allocate.
/// Streaming uses left-aligned complete frames, independent of config.center.

///|
pub(all) struct StreamingExtractor {
  config : @types.FeatureConfig
  window : Array[Double]
  filterbank : @types.FeatureMatrix
  mut buffer : Array[Double]
  mut buffer_start : Int
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
    buffer_start: 0,
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
  for sample in chunk {
    self.buffer.push(sample)
  }
}

///|
/// Returns the number of ready full frames available for extraction.
pub fn StreamingExtractor::available_frames(self : StreamingExtractor) -> Int {
  let n_fft = self.config.n_fft
  let hop = self.config.hop_length
  let len = self.buffer.length() - self.buffer_start
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
    let offset = self.buffer_start + frame * hop

    @framing.window_frame(self.buffer, offset, self.window, self.fft_re)
    self.fft_im.fill(0.0)
    match @fft.transform_in_place(self.fft_re, self.fft_im, n_fft, false) {
      Ok(_) => ()
      Err(_) => abort("Validated streaming FFT buffers are inconsistent")
    }
    for i in 0..<n_bins {
      let p2 = self.fft_re[i] * self.fft_re[i] + self.fft_im[i] * self.fft_im[i]
      self.spec_buffer[i] = if self.config.power == 2.0 {
        p2
      } else if self.config.power == 1.0 {
        p2.sqrt()
      } else {
        @math.pow(p2, self.config.power / 2.0)
      }
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

  // The cursor can pass the current buffer for hop > n_fft. Preserve that
  // gap so the next arriving chunks resume on the original sample timeline.
  self.buffer_start = self.buffer_start + n_frames * hop
  if self.buffer_start >= self.buffer.length() {
    self.buffer_start = self.buffer_start - self.buffer.length()
    self.buffer = []
  } else if self.buffer_start >= self.buffer.length() / 2 {
    let remaining = self.buffer.length() - self.buffer_start
    let compacted = Array::make(remaining, 0.0)
    for i in 0..<remaining {
      compacted[i] = self.buffer[self.buffer_start + i]
    }
    self.buffer = compacted
    self.buffer_start = 0
  }

  out
}

///|
/// Process and consume ready frames, returning an MFCC matrix [n_mfcc][n_frames].
pub fn StreamingExtractor::pop_mfcc_frames(
  self : StreamingExtractor,
) -> @types.FeatureMatrix {
  let mel_mat = self.pop_mel_frames()
  let log_mel = match @mfcc.log_mel_from_mel(mel_mat, self.config) {
    Ok(value) => value
    Err(_) => abort("Validated streaming Mel matrix is inconsistent")
  }
  match @mfcc.mfcc_from_log_mel(log_mel, self.config) {
    Ok(value) => value
    Err(_) => abort("Validated streaming Log-Mel matrix is inconsistent")
  }
}

///|
/// Clear remaining samples in buffer.
pub fn StreamingExtractor::reset(self : StreamingExtractor) -> Unit {
  self.buffer = []
  self.buffer_start = 0
}
