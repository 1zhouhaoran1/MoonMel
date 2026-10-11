import report from '../../../tools/reference/parity_report.json';
import reportUrl from '../../../tools/reference/parity_report.json?url';

export function renderEvidence() {
  const summary = document.getElementById('parity-summary');
  summary.textContent = `${report.passed ? '通过' : '未通过'} · ${report.cases.length} 组确定性参考验证`;
  document.getElementById('reference-convention').textContent = `librosa ${report.reference.librosa} · reflect 填充 · 周期 Hann · float64 Slaney · 正交 DCT-II`;
  const labels = { tone: '440 Hz 正弦', silence: '静音', noise: '噪声', 'short-window': '短窗', 'whisper-fft': '400 点 FFT', 'odd-fft': '奇数 FFT', magnitude: '幅度谱', 'single-sample': '单样本' };
  const body = document.getElementById('parity-rows');
  for (const row of report.cases) {
    const tr = document.createElement('tr');
    const heading = document.createElement('th'); heading.scope = 'row'; heading.textContent = labels[row.case] ?? row.case; tr.append(heading);
    for (const stage of ['mel', 'log_mel', 'mfcc']) {
      const cell = document.createElement('td'); cell.textContent = row.max_absolute_error[stage].toExponential(1); tr.append(cell);
    }
    body.append(tr);
  }
  const download = document.getElementById('report-download'); download.href = reportUrl; download.download = 'moonmel-parity-report.json';
}
