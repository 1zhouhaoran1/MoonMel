# MoonMel 项目申报书

[English](../en/PROPOSAL.md)

## 基本信息

- 项目名称：MoonMel
- 参赛者及联系方式：周皓然（zhr），3449002191@qq.com
- GitHub 仓库链接：https://github.com/1zhouhaoran1/MoonMel
- 项目方向：MoonBit 音频特征提取、增量分析与频谱变换基础库
- 是否为移植项目：基于经典 DSP 算法的 MoonBit 实现与工程适配；算法参考、同生态重叠及具体实现差异见下文

## 项目简介

MoonMel 是面向 MoonBit 的音频分析库。基础部分提供 PCM WAV 解码和 STFT、Mel、Log-Mel、MFCC 提取；在此之外，已经实现维护跨块状态的增量提取器、保留相位的复数 STFT 与 ISTFT、基于相位声码器的变速/变调、带抗混叠滤波的重采样，以及保留声道关系的 ILD/IPD 分析。算法主体由 MoonBit 实现，通过分层包和统一门面供 JS、WASM/WASM-GC、Native 目标使用。

本项目承认已有 MoonBit 库 `moon-certified` 覆盖了 WAV、分帧、功率谱、Mel、MFCC、Delta 和线性重采样。此次补充申报不以 Slaney 刻度、归一化、参数默认值或边界兼容作为独立项目范围的主要依据，而是说明上述增量处理、帧级分析与重建、抗混叠重采样和多声道分析的实际实现、使用场景与验证边界。项目不申报原创 DSP 算法，也不宣称全库数值等价、生产认证或性能领先。

## 核心功能范围

- **共享特征流水线**：提供可配置 STFT、Slaney/HTK Mel、Log-Mel 和 DCT-II MFCC；`analyze` 复用一次 STFT 和滤波器组生成多种输出。这部分与已有生态存在重叠，是兼容和集成基础，不单独作为独立性论据；
- **增量提取与状态管理**：`StreamingExtractor` 提供 push、就绪帧查询、Mel/MFCC 消费和 reset；保留跨块样本、重叠窗口及大步长间隔，预计算窗和滤波器组，复用 FFT 缓冲。输出矩阵与部分路径仍会分配，不承诺零 GC 或硬实时；
- **保留相位的帧级分析与重建**：提供复数 STFT、ISTFT 和逐帧重叠相加，支持 Radix-2 与 Bluestein 任意长度变换；在此基础上提供相位声码器、变速与变调。可从特征分析延伸到波形变换，重建依赖窗口、步长和有效覆盖条件，不承诺任意配置无损；
- **抗混叠重采样**：在线性插值之外实现窗化 sinc、有理倍率多相 FIR 和指定输出长度路径，下采样时按倍率调整低通截止及滤波范围。当前接口处理整段数组，不是有状态跨块重采样器，也不宣称与 SciPy 默认滤波器等价；
- **多声道及幅相关系分析**：除算术下混外，提供逐声道 STFT/Mel/MFCC、以功率比计算的 ILD 和基于复数互谱计算的 IPD，保留声道间可分析关系；不将这些特征直接解释为声源方位、距离或完整波束形成系统。

仓库还包含 Chroma、直接 CQT、HPSS、LPC/LPCC、YIN、共振峰、起音/节奏、谱对比及响度等扩展。它们作为已有模块公开，但本次独立范围说明不依赖算法数量，也不将其单元测试等同于完整外部认证。

## 预期使用场景

1. **持续到达音频的增量特征消费**：MoonBit 应用分批输入样本，提取已经就绪的完整帧，并保留下一批所需的样本与窗口位置；适用于不希望每批重新分析全部历史音频的集成场景。浏览器麦克风演示目前使用滚动离线窗口，不冒充该增量接口的下游应用。
2. **离线音频分析及波形变换工具**：按目标采样率进行抗混叠重采样，检查复数频谱，在满足重建条件时通过 ISTFT 回到波形，或调用变速/变调接口。已有合成信号和回归验证，感知音质及实际工具接入仍需补充。
3. **双声道或多通道音频关系检查**：保留各声道特征，计算相同、幅度缩放及同相输入的 ILD/IPD，用于声道一致性和幅相差异分析。已有对应测试，尚未提供真实麦克风阵列标定或独立业务采用案例。

以上为目标用途，不表示已有生产用户。当前可直接运行的交付是库、最小示例、测试及浏览器演示。

## 移植或参考说明

### 算法与工程参考

FFT/Bluestein、STFT/ISTFT、Mel、DCT-II、窗化 sinc、多相滤波和相位声码器均为已有技术，不申报为原创算法。工程及数值参考包括 [librosa](https://github.com/librosa/librosa)、[Meyda](https://meyda.js.org/audio-features) 和 [Essentia.js](https://github.com/MTG/essentia.js)。项目采用 [MIT](../../LICENSE)，参考来源及分发资产见[第三方声明](../../THIRD_PARTY_NOTICES_zh.md)；运行时不链接这些项目的 DSP 实现。

### 同生态对照与具体差异

同生态对照为 [Juwan-Hwang/moon-certified](https://github.com/Juwan-Hwang/moon-certified/tree/94dd850ce24db5610e720035d5bdb1ecb2923e43)。以下核查固定在提交 `94dd850ce24db5610e720035d5bdb1ecb2923e43`，依据其[音频特征源码](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/audio_processing/features/features.mbt)、[通用 FFT](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/math/fft/fft.mbt)、[滤波设计](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/signal_processing/filter_design/filter_design.mbt)和 [WAV 模块](https://github.com/Juwan-Hwang/moon-certified/blob/94dd850ce24db5610e720035d5bdb1ecb2923e43/audio_processing/wav/wav.mbt)，不只比较 README。

| 比较范围 | 对照库已有能力 | MoonMel 已实现部分及可检查证据 |
| --- | --- | --- |
| 基础链路 | WAV、分帧、功率谱、HTK Mel、MFCC、Delta、线性重采样 | 承认核心重叠；Slaney、归一化和边界兼容不单独作为实质范围依据 |
| 增量处理 | 音频特征接口接收整段数组并构建帧序列；所核查接口未提供对应的持久化音频提取器 | [提取器源码](../../src/features/streaming/streaming.mbt)维护样本与消费游标，保留重叠和跨块间隔；[测试](../../src/features/streaming/streaming_test.mbt)及[回归](../../src/features/streaming/regression_test.mbt)覆盖小块输入帧数、短窗、任意 FFT 和大步长间隔 |
| 分析与重建 | 已有通用正/逆 FFT 和窗函数；音频特征包主要输出功率与倒谱 | [复数 STFT/ISTFT](../../src/dsp/stft/stft.mbt)实现帧级相位保留与波形合成，[效果模块](../../src/features/effects/effects.mbt)实现相位声码器；有[重建](../../src/dsp/stft/stft_wbtest.mbt)、[奇数 FFT](../../src/dsp/stft/regression_wbtest.mbt)及[相位推进回归](../../src/features/effects/regression_test.mbt) |
| 重采样 | 音频特征包提供线性插值；另有独立 FIR/IIR 滤波设计 | [重采样源码](../../src/dsp/resample/resample.mbt)集成下采样低通、窗化 sinc 和多相分数相位处理；[测试](../../src/dsp/resample/resample_test.mbt)覆盖 48 kHz/16 kHz 正弦及长度，[回归](../../src/dsp/resample/regression_test.mbt)检查分数相位 |
| 多声道分析 | WAV 保留交错声道并支持下混；所核查音频特征包未提供对应 ILD/IPD 接口 | [多声道源码](../../src/features/multichannel/multichannel.mbt)保留逐声道特征并计算功率比、复数互谱相位；[测试](../../src/features/multichannel/multichannel_test.mbt)及[回归](../../src/features/multichannel/regression_test.mbt)覆盖同相、静音、幅度比及异常元数据 |

这些差异描述现成接口及执行状态，不表示对方库不能通过进一步开发组合出相似功能。对方已有通用 FFT、滤波设计、Welch 功率谱和小波模块，WAV 支持的编码/位深也比本项目更广；MoonMel 当前 WAV 仅解码 8/16 位 PCM，不把容器解码作为优势。

## 适用边界与已有证据

- **可复现工程验证**：源码提交 `457f9bf78904bc4b45d67c5c41e8aeae0883111c` 的 [CI 记录](https://github.com/1zhouhaoran1/MoonMel/actions/runs/39132207959)包含 WASM、WASM-GC、JS 各 147 项测试，Native 145 项测试及 5 项浏览器绑定测试，均通过；Native 排除两个浏览器绑定包内测试。测试数量说明当前工程验证范围，不作为独立性的证明；
- **限定数值对齐**：[八组报告](../../tools/reference/parity_report.json)由[检查脚本](../../tools/reference/check_parity.py)生成，对齐周期 Hann、reflect、float64 Slaney 及正交 DCT-II；比较全部 Mel/Log-Mel/MFCC 单元及每帧最多 64 个明确索引的 STFT 频点，`atol=rtol=1e-7`，已记录最大绝对误差约 `2.3e-12`。该报告不覆盖流式、效果、多声道或重采样的完整外部对照；
- **直接运行与展示**：`moon run examples/basic --target js` 输出 `STFT 513×63 / Mel 80×63 / Log-Mel 80×63 / MFCC 13×63`；[在线演示](https://1zhouhaoran1.github.io/MoonMel/)使用 MoonBit 生成的 JS，在 Worker 中分析合成信号或上传的 PCM WAV，支持检查数值及导出。当前网页不演示所有扩展，不将 JS 执行说成 WASM 执行；
- **仍待补充**：未提供与 `moon-certified` 的直接性能比较、真实独立下游采用或完整高级算法外部认证。流式只输出左对齐完整帧，不自动刷新不足一帧的尾部，不附带时间戳；分批 dB 截断与全局离线截断可能不同，未证明所有随机分块的 MFCC 全矩阵等价；
- **申报边界**：不承诺固定毫秒延迟、零分配、硬实时、完整 Whisper 前端或广播响度规范合规；模块已发布到 mooncakes.io。源码、示例、接口及测试可独立检查，许可证为 MIT。

本次复审申请依据以上已经实现的增量分析、帧级重建、抗混叠重采样和多声道分析范围，请求结合具体源码及验证重新评估项目的独立交付内容。未实现或尚未充分验证的能力不列为已完成成果。
