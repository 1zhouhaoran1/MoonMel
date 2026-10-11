# 架构

[English](../en/ARCHITECTURE.md)

## 层次与依赖

核心类型 → DSP/编解码 → 特征 → 流水线 → 门面 → 根模块与浏览器绑定 → 演示页。`node tools/quality/check-architecture.mjs` 自动拒绝循环与向上依赖；核心类型不引用项目内部包，同层特征允许按需求互相依赖。

| 层 | 责任 | 边界 |
| --- | --- | --- |
| core/types | 错误、音频、配置、矩阵、复数分别组织 | 只持有数据与校验，不编排算法 |
| DSP/codec | 窗、分帧、FFT、STFT、滤波、重采样、WAV | 处理信号或有边界的字节输入 |
| features | Mel/MFCC 与扩展特征 | 引用 DSP 或同层、下层特征 |
| pipeline/analysis | 按顺序编排四类特征 | 只计算一次 STFT 与滤波器组 |
| facade/bindings | 易用适配、公开重导出、JSON 传输 | 不复制 DSP 算法 |

## 共享计算

`AnalysisResult` 包含 STFT、滤波器组、Mel、Log-Mel、MFCC。独立接口保留；矩阵阶段提供滤波器投影、已有谱转 Mel、Mel 转对数、对数 Mel 转 MFCC。每个矩阵只生成一次 DCT 基，而非每帧重算。

`framing.window_frame` 将短窗居中到完整 FFT 帧，窗口位置与取样位置使用同一偏移。离线、流式共用。STFT 复用实部、虚部缓冲；非 2 的幂使用 Bluestein 并分配临时数组。低层 Radix-2 内核仍要求尺寸为 2 的幂且缓冲足够。

## 数据与错误

矩阵使用可变行数组和显式维度。阶段边界的 `validate()` 检查维度与不等长行；`at`、`set` 等低层操作要求调用者保证索引有效。高层使用 `Result`；配置验证窗口尺寸、正数维度、有限数值与频率范围。浏览器错误返回 `success:false`，字符串经过 JSON 转义。

WAV 必须满足声明的 RIFF 边界和各个数据块边界；校验格式、块对齐及完整 PCM 帧。有符号表示为负数的恶意无符号长度被拒绝。允许 data 在 fmt 前，拒绝重复的 data/fmt。

## 流式约定

只处理左对齐的完整 FFT 帧，忽略 `config.center`；不模拟离线反射边界，也不自动刷新不足一帧的尾部。缓冲游标保留大步长跨块间隔。FFT、窗、滤波器组复用，输出、缓冲增长/整理、Bluestein 仍会分配。MFCC 遵循对数、参考值及 DCT 配置；`top_db` 按每次输出矩阵裁剪，不能宣称分批结果与整段离线全局裁剪完全相同。

## 浏览器结构

`domain/signals` 管合成信号与限制，`engine` 管请求、Worker 与绑定，`audio` 管播放及 AudioWorklet，`render` 管图形与证据，`main` 管 DOM 协调。输入加载标识与分析版本分离，修改参数不会丢弃正在解码的 WAV；上传音频采样率不会被合成参数重解释。

编译 JS 被忽略并在启动/构建前自动生成。页面明确运行 JS。麦克风属于节流后的滚动离线预览，并非增量流式 API 展示。

浏览器绑定只声明 JS/WASM/WASM-GC，Native 构建不再将浏览器外部库误链接为可执行文件；核心库和示例仍支持 Native。
