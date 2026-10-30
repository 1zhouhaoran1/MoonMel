# 0.1.1～0.1.6 开发记录

[English](../en/DEVELOPMENT_SERIES.md)

2026-10-30：六轮开发增量合并为 0.1.6 发布。下表中的 0.1.1～0.1.5 是内部里程碑，没有分别发布。发布状态见 [GitHub Release](https://github.com/1zhouhaoran1/MoonMel/releases/tag/v0.1.6) 和 [Mooncakes](https://mooncakes.io/docs/1zhouhaoran1/moonmel)。

## 六轮增量

| 轮次 | 交付 | 可检查的验证 |
| --- | --- | --- |
| 0.1.1 | 完成 0.10.18 格式迁移及 Windows Native 修复；架构检查从 moon.mod 读取命名空间，解决旧 zhr 路径导致漏检；CI 增加格式与架构回归检查 | 5 项 Node 架构回归覆盖依赖计数、向上依赖、循环、缺包与 core 隔离 |
| 0.1.2 | WAV 支持 24/32 位整数 PCM，共享格式与有界块解析；保留 8/16 位支持 | PCM 极值、正负半幅、最低有效位、截断帧、错误对齐与浮点格式拒绝；浏览器绑定宽 PCM 回归 |
| 0.1.3 | 新增 decode_wav_multichannel，保留文件声道顺序与采样率 | 双声道反相信号不相互抵消；单声道与多声道入口对四种位深一致 |
| 0.1.4 | 流式新增 try_push_samples、buffered_samples、pop_features 与 StreamingFeatures | 非有限块整块拒绝且不污染状态；逐样本分块与离线 Mel/Log-Mel/MFCC 对齐 |
| 0.1.5 | 新分层包 features/normalize，提供离线整段 CMVN | 已知总体方差、常数/单帧/空矩阵、方差下限、大有限值、大偏置小变化、非法值与输入不变性 |
| 0.1.6 | FeatureMatrix::concat_frames 与完整 WAV→流式 MFCC→CMVN 示例；双语使用说明与 CI 示例执行 | 独立数组、错误形状、帧数溢出；双声道 1600 样本示例断言流式/离线 13×17 数值一致 |

## 复现

Windows 本机先运行 `. ./tools/dev/activate.ps1`，实际编译器为 `moonc v0.10.18+6c83a7f62`。

```sh
moon run examples/streaming --target js
node tools/quality/check-architecture.mjs
node --test tools/quality/check-architecture.test.mjs
moon fmt --check
```

示例输出：

```text
WAV: 2 channels, 1600 samples/channel at 16000 Hz
Streaming/offline MFCC agree: 13 x 17
CMVN: 13 x 17; pending tail: 240 samples
```

完整本地验证：WASM/WASM-GC/JS 各 159 项、Windows Native 157 项测试通过；四目标检查、发行构建及两个示例通过。Node 共 11 项（5 项架构、6 项绑定）通过，网页生产构建通过，原核心 librosa 八组参考通过。架构检查实际统计 34 个包、88 条内部依赖。新增 CMVN 采用解析用例验证，不包含在原八组 librosa 报告内。

## 使用边界

WAV 暂不支持浮点及 WAVE_FORMAT_EXTENSIBLE。单声道解码仍按声道平均；双声道保留入口适合需要空间信息的调用者。流式仅返回完整帧，保留尾部包含重叠样本；dB 截断按每批计算。示例用 NaturalLog，且使用生成的确定性音频，不作为真实下游项目采用的证据。

CMVN 按整段逐行统计，不是在线滑窗、说话人统计或完整语音模型前端。旧 push_samples 仍可接收未经校验的输入，应优先使用 try_push_samples。新接口需要 0.1.6；安装旧 0.1.0 不会获得这些接口。
