///|
/// A deterministic stereo PCM16 WAV, generated locally without external assets.
fn stereo_fixture() -> Array[Byte] {
  let frames = 1600
  let bytes = Array::make(44 + frames * 4, b'\x00')
  for i in 0..<4 {
    bytes[i] = "RIFF"[i].to_int().to_byte()
    bytes[8 + i] = "WAVE"[i].to_int().to_byte()
    bytes[12 + i] = "fmt "[i].to_int().to_byte()
    bytes[36 + i] = "data"[i].to_int().to_byte()
  }
  for i in 0..<4 {
    bytes[4 + i] = (((bytes.length() - 8) >> (8 * i)) & 255).to_byte()
    bytes[24 + i] = ((16000 >> (8 * i)) & 255).to_byte()
    bytes[28 + i] = ((64000 >> (8 * i)) & 255).to_byte()
    bytes[40 + i] = (((frames * 4) >> (8 * i)) & 255).to_byte()
  }
  bytes[16] = b'\x10'
  bytes[20] = b'\x01'
  bytes[22] = b'\x02'
  bytes[32] = b'\x04'
  bytes[34] = b'\x10'
  for frame in 0..<frames {
    let value = (12000.0 *
    @math.sin(2.0 * @math.PI * 440.0 * frame.to_double() / 16000.0)).to_int()
    for channel in 0..<2 {
      let sample = if channel == 0 { value } else { value / 2 }
      let offset = 44 + frame * 4 + channel * 2
      bytes[offset] = (sample & 255).to_byte()
      bytes[offset + 1] = ((sample >> 8) & 255).to_byte()
    }
  }
  bytes
}

///|
/// WAV → preserved channels → complete streaming frames → assembled MFCC → CMVN.
/// NaturalLog avoids the batch-dependent dB clipping of separately popped batches.
fn main raise {
  let audio = @moonmel.decode_wav_multichannel(stereo_fixture()).unwrap()
  let config = {
    ..@moonmel.FeatureConfig::default(),
    n_fft: 256,
    win_length: 200,
    hop_length: 80,
    n_mels: 24,
    n_mfcc: 13,
    center: false,
    log_scale: NaturalLog,
  }
  let mono = audio.to_mono()
  let extractor = @moonmel.create_streaming_extractor(config~).unwrap()
  let batches : Array[@moonmel.FeatureMatrix] = []
  for offset = 0; offset < mono.length(); offset = offset + 127 {
    let chunk : Array[Double] = []
    for index = offset
        index < offset + 127 && index < mono.length()
        index = index + 1 {
      chunk.push(mono.samples[index])
    }
    extractor.try_push_samples(chunk).unwrap()
    batches.push(extractor.pop_features().unwrap().mfcc)
  }
  let features = @moonmel.FeatureMatrix::concat_frames(batches).unwrap()
  let offline = @moonmel.mfcc(mono.samples, config~).unwrap()
  assert_eq(features.n_cols, 17)
  for row in 0..<features.n_rows {
    for col in 0..<features.n_cols {
      assert_true((features.at(row, col) - offline.at(row, col)).abs() < 1.0e-9)
    }
  }
  let normalized = @moonmel.cmvn(features).unwrap()
  println(
    "WAV: \{audio.num_channels()} channels, \{audio.length()} samples/channel at \{audio.sample_rate} Hz",
  )
  println(
    "Streaming/offline MFCC agree: \{features.n_rows} x \{features.n_cols}",
  )
  println(
    "CMVN: \{normalized.n_rows} x \{normalized.n_cols}; pending tail: \{extractor.buffered_samples()} samples",
  )
}
