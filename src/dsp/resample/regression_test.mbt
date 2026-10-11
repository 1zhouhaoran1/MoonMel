///|
test "polyphase upsampling preserves the fractional sample phase" {
  let samples = Array::make(256, 0.0)
  for i in 0..<256 {
    samples[i] = @math.sin(2.0 * @math.PI * 1000.0 * i.to_double() / 16000.0)
  }
  let out = @resample.resample_polyphase(samples, 16000, 48000).unwrap()
  let mut error = 0.0
  for i in 60..<700 {
    error = error +
      (out[i] - @math.sin(2.0 * @math.PI * 1000.0 * i.to_double() / 48000.0)).abs()
  }
  assert_true(error / 640.0 < 0.01)
}

///|
test "resamplers reject nonpositive filters" {
  assert_true(
    @resample.resample_polyphase([1.0], 16000, 8000, half_len=0) is Err(_),
  )
  assert_true(
    @resample.resample_sinc([1.0], 16000, 8000, filter_size=-1) is Err(_),
  )
}
