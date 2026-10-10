///|
test "fft_impulse_and_dc" {
  let impulse = [
    @types.complex(1.0, 0.0),
    @types.complex(0.0, 0.0),
    @types.complex(0.0, 0.0),
    @types.complex(0.0, 0.0),
  ]
  match fft(impulse) {
    Ok(res) =>
      for i in 0..<4 {
        assert_true((res[i].re - 1.0).abs() < 1.0e-7)
        assert_true(res[i].im.abs() < 1.0e-7)
      }
    Err(_) => assert_true(false)
  }

  let dc = [
    @types.complex(1.0, 0.0),
    @types.complex(1.0, 0.0),
    @types.complex(1.0, 0.0),
    @types.complex(1.0, 0.0),
  ]
  match fft(dc) {
    Ok(res) => {
      assert_true((res[0].re - 4.0).abs() < 1.0e-7)
      assert_true(res[1].re.abs() < 1.0e-7)
      assert_true(res[2].re.abs() < 1.0e-7)
      assert_true(res[3].re.abs() < 1.0e-7)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "fft_roundtrip" {
  let original = [
    @types.complex(1.5, -0.5),
    @types.complex(-2.0, 3.1),
    @types.complex(0.25, 0.0),
    @types.complex(4.0, -1.2),
  ]
  match fft(original) {
    Ok(spec) =>
      match ifft(spec) {
        Ok(recovered) =>
          for i in 0..<4 {
            assert_true((recovered[i].re - original[i].re).abs() < 1.0e-7)
            assert_true((recovered[i].im - original[i].im).abs() < 1.0e-7)
          }
        Err(_) => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "fft_padded_non_power_of_two" {
  // Length 3 should be padded to 4
  let signal3 = [
    @types.complex(1.0, 0.0),
    @types.complex(2.0, 0.0),
    @types.complex(3.0, 0.0),
  ]
  match fft_padded(signal3) {
    Ok(padded_fft) => {
      assert_eq(padded_fft.length(), 4)
      // DC component (k=0) should be 1 + 2 + 3 + 0 = 6
      assert_true((padded_fft[0].re - 6.0).abs() < 1.0e-7)
      assert_true(padded_fft[0].im.abs() < 1.0e-7)
    }
    Err(_) => assert_true(false)
  }

  // Length 5 should be padded to 8
  let signal5 = [
    @types.complex(1.0, 0.0),
    @types.complex(1.0, 0.0),
    @types.complex(1.0, 0.0),
    @types.complex(1.0, 0.0),
    @types.complex(1.0, 0.0),
  ]
  match fft_padded(signal5) {
    Ok(padded_fft) => {
      assert_eq(padded_fft.length(), 8)
      // DC component should be 5.0
      assert_true((padded_fft[0].re - 5.0).abs() < 1.0e-7)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "rfft_padded_non_power_of_two" {
  let frame = [1.0, 2.0, 3.0]
  match rfft_padded(frame, 2.0) {
    Ok(spec) => {
      // Padded to 4 -> n_bins = 4/2 + 1 = 3
      assert_eq(spec.length(), 3)
      // DC power = 6^2 = 36
      assert_true((spec[0] - 36.0).abs() < 1.0e-7)
    }
    Err(_) => assert_true(false)
  }
}
