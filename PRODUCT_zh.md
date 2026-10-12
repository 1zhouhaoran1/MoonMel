# MoonMel

[English](PRODUCT.md)

## 平台与用户

浏览器演示页面向黑客松评委及进行音频库选型的开发者，受众由项目负责人确认。

## 目标

用纯 MoonBit 实现可编译至 JavaScript、WebAssembly 与 Native 的音频特征提取。代码健康优先，演示页通过真实输入、数值结果与可重复验证展示贡献。

## 已有流程

Vite 与 Tailwind 演示页已有合成音频、PCM WAV 上传、播放、麦克风、参数配置、可视化及导出能力。负责人允许必要的大范围重构，选择直接编码并验证页面。

## 定位与限制

核心算法不依赖第三方 DSP 库，统一流水线复用 STFT。浏览器演示实际运行 MoonBit 生成的 JS；WASM 是库的编译目标。WAV 支持 8/16 位 PCM，多声道混合为单声道。项目仍是研究库，不能宣称全面替代竞品。

## 证据与原则

源码、回归测试及 tools/reference/parity_report.json 提供可核查依据。数值比较覆盖八种核心流水线配置，采用 reflect 填充与 float64 Slaney 滤波器；不包含整个库的等价性或竞品速度排名。负责人明确要求重新生图改品牌：暖白、炭黑、朱砂红，声波柱与月牙图标，优先正确性，呈现优势和差距，音频在本地处理。

负责人已要求并启用 GitHub Pages；演示通过 main 分支工作流部署到 https://1zhouhaoran1.github.io/MoonMel/ 。
