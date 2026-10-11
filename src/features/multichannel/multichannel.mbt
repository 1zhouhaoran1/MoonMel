///| Multi-channel audio feature extraction and spatial acoustics (ILD & IPD).

///|
/// Extract STFT power spectrograms for all channels in buffer.
pub fn multichannel_stft(
  buffer : @types.MultiChannelAudioBuffer,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  let n_ch = buffer.num_channels()
  let out : Array[@types.FeatureMatrix] = []
  for i in 0..<n_ch {
    let ch_samples = buffer.channels[i]
    let stft_mat = match @stft.stft_spectrogram(ch_samples, config) {
      Ok(m) => m
      Err(e) => return Err(e)
    }
    out.push(stft_mat)
  }
  Ok(out)
}

///|
/// Extract Mel spectrograms for all channels in buffer.
pub fn multichannel_mel(
  buffer : @types.MultiChannelAudioBuffer,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  let n_ch = buffer.num_channels()
  let out : Array[@types.FeatureMatrix] = []
  for i in 0..<n_ch {
    let ch_samples = buffer.channels[i]
    let mel_mat = match @mel.mel_spectrogram(ch_samples, config) {
      Ok(m) => m
      Err(e) => return Err(e)
    }
    out.push(mel_mat)
  }
  Ok(out)
}

///|
/// Extract MFCC coefficients for all channels in buffer.
pub fn multichannel_mfcc(
  buffer : @types.MultiChannelAudioBuffer,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  let n_ch = buffer.num_channels()
  let out : Array[@types.FeatureMatrix] = []
  for i in 0..<n_ch {
    let ch_samples = buffer.channels[i]
    let mfcc_mat = match @mfcc.mfcc(ch_samples, config) {
      Ok(m) => m
      Err(e) => return Err(e)
    }
    out.push(mfcc_mat)
  }
  Ok(out)
}

///|
/// Inter-channel Level Difference (ILD) between two channels in decibels (dB).
/// ILD[k, t] = 10 * log10((P_ch1[k, t] + eps) / (P_ch2[k, t] + eps)).
pub fn interchannel_level_difference(
  buffer : @types.MultiChannelAudioBuffer,
  ch1 : Int,
  ch2 : Int,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let n_ch = buffer.num_channels()
  if ch1 < 0 || ch1 >= n_ch || ch2 < 0 || ch2 >= n_ch {
    return Err(
      @types.MelError::DimensionMismatch(
        "Invalid channel indices: \{ch1}, \{ch2}",
      ),
    )
  }

  let stft1 = match @stft.stft_spectrogram(buffer.channels[ch1], config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  let stft2 = match @stft.stft_spectrogram(buffer.channels[ch2], config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }

  let rows = stft1.n_rows
  let cols = stft1.n_cols
  let out = @types.FeatureMatrix::zeros(rows, cols)
  let eps = 1.0e-10

  for r in 0..<rows {
    for c in 0..<cols {
      let p1 = stft1.at(r, c) + eps
      let p2 = stft2.at(r, c) + eps
      let ild = 10.0 * @math.log10(p1 / p2)
      out.set(r, c, ild)
    }
  }

  Ok(out)
}

///|
/// Inter-channel Phase Difference (IPD) between two channels in radians [-PI, PI].
/// Computed from the angle of the complex cross-spectrum S_ch1 * conj(S_ch2).
pub fn interchannel_phase_difference(
  buffer : @types.MultiChannelAudioBuffer,
  ch1 : Int,
  ch2 : Int,
  config? : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  let n_ch = buffer.num_channels()
  if ch1 < 0 || ch1 >= n_ch || ch2 < 0 || ch2 >= n_ch {
    return Err(
      @types.MelError::DimensionMismatch(
        "Invalid channel indices: \{ch1}, \{ch2}",
      ),
    )
  }

  let c1 = match @stft.stft_complex(buffer.channels[ch1], config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  let c2 = match @stft.stft_complex(buffer.channels[ch2], config) {
    Ok(m) => m
    Err(e) => return Err(e)
  }

  let n_frames = c1.length()
  if n_frames == 0 || c1[0].length() == 0 {
    return Ok(@types.FeatureMatrix::zeros(0, 0))
  }
  let n_bins = c1[0].length()
  let out = @types.FeatureMatrix::zeros(n_bins, n_frames)

  for f in 0..<n_frames {
    for k in 0..<n_bins {
      let comp1 = c1[f][k]
      let comp2 = c2[f][k]
      // Cross-spectrum: comp1 * conj(comp2)
      // (r1 + j*i1) * (r2 - j*i2) = (r1*r2 + i1*i2) + j*(i1*r2 - r1*i2)
      let cross_re = comp1.re * comp2.re + comp1.im * comp2.im
      let cross_im = comp1.im * comp2.re - comp1.re * comp2.im
      let power1 = comp1.re * comp1.re + comp1.im * comp1.im
      let power2 = comp2.re * comp2.re + comp2.im * comp2.im
      let ipd = if power1 < 1.0e-12 || power2 < 1.0e-12 {
        0.0
      } else {
        @math.atan2(cross_im, cross_re)
      }
      out.set(k, f, ipd)
    }
  }

  Ok(out)
}
