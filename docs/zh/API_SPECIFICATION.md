# 公开 API

[English](../en/API_SPECIFICATION.md)

完整签名以 `moon info` 生成的 [根接口](../../pkg.generated.mbti)、[门面接口](../../src/facade/pkg.generated.mbti) 及各包 `pkg.generated.mbti` 为准。根模块重导出门面，不持有 DSP 算法。

## 核心提取

| 接口 | 输入与输出 |
| --- | --- |
| `FeatureConfig::default()` | 16 kHz、1024 FFT/窗、256 步长、80 Mel、13 MFCC、周期 Hann、reflect 居中、功率 2、Slaney、dB、正交 DCT |
| `analyze(samples, config?)` | 共享 STFT、滤波器、Mel、Log-Mel、MFCC 的 Result |
| `stft`、`stft_complex` | 实数特征矩阵或单边复数帧 |
| `mel_filterbank`、`mel_spectrogram` | 三角滤波器组或 Mel 特征 |
| `log_mel_spectrogram`、`mfcc` | 按配置对数压缩或倒谱系数 |
| `decode_wav(bytes)` | 8/16 位 PCM，算术平均混合为单声道 |
| `create_streaming_extractor` | 复用状态，处理左对齐完整帧 |

`AudioBuffer::new` 构建验证过的音频。没有 `AudioBuffer::mfcc()`、`AudioBuffer::from_wav_bytes()`；使用上述函数。改变采样率时同步更新 `sample_rate` 与 `f_max`。Whisper 尺寸预设不等于完整模型归一化前端。

## 形状与校验

特征矩阵 `[行][列]` 的行为特征/频率，列为时间。STFT 频点为 `n_fft/2+1`；奇数 FFT 的最后频点低于 Nyquist。复数帧 `[时间][频点]`。矩阵 `validate()` 检查公开可变的形状，低层访问要求索引有效。

高层转换校验配置与有限 PCM。窗口在 `[1,n_fft]`，频率有限且位于 `[0,sr/2]`，各维度和步长为正，power/amin/ref_value 为有限正数，top_db 为有限非负数。`fft/ifft` 限 2 的幂；`dft/idft`、STFT 支持任意正尺寸。原始 `fft_in_place` 有明确前置条件，不确定输入使用检查过的调度器。

## 阶段复用

直接导入特征包，可使用已有谱转 Mel、复用滤波器、Mel 转对数、Log-Mel 转 MFCC。阶段校验形状并避免重复 STFT。通常使用 `analyze` 取得四种核心输出及实际滤波器组。

## 流式

push、available、pop、reset 按左对齐时间线工作，即使 `center=true`。pop 会消费帧，先取 Mel 再取 MFCC 不会重复返回已消费帧。尾部不足帧不会自动补齐。大步长跨块间隔被保留。对数、DCT 配置有效；top_db 每批矩阵独立裁剪，不能宣称分批 MFCC 等于整段离线全局裁剪。

## 扩展功能

频谱描述、能量/RMS、差分、Chroma、CQT、HPSS、多声道、起音、LPC/LPCC、YIN、节奏、对比、响度、效果处理仍公开。精确标签和类型见各包接口。差分为重复 HTK 回归及最近边界，CQT 为直接核相关，频谱描述遵循配置功率，对比使用经验分位数，响度保留有限静音哨兵且未通过完整规范认证。跨库等价性应先查健康报告。

## 浏览器传输

web 绑定导出音频分析、显式配置分析、WAV 分析与 WAV 解码函数。返回实际矩阵、滤波器组与 STFT 预览索引。成功标识反映真实结果，错误字符串经过 JSON 转义。WASM 可构建，当前演示明确使用 JS。文件/预览限制属于 UI 域，不改变库 API。

浏览器绑定只声明 JS/WASM/WASM-GC，Native 构建不再将浏览器外部库误链接为可执行文件；核心库和示例仍支持 Native。
