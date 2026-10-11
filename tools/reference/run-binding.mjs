import { process_audio_config } from '../../playground/src/generated/moonmel.js';

let input = '';
for await (const chunk of process.stdin) input += chunk;
const cases = JSON.parse(input);
const results = cases.map(({ samples, sample_rate, n_fft, hop_length, win_length, n_mels, n_mfcc, center, power }) =>
  JSON.parse(process_audio_config(samples, sample_rate, n_fft, hop_length, win_length, n_mels, n_mfcc, center, power)),
);
process.stdout.write(JSON.stringify(results));
