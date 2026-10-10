///|
test "wav_decode_synthetic" {
  let bytes : Array[Byte] = [
    // RIFF
    b'R', b'I', b'F', b'F', b'\x28', b'\x00', b'\x00', b'\x00', // size = 40 (44 - 8 + 4)
     b'W', b'A', b'V', b'E',
    // fmt 
     b'f', b'm', b't', b' ', b'\x10', b'\x00', b'\x00', b'\x00', // fmt chunk size 16
     b'\x01', b'\x00', // PCM format
     b'\x01', b'\x00', // 1 channel
     b'\x80', b'\x3E', b'\x00', b'\x00', // 16000 Hz
     b'\x00', b'\x7D', b'\x00', b'\x00', // 32000 byte rate
     b'\x02', b'\x00', // block align
     b'\x10', b'\x00', // 16 bits per sample
    // data
     b'd', b'a', b't', b'a', b'\x04', b'\x00', b'\x00', b'\x00', // data size 4 bytes
     b'\x00', b'\x40', // +16384 -> +0.5
     b'\x00', b'\xC0', // -16384 -> -0.5
  ]

  match decode_wav(bytes) {
    Ok(buf) => {
      assert_eq(buf.sample_rate, 16000)
      assert_eq(buf.samples.length(), 2)
      assert_true((buf.samples[0] - 0.5).abs() < 1.0e-4)
      assert_true((buf.samples[1] - -0.5).abs() < 1.0e-4)
    }
    Err(_) => assert_true(false)
  }
}
