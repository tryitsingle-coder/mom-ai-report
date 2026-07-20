param(
  [string]$InputFile = "",
  [switch]$FromClipboard
)

$ErrorActionPreference = "Stop"

try {
  $root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
  $outDir = Join-Path $root "data"
  $outFile = Join-Path $outDir "live.js"

  if (-not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
  }

  if ($FromClipboard) {
    Add-Type -AssemblyName System.Windows.Forms
    $text = [System.Windows.Forms.Clipboard]::GetText([System.Windows.Forms.TextDataFormat]::UnicodeText)
    if ([string]::IsNullOrWhiteSpace($text)) {
      $text = [System.Windows.Forms.Clipboard]::GetText([System.Windows.Forms.TextDataFormat]::Text)
    }
  }
  elseif ($InputFile) {
    $path = if ([IO.Path]::IsPathRooted($InputFile)) { $InputFile } else { Join-Path $root $InputFile }
    if (-not (Test-Path -LiteralPath $path)) { throw "找不到輸入檔案：$path" }
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  }
  else {
    throw "請使用 -FromClipboard 或 -InputFile。"
  }

  if ([string]::IsNullOrWhiteSpace($text)) {
    throw "剪貼簿沒有文字表格。請在 Excel 選取資料後按 Ctrl+C。"
  }

  $text = $text -replace "`r`n", "`n" -replace "`r", "`n"
  $lines = @($text -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  if ($lines.Count -lt 2) { throw "DDE 表格需要表頭及至少一列股票資料。" }

  $headerLine = $lines[0].Trim([char]0xFEFF)
  if ($headerLine -notmatch "代號" -or $headerLine -notmatch "成交價") {
    throw "第一列找不到『代號』與『成交價』。請連同表頭一起複製。實際第一列：$headerLine"
  }

  $normalized = $headerLine + "`n" + (($lines | Select-Object -Skip 1) -join "`n")
  $records = @($normalized | ConvertFrom-Csv -Delimiter "`t")

  function Num($v) {
    if ($null -eq $v) { return $null }
    $s = ([string]$v).Trim().Replace(",", "").Replace("%", "")
    if ($s -eq "" -or $s -eq "--" -or $s -eq "N/A") { return $null }
    $d = 0.0
    if ([double]::TryParse($s, [Globalization.NumberStyles]::Any, [Globalization.CultureInfo]::InvariantCulture, [ref]$d)) { return $d }
    if ([double]::TryParse($s, [ref]$d)) { return $d }
    return $null
  }

  $rows = foreach ($r in $records) {
    $code = ([string]$r.代號).Trim()
    if ([string]::IsNullOrWhiteSpace($code)) { continue }

    [ordered]@{
      代號 = $code
      名稱 = if ($r.PSObject.Properties.Name -contains "名稱") { ([string]$r.名稱).Trim() } else { $code }
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
      定價量 = Num $r.定價量
      漲停 = Num $r.漲停
      跌停 = Num $r.跌停
      單量 = Num $r.單量
      成交金額 = Num $r.成交金額
      賣量 = Num $r.賣量
      買量 = Num $r.買量
      振幅 = Num $r.振幅
      買進 = Num $r.買進
      賣出 = Num $r.賣出
    }
  }

  if (@($rows).Count -eq 0) { throw "沒有解析到有效股票資料。" }

  $payload = [ordered]@{
    generatedAt = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    source = "DDE table imported: $(@($rows).Count) stocks"
    rows = @($rows)
  }

  $json = $payload | ConvertTo-Json -Depth 6 -Compress
  $js = "window.MOM_LIVE_DATA = $json;"
  [System.IO.File]::WriteAllText($outFile, $js, (New-Object System.Text.UTF8Encoding($false)))

  Write-Host "OK: updated $outFile" -ForegroundColor Green
  Write-Host "Rows: $(@($rows).Count)" -ForegroundColor Cyan
  exit 0
}
catch {
  Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
