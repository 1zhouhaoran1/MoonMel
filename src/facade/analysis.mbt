///|
pub type AnalysisResult = @analysis.AnalysisResult

///|
/// Analyze all core features with one shared STFT.
pub fn analyze(
  samples : Array[Double],
  config~ : @types.FeatureConfig = @types.FeatureConfig::default(),
) -> Result[@analysis.AnalysisResult, @types.MelError] {
  @analysis.analyze(samples, config)
}
