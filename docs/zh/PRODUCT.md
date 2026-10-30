# MoonMel 产品规格说明书

[English](../en/PRODUCT.md)

## 产品定位

MoonMel 是 MoonBit 原生音频特征提取库，提供可验证的 STFT、Mel、Log-Mel 与 MFCC 流水线，将已有成熟算法通过 MoonBit 包和编译目标提供给开发者。

目标读者是需要集成音频特征的 MoonBit 开发者，以及检查实现和可复现结果的黑客松评委。音频可视化、下游分类器的特征准备属于预期用途；项目不包含完整分类器或语音识别器。仓库目前展示特征提取能力，尚未提供独立下游应用采用它的证据。

## 核心价值

1. **MoonBit 集成**：DSP 算法使用 MoonBit 实现，通过统一门面和分层包提供接口。这是独立维护的库，不是官方标准库。
2. **复用计算**：`analyze` 只计算一次 STFT 和滤波器组，再派生 Mel、Log-Mel 与 MFCC 矩阵。
3. **可检查的证据**：在显式对齐参数后，用 librosa 比较确定性核心案例。高级算法另有验证边界。
4. **本地演示**：当前浏览器演示在 Web Worker 中运行 MoonBit 生成的 JavaScript，分析不需要音频上传服务。这不构成通用隐私或延迟保证。

## 编译目标与演示

| 目标 | 当前范围 |
| --- | --- |
| JS | 库的编译目标，也是当前浏览器演示实际使用的计算引擎 |
| WASM / WASM-GC | CI 覆盖的库编译目标；当前演示不运行这些产物 |
| Native | CI 覆盖的核心库及示例目标；排除浏览器传输包 |

[在线演示](https://1zhouhaoran1.github.io/MoonMel/)支持合成信号、PCM WAV 输入、参数修改、矩阵检查及 JSON/CSV 导出。麦克风通过 AudioWorklet 采集并分析滚动窗口，与库的增量流式提取器不同。

## 核心能力

| 模块 | 范围与约定 |
| --- | --- |
| 分帧 | 周期/对称 Hann、Hamming、Blackman、矩形窗；短窗居中；居中时使用 reflect 填充 |
| STFT | Radix-2 或任意长度 Bluestein 变换；单边频点数 `floor(n_fft / 2) + 1`；可配置频谱幂次 |
| Mel | Slaney/HTK 三角滤波器，可选 Slaney 面积归一化 |
| Log-Mel | dB、自然对数或 log10；可配置下限、参考值及 dB 截断 |
| MFCC | DCT-II，可配置正交归一化 |
| WAV | RIFF 8/16 位 PCM 解码，按声道算术平均混合为单声道 |

重采样、流式、频谱描述及其他已实现扩展见[路线图](ROADMAP.md)。功能可用不代表全库数值等价或标准合规。

## 证据与完成边界

1. **可复现核心**：`moon run examples/basic --target js` 分析一秒信号并输出 STFT/Mel/Log-Mel/MFCC 形状。四目标 CI 执行检查、构建、测试及示例。
2. **限定范围的参考比较**：[已记录报告](../../tools/reference/parity_report.json)对照 librosa 1.0.0、NumPy 2.5.3、SciPy 1.18.1，覆盖八组确定性案例。检查全部 Mel/Log-Mel/MFCC 单元及每帧最多 64 个明确索引的 STFT 频点；`atol=rtol=1e-7`，已记录最大绝对误差约 `2.3e-12`。
3. **明确约定**：参考比较对齐周期 Hann、reflect 填充、float64 Slaney 滤波器和正交 DCT-II。不同库的默认参数可能产生不同结果。
4. **性能边界**：没有同设备竞品跑分或固定延迟保证。页面计时包含特征计算、JSON 序列化/解析及 Worker 内准备，不含启动、跨线程传递与渲染。

核心交付范围是可复用提取 API、可运行示例/演示及可复现检查。生产适用性和高级算法合规性仍需更多证据，见[健康报告](HEALTH.md)。

## 非目标与发布状态

- 不包含完整 ASR/模型推理；Whisper 尺寸分帧预设不代表完整模型兼容前端。
- 不实现 MP3、AAC、Opus 等有损编解码器；重采样已经实现。
- 不提供云端 AI 服务，也不宣称替代整个 librosa/Meyda/Essentia.js 生态。
- 分发渠道为 mooncakes.io、源码、GitHub Release 与 Pages 演示。
