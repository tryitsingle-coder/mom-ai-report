# fetch_global_market_now_v24.ps1
# Placeholder-safe fetch script for global_market.json.
# No hard-coded Windows user path. Run from the folder where this script is located.
# Keep your existing API-key version if it already works. This file intentionally contains no API key.
$ErrorActionPreference = "Stop"

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $repo) { $repo = (Get-Location).Path }
Set-Location -LiteralPath $repo

$payload = [ordered]@{
  updated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  global_signal = "BULLISH_BUT_INTRADAY_DIVERGENCE"
  note = "07/01 close public package: Taiwan semiconductors supported by TSMC, but ABF/PCB intraday sell pressure requires confirmation. Replace this placeholder with live fetch if needed."
}
$payload | ConvertTo-Json -Depth 5 | Set-Content -Path "global_market.json" -Encoding UTF8
Write-Host "global_market.json updated placeholder."
