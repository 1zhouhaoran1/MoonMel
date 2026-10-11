///|
/// Reproducible one-second 440 Hz signal; no audio files or external data.
fn main {
  let samples = Array::make(16000, 0.0)
  for i in 0..<samples.length() {
    samples[i] = 0.8 *
      @math.sin(2.0 * @math.PI * 440.0 * i.to_double() / 16000.0)
  }
  match @moonmel.analyze(samples) {
    Ok(result) => {
      println("STFT: \{result.stft.n_rows} x \{result.stft.n_cols}")
      println("Mel: \{result.mel.n_rows} x \{result.mel.n_cols}")
      println("Log-Mel: \{result.log_mel.n_rows} x \{result.log_mel.n_cols}")
      println("MFCC: \{result.mfcc.n_rows} x \{result.mfcc.n_cols}")
    }
    Err(error) => abort(error.to_string())
  }
}
