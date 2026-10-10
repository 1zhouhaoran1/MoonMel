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
