///|
let test_pi : Double = 3.14159265358979323846

///|
fn generate_sine_wave(
  freq : Double,
  sample_rate : Int,
  duration : Double,
) -> Array[Double] {
  let num_samples = (duration * sample_rate.to_double()).to_int()
  let samples = Array::make(num_samples, 0.0)
  let two_pi_f = 2.0 * test_pi * freq
  for i in 0..<num_samples {
    let t = i.to_double() / sample_rate.to_double()
    samples[i] = @math.sin(two_pi_f * t)
  }
  samples
}

///|
test "pitch_class_name_mapping" {
  assert_eq(@chroma.pitch_class_name(0), "C")
  assert_eq(@chroma.pitch_class_name(2), "D")
  assert_eq(@chroma.pitch_class_name(4), "E")
  assert_eq(@chroma.pitch_class_name(5), "F")
  assert_eq(@chroma.pitch_class_name(7), "G")
  assert_eq(@chroma.pitch_class_name(9), "A")
  assert_eq(@chroma.pitch_class_name(11), "B")
  assert_eq(@chroma.pitch_class_name(12), "C")
  assert_eq(@chroma.pitch_class_name(-1), "B")
}

///|
test "chroma_filterbank_dimensions_and_energy" {
  let sr = 16000
  let n_fft = 1024
  let fb = @chroma.chroma_filterbank(sr, n_fft, 0.0, 0.0)
  assert_eq(fb.n_rows, 12)
  assert_eq(fb.n_cols, 513)

  // Verify non-negativity across all elements
  for c in 0..<12 {
    for k in 0..<513 {
      assert_true(fb.at(c, k) >= 0.0)
    }
  }
}

///|
test "chroma_a440_prominence" {
  let sr = 16000
  let tone_a4 = generate_sine_wave(440.0, sr, 0.2)
  let cfg = @types.FeatureConfig::default()
  match @chroma.chroma_stft(tone_a4, cfg, @chroma.ChromaNorm::Max) {
    Ok(chroma) => {
      assert_eq(chroma.n_rows, 12)
      assert_true(chroma.n_cols > 0)
      // Check middle frame
      let mid = chroma.n_cols / 2
      let a_val = chroma.at(9, mid) // Pitch class 9 is A
      // A should be the dominant pitch class (>= all others)
      for c in 0..<12 {
        assert_true(a_val >= chroma.at(c, mid))
      }
      assert_true(a_val > 0.8)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "chroma_c4_prominence" {
  let sr = 16000
  let tone_c4 = generate_sine_wave(261.63, sr, 0.2)
  let cfg = @types.FeatureConfig::default()
  match @chroma.chroma_stft(tone_c4, cfg, @chroma.ChromaNorm::Max) {
    Ok(chroma) => {
      let mid = chroma.n_cols / 2
      let c_val = chroma.at(0, mid) // Pitch class 0 is C
      // C should be dominant
      for c in 0..<12 {
        assert_true(c_val >= chroma.at(c, mid))
      }
      assert_true(c_val > 0.8)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "chroma_normalization_l1_and_l2" {
  let sr = 16000
  let tone = generate_sine_wave(330.0, sr, 0.15)
  let cfg = @types.FeatureConfig::default()

  // Test L1 normalization: column sums equal ~1.0
  match @chroma.chroma_stft(tone, cfg, @chroma.ChromaNorm::L1) {
    Ok(chroma) => {
      let mid = chroma.n_cols / 2
      let mut sum = 0.0
      for c in 0..<12 {
        sum = sum + chroma.at(c, mid)
      }
      assert_true((sum - 1.0).abs() < 1.0e-5)
    }
    Err(_) => assert_true(false)
  }

  // Test L2 normalization: Euclidean length equals ~1.0
  match @chroma.chroma_stft(tone, cfg, @chroma.ChromaNorm::L2) {
    Ok(chroma) => {
      let mid = chroma.n_cols / 2
      let mut sum_sq = 0.0
      for c in 0..<12 {
        let v = chroma.at(c, mid)
        sum_sq = sum_sq + v * v
      }
      assert_true((sum_sq - 1.0).abs() < 1.0e-5)
    }
    Err(_) => assert_true(false)
  }
}
