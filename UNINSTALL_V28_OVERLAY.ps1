$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IndexPath = Join-Path $ProjectDir "index.html"
if (-not (Test-Path -LiteralPath $IndexPath)) { throw "index.html not found." }
$html = [System.IO.File]::ReadAllText($IndexPath, [System.Text.Encoding]::UTF8)
$pattern = '(?is)\s*<script\s+src=["''](?:\./)?mom-ai-report-overlay-v28-20260716\.js(?:\?v=[^"'']*)?["'']\s*>\s*</script>\s*'
$html = [System.Text.RegularExpressions.Regex]::Replace($html, $pattern, "")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($IndexPath, $html, $utf8NoBom)
Write-Host "V28 overlay tag removed. api_key files were untouched." -ForegroundColor Green
