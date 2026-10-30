///|
/// AudioBuffer stores single-channel 64-bit float PCM audio samples and metadata.
pub(all) struct AudioBuffer {
  samples : Array[Double]
  sample_rate : Int32
} derive(Debug)

///|
/// Create an AudioBuffer with validation.
pub fn AudioBuffer::new(
  samples : Array[Double],
  sample_rate : Int32,
) -> Result[AudioBuffer, MelError] {
  if samples.is_empty() {
    return Err(EmptyAudio)
  }
  if sample_rate <= 0 {
    return Err(InvalidSampleRate(sample_rate))
  }
  match validate_samples(samples) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  Ok({ samples, sample_rate, })
}

///|
/// Number of samples in buffer.
pub fn AudioBuffer::length(self : AudioBuffer) -> Int32 {
  self.samples.length()
}

///|
/// Duration in seconds.
pub fn AudioBuffer::duration(self : AudioBuffer) -> Double {
  self.samples.length().to_double() / self.sample_rate.to_double()
}

///|
/// MultiChannelAudioBuffer stores multi-channel 64-bit float PCM audio samples.
pub(all) struct MultiChannelAudioBuffer {
  channels : Array[Array[Double]]
  sample_rate : Int32
} derive(Debug)

///|
/// Create a MultiChannelAudioBuffer with validation.
pub fn MultiChannelAudioBuffer::new(
  channels : Array[Array[Double]],
  sample_rate : Int32,
) -> Result[MultiChannelAudioBuffer, MelError] {
  if channels.is_empty() {
    return Err(EmptyAudio)
  }
  let n_ch = channels.length()
  let len = channels[0].length()
  if len == 0 {
    return Err(EmptyAudio)
  }
  for i in 1..<n_ch {
    if channels[i].length() != len {
      return Err(DimensionMismatch("Channels have differing sample lengths"))
    }
  }
  for samples in channels {
    match validate_samples(samples) {
      Ok(_) => ()
      Err(e) => return Err(e)
    }
  }
  if sample_rate <= 0 {
    return Err(InvalidSampleRate(sample_rate))
  }
  Ok({ channels, sample_rate, })
}

///|
/// Number of channels.
pub fn MultiChannelAudioBuffer::num_channels(
  self : MultiChannelAudioBuffer,
) -> Int32 {
  self.channels.length()
}

///|
/// Number of samples per channel.
pub fn MultiChannelAudioBuffer::length(self : MultiChannelAudioBuffer) -> Int32 {
  if self.channels.is_empty() {
    0
  } else {
    self.channels[0].length()
  }
}

///|
/// Duration in seconds.
pub fn MultiChannelAudioBuffer::duration(
  self : MultiChannelAudioBuffer,
) -> Double {
  self.length().to_double() / self.sample_rate.to_double()
}

///|
/// Downmix all channels to mono single-channel AudioBuffer.
pub fn MultiChannelAudioBuffer::to_mono(
  self : MultiChannelAudioBuffer,
) -> AudioBuffer {
  let len = self.length()
  let n_ch = self.channels.length()
  let mono = Array::make(len, 0.0)
  let scale = 1.0 / n_ch.to_double()
  for i in 0..<len {
    let mut sum = 0.0
    for ch in 0..<n_ch {
      sum = sum + self.channels[ch][i]
    }
    mono[i] = sum * scale
  }
  { samples: mono, sample_rate: self.sample_rate, }
}

///|
/// Extract a specific channel as a single-channel AudioBuffer.
pub fn MultiChannelAudioBuffer::channel(
  self : MultiChannelAudioBuffer,
  ch_idx : Int32,
) -> Result[AudioBuffer, MelError] {
  if ch_idx < 0 || ch_idx >= self.channels.length() {
    return Err(DimensionMismatch("Channel index out of bounds: \{ch_idx}"))
  }
  let ch_samples = self.channels[ch_idx].copy()
  Ok({ samples: ch_samples, sample_rate: self.sample_rate, })
}

///|
pub extend AudioBuffer with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend MultiChannelAudioBuffer with @moonbitlang/core/debug.Debug::{to_repr}
