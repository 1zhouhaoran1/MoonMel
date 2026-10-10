///|
test "rms: constant signal produces constant rms" {
  let samples = Array::make(1024, 3.5)
  let audio = @types.AudioBuffer::new(samples, 16000).unwrap()
  let rms = compute_rms(audio, frame_length=256, hop_length=128, center=false).unwrap()
  assert_eq(rms.n_rows, 1)
  assert_true(rms.n_cols > 0)
  for c in 0..<rms.n_cols {
    let diff = (rms.at(0, c) - 3.5).abs()
    assert_true(diff < 1.0e-12)
  }
}

///|
test "rms: silence produces zero energy" {
  let samples = Array::make(512, 0.0)
  let audio = @types.AudioBuffer::new(samples, 16000).unwrap()
  let rms = compute_rms(audio, frame_length=128, hop_length=64, center=true).unwrap()
  for c in 0..<rms.n_cols {
    assert_true(rms.at(0, c) < 1.0e-12)
  }
}

///|
test "energy: energy equals square of rms times frame_length" {
  let samples = [0.1, -0.2, 0.5, 0.8, -0.4, 0.3, -0.9, 0.6]
  let audio = @types.AudioBuffer::new(samples, 8000).unwrap()
  let frame_len = 4
  let rms = compute_rms(
    audio,
    frame_length=frame_len,
    hop_length=2,
    center=false,
  ).unwrap()
  let energy = compute_energy(
    audio,
    frame_length=frame_len,
    hop_length=2,
    center=false,
  ).unwrap()
  assert_eq(rms.n_cols, energy.n_cols)
  for c in 0..<rms.n_cols {
    let r = rms.at(0, c)
    let e = energy.at(0, c)
    let expected_e = r * r * frame_len.to_double()
    assert_true((e - expected_e).abs() < 1.0e-10)
  }
}
