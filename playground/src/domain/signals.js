export function generateSignal(kind, sampleRate, duration) {
  const samples = new Float64Array(Math.floor(sampleRate * duration));
  const tau = 2 * Math.PI;
  for (let i = 0; i < samples.length; i++) {
    const t = i / sampleRate;
    switch (kind) {
      case 'sine': samples[i] = .8 * Math.sin(tau * 440 * t); break;
      case 'chord': samples[i] = .5 * Math.sin(tau * 440 * t) + .3 * Math.sin(tau * 1000 * t) + .2 * Math.sin(tau * 2500 * t); break;
      case 'chirp': samples[i] = .75 * Math.sin(tau * (100 * t + (4000 - 100) * t * t / (2 * duration))); break;
      case 'vowel': samples[i] = .5 * Math.sin(tau * 130 * t) + .25 * Math.sin(tau * 500 * t) + .15 * Math.sin(tau * 1500 * t) + .1 * Math.sin(tau * 2500 * t); break;
      case 'silence': break;
      default: throw new Error('Unknown synthetic signal');
    }
  }
  return samples;
}

export function validateAnalysis(samples, sampleRate, config) {
  if (!samples.length || sampleRate <= 0) throw new Error('没有有效音频，请选择合成信号或 PCM WAV。');
  if (!samples.every(Number.isFinite)) throw new Error('音频包含非有限数值，请更换输入。');
  if (!Number.isInteger(config.fft) || config.fft < 2 || config.fft > 4096 ||
      !Number.isInteger(config.hop) || config.hop < 1 || config.hop > 4096 ||
      !Number.isInteger(config.mels) || config.mels < 1 || config.mels > 128 ||
      !Number.isInteger(config.mfcc) || config.mfcc < 1 || config.mfcc > 40) {
    throw new Error('分析参数超出演示范围，请使用界面提供的数值。');
  }
  if (1 + Math.floor(samples.length / config.hop) > 2000) {
    throw new Error('预览超过 2,000 帧；请增加帧步长或缩短音频。');
  }
}

export function mfccCsv(result) {
  const header = ['frame', ...result.mfcc.map((_, i) => `c${i}`)];
  const rows = Array.from({ length: result.n_frames }, (_, frame) => [frame, ...result.mfcc.map((row) => row[frame])].join(','));
  return [header.join(','), ...rows].join('\n') + '\n';
}
