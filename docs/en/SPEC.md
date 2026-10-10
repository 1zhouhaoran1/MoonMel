# MoonMel Formal Technical Specification

[English](./SPEC.md) | [中文说明](../zh/SPEC.md)

This document defines the mathematical foundations, discretization strategies, matrix dimension invariants, and numerical safeguards of MoonMel.

---

## 1. Signal Representation & Boundary Handling

### 1.1 Discrete Input Model
A continuous acoustic signal $x(t)$ sampled at frequency $f_s$ yields a discrete real sequence:
$$x[n] \in [-1.0, 1.0], \quad n = 0, 1, \dots, L - 1$$

### 1.2 Boundary Reflect Padding
When centered framing is enabled ($\text{center} = \text{true}$), the sequence is padded with $P = \lfloor N_{\text{fft}} / 2 \rfloor$ points on both sides:
$$x_{\text{pad}}[i] = x[\text{reflect}(i - P, L)], \quad i = 0, \dots, L + 2P - 1$$
The reflection function maps out-of-bounds indices without duplicating boundaries:
$$\text{reflect}(k, L) = \begin{cases} -k, & k < 0 \\ 2(L - 1) - k, & k \ge L \\ k, & 0 \le k < L \end{cases}$$

---

## 2. Short-Time Fourier Transform (STFT)

### 2.1 Periodic Hann Window
The discrete Periodic Hann window of length $N$ is defined as:
$$w[n] = 0.5 - 0.5 \cos\left( \frac{2\pi n}{N} \right), \quad n = 0, \dots, N - 1$$
The denominator $N$ (unlike $N - 1$ in symmetric windows) preserves perfect overlap-add (OLA) constant reconstruction properties.

### 2.2 Discrete Fourier Transform & Framing
For frame index $m$ (starting sample $s_m = m \cdot H$, where $H$ is `hop_length`):
$$X[m, k] = \sum_{n=0}^{N-1} x_{\text{pad}}[s_m + n] \cdot w[n] \cdot e^{-j \frac{2\pi k n}{N}}$$
Real inputs produce conjugate symmetry $X[m, N-k] = X^*[m, k]$; hence, only the one-sided positive frequency spectrum is retained:
$$k \in \left[0, \frac{N}{2}\right], \quad K = \frac{N}{2} + 1 \quad \text{frequency bins}$$

### 2.3 Power Spectrogram
$$S[m, k] = |X[m, k]|^2 = \text{Re}(X[m, k])^2 + \text{Im}(X[m, k])^2$$

---

## 3. Mel Filterbank Construction (Slaney Scale)

### 3.1 Hertz to Mel Conversion
Using the Slaney / Auditory Toolbox piecewise definition:
- **Linear segment** ($f < 1000\text{ Hz}$):
  $$\text{Mel}(f) = \frac{3f}{200}$$
- **Logarithmic segment** ($f \ge 1000\text{ Hz}$):
  $$\text{Mel}(f) = 15.0 + \frac{27.0}{\ln(6.4)} \cdot \ln\left( \frac{f}{1000.0} \right)$$

Inverse formula:
$$f(\text{mel}) = \begin{cases} \frac{200}{3} \cdot \text{mel}, & \text{mel} < 15.0 \\ 1000.0 \cdot \exp\left( \frac{\ln(6.4)}{27.0} \cdot (\text{mel} - 15.0) \right), & \text{mel} \ge 15.0 \end{cases}$$

### 3.2 Triangular Filters & Area Normalization
$M + 2$ control points $m_i$ are linearly spaced in Mel space, transforming to physical corner frequencies $f_i$.
For filter $i$ (center $f_{i+1}$, left $f_i$, right $f_{i+2}$):
$$H_i(f) = \begin{cases} 
\frac{f - f_i}{f_{i+1} - f_i}, & f_i \le f \le f_{i+1} \\
\frac{f_{i+2} - f}{f_{i+2} - f_{i+1}}, & f_{i+1} \le f \le f_{i+2} \\
0, & \text{otherwise}
\end{cases}$$
Slaney area normalization factor:
$$H_i^{\text{norm}}(f) = H_i(f) \cdot \frac{2.0}{f_{i+2} - f_i}$$

### 3.3 Mel Spectrogram Projection
$$\text{MelSpec}[m, i] = \sum_{k=0}^{K-1} H_i^{\text{norm}}(f_k) \cdot S[m, k]$$

---

## 4. Power-to-dB Conversion

$$\text{dB}[m, i] = 10 \log_{10}\left( \frac{\max(\text{MelSpec}[m, i], \epsilon)}{\max(P_{\text{ref}}, \epsilon)} \right)$$
Dynamic range is clamped via `top_db`:
$$\text{cutoff} = \max_{m, i}(\text{dB}[m, i]) - \text{top\_db}$$
$$\text{LogMel}[m, i] = \max(\text{dB}[m, i], \text{cutoff})$$

---

## 5. Discrete Cosine Transform & MFCC

### 5.1 DCT-II Orthogonal Formulation
$$\text{MFCC}[m, c] = w(c) \sum_{n=0}^{M-1} Y[n] \cos\left( \frac{\pi c (2n + 1)}{2M} \right), \quad c = 0, \dots, C - 1$$
Orthonormal weights:
$$w(0) = \sqrt{\frac{1}{M}}, \quad w(c) = \sqrt{\frac{2}{M}} \quad (c > 0)$$
保证基底向量正交并保持欧氏范数不变。
