param([string]$ProjectDir="")
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectDir)) {
    $ProjectDir = $PSScriptRoot
}

$ProjectDir = $ProjectDir.Trim().Trim('"').TrimEnd('\')
$IndexPath = Join-Path $ProjectDir 'index.html'

if (!(Test-Path -LiteralPath $IndexPath)) {
    throw "找不到 index.html：$IndexPath"
}

$Overlay = 'mom-ai-report-overlay-v30-20260716.js'
$Source = Join-Path $PSScriptRoot $Overlay
$Destination = Join-Path $ProjectDir $Overlay

if (!(Test-Path -LiteralPath $Source)) {
    throw "缺少 $Overlay"
}

$BackupDir = Join-Path $ProjectDir 'backups'
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
Copy-Item -LiteralPath $IndexPath -Destination (Join-Path $BackupDir "index_before_v30_$Stamp.html") -Force

# ZIP 若直接解壓到專案根目錄，來源與目的會是同一個檔案；此時不需要複製。
$SourceFull = [IO.Path]::GetFullPath($Source)
$DestinationFull = [IO.Path]::GetFullPath($Destination)
if (![string]::Equals($SourceFull, $DestinationFull, [StringComparison]::OrdinalIgnoreCase)) {
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

$html = [IO.File]::ReadAllText($IndexPath, [Text.Encoding]::UTF8)
$html = [regex]::Replace(
    $html,
    '\s*<script\s+src="\./mom-ai-report-overlay-v(?:27|28|29|30)[^"]*"></script>\s*',
    '',
    [Text.RegularExpressions.RegexOptions]::IgnoreCase
)

$tag = '<script src="./mom-ai-report-overlay-v30-20260716.js?v=20260716_0930"></script>'
if ($html -match '</body>') {
    $html = [regex]::Replace(
        $html,
        '</body>',
        "  $tag`r`n</body>",
        [Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
} else {
    $html += "`r`n$tag`r`n"
}

[IO.File]::WriteAllText($IndexPath, $html, [Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host 'V30 安裝完成' -ForegroundColor Green
Write-Host "Index: $IndexPath"
Write-Host '請啟動 auto_update_1min_public_v24.bat，再於瀏覽器按 Ctrl+F5。' -ForegroundColor Cyan
