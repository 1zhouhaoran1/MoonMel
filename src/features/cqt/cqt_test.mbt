///|
let test_cqt_pi : Double = 3.14159265358979323846

///|
fn synth_sine(
  freq : Double,
  sample_rate : Int,
  duration : Double,
) -> Array[Double] {
  let num_samples = (duration * sample_rate.to_double()).to_int()
  let samples = Array::make(num_samples, 0.0)
  let two_pi_f = 2.0 * test_cqt_pi * freq
  for i in 0..<num_samples {
    let t = i.to_double() / sample_rate.to_double()
    samples[i] = @math.sin(two_pi_f * t)
  }
  samples
}

///|
test "cqt_frequencies_octave_doubling" {
  let cfg = @cqt.CqtConfig::default()
  let freqs = @cqt.cqt_frequencies(cfg)
  assert_eq(freqs.length(), 84)

  // Test that 12 bins corresponds to exact frequency doubling (octave)
  for k in 0..<(84 - 12) {
    let ratio = freqs[k + 12] / freqs[k]
    assert_true((ratio - 2.0).abs() < 1.0e-5)
  }
}

///|
test "cqt_tone_440hz_peak_at_bin_45" {
  let sr = 16000
  let tone_a4 = synth_sine(440.0, sr, 0.3)
  let cfg = @cqt.CqtConfig::default()

  match @cqt.cqt(tone_a4, config=cfg) {
    Ok(cqt_mat) => {
      assert_eq(cqt_mat.n_rows, 84)
      assert_true(cqt_mat.n_cols > 0)

      let mid = cqt_mat.n_cols / 2
      let mut max_val = 0.0
      let mut max_bin = 0
      for k in 0..<84 {
        let v = cqt_mat.at(k, mid)
        if v > max_val {
          max_val = v
          max_bin = k
        }
      }

      assert_eq(max_bin, 45)
      assert_true(max_val > 0.05)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "cqt_octave_peak_shift_220hz_and_440hz" {
  let sr = 16000
  let tone_a3 = synth_sine(220.0, sr, 0.3)
  let cfg = @cqt.CqtConfig::default()

  match @cqt.cqt(tone_a3, config=cfg) {
    Ok(cqt_mat) => {
      let mid = cqt_mat.n_cols / 2
      let mut max_val = 0.0
      let mut max_bin = 0
      for k in 0..<84 {
        let v = cqt_mat.at(k, mid)
        if v > max_val {
          max_val = v
          max_bin = k
        }
      }

      // Bin 33 is A3 (220 Hz), exactly 12 bins below bin 45
      assert_eq(max_bin, 33)
    }
    Err(_) => assert_true(false)
  }
}
