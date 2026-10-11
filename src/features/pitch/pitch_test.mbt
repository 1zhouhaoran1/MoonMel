///|
test "difference_function_and_cmndf_properties" {
  let frame = [1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0]
  let d = @pitch.difference_function(frame, 4)
  assert_eq(d.length(), 5)
  assert_eq(d[0], 0.0)

  let cmndf = @pitch.cumulative_mean_normalized_difference(d)
  assert_eq(cmndf.length(), 5)
  assert_eq(cmndf[0], 1.0)
  // For period of 3, d[3] should be 0.0 and cmndf[3] should be 0.0
  assert_eq(d[3], 0.0)
  assert_eq(cmndf[3], 0.0)
}

///|
test "yin_frame_440hz_sine" {
  let sr = 16000
  let n = 2048
  let frame : Array[Double] = Array::make(n, 0.0)
  let pi2 = 2.0 * @math.PI
  let target_f0 = 440.0

  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    frame[i] = @math.sin(pi2 * target_f0 * t)
  }

  let (f0, voiced_prob, _) = @pitch.yin_frame(frame, sr, 65.0, 2093.0, 0.1)
  assert_true((f0 - target_f0).abs() < 1.0)
  assert_true(voiced_prob > 0.9)
}

///|
test "pitch_yin_audio_pipeline" {
  let sr = 16000
  let n = 4096
  let samples : Array[Double] = Array::make(n, 0.0)
  let pi2 = 2.0 * @math.PI
  let target_f0 = 220.0 // A3

  for i in 0..<n {
    let t = i.to_double() / sr.to_double()
    samples[i] = @math.sin(pi2 * target_f0 * t)
  }

  let audio = @types.AudioBuffer::new(samples, sr).unwrap()
  let track = @pitch.pitch_yin(audio).unwrap()
  assert_true(track.f0.length() > 0)

  let mid_frame = track.f0.length() / 2
  assert_true((track.f0[mid_frame] - target_f0).abs() < 1.0)
  assert_true(track.voiced_prob[mid_frame] > 0.8)
}
