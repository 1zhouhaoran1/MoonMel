///|
let pi : Double = 3.14159265358979323846264338327950288

///|
/// Checks whether an integer is a power of 2.
pub fn is_power_of_two(n : Int) -> Bool {
  n > 0 && (n & (n - 1)) == 0
}

///|
/// Computes the smallest power of 2 that is >= n.
pub fn next_power_of_two(n : Int) -> Int {
  if n <= 1 {
    return 1
  }
  let mut v = n - 1
  v = v | (v >> 1)
  v = v | (v >> 2)
  v = v | (v >> 4)
  v = v | (v >> 8)
  v = v | (v >> 16)
  v + 1
}

///|
/// In-place bit-reversal permutation for separate real and imaginary arrays.
fn bit_reverse_permute(re : Array[Double], im : Array[Double], n : Int) -> Unit {
  let mut j = 0
  for i = 0; i < n - 1; i = i + 1 {
    if i < j {
      let tr = re[i]
      re[i] = re[j]
      re[j] = tr
      let ti = im[i]
      im[i] = im[j]
      im[j] = ti
    }
    let mut k = n / 2
    while k <= j {
      j = j - k
      k = k / 2
    }
    j = j + k
  }
}

///|
/// In-place Radix-2 Cooley-Tukey FFT algorithm.
pub fn fft_in_place(
  re : Array[Double],
  im : Array[Double],
  n : Int,
  inverse : Bool,
) -> Unit {
  // This low-level kernel is radix-2 only. Reject unsafe direct calls before
  // bit reversal can loop forever or a butterfly can index beyond the arrays.
  if !is_power_of_two(n) || re.length() < n || im.length() < n {
    abort(
      "fft_in_place requires power-of-two n and buffers of at least n elements",
    )
  }
  bit_reverse_permute(re, im, n)
  let dir = if inverse { 1.0 } else { -1.0 }
  let mut len = 2
  while len <= n {
    let half = len / 2
    let angle_step = dir * 2.0 * pi / len.to_double()
    let w_step_re = @math.cos(angle_step)
    let w_step_im = @math.sin(angle_step)
    let mut i = 0
    while i < n {
      let mut w_re = 1.0
      let mut w_im = 0.0
      for j in 0..<half {
        let idx1 = i + j
        let idx2 = idx1 + half
        let u_re = re[idx1]
        let u_im = im[idx1]
        let v_re = re[idx2] * w_re - im[idx2] * w_im
        let v_im = re[idx2] * w_im + im[idx2] * w_re
        re[idx1] = u_re + v_re
        im[idx1] = u_im + v_im
        re[idx2] = u_re - v_re
        im[idx2] = u_im - v_im
        let next_w_re = w_re * w_step_re - w_im * w_step_im
        let next_w_im = w_re * w_step_im + w_im * w_step_re
        w_re = next_w_re
        w_im = next_w_im
      }
      i = i + len
    }
    len = len * 2
  }
  if inverse {
    let inv_n = 1.0 / n.to_double()
    for i in 0..<n {
      re[i] = re[i] * inv_n
      im[i] = im[i] * inv_n
    }
  }
}

///|
/// Forward FFT for an array of Complex numbers.
pub fn fft(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  let n = signal.length()
  if n == 0 {
    return Err(EmptyAudio)
  }
  if !is_power_of_two(n) {
    return Err(InvalidFftSize(n))
  }
  let re : Array[Double] = Array::make(n, 0.0)
  let im : Array[Double] = Array::make(n, 0.0)
  for i in 0..<n {
    re[i] = signal[i].re
    im[i] = signal[i].im
  }
  fft_in_place(re, im, n, false)
  let out : Array[@types.Complex] = Array::make(n, @types.Complex::{
    re: 0.0,
    im: 0.0,
  })
  for i in 0..<n {
    out[i] = { re: re[i], im: im[i], }
  }
  Ok(out)
}

///|
/// Inverse FFT for an array of Complex numbers.
pub fn ifft(
  spectrum : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  let n = spectrum.length()
  if n == 0 {
    return Err(EmptyAudio)
  }
  if !is_power_of_two(n) {
    return Err(InvalidFftSize(n))
  }
  let re : Array[Double] = Array::make(n, 0.0)
  let im : Array[Double] = Array::make(n, 0.0)
  for i in 0..<n {
    re[i] = spectrum[i].re
    im[i] = spectrum[i].im
  }
  fft_in_place(re, im, n, true)
  let out : Array[@types.Complex] = Array::make(n, @types.Complex::{
    re: 0.0,
    im: 0.0,
  })
  for i in 0..<n {
    out[i] = { re: re[i], im: im[i], }
  }
  Ok(out)
}

///|
/// Compute one-sided power or magnitude spectrum of a real frame of size n_fft.
pub fn rfft_spectrum(
  frame : Array[Double],
  n_fft : Int,
  power : Double,
) -> Result[Array[Double], @types.MelError] {
  if n_fft <= 0 {
    return Err(InvalidFftSize(n_fft))
  }
  let re : Array[Double] = Array::make(n_fft, 0.0)
  let im : Array[Double] = Array::make(n_fft, 0.0)
  let flen = frame.length()
  for i in 0..<n_fft {
    if i < flen {
      re[i] = frame[i]
    } else {
      re[i] = 0.0
    }
  }
  match transform_in_place(re, im, n_fft, false) {
    Ok(_) => ()
    Err(e) => return Err(e)
  }
  let num_bins = n_fft / 2 + 1
  let spec : Array[Double] = Array::make(num_bins, 0.0)
  if power == 2.0 {
    for i in 0..<num_bins {
      spec[i] = re[i] * re[i] + im[i] * im[i]
    }
  } else if power == 1.0 {
    for i in 0..<num_bins {
      spec[i] = (re[i] * re[i] + im[i] * im[i]).sqrt()
    }
  } else {
    for i in 0..<num_bins {
      let p2 = re[i] * re[i] + im[i] * im[i]
      spec[i] = @math.pow(p2, power / 2.0)
    }
  }
  Ok(spec)
}

///|
/// Safe transform dispatcher. Reuses buffers for radix-2 sizes and preserves
/// the exact frequency grid with Bluestein for all other positive lengths.
pub fn transform_in_place(
  re : Array[Double],
  im : Array[Double],
  n : Int,
  inverse : Bool,
) -> Result[Unit, @types.MelError] {
  if n <= 0 {
    return Err(InvalidFftSize(n))
  }
  if re.length() < n || im.length() < n {
    return Err(DimensionMismatch("FFT buffers are shorter than n"))
  }
  if is_power_of_two(n) {
    fft_in_place(re, im, n, inverse)
    return Ok(())
  }
  let signal = Array::make(n, @types.complex(0.0, 0.0))
  for i in 0..<n {
    signal[i] = @types.complex(re[i], im[i])
  }
  let transformed = match (if inverse { idft(signal) } else { dft(signal) }) {
    Ok(result) => result
    Err(e) => return Err(e)
  }
  for i in 0..<n {
    re[i] = transformed[i].re
    im[i] = transformed[i].im
  }
  Ok(())
}

///|
/// Forward FFT with automatic zero-padding to the next power of 2 for arbitrary length signals.
pub fn fft_padded(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  let n = signal.length()
  if n == 0 {
    return Err(EmptyAudio)
  }
  let target_n = next_power_of_two(n)
  let padded : Array[@types.Complex] = Array::make(
    target_n,
    @types.complex(0.0, 0.0),
  )
  for i in 0..<n {
    padded[i] = signal[i]
  }
  fft(padded)
}

///|
/// Real FFT spectrum with automatic zero-padding to the next power of 2 for arbitrary length frames.
pub fn rfft_padded(
  frame : Array[Double],
  power : Double,
) -> Result[Array[Double], @types.MelError] {
  let flen = frame.length()
  if flen == 0 {
    return Err(EmptyAudio)
  }
  let target_n = next_power_of_two(flen)
  rfft_spectrum(frame, target_n, power)
}

///|
/// Arbitrary-length Discrete Fourier Transform (DFT) via Bluestein's Algorithm (Chirp Z-Transform).
/// Runs in O(N log N) time for any length N, including prime numbers.
pub fn bluestein_fft(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  let n = signal.length()
  if n == 0 {
    return Err(EmptyAudio)
  }
  if n == 1 {
    return Ok([signal[0]])
  }
  if is_power_of_two(n) {
    return fft(signal)
  }

  let m = next_power_of_two(2 * n - 1)
  let two_n = 2 * n

  // Precompute chirp factors w_k = exp(-j * pi * (k^2 % 2N) / N)
  let w : Array[@types.Complex] = Array::make(n, @types.complex(0.0, 0.0))
  let w_conj : Array[@types.Complex] = Array::make(n, @types.complex(0.0, 0.0))
  for k in 0..<n {
    let k_sq = k * k % two_n
    let angle = -pi * k_sq.to_double() / n.to_double()
    let cos_a = @math.cos(angle)
    let sin_a = @math.sin(angle)
    w[k] = @types.complex(cos_a, sin_a)
    w_conj[k] = @types.complex(cos_a, -sin_a)
  }

  // Sequence a of length m: a[k] = signal[k] * w[k] for k < n, else 0
  let a : Array[@types.Complex] = Array::make(m, @types.complex(0.0, 0.0))
  for k in 0..<n {
    let s_re = signal[k].re
    let s_im = signal[k].im
    let wk_re = w[k].re
    let wk_im = w[k].im
    a[k] = @types.complex(
      s_re * wk_re - s_im * wk_im,
      s_re * wk_im + s_im * wk_re,
    )
  }

  // Sequence b of length m: b[0] = w_conj[0], b[k] = b[m - k] = w_conj[k] for k in 1..<n, else 0
  let b : Array[@types.Complex] = Array::make(m, @types.complex(0.0, 0.0))
  b[0] = w_conj[0]
  for k in 1..<n {
    b[k] = w_conj[k]
    b[m - k] = w_conj[k]
  }

  // Fast convolution via Radix-2 FFT and IFFT of length m
  let fa = match fft(a) {
    Ok(res) => res
    Err(e) => return Err(e)
  }
  let fb = match fft(b) {
    Ok(res) => res
    Err(e) => return Err(e)
  }

  let fc : Array[@types.Complex] = Array::make(m, @types.complex(0.0, 0.0))
  for i in 0..<m {
    let ar = fa[i].re
    let ai = fa[i].im
    let br = fb[i].re
    let bi = fb[i].im
    fc[i] = @types.complex(ar * br - ai * bi, ar * bi + ai * br)
  }

  let c = match ifft(fc) {
    Ok(res) => res
    Err(e) => return Err(e)
  }

  // Post-multiply by chirp factor w[k]: out[k] = c[k] * w[k]
  let out : Array[@types.Complex] = Array::make(n, @types.complex(0.0, 0.0))
  for k in 0..<n {
    let cr = c[k].re
    let ci = c[k].im
    let wr = w[k].re
    let wi = w[k].im
    out[k] = @types.complex(cr * wr - ci * wi, cr * wi + ci * wr)
  }

  Ok(out)
}

///|
/// Arbitrary-length Inverse Discrete Fourier Transform (IDFT) via Bluestein's Algorithm.
pub fn bluestein_ifft(
  spectrum : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  let n = spectrum.length()
  if n == 0 {
    return Err(EmptyAudio)
  }
  if n == 1 {
    return Ok([spectrum[0]])
  }
  if is_power_of_two(n) {
    return ifft(spectrum)
  }

  // IDFT(X) = (1/N) * conj(DFT(conj(X)))
  let conj_spec : Array[@types.Complex] = Array::make(
    n,
    @types.complex(0.0, 0.0),
  )
  for i in 0..<n {
    conj_spec[i] = @types.complex(spectrum[i].re, -spectrum[i].im)
  }

  let dft_res = match bluestein_fft(conj_spec) {
    Ok(res) => res
    Err(e) => return Err(e)
  }

  let inv_n = 1.0 / n.to_double()
  let out : Array[@types.Complex] = Array::make(n, @types.complex(0.0, 0.0))
  for i in 0..<n {
    out[i] = @types.complex(dft_res[i].re * inv_n, -dft_res[i].im * inv_n)
  }

  Ok(out)
}

///|
/// Universal Forward DFT for arbitrary-length complex sequences.
/// Dispatches to in-place Radix-2 Cooley-Tukey FFT when length is a power of 2,
/// and Bluestein's Chirp Z-Transform when length is arbitrary or prime.
pub fn dft(
  signal : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  bluestein_fft(signal)
}

///|
/// Universal Inverse DFT for arbitrary-length complex sequences.
pub fn idft(
  spectrum : Array[@types.Complex],
) -> Result[Array[@types.Complex], @types.MelError] {
  bluestein_ifft(spectrum)
}
