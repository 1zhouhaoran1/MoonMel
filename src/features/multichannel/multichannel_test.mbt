///|
/// Unit tests for multi-channel audio features and spatial acoustics.
test "multichannel_audio_buffer_downmix" {
  let ch0 = [1.0, 2.0, 3.0, 4.0]
  let ch1 = [3.0, 4.0, 5.0, 6.0]
  let multi = @types.MultiChannelAudioBuffer::new([ch0, ch1], 16000).unwrap()
  assert_eq(multi.num_channels(), 2)
  assert_eq(multi.length(), 4)

  let mono = multi.to_mono()
  assert_eq(mono.length(), 4)
  assert_eq(mono.samples[0], 2.0)
  assert_eq(mono.samples[1], 3.0)
  assert_eq(mono.samples[2], 4.0)
  assert_eq(mono.samples[3], 5.0)

  let ch_ext = multi.channel(1).unwrap()
  assert_eq(ch_ext.samples[0], 3.0)
}

///|
test "multichannel_stft_and_mel_shape" {
  let sr = 16000
  let n = 2048
  let ch0 = Array::make(n, 0.1)
  let ch1 = Array::make(n, 0.2)
  let multi = @types.MultiChannelAudioBuffer::new([ch0, ch1], sr).unwrap()

  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
    n_mels: 20,
  }

  let stfts = @multichannel.multichannel_stft(multi, config=cfg).unwrap()
  let mels = @multichannel.multichannel_mel(multi, config=cfg).unwrap()
  let mfccs = @multichannel.multichannel_mfcc(multi, config=cfg).unwrap()

  assert_eq(stfts.length(), 2)
  assert_eq(mels.length(), 2)
  assert_eq(mfccs.length(), 2)

  assert_eq(stfts[0].n_rows, 257)
  assert_eq(mels[0].n_rows, 20)
  assert_eq(mfccs[0].n_rows, 13)
}

///|
test "interchannel_level_difference_identical_and_scaled" {
  let n = 2048
  let ch0 = Array::make(n, 1.0)
  let ch1 = Array::make(n, 1.0)
  let ch2 = Array::make(n, 2.0) // 2x amplitude = 4x power

  let multi_ident = @types.MultiChannelAudioBuffer::new([ch0, ch1], 16000).unwrap()
  let ild_ident = @multichannel.interchannel_level_difference(multi_ident, 0, 1).unwrap()

  // For identical channels, ILD should be ~0 dB
  let mid_val = ild_ident.at(0, ild_ident.n_cols / 2)
  assert_true(mid_val.abs() < 1.0e-5)

  let multi_scaled = @types.MultiChannelAudioBuffer::new([ch2, ch0], 16000).unwrap()
  let ild_scaled = @multichannel.interchannel_level_difference(
    multi_scaled, 0, 1,
  ).unwrap()
  // 4x power difference is ~ 6.02 dB at bin 0
  let mid_scaled = ild_scaled.at(0, ild_scaled.n_cols / 2)
  assert_true((mid_scaled - 6.0206).abs() < 0.1)
}

///|
test "interchannel_phase_difference_in_phase" {
  let sr = 16000
  let n = 2048
  let ch0 = Array::make(n, 0.0)
  let ch1 = Array::make(n, 0.0)
  let pi = 3.14159265358979323846

  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    ch0[i] = @math.sin(2.0 * pi * 440.0 * t)
    ch1[i] = @math.sin(2.0 * pi * 440.0 * t) // exact in-phase
  }

  let multi = @types.MultiChannelAudioBuffer::new([ch0, ch1], sr).unwrap()
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
  }

  let ipd = @multichannel.interchannel_phase_difference(multi, 0, 1, config=cfg).unwrap()
  // At the 440 Hz bin, in-phase signals should have phase difference close to 0
  let bin_440 = (440.0 * 512.0 / 16000.0 + 0.5).to_int()
  let mid_ipd = ipd.at(bin_440, ipd.n_cols / 2)
  assert_true(mid_ipd.abs() < 1.0e-4)
}
