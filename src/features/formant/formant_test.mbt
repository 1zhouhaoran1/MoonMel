///|
test "durand_kerner_quadratic_real" {
  // P(z) = (z - 2)(z - 3) = z^2 - 5z + 6
  let roots = durand_kerner([-5.0, 6.0])
  assert_eq(roots.length(), 2)
  let r0 = roots[0].re
  let r1 = roots[1].re
  let min_r = if r0 < r1 { r0 } else { r1 }
  let max_r = if r0 > r1 { r0 } else { r1 }
  assert_true((min_r - 2.0).abs() < 1.0e-5)
  assert_true((max_r - 3.0).abs() < 1.0e-5)
}

///|
test "durand_kerner_imaginary_roots" {
  // P(z) = z^2 + 4 = 0 => z = +- 2i
  let roots = durand_kerner([0.0, 4.0])
  assert_eq(roots.length(), 2)
  assert_true(roots[0].re.abs() < 1.0e-5)
  assert_true(roots[1].re.abs() < 1.0e-5)
  assert_true((roots[0].im.abs() - 2.0).abs() < 1.0e-5)
  assert_true((roots[1].im.abs() - 2.0).abs() < 1.0e-5)
}

///|
test "durand_kerner_cubic" {
  // P(z) = (z - 1)(z - 2)(z - 3) = z^3 - 6z^2 + 11z - 6
  let roots = durand_kerner([-6.0, 11.0, -6.0])
  assert_eq(roots.length(), 3)
  for k in 0..<3 {
    let re = roots[k].re
    let match_root = (re - 1.0).abs() < 1.0e-3 ||
      (re - 2.0).abs() < 1.0e-3 ||
      (re - 3.0).abs() < 1.0e-3
    assert_true(match_root)
    assert_true(roots[k].im.abs() < 1.0e-3)
  }
}

///|
test "formant_extraction_synthetic_resonances" {
  let sr = 16000
  let n = 1600
  let sig : Array[Double] = Array::make(n, 0.0)
  let pi2 = 2.0 * @math.PI

  // Synthetic vowel-like signal with resonances near 700 Hz (F1) and 1200 Hz (F2)
  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    let decay1 = @math.exp(-50.0 * (t % 0.01))
    let decay2 = @math.exp(-80.0 * (t % 0.01))
    sig[i] = decay1 * @math.sin(pi2 * 700.0 * t) +
      decay2 * @math.sin(pi2 * 1200.0 * t)
  }

  let cfg = {
    ..FormantConfig::default(),
    lpc_order: 14,
    frame_length: 400,
    hop_length: 160,
  }

  let frames = match formant_track(sig, sr, config=cfg) {
    Ok(f) => f
    Err(_) => {
      assert_true(false)
      return
    }
  }

  assert_true(frames.length() > 0)
  let f1_track = formant_frequencies(frames, 0)
  assert_eq(f1_track.length(), frames.length())
}
