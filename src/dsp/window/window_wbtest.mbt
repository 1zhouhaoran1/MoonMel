///|
test "window_periodic_hann" {
  let win = create_window(PeriodicHann, 4)
  assert_eq(win.length(), 4)
  assert_true((win[0] - 0.0).abs() < 1.0e-7)
  assert_true((win[1] - 0.5).abs() < 1.0e-7)
  assert_true((win[2] - 1.0).abs() < 1.0e-7)
  assert_true((win[3] - 0.5).abs() < 1.0e-7)
}

///|
test "window_reflect_padding" {
  let sig = [1.0, 2.0, 3.0, 4.0]
  let padded = pad_reflect(sig, 2)
  assert_eq(padded.length(), 8)
  assert_eq(padded[0], 3.0)
  assert_eq(padded[1], 2.0)
  assert_eq(padded[2], 1.0)
  assert_eq(padded[3], 2.0)
  assert_eq(padded[4], 3.0)
  assert_eq(padded[5], 4.0)
  assert_eq(padded[6], 3.0)
  assert_eq(padded[7], 2.0)
}

///|
test "reflect_index_large_offsets" {
  // len = 4, period = 6
  assert_eq(reflect_index(0, 4), 0)
  assert_eq(reflect_index(1, 4), 1)
  assert_eq(reflect_index(2, 4), 2)
  assert_eq(reflect_index(3, 4), 3)
  assert_eq(reflect_index(-1, 4), 1)
  assert_eq(reflect_index(-2, 4), 2)
  assert_eq(reflect_index(-3, 4), 3)
  assert_eq(reflect_index(4, 4), 2)
  assert_eq(reflect_index(5, 4), 1)
  assert_eq(reflect_index(6, 4), 0)
  // Large offsets: -6000000 % 6 == 0
  assert_eq(reflect_index(-6000000, 4), 0)
  assert_eq(reflect_index(6000001, 4), 1)
}
