///|
/// One analysis result with shared intermediate matrices.
pub(all) struct AnalysisResult {
  stft : @types.FeatureMatrix
  filterbank : @types.FeatureMatrix
  mel : @types.FeatureMatrix
  log_mel : @types.FeatureMatrix
  mfcc : @types.FeatureMatrix
} derive(Debug)

///|
/// Execute STFT -> Mel -> Log-Mel -> MFCC once in dependency order.
pub fn analyze(
  samples : Array[Double],
  config : @types.FeatureConfig,
) -> Result[AnalysisResult, @types.MelError] {
  let stft = match @stft.stft_spectrogram(samples, config) {
    Ok(value) => value
    Err(e) => return Err(e)
  }
  let filterbank = match @mel.mel_filterbank(config) {
    Ok(value) => value
    Err(e) => return Err(e)
  }
  let mel = match @mel.apply_filterbank(stft, filterbank) {
    Ok(value) => value
    Err(e) => return Err(e)
  }
  let log_mel = match @mfcc.log_mel_from_mel(mel, config) {
    Ok(value) => value
    Err(e) => return Err(e)
  }
  let mfcc = match @mfcc.mfcc_from_log_mel(log_mel, config) {
    Ok(value) => value
    Err(e) => return Err(e)
  }
  Ok({ stft, filterbank, mel, log_mel, mfcc, })
}

///|
pub extend AnalysisResult with @moonbitlang/core/debug.Debug::{to_repr}
