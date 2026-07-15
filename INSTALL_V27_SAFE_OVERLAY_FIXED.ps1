# V27 Safe Overlay Installer - ASCII-only / UTF-8 safe
# Put this file in the mom-ai-report project folder, together with:
#   mom-ai-report-overlay-v27-20260715.js
# Then run RUN_INSTALL_V27_SAFE_OVERLAY_FIXED.bat

$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IndexPath = Join-Path $ProjectDir "index.html"
$OverlayName = "mom-ai-report-overlay-v27-20260715.js"
$SourceOverlay = Join-Path $ProjectDir $OverlayName
$TargetOverlay = Join-Path $ProjectDir $OverlayName

if (-not (Test-Path -LiteralPath $IndexPath)) {
    throw "index.html was not found in: $ProjectDir"
}

if (-not (Test-Path -LiteralPath $SourceOverlay)) {
    throw "$OverlayName was not found in: $ProjectDir"
}

$BackupDir = Join-Path $ProjectDir "backups"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Backup = Join-Path $BackupDir ("index_before_v27_{0}.html" -f $Stamp)
Copy-Item -LiteralPath $IndexPath -Destination $Backup -Force

# Keep/copy the overlay in the project root.
# Source and target are normally the same path; this check avoids Copy-Item self-copy errors.
$sourceFull = [System.IO.Path]::GetFullPath($SourceOverlay)
$targetFull = [System.IO.Path]::GetFullPath($TargetOverlay)
if ($sourceFull -ne $targetFull) {
    Copy-Item -LiteralPath $SourceOverlay -Destination $TargetOverlay -Force
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$html = [System.IO.File]::ReadAllText($IndexPath, [System.Text.Encoding]::UTF8)

# Remove any older V27 script tags first, regardless of query-string version.
$pattern = '(?is)\s*<script\s+src=["''](?:\./)?mom-ai-report-overlay-v27-20260715\.js(?:\?v=[^"'']*)?["'']\s*>\s*</script>\s*'
$html = [System.Text.RegularExpressions.Regex]::Replace($html, $pattern, "")

$version = Get-Date -Format "yyyyMMddHHmmss"
$tag = '  <script src="./mom-ai-report-overlay-v27-20260715.js?v={0}"></script>' -f $version

if ($html -match '(?is)</body>') {
    $html = [System.Text.RegularExpressions.Regex]::Replace(
        $html,
        '(?is)</body>',
        ($tag + [Environment]::NewLine + '</body>'),
        1
    )
}
else {
    $html = $html.TrimEnd() + [Environment]::NewLine + $tag + [Environment]::NewLine
}

[System.IO.File]::WriteAllText($IndexPath, $html, $utf8NoBom)

Write-Host ""
Write-Host "V27 overlay installation completed." -ForegroundColor Green
Write-Host ("Project : {0}" -f $ProjectDir) -ForegroundColor Cyan
Write-Host ("Backup  : {0}" -f $Backup) -ForegroundColor Cyan
Write-Host ("Script  : {0}" -f $OverlayName) -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: refresh the webpage with Ctrl+F5." -ForegroundColor Yellow
