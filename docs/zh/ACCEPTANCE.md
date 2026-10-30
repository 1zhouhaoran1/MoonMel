# 黑客松验收检查

[English](../en/ACCEPTANCE.md)

检查日期：2026-10-30。源码基线：`74b10bdf5ae88392ab2175193df97f778cc4e06d`，仓库身份与模块命名空间均为 `1zhouhaoran1`。

本记录按维护者提供的九项指南检查工程证据，不代替组委会的审核或最终验收决定。本地结果包含基线之后的 0.10.18 格式迁移、Native 修复及 [0.1.6 增量](DEVELOPMENT_SERIES.md)；远端证据仅对应上述基线。该验收检查先于 0.1.6 发布，后续发布状态见 GitHub Release；未提交报名表。

## 九项要求

| 要求 | 本次证据 | 结论 |
| --- | --- | --- |
| 1. MoonBit 主实现，moonc >= 0.10.16 | 算法、门面与 CLI 使用 MoonBit；本机为 `moonc v0.10.18+6c83a7f62`、`moon 0.1.20261028`，隔离 SDK 为 `A:/DevEnv/SDKs/MoonBit/latest-20261030`；当前提交 CI 同样使用 0.10.18 | 符合；按维护者要求实际验证 0.10.18 |
| 2. 公开 GitHub、清晰提交 | GitHub API 确认仓库 public、默认分支 main、MIT 元数据，当前提交作者及提交者为 1zhouhaoran1，提交记录按功能/修复/文档组织 | 符合 |
| 3. 结构清晰、完成声明核心 | 架构检查已修复命名空间漏检：本地 34 个包、88 条内部依赖，无环和向上层依赖；本地四目标通过，基线 CI 四目标通过 | 在已声明实现及验证边界内符合 |
| 4. README 可复现 | 中英文 README 提供目标、安装、调用和期望形状；本地最小示例及独立 Mooncakes 消费项目实际运行成功 | 符合；Windows Native 环境要求见下文 |
| 5. CI 覆盖检查/构建/测试 | 当前提交 Project CI 四目标均完成 check/build/test/example，演示页完成构建及绑定测试 | 符合；有当前提交的远端成功记录 |
| 6. 至少一个可运行示例 | `moon run examples/basic --target <wasm/wasm-gc/js/native>` 本地运行成功；独立项目调用已发布包成功 | 符合 |
| 7. 核心路径测试 | 本地 WASM/WASM-GC/JS 各 159 项、Windows Native 157 项、Node 11 项（绑定 6、架构 5）；基线 CI 为 147/145 及绑定 5 项；包含错误输入、WAV、分帧、FFT、Mel/MFCC 及扩展回归 | 核心路径有实际通过证据，不宣称穷尽全部输入或高级算法标准认证 |
| 8. 发布 mooncakes.io | 注册表页面显示 `1zhouhaoran1/moonmel` 0.1.0；新消费项目刷新索引、解析安装并运行其公开 API | 符合，无需重复发布 |
| 9. OSI 许可及来源说明 | MIT LICENSE、模块元数据、双语第三方声明、Manrope 完整 OFL 正文及网页分发副本均存在 | 已提供许可与来源材料；本次为仓库材料检查，不是法律合规认证 |

## 当前提交的远端证据

[Project CI 41029437824](https://github.com/1zhouhaoran1/MoonMel/actions/runs/41029437824) 对应上述源码基线，所有任务通过。日志明确记录 `moonc v0.10.18+6c83a7f62 (2026-10-28)`，WASM/WASM-GC/JS 各 147 项测试、Native 145 项测试及 5 项浏览器绑定测试通过。Native 排除两个浏览器专用包内测试。

[Pages 部署 41029437856](https://github.com/1zhouhaoran1/MoonMel/actions/runs/41029437856) 同样对应该提交并通过。[公开演示](https://1zhouhaoran1.github.io/MoonMel/)和 [Mooncakes 文档页](https://mooncakes.io/docs/1zhouhaoran1/moonmel)本次均返回 HTTP 200；HTTP 可访问不等于本轮已重做全部浏览器交互验证。

CI 当前下载可用工具链并检查最低 0.10.16，未固定未来运行的编译器版本。已有日志证明本次提交在 0.10.18 通过，不应据此推断以后每次 CI 都是 0.10.18。

## 本地复现结果

| 检查 | 结果 |
| --- | --- |
| `moon check --target <wasm/wasm-gc/js> --deny-warn` | 三目标通过，无警告 |
| `moon build --target <wasm/wasm-gc/js> --release` | 三目标通过 |
| `moon test --target <wasm/wasm-gc/js> --deny-warn` | 各 159/159 通过 |
| `moon run examples/basic --target <wasm/wasm-gc/js>` | 三目标均输出 STFT 513×63、Mel 80×63、Log-Mel 80×63、MFCC 13×63 |
| `pnpm --dir playground install --frozen-lockfile` | 锁定依赖安装通过 |
| `pnpm --dir playground run build --base /MoonMel/` | 最新 MoonBit JS 绑定及生产页面构建通过 |
| `pnpm --dir playground test` | 11/11 通过：6 项绑定、5 项架构 |
| 独立消费 `1zhouhaoran1/moonmel@0.1.0` | 0.10.18 下检查通过，运行并断言核心输出形状成功 |
| `moon check --target native --deny-warn` | 通过，无警告 |
| `pwsh -File tools/quality/test-native.ps1 -Build` | Windows MSVC Native 发行构建通过 |
| `moon test --target native --deny-warn` | 本机 Native 157/157 通过；此前修复阶段脚本运行 145/145 通过 |
| `moon run examples/basic --target native` | 输出与上述三目标一致 |
| `moon fmt --check` | 0.10.18 格式迁移后通过 |
| `moon run examples/streaming --target <wasm/wasm-gc/js/native>` | 四目标均通过，双声道 WAV→流式 MFCC 与离线 13×17 数值一致，再执行 CMVN |

独立消费项目、构建产物和本轮数值参考结果放在忽略目录 `_build/acceptance-20261030/`。上一轮格式迁移涉及 62 个源码/接口文件，规范化文本一致；本轮另有功能增量，不应把全部差异描述为仅格式变化。新增 CMVN 有解析回归，未纳入原八组 librosa 核心报告。

## 本机问题及处理边界

- **Windows Native 工具链**：0.10.18 SDK 运行时代码要求 Windows 使用 MSVC。已通过微软官方安装器修复现有 Visual Studio C++ 工具及 Windows SDK；标准 C 头文件由 SDK 的 UCRT 提供，不应仅凭 VC include 目录没有 `stdio.h` 判断安装损坏。Native 脚本已删除不兼容的 MinGW 回退，交由 Moon 选择编译器，并保留显式调用方设置。本机 Windows Native 检查、发行构建、145 项测试及示例均实际通过，未修改 MoonBit SDK 源码。
- **Python 参考环境**：本轮发现专用环境中的 NumPy/SciPy/librosa 元数据存在但模块文件不完整，已使用 uv 按仓库 requirements 在专用环境重新安装；数值复验结果见下节。
- **格式迁移**：已按 0.10.18 规范统一类型、可选参数和排版，`moon fmt --check` 通过；迁移后四目标检查/构建/测试/示例、网页构建与绑定测试及八组数值参考全部复验通过。

## 数值参考复验

修复专用环境后，使用 0.10.18 重新编译当前源码的 JS 绑定，实际执行：

```powershell
& A:/DevEnv/Envs/moonmel_py/Scripts/python.exe tools/reference/check_parity.py --output _build/acceptance-20261030/parity-0.1.6.json
```

八组全部通过，参考版本为 NumPy 2.5.3、SciPy 1.18.1、librosa 1.0.0。覆盖音调、静音、噪声、短窗、400 点 FFT、奇数 FFT、幅度谱及单样本；检查全部 Mel/Log-Mel/MFCC 单元和每帧最多 64 个明确索引的 STFT 频点，`atol=rtol=1e-7`。本轮最大绝对误差约 `2.3e-12`，不扩大到全库或高级算法认证。librosa 对单样本用例提示 FFT 大于输入长度，测试仍按显式 reflect 约定通过。

## 评委演示流程

1. 展示 `moonc -v` 的 0.10.18 输出，运行最小示例。
2. 打开当前提交的 CI，展示四目标 check/build/test/example 与网页绑定测试。
3. 展示 Mooncakes 页面及独立安装调用结果。
4. 打开在线演示，选择扫频/正弦、400 点 FFT，上传 PCM WAV，修改参数并导出矩阵。
5. 使用申报书中的固定版本对照及源码解释增量、帧级合成、抗混叠重采样和多声道分析边界。

不能把生成 JS 说成 WASM，把特定案例对齐说成全库认证，或把本机耗时说成竞品性能排名。本验收记录不改变申报书中高级算法与实际下游采用仍待补证据的边界。
