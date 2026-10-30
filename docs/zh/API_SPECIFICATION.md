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
| `decode_wav(bytes)` | 8/16/24/32 位整数 PCM，算术平均混合为单声道 |
| `decode_wav_multichannel(bytes)` | 保留文件中的声道顺序，返回多声道音频 |
| `cmvn(matrix, normalize_variance?, variance_floor?)` | 离线逐行均值及可选总体方差归一化 |
| `create_streaming_extractor` | 复用状态，处理左对齐完整帧 |

`AudioBuffer::new` 构建验证过的音频。没有 `AudioBuffer::mfcc()`、`AudioBuffer::from_wav_bytes()`；使用上述函数。改变采样率时同步更新 `sample_rate` 与 `f_max`。Whisper 尺寸预设不等于完整模型归一化前端。

## 形状与校验

特征矩阵 `[行][列]` 的行为特征/频率，列为时间。STFT 频点为 `n_fft/2+1`；奇数 FFT 的最后频点低于 Nyquist。复数帧 `[时间][频点]`。矩阵 `validate()` 检查公开可变的形状，低层访问要求索引有效。

高层转换校验配置与有限 PCM。窗口在 `[1,n_fft]`，频率有限且位于 `[0,sr/2]`，各维度和步长为正，power/amin/ref_value 为有限正数，top_db 为有限非负数。`fft/ifft` 限 2 的幂；`dft/idft`、STFT 支持任意正尺寸。原始 `fft_in_place` 有明确前置条件，不确定输入使用检查过的调度器。

## 阶段复用

直接导入特征包，可使用已有谱转 Mel、复用滤波器、Mel 转对数、Log-Mel 转 MFCC。阶段校验形状并避免重复 STFT。通常使用 `analyze` 取得四种核心输出及实际滤波器组。

## 流式

push、available、pop、reset 按左对齐时间线工作，即使 `center=true`。pop 会消费帧，先取 Mel 再取 MFCC 不会重复返回已消费帧。尾部不足帧不会自动补齐。大步长跨块间隔被保留。对数、DCT 配置有效；top_db 每批矩阵独立裁剪，不能宣称分批 MFCC 等于整段离线全局裁剪。

0.1.6 建议对用户输入使用 `try_push_samples(chunk)`：先校验整块有限性，再写入缓冲，返回 `Result[Unit, MelError]`，空块为空操作；旧 `push_samples` 仍是不检查输入的低层入口。`buffered_samples()` 返回不含待跨越步长间隔的保留样本数。`pop_features()` 返回 `Result[StreamingFeatures, MelError]`，一次消费后从共享 Mel 派生同批 `mel`、`log_mel`、`mfcc`；无完整帧时返回对应行数的零列矩阵。

`FeatureMatrix::concat_frames(batches)` 沿时间列拼接，不与输入共享数组。各批必须形状合法且特征行数一致，包括零列批次；空列表返回 0×0。保留尾部包含帧重叠样本，`reset()` 会丢弃它们。示例使用 NaturalLog，避免每批 dB 截断影响分块/离线对照。

## CMVN 与 WAV 约定

`cmvn` 不修改输入，按整段所有时间列计算每个特征行的统计量。默认归一化方差，使用除以帧数的总体方差，`variance_floor=1e-10`，单位为输入单位的平方；设 `normalize_variance=false` 仅减均值。常数行变为零，空矩阵保留形状；不规则矩阵、非有限值及非正/非有限下限返回 `DimensionMismatch`。缩放后的矩累积避免大有限值溢出，无法表示的中心化结果返回错误。这不是说话人统计或在线滑窗 CMVN，也不表示与 Kaldi 模型兼容。通用约定参考 [Kaldi 的 CMVN 说明](https://kaldi-asr.org/doc/transform.html)，未复制其源码。

WAV 接受小端 RIFF 格式标签 1：8 位无符号、16/24/32 位有符号整数，按 `2^(bits-1)` 缩放；两种解码共享有界块解析及格式校验。浮点、压缩和 extensible 格式明确拒绝。单声道入口按全部声道平均，保留声道入口不重新解释空间布局。格式布局依据 [Microsoft WAVE 说明](https://learn.microsoft.com/en-us/windows/win32/api/mmreg/ns-mmreg-waveformatex)。

## 扩展功能

频谱描述、能量/RMS、差分、Chroma、CQT、HPSS、多声道、起音、LPC/LPCC、YIN、节奏、对比、响度、效果处理仍公开。精确标签和类型见各包接口。差分为重复 HTK 回归及最近边界，CQT 为直接核相关，频谱描述遵循配置功率，对比使用经验分位数，响度保留有限静音哨兵且未通过完整规范认证。跨库等价性应先查健康报告。

`spectral_rolloff` 的 `roll_percent` 必须是 `[0, 1]` 内的有限数，包含两个端点。`spectral_flatness` 的 `amin` 必须为有限正数。不合法的值会在计算 STFT 前返回 `DimensionMismatch`。

`chroma_from_spectrogram` 要求 `tuning` 有限，且 `f_min` 为 `[0, sample_rate / 2]` 内的有限数。非法调音值返回 `DimensionMismatch`，非法下限在访问滤波器组前返回 `InvalidFrequencyRange`。

`super_flux` 在尺寸大于 1 时使用半径为 `filter_size / 2` 的频率邻域；尺寸不大于 1 时使用普通谱通量，不扩展频率邻域。该约定也适用于 `OnsetMethod::SuperFlux`。

`tempogram_from_onset` 将整数延迟与包含端点的 `[min_bpm, max_bpm]` 区间及分析窗求交。没有可用延迟时返回 `bpm=0`、空 `tempi` 和 `0 x 0` 节奏图，不生成超出请求范围的候选。

## 浏览器传输

web 绑定导出音频分析、显式配置分析、WAV 分析与 WAV 解码函数。返回实际矩阵、滤波器组与 STFT 预览索引。成功标识反映真实结果，错误字符串经过 JSON 转义。WASM 可构建，当前演示明确使用 JS。文件/预览限制属于 UI 域，不改变库 API。

浏览器绑定只声明 JS/WASM/WASM-GC，Native 构建不再将浏览器外部库误链接为可执行文件；核心库和示例仍支持 Native。
