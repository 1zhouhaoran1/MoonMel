///|
test "ild uses power even when visualization requests magnitude" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 8,
    win_length: 8,
    hop_length: 4,
    center: false,
    window: Rectangular,
    power: 1.0,
  }
  let audio = @types.MultiChannelAudioBuffer::new(
    [Array::make(8, 2.0), Array::make(8, 1.0)],
    16000,
  ).unwrap()
  let result = @multichannel.interchannel_level_difference(
    audio,
    0,
    1,
    config=cfg,
  ).unwrap()
  assert_true((result.at(0, 0) - 6.020599913279624).abs() < 1.0e-8)
}

///|
test "multichannel rejects mismatched rates and malformed public channels" {
  let audio = @types.MultiChannelAudioBuffer::new(
    [Array::make(1024, 0.1)],
    48000,
  ).unwrap()
  assert_true(@multichannel.multichannel_mel(audio) is Err(_))
  let malformed : @types.MultiChannelAudioBuffer = {
    channels: [Array::make(1024, 0.1), Array::make(512, 0.1)],
    sample_rate: 16000,
  }
  assert_true(
    @multichannel.interchannel_phase_difference(malformed, 0, 1) is Err(_),
  )
}
