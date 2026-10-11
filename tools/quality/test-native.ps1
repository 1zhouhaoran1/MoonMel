$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$originalCompiler = $env:MOON_CC
$originalArchiver = $env:MOON_AR
try {
    if ($IsWindows -and -not $env:MOON_CC) {
        $compilerPath = (Get-Command gcc -ErrorAction Stop).Source
        $env:MOON_AR = (Get-Command ar -ErrorAction Stop).Source
        $buildDirectory = Join-Path $repositoryRoot '_build'
        New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null
        $wrapperPath = Join-Path $buildDirectory 'gcc-native.cmd'
        # MoonBit's Windows random runtime needs the MinGW rand_s declaration.
        Set-Content -LiteralPath $wrapperPath -Encoding ascii -Value "@echo off`r`n`"$compilerPath`" -D_CRT_RAND_S %*"
        $env:MOON_CC = $wrapperPath
    }
    Push-Location $repositoryRoot
    try { & moon test --target native; $testExitCode = $LASTEXITCODE }
    finally { Pop-Location }
} finally {
    $env:MOON_CC = $originalCompiler
    $env:MOON_AR = $originalArchiver
}
exit $testExitCode
