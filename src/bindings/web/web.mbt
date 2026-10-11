///|
/// Web transport only: algorithms and orchestration belong to lower layers.
pub fn process_audio(
  samples : Array[Double],
  sample_rate : Int,
  n_fft : Int,
  hop_length : Int,
  n_mels : Int,
  n_mfcc : Int,
) -> String {
  let cfg = {
    ..@facade.FeatureConfig::default(),
    sample_rate,
    n_fft,
    hop_length,
    win_length: n_fft,
    n_mels,
    n_mfcc,
    f_max: sample_rate.to_double() / 2.0,
  }
  analyze_config(samples, cfg)
}

///|
/// Explicit framing options for reproducible browser and reference analyses.
pub fn process_audio_config(
  samples : Array[Double],
  sample_rate : Int,
  n_fft : Int,
  hop_length : Int,
  win_length : Int,
  n_mels : Int,
  n_mfcc : Int,
  center : Bool,
  power : Double,
) -> String {
  let cfg = {
    ..@facade.FeatureConfig::default(),
    sample_rate,
    n_fft,
    hop_length,
    win_length,
    n_mels,
    n_mfcc,
    center,
    power,
    f_max: sample_rate.to_double() / 2.0,
  }
  analyze_config(samples, cfg)
}

///|
/// Configure all numerical options from MoonBit callers and reference tests.
pub fn analyze_config(
  samples : Array[Double],
  cfg : @facade.FeatureConfig,
) -> String {
  let result = match @facade.analyze(samples, config=cfg) {
    Ok(value) => value
    Err(error) => return error_json(error.to_string())
  }
  // Cover the complete one-sided frequency range, including its last bin.
  let bins = if result.stft.n_rows > 64 { 64 } else { result.stft.n_rows }
  let preview = Array::make(bins, [])
  let indices = Array::make(bins, 0)
  for r in 0..<bins {
    let k = if bins > 1 { r * (result.stft.n_rows - 1) / (bins - 1) } else { 0 }
    indices[r] = k
    preview[r] = result.stft.get_row(k)
  }
  let sb = StringBuilder()
  sb.write_string("{\"success\":true,\"sample_rate\":\{cfg.sample_rate},")
  sb.write_string("\"num_samples\":\{samples.length()},\"n_fft\":\{cfg.n_fft},")
  sb.write_string(
    "\"hop_length\":\{cfg.hop_length},\"n_mels\":\{cfg.n_mels},\"n_mfcc\":\{cfg.n_mfcc},",
  )
  sb.write_string(
    "\"n_frames\":\{result.stft.n_cols},\"n_freq_bins\":\{result.stft.n_rows},",
  )
  sb.write_string("\"mel\":")
  sb.write_string(@json.to_json(result.mel.data).stringify())
  sb.write_string(",\"log_mel\":")
  sb.write_string(@json.to_json(result.log_mel.data).stringify())
  sb.write_string(",\"mfcc\":")
  sb.write_string(@json.to_json(result.mfcc.data).stringify())
  sb.write_string(",\"stft_preview\":")
  sb.write_string(@json.to_json(preview).stringify())
  sb.write_string(",\"stft_bin_indices\":")
  sb.write_string(@json.to_json(indices).stringify())
  sb.write_string(",\"filterbank\":")
  sb.write_string(@json.to_json(result.filterbank.data).stringify())
  sb.write_string("}")
  sb.to_string()
}

///|
fn error_json(message : String) -> String {
  "{\"success\":false,\"error\":" + @json.to_json(message).stringify() + "}"
}

///|
/// Decode through the project's PCM WAV parser, preserving samples for playback.
pub fn decode_wav_audio(bytes : Array[Byte]) -> String {
  match @facade.decode_wav(bytes) {
    Ok(audio) =>
      "{\"success\":true,\"sample_rate\":\{audio.sample_rate},\"samples\":" +
      @json.to_json(audio.samples).stringify() +
      "}"
    Err(error) => error_json(error.to_string())
  }
}

///|
pub fn process_wav_bytes(
  bytes : Array[Byte],
  n_fft : Int,
  hop_length : Int,
  n_mels : Int,
  n_mfcc : Int,
) -> String {
  match @facade.decode_wav(bytes) {
    Ok(audio) =>
      process_audio(
        audio.samples,
        audio.sample_rate,
        n_fft,
        hop_length,
        n_mels,
        n_mfcc,
      )
    Err(error) => error_json(error.to_string())
  }
}
