# Dot-source this script to select the isolated acceptance toolchain locally.
$candidateHome = 'A:\DevEnv\SDKs\MoonBit\moonmel-current'
if (-not (Test-Path -LiteralPath (Join-Path $candidateHome 'bin\moonc.exe'))) {
    throw 'Install MoonBit >= 0.10.14, or set MOON_HOME to a compatible toolchain.'
}
$env:MOON_HOME = $candidateHome
$env:PATH = (Join-Path $candidateHome 'bin') + ';' + $env:PATH

# Sync credentials from user ~/.moon profile into isolated toolchain
$userCred = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.moon\credentials.json'
if (Test-Path -LiteralPath $userCred) {
    Copy-Item -LiteralPath $userCred -Destination (Join-Path $candidateHome 'credentials.json') -Force
}

if ($env:MOONCAKE_TOKEN_1ZHOUHAORAN1) {
    $env:MOONCAKE_TOKEN = $env:MOONCAKE_TOKEN_1ZHOUHAORAN1
}
$env:MOON_TOKEN = $env:MOONCAKE_TOKEN

& moonc -v
