# MoonMel Development & Testing Guide

[English](./DEVELOPMENT.md) | [中文说明](../zh/DEVELOPMENT.md)

This document provides instructions for local development, compilation, test execution, and reference parity verification.

---

## 1. Toolchain & Prerequisites

- **MoonBit SDK**: `moon 0.1.20260904` or later, `moonc v0.10.12+1634b282e`.
- **Node.js & Package Manager**: Node 22+, `pnpm` exclusively (`v11.14.0`).
- **Python Environment**: Python 3.13 (`A:\DevEnv\Envs\moonmel_py`) with `librosa 1.0.0`, `scipy 1.18.1`, `numpy 2.5.3`.

---

## 2. Code Checking & Formatting

```bash
# Verify syntax and types across all packages
moon check

# Update interface files (.mbti) and apply standard formatting
moon info && moon fmt
```

---

## 3. Test Suites

### 3.1 Local Test Execution
```bash
# Run all unit and integration tests (default WASM backend)
moon test

# Test against the JavaScript compilation target
moon test --target js

# Test against the WebAssembly compilation target
moon test --target wasm
```

### 3.2 Reference Ground-Truth Parity Verification
```bash
# Generate reference_vectors.json using Python
A:\DevEnv\Envs\moonmel_py\Scripts\python.exe tools/reference/validate_reference.py

# Execute test suite to verify numerical assertions against ground truth
moon test
```

---

## 4. CLI Benchmark

```bash
moon run cmd/main
```

Executes end-to-end benchmark analysis across 1s and 10s audio buffers.

---

## 5. WebAssembly Playground

```bash
cd playground
pnpm install
pnpm run dev
pnpm run build
```
Production output is generated at `playground/dist/`.
