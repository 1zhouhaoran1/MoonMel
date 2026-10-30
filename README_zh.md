<p align="center"><img src="docs/banner.png" alt="MoonMel — Audio Into Features" width="960" /></p>
<p align="center"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-b63a25?style=flat-square" /> <img alt="MoonBit 0.10.16+" src="https://img.shields.io/badge/moonc-0.10.16+-24211d?style=flat-square" /> <img alt="编译目标" src="https://img.shields.io/badge/targets-JS%20%7C%20WASM%20%7C%20Native-24211d?style=flat-square" /></p>
<p align="center">纯 MoonBit 音频特征引擎，复用 STFT、Mel、Log-Mel 与 MFCC 流水线。</p>
<p align="center"><a href="README.md">English</a> · <a href="https://1zhouhaoran1.github.io/MoonMel/">在线演示</a> · <a href="CHANGELOG_zh.md">更新日志</a> · <a href="#从源码运行">运行</a> · <a href="docs/zh/API_SPECIFICATION.md">API</a> · <a href="docs/zh/ARCHITECTURE.md">架构</a> · <a href="docs/zh/HEALTH.md">健康报告</a></p>

## 从源码运行

安装 [MoonBit](https://www.moonbitlang.com/download/)，要求 `moonc >= 0.10.16`。浏览器演示另需 Node.js 22.12+ 或 24+、pnpm 11。使用 `moon add 1zhouhaoran1/moonmel@0.1.6` 从 mooncakes.io 安装 0.1.6。

**0.1.6** 合并了 0.1.0 后的六轮增量，见[开发记录](docs/zh/DEVELOPMENT_SERIES.md)。下述新增 API 需要 0.1.6 或本仓库源码。

```sh
git clone https://github.com/1zhouhaoran1/MoonMel.git
cd MoonMel
moon run examples/basic --target js
```

内置一秒 440 Hz 正弦信号，无需音频文件，输出：

```text
STFT: 513 x 63
Mel: 80 x 63
Log-Mel: 80 x 63
MFCC: 13 x 63
```

项目本机可先在 PowerShell 选择已安装的隔离编译器：

```powershell
. ./tools/dev/activate.ps1
```

## 浏览器演示

```sh
pnpm --dir playground install --frozen-lockfile
pnpm --dir playground run dev
```

打开 `http://localhost:5173`。启动与构建会重新编译 MoonBit 绑定，不再手工维护生成代码。当前页实际在 Web Worker 中运行 **MoonBit 生成的 JS**；WASM 是库支持的编译目标。音频保留在本地。

| 操作 | 实际结果 |
| --- | --- |
| 选择正弦、扫频、混合或静音 | 显示 MoonBit 计算的频谱与输入波形 |
| 上传 8/16/24/32 位整数 PCM WAV | 使用 MoonMel 解析，多声道混合为单声道，预览前十秒 |
| 更改 FFT、步长、Mel、MFCC | 对当前真实输入重新计算 |
| 切换 Log-Mel、STFT、MFCC | 鼠标或图上左右键检查时间帧数值 |
| 播放、麦克风、导出 | 听输入、分析滚动一秒窗口、下载 JSON/CSV |

麦克风需要 HTTPS 或 localhost 与浏览器许可，使用 AudioWorklet。它是滚动窗口演示，不等于库的增量流式接口。文件限制 10 MB，分析预览限制 2,000 帧；超限时缩短音频或增加步长。

## 使用 API

```moonbit
let cfg = @moonmel.FeatureConfig::default()
let result = @moonmel.analyze(samples, config=cfg).unwrap()
println(result.mfcc.n_cols)
```

`analyze` 只计算一次 STFT 与滤波器组，依次派生 Mel、Log-Mel、MFCC。已有独立接口及扩展特征接口保留。WAV 使用 `@moonmel.decode_wav(bytes)`，再分析 `audio.samples`；配置采样率和频率上限必须与解码后的音频一致。

特征矩阵为 `[特征行][时间帧]`，复数 STFT 为 `[时间帧][频点]`。用户输入要处理 `Result` 错误，不应直接 `unwrap`。公开原始矩阵与低层内核仍有前置条件。

需要保留文件声道时使用 `decode_wav_multichannel(bytes)`。流式输入可用 `try_push_samples` 整块校验，调用一次 `pop_features` 获取同批 Mel/Log-Mel/MFCC，用 `FeatureMatrix::concat_frames` 拼接各批时间帧，再以 `cmvn` 归一化特征。原有单声道及单独 pop 接口保留。运行完整示例：

```sh
moon run examples/streaming --target js
```

示例自行生成双声道 PCM16 音频，断言流式与离线 MFCC 数值一致，再执行整段 CMVN。[API 约定](docs/zh/API_SPECIFICATION.md)说明每批 dB 截断及未补齐尾帧的边界；浮点 WAV 和 WAVE_FORMAT_EXTENSIBLE 暂不支持。

## 数值证据与边界

[机器可读报告](tools/reference/parity_report.json) 由 `tools/reference/check_parity.py` 生成，参考 librosa 1.0.0、NumPy 2.5.3、SciPy 1.18.1。八组确定性案例包含短窗、任意与奇数 FFT、单样本；比较全部 Mel、Log-Mel、MFCC 单元，STFT 每帧比较最多 64 个明确索引频点。对齐周期 Hann、reflect 填充、float64 Slaney 滤波器、正交 DCT-II；容差 `atol=rtol=1e-7`，观察到的最大绝对误差约 `2.3e-12`。

不宣称整个库等价或竞品速度排名。librosa 默认 STFT 为 constant 填充，MoonMel 使用 reflect；HTK 风格差分、直接 CQT、Chroma、HPSS、响度与效果处理仍有独立约定和验证边界。Whisper 配置只是分帧预设，不是完整模型前端。

| 库 | 实现与场景 | 本项目选型差异 |
| --- | --- | --- |
| MoonMel | 纯 MoonBit，同源编译 JS/WASM/Native | 原生 MoonBit 集成与可检查流水线；高级功能外部验证仍有限 |
| [librosa](https://github.com/librosa/librosa) | Python / NumPy / SciPy 研究生态 | 核心参数对齐后的数值参考 |
| [Meyda](https://meyda.js.org/audio-features) | JS 与 Web Audio 特征 | 成熟的浏览器音频接入 |
| [Essentia.js](https://github.com/MTG/essentia.js) | C++ → WASM，JS/TS 接口 | 更广的音乐算法与模型集成 |

## 检查与 CI

```sh
node tools/quality/check-toolchain.mjs
node tools/quality/check-architecture.mjs
moon check --deny-warn
moon test --deny-warn
moon test --target js --deny-warn
pnpm --dir playground run build
pnpm --dir playground test
```

[CI 工作流](.github/workflows/ci.yml) 覆盖 WASM、WASM-GC、JS、Native 的检查、构建、测试与基本示例，另构建演示页并验证浏览器绑定。配置文件存在不等于远端运行通过，实际状态以 GitHub Actions 为准。

MoonBit 0.10.18 的 Windows Native 运行时要求 MSVC。安装完整的 Visual Studio C++ 工具和 Windows SDK 头文件/库后，运行 `pwsh -File tools/quality/test-native.ps1` 测试，添加 `-Build` 进行发行构建。脚本使用 Moon 的编译器选择机制，不再强制不兼容的 MinGW 回退。本地与 CI 结果见验收记录。

独立 Python 验证可使用项目已准备环境：

```powershell
& A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/check_parity.py
```

[开发指南](docs/zh/DEVELOPMENT.md) 提供可移植 uv 设置，[验收清单](docs/zh/ACCEPTANCE.md) 对应九项指南，[健康报告](docs/zh/HEALTH.md) 列出审查范围和剩余限制。本次发行模块为 `1zhouhaoran1/moonmel` 0.1.6。

## 许可证

[MIT](LICENSE)，Copyright 2026 zhr。算法在 MoonBit 中实现，NumPy/SciPy/librosa 用于开发验证。字体与参考来源见 [第三方声明](THIRD_PARTY_NOTICES_zh.md)。
