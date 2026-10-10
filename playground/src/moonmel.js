function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function $oob() {
  throw new Error("Index out of bounds");
}
const _M0MPB7JSArray4copy = (arr) => arr.slice(0);
function _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE2Ok.prototype.$tag = 1;
function _M0DTP53zhr7moonmel3src4core5types8MelError10EmptyAudio() {}
_M0DTP53zhr7moonmel3src4core5types8MelError10EmptyAudio.prototype.$tag = 0;
const _M0DTP53zhr7moonmel3src4core5types8MelError10EmptyAudio__ = new _M0DTP53zhr7moonmel3src4core5types8MelError10EmptyAudio();
function _M0DTP53zhr7moonmel3src4core5types8MelError17InvalidSampleRate(param0) {
  this._0 = param0;
}
_M0DTP53zhr7moonmel3src4core5types8MelError17InvalidSampleRate.prototype.$tag = 1;
function _M0DTP53zhr7moonmel3src4core5types8MelError14InvalidFftSize(param0) {
  this._0 = param0;
}
_M0DTP53zhr7moonmel3src4core5types8MelError14InvalidFftSize.prototype.$tag = 2;
function _M0DTP53zhr7moonmel3src4core5types8MelError16InvalidHopLength(param0) {
  this._0 = param0;
}
_M0DTP53zhr7moonmel3src4core5types8MelError16InvalidHopLength.prototype.$tag = 3;
function _M0DTP53zhr7moonmel3src4core5types8MelError15InvalidMelBands(param0) {
  this._0 = param0;
}
_M0DTP53zhr7moonmel3src4core5types8MelError15InvalidMelBands.prototype.$tag = 4;
function _M0DTP53zhr7moonmel3src4core5types8MelError21InvalidFrequencyRange(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP53zhr7moonmel3src4core5types8MelError21InvalidFrequencyRange.prototype.$tag = 5;
function _M0DTP53zhr7moonmel3src4core5types8MelError17DimensionMismatch(param0) {
  this._0 = param0;
}
_M0DTP53zhr7moonmel3src4core5types8MelError17DimensionMismatch.prototype.$tag = 6;
function _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError(param0) {
  this._0 = param0;
}
_M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError.prototype.$tag = 7;
function _M0TP53zhr7moonmel3src4core5types11AudioBuffer(param0, param1) {
  this.samples = param0;
  this.sample_rate = param1;
}
function _M0TP53zhr7moonmel3src4core5types13FeatureConfig(param0, param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11, param12, param13, param14, param15, param16, param17) {
  this.sample_rate = param0;
  this.n_fft = param1;
  this.hop_length = param2;
  this.win_length = param3;
  this.window = param4;
  this.center = param5;
  this.power = param6;
  this.n_mels = param7;
  this.f_min = param8;
  this.f_max = param9;
  this.mel_scale = param10;
  this.mel_norm = param11;
  this.log_scale = param12;
  this.n_mfcc = param13;
  this.norm_ortho = param14;
  this.ref_value = param15;
  this.amin = param16;
  this.top_db = param17;
}
function _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE2Ok.prototype.$tag = 1;
function _M0TP53zhr7moonmel3src4core5types13FeatureMatrix(param0, param1, param2) {
  this.data = param0;
  this.n_rows = param1;
  this.n_cols = param2;
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function _M0TPB8MutLocalGdE(param0) {
  this.val = param0;
}
function _M0DTPC16result6ResultGRPB5ArrayGdERP53zhr7moonmel3src4core5types8MelErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGdERP53zhr7moonmel3src4core5types8MelErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRPB5ArrayGdERP53zhr7moonmel3src4core5types8MelErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRPB5ArrayGdERP53zhr7moonmel3src4core5types8MelErrorE2Ok.prototype.$tag = 1;
function _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err.prototype.$tag = 0;
function _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(param0) {
  this._0 = param0;
}
_M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok.prototype.$tag = 1;
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
const _M0FP53zhr7moonmel3src3dsp3fft2pi = 3.1415926535897931;
const _M0FP53zhr7moonmel3src3dsp6window2pi = 3.1415926535897931;
const _M0FP53zhr7moonmel3src8features3mel13slaney__f__sp = 66.666666666666671;
const _M0FP53zhr7moonmel3src8features3mel20slaney__min__log__hz = 1000;
const _M0FP53zhr7moonmel3src8features3mel21slaney__min__log__mel = 15;
const _M0FP53zhr7moonmel3src8features4mfcc2pi = 3.1415926535897931;
function _M0MPB13StringBuilder13write__objectGiE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGiE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGdE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGdE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGRP53zhr7moonmel3src4core5types8MelErrorE(self, obj) {
  _M0IP53zhr7moonmel3src4core5types8MelErrorPB4Show6output(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGsE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGsE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder21StringBuilder_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
}
function _M0MPB13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return self >= 56320 && self <= 57343;
}
function _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC16string6String11sub_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    const _end = _Some;
    end$2 = _end;
  }
  if (start >= 0 && (start <= end$2 && end$2 <= len)) {
    if (start < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start))) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0IP016_24default__implPB4Show6outputGiE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC13int3IntPB4Show10to__string(self));
}
function _M0IP016_24default__implPB4Show6outputGdE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC16double6DoublePB4Show10to__string(self));
}
function _M0IP016_24default__implPB4Show6outputGsE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC16string6StringPB4Show10to__string(self));
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
}
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0IPC13int3IntPB4Show10to__string(self) {
  return _M0MPC13int3Int18to__string_2einner(self, 10);
}
function _M0IPC16double6DoublePB4Show10to__string(self) {
  return String(self);
}
function _M0MPC15array5Array9is__emptyGdE(self) {
  return self.length === 0;
}
function _M0MPC15array5Array4copyGdE(self) {
  return _M0MPB7JSArray4copy(self);
}
function _M0MPC15array5Array2atGdE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGRPB5ArrayGdEE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array2atGyE(self, index) {
  const len = self.length;
  return index >= 0 && index < len ? self[index] : $panic();
}
function _M0MPC15array5Array3setGdE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array3setGRPB5ArrayGdEE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array4makeGdE(len, elem) {
  const arr = new Array(len);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < len) {
      arr[i] = elem;
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0MPC15array5Array4makeGRPB5ArrayGdEE(len, elem) {
  const arr = new Array(len);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < len) {
      arr[i] = elem;
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return arr;
}
function _M0FPC14math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FPC14math3cos(_tmp) {
  return Math.cos(_tmp);
}
function _M0FPC14math3pow(_tmp, _tmp$2) {
  return Math.pow(_tmp, _tmp$2);
}
function _M0FPC14math2ln(_tmp) {
  return Math.log(_tmp);
}
function _M0FPC14math5log10(_tmp) {
  return Math.log10(_tmp);
}
function _M0FPC14math3exp(_tmp) {
  return Math.exp(_tmp);
}
function _M0IP53zhr7moonmel3src4core5types8MelErrorPB4Show6output(self, logger) {
  let msg;
  _L: {
    let msg$2;
    _L$2: {
      let fmin;
      let fmax;
      _L$3: {
        let m;
        _L$4: {
          let h;
          _L$5: {
            let n;
            _L$6: {
              let sr;
              _L$7: {
                switch (self.$tag) {
                  case 0: {
                    logger.method_table.method_0(logger.self, "Audio buffer is empty");
                    return;
                  }
                  case 1: {
                    const _InvalidSampleRate = self;
                    const _sr = _InvalidSampleRate._0;
                    sr = _sr;
                    break _L$7;
                  }
                  case 2: {
                    const _InvalidFftSize = self;
                    const _n = _InvalidFftSize._0;
                    n = _n;
                    break _L$6;
                  }
                  case 3: {
                    const _InvalidHopLength = self;
                    const _h = _InvalidHopLength._0;
                    h = _h;
                    break _L$5;
                  }
                  case 4: {
                    const _InvalidMelBands = self;
                    const _m = _InvalidMelBands._0;
                    m = _m;
                    break _L$4;
                  }
                  case 5: {
                    const _InvalidFrequencyRange = self;
                    const _fmin = _InvalidFrequencyRange._0;
                    const _fmax = _InvalidFrequencyRange._1;
                    fmin = _fmin;
                    fmax = _fmax;
                    break _L$3;
                  }
                  case 6: {
                    const _DimensionMismatch = self;
                    const _msg = _DimensionMismatch._0;
                    msg$2 = _msg;
                    break _L$2;
                  }
                  default: {
                    const _WavParseError = self;
                    const _msg$2 = _WavParseError._0;
                    msg = _msg$2;
                    break _L;
                  }
                }
              }
              const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(21);
              _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Invalid sample rate: ");
              _M0MPB13StringBuilder13write__objectGiE(_string_builder, sr);
              logger.method_table.method_0(logger.self, _M0MPB13StringBuilder10to__string(_string_builder));
              return;
            }
            const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(18);
            _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Invalid FFT size: ");
            _M0MPB13StringBuilder13write__objectGiE(_string_builder, n);
            logger.method_table.method_0(logger.self, _M0MPB13StringBuilder10to__string(_string_builder));
            return;
          }
          const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(20);
          _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Invalid hop length: ");
          _M0MPB13StringBuilder13write__objectGiE(_string_builder, h);
          logger.method_table.method_0(logger.self, _M0MPB13StringBuilder10to__string(_string_builder));
          return;
        }
        const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(25);
        _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Invalid mel bands count: ");
        _M0MPB13StringBuilder13write__objectGiE(_string_builder, m);
        logger.method_table.method_0(logger.self, _M0MPB13StringBuilder10to__string(_string_builder));
        return;
      }
      const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(29);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Invalid frequency range: [");
      _M0MPB13StringBuilder13write__objectGdE(_string_builder, fmin);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", ");
      _M0MPB13StringBuilder13write__objectGdE(_string_builder, fmax);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "]");
      logger.method_table.method_0(logger.self, _M0MPB13StringBuilder10to__string(_string_builder));
      return;
    }
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(20);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Dimension mismatch: ");
    _M0MPB13StringBuilder13write__objectGsE(_string_builder, msg$2);
    logger.method_table.method_0(logger.self, _M0MPB13StringBuilder10to__string(_string_builder));
    return;
  }
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(17);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "WAV parse error: ");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, msg);
  logger.method_table.method_0(logger.self, _M0MPB13StringBuilder10to__string(_string_builder));
}
function _M0MP53zhr7moonmel3src4core5types11AudioBuffer3new(samples, sample_rate) {
  if (_M0MPC15array5Array9is__emptyGdE(samples)) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(_M0DTP53zhr7moonmel3src4core5types8MelError10EmptyAudio__);
  }
  if (sample_rate <= 0) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError17InvalidSampleRate(sample_rate));
  }
  return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE2Ok(new _M0TP53zhr7moonmel3src4core5types11AudioBuffer(samples, sample_rate));
}
function _M0MP53zhr7moonmel3src4core5types13FeatureConfig7default() {
  return new _M0TP53zhr7moonmel3src4core5types13FeatureConfig(16000, 1024, 256, 1024, 0, true, 2, 80, 0, 8000, 0, 0, 0, 13, true, 1, 1e-010, 80);
}
function _M0MP53zhr7moonmel3src4core5types13FeatureConfig8validate(self) {
  if (self.sample_rate <= 0) {
    return new _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError17InvalidSampleRate(self.sample_rate));
  }
  if (self.n_fft <= 0) {
    return new _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError14InvalidFftSize(self.n_fft));
  }
  if (self.hop_length <= 0) {
    return new _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError16InvalidHopLength(self.hop_length));
  }
  if (self.n_mels <= 0) {
    return new _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError15InvalidMelBands(self.n_mels));
  }
  const nyquist = (self.sample_rate + 0) / 2;
  if (self.f_min < 0 || (self.f_max <= self.f_min || self.f_max > nyquist)) {
    return new _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError21InvalidFrequencyRange(self.f_min, self.f_max));
  }
  return new _M0DTPC16result6ResultGuRP53zhr7moonmel3src4core5types8MelErrorE2Ok(undefined);
}
function _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(n_rows, n_cols) {
  const data = _M0MPC15array5Array4makeGRPB5ArrayGdEE(n_rows, []);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const r = _tmp;
    if (r < n_rows) {
      _M0MPC15array5Array3setGRPB5ArrayGdEE(data, r, _M0MPC15array5Array4makeGdE(n_cols, 0));
      _tmp = r + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0TP53zhr7moonmel3src4core5types13FeatureMatrix(data, n_rows, n_cols);
}
function _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(self, row, col) {
  return _M0MPC15array5Array2atGdE(_M0MPC15array5Array2atGRPB5ArrayGdEE(self.data, row), col);
}
function _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(self, row, col, val) {
  _M0MPC15array5Array3setGdE(_M0MPC15array5Array2atGRPB5ArrayGdEE(self.data, row), col, val);
}
function _M0FP53zhr7moonmel3src5codec3wav13read__i16__le(bytes, offset) {
  const b0 = _M0MPC15array5Array2atGyE(bytes, offset);
  const b1 = _M0MPC15array5Array2atGyE(bytes, offset + 1 | 0);
  const unsigned = b0 | b1 << 8;
  return unsigned >= 32768 ? unsigned - 65536 | 0 : unsigned;
}
function _M0FP53zhr7moonmel3src5codec3wav13read__u32__le(bytes, offset) {
  const b0 = _M0MPC15array5Array2atGyE(bytes, offset);
  const b1 = _M0MPC15array5Array2atGyE(bytes, offset + 1 | 0);
  const b2 = _M0MPC15array5Array2atGyE(bytes, offset + 2 | 0);
  const b3 = _M0MPC15array5Array2atGyE(bytes, offset + 3 | 0);
  return b0 | b1 << 8 | b2 << 16 | b3 << 24;
}
function _M0FP53zhr7moonmel3src5codec3wav10match__tag(bytes, offset, tag) {
  if ((offset + 4 | 0) > bytes.length) {
    return false;
  }
  const _bind = 0;
  const _bind$2 = 4;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      if (_M0MPC15array5Array2atGyE(bytes, offset + i | 0) !== (i >>> 0 < tag.length ? tag.charCodeAt(i) : $oob())) {
        return false;
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return true;
}
function _M0FP53zhr7moonmel3src5codec3wav11decode__wav(bytes) {
  const len = bytes.length;
  if (len < 44) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError("File is too short to be a valid WAV"));
  }
  if (!_M0FP53zhr7moonmel3src5codec3wav10match__tag(bytes, 0, "RIFF") || !_M0FP53zhr7moonmel3src5codec3wav10match__tag(bytes, 8, "WAVE")) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError("Missing RIFF or WAVE signature"));
  }
  const offset = new _M0TPB8MutLocalGiE(12);
  const channels = new _M0TPB8MutLocalGiE(1);
  const sample_rate = new _M0TPB8MutLocalGiE(16000);
  const bits_per_sample = new _M0TPB8MutLocalGiE(16);
  const audio_format = new _M0TPB8MutLocalGiE(1);
  const data_offset = new _M0TPB8MutLocalGiE(-1);
  const data_size = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if ((offset.val + 8 | 0) <= len) {
      const chunk_size = _M0FP53zhr7moonmel3src5codec3wav13read__u32__le(bytes, offset.val + 4 | 0);
      if (_M0FP53zhr7moonmel3src5codec3wav10match__tag(bytes, offset.val, "fmt ")) {
        if (chunk_size < 16) {
          return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError("Invalid fmt chunk size"));
        }
        audio_format.val = _M0FP53zhr7moonmel3src5codec3wav13read__i16__le(bytes, offset.val + 8 | 0);
        channels.val = _M0FP53zhr7moonmel3src5codec3wav13read__i16__le(bytes, offset.val + 10 | 0);
        sample_rate.val = _M0FP53zhr7moonmel3src5codec3wav13read__u32__le(bytes, offset.val + 12 | 0);
        bits_per_sample.val = _M0FP53zhr7moonmel3src5codec3wav13read__i16__le(bytes, offset.val + 22 | 0);
      } else {
        if (_M0FP53zhr7moonmel3src5codec3wav10match__tag(bytes, offset.val, "data")) {
          data_offset.val = offset.val + 8 | 0;
          data_size.val = chunk_size;
          break;
        }
      }
      let padded_size;
      if (2 === 0) {
        $panic();
      }
      if ((chunk_size % 2 | 0) !== 0) {
        padded_size = chunk_size + 1 | 0;
      } else {
        padded_size = chunk_size;
      }
      offset.val = (offset.val + 8 | 0) + padded_size | 0;
      continue;
    } else {
      break;
    }
  }
  if (data_offset.val < 0 || (data_offset.val + data_size.val | 0) > len) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError("Valid data chunk not found"));
  }
  if (channels.val <= 0) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError("Invalid number of channels"));
  }
  if (8 === 0) {
    $panic();
  }
  const bytes_per_sample = bits_per_sample.val / 8 | 0;
  if (bytes_per_sample <= 0) {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(29);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Unsupported bits per sample: ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, bits_per_sample.val);
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError(_M0MPB13StringBuilder10to__string(_string_builder)));
  }
  const block_align = Math.imul(channels.val, bytes_per_sample) | 0;
  if (block_align === 0) {
    $panic();
  }
  const num_frames = data_size.val / block_align | 0;
  const samples = _M0MPC15array5Array4makeGdE(num_frames, 0);
  if (audio_format.val === 1 && bits_per_sample.val === 16) {
    const _bind = 0;
    let _tmp = _bind;
    while (true) {
      const f = _tmp;
      if (f < num_frames) {
        const sum = new _M0TPB8MutLocalGdE(0);
        const frame_pos = data_offset.val + (Math.imul(f, block_align) | 0) | 0;
        const _bind$2 = 0;
        const _bind$3 = channels.val;
        let _tmp$2 = _bind$2;
        while (true) {
          const ch = _tmp$2;
          if (ch < _bind$3) {
            const sample_pos = frame_pos + (Math.imul(ch, 2) | 0) | 0;
            const raw_val = _M0FP53zhr7moonmel3src5codec3wav13read__i16__le(bytes, sample_pos);
            sum.val = sum.val + (raw_val + 0) / 32768;
            _tmp$2 = ch + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _M0MPC15array5Array3setGdE(samples, f, sum.val / (channels.val + 0));
        _tmp = f + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  } else {
    if (audio_format.val === 1 && bits_per_sample.val === 8) {
      const _bind = 0;
      let _tmp = _bind;
      while (true) {
        const f = _tmp;
        if (f < num_frames) {
          const sum = new _M0TPB8MutLocalGdE(0);
          const frame_pos = data_offset.val + (Math.imul(f, block_align) | 0) | 0;
          const _bind$2 = 0;
          const _bind$3 = channels.val;
          let _tmp$2 = _bind$2;
          while (true) {
            const ch = _tmp$2;
            if (ch < _bind$3) {
              const raw_u8 = _M0MPC15array5Array2atGyE(bytes, frame_pos + ch | 0);
              const normalized = (raw_u8 + 0 - 128) / 128;
              sum.val = sum.val + normalized;
              _tmp$2 = ch + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0MPC15array5Array3setGdE(samples, f, sum.val / (channels.val + 0));
          _tmp = f + 1 | 0;
          continue;
        } else {
          break;
        }
      }
    } else {
      const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(36);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "Unsupported audio format: ");
      _M0MPB13StringBuilder13write__objectGiE(_string_builder, audio_format.val);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, " with ");
      _M0MPB13StringBuilder13write__objectGiE(_string_builder, bits_per_sample.val);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "-bit");
      return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types11AudioBufferRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError13WavParseError(_M0MPB13StringBuilder10to__string(_string_builder)));
    }
  }
  return _M0MP53zhr7moonmel3src4core5types11AudioBuffer3new(samples, sample_rate.val);
}
function _M0FP53zhr7moonmel3src3dsp3fft18is__power__of__two(n) {
  return n > 0 && (n & (n - 1 | 0)) === 0;
}
function _M0FP53zhr7moonmel3src3dsp3fft21bit__reverse__permute(re, im, n) {
  const j = new _M0TPB8MutLocalGiE(0);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < (n - 1 | 0)) {
      if (i < j.val) {
        const tr = _M0MPC15array5Array2atGdE(re, i);
        _M0MPC15array5Array3setGdE(re, i, _M0MPC15array5Array2atGdE(re, j.val));
        _M0MPC15array5Array3setGdE(re, j.val, tr);
        const ti = _M0MPC15array5Array2atGdE(im, i);
        _M0MPC15array5Array3setGdE(im, i, _M0MPC15array5Array2atGdE(im, j.val));
        _M0MPC15array5Array3setGdE(im, j.val, ti);
      }
      if (2 === 0) {
        $panic();
      }
      const k = new _M0TPB8MutLocalGiE(n / 2 | 0);
      while (true) {
        if (k.val <= j.val) {
          j.val = j.val - k.val | 0;
          if (2 === 0) {
            $panic();
          }
          k.val = k.val / 2 | 0;
          continue;
        } else {
          break;
        }
      }
      j.val = j.val + k.val | 0;
      _tmp = i + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0FP53zhr7moonmel3src3dsp3fft14fft__in__place(re, im, n, inverse) {
  _M0FP53zhr7moonmel3src3dsp3fft21bit__reverse__permute(re, im, n);
  const dir = inverse ? 1 : -1;
  const len = new _M0TPB8MutLocalGiE(2);
  while (true) {
    if (len.val <= n) {
      if (2 === 0) {
        $panic();
      }
      const half = len.val / 2 | 0;
      const angle_step = dir * 2 * _M0FP53zhr7moonmel3src3dsp3fft2pi / (len.val + 0);
      const w_step_re = _M0FPC14math3cos(angle_step);
      const w_step_im = _M0FPC14math3sin(angle_step);
      const i = new _M0TPB8MutLocalGiE(0);
      while (true) {
        if (i.val < n) {
          const w_re = new _M0TPB8MutLocalGdE(1);
          const w_im = new _M0TPB8MutLocalGdE(0);
          const _bind = 0;
          let _tmp = _bind;
          while (true) {
            const j = _tmp;
            if (j < half) {
              const idx1 = i.val + j | 0;
              const idx2 = idx1 + half | 0;
              const u_re = _M0MPC15array5Array2atGdE(re, idx1);
              const u_im = _M0MPC15array5Array2atGdE(im, idx1);
              const v_re = _M0MPC15array5Array2atGdE(re, idx2) * w_re.val - _M0MPC15array5Array2atGdE(im, idx2) * w_im.val;
              const v_im = _M0MPC15array5Array2atGdE(re, idx2) * w_im.val + _M0MPC15array5Array2atGdE(im, idx2) * w_re.val;
              _M0MPC15array5Array3setGdE(re, idx1, u_re + v_re);
              _M0MPC15array5Array3setGdE(im, idx1, u_im + v_im);
              _M0MPC15array5Array3setGdE(re, idx2, u_re - v_re);
              _M0MPC15array5Array3setGdE(im, idx2, u_im - v_im);
              const next_w_re = w_re.val * w_step_re - w_im.val * w_step_im;
              const next_w_im = w_re.val * w_step_im + w_im.val * w_step_re;
              w_re.val = next_w_re;
              w_im.val = next_w_im;
              _tmp = j + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          i.val = i.val + len.val | 0;
          continue;
        } else {
          break;
        }
      }
      len.val = Math.imul(len.val, 2) | 0;
      continue;
    } else {
      break;
    }
  }
  if (inverse) {
    const inv_n = 1 / (n + 0);
    const _bind = 0;
    let _tmp = _bind;
    while (true) {
      const i = _tmp;
      if (i < n) {
        _M0MPC15array5Array3setGdE(re, i, _M0MPC15array5Array2atGdE(re, i) * inv_n);
        _M0MPC15array5Array3setGdE(im, i, _M0MPC15array5Array2atGdE(im, i) * inv_n);
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    return;
  }
}
function _M0FP53zhr7moonmel3src3dsp3fft14rfft__spectrum(frame, n_fft, power) {
  if (!_M0FP53zhr7moonmel3src3dsp3fft18is__power__of__two(n_fft)) {
    return new _M0DTPC16result6ResultGRPB5ArrayGdERP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError14InvalidFftSize(n_fft));
  }
  const re = _M0MPC15array5Array4makeGdE(n_fft, 0);
  const im = _M0MPC15array5Array4makeGdE(n_fft, 0);
  const flen = frame.length;
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < n_fft) {
      if (i < flen) {
        _M0MPC15array5Array3setGdE(re, i, _M0MPC15array5Array2atGdE(frame, i));
      } else {
        _M0MPC15array5Array3setGdE(re, i, 0);
      }
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FP53zhr7moonmel3src3dsp3fft14fft__in__place(re, im, n_fft, false);
  if (2 === 0) {
    $panic();
  }
  const num_bins = (n_fft / 2 | 0) + 1 | 0;
  const spec = _M0MPC15array5Array4makeGdE(num_bins, 0);
  if (power === 2) {
    const _bind$2 = 0;
    let _tmp$2 = _bind$2;
    while (true) {
      const i = _tmp$2;
      if (i < num_bins) {
        _M0MPC15array5Array3setGdE(spec, i, _M0MPC15array5Array2atGdE(re, i) * _M0MPC15array5Array2atGdE(re, i) + _M0MPC15array5Array2atGdE(im, i) * _M0MPC15array5Array2atGdE(im, i));
        _tmp$2 = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  } else {
    if (power === 1) {
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const i = _tmp$2;
        if (i < num_bins) {
          _M0MPC15array5Array3setGdE(spec, i, Math.sqrt(_M0MPC15array5Array2atGdE(re, i) * _M0MPC15array5Array2atGdE(re, i) + _M0MPC15array5Array2atGdE(im, i) * _M0MPC15array5Array2atGdE(im, i)));
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
    } else {
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const i = _tmp$2;
        if (i < num_bins) {
          const p2 = _M0MPC15array5Array2atGdE(re, i) * _M0MPC15array5Array2atGdE(re, i) + _M0MPC15array5Array2atGdE(im, i) * _M0MPC15array5Array2atGdE(im, i);
          _M0MPC15array5Array3setGdE(spec, i, _M0FPC14math3pow(p2, power / 2));
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
    }
  }
  return new _M0DTPC16result6ResultGRPB5ArrayGdERP53zhr7moonmel3src4core5types8MelErrorE2Ok(spec);
}
function _M0FP53zhr7moonmel3src3dsp6window14create__window(kind, n) {
  if (n <= 0) {
    return [];
  }
  if (n === 1) {
    return [1];
  }
  const out = _M0MPC15array5Array4makeGdE(n, 0);
  switch (kind) {
    case 4: {
      const _bind = 0;
      let _tmp = _bind;
      while (true) {
        const i = _tmp;
        if (i < n) {
          _M0MPC15array5Array3setGdE(out, i, 1);
          _tmp = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return out;
    }
    case 0: {
      const denom = n + 0;
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const i = _tmp$2;
        if (i < n) {
          const x = 2 * _M0FP53zhr7moonmel3src3dsp6window2pi * (i + 0) / denom;
          _M0MPC15array5Array3setGdE(out, i, 0.5 - 0.5 * _M0FPC14math3cos(x));
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return out;
    }
    case 1: {
      const denom$2 = (n - 1 | 0) + 0;
      const _bind$3 = 0;
      let _tmp$3 = _bind$3;
      while (true) {
        const i = _tmp$3;
        if (i < n) {
          const x = 2 * _M0FP53zhr7moonmel3src3dsp6window2pi * (i + 0) / denom$2;
          _M0MPC15array5Array3setGdE(out, i, 0.5 - 0.5 * _M0FPC14math3cos(x));
          _tmp$3 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return out;
    }
    case 2: {
      const denom$3 = n + 0;
      const _bind$4 = 0;
      let _tmp$4 = _bind$4;
      while (true) {
        const i = _tmp$4;
        if (i < n) {
          const x = 2 * _M0FP53zhr7moonmel3src3dsp6window2pi * (i + 0) / denom$3;
          _M0MPC15array5Array3setGdE(out, i, 0.54 - 0.46 * _M0FPC14math3cos(x));
          _tmp$4 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return out;
    }
    default: {
      const denom$4 = n + 0;
      const _bind$5 = 0;
      let _tmp$5 = _bind$5;
      while (true) {
        const i = _tmp$5;
        if (i < n) {
          const x = 2 * _M0FP53zhr7moonmel3src3dsp6window2pi * (i + 0) / denom$4;
          _M0MPC15array5Array3setGdE(out, i, 0.42 - 0.5 * _M0FPC14math3cos(x) + 0.08 * _M0FPC14math3cos(2 * x));
          _tmp$5 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return out;
    }
  }
}
function _M0FP53zhr7moonmel3src3dsp6window14reflect__index(idx, len) {
  if (len <= 1) {
    return 0;
  }
  const i = new _M0TPB8MutLocalGiE(idx);
  while (true) {
    if (i.val < 0 || i.val >= len) {
      if (i.val < 0) {
        i.val = -i.val | 0;
      }
      if (i.val >= len) {
        i.val = (Math.imul(2, len - 1 | 0) | 0) - i.val | 0;
      }
      continue;
    } else {
      break;
    }
  }
  return i.val;
}
function _M0FP53zhr7moonmel3src3dsp6window12pad__reflect(samples, pad_width) {
  const len = samples.length;
  if (pad_width <= 0 || len === 0) {
    return _M0MPC15array5Array4copyGdE(samples);
  }
  const total_len = len + (Math.imul(2, pad_width) | 0) | 0;
  const out = _M0MPC15array5Array4makeGdE(total_len, 0);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < total_len) {
      const original_idx = i - pad_width | 0;
      const ref_idx = _M0FP53zhr7moonmel3src3dsp6window14reflect__index(original_idx, len);
      _M0MPC15array5Array3setGdE(out, i, _M0MPC15array5Array2atGdE(samples, ref_idx));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP53zhr7moonmel3src3dsp4stft17stft__spectrogram(samples, config) {
  let e;
  _L: {
    _L$2: {
      const _bind = _M0MP53zhr7moonmel3src4core5types13FeatureConfig8validate(config);
      if (_bind.$tag === 1) {
      } else {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(e);
  }
  if (_M0MPC15array5Array9is__emptyGdE(samples)) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(_M0DTP53zhr7moonmel3src4core5types8MelError10EmptyAudio__);
  }
  const n_fft = config.n_fft;
  const hop_length = config.hop_length;
  const win_length = config.win_length;
  let audio;
  if (config.center) {
    if (2 === 0) {
      $panic();
    }
    const pad_width = n_fft / 2 | 0;
    audio = _M0FP53zhr7moonmel3src3dsp6window12pad__reflect(samples, pad_width);
  } else {
    audio = _M0MPC15array5Array4copyGdE(samples);
  }
  const audio_len = audio.length;
  if (audio_len < n_fft) {
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(new _M0DTP53zhr7moonmel3src4core5types8MelError17DimensionMismatch("Audio length after padding is shorter than n_fft"));
  }
  if (hop_length === 0) {
    $panic();
  }
  const n_frames = 1 + ((audio_len - n_fft | 0) / hop_length | 0) | 0;
  if (2 === 0) {
    $panic();
  }
  const n_bins = (n_fft / 2 | 0) + 1 | 0;
  const result = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(n_bins, n_frames);
  const win = _M0FP53zhr7moonmel3src3dsp6window14create__window(config.window, win_length);
  const frame_buf = _M0MPC15array5Array4makeGdE(n_fft, 0);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const frame_idx = _tmp;
    if (frame_idx < n_frames) {
      const start = Math.imul(frame_idx, hop_length) | 0;
      if (2 === 0) {
        $panic();
      }
      const pad_offset = (n_fft - win_length | 0) / 2 | 0;
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const i = _tmp$2;
        if (i < n_fft) {
          _M0MPC15array5Array3setGdE(frame_buf, i, 0);
          _tmp$2 = i + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      const _bind$3 = 0;
      let _tmp$3 = _bind$3;
      while (true) {
        const j = _tmp$3;
        if (j < win_length) {
          const s_idx = start + j | 0;
          if (s_idx < audio_len) {
            _M0MPC15array5Array3setGdE(frame_buf, pad_offset + j | 0, _M0MPC15array5Array2atGdE(audio, s_idx) * _M0MPC15array5Array2atGdE(win, j));
          }
          _tmp$3 = j + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      let e$2;
      _L$2: {
        _L$3: {
          let spec;
          _L$4: {
            const _bind$4 = _M0FP53zhr7moonmel3src3dsp3fft14rfft__spectrum(frame_buf, n_fft, config.power);
            if (_bind$4.$tag === 1) {
              const _Ok = _bind$4;
              const _spec = _Ok._0;
              spec = _spec;
              break _L$4;
            } else {
              const _Err = _bind$4;
              const _e = _Err._0;
              e$2 = _e;
              break _L$3;
            }
          }
          const _bind$4 = 0;
          let _tmp$4 = _bind$4;
          while (true) {
            const bin_idx = _tmp$4;
            if (bin_idx < n_bins) {
              _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(result, bin_idx, frame_idx, _M0MPC15array5Array2atGdE(spec, bin_idx));
              _tmp$4 = bin_idx + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          break _L$2;
        }
        return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(e$2);
      }
      _tmp = frame_idx + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(result);
}
function _M0FP53zhr7moonmel3src8features3mel11hz__to__mel(freq, scale) {
  if (scale === 0) {
    const logstep = _M0FPC14math2ln(6.4) / 27;
    return freq >= _M0FP53zhr7moonmel3src8features3mel20slaney__min__log__hz ? _M0FP53zhr7moonmel3src8features3mel21slaney__min__log__mel + _M0FPC14math2ln(freq / _M0FP53zhr7moonmel3src8features3mel20slaney__min__log__hz) / logstep : freq / _M0FP53zhr7moonmel3src8features3mel13slaney__f__sp;
  } else {
    return 2595 * _M0FPC14math5log10(1 + freq / 700);
  }
}
function _M0FP53zhr7moonmel3src8features3mel11mel__to__hz(mel, scale) {
  if (scale === 0) {
    const logstep = _M0FPC14math2ln(6.4) / 27;
    return mel >= _M0FP53zhr7moonmel3src8features3mel21slaney__min__log__mel ? _M0FP53zhr7moonmel3src8features3mel20slaney__min__log__hz * _M0FPC14math3exp(logstep * (mel - _M0FP53zhr7moonmel3src8features3mel21slaney__min__log__mel)) : _M0FP53zhr7moonmel3src8features3mel13slaney__f__sp * mel;
  } else {
    return 700 * (_M0FPC14math3pow(10, mel / 2595) - 1);
  }
}
function _M0FP53zhr7moonmel3src8features3mel15mel__filterbank(config) {
  let e;
  _L: {
    _L$2: {
      const _bind = _M0MP53zhr7moonmel3src4core5types13FeatureConfig8validate(config);
      if (_bind.$tag === 1) {
      } else {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(e);
  }
  const n_mels = config.n_mels;
  const n_fft = config.n_fft;
  if (2 === 0) {
    $panic();
  }
  const n_bins = (n_fft / 2 | 0) + 1 | 0;
  const sr = config.sample_rate + 0;
  const mel_min = _M0FP53zhr7moonmel3src8features3mel11hz__to__mel(config.f_min, config.mel_scale);
  const mel_max = _M0FP53zhr7moonmel3src8features3mel11hz__to__mel(config.f_max, config.mel_scale);
  const mel_step = (mel_max - mel_min) / ((n_mels + 1 | 0) + 0);
  const f_pts = _M0MPC15array5Array4makeGdE(n_mels + 2 | 0, 0);
  const _bind = 0;
  const _bind$2 = n_mels + 2 | 0;
  let _tmp = _bind;
  while (true) {
    const i = _tmp;
    if (i < _bind$2) {
      const m = mel_min + (i + 0) * mel_step;
      _M0MPC15array5Array3setGdE(f_pts, i, _M0FP53zhr7moonmel3src8features3mel11mel__to__hz(m, config.mel_scale));
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const fft_freqs = _M0MPC15array5Array4makeGdE(n_bins, 0);
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const k = _tmp$2;
    if (k < n_bins) {
      _M0MPC15array5Array3setGdE(fft_freqs, k, (k + 0) * sr / (n_fft + 0));
      _tmp$2 = k + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const fb = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(n_mels, n_bins);
  const _bind$4 = 0;
  let _tmp$3 = _bind$4;
  while (true) {
    const i = _tmp$3;
    if (i < n_mels) {
      const f_left = _M0MPC15array5Array2atGdE(f_pts, i);
      const f_center = _M0MPC15array5Array2atGdE(f_pts, i + 1 | 0);
      const f_right = _M0MPC15array5Array2atGdE(f_pts, i + 2 | 0);
      const _bind$5 = config.mel_norm;
      let enorm;
      if (_bind$5 === 0) {
        enorm = 2 / (f_right - f_left);
      } else {
        enorm = 1;
      }
      const _bind$6 = 0;
      let _tmp$4 = _bind$6;
      while (true) {
        const k = _tmp$4;
        if (k < n_bins) {
          const f = _M0MPC15array5Array2atGdE(fft_freqs, k);
          const weight = new _M0TPB8MutLocalGdE(0);
          if (f >= f_left && (f <= f_center && f_center > f_left)) {
            weight.val = (f - f_left) / (f_center - f_left);
          } else {
            if (f >= f_center && (f <= f_right && f_right > f_center)) {
              weight.val = (f_right - f) / (f_right - f_center);
            }
          }
          _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(fb, i, k, weight.val * enorm);
          _tmp$4 = k + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$3 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(fb);
}
function _M0FP53zhr7moonmel3src8features3mel16mel__spectrogram(samples, config) {
  let spec;
  let e;
  _L: {
    _L$2: {
      const _bind = _M0FP53zhr7moonmel3src3dsp4stft17stft__spectrogram(samples, config);
      if (_bind.$tag === 1) {
        const _Ok = _bind;
        const _s = _Ok._0;
        spec = _s;
      } else {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(e);
  }
  let fb;
  let e$2;
  _L$2: {
    _L$3: {
      const _bind = _M0FP53zhr7moonmel3src8features3mel15mel__filterbank(config);
      if (_bind.$tag === 1) {
        const _Ok = _bind;
        const _f = _Ok._0;
        fb = _f;
      } else {
        const _Err = _bind;
        const _e = _Err._0;
        e$2 = _e;
        break _L$3;
      }
      break _L$2;
    }
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(e$2);
  }
  const n_mels = config.n_mels;
  const n_frames = spec.n_cols;
  const n_bins = spec.n_rows;
  const mel_spec = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(n_mels, n_frames);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const m = _tmp;
    if (m < n_mels) {
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const t = _tmp$2;
        if (t < n_frames) {
          const sum = new _M0TPB8MutLocalGdE(0);
          const _bind$3 = 0;
          let _tmp$3 = _bind$3;
          while (true) {
            const k = _tmp$3;
            if (k < n_bins) {
              sum.val = sum.val + _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(fb, m, k) * _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(spec, k, t);
              _tmp$3 = k + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(mel_spec, m, t, sum.val);
          _tmp$2 = t + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = m + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(mel_spec);
}
function _M0FP53zhr7moonmel3src8features4mfcc13power__to__db(matrix, ref_val, amin, top_db) {
  const rows = matrix.n_rows;
  const cols = matrix.n_cols;
  const out = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(rows, cols);
  const safe_ref = ref_val > amin ? ref_val : amin;
  const log_ref = 10 * _M0FPC14math5log10(safe_ref);
  const max_val = new _M0TPB8MutLocalGdE(-1e+030);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const r = _tmp;
    if (r < rows) {
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const c = _tmp$2;
        if (c < cols) {
          const v = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(matrix, r, c);
          const safe_v = v > amin ? v : amin;
          const db = 10 * _M0FPC14math5log10(safe_v) - log_ref;
          _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(out, r, c, db);
          if (db > max_val.val) {
            max_val.val = db;
          }
          _tmp$2 = c + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = r + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (top_db > 0) {
    const threshold = max_val.val - top_db;
    const _bind$2 = 0;
    let _tmp$2 = _bind$2;
    while (true) {
      const r = _tmp$2;
      if (r < rows) {
        const _bind$3 = 0;
        let _tmp$3 = _bind$3;
        while (true) {
          const c = _tmp$3;
          if (c < cols) {
            const v = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(out, r, c);
            if (v < threshold) {
              _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(out, r, c, threshold);
            }
            _tmp$3 = c + 1 | 0;
            continue;
          } else {
            break;
          }
        }
        _tmp$2 = r + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  return out;
}
function _M0FP53zhr7moonmel3src8features4mfcc21log__mel__spectrogram(samples, config) {
  let mel;
  let e;
  _L: {
    _L$2: {
      const _bind = _M0FP53zhr7moonmel3src8features3mel16mel__spectrogram(samples, config);
      if (_bind.$tag === 1) {
        const _Ok = _bind;
        const _m = _Ok._0;
        mel = _m;
      } else {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(e);
  }
  const rows = mel.n_rows;
  const cols = mel.n_cols;
  const _bind = config.log_scale;
  switch (_bind) {
    case 0: {
      const db_mat = _M0FP53zhr7moonmel3src8features4mfcc13power__to__db(mel, config.ref_value, config.amin, config.top_db);
      return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(db_mat);
    }
    case 1: {
      const out = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(rows, cols);
      const _bind$2 = 0;
      let _tmp = _bind$2;
      while (true) {
        const r = _tmp;
        if (r < rows) {
          const _bind$3 = 0;
          let _tmp$2 = _bind$3;
          while (true) {
            const c = _tmp$2;
            if (c < cols) {
              const v = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(mel, r, c);
              const safe_v = v > config.amin ? v : config.amin;
              _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(out, r, c, _M0FPC14math2ln(safe_v));
              _tmp$2 = c + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _tmp = r + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(out);
    }
    default: {
      const out$2 = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(rows, cols);
      const _bind$3 = 0;
      let _tmp$2 = _bind$3;
      while (true) {
        const r = _tmp$2;
        if (r < rows) {
          const _bind$4 = 0;
          let _tmp$3 = _bind$4;
          while (true) {
            const c = _tmp$3;
            if (c < cols) {
              const v = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(mel, r, c);
              const safe_v = v > config.amin ? v : config.amin;
              _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(out$2, r, c, _M0FPC14math5log10(safe_v));
              _tmp$3 = c + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _tmp$2 = r + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(out$2);
    }
  }
}
function _M0FP53zhr7moonmel3src8features4mfcc7dct__ii(input, n_out, norm_ortho) {
  const n_in = input.length;
  const out = _M0MPC15array5Array4makeGdE(n_out, 0);
  if (n_in === 0 || n_out === 0) {
    return out;
  }
  const denom = 2 * (n_in + 0);
  const w0 = norm_ortho ? Math.sqrt(1 / (n_in + 0)) : 2;
  const wk = norm_ortho ? Math.sqrt(2 / (n_in + 0)) : 2;
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const k = _tmp;
    if (k < n_out) {
      const sum = new _M0TPB8MutLocalGdE(0);
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const n = _tmp$2;
        if (n < n_in) {
          const angle = _M0FP53zhr7moonmel3src8features4mfcc2pi * (k + 0) * (2 * (n + 0) + 1) / denom;
          sum.val = sum.val + _M0MPC15array5Array2atGdE(input, n) * _M0FPC14math3cos(angle);
          _tmp$2 = n + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      const weight = k === 0 ? w0 : wk;
      _M0MPC15array5Array3setGdE(out, k, sum.val * weight);
      _tmp = k + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0FP53zhr7moonmel3src8features4mfcc4mfcc(samples, config) {
  let log_mel;
  let e;
  _L: {
    _L$2: {
      const _bind = _M0FP53zhr7moonmel3src8features4mfcc21log__mel__spectrogram(samples, config);
      if (_bind.$tag === 1) {
        const _Ok = _bind;
        const _lm = _Ok._0;
        log_mel = _lm;
      } else {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      }
      break _L;
    }
    return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE3Err(e);
  }
  const n_mfcc = config.n_mfcc;
  const n_mels = log_mel.n_rows;
  const n_frames = log_mel.n_cols;
  const res = _M0MP53zhr7moonmel3src4core5types13FeatureMatrix5zeros(n_mfcc, n_frames);
  const col_buf = _M0MPC15array5Array4makeGdE(n_mels, 0);
  const _bind = 0;
  let _tmp = _bind;
  while (true) {
    const t = _tmp;
    if (t < n_frames) {
      const _bind$2 = 0;
      let _tmp$2 = _bind$2;
      while (true) {
        const m = _tmp$2;
        if (m < n_mels) {
          _M0MPC15array5Array3setGdE(col_buf, m, _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(log_mel, m, t));
          _tmp$2 = m + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      const coeffs = _M0FP53zhr7moonmel3src8features4mfcc7dct__ii(col_buf, n_mfcc, config.norm_ortho);
      const _bind$3 = 0;
      let _tmp$3 = _bind$3;
      while (true) {
        const k = _tmp$3;
        if (k < n_mfcc) {
          _M0MP53zhr7moonmel3src4core5types13FeatureMatrix3set(res, k, t, _M0MPC15array5Array2atGdE(coeffs, k));
          _tmp$3 = k + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = t + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPC16result6ResultGRP53zhr7moonmel3src4core5types13FeatureMatrixRP53zhr7moonmel3src4core5types8MelErrorE2Ok(res);
}
function _M0FP23zhr7moonmel12stft_2einner(samples, config) {
  return _M0FP53zhr7moonmel3src3dsp4stft17stft__spectrogram(samples, config);
}
function _M0FP23zhr7moonmel24mel__spectrogram_2einner(samples, config) {
  return _M0FP53zhr7moonmel3src8features3mel16mel__spectrogram(samples, config);
}
function _M0FP23zhr7moonmel29log__mel__spectrogram_2einner(samples, config) {
  return _M0FP53zhr7moonmel3src8features4mfcc21log__mel__spectrogram(samples, config);
}
function _M0FP23zhr7moonmel12mfcc_2einner(samples, config) {
  return _M0FP53zhr7moonmel3src8features4mfcc4mfcc(samples, config);
}
function _M0FP23zhr7moonmel11decode__wav(bytes) {
  return _M0FP53zhr7moonmel3src5codec3wav11decode__wav(bytes);
}
function _M0FP53zhr7moonmel3src8bindings3web14process__audio(samples, sample_rate, n_fft, hop_length, n_mels, n_mfcc) {
  const _tmp = _M0MP53zhr7moonmel3src4core5types13FeatureConfig7default();
  const cfg = new _M0TP53zhr7moonmel3src4core5types13FeatureConfig(sample_rate, n_fft, hop_length, n_fft, _tmp.window, _tmp.center, _tmp.power, n_mels, _tmp.f_min, (sample_rate + 0) / 2, _tmp.mel_scale, _tmp.mel_norm, _tmp.log_scale, n_mfcc, _tmp.norm_ortho, _tmp.ref_value, _tmp.amin, _tmp.top_db);
  const stft_res = _M0FP23zhr7moonmel12stft_2einner(samples, cfg);
  const mel_res = _M0FP23zhr7moonmel24mel__spectrogram_2einner(samples, cfg);
  const logmel_res = _M0FP23zhr7moonmel29log__mel__spectrogram_2einner(samples, cfg);
  const mfcc_res = _M0FP23zhr7moonmel12mfcc_2einner(samples, cfg);
  const sb = _M0MPB13StringBuilder21StringBuilder_2einner(0);
  _M0IPB13StringBuilderPB6Logger13write__string(sb, "{\"success\":true,");
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(15);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "\"sample_rate\":");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, sample_rate);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ",");
  _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder));
  const _string_builder$2 = _M0MPB13StringBuilder21StringBuilder_2einner(15);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$2, "\"num_samples\":");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$2, samples.length);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$2, ",");
  _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$2));
  const _string_builder$3 = _M0MPB13StringBuilder21StringBuilder_2einner(9);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$3, "\"n_fft\":");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$3, n_fft);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$3, ",");
  _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$3));
  const _string_builder$4 = _M0MPB13StringBuilder21StringBuilder_2einner(14);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$4, "\"hop_length\":");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$4, hop_length);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$4, ",");
  _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$4));
  const _string_builder$5 = _M0MPB13StringBuilder21StringBuilder_2einner(10);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$5, "\"n_mels\":");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$5, n_mels);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$5, ",");
  _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$5));
  const _string_builder$6 = _M0MPB13StringBuilder21StringBuilder_2einner(10);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$6, "\"n_mfcc\":");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$6, n_mfcc);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$6, ",");
  _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$6));
  _L: {
    _L$2: {
      let logmel_mat;
      let stft_mat;
      let mel_mat;
      let mfcc_mat;
      _L$3: {
        if (stft_res.$tag === 1) {
          const _Ok = stft_res;
          const _stft_mat = _Ok._0;
          if (mel_res.$tag === 1) {
            const _Ok$2 = mel_res;
            const _mel_mat = _Ok$2._0;
            if (logmel_res.$tag === 1) {
              const _Ok$3 = logmel_res;
              const _logmel_mat = _Ok$3._0;
              if (mfcc_res.$tag === 1) {
                const _Ok$4 = mfcc_res;
                const _mfcc_mat = _Ok$4._0;
                logmel_mat = _logmel_mat;
                stft_mat = _stft_mat;
                mel_mat = _mel_mat;
                mfcc_mat = _mfcc_mat;
                break _L$3;
              } else {
                break _L$2;
              }
            } else {
              break _L$2;
            }
          } else {
            break _L$2;
          }
        } else {
          break _L$2;
        }
      }
      const _string_builder$7 = _M0MPB13StringBuilder21StringBuilder_2einner(12);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$7, "\"n_frames\":");
      _M0MPB13StringBuilder13write__objectGiE(_string_builder$7, stft_mat.n_cols);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$7, ",");
      _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$7));
      const _string_builder$8 = _M0MPB13StringBuilder21StringBuilder_2einner(15);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$8, "\"n_freq_bins\":");
      _M0MPB13StringBuilder13write__objectGiE(_string_builder$8, stft_mat.n_rows);
      _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$8, ",");
      _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$8));
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "\"mel\":[");
      const _bind = 0;
      const _bind$2 = mel_mat.n_rows;
      let _tmp$2 = _bind;
      while (true) {
        const r = _tmp$2;
        if (r < _bind$2) {
          if (r > 0) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "[");
          const _bind$3 = 0;
          const _bind$4 = mel_mat.n_cols;
          let _tmp$3 = _bind$3;
          while (true) {
            const c = _tmp$3;
            if (c < _bind$4) {
              if (c > 0) {
                _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
              }
              const _string_builder$9 = _M0MPB13StringBuilder21StringBuilder_2einner(0);
              _M0MPB13StringBuilder13write__objectGdE(_string_builder$9, _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(mel_mat, r, c));
              _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$9));
              _tmp$3 = c + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "]");
          _tmp$2 = r + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "],");
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "\"log_mel\":[");
      const _bind$3 = 0;
      const _bind$4 = logmel_mat.n_rows;
      let _tmp$3 = _bind$3;
      while (true) {
        const r = _tmp$3;
        if (r < _bind$4) {
          if (r > 0) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "[");
          const _bind$5 = 0;
          const _bind$6 = logmel_mat.n_cols;
          let _tmp$4 = _bind$5;
          while (true) {
            const c = _tmp$4;
            if (c < _bind$6) {
              if (c > 0) {
                _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
              }
              const _string_builder$9 = _M0MPB13StringBuilder21StringBuilder_2einner(0);
              _M0MPB13StringBuilder13write__objectGdE(_string_builder$9, _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(logmel_mat, r, c));
              _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$9));
              _tmp$4 = c + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "]");
          _tmp$3 = r + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "],");
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "\"mfcc\":[");
      const _bind$5 = 0;
      const _bind$6 = mfcc_mat.n_rows;
      let _tmp$4 = _bind$5;
      while (true) {
        const r = _tmp$4;
        if (r < _bind$6) {
          if (r > 0) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "[");
          const _bind$7 = 0;
          const _bind$8 = mfcc_mat.n_cols;
          let _tmp$5 = _bind$7;
          while (true) {
            const c = _tmp$5;
            if (c < _bind$8) {
              if (c > 0) {
                _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
              }
              const _string_builder$9 = _M0MPB13StringBuilder21StringBuilder_2einner(0);
              _M0MPB13StringBuilder13write__objectGdE(_string_builder$9, _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(mfcc_mat, r, c));
              _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$9));
              _tmp$5 = c + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "]");
          _tmp$4 = r + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "],");
      const stft_sample_bins = stft_mat.n_rows > 64 ? 64 : stft_mat.n_rows;
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "\"stft_preview\":[");
      const _bind$7 = 0;
      let _tmp$5 = _bind$7;
      while (true) {
        const r = _tmp$5;
        if (r < stft_sample_bins) {
          if (r > 0) {
            _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "[");
          if (stft_sample_bins === 0) {
            $panic();
          }
          const bin_idx = Math.imul(r, stft_mat.n_rows / stft_sample_bins | 0) | 0;
          const _bind$8 = 0;
          const _bind$9 = stft_mat.n_cols;
          let _tmp$6 = _bind$8;
          while (true) {
            const c = _tmp$6;
            if (c < _bind$9) {
              if (c > 0) {
                _M0IPB13StringBuilderPB6Logger13write__string(sb, ",");
              }
              const _string_builder$9 = _M0MPB13StringBuilder21StringBuilder_2einner(0);
              _M0MPB13StringBuilder13write__objectGdE(_string_builder$9, _M0MP53zhr7moonmel3src4core5types13FeatureMatrix2at(stft_mat, bin_idx, c));
              _M0IPB13StringBuilderPB6Logger13write__string(sb, _M0MPB13StringBuilder10to__string(_string_builder$9));
              _tmp$6 = c + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          _M0IPB13StringBuilderPB6Logger13write__string(sb, "]");
          _tmp$5 = r + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _M0IPB13StringBuilderPB6Logger13write__string(sb, "]");
      break _L;
    }
    _M0IPB13StringBuilderPB6Logger13write__string(sb, "\"error\":\"Feature extraction failed\"");
  }
  _M0IPB13StringBuilderPB6Logger13write__string(sb, "}");
  return _M0MPB13StringBuilder10to__string(sb);
}
function _M0FP53zhr7moonmel3src8bindings3web19process__wav__bytes(bytes, n_fft, hop_length, n_mels, n_mfcc) {
  let e;
  _L: {
    let buf;
    _L$2: {
      const _bind = _M0FP23zhr7moonmel11decode__wav(bytes);
      if (_bind.$tag === 1) {
        const _Ok = _bind;
        const _buf = _Ok._0;
        buf = _buf;
        break _L$2;
      } else {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L;
      }
    }
    return _M0FP53zhr7moonmel3src8bindings3web14process__audio(buf.samples, buf.sample_rate, n_fft, hop_length, n_mels, n_mfcc);
  }
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(28);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "{\"success\":false,\"error\":\"");
  _M0MPB13StringBuilder13write__objectGRP53zhr7moonmel3src4core5types8MelErrorE(_string_builder, e);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "\"}");
  return _M0MPB13StringBuilder10to__string(_string_builder);
}
export { _M0FP53zhr7moonmel3src8bindings3web14process__audio as process_audio, _M0FP53zhr7moonmel3src8bindings3web19process__wav__bytes as process_wav_bytes }
//# sourceMappingURL=web.js.map
