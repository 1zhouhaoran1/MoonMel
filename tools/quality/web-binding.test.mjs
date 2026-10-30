import test from 'node:test';
import assert from 'node:assert/strict';
import { decode_wav_audio, process_audio, process_audio_config, process_wav_bytes } from '../../playground/src/moonmel.js';

function wav() {
  const bytes = new Uint8Array(48);
  const view = new DataView(bytes.buffer);
  for (const [offset, tag] of [[0, 'RIFF'], [8, 'WAVE'], [12, 'fmt '], [36, 'data']]) {
    [...tag].forEach((char, i) => { bytes[offset + i] = char.charCodeAt(0); });
  }
  view.setUint32(4, 40, true); view.setUint32(16, 16, true);
  view.setUint16(20, 1, true); view.setUint16(22, 1, true);
  view.setUint32(24, 16000, true); view.setUint32(28, 32000, true);
  view.setUint16(32, 2, true); view.setUint16(34, 16, true);
  view.setUint32(40, 4, true); view.setInt16(44, 16384, true); view.setInt16(46, -16384, true);
  return bytes;
}
test('invalid inputs have a parseable failure envelope', () => {
  for (const args of [ [[], 16000, 1024, 256, 80, 13], [[NaN], 16000, 8, 4, 4, 2],
    [[0.1], 0, 8, 4, 4, 2], [[0.1], 16000, 8, 0, 4, 2], [[0.1], 16000, 8, 4, 0, 2] ]) {
    const result = JSON.parse(process_audio(...args));
    assert.equal(result.success, false);
    assert.equal(typeof result.error, 'string');
  }
});
test('WAV samples and later recomputation use the same audio', () => {
  const bytes = wav();
  const audio = JSON.parse(decode_wav_audio(bytes));
  assert.deepEqual(audio.samples, [0.5, -0.5]);
  assert.equal(audio.sample_rate, 16000);
  const direct = JSON.parse(process_audio(audio.samples, audio.sample_rate, 8, 4, 4, 2));
  assert.deepEqual(JSON.parse(process_wav_bytes(bytes, 8, 4, 4, 2)), direct);
});
test('hostile unsigned chunk sizes never hang or index beyond the file', { timeout: 3000 }, () => {
  const bytes = wav();
  for (const size of [0xffffffff, 0x7fffffff, 400]) {
    new DataView(bytes.buffer).setUint32(16, size, true);
    assert.equal(JSON.parse(decode_wav_audio(bytes)).success, false);
  }
});
test('wide integer PCM reaches browser decode and analysis with signed values intact', () => {
  for (const bits of [24, 32]) {
    const width = bits / 8;
    const bytes = new Uint8Array(44 + width * 2);
    bytes.set(wav().subarray(0, 44));
    const view = new DataView(bytes.buffer);
    view.setUint32(4, bytes.length - 8, true);
    view.setUint32(28, 16000 * width, true);
    view.setUint16(32, width, true);
    view.setUint16(34, bits, true);
    view.setUint32(40, width * 2, true);
    bytes[44 + width - 1] = 0x40;
    bytes[44 + width * 2 - 1] = 0xc0;
    const audio = JSON.parse(decode_wav_audio(bytes));
    assert.equal(audio.success, true);
    assert.deepEqual(audio.samples, [0.5, -0.5]);
    assert.deepEqual(JSON.parse(process_wav_bytes(bytes, 8, 4, 4, 2)),
      JSON.parse(process_audio([0.5, -0.5], 16000, 8, 4, 4, 2)));
  }
});
test('arbitrary FFTs retain their frequency grid and endpoint previews', () => {
  for (const fft of [5, 255, 400, 512, 1024]) {
    const result = JSON.parse(process_audio(Array.from({ length: 1200 }, (_, i) => Math.sin(i * 0.17)), 16000, fft, 64, 24, 13));
    assert.equal(result.success, true);
    assert.equal(result.n_freq_bins, Math.floor(fft / 2) + 1);
    assert.equal(result.stft_bin_indices.at(-1), result.n_freq_bins - 1);
    assert.equal(result.mfcc.length, 13);
    assert.ok(result.mfcc.flat().every(Number.isFinite));
  }
});
test('short centered window reads the middle of a full FFT frame', () => {
  const result = JSON.parse(process_audio_config([0, 1, 2, 3, 4, 5, 6, 7], 16000, 8, 4, 4, 4, 2, false, 2));
  assert.equal(result.success, true);
  // Periodic Hann [0, .5, 1, .5] over samples [2,3,4,5]: DC=8.
  assert.ok(Math.abs(result.stft_preview[0][0] - 64) < 1e-10);
});
