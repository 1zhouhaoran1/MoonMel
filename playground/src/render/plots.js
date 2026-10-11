function context(canvas) {
  const { width, height } = canvas.getBoundingClientRect();
  const ratio = Math.min(devicePixelRatio || 1, 2);
  canvas.width = Math.max(1, Math.round(width * ratio));
  canvas.height = Math.max(1, Math.round(height * ratio));
  const ctx = canvas.getContext('2d');
  ctx.scale(ratio, ratio);
  return { ctx, width, height };
}
const stops = [[21, 20, 18], [79, 47, 35], [169, 58, 31], [220, 147, 85], [247, 231, 190]];
function color(value) {
  const position = Math.max(0, Math.min(1, value)) * (stops.length - 1);
  const index = Math.min(stops.length - 2, Math.floor(position));
  return stops[index].map((c, i) => Math.round(c + (stops[index + 1][i] - c) * (position - index)));
}
export function heatmap(canvas, matrix, view) {
  const { ctx, width, height } = context(canvas);
  const rows = matrix.length, columns = matrix[0]?.length ?? 0;
  if (!rows || !columns) return;
  let high = -Infinity, low = Infinity;
  const transformed = matrix.map((row) => row.map((v) => view === 'stft_preview' ? 10 * Math.log10(Math.max(v, 1e-10)) : v));
  for (const row of transformed) for (const value of row) { high = Math.max(high, value); low = Math.min(low, value); }
  if (view !== 'mfcc') low = high - 80;
  const range = Math.max(high - low, 1e-12);
  const image = new ImageData(columns, rows);
  for (let y = 0; y < rows; y++) for (let x = 0; x < columns; x++) {
    const rgb = color((transformed[rows - 1 - y][x] - low) / range);
    image.data.set([...rgb, 255], (y * columns + x) * 4);
  }
  const scratch = document.createElement('canvas'); scratch.width = columns; scratch.height = rows;
  scratch.getContext('2d').putImageData(image, 0, 0);
  ctx.imageSmoothingEnabled = false; ctx.drawImage(scratch, 0, 0, width, height);
  return { low, high };
}
export function waveform(canvas, samples) {
  const { ctx, width, height } = context(canvas);
  ctx.strokeStyle = '#6b5c4a'; ctx.beginPath(); ctx.moveTo(0, height / 2); ctx.lineTo(width, height / 2); ctx.stroke();
  if (!samples?.length) return;
  let peak = 1;
  for (const sample of samples) peak = Math.max(peak, Math.abs(sample));
  ctx.strokeStyle = '#c49368'; ctx.beginPath();
  // Map each pixel to its actual sample interval, including the final sample.
  for (let x = 0; x < width; x++) {
    const start = Math.floor(x * samples.length / width);
    const end = Math.min(samples.length, Math.max(start + 1, Math.floor((x + 1) * samples.length / width)));
    let minimum = 0, maximum = 0;
    for (let i = start; i < end; i++) { minimum = Math.min(minimum, samples[i]); maximum = Math.max(maximum, samples[i]); }
    ctx.moveTo(x, height / 2 - maximum / peak * height * .44); ctx.lineTo(x, height / 2 - minimum / peak * height * .44);
  }
  ctx.stroke();
}
export function filterbank(canvas, matrix) {
  const { ctx, width, height } = context(canvas);
  const bins = matrix[0]?.length ?? 0;
  let peak = 1e-12;
  for (const row of matrix) for (const value of row) peak = Math.max(peak, value);
  ctx.lineWidth = 1;
  for (let r = 0; r < matrix.length; r++) {
    ctx.strokeStyle = r % 2 ? '#947355' : '#d3a878'; ctx.beginPath();
    for (let k = 0; k < bins; k++) {
      const x = k / Math.max(1, bins - 1) * width;
      const y = height - matrix[r][k] / peak * (height - 8);
      if (k === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.stroke();
  }
}
