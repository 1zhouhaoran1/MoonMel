# MoonMel 产品规格说明书

[English](../en/PRODUCT.md) | [中文说明](./PRODUCT.md)

本文档定义 MoonMel（2026 MoonBit Hackathon）的产品定位、核心价值、目标平台、验收边界与非目标。

---

## 1. 产品定位与核心价值

MoonMel 是一个基于 MoonBit 的轻量级、跨平台音频特征提取引擎，将 PCM 单声道音频信号转换为用于语音识别、声音分类及音频机器学习的基础特征（STFT 功率谱、Slaney Mel 频谱图、Log-Mel 频谱图及 MFCC 倒谱系数）。

### 核心价值主张

1. **填补生态空白**：为 MoonBit 生态提供生产级音频数字信号处理（DSP）标准库。
2. **边缘与浏览器端可用**：通过 WebAssembly（WASM）在浏览器端本地完成音频特征计算，零网络延迟，零隐私泄露风险。
3. **确定性与科学验证**：核心数学逻辑经过 Python 科学计算栈（librosa, NumPy, SciPy）严格数值对齐，误差受控在浮点精度阈值内。
4. **统一简洁 API**：提供符合 MoonBit 惯用风格的高层门面接口与细粒度分层子包。

---

## 2. 目标平台与运行环境

- **WebAssembly (WASM)**：浏览器 WebAssembly 运行环境及 Node.js / Wasmtime。
- **JavaScript (JS)**：生成干净的 ES 模块（ESM），无缝集成 Web 前端项目。
- **Native**：C / 原生机器码目标。

---

## 3. 核心能力矩阵

| 模块 | 能力范围 | 算法约定 |
| :--- | :--- | :--- |
| **时域处理** | PCM 数据模型、分帧提取、窗函数、反射填充 | 支持 Periodic Hann、Symmetric Hann、Hamming、Blackman；`center=True` 镜像反射填充 |
| **频谱分析** | 短时傅里叶变换（STFT）、单边功率谱 | 原地 Radix-2 Cooley-Tukey FFT，输出前 $N/2 + 1$ 个频率分量 |
| **Mel 滤波器组** | Slaney 标度与 HTK 标度三角滤波器组 | 支持 Slaney 面积归一化，1 kHz 以下线性、1 kHz 以上对数 |
| **对数压缩** | Log-Mel 频谱图提取 | 支持分贝转换（dB，基于 `amin` 与 `top_db` 截断）、自然对数及常用对数 |
| **倒谱提取** | MFCC 提取 | DCT-II 正交归一化（`norm='ortho'`） |
| **音频编解码** | WAV 音频解析 | 纯 MoonBit 实现的 RIFF 8-bit / 16-bit PCM 解码，多声道自动下混单声道 |

---

## 4. 质量与验收标准

1. **零外部 C 库依赖**：100% 纯 MoonBit 实现，保证跨平台编译一致性。
2. **数值对齐**：STFT 与 MFCC 特征输出与 `librosa 1.0.0` 最大绝对误差低于 0.05。
3. **真实端到端演示**：Playground 页面必须直接调用 MoonBit 编译目标，严禁用 JavaScript 重写伪造算法。
4. **性能基准**：处理 1 秒 16 kHz 音频在现代浏览器或 Native 环境下处理耗时在数十毫秒以内。

---

## 5. 非目标 (Out of Scope)

本项目在 MVP 阶段明确不包含以下内容：
- 不实现完整的端到端语音识别（ASR）深度学习模型推理（如 Whisper 解码器）。
- 不提供音频重采样与有损音频编解码器（MP3、AAC、Opus）。
- 不依赖外部云端 AI API。
