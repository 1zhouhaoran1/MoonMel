///|
/// Complex represents a 2D complex number with Double precision.
pub(all) struct Complex {
  re : Double
  im : Double
} derive(Eq, Debug)

///|
/// Create complex number.
pub fn complex(re : Double, im : Double) -> Complex {
  { re, im, }
}

///|
/// Complex addition.
pub fn Complex::add(self : Complex, other : Complex) -> Complex {
  { re: self.re + other.re, im: self.im + other.im, }
}

///|
/// Complex subtraction.
pub fn Complex::sub(self : Complex, other : Complex) -> Complex {
  { re: self.re - other.re, im: self.im - other.im, }
}

///|
/// Complex multiplication.
pub fn Complex::mul(self : Complex, other : Complex) -> Complex {
  {
    re: self.re * other.re - self.im * other.im,
    im: self.re * other.im + self.im * other.re,
  }
}

///|
/// Squared magnitude |z|^2 = re^2 + im^2.
pub fn Complex::abs2(self : Complex) -> Double {
  self.re * self.re + self.im * self.im
}

///|
/// Magnitude |z| = sqrt(re^2 + im^2).
pub fn Complex::abs(self : Complex) -> Double {
  (self.re * self.re + self.im * self.im).sqrt()
}

///|
/// Complex division self / other.
pub fn Complex::div(self : Complex, other : Complex) -> Complex {
  let denom = other.re * other.re + other.im * other.im
  if denom == 0.0 {
    { re: 0.0, im: 0.0, }
  } else {
    {
      re: (self.re * other.re + self.im * other.im) / denom,
      im: (self.im * other.re - self.re * other.im) / denom,
    }
  }
}

///|
pub extend Complex with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Complex with Eq::{not_equal, equal}
