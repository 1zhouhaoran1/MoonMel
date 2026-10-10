# MoonMel 形式化技术规格说明书 (Specification)

[English](../en/SPEC.md) | [中文说明](./SPEC.md)

本文档定义 MoonMel 音频特征提取库的数学理论模型、连续公式离散化方案、矩阵形状约定及数值稳定性控制规则。

---

## 1. 信号表示与预处理

### 1.1 输入信号定义
连续音频信号 $x(t)$ 经理想周期采样（采样率 $f_s$）转化为离散实数序列：
$$x[n] \in [-1.0, 1.0], \quad n = 0, 1, \dots, L - 1$$

### 1.2 反射填充 (Reflect Padding)
当配置中心对齐模式（$\text{center} = \text{true}$）时，信号两端各扩充 $P = \lfloor N_{\text{fft}} / 2 \rfloor$ 个采样点：
$$x_{\text{pad}}[i] = x[\text{reflect}(i - P, L)], \quad i = 0, \dots, L + 2P - 1$$
其中反射索引映射函数满足无边界重复的折叠不变式：
$$\text{reflect}(k, L) = \begin{cases} -k, & k < 0 \\ 2(L - 1) - k, & k \ge L \\ k, & 0 \le k < L \end{cases}$$

---

## 2. 短时傅里叶变换 (STFT)

### 2.1 周期性 Hann 窗 (Periodic Hann Window)
离散长度为 $N$ 的周期性 Hann 窗函数定义为：
$$w[n] = 0.5 - 0.5 \cos\left( \frac{2\pi n}{N} \right), \quad n = 0, \dots, N - 1$$
注意：分母为 $N$ 而非对称窗的 $N - 1$，以精确匹配连续卷积的完备性与重叠相加（OLA）常数重构条件。

### 2.2 分帧与离散傅里叶变换
对于第 $m$ 帧（起始采样点 $s_m = m \cdot H$，其中 $H$ 为帧移 `hop_length`）：
$$X[m, k] = \sum_{n=0}^{N-1} x_{\text{pad}}[s_m + n] \cdot w[n] \cdot e^{-j \frac{2\pi k n}{N}}$$
对实数输入信号，频域满足共轭对称性 $X[m, N-k] = X^*[m, k]$，仅保留单边非负频率分量：
$$k \in \left[0, \frac{N}{2}\right], \quad \text{频带数} \quad K = \frac{N}{2} + 1$$

### 2.3 功率谱 (Power Spectrogram)
$$S[m, k] = |X[m, k]|^2 = \text{Re}(X[m, k])^2 + \text{Im}(X[m, k])^2$$

---

## 3. Mel 滤波器组构建 (Slaney Mel Scale)

### 3.1 频率与 Mel 刻度双向映射
采用 Slaney / Auditory Toolbox 标准分段函数：
- **线性区**（$f < 1000\text{ Hz}$）：
  $$\text{Mel}(f) = \frac{f}{66.6667} = \frac{3f}{200}$$
- **对数区**（$f \ge 1000\text{ Hz}$）：
  $$\text{Mel}(f) = 15.0 + \frac{27.0}{\ln(6.4)} \cdot \ln\left( \frac{f}{1000.0} \right)$$

反变换公式：
$$f(\text{mel}) = \begin{cases} \frac{200}{3} \cdot \text{mel}, & \text{mel} < 15.0 \\ 1000.0 \cdot \exp\left( \frac{\ln(6.4)}{27.0} \cdot (\text{mel} - 15.0) \right), & \text{mel} \ge 15.0 \end{cases}$$

### 3.2 三角滤波器组与面积归一化
在 Mel 空间取 $M$ 个滤波器对应的 $M + 2$ 个等距控制点 $m_i$（$i = 0, \dots, M+1$），反变换得到物理频率中心点 $f_i$。
对于第 $i$ 个滤波器（中心频率 $f_{i+1}$，左侧截止 $f_i$，右侧截止 $f_{i+2}$）：
$$H_i(f) = \begin{cases} 
\frac{f - f_i}{f_{i+1} - f_i}, & f_i \le f \le f_{i+1} \\
\frac{f_{i+2} - f}{f_{i+2} - f_{i+1}}, & f_{i+1} \le f \le f_{i+2} \\
0, & \text{其他}
\end{cases}$$
Slaney 面积归一化权重系数：
$$H_i^{\text{norm}}(f) = H_i(f) \cdot \frac{2.0}{f_{i+2} - f_i}$$

### 3.3 Mel 频谱图计算
$$\text{MelSpec}[m, i] = \sum_{k=0}^{K-1} H_i^{\text{norm}}(f_k) \cdot S[m, k]$$

---

## 4. 对数能量与分贝转换

### 4.1 功率转分贝 (Power to dB)
$$\text{dB}[m, i] = 10 \log_{10}\left( \frac{\max(\text{MelSpec}[m, i], \epsilon)}{\max(P_{\text{ref}}, \epsilon)} \right)$$
其中 $\epsilon = 10^{-10}$ 为浮点保护下界。
动态范围由 `top_db` 截断保护：
$$\text{cutoff} = \max_{m, i}(\text{dB}[m, i]) - \text{top\_db}$$
$$\text{LogMel}[m, i] = \max(\text{dB}[m, i], \text{cutoff})$$

---

## 5. 离散余弦变换与 MFCC

### 5.1 DCT-II 正交归一化 (Orthogonal DCT-II)
对每帧对数 Mel 能量向量 $Y = \text{LogMel}[m, :]$（长度 $M$），提取前 $C$ 阶倒谱系数：
$$\text{MFCC}[m, c] = w(c) \sum_{n=0}^{M-1} Y[n] \cos\left( \frac{\pi c (2n + 1)}{2M} \right), \quad c = 0, \dots, C - 1$$
正交加权权重：
$$w(0) = \sqrt{\frac{1}{M}}, \quad w(c) = \sqrt{\frac{2}{M}} \quad (c > 0)$$
保证基底向量正交并保持欧氏范数不变。
