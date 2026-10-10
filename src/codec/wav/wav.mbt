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
/// Parse a WAV file from raw bytes into an AudioBuffer (mono float PCM).
pub fn decode_wav(
  bytes : Array[Byte],
) -> Result[@types.AudioBuffer, @types.MelError] {
  let len = bytes.length()
  if len < 44 {
    return Err(WavParseError("File is too short to be a valid WAV"))
  }
  if !match_tag(bytes, 0, "RIFF") || !match_tag(bytes, 8, "WAVE") {
    return Err(WavParseError("Missing RIFF or WAVE signature"))
  }

  let mut offset = 12
  let mut channels = 1
  let mut sample_rate = 16000
  let mut bits_per_sample = 16
  let mut audio_format = 1
  let mut data_offset = -1
  let mut data_size = 0

  while offset + 8 <= len {
    let chunk_size = read_u32_le(bytes, offset + 4)
    if match_tag(bytes, offset, "fmt ") {
      if chunk_size < 16 {
        return Err(WavParseError("Invalid fmt chunk size"))
      }
      audio_format = read_i16_le(bytes, offset + 8)
      channels = read_i16_le(bytes, offset + 10)
      sample_rate = read_u32_le(bytes, offset + 12)
      bits_per_sample = read_i16_le(bytes, offset + 22)
    } else if match_tag(bytes, offset, "data") {
      data_offset = offset + 8
      data_size = chunk_size
      break
    }
    let padded_size = if chunk_size % 2 != 0 {
      chunk_size + 1
    } else {
      chunk_size
    }
    offset = offset + 8 + padded_size
  }

  if data_offset < 0 || data_offset + data_size > len {
    return Err(WavParseError("Valid data chunk not found"))
  }

  if channels <= 0 {
    return Err(WavParseError("Invalid number of channels"))
  }

  let bytes_per_sample = bits_per_sample / 8
  if bytes_per_sample <= 0 {
    return Err(WavParseError("Unsupported bits per sample: \{bits_per_sample}"))
  }

  let block_align = channels * bytes_per_sample
  let num_frames = data_size / block_align
  let samples : Array[Double] = Array::make(num_frames, 0.0)

  if audio_format == 1 && bits_per_sample == 16 {
    for f in 0..<num_frames {
      let mut sum = 0.0
      let frame_pos = data_offset + f * block_align
      for ch in 0..<channels {
        let sample_pos = frame_pos + ch * 2
        let raw_val = read_i16_le(bytes, sample_pos)
        sum = sum + raw_val.to_double() / 32768.0
      }
      samples[f] = sum / channels.to_double()
    }
  } else if audio_format == 1 && bits_per_sample == 8 {
    for f in 0..<num_frames {
      let mut sum = 0.0
      let frame_pos = data_offset + f * block_align
      for ch in 0..<channels {
        let raw_u8 = bytes[frame_pos + ch].to_int()
        let normalized = (raw_u8.to_double() - 128.0) / 128.0
        sum = sum + normalized
      }
      samples[f] = sum / channels.to_double()
    }
  } else {
    return Err(
      WavParseError(
        "Unsupported audio format: \{audio_format} with \{bits_per_sample}-bit",
      ),
    )
  }

  @types.AudioBuffer::new(samples, sample_rate)
}
