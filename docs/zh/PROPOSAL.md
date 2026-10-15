# MoonMel 项目提案与工程选择

[English](../en/PROPOSAL.md)

## 问题与范围

音频可视化、语音分析、声音分类器需要频谱或倒谱特征。[librosa](https://librosa.org/doc/main/api/generated/librosa.feature.mfcc.html)、[Meyda](https://meyda.js.org/audio-features)、[Essentia.js](https://mtg.github.io/essentia.js/) 已为这类问题提供成熟参考。

MoonMel 用 MoonBit 实现限定范围内的 PCM 到 STFT、Mel、Log-Mel、MFCC 路径，价值在于通过 MoonBit 包和目标集成，并提供可检查的数值验证。本提案不证明 MoonBit 生态没有其他方案，也不证明 MoonMel 性能优于其他项目。

## 工程选择

| 决策 | 原因与边界 |
| --- | --- |
| 用 MoonBit 实现 DSP 算法 | 通过常规 MoonBit API 支持各编译目标，不依赖外部 DSP 库；不代表没有工具链或浏览器桥接依赖 |
| 使用分层包 | 分离核心类型、DSP、编解码、特征阶段、编排、门面及浏览器传输；通过架构检查器约束依赖方向 |
| 复用中间结果 | `analyze` 共享 STFT 和滤波器组，在已有实现处复用数值缓冲，不宣称零分配 |
| 分离参考工具 | Python 库用于开发时比较，不参与正式特征提取路径 |

仓库采用 MIT 许可证，参考来源及分发资产记录在[第三方声明](../../THIRD_PARTY_NOTICES_zh.md)。依赖选择无需建立在未经核实的竞品性能或许可义务结论之上。

## 数值参考

当前[报告](../../tools/reference/parity_report.json)记录八组确定性核心案例，对照 librosa 1.0.0、NumPy 2.5.3、SciPy 1.18.1。参数显式对齐周期 Hann、reflect 填充、float64 Slaney 滤波器及正交 DCT-II。是否居中由各案例指定；仅设置 `center=true` 不会让 librosa 自动选择 reflect 填充。

检查器覆盖全部 Mel/Log-Mel/MFCC 单元及每帧最多 64 个明确索引的 STFT 频点，`atol=rtol=1e-7`。这不认证所有配置、高级算法、模型前端或竞品速度。

## 仍需补充的证据

最小示例和浏览器演示展示可复用的特征能力。基于维护者实际需求的独立下游示例仍待补充。性能和高级算法声明需在提供可复现测量或外部测试套件后再升级。

当前实现及发布边界以[产品说明](PRODUCT.md)、[健康报告](HEALTH.md)和[路线图](ROADMAP.md)为准。
