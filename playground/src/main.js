import { process_audio, process_wav_bytes } from './moonmel.js';

// Application State
let currentSamples = [];
let sampleRate = 16000;
let lastResult = null;
let audioCtx = null;
let currentSourceNode = null;
let isPlaying = false;

// Color Palette Maps
// Warm Studio colormap (black -> dark slate -> deep terracotta -> warm amber -> gold -> warm white)
function getHeatmapColor(val) {
  // val is normalized 0.0 to 1.0
  const v = Math.max(0.0, Math.min(1.0, val));
  if (v < 0.2) {
    const t = v / 0.2;
    return [11 + t * 20, 15 + t * 20, 20 + t * 30]; // deep dark slate
  } else if (v < 0.45) {
    const t = (v - 0.2) / 0.25;
    return [31 + t * 120, 35 + t * 40, 50 + t * 10]; // terracotta/rust
  } else if (v < 0.75) {
    const t = (v - 0.45) / 0.3;
    return [151 + t * 65, 75 + t * 65, 60 - t * 20]; // warm amber
  } else {
    const t = (v - 0.75) / 0.25;
    return [216 + t * 39, 140 + t * 100, 40 + t * 190]; // gold to light warm
  }
}

// Generate Synthetic Audio
function generatePreset(type, sr, duration = 1.0) {
  const n = Math.floor(sr * duration);
  const samples = new Float64Array(n);
  const twoPi = 2 * Math.PI;

  if (type === 'sine') {
    const freq = 440.0;
    for (let i = 0; i < n; i++) {
      const t = i / sr;
      samples[i] = 0.8 * Math.sin(twoPi * freq * t);
    }
  } else if (type === 'chord') {
    for (let i = 0; i < n; i++) {
      const t = i / sr;
      const s1 = 0.5 * Math.sin(twoPi * 440.0 * t);
      const s2 = 0.3 * Math.sin(twoPi * 1000.0 * t);
      const s3 = 0.2 * Math.sin(twoPi * 2500.0 * t);
      samples[i] = s1 + s2 + s3;
    }
  } else if (type === 'chirp') {
    const f0 = 100.0;
    const f1 = 4000.0;
    for (let i = 0; i < n; i++) {
      const t = i / sr;
      const instantFreq = f0 + (f1 - f0) * (t / (2 * duration));
      samples[i] = 0.75 * Math.sin(twoPi * instantFreq * t);
    }
  } else if (type === 'vowel') {
    // Formant simulation: fundamental 130 Hz with resonances at 500, 1500, 2500 Hz
    const f0 = 130.0;
    for (let i = 0; i < n; i++) {
      const t = i / sr;
      const pulse = Math.sin(twoPi * f0 * t);
      const form1 = 0.5 * Math.sin(twoPi * 500.0 * t);
      const form2 = 0.3 * Math.sin(twoPi * 1500.0 * t);
      const form3 = 0.2 * Math.sin(twoPi * 2500.0 * t);
      samples[i] = pulse * (form1 + form2 + form3) * 0.9;
    }
  }
  return Array.from(samples);
}

// Canvas Helpers (High-DPI)
function setupCanvas(canvas) {
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.floor(rect.width * dpr);
  canvas.height = Math.floor(rect.height * dpr);
  const ctx = canvas.getContext('2d');
  ctx.scale(dpr, dpr);
  return { ctx, width: rect.width, height: rect.height };
}

// 1. Draw Waveform
function drawWaveform(canvas, samples, sr) {
  const { ctx, width, height } = setupCanvas(canvas);
  ctx.fillStyle = '#0d1219';
  ctx.fillRect(0, 0, width, height);

  // Grid line
  ctx.strokeStyle = '#1b2533';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(0, height / 2);
  ctx.lineTo(width, height / 2);
  ctx.stroke();

  if (!samples || samples.length === 0) return;

  const step = Math.max(1, Math.floor(samples.length / width));
  ctx.strokeStyle = '#d4a373';
  ctx.lineWidth = 1.5;
  ctx.beginPath();

  for (let x = 0; x < width; x++) {
    const idx = Math.floor(x * step);
    let min = 1.0;
    let max = -1.0;
    for (let j = 0; j < step && idx + j < samples.length; j++) {
      const val = samples[idx + j];
      if (val < min) min = val;
      if (val > max) max = val;
    }
    const yMin = ((1 - max) / 2) * height;
    const yMax = ((1 - min) / 2) * height;
    ctx.moveTo(x, yMin);
    ctx.lineTo(x, yMax);
  }
  ctx.stroke();
}

// 2. Draw 2D Matrix Heatmap (Spectrogram, Mel, MFCC)
function drawHeatmap(canvas, matrix, options = {}) {
  const { ctx, width, height } = setupCanvas(canvas);
  ctx.fillStyle = '#0d1219';
  ctx.fillRect(0, 0, width, height);

  if (!matrix || matrix.length === 0 || matrix[0].length === 0) return;

  const rows = matrix.length;
  const cols = matrix[0].length;

  // Find min and max for normalization
  let min = Infinity;
  let max = -Infinity;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const v = matrix[r][c];
      if (v < min) min = v;
      if (v > max) max = v;
    }
  }

  const range = (max - min) || 1.0;
  const imgData = ctx.createImageData(cols, rows);

  for (let r = 0; r < rows; r++) {
    // Invert row index so low frequencies are at bottom
    const srcRow = rows - 1 - r;
    for (let c = 0; c < cols; c++) {
      const v = matrix[srcRow][c];
      const norm = (v - min) / range;
      const [cr, cg, cb] = getHeatmapColor(norm);
      const pixelIdx = (r * cols + c) * 4;
      imgData.data[pixelIdx + 0] = cr;
      imgData.data[pixelIdx + 1] = cg;
      imgData.data[pixelIdx + 2] = cb;
      imgData.data[pixelIdx + 3] = 255;
    }
  }

  // Draw offscreen and scale
  const offscreen = document.createElement('canvas');
  offscreen.width = cols;
  offscreen.height = rows;
  offscreen.getContext('2d').putImageData(imgData, 0, 0);

  ctx.imageSmoothingEnabled = false;
  ctx.drawImage(offscreen, 0, 0, width, height);
}

// 3. Draw Mel Filterbank Frequency Curves
function drawFilterbank(canvas, nMels, sr, nFft) {
  const { ctx, width, height } = setupCanvas(canvas);
  ctx.fillStyle = '#0d1219';
  ctx.fillRect(0, 0, width, height);

  // Draw frequency grid
  ctx.strokeStyle = '#1b2533';
  ctx.lineWidth = 1;
  for (let x = 0; x <= width; x += width / 8) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, height);
    ctx.stroke();
  }

  const nyquist = sr / 2;
  const melMin = 0;
  const melMax = 2595 * Math.log10(1 + nyquist / 700);
  const melStep = (melMax - melMin) / (nMels + 1);

  ctx.lineWidth = 1.2;
  for (let m = 0; m < nMels; m++) {
    const fCenterMel = melMin + (m + 1) * melStep;
    const fLeftMel = melMin + m * melStep;
    const fRightMel = melMin + (m + 2) * melStep;

    const fCenter = 700 * (Math.pow(10, fCenterMel / 2595) - 1);
    const fLeft = 700 * (Math.pow(10, fLeftMel / 2595) - 1);
    const fRight = 700 * (Math.pow(10, fRightMel / 2595) - 1);

    const xLeft = (fLeft / nyquist) * width;
    const xCenter = (fCenter / nyquist) * width;
    const xRight = (fRight / nyquist) * width;

    // Golden/warm gradient per filter
    const hue = 35 + (m / nMels) * 20;
    ctx.strokeStyle = `hsla(${hue}, 70%, 60%, 0.65)`;
    ctx.beginPath();
    ctx.moveTo(xLeft, height - 4);
    ctx.lineTo(xCenter, 12);
    ctx.lineTo(xRight, height - 4);
    ctx.stroke();
  }
}

// Run MoonBit Feature Extraction
function runExtraction() {
  const nFft = parseInt(document.getElementById('param-nfft').value, 10);
  const hopLength = parseInt(document.getElementById('param-hop').value, 10);
  const nMels = parseInt(document.getElementById('param-mels').value, 10);
  const nMfcc = parseInt(document.getElementById('param-mfcc').value, 10);

  if (!currentSamples || currentSamples.length === 0) {
    return;
  }

  const startTime = performance.now();
  // Call MoonBit compiled engine
  const jsonStr = process_audio(currentSamples, sampleRate, nFft, hopLength, nMels, nMfcc);
  const durationMs = Math.round((performance.now() - startTime) * 10) / 10;

  try {
    lastResult = JSON.parse(jsonStr);
    if (!lastResult.success) {
      console.error('Feature extraction failed:', lastResult.error);
      return;
    }

    // Update UI Metrics
    document.getElementById('dsp-latency').textContent = `${durationMs} ms latency`;
    document.getElementById('metric-latency').textContent = `${durationMs} ms`;
    document.getElementById('metric-frames').textContent = `${lastResult.n_frames} frames`;
    document.getElementById('metric-bins').textContent = `${lastResult.n_freq_bins} bins`;
    document.getElementById('metric-duration').textContent = `${(currentSamples.length / sampleRate).toFixed(2)} s`;

    // Redraw all canvases
    const canvasWaveform = document.getElementById('canvas-waveform');
    const canvasStft = document.getElementById('canvas-stft');
    const canvasMel = document.getElementById('canvas-mel');
    const canvasMfcc = document.getElementById('canvas-mfcc');
    const canvasFilterbank = document.getElementById('canvas-filterbank');

    drawWaveform(canvasWaveform, currentSamples, sampleRate);
    drawHeatmap(canvasStft, lastResult.stft_preview);
    drawHeatmap(canvasMel, lastResult.log_mel);
    drawHeatmap(canvasMfcc, lastResult.mfcc);
    drawFilterbank(canvasFilterbank, nMels, sampleRate, nFft);

  } catch (err) {
    console.error('Failed to parse MoonBit output:', err);
  }
}

// Audio Playback
function togglePlayback() {
  if (!currentSamples || currentSamples.length === 0) return;

  if (isPlaying) {
    if (currentSourceNode) {
      currentSourceNode.stop();
      currentSourceNode.disconnect();
    }
    isPlaying = false;
    document.getElementById('play-icon').textContent = '▶';
    document.getElementById('play-text').textContent = 'Play Audio';
    return;
  }

  if (!audioCtx) {
    audioCtx = new (window.AudioContext || window.webkitAudioContext)({ sampleRate });
  }

  const buffer = audioCtx.createBuffer(1, currentSamples.length, sampleRate);
  const channelData = buffer.getChannelData(0);
  for (let i = 0; i < currentSamples.length; i++) {
    channelData[i] = currentSamples[i];
  }

  currentSourceNode = audioCtx.createBufferSource();
  currentSourceNode.buffer = buffer;
  currentSourceNode.connect(audioCtx.destination);
  currentSourceNode.onended = () => {
    isPlaying = false;
    document.getElementById('play-icon').textContent = '▶';
    document.getElementById('play-text').textContent = 'Play Audio';
  };

  currentSourceNode.start();
  isPlaying = true;
  document.getElementById('play-icon').textContent = '⏹';
  document.getElementById('play-text').textContent = 'Stop Audio';
}

// Setup Event Listeners
document.addEventListener('DOMContentLoaded', () => {
  // Initial Preset
  currentSamples = generatePreset('sine', sampleRate, 1.0);
  runExtraction();

  // Preset Buttons
  document.querySelectorAll('.preset-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const preset = e.currentTarget.dataset.preset;
      currentSamples = generatePreset(preset, sampleRate, 1.0);
      document.getElementById('audio-meta').textContent = `1.00s @ ${sampleRate}Hz`;
      runExtraction();
    });
  });

  // Recompute button
  document.getElementById('btn-recompute').addEventListener('click', runExtraction);

  // Play button
  document.getElementById('btn-play-audio').addEventListener('click', togglePlayback);

  // Parameter Change Handlers
  document.getElementById('param-sr').addEventListener('change', (e) => {
    sampleRate = parseInt(e.target.value, 10);
    document.getElementById('val-sr').textContent = `${sampleRate.toLocaleString()} Hz`;
    currentSamples = generatePreset('sine', sampleRate, 1.0);
    document.getElementById('audio-meta').textContent = `1.00s @ ${sampleRate}Hz`;
    runExtraction();
  });

  document.getElementById('param-nfft').addEventListener('change', (e) => {
    document.getElementById('val-nfft').textContent = e.target.value;
    runExtraction();
  });

  document.getElementById('param-hop').addEventListener('change', (e) => {
    document.getElementById('val-hop').textContent = e.target.value;
    runExtraction();
  });

  document.getElementById('param-mels').addEventListener('change', (e) => {
    document.getElementById('val-mels').textContent = e.target.value;
    runExtraction();
  });

  document.getElementById('param-mfcc').addEventListener('change', (e) => {
    document.getElementById('val-mfcc').textContent = e.target.value;
    runExtraction();
  });

  // WAV File Input
  const fileInput = document.getElementById('audio-file-input');
  fileInput.addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const arrayBuffer = await file.arrayBuffer();
    const bytes = new Uint8Array(arrayBuffer);

    const nFft = parseInt(document.getElementById('param-nfft').value, 10);
    const hopLength = parseInt(document.getElementById('param-hop').value, 10);
    const nMels = parseInt(document.getElementById('param-mels').value, 10);
    const nMfcc = parseInt(document.getElementById('param-mfcc').value, 10);

    const startTime = performance.now();
    // Use MoonBit native WAV decoder + feature extraction pipeline
    const resStr = process_wav_bytes(Array.from(bytes), nFft, hopLength, nMels, nMfcc);
    const durationMs = Math.round((performance.now() - startTime) * 10) / 10;

    try {
      const parsed = JSON.parse(resStr);
      if (parsed.success) {
        lastResult = parsed;
        sampleRate = parsed.sample_rate;
        document.getElementById('param-sr').value = sampleRate.toString();
        document.getElementById('val-sr').textContent = `${sampleRate.toLocaleString()} Hz`;
        document.getElementById('dsp-latency').textContent = `${durationMs} ms latency`;
        document.getElementById('metric-latency').textContent = `${durationMs} ms`;
        document.getElementById('metric-frames').textContent = `${parsed.n_frames} frames`;
        document.getElementById('metric-bins').textContent = `${parsed.n_freq_bins} bins`;
        document.getElementById('audio-meta').textContent = `${file.name} (${(parsed.num_samples / sampleRate).toFixed(2)}s)`;

        drawHeatmap(document.getElementById('canvas-stft'), parsed.stft_preview);
        drawHeatmap(document.getElementById('canvas-mel'), parsed.log_mel);
        drawHeatmap(document.getElementById('canvas-mfcc'), parsed.mfcc);
        drawFilterbank(document.getElementById('canvas-filterbank'), nMels, sampleRate, nFft);
      } else {
        alert('WAV Parsing error: ' + parsed.error);
      }
    } catch (err) {
      console.error(err);
    }
  });

  // MFCC Hover Tooltip
  const canvasMfcc = document.getElementById('canvas-mfcc');
  canvasMfcc.addEventListener('mousemove', (e) => {
    if (!lastResult || !lastResult.mfcc) return;
    const rect = canvasMfcc.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const cols = lastResult.mfcc[0].length;
    const rows = lastResult.mfcc.length;
    const frame = Math.floor((x / rect.width) * cols);
    const coeffIdx = Math.floor((1.0 - y / rect.height) * rows);

    if (frame >= 0 && frame < cols && coeffIdx >= 0 && coeffIdx < rows) {
      const val = lastResult.mfcc[coeffIdx][frame].toFixed(3);
      document.getElementById('mfcc-tooltip-val').textContent = `Frame ${frame}, C${coeffIdx}: ${val}`;
    }
  });

  // Export JSON
  document.getElementById('btn-export-json').addEventListener('click', () => {
    if (!lastResult) return;
    const blob = new Blob([JSON.stringify(lastResult, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `moonmel_features_${Date.now()}.json`;
    a.click();
    URL.revokeObjectURL(url);
  });

  // Export CSV
  document.getElementById('btn-export-csv').addEventListener('click', () => {
    if (!lastResult || !lastResult.mfcc) return;
    const mfccs = lastResult.mfcc;
    const nCoeffs = mfccs.length;
    const nFrames = mfccs[0].length;

    let csv = 'frame,' + Array.from({ length: nCoeffs }, (_, i) => `c${i}`).join(',') + '\n';
    for (let f = 0; f < nFrames; f++) {
      const row = [f];
      for (let c = 0; c < nCoeffs; c++) {
        row.push(mfccs[c][f]);
      }
      csv += row.join(',') + '\n';
    }

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `moonmel_mfcc_${Date.now()}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  });

  // Live Microphone Streaming
  const btnMic = document.getElementById('btn-mic-stream');
  const micStatus = document.getElementById('mic-status');
  const micIcon = document.getElementById('mic-icon');
  const micText = document.getElementById('mic-text');

  let isStreamingMic = false;
  let micStream = null;
  let micAudioCtx = null;
  let micNode = null;
  let liveBuffer = [];

  btnMic.addEventListener('click', async () => {
    if (isStreamingMic) {
      // Stop streaming
      isStreamingMic = false;
      if (micStream) {
        micStream.getTracks().forEach((t) => t.stop());
        micStream = null;
      }
      if (micNode) {
        micNode.disconnect();
        micNode = null;
      }
      if (micAudioCtx) {
        await micAudioCtx.close();
        micAudioCtx = null;
      }
      btnMic.classList.remove('bg-rose-900/60', 'text-rose-200', 'border-rose-500');
      btnMic.classList.add('bg-studio-850', 'text-slate-300', 'border-studio-700');
      micText.textContent = 'Live Mic';
      micIcon.textContent = '🎙️';
      micStatus.classList.add('hidden');
      return;
    }

    try {
      micStream = await navigator.mediaDevices.getUserMedia({
        audio: { echoCancellation: true, noiseSuppression: true },
      });
      micAudioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const source = micAudioCtx.createMediaStreamSource(micStream);

      micNode = micAudioCtx.createScriptProcessor(2048, 1, 1);
      liveBuffer = [];

      let lastUpdateTime = Date.now();
      micNode.onaudioprocess = (e) => {
        if (!isStreamingMic) return;
        const inputData = e.inputBuffer.getChannelData(0);
        for (let i = 0; i < inputData.length; i++) {
          liveBuffer.push(inputData[i]);
        }
        const maxLen = micAudioCtx.sampleRate;
        if (liveBuffer.length > maxLen) {
          liveBuffer = liveBuffer.slice(liveBuffer.length - maxLen);
        }

        const now = Date.now();
        if (now - lastUpdateTime > 70 && liveBuffer.length >= 1024) {
          lastUpdateTime = now;
          currentSamples = liveBuffer.slice();
          sampleRate = micAudioCtx.sampleRate;
          document.getElementById('audio-meta').textContent = `${(currentSamples.length / sampleRate).toFixed(2)}s @ ${sampleRate}Hz`;
          runExtraction();
        }
      };

      source.connect(micNode);
      micNode.connect(micAudioCtx.destination);

      isStreamingMic = true;
      btnMic.classList.remove('bg-studio-850', 'text-slate-300', 'border-studio-700');
      btnMic.classList.add('bg-rose-900/60', 'text-rose-200', 'border-rose-500');
      micText.textContent = 'Stop Mic';
      micIcon.textContent = '⏹️';
      micStatus.classList.remove('hidden');
    } catch (err) {
      console.error('Microphone access denied or unavailable:', err);
      alert('Could not access microphone: ' + err.message);
    }
  });

  // Handle Window Resize
  window.addEventListener('resize', () => {
    if (lastResult) {
      drawWaveform(document.getElementById('canvas-waveform'), currentSamples, sampleRate);
      drawHeatmap(document.getElementById('canvas-stft'), lastResult.stft_preview);
      drawHeatmap(document.getElementById('canvas-mel'), lastResult.log_mel);
      drawHeatmap(document.getElementById('canvas-mfcc'), lastResult.mfcc);
      drawFilterbank(document.getElementById('canvas-filterbank'), lastResult.n_mels, sampleRate, lastResult.n_fft);
    }
  });
});
