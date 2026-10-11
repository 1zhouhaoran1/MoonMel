///|
test "vocoder accumulates the previous synthesis step before rendering" {
  let frames : Array[Array[@types.Complex]] = []
  for phase in [0.0, 0.1, 0.3, 0.6] {
    frames.push([
      @types.complex(0.0, 0.0),
      @types.complex(@math.cos(phase), @math.sin(phase)),
      @types.complex(0.0, 0.0),
    ])
  }
  let result = @effects.phase_vocoder(frames, 0.5, 1, 4).unwrap()
  // Two half-speed steps use the first 0.1-radian phase advance twice.
  assert_true((result[2][1].re - @math.cos(0.2)).abs() < 1.0e-9)
  assert_true((result[2][1].im - @math.sin(0.2)).abs() < 1.0e-9)
  // The final interpolation fades toward the explicitly padded zero frame.
  assert_true((result[7][1].abs() - 0.5).abs() < 1.0e-9)
}
