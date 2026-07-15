# Mom AI Report V28 safe overlay installer
# ASCII-only script body to avoid Windows PowerShell 5 encoding/parser errors.
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IndexPath = Join-Path $ProjectDir "index.html"
$OverlayName = "mom-ai-report-overlay-v28-20260716.js"
$OverlayPath = Join-Path $ProjectDir $OverlayName
if (-not (Test-Path -LiteralPath $IndexPath)) { throw "index.html was not found. Copy this package into the mom-ai-report project folder." }
if (-not (Test-Path -LiteralPath $OverlayPath)) { throw "$OverlayName was not found beside this installer." }
$BackupDir = Join-Path $ProjectDir "backups"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupPath = Join-Path $BackupDir ("index_before_v28_{0}.html" -f $Stamp)
Copy-Item -LiteralPath $IndexPath -Destination $BackupPath -Force
$html = [System.IO.File]::ReadAllText($IndexPath, [System.Text.Encoding]::UTF8)
$patterns = @(
  '(?is)\s*<script\s+src=["''](?:\./)?mom-ai-report-overlay-v27-20260715\.js(?:\?v=[^"'']*)?["'']\s*>\s*</script>\s*',
  '(?is)\s*<script\s+src=["''](?:\./)?mom-ai-report-overlay-v28-20260716\.js(?:\?v=[^"'']*)?["'']\s*>\s*</script>\s*'
)
foreach ($pattern in $patterns) { $html = [System.Text.RegularExpressions.Regex]::Replace($html, $pattern, "") }
$version = Get-Date -Format "yyyyMMddHHmmss"
$tag = '  <script src="./mom-ai-report-overlay-v28-20260716.js?v={0}"></script>' -f $version
if ($html -match '(?is)</body>') { $html = [System.Text.RegularExpressions.Regex]::Replace($html,'(?is)</body>',($tag + [Environment]::NewLine + '</body>'),1) } else { $html = $html.TrimEnd() + [Environment]::NewLine + $tag + [Environment]::NewLine }
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($IndexPath, $html, $utf8NoBom)
Write-Host ""
Write-Host "V28 overlay installation completed." -ForegroundColor Green
Write-Host ("Backup: {0}" -f $BackupPath) -ForegroundColor Cyan
Write-Host "The api_key files were not read, changed, copied, or deleted." -ForegroundColor Yellow
Write-Host "Refresh with Ctrl+F5, then commit/push index.html and the V28 JS file." -ForegroundColor Yellow
