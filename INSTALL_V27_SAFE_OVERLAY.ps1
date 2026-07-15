param([string]$IndexPath = ".\index.html")
$ErrorActionPreference = "Stop"
$Overlay = "mom-ai-report-overlay-v27-20260715.js"
$Tag = '<script src="./mom-ai-report-overlay-v27-20260715.js?v=20260715_1"></script>'
if (!(Test-Path $IndexPath)) { throw "找不到 index.html，請把本檔放在 mom-ai-report 根目錄。" }
$ResolvedIndex=(Resolve-Path $IndexPath).Path
$ProjectDir=Split-Path -Parent $ResolvedIndex
$SourceOverlay=Join-Path $PSScriptRoot $Overlay
$TargetOverlay=Join-Path $ProjectDir $Overlay
if (!(Test-Path $SourceOverlay)) { throw "找不到 $Overlay" }
$BackupDir=Join-Path $ProjectDir "backups"; New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
$Stamp=Get-Date -Format "yyyyMMdd_HHmmss"; $Backup=Join-Path $BackupDir "index_before_v27_$Stamp.html"
Copy-Item $ResolvedIndex $Backup -Force; Copy-Item $SourceOverlay $TargetOverlay -Force
$html=[System.IO.File]::ReadAllText($ResolvedIndex,[System.Text.Encoding]::UTF8)
$pattern='<script\s+src="\.\/mom-ai-report-overlay-v27-20260715\.js\?v=[^"]+"><\/script>\s*'
$html=[regex]::Replace($html,$pattern,"",[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
if($html -match '</body>'){$html=[regex]::Replace($html,'</body>',"  $Tag`r`n</body>",[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)}else{$html+="`r`n$Tag`r`n"}
[System.IO.File]::WriteAllText($ResolvedIndex,$html,(New-Object System.Text.UTF8Encoding($false)))
Write-Host "OK：已安裝 V27 首頁低接雷達。" -ForegroundColor Green
Write-Host "備份：$Backup" -ForegroundColor Cyan
