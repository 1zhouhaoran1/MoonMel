# MoonMel 演进路线图 (Roadmap)

[English](../en/ROADMAP.md) | [中文说明](./ROADMAP.md)

本文档规划 MoonMel 从当前 0.1.0 Hackathon MVP 版本向生产级生态基础设施演进的里程碑。

---

## 里程碑阶段规划

### Phase 1: 0.1.0 MVP (当前版本 - 2026 Hackathon)
- [x] 纯 MoonBit 原地 Radix-2 Cooley-Tukey 快速傅里叶变换。
- [x] 周期性与对称性 Hann 窗函数，支持 `center=True` 镜像反射填充。
- [x] Slaney 标度三角 Mel 滤波器组构建与面积归一化。
- [x] Log-Mel 功率转分贝压缩（支持 `amin` 与 `top_db` 保护）。
- [x] 正交归一化 DCT-II 与 MFCC 系数提取。
- [x] 纯 MoonBit PCM WAV 解码器（支持 8-bit、16-bit 及声道自动下混）。
- [x] 基于 Python `librosa 1.0.0` 的 15 项权威数值真值严格对齐测试。
- [x] 低耦合分层架构（`src/core/types`、`src/dsp/*`、`src/features/*`、`src/codec/*`）。
- [x] 交互式 Vite + TailwindCSS WebAssembly 浏览器演练场。

---

### Phase 2: 0.2.0 特征扩展与算法增强
- [x] **Delta 与 Delta-Delta 一阶/二阶差分特征**：增强语音时序动态特征建模。
- [x] **预加重高通滤波器 (Pre-emphasis / De-emphasis)**：高频补偿增强（$y[n] = x[n] - \alpha x[n-1]$）与逆滤波重建。
- [x] **帧能量与 RMS 均方根能量 (Root Mean Square Energy)**：时域与频域分帧能量抽取。
- [x] **高保真音频重采样器 (Audio Resampling)**：支持 44.1k/48k 转 16k 语音标准采样率（Sinc 抗混叠滤波与线性插值）。
- [x] **流式特征提取 (Streaming Audio)**：支持定长滑动窗口实时在线增量特征抽取（StreamingExtractor）。
- [x] **实时麦克风输入接入**：在 Playground 中接入 Web Audio API 实时录音流与动态频谱渲染。
- [x] **频域声学描述符 (Spectral Descriptors)**：谱质心 (Centroid)、谱滚降 (Rolloff)、谱平坦度 (Flatness) 与时域过零率 (ZCR)。
- [x] **多声道与多通道谱支持**：支持独立多声道特征并行抽取与空间声学特征（ILD / IPD）。

---

### Phase 3: 0.3.0 性能极限与特征扩展
- [x] **12 音级色度图特征 (Chroma STFT / Chromagram)**：支持音高类特征抽取、高斯滤波器组与多样化时间帧归一化（L1 / L2 / Max）。
- [x] **任意长度 FFT 零填充扩展 (Padded FFT / RFFT)**：消除对输入序列必须为 $2^k$ 的严格限制。
- [ ] **WebAssembly SIMD 向量化加速**：针对蝶形运算和三角滤波投影进行 128 位 SIMD 原语优化。
- [x] **任意长度 Bluestein 算法**：基于快速卷积的任意素数长度离散傅里叶变换。
- [x] **常量 Q 变换 (Constant-Q Transform / CQT)**：对数几何频带抽取，恒定品质因数 $Q$ 分辨率。
- [x] **多采样率多相重采样器 (Polyphase Resampler)**：预计算多相 FIR 滤波组，支持任意有理倍率（scipy.signal.resample_poly 对齐）。
- [x] **谐波-冲击成分分离 (HPSS)**：二维中值滤波与软/硬掩蔽分离音频谐波与打击乐分量，计算帧能量比。
- [x] **广播级响度计量 (ITU-R BS.1770-4 / EBU R128)**：级联 K-weighting IIR 滤波、门限积分响度 (LUFS)、响度范围 (LRA) 与 4 倍过采样 True-Peak 真实峰值估计。
- [x] **音符起始检测与起始强度包络 (Onset Detection & SuperFlux)**：谱通量 (Spectral Flux)、频域极值滤波抗颤音 (SuperFlux) 与自适应双门限峰值拾取。
- [x] **线性预测编码与倒谱系数 (LPC & LPCC)**：Levinson-Durbin 递归求解全极点滤波器、反射系数 (PARCOR)、逆滤波预测残差与线性预测倒谱。
- [x] **基频提取与音高追踪 (Pitch Tracking / YIN)**：差分函数、累积平均归一化差分函数 (CMNDF)、绝对阈值与抛物线亚采样插值。
- [x] **节奏图与速度估计 (Tempogram & Tempo Estimation)**：局部自相关节奏图矩阵、对数正态先验加权与全局 BPM 速度估计。
- [x] **八度谱对比度特征 (Octave Spectral Contrast)**：多子带峰谷分位数差值估计，音乐音色与纹理表征。

---

### Phase 4: 1.0.0 生产级生态发布
- [ ] 发布到 Mooncakes 官方包管理器中心。
- [ ] 提供与 ONNX Runtime Web / Transformers.js 的特征输入适配器。
- [ ] 针对常见开源语音识别模型（Whisper、Wav2Vec2、Conformer）提供标准化前端特征抽取流水线。
