///|
test "web errors are failure envelopes with escaped strings" {
  assert_true(@json.valid(process_audio([], 16000, 1024, 256, 80, 13)))
  assert_eq(
    error_json("bad \"input\"\n"),
    "{\"success\":false,\"error\":\"bad \\\"input\\\"\\n\"}",
  )
  let json = @json.parse(process_audio([], 16000, 1024, 256, 80, 13))
  assert_true(json is { "success": false, .. })
}

///|
test "web arbitrary fft and non finite samples" {
  let valid = @json.parse(
    process_audio([0.1, 0.2, 0.3], 16000, 400, 160, 80, 13),
  )
  assert_true(valid is { "success": true, .. })
  let invalid = @json.parse(process_audio([0.0 / 0.0], 16000, 8, 4, 4, 2))
  assert_true(invalid is { "success": false, .. })
}
