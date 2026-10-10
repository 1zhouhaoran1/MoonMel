///|
/// Unit tests for StreamingExtractor.
test "streaming_incremental_chunks" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 512,
    hop_length: 128,
    win_length: 512,
    n_mels: 20,
    n_mfcc: 13,
  }
  let extractor = @streaming.StreamingExtractor::new(config=cfg).unwrap()

  // Initially 0 frames
  assert_eq(extractor.available_frames(), 0)

  // Push 256 samples (less than n_fft 512) -> 0 frames
  extractor.push_samples(Array::make(256, 0.1))
  assert_eq(extractor.available_frames(), 0)

  // Push another 256 samples (total 512) -> 1 frame
  extractor.push_samples(Array::make(256, 0.2))
  assert_eq(extractor.available_frames(), 1)

  // Push 128 samples (total 640 = 512 + 128) -> 2 frames
  extractor.push_samples(Array::make(128, 0.3))
  assert_eq(extractor.available_frames(), 2)

  // Pop Mel frames
  let mel = extractor.pop_mel_frames()
  assert_eq(mel.n_rows, 20)
  assert_eq(mel.n_cols, 2)

  // Buffer should now have 640 - 2 * 128 = 384 samples (less than 512) -> 0 frames available
  assert_eq(extractor.available_frames(), 0)

  // Reset
  extractor.reset()
  assert_eq(extractor.available_frames(), 0)
}

///|
test "streaming_parity_with_offline_frames" {
  let cfg = {
    ..@types.FeatureConfig::default(),
    n_fft: 512,
    hop_length: 256,
    win_length: 512,
    n_mels: 32,
    n_mfcc: 13,
  }
  let extractor = @streaming.StreamingExtractor::new(config=cfg).unwrap()

  // Generate 2048 test samples
  let total_samples = 2048
  let samples = Array::make(total_samples, 0.0)
  for i in 0..<total_samples {
    samples[i] = @math.sin(i.to_double() * 0.1)
  }

  // Push samples in small streaming chunks of 128 samples each
  let mut total_mfcc_cols = 0
  for offset = 0; offset < total_samples; offset = offset + 128 {
    let chunk = Array::make(128, 0.0)
    for i in 0..<128 {
      chunk[i] = samples[offset + i]
    }
    extractor.push_samples(chunk)
    let mfcc_chunk = extractor.pop_mfcc_frames()
    if mfcc_chunk.n_cols > 0 {
      assert_eq(mfcc_chunk.n_rows, 13)
      total_mfcc_cols = total_mfcc_cols + mfcc_chunk.n_cols
    }
  }

  // 2048 samples with n_fft=512, hop=256: (2048 - 512) / 256 + 1 = 7 frames
  assert_eq(total_mfcc_cols, 7)
}
