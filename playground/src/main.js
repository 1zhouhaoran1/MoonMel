import '@fontsource-variable/manrope';
import './style.css';
import { generateSignal, mfccCsv } from './domain/signals.js';
import { AnalysisClient } from './engine/client.js';
import { AudioSession } from './audio/session.js';
import { heatmap, waveform, filterbank } from './render/plots.js';
import { renderEvidence } from './render/evidence.js';

const element = (id) => document.getElementById(id);
const engine = new AnalysisClient();
const audio = new AudioSession();
const state = { samples: null, sampleRate: 16000, source: 'synthetic', sourceName: '合成信号', result: null, view: 'log_mel', frame: 0, revision: 0, inputRevision: 0, loadingAudio: false, busy: false, pending: false, microphone: false, micStarting: false };
const config = () => ({ fft: Number(element('fft').value), hop: Number(element('hop').value), mels: Number(element('mels').value), mfcc: Number(element('mfcc').value) });
function error(message) { element('error').textContent = message; element('error').hidden = !message; }
function stopPlayback() { audio.stopPlayback(); element('play').textContent = '播放声音'; }
function invalidate() {
  state.revision++; state.result = null;
  for (const id of ['play', 'export-json', 'export-csv']) element(id).disabled = true;
  error('');
}
function synthetic() {
  state.inputRevision++; state.loadingAudio = false;
  invalidate(); stopPlayback();
  state.source = 'synthetic'; state.sourceName = '合成 · ' + element('signal').selectedOptions[0].textContent.replace('合成 · ', '');
  state.sampleRate = Number(element('sample-rate').value);
  state.samples = generateSignal(element('signal').value, state.sampleRate, Number(element('duration').value));
  element('sample-rate').disabled = false; element('duration').disabled = false;
  element('audio-file').value = '';
  run();
}
function readout() {
  if (!state.result) return;
  const matrix = state.result[state.view];
  state.frame = Math.max(0, Math.min(state.result.n_frames - 1, state.frame));
  let value = matrix[0][state.frame];
  if (state.view === 'mfcc') element('frame-readout').textContent = `帧 ${state.frame} · C0 ${value.toFixed(3)}`;
  else {
    let best = 0;
    for (let r = 1; r < matrix.length; r++) if (matrix[r][state.frame] > value) { best = r; value = matrix[r][state.frame]; }
    const name = state.view === 'log_mel' ? `Mel ${best}` : `${(state.result.stft_bin_indices[best] * state.sampleRate / state.result.n_fft).toFixed(0)} Hz`;
    element('frame-readout').textContent = `帧 ${state.frame} · 峰值 ${name} · ${value.toFixed(3)}`;
  }
}
function render() {
  if (!state.result) return;
  const result = state.result;
  const range = heatmap(element('spectrum'), result[state.view], state.view);
  const duration = state.samples.length / state.sampleRate;
  const isMfcc = state.view === 'mfcc', isStft = state.view === 'stft_preview';
  element('axis-high').textContent = isMfcc ? `C${result.n_mfcc - 1}` : isStft ? `${Math.floor(result.n_fft / 2) * state.sampleRate / result.n_fft / 1000} kHz` : `Mel ${result.n_mels - 1}`;
  element('axis-low').textContent = isMfcc ? 'C0' : isStft ? '0 Hz' : 'Mel 0';
  element('plot-title').textContent = isMfcc ? 'MFCC · 自适应系数色阶' : `${isStft ? 'STFT' : 'Log-Mel'} · ${range.low.toFixed(1)} 至 ${range.high.toFixed(1)} dB`;
  element('time-end').textContent = `${duration.toFixed(2)} s`;
  element('plot-description').textContent = `${result[state.view].length} 行 × ${result.n_frames} 帧；低频在下，时间从左向右。`;
  element('dimensions').textContent = `${result.n_freq_bins} FFT bins · ${result.n_mels} Mel · ${result.n_mfcc} MFCC`;
  element('audio-meta').textContent = `${state.sourceName} · ${duration.toFixed(2)} s @ ${state.sampleRate.toLocaleString()} Hz`;
  element('waveform-description').textContent = `${state.sourceName} · 当前实际 PCM 输入`;
  waveform(element('waveform'), state.samples);
  if (element('filter-details').open) filterbank(element('filterbank'), result.filterbank);
  readout();
}
async function run() {
  state.pending = true;
  if (state.busy || state.loadingAudio) return;
  state.busy = true;
  try {
    while (state.pending) {
      if (state.loadingAudio) break;
      state.pending = false;
      const revision = state.revision;
      element('results').setAttribute('aria-busy', 'true'); element('compute-status').textContent = '正在计算';
      try {
        const response = await engine.request({ type: 'analyze', samples: state.samples, sampleRate: state.sampleRate, config: config() });
        if (revision !== state.revision) continue;
        state.result = response.result;
        element('compute-status').textContent = `${response.milliseconds.toFixed(1)} ms · 本机计算含序列化`;
        for (const id of ['play', 'export-json', 'export-csv']) element(id).disabled = false;
        render();
      } catch (failure) {
        if (revision === state.revision) { error(failure.message); element('compute-status').textContent = '计算未完成'; }
      }
    }
  } finally { state.busy = false; element('results').setAttribute('aria-busy', String(state.loadingAudio)); }
}
async function stopMicrophone() {
  state.microphone = false;
  await audio.stopMicrophone();
  element('microphone').textContent = '使用麦克风';
}
element('analysis-form').addEventListener('submit', (event) => { event.preventDefault(); invalidate(); run(); });
for (const id of ['fft', 'hop', 'mels', 'mfcc']) element(id).addEventListener('change', () => { invalidate(); run(); });
for (const id of ['signal', 'sample-rate', 'duration']) element(id).addEventListener('change', async () => { await stopMicrophone(); synthetic(); });
element('audio-file').addEventListener('change', async () => {
  const file = element('audio-file').files[0]; if (!file) return;
  await stopMicrophone(); stopPlayback(); invalidate();
  const inputRevision = ++state.inputRevision;
  state.loadingAudio = true;
  element('results').setAttribute('aria-busy', 'true'); element('compute-status').textContent = '正在解码 WAV';
  try {
    if (file.size > 10 * 1024 * 1024) throw new Error('WAV 超过 10 MB，请截取较短的音频。');
    const bytes = await file.arrayBuffer();
    const { audio: decoded } = await engine.request({ type: 'decode', bytes }, [bytes]);
    if (inputRevision !== state.inputRevision) return;
    state.samples = decoded.samples; state.sampleRate = decoded.sampleRate; state.source = 'file';
    state.sourceName = file.name + (decoded.totalSamples > decoded.samples.length ? '（前 10 秒）' : '');
    element('sample-rate').disabled = true; element('duration').disabled = true;
    state.loadingAudio = false;
    run();
  } catch (failure) {
    if (inputRevision === state.inputRevision) {
      state.loadingAudio = false; state.pending = false;
      element('audio-file').value = ''; element('results').setAttribute('aria-busy', 'false');
      element('compute-status').textContent = 'WAV 未解码'; error(failure.message);
    }
  }
});
element('play').addEventListener('click', async () => {
  if (audio.source) { stopPlayback(); return; }
  try { await audio.play(state.samples, state.sampleRate, () => { element('play').textContent = '播放声音'; }); element('play').textContent = '停止播放'; }
  catch (failure) { error(failure.message); }
});
element('microphone').addEventListener('click', async () => {
  if (state.micStarting) return;
  if (state.microphone) { await stopMicrophone(); return; }
  state.micStarting = true; element('microphone').disabled = true; error(''); stopPlayback();
  state.inputRevision++; state.loadingAudio = false;
  let rolling = new Float64Array(0), lastUpdate = 0;
  try {
    state.microphone = true;
    await audio.startMicrophone((chunk, sampleRate) => {
      if (!state.microphone) return;
      const joined = new Float64Array(rolling.length + chunk.length); joined.set(rolling); joined.set(chunk, rolling.length);
      rolling = joined.slice(Math.max(0, joined.length - sampleRate));
      if (performance.now() - lastUpdate < 500 || state.busy || rolling.length < 2048) return;
      lastUpdate = performance.now(); invalidate(); state.samples = rolling; state.sampleRate = sampleRate; state.source = 'microphone'; state.sourceName = '麦克风 · 最近一秒';
      element('sample-rate').disabled = true; element('duration').disabled = true;
      run();
    });
    element('microphone').textContent = '停止麦克风';
  } catch (failure) { state.microphone = false; error(`麦克风无法启用：${failure.message}`); }
  finally { state.micStarting = false; element('microphone').disabled = false; }
});
document.querySelectorAll('[data-view]').forEach((button) => button.addEventListener('click', () => {
  state.view = button.dataset.view;
  document.querySelectorAll('[data-view]').forEach((item) => item.setAttribute('aria-pressed', String(item === button)));
  render();
}));
element('spectrum').addEventListener('pointermove', (event) => {
  if (!state.result) return;
  const rect = event.currentTarget.getBoundingClientRect(); state.frame = Math.floor((event.clientX - rect.left) / rect.width * state.result.n_frames); readout();
});
element('spectrum').addEventListener('keydown', (event) => {
  if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
  event.preventDefault(); state.frame += event.key === 'ArrowRight' ? 1 : -1; readout();
});
function download(content, name, type) {
  const url = URL.createObjectURL(new Blob([content], { type }));
  const anchor = document.createElement('a'); anchor.href = url; anchor.download = name; anchor.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
element('export-json').addEventListener('click', () => { if (state.result) download(JSON.stringify(state.result, null, 2), 'moonmel-features.json', 'application/json'); });
element('export-csv').addEventListener('click', () => { if (state.result) download(mfccCsv(state.result), 'moonmel-mfcc.csv', 'text/csv'); });
element('filter-details').addEventListener('toggle', () => { if (state.result && element('filter-details').open) filterbank(element('filterbank'), state.result.filterbank); });
let resizeFrame;
new ResizeObserver(() => { cancelAnimationFrame(resizeFrame); resizeFrame = requestAnimationFrame(render); }).observe(element('results'));
window.addEventListener('pagehide', () => { audio.dispose(); engine.dispose(); });
renderEvidence(); synthetic();
