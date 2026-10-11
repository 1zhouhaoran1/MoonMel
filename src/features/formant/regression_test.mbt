///|
test "formants recover the frequency and bandwidth of a known all pole model" {
  let radius = 0.95
  let sr = 16000
  let frequency = 1000.0
  let a1 = 2.0 * radius * @math.cos(2.0 * @math.PI * frequency / sr.to_double())
  let result = @formant.formants_from_lpc(
    [a1, -radius * radius],
    sr,
    @formant.FormantConfig::default(),
  )
  assert_eq(result.formants.length(), 1)
  assert_true((result.formants[0].frequency - frequency).abs() < 1.0e-7)
  let bandwidth = -sr.to_double() * @math.ln(radius) / @math.PI
  assert_true((result.formants[0].bandwidth - bandwidth).abs() < 1.0e-7)
}

///|
test "formant track rejects a zero hop" {
  let cfg = { ..@formant.FormantConfig::default(), hop_length: 0, }
  assert_true(
    @formant.formant_track(Array::make(800, 0.1), 16000, config=cfg) is Err(_),
  )
}
