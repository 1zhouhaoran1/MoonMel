///| Web binding API for MoonMel Playground.
pub fn process_audio(
  samples : Array[Double],
  sample_rate : Int,
  n_fft : Int,
  hop_length : Int,
  n_mels : Int,
  n_mfcc : Int
) -> String {
  let cfg = {
    ..@moonmel.FeatureConfig::default(),
    sample_rate,
    n_fft,
    hop_length,
    win_length: n_fft,
    n_mels,
    n_mfcc,
    f_max: sample_rate.to_double() / 2.0,
  }

  let stft_res = @moonmel.stft(samples, config=cfg)
  let mel_res = @moonmel.mel_spectrogram(samples, config=cfg)
  let logmel_res = @moonmel.log_mel_spectrogram(samples, config=cfg)
  let mfcc_res = @moonmel.mfcc(samples, config=cfg)

  let sb = StringBuilder()
  sb.write_string("{\"success\":true,")
  sb.write_string("\"sample_rate\":\{sample_rate},")
  sb.write_string("\"num_samples\":\{samples.length()},")
  sb.write_string("\"n_fft\":\{n_fft},")
  sb.write_string("\"hop_length\":\{hop_length},")
  sb.write_string("\"n_mels\":\{n_mels},")
  sb.write_string("\"n_mfcc\":\{n_mfcc},")

  match (stft_res, mel_res, logmel_res, mfcc_res) {
    (Ok(stft_mat), Ok(mel_mat), Ok(logmel_mat), Ok(mfcc_mat)) => {
      sb.write_string("\"n_frames\":\{stft_mat.n_cols},")
      sb.write_string("\"n_freq_bins\":\{stft_mat.n_rows},")

      // Linear Mel Spectrogram matrix [n_mels][n_frames]
      sb.write_string("\"mel\":[")
      for r in 0..<mel_mat.n_rows {
        if r > 0 { sb.write_string(",") }
        sb.write_string("[")
        for c in 0..<mel_mat.n_cols {
          if c > 0 { sb.write_string(",") }
          sb.write_string("\{mel_mat.at(r, c)}")
        }
        sb.write_string("]")
      }
      sb.write_string("],")

      // Log-Mel matrix [n_mels][n_frames]
      sb.write_string("\"log_mel\":[")
      for r in 0..<logmel_mat.n_rows {
        if r > 0 { sb.write_string(",") }
        sb.write_string("[")
        for c in 0..<logmel_mat.n_cols {
          if c > 0 { sb.write_string(",") }
          sb.write_string("\{logmel_mat.at(r, c)}")
        }
        sb.write_string("]")
      }
      sb.write_string("],")

      // MFCC matrix [n_mfcc][n_frames]
      sb.write_string("\"mfcc\":[")
      for r in 0..<mfcc_mat.n_rows {
        if r > 0 { sb.write_string(",") }
        sb.write_string("[")
        for c in 0..<mfcc_mat.n_cols {
          if c > 0 { sb.write_string(",") }
          sb.write_string("\{mfcc_mat.at(r, c)}")
        }
        sb.write_string("]")
      }
      sb.write_string("],")

      // Downsampled STFT preview (max 64 frequency bins for speedy rendering)
      let stft_sample_bins = if stft_mat.n_rows > 64 { 64 } else { stft_mat.n_rows }
      sb.write_string("\"stft_preview\":[")
      for r in 0..<stft_sample_bins {
        if r > 0 { sb.write_string(",") }
        sb.write_string("[")
        let bin_idx = r * (stft_mat.n_rows / stft_sample_bins)
        for c in 0..<stft_mat.n_cols {
          if c > 0 { sb.write_string(",") }
          sb.write_string("\{stft_mat.at(bin_idx, c)}")
        }
        sb.write_string("]")
      }
      sb.write_string("]")
    }
    _ => {
      sb.write_string("\"error\":\"Feature extraction failed\"")
    }
  }

  sb.write_string("}")
  sb.to_string()
}

///| Web binding for WAV bytes.
pub fn process_wav_bytes(
  bytes : Array[Byte],
  n_fft : Int,
  hop_length : Int,
  n_mels : Int,
  n_mfcc : Int
) -> String {
  match @moonmel.decode_wav(bytes) {
    Ok(buf) => {
      process_audio(buf.samples, buf.sample_rate, n_fft, hop_length, n_mels, n_mfcc)
    }
    Err(e) => {
      "{\"success\":false,\"error\":\"\{e}\"}"
    }
  }
}
