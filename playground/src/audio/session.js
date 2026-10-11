import workletUrl from './capture.worklet.js?url';

export class AudioSession {
  async play(samples, sampleRate, onEnd) {
    this.stopPlayback();
    this.playContext ??= new AudioContext();
    await this.playContext.resume();
    const buffer = this.playContext.createBuffer(1, samples.length, sampleRate);
    buffer.getChannelData(0).set(samples);
    this.source = this.playContext.createBufferSource();
    this.source.buffer = buffer; this.source.connect(this.playContext.destination);
    this.source.onended = () => { this.source = null; onEnd(); };
    this.source.start();
  }
  stopPlayback() {
    if (this.source) { this.source.onended = null; this.source.stop(); this.source.disconnect(); this.source = null; }
  }
  async startMicrophone(onChunk) {
    if (!navigator.mediaDevices?.getUserMedia) throw new Error('麦克风需要 HTTPS 或 localhost。');
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ audio: { echoCancellation: false, noiseSuppression: false, autoGainControl: false } });
      this.micContext = new AudioContext();
      await this.micContext.resume();
      await this.micContext.audioWorklet.addModule(workletUrl);
      this.micSource = this.micContext.createMediaStreamSource(this.stream);
      this.capture = new AudioWorkletNode(this.micContext, 'moonmel-capture');
      this.capture.port.onmessage = ({ data }) => onChunk(data, this.micContext.sampleRate);
      this.mute = this.micContext.createGain(); this.mute.gain.value = 0;
      this.micSource.connect(this.capture); this.capture.connect(this.mute); this.mute.connect(this.micContext.destination);
    } catch (error) { await this.stopMicrophone(); throw error; }
  }
  async stopMicrophone() {
    this.stream?.getTracks().forEach((track) => track.stop());
    if (this.capture) { this.capture.port.onmessage = null; this.capture.disconnect(); }
    this.micSource?.disconnect(); this.mute?.disconnect();
    if (this.micContext && this.micContext.state !== 'closed') await this.micContext.close();
    this.stream = this.capture = this.micSource = this.mute = this.micContext = null;
  }
  dispose() { this.stopPlayback(); void this.stopMicrophone(); void this.playContext?.close(); }
}
