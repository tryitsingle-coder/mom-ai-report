# update_ai_report_public_v24.ps1
# V27.3 2026-07-01 Close Select100 - FIX6 Auto Page Updated Time
# No hard-coded Windows user path. Run from the folder where this script is located.
$ErrorActionPreference = "Stop"

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $repo) { $repo = (Get-Location).Path }
Set-Location -LiteralPath $repo

Write-Host "=========================================="
Write-Host "AI Report Public Update - V27.3 FIX6 Select100 Auto Page Updated Time"
Write-Host "Repo: $repo"
Write-Host "=========================================="


# Update the visible webpage update time every time this script runs.
# Data node stays as 2026/07/01 close, but this field tells viewers when the page was last pushed.
$buildTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
$indexPath = Join-Path $repo "index.html"
if (Test-Path -LiteralPath $indexPath) {
  $html = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
  $html = [regex]::Replace($html, 'data-generated-at="[^"]*"', ('data-generated-at="' + $buildTime + '"'))
  $html = [regex]::Replace($html, '<span class="pageUpdatedText">.*?</span>', ('<span class="pageUpdatedText">' + $buildTime + '</span>'))
  Set-Content -LiteralPath $indexPath -Value $html -Encoding UTF8
  Write-Host "Page update time written: $buildTime"
}

if (-not (Test-Path -LiteralPath ".git")) {
  Write-Host "WARNING: This folder is not a Git repo. Files are overwritten locally, but git add/commit/push will be skipped."
  Write-Host "Open index.html directly or copy these files into your mom-ai-report GitHub repo folder."
  exit 0
}

# Add everything in this folder. This avoids Chinese filename/path encoding problems.
git add -- .
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
  Write-Host "No changes to commit."
  exit 0
}

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "V27.3 FIX6 select100 page update time $stamp"
git push
Write-Host "Done. Open GitHub Pages after a short delay."
