# Dot-source this script to select the isolated acceptance toolchain locally.
$candidateHome = if ($env:MOONMEL_MOON_HOME) { $env:MOONMEL_MOON_HOME } else { 'A:\DevEnv\SDKs\MoonBit\latest-20261030' }
if (-not (Test-Path -LiteralPath (Join-Path $candidateHome 'bin\moonc.exe'))) {
    throw 'Install MoonBit >= 0.10.16, or point MOONMEL_MOON_HOME at a compatible toolchain.'
}
$env:MOON_HOME = $candidateHome
$env:PATH = (Join-Path $candidateHome 'bin') + ';' + $env:PATH

# Sync credentials from user ~/.moon profile into isolated toolchain
$userCred = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.moon\credentials.json'
if (Test-Path -LiteralPath $userCred) {
    Copy-Item -LiteralPath $userCred -Destination (Join-Path $candidateHome 'credentials.json') -Force
}

# Publishing credentials come from the environment; never commit a token.
if (-not $env:MOONCAKE_TOKEN -and $env:MOONCAKE_TOKEN_1ZHOUHAORAN1) {
    $env:MOONCAKE_TOKEN = $env:MOONCAKE_TOKEN_1ZHOUHAORAN1
}
if ($env:MOONCAKE_TOKEN) {
    $env:MOON_TOKEN = $env:MOONCAKE_TOKEN
}

& moonc -v
