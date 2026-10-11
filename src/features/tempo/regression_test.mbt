///|
test "silence has no detected tempo" {
  assert_eq(
    @tempo.tempogram_from_onset(Array::make(200, 0.0), 16000, 256).bpm,
    0.0,
  )
  assert_eq(@tempo.tempogram_from_onset([], 16000, 256).bpm, 0.0)
}
