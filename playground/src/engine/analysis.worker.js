import { process_audio, decode_wav_audio } from '../moonmel.js';
import { validateAnalysis } from '../domain/signals.js';

self.onmessage = ({ data: { id, type, samples, sampleRate, config, bytes } }) => {
  try {
    if (type === 'decode') {
      if (bytes.byteLength > 10 * 1024 * 1024) throw new Error('WAV 超过 10 MB，请截取较短的音频。');
      const audio = JSON.parse(decode_wav_audio(new Uint8Array(bytes)));
      if (!audio.success) throw new Error(audio.error);
      const totalSamples = audio.samples.length;
      const preview = new Float64Array(audio.samples.slice(0, audio.sample_rate * 10));
      self.postMessage({ id, audio: { samples: preview, sampleRate: audio.sample_rate, totalSamples } }, [preview.buffer]);
      return;
    }
    validateAnalysis(samples, sampleRate, config);
    const start = performance.now();
    const result = JSON.parse(process_audio(Array.from(samples), sampleRate, config.fft, config.hop, config.mels, config.mfcc));
    if (!result.success) throw new Error(result.error);
    self.postMessage({ id, result, milliseconds: performance.now() - start });
  } catch (error) {
    self.postMessage({ id, error: error.message || String(error) });
  }
};
