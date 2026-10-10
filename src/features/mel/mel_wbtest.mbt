///|
test "mel_conversion_roundtrip" {
  let freqs = [0.0, 200.0, 700.0, 1000.0, 2500.0, 8000.0]
  for f in freqs {
    let mel = hz_to_mel(f, Slaney)
    let back = mel_to_hz(mel, Slaney)
    assert_true((f - back).abs() < 1.0e-6)

    let mel_htk = hz_to_mel(f, Htk)
    let back_htk = mel_to_hz(mel_htk, Htk)
    assert_true((f - back_htk).abs() < 1.0e-6)
  }
}

///|
test "mel_filterbank_structure" {
  let config = @types.FeatureConfig::default()
  match mel_filterbank(config) {
    Ok(fb) => {
      assert_eq(fb.n_rows, 80)
      assert_eq(fb.n_cols, 513)
      for r in 0..<fb.n_rows {
        for c in 0..<fb.n_cols {
          assert_true(fb.at(r, c) >= 0.0)
        }
      }
    }
    Err(_) => assert_true(false)
  }
}
