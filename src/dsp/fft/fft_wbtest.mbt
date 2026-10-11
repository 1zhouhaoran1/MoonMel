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

///|
test "bluestein_prime_length_3_numerical_exact" {
  let sig = [
    @types.complex(1.0, 0.0),
    @types.complex(2.0, 0.0),
    @types.complex(3.0, 0.0),
  ]
  match bluestein_fft(sig) {
    Ok(dft_res) => {
      assert_eq(dft_res.length(), 3)
      // X[0] = 6.0
      assert_true((dft_res[0].re - 6.0).abs() < 1.0e-7)
      assert_true(dft_res[0].im.abs() < 1.0e-7)
      // X[1] = -1.5 + j * sqrt(3)/2 = -1.5 + j * 0.8660254037844386
      let sqrt3_over_2 = 0.8660254037844386
      assert_true((dft_res[1].re - -1.5).abs() < 1.0e-7)
      assert_true((dft_res[1].im - sqrt3_over_2).abs() < 1.0e-7)
      // X[2] = -1.5 - j * sqrt(3)/2
      assert_true((dft_res[2].re - -1.5).abs() < 1.0e-7)
      assert_true((dft_res[2].im - -sqrt3_over_2).abs() < 1.0e-7)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "bluestein_roundtrip_prime_lengths" {
  // Prime length 5
  let sig5 = [
    @types.complex(1.2, -0.4),
    @types.complex(-3.0, 2.5),
    @types.complex(0.5, 1.1),
    @types.complex(4.8, -0.9),
    @types.complex(-1.7, -2.3),
  ]
  match dft(sig5) {
    Ok(spec5) =>
      match idft(spec5) {
        Ok(recovered5) =>
          for i in 0..<5 {
            assert_true((recovered5[i].re - sig5[i].re).abs() < 1.0e-7)
            assert_true((recovered5[i].im - sig5[i].im).abs() < 1.0e-7)
          }
        Err(_) => assert_true(false)
      }
    Err(_) => assert_true(false)
  }

  // Prime length 7
  let sig7 = [
    @types.complex(0.1, 0.2),
    @types.complex(0.3, 0.4),
    @types.complex(0.5, 0.6),
    @types.complex(0.7, 0.8),
    @types.complex(0.9, 1.0),
    @types.complex(1.1, 1.2),
    @types.complex(1.3, 1.4),
  ]
  match dft(sig7) {
    Ok(spec7) =>
      match idft(spec7) {
        Ok(recovered7) =>
          for i in 0..<7 {
            assert_true((recovered7[i].re - sig7[i].re).abs() < 1.0e-7)
            assert_true((recovered7[i].im - sig7[i].im).abs() < 1.0e-7)
          }
        Err(_) => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}
