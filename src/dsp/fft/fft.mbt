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
  if !is_power_of_two(n_fft) {
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
  fft_in_place(re, im, n_fft, false)
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
