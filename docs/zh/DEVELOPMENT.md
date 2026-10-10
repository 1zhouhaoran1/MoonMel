# MoonMel 开发者构建与测试指南 (Development Guide)

[English](../en/DEVELOPMENT.md) | [中文说明](./DEVELOPMENT.md)

本文档说明 MoonMel 本地开发环境准备、代码检查与格式化、全后端测试运行及基准测试复现流程。

---

## 1. 工具链要求与环境准备

项目遵循 `A:\DevEnv` 统一工具链规范：
- **MoonBit SDK**：`moon 0.1.20260904` 或更新版本，`moonc v0.10.12+1634b282e`。
- **Node.js 与 包管理器**：Node 22+，使用 `pnpm`（`v11.14.0`）进行依赖管理。
- **Python 科学验证环境**：Python 3.13（位于 `A:\DevEnv\Envs\moonmel_py`），预装 `librosa 1.0.0`、`numpy 2.5.3`、`scipy 1.18.1`。

---

## 2. 代码检查与格式化

在修改代码后，必须执行以下指令完成类型与语法检查：

```bash
# 检查所有模块的类型与语法正确性
moon check

# 更新接口定义文件并执行统一代码格式化
moon info && moon fmt
```

---

## 3. 测试与验证执行

### 3.1 本地测试套件
MoonMel 内置完整的单元测试、边界测试与端到端管道测试：

```bash
# 执行全套白盒与黑盒测试（默认 WASM 后端）
moon test

# 执行 JavaScript 后端编译与运行时测试
moon test --target js

# 执行 WebAssembly 后端测试
moon test --target wasm
```

### 3.2 Python 权威真值对齐测试
运行对照验证程序，生成 librosa 真值基准并验证一致性：

```bash
# 生成 reference_vectors.json
A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/validate_reference.py

# 验证测试套件中与真值的数值断言
moon test
```

---

## 4. 运行本地基准测试 (CLI)

```bash
moon run cmd/main
```

测试将自动对 1 秒与 10 秒 16 kHz 多频信号进行 STFT、Mel 及 MFCC 特征提取，并打印时频矩阵规模。

---

## 5. WebAssembly Playground 启动与构建

进入前端调试目录：

```bash
cd playground

# 安装前端依赖
pnpm install

# 启动本地开发服务器（默认端口 5173）
pnpm run dev

# 编译生产优化包
pnpm run build
```
编译产物输出至 `playground/dist/`，可直接部署到任何静态托管平台。
