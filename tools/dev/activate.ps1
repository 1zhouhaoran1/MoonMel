# Dot-source this script to select the isolated acceptance toolchain locally.
$candidateHome = 'A:\DevEnv\SDKs\MoonBit\moonmel-current'
if (-not (Test-Path -LiteralPath (Join-Path $candidateHome 'bin\moonc.exe'))) {
    throw 'Install MoonBit >= 0.10.14, or set MOON_HOME to a compatible toolchain.'
}
$env:MOON_HOME = $candidateHome
$env:PATH = (Join-Path $candidateHome 'bin') + ';' + $env:PATH
& moonc -v
