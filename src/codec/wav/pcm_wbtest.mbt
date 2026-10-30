///|
fn pcm_fixture(
  bits : Int32,
  channels : Int32,
  payload : Array[Byte],
) -> Array[Byte] {
  let bytes = wav_fixture()
  // Reuse the canonical 16 kHz fmt header and replace its data payload.
  while bytes.length() > 44 {
    let _ = bytes.pop()
  }
  bytes[22] = channels.to_byte()
  bytes[32] = (channels * (bits / 8)).to_byte()
  bytes[34] = bits.to_byte()
  let rate = 16000 * channels * (bits / 8)
  for i in 0..<4 {
    bytes[28 + i] = ((rate >> (8 * i)) & 255).to_byte()
  }
  for b in payload {
    bytes.push(b)
  }
  if payload.length() % 2 != 0 {
    bytes.push(b'\x00')
  }
  let size = bytes.length() - 8
  for i in 0..<4 {
    bytes[4 + i] = ((size >> (8 * i)) & 255).to_byte()
    bytes[40 + i] = ((payload.length() >> (8 * i)) & 255).to_byte()
  }
  bytes
}

///|
test "24 bit PCM sign extension and full scale endpoints" {
  let audio = decode_wav(
    pcm_fixture(24, 1, [
      b'\x00', b'\x00', b'\x80', b'\xff', b'\xff', b'\x7f', b'\x00', b'\x00', b'\x40',
      b'\x00', b'\x00', b'\xc0', b'\xff', b'\xff', b'\xff',
    ]),
  ).unwrap()
  assert_eq(audio.samples, [
    -1.0,
    8388607.0 / 8388608.0,
    0.5,
    -0.5,
    -1.0 / 8388608.0,
  ])
}

///|
test "32 bit integer PCM preserves signed extrema and small values" {
  let audio = decode_wav(
    pcm_fixture(32, 1, [
      b'\x00', b'\x00', b'\x00', b'\x80', b'\xff', b'\xff', b'\xff', b'\x7f', b'\x01',
      b'\x00', b'\x00', b'\x00', b'\xff', b'\xff', b'\xff', b'\xff',
    ]),
  ).unwrap()
  assert_eq(audio.samples, [
    -1.0,
    2147483647.0 / 2147483648.0,
    1.0 / 2147483648.0,
    -1.0 / 2147483648.0,
  ])
}

///|
test "wide PCM rejects partial frames unsupported encodings and bad layout" {
  assert_true(decode_wav(pcm_fixture(24, 1, [b'\x00', b'\x00'])) is Err(_))
  let bytes = pcm_fixture(32, 1, [b'\x00', b'\x00', b'\x00', b'\x00'])
  bytes[20] = b'\x03'
  assert_true(decode_wav(bytes) is Err(_))
  bytes[20] = b'\x01'
  bytes[32] = b'\x02'
  assert_true(decode_wav(bytes) is Err(_))
}

///|
test "stereo PCM preserves channel order instead of cancelling opposite signals" {
  let bytes = pcm_fixture(24, 2, [
    b'\x00', b'\x00', b'\x40', b'\x00', b'\x00', b'\xc0', b'\x00', b'\x00', b'\x20',
    b'\x00', b'\x00', b'\xe0',
  ])
  let audio = decode_wav_multichannel(bytes).unwrap()
  assert_eq(audio.sample_rate, 16000)
  assert_eq(audio.channels, [[0.5, 0.25], [-0.5, -0.25]])
  assert_eq(audio.to_mono().samples, decode_wav(bytes).unwrap().samples)
  assert_eq(audio.channel(1).unwrap().samples, [-0.5, -0.25])
  assert_true(audio.channel(2) is Err(_))
}

///|
test "all supported PCM widths agree between mono and multichannel decoders" {
  for bits in [8, 16, 24, 32] {
    let bytes = pcm_fixture(bits, 1, Array::make(bits / 8 * 4, b'\x00'))
    let mono = decode_wav(bytes).unwrap()
    let multi = decode_wav_multichannel(bytes).unwrap()
    assert_eq(multi.channels.length(), 1)
    assert_eq(multi.channels[0], mono.samples)
  }
  let partial = pcm_fixture(24, 2, [b'\x00', b'\x00', b'\x00'])
  assert_true(decode_wav_multichannel(partial) is Err(_))
  assert_true(decode_wav_multichannel(pcm_fixture(16, 1, [])) is Err(_))
}
