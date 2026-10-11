# 开发与测试

[English](../en/DEVELOPMENT.md)

## 工具链

要求 `moonc >= 0.10.14`、Node.js 22.12+ 或 24+、pnpm 11.14.0。`node tools/quality/check-toolchain.mjs` 检查版本。本机隔离 SDK 位于 `A:/DevEnv/SDKs/MoonBit/moonmel-current`，用 `. ./tools/dev/activate.ps1` 选择，不修改系统安装。

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
```

本机 Windows Native 使用 `pwsh -File tools/quality/test-native.ps1`。脚本为现有 MinGW GCC 补运行时声明，不修改 SDK 源码，退出时恢复 `MOON_CC`/`MOON_AR`。默认 MSVC 缺失头文件。Linux/macOS CI 使用正常本机编译器。

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

`.github/workflows/ci.yml` 覆盖四目标检查、构建、测试与示例，再构建演示页和测试绑定。每个任务检查编译器门槛。远端通过状态看 GitHub Actions。Mooncakes 发布暂缓，当前以源码检出提供可复现运行路径。

使用同一 Windows 适配器构建 Native 发行产物：`pwsh -File tools/quality/test-native.ps1 -Build`。
