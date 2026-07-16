param(
  [string]$InputFile = "",
  [switch]$FromClipboard
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outFile = Join-Path $root "data\live.js"

if ($FromClipboard) {
  $text = Get-Clipboard -Raw
} elseif ($InputFile) {
  $path = if ([IO.Path]::IsPathRooted($InputFile)) { $InputFile } else { Join-Path $root $InputFile }
  if (-not (Test-Path -LiteralPath $path)) { throw "Input file not found: $path" }
  $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
} else {
  throw "Use -FromClipboard or -InputFile."
}

if ([string]::IsNullOrWhiteSpace($text)) { throw "No DDE text found." }
$text = $text -replace "`r`n", "`n" -replace "`r", "`n"
$lines = @($text -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($lines.Count -lt 2) { throw "DDE table needs a header and at least one data row." }

$headerLine = $lines[0].Trim([char]0xFEFF)
if ($headerLine -notmatch "代號" -or $headerLine -notmatch "成交價") {
  throw "Clipboard does not look like a DDE table. The first row must include 代號 and 成交價."
}
$normalized = ($headerLine + "`n" + (($lines | Select-Object -Skip 1) -join "`n"))
$records = @($normalized | ConvertFrom-Csv -Delimiter "`t")

function Num($v) {
  if ($null -eq $v) { return $null }
  $s = ([string]$v).Trim().Replace(",", "").Replace("%", "")
  if ($s -eq "" -or $s -eq "--") { return $null }
  $d = 0.0
  if ([double]::TryParse($s, [Globalization.NumberStyles]::Any, [Globalization.CultureInfo]::InvariantCulture, [ref]$d)) { return $d }
  if ([double]::TryParse($s, [ref]$d)) { return $d }
  return $null
}

$rows = foreach ($r in $records) {
  $code = ([string]$r.代號).Trim()
  if ([string]::IsNullOrWhiteSpace($code)) { continue }
  $name = if ($r.PSObject.Properties.Name -contains "名稱") { ([string]$r.名稱).Trim() } else { $code }
  [ordered]@{
    代號 = $code
    名稱 = $name
    擴充名 = if ($r.PSObject.Properties.Name -contains "擴充名") { ([string]$r.擴充名).Trim() } else { $code }
    漲跌 = Num $r.漲跌
    昨收 = Num $r.昨收
    開盤 = Num $r.開盤
    幅度 = if ($r.PSObject.Properties.Name -contains "幅度%") { Num $r.'幅度%' } elseif ($r.PSObject.Properties.Name -contains "幅度") { Num $r.幅度 } else { $null }
    成交價 = Num $r.成交價
    最高 = Num $r.最高
    最低 = Num $r.最低
    成交量 = Num $r.成交量
    昨量 = Num $r.昨量
    漲停 = Num $r.漲停
    跌停 = Num $r.跌停
    單量 = Num $r.單量
    成交金額 = Num $r.成交金額
    賣量 = Num $r.賣量
    買量 = Num $r.買量
    振幅 = Num $r.振幅
    買進 = Num $r.買進
    賣出 = Num $r.賣出
    定價量 = Num $r.定價量
  }
}
if (@($rows).Count -eq 0) { throw "No valid stock rows were parsed." }

$payload = [ordered]@{
  generatedAt = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
  source = "DDE table imported: $(@($rows).Count) stocks"
  rows = @($rows)
}
$json = $payload | ConvertTo-Json -Depth 6 -Compress
$js = "window.MOM_LIVE_DATA = $json;"
Set-Content -LiteralPath $outFile -Value $js -Encoding UTF8
Write-Host "OK: updated $outFile" -ForegroundColor Green
Write-Host "Rows: $(@($rows).Count)" -ForegroundColor Cyan
