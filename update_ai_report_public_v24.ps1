# update_ai_report_public_v24.ps1
# V27.0 2026-07-01 Close Full Overwrite - FIX
# No hard-coded Windows user path. Run from the folder where this script is located.
$ErrorActionPreference = "Stop"

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $repo) { $repo = (Get-Location).Path }
Set-Location -LiteralPath $repo

Write-Host "=========================================="
Write-Host "AI Report Public Update - V27.0 2026-07-01 Close FIX"
Write-Host "Repo: $repo"
Write-Host "=========================================="

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
git commit -m "V27.0 2026-07-01 close public dashboard update FIX $stamp"
git push
Write-Host "Done. Open GitHub Pages after a short delay."
