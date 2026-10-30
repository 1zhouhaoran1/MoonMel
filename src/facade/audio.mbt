///|
/// Re-export pre-emphasis high-pass filter.
pub fn preemphasis(
  samples : Array[Double],
  alpha~ : Double = 0.97,
) -> Array[Double] {
  @filter.preemphasis(samples, alpha~)
}

///|
/// Re-export de-emphasis inverse filter.
pub fn deemphasis(
  samples : Array[Double],
  alpha~ : Double = 0.97,
) -> Array[Double] {
  @filter.deemphasis(samples, alpha~)
}

///|
/// Re-export WAV decoder.
pub fn decode_wav(
  bytes : Array[Byte],
) -> Result[@types.AudioBuffer, @types.MelError] {
  @wav.decode_wav(bytes)
}

///|
/// Decode integer PCM WAV while preserving channel order and sample rate.
pub fn decode_wav_multichannel(
  bytes : Array[Byte],
) -> Result[@types.MultiChannelAudioBuffer, @types.MelError] {
  @wav.decode_wav_multichannel(bytes)
}

///|
/// Re-export audio resampler (polyphase by default).
pub fn resample(
  samples : Array[Double],
  orig_sr : Int32,
  target_sr : Int32,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample(samples, orig_sr, target_sr)
}

///|
/// Re-export polyphase rational factor audio resampler.
pub fn resample_polyphase(
  samples : Array[Double],
  orig_sr : Int32,
  target_sr : Int32,
  half_len~ : Int32 = 10,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample_polyphase(samples, orig_sr, target_sr, half_len~)
}

///|
/// Re-export windowed-sinc bandlimited audio resampler.
pub fn resample_sinc(
  samples : Array[Double],
  orig_sr : Int32,
  target_sr : Int32,
  filter_size~ : Int32 = 16,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample_sinc(samples, orig_sr, target_sr, filter_size~)
}

///|
/// Re-export linear interpolation audio resampler.
pub fn resample_linear(
  samples : Array[Double],
  orig_sr : Int32,
  target_sr : Int32,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample_linear(samples, orig_sr, target_sr)
}

///|
/// Re-export streaming extractor type alias.
pub type StreamingExtractor = @streaming.StreamingExtractor

///|
pub type StreamingFeatures = @streaming.StreamingFeatures

///|
/// Re-export constructor for StreamingExtractor.
pub fn create_streaming_extractor(
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@streaming.StreamingExtractor, @types.MelError] {
  @streaming.StreamingExtractor::new(config~)
}

///|
/// Re-export multi-channel STFT extraction.
pub fn multichannel_stft(
  buffer : @types.MultiChannelAudioBuffer,
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  @multichannel.multichannel_stft(buffer, config~)
}

///|
/// Re-export multi-channel Mel spectrogram extraction.
pub fn multichannel_mel(
  buffer : @types.MultiChannelAudioBuffer,
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  @multichannel.multichannel_mel(buffer, config~)
}

///|
/// Re-export multi-channel MFCC extraction.
pub fn multichannel_mfcc(
  buffer : @types.MultiChannelAudioBuffer,
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[@types.FeatureMatrix], @types.MelError] {
  @multichannel.multichannel_mfcc(buffer, config~)
}

///|
/// Re-export Inter-channel Level Difference (ILD).
pub fn interchannel_level_difference(
  buffer : @types.MultiChannelAudioBuffer,
  ch1 : Int32,
  ch2 : Int32,
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @multichannel.interchannel_level_difference(buffer, ch1, ch2, config~)
}

///|
/// Re-export Inter-channel Phase Difference (IPD).
pub fn interchannel_phase_difference(
  buffer : @types.MultiChannelAudioBuffer,
  ch1 : Int32,
  ch2 : Int32,
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@types.FeatureMatrix, @types.MelError] {
  @multichannel.interchannel_phase_difference(buffer, ch1, ch2, config~)
}

///|
/// Re-export Biquad filter coefficients.
pub type BiquadCoeffs = @loudness.BiquadCoeffs

///|
/// Re-export Biquad filter state.
pub type BiquadFilter = @loudness.BiquadFilter

///|
/// Re-export ITU-R BS.1770-4 / EBU R128 Loudness result.
pub type LoudnessResult = @loudness.LoudnessResult

///|
/// Re-export K-weighting filtering.
pub fn apply_k_weighting(
  samples : Array[Double],
  sample_rate : Int32,
) -> Array[Double] {
  @loudness.apply_k_weighting(samples, sample_rate)
}

///|
/// Re-export True Peak measurement in dBFS via 4x oversampling.
pub fn true_peak_db(
  samples : Array[Double],
  sample_rate : Int32,
) -> Result[Double, @types.MelError] {
  @loudness.true_peak_db(samples, sample_rate)
}

///|
/// Re-export ITU-R BS.1770-4 Loudness Meter for audio samples.
pub fn loudness_meter(
  samples : Array[Double],
  sample_rate~ : Int32 = 48000,
) -> Result[@loudness.LoudnessResult, @types.MelError] {
  match @types.AudioBuffer::new(samples, sample_rate) {
    Ok(audio) => @loudness.loudness_meter(audio)
    Err(e) => Err(e)
  }
}

///|
/// Re-export windowed-sinc resampling to target length.
pub fn resample_to_length(
  samples : Array[Double],
  target_len : Int32,
  filter_size~ : Int32 = 16,
) -> Result[Array[Double], @types.MelError] {
  @resample.resample_to_length(samples, target_len, filter_size~)
}

///|
/// Re-export Phase Vocoder time stretching on complex STFT frames.
pub fn phase_vocoder(
  frames : Array[Array[@types.Complex]],
  rate : Double,
  hop_length : Int32,
  n_fft : Int32,
) -> Result[Array[Array[@types.Complex]], @types.MelError] {
  @effects.phase_vocoder(frames, rate, hop_length, n_fft)
}

///|
/// Re-export time stretching on audio samples without pitch shift.
pub fn time_stretch(
  samples : Array[Double],
  rate : Double,
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[Double], @types.MelError] {
  @effects.time_stretch(samples, rate, config)
}

///|
/// Re-export pitch shifting on audio samples without tempo change.
pub fn pitch_shift(
  samples : Array[Double],
  sample_rate~ : Int32 = 16000,
  n_steps~ : Double = 0.0,
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[Array[Double], @types.MelError] {
  @effects.pitch_shift(samples, sample_rate, n_steps, config)
}
