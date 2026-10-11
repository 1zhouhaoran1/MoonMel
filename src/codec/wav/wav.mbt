///|
/// Decode 16-bit little endian signed integer from byte array.
fn read_i16_le(bytes : Array[Byte], offset : Int) -> Int {
  let b0 = bytes[offset].to_int()
  let b1 = bytes[offset + 1].to_int()
  let unsigned = b0 | (b1 << 8)
  if unsigned >= 32768 {
    unsigned - 65536
  } else {
    unsigned
  }
}

///|
/// Decode 32-bit little endian unsigned integer from byte array.
fn read_u32_le(bytes : Array[Byte], offset : Int) -> Int {
  let b0 = bytes[offset].to_int()
  let b1 = bytes[offset + 1].to_int()
  let b2 = bytes[offset + 2].to_int()
  let b3 = bytes[offset + 3].to_int()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
/// Check 4-byte ASCII tag.
fn match_tag(bytes : Array[Byte], offset : Int, tag : String) -> Bool {
  if offset + 4 > bytes.length() {
    return false
  }
  for i in 0..<4 {
    if bytes[offset + i].to_int() != tag[i].to_int() {
      return false
    }
  }
  true
}

///|
/// Parse bounded RIFF chunks, then decode supported PCM to mono.
pub fn decode_wav(
  bytes : Array[Byte],
) -> Result[@types.AudioBuffer, @types.MelError] {
  let len = bytes.length()
  if len < 12 || !match_tag(bytes, 0, "RIFF") || !match_tag(bytes, 8, "WAVE") {
    return Err(WavParseError("Missing RIFF or WAVE signature"))
  }
  let riff_size = read_u32_le(bytes, 4)
  if riff_size < 4 || riff_size > len - 8 {
    return Err(WavParseError("Invalid or truncated RIFF size"))
  }
  let end = riff_size + 8
  let mut offset = 12
  let mut channels = 0
  let mut sample_rate = 0
  let mut bits_per_sample = 0
  let mut block_align = 0
  let mut found_fmt = false
  let mut data_offset = -1
  let mut data_size = 0
  while offset < end {
    if end - offset < 8 {
      return Err(WavParseError("Truncated chunk header"))
    }
    let size = read_u32_le(bytes, offset + 4)
    let payload = offset + 8
    // Subtraction prevents signed overflow from a hostile 32-bit size field.
    if size < 0 || size > end - payload {
      return Err(WavParseError("Chunk extends beyond RIFF bounds"))
    }
    if match_tag(bytes, offset, "fmt ") {
      if found_fmt || size < 16 {
        return Err(WavParseError("Invalid or duplicate fmt chunk"))
      }
      if read_i16_le(bytes, payload) != 1 {
        return Err(WavParseError("Only PCM WAV is supported"))
      }
      channels = read_i16_le(bytes, payload + 2)
      sample_rate = read_u32_le(bytes, payload + 4)
      block_align = read_i16_le(bytes, payload + 12)
      bits_per_sample = read_i16_le(bytes, payload + 14)
      if channels <= 0 ||
        sample_rate <= 0 ||
        (bits_per_sample != 8 && bits_per_sample != 16) {
        return Err(
          WavParseError("Invalid PCM format, sample rate or channel count"),
        )
      }
      if block_align != channels * (bits_per_sample / 8) {
        return Err(
          WavParseError("PCM block alignment does not match channel layout"),
        )
      }
      found_fmt = true
    } else if match_tag(bytes, offset, "data") {
      if data_offset >= 0 {
        return Err(WavParseError("Duplicate data chunk"))
      }
      data_offset = payload
      data_size = size
    }
    offset = payload + size
    if size % 2 != 0 && offset < end {
      offset = offset + 1
    }
  }
  if !found_fmt || data_offset < 0 {
    return Err(WavParseError("Missing fmt or data chunk"))
  }
  if data_size % block_align != 0 {
    return Err(WavParseError("Incomplete PCM frame"))
  }
  let bytes_per_sample = bits_per_sample / 8
  let num_frames = data_size / block_align
  let samples = Array::make(num_frames, 0.0)
  for f in 0..<num_frames {
    let mut sum = 0.0
    for ch in 0..<channels {
      let pos = data_offset + f * block_align + ch * bytes_per_sample
      let value = if bits_per_sample == 16 {
        read_i16_le(bytes, pos).to_double() / 32768.0
      } else {
        (bytes[pos].to_int().to_double() - 128.0) / 128.0
      }
      sum = sum + value
    }
    samples[f] = sum / channels.to_double()
  }
  @types.AudioBuffer::new(samples, sample_rate)
}
