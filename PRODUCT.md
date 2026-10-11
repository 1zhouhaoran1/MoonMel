# MoonMel

[中文](PRODUCT_zh.md)

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Hackathon judges evaluating the project's technical contribution, and developers choosing an audio feature extraction library. Confirmed by the project owner.

## Product Purpose

Extract audio features with a pure MoonBit implementation that compiles to JavaScript, WebAssembly and native code. The demo must make the implementation inspectable through actual audio input and reproducible evidence.

## Operating Context

Existing Vite and Tailwind playground. Synthetic audio, local PCM WAV, playback, microphone capture, configuration, visualizations and export are established workflows. The owner prioritizes code health and permits substantial refactoring.

## Positioning

A MoonBit-native DSP implementation with a shared STFT/Mel/Log-Mel/MFCC pipeline and no third-party algorithm dependencies. Compare against librosa, Meyda and Essentia.js without inventing speed, size or quality advantages.

## Capabilities and Constraints

The browser demo runs generated JavaScript from MoonBit. WASM is a supported library build target, not the demo's current execution engine. PCM WAV parsing supports 8-bit and 16-bit data and mono downmixing. This is a research library, not a complete replacement for the broader competitor ecosystems.

## Brand Commitments

The owner explicitly requested a new image-generated identity: warm ivory, near-black and vermilion, with an acoustic-bar/crescent emblem and custom MoonMel wordmark. The website is a local repository artifact; hosting has not been requested.

## Evidence on Hand

Source packages, regression tests and tools/reference/parity_report.json. Numerical comparison is scoped to eight configurations of the core pipeline, with reflect padding and float64 Slaney filters. No measured competitor speed benchmarks or whole-library equivalence are available.

## Product Principles

Correctness before presentation. Demonstrate the real implementation. State assumptions beside evidence. Show both advantages and remaining gaps. Keep local audio processing on the device.
