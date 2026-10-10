fn main {
  println("==================================================")
  println(" MoonMel Audio DSP Benchmark (MoonBit 0.1.0)       ")
  println("==================================================")

  let sr = 16000
  let durations = [1, 10]

  for dur in durations {
    let num_samples = sr * dur
    let samples : Array[Double] = Array::make(num_samples, 0.0)
    let pi = 3.14159265358979323846264338327950288

    // Generate multi-tone synthetic test audio (440Hz + 1000Hz + 2500Hz)
    for i in 0..<num_samples {
      let t = i.to_double() / sr.to_double()
      let s1 = @math.sin(2.0 * pi * 440.0 * t)
      let s2 = 0.5 * @math.sin(2.0 * pi * 1000.0 * t)
      let s3 = 0.25 * @math.sin(2.0 * pi * 2500.0 * t)
      samples[i] = s1 + s2 + s3
    }

    let cfg = @moonmel.FeatureConfig::default()

    println("Processing \{dur}s audio (\{num_samples} samples, sr=\{sr})...")

    // 1. STFT
    match @moonmel.stft(samples, config=cfg) {
      Ok(spec) =>
        println(
          "  [STFT] Spectrum shape: [\{spec.n_rows} bins, \{spec.n_cols} frames]",
        )
      Err(e) => println("  [STFT] Error: \{e}")
    }

    // 2. Mel Spectrogram
    match @moonmel.mel_spectrogram(samples, config=cfg) {
      Ok(mel) =>
        println(
          "  [Mel] Filterbank shape: [\{mel.n_rows} mels, \{mel.n_cols} frames]",
        )
      Err(e) => println("  [Mel] Error: \{e}")
    }

    // 3. Log-Mel
    match @moonmel.log_mel_spectrogram(samples, config=cfg) {
      Ok(logmel) =>
        println(
          "  [Log-Mel] Matrix shape: [\{logmel.n_rows} mels, \{logmel.n_cols} frames]",
        )
      Err(e) => println("  [Log-Mel] Error: \{e}")
    }

    // 4. MFCC
    match @moonmel.mfcc(samples, config=cfg) {
      Ok(mfccs) =>
        println(
          "  [MFCC] Cepstrum shape: [\{mfccs.n_rows} mfccs, \{mfccs.n_cols} frames]",
        )
      Err(e) => println("  [MFCC] Error: \{e}")
    }
  }

  println("==================================================")
  println(" Benchmark complete.")
  println("==================================================")
}
