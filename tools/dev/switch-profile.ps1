[CmdletBinding()]
param(
    [ValidateSet('1zhouhaoran1', 'Sidney-sunny', 'LING71671')]
    [string]$ProfileName = '1zhouhaoran1'
)

$userHome = [Environment]::GetFolderPath('UserProfile')
$sourceCred = Join-Path $userHome ".moon\profiles\$ProfileName\credentials.json"

if (-not (Test-Path -LiteralPath $sourceCred)) {
    throw "Profile credentials not found at: $sourceCred"
}

# 1. Update ~/.moon/credentials.json
$targetCred = Join-Path $userHome '.moon\credentials.json'
Copy-Item -LiteralPath $sourceCred -Destination $targetCred -Force

# 2. Update isolated SDK credentials if present
$candidateHome = 'A:\DevEnv\SDKs\MoonBit\moonmel-current'
if (Test-Path -LiteralPath $candidateHome) {
    Copy-Item -LiteralPath $sourceCred -Destination (Join-Path $candidateHome 'credentials.json') -Force
}

# 3. Read token and update env vars
$json = Get-Content -LiteralPath $sourceCred -Raw | ConvertFrom-Json
$env:MOONCAKE_TOKEN = $json.token
$env:MOON_TOKEN = $json.token
$env:MOONCAKE_USERNAME = $json.username

[Environment]::SetEnvironmentVariable('MOONCAKE_TOKEN', $json.token, 'User')
[Environment]::SetEnvironmentVariable('MOON_TOKEN', $json.token, 'User')
[Environment]::SetEnvironmentVariable('MOONCAKE_USER', $json.username, 'User')

Write-Host "Switched active Mooncake profile to: $ProfileName" -ForegroundColor Green
if (Get-Command moon -ErrorAction SilentlyContinue) {
    moon whoami
}
