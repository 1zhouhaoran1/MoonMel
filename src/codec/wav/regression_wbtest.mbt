///|
fn wav_fixture() -> Array[Byte] {
  [
    b'R', b'I', b'F', b'F', b'\x28', b'\x00', b'\x00', b'\x00', b'W', b'A', b'V',
    b'E', b'f', b'm', b't', b' ', b'\x10', b'\x00', b'\x00', b'\x00', b'\x01', b'\x00',
    b'\x01', b'\x00', b'\x80', b'\x3e', b'\x00', b'\x00', b'\x00', b'\x7d', b'\x00',
    b'\x00', b'\x02', b'\x00', b'\x10', b'\x00', b'd', b'a', b't', b'a', b'\x04',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x40', b'\x00', b'\xc0',
  ]
}

///|
test "wav rejects hostile chunk sizes without indexing or looping" {
  let bytes = wav_fixture()
  for i in 16..<20 {
    bytes[i] = b'\xff'
  }
  assert_true(decode_wav(bytes) is Err(_))
  bytes[16] = b'\x7f'
  bytes[19] = b'\x7f'
  assert_true(decode_wav(bytes) is Err(_))
}

///|
test "wav requires a format and complete pcm frames" {
  let bytes = wav_fixture()
  bytes[12] = b'J'
  bytes[13] = b'U'
  bytes[14] = b'N'
  bytes[15] = b'K'
  assert_true(decode_wav(bytes) is Err(_))
  let partial = wav_fixture()
  partial[40] = b'\x03'
  assert_true(decode_wav(partial) is Err(_))
}

///|
test "wav rejects invalid block alignment and truncated riff" {
  let bytes = wav_fixture()
  bytes[32] = b'\x01'
  assert_true(decode_wav(bytes) is Err(_))
  let truncated = wav_fixture()
  truncated[4] = b'\x60'
  assert_true(decode_wav(truncated) is Err(_))
}
