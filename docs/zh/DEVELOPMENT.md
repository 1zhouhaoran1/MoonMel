# 开发与测试

[English](../en/DEVELOPMENT.md)

## 工具链

要求 `moonc >= 0.10.16`、Node.js 22.12+ 或 24+、pnpm 11.14.0。`node tools/quality/check-toolchain.mjs` 检查版本。本机隔离 SDK 位于 `A:/DevEnv/SDKs/MoonBit/latest-20261030`（moonc 0.10.18），用 `. ./tools/dev/activate.ps1` 选择，或用 `MOONMEL_MOON_HOME` 指向其他工具链，不修改系统安装。

```sh
moon info
moon fmt
moon check --deny-warn
node tools/quality/check-architecture.mjs
moon test --target wasm --deny-warn
moon test --target wasm-gc --deny-warn
moon test --target js --deny-warn
moon test --target native --deny-warn
moon run examples/basic --target js
moon run examples/streaming --target js
```

Windows 上 MoonBit 0.10.18 运行时要求完整的 Visual Studio C++ 工具和 Windows SDK 头文件/库。使用上述 Native 命令，或运行 `pwsh -File tools/quality/test-native.ps1` 测试，添加 `-Build` 进行发行构建。脚本改为由 Moon 选择支持的编译器，不再强制 MinGW，并保留调用方显式指定的编译器设置。[验收记录](ACCEPTANCE.md)分别记录本地及远端结果。

源码及生成接口已按 0.10.18 格式器规范化，包括 `Int32` 类型拼写、当前可选参数语法及排版；`moon fmt --check` 通过。格式化及重新生成接口后运行该命令，检查一致性。

[0.1.6 开发记录](DEVELOPMENT_SERIES.md)说明新增 WAV、流式、CMVN 与帧拼接 API。CI 另执行 `node --test tools/quality/check-architecture.test.mjs`，架构检查读取当前模块命名空间并统计真实内部依赖。

## 演示页

```sh
pnpm --dir playground install --frozen-lockfile
pnpm --dir playground run dev
pnpm --dir playground run build
pnpm --dir playground test
```

启动与构建前自动执行 `tools/build/sync-web.mjs`。生成 JS 位于忽略目录 `playground/src/generated`，不要手工修改。生产输出 `playground/dist`。绑定测试覆盖错误输入、恶意 WAV 长度、解码音频重算、任意 FFT、短窗偏移。

## 独立数值参考

使用 uv 与隔离环境，不向共享基础解释器安装。Windows 新环境统一放在 `A:/DevEnv/Envs`：

```powershell
uv venv A:\DevEnv\Envs\moonmel_py --python 3.13
uv pip install --python A:\DevEnv\Envs\moonmel_py\Scripts\python.exe -r tools/reference/requirements.txt
& A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/check_parity.py
```

已有环境时跳过创建。其他平台在批准的环境目录创建隔离环境，再将解释器传给 `uv pip install --python`。脚本重新构建当前 JS，比较完整 Mel/Log-Mel/MFCC 与选定 STFT 频点，并记录实际版本和容差。旧 `validate_reference.py` 只生成抽查向量，生成向量本身不等于验证 MoonMel。

## CI 与发布

`.github/workflows/ci.yml` 覆盖四目标检查、构建、测试与示例，再构建演示页和测试绑定。每个任务检查编译器门槛。远端通过状态看 GitHub Actions。0.1.6 以 `1zhouhaoran1/moonmel` 发布到 mooncakes.io，后续版本用 `moon publish` 发布。

Windows Native 的 0.10.18 发行构建应在完整 MSVC 开发者环境运行 `moon build --target native --release`，不要使用旧 MinGW 适配器。

## GitHub Pages

在线演示：https://1zhouhaoran1.github.io/MoonMel/ 。`.github/workflows/pages.yml` 在 main 的相关源码变化后重新生成 MoonBit 绑定、验证绑定并部署 Vite 输出。资源前缀来自 Pages 元数据，本地开发仍使用 `/`。可通过 `pnpm --dir playground run build --base /MoonMel/` 检查同样的构建。
