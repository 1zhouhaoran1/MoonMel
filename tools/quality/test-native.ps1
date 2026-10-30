param([switch]$Build)
$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Push-Location $repositoryRoot
try {
    # Let Moon select its supported native compiler. MoonBit 0.10.18 requires
    # MSVC on Windows; a MinGW wrapper cannot compile the complete runtime.
    # Explicit caller MOON_CC/MOON_AR settings remain untouched.
    if ($Build) { & moon build --target native --release }
    else { & moon test --target native --deny-warn }
    $testExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $testExitCode
