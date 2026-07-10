
param(
  [string]$IndexPath = ".\index.html"
)
$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$base = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $base) { $base = (Get-Location).Path }
$indexFull = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $IndexPath))

if (!(Test-Path -LiteralPath $indexFull)) {
  throw "找不到 index.html：$indexFull。請把本覆蓋包解壓到 mom-ai-report 資料夾後再執行。"
}

$projectDir = Split-Path -Parent $indexFull
$sourceJs = Join-Path $base "v27_seven_giants_complete.js"
$targetJs = Join-Path $projectDir "v27_seven_giants_complete.js"
if (!(Test-Path -LiteralPath $sourceJs)) { throw "缺少 v27_seven_giants_complete.js" }

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = "$indexFull.bak_v27_$stamp"
Copy-Item -LiteralPath $indexFull -Destination $backup -Force
Copy-Item -LiteralPath $sourceJs -Destination $targetJs -Force

$html = [System.IO.File]::ReadAllText($indexFull, [System.Text.Encoding]::UTF8)

# 清除本模組舊標籤，避免重複；完全不移除原本 global_market / 夜盤程式。
$html = [regex]::Replace(
  $html,
  '(?is)\s*<script[^>]+src=["''](?:\./)?v27_seven_giants_complete\.js(?:\?[^"'']*)?["''][^>]*>\s*</script>',
  ''
)

$tag = '<script src="./v27_seven_giants_complete.js?v=20260711"></script>'
if ($html -match '(?i)</body>') {
  $html = [regex]::Replace($html, '(?i)</body>', "  $tag`r`n</body>", 1)
} else {
  $html += "`r`n$tag`r`n"
}

[System.IO.File]::WriteAllText($indexFull, $html, $Utf8NoBom)

Write-Host ""
Write-Host "完成：V27 七巨頭主線溫度計已整合。" -ForegroundColor Green
Write-Host "保留：原本美股夜盤、台指夜盤、全球風向、DDE 100 檔與個股雷達。" -ForegroundColor Green
Write-Host "修正：快照與 100 檔 DDE 表頭不再懸浮遮住資料。" -ForegroundColor Green
Write-Host "備份：$backup" -ForegroundColor Yellow
Write-Host ""
Write-Host "接著開 auto_update_1min_public_v24.bat，等待推送後按 Ctrl+F5。" -ForegroundColor Cyan
