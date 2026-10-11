export class AnalysisClient {
  constructor() {
    this.pending = new Map();
    this.nextId = 0;
    this.worker = new Worker(new URL('./analysis.worker.js', import.meta.url), { type: 'module' });
    this.worker.onmessage = ({ data }) => {
      const pending = this.pending.get(data.id);
      if (!pending) return;
      clearTimeout(pending.timeout);
      this.pending.delete(data.id);
      if (data.error) pending.reject(new Error(data.error)); else pending.resolve(data);
    };
    this.worker.onerror = () => this.fail(new Error('计算引擎加载失败，请刷新页面。'));
  }
  request(data, transfer = []) {
    const id = ++this.nextId;
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => this.fail(new Error('计算超过 30 秒，请刷新并使用较短音频。')), 30000);
      this.pending.set(id, { resolve, reject, timeout });
      this.worker.postMessage({ id, ...data }, transfer);
    });
  }
  fail(error) {
    for (const entry of this.pending.values()) { clearTimeout(entry.timeout); entry.reject(error); }
    this.pending.clear();
    this.worker.terminate();
  }
  dispose() { this.fail(new Error('计算引擎已关闭。')); }
}
