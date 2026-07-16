
param(
  [string]$ProjectDir = ""
)
$ErrorActionPreference = "Stop"

# Normalize the project path. This avoids embedded quote characters from BAT arguments.
if ([string]::IsNullOrWhiteSpace($ProjectDir)) {
  $ProjectDir = $PSScriptRoot
}
$ProjectDir = $ProjectDir.Trim().Trim('"').TrimEnd('\')
if (!(Test-Path -LiteralPath $ProjectDir -PathType Container)) {
  throw "Project folder not found: $ProjectDir"
}
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$OverlayName = "mom-ai-report-overlay-v29-20260716.js"
$SourceOverlay = Join-Path $PSScriptRoot $OverlayName
if (!(Test-Path -LiteralPath $SourceOverlay -PathType Leaf)) { throw "Missing overlay file: $SourceOverlay" }

$indexCandidates = @(
  (Join-Path $ProjectDir "index.html"),
  (Join-Path $ProjectDir "docs\index.html")
)
$IndexPath = $indexCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
if (!$IndexPath) {
  throw "Cannot find index.html. Put this V29 folder inside the mom-ai-report project, or copy all V29 files to the project root."
}

$ResolvedIndex = (Resolve-Path $IndexPath).Path
$TargetDir = Split-Path -Parent $ResolvedIndex
$TargetOverlay = Join-Path $TargetDir $OverlayName

$BackupDir = Join-Path $TargetDir "backups"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Backup = Join-Path $BackupDir "index_before_v29_$Stamp.html"
Copy-Item $ResolvedIndex $Backup -Force
Copy-Item $SourceOverlay $TargetOverlay -Force

$html = [System.IO.File]::ReadAllText($ResolvedIndex, [System.Text.Encoding]::UTF8)

# Remove all prior V27/V28/V29 overlay tags to prevent duplication.
$patterns = @(
  '<script\s+src="\.\/mom-ai-report-overlay-v27[^"]*"><\/script>\s*',
  '<script\s+src="\.\/mom-ai-report-overlay-v28[^"]*"><\/script>\s*',
  '<script\s+src="\.\/mom-ai-report-overlay-v29[^"]*"><\/script>\s*'
)
foreach ($pattern in $patterns) {
  $html = [regex]::Replace($html, $pattern, "", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

$Tag = '<script src="./mom-ai-report-overlay-v29-20260716.js?v=20260716_02"></script>'
if ($html -match '</body>') {
  $html = [regex]::Replace(
    $html,
    '</body>',
    "  $Tag`r`n</body>",
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
  )
} else {
  $html += "`r`n$Tag`r`n"
}

$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($ResolvedIndex, $html, $Utf8NoBom)

Write-Host ""
Write-Host "V29.2 installed successfully." -ForegroundColor Green
Write-Host "Index:   $ResolvedIndex"
Write-Host "Overlay: $TargetOverlay"
Write-Host "Backup:  $Backup"
Write-Host ""
Write-Host "Next: open auto_update_1min_public_v24.bat, then press Ctrl+F5 in the browser." -ForegroundColor Cyan
