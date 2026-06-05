# fetch_global_market.ps1
# V18: Fetch global market data and auto-inject into index.html
# Put api_key.txt in the same folder, then run:
# powershell -ExecutionPolicy Bypass -File .\fetch_global_market.ps1

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ApiKeyPath = Join-Path $Root "api_key.txt"
$JsonOut = Join-Path $Root "global_market.json"
$HtmlOut = Join-Path $Root "global_market_block.html"
$LogOut  = Join-Path $Root "global_market_fetch.log"
$IndexPath = Join-Path $Root "index.html"

function Write-Log($msg) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg"
    Add-Content -Path $LogOut -Value $line -Encoding UTF8
}

if (!(Test-Path $ApiKeyPath)) {
    throw "Cannot find api_key.txt. Please put your Twelve Data API key in api_key.txt."
}

$ApiKey = (Get-Content $ApiKeyPath -Raw -Encoding UTF8).Trim()
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw "api_key.txt is empty."
}

Add-Type -AssemblyName System.Web

# First stable phase: NVDA, TSM ADR, USD/TWD.
# Index symbols from Twelve Data often need paid/alternate symbols, so they are not used for signal yet.
$Items = @(
    @{ Key="nvda";     Name="NVDA";         Symbol="NVDA";      Kind="stock" },
    @{ Key="tsm";      Name="TSM ADR";      Symbol="TSM";       Kind="stock" },
    @{ Key="usdtwd";   Name="USD/TWD";      Symbol="USD/TWD";   Kind="forex" }
)

function Get-TwelveQuote($Symbol) {
    $encodedSymbol = [System.Web.HttpUtility]::UrlEncode($Symbol)
    $url = "https://api.twelvedata.com/quote?symbol=$encodedSymbol&apikey=$ApiKey"
    try {
        return Invoke-RestMethod -Uri $url -Method GET -TimeoutSec 20
    } catch {
        return [PSCustomObject]@{
            error = "HTTP_ERROR"
            message = $_.Exception.Message
            symbol = $Symbol
        }
    }
}

$Results = @()

foreach ($item in $Items) {
    Start-Sleep -Milliseconds 300
    $q = Get-TwelveQuote $item.Symbol

    if ($q.error) {
        Write-Log "ERROR $($item.Name) $($item.Symbol): $($q.message)"
        $Results += [PSCustomObject]@{
            key = $item.Key
            name = $item.Name
            symbol = $item.Symbol
            kind = $item.Kind
            ok = $false
            price = $null
            change = $null
            percent_change = $null
            status = "ERROR"
            message = $q.message
            datetime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        }
        continue
    }

    $price = $null
    $change = $null
    $percent = $null

    if ($q.close) { $price = [double]$q.close }
    elseif ($q.price) { $price = [double]$q.price }
    elseif ($q.previous_close) { $price = [double]$q.previous_close }

    if ($q.change) { $change = [double]$q.change }
    if ($q.percent_change) { $percent = [double]$q.percent_change }

    $status = "Neutral"
    if ($percent -ne $null) {
        if ($percent -ge 0.8) { $status = "Bullish" }
        elseif ($percent -le -0.8) { $status = "Bearish" }
    }

    $Results += [PSCustomObject]@{
        key = $item.Key
        name = $item.Name
        symbol = $item.Symbol
        kind = $item.Kind
        ok = $true
        price = $price
        change = $change
        percent_change = $percent
        status = $status
        message = ""
        datetime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    Write-Log "OK $($item.Name) $($item.Symbol): price=$price change=$change percent=$percent"
}

# Signal score: NVDA and TSM ADR are the main AI/Taiwan tech indicators.
$score = 0
$validCount = 0
foreach ($r in $Results) {
    if ($r.ok -and $r.percent_change -ne $null) {
        $w = 1
        if ($r.key -in @("nvda","tsm")) { $w = 2 }
        $score += [double]$r.percent_change * $w
        $validCount += $w
    }
}

$avgScore = $null
$globalSignal = "DATA_NOT_ENOUGH"
if ($validCount -gt 0) {
    $avgScore = [math]::Round($score / $validCount, 2)
    if ($avgScore -ge 0.6) { $globalSignal = "BULLISH" }
    elseif ($avgScore -le -0.6) { $globalSignal = "BEARISH" }
    else { $globalSignal = "NEUTRAL" }
}

$Output = [PSCustomObject]@{
    updated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    source = "Twelve Data"
    global_signal = $globalSignal
    average_score = $avgScore
    items = $Results
}
$Output | ConvertTo-Json -Depth 5 | Set-Content -Path $JsonOut -Encoding UTF8

function FmtNum($n) {
    if ($null -eq $n) { return "N/A" }
    return "{0:N2}" -f [double]$n
}
function FmtPct($n) {
    if ($null -eq $n) { return "N/A" }
    return ("{0:N2}%" -f [double]$n)
}
function CardClass($pct) {
    if ($null -eq $pct) { return "summary-gray" }
    if ([double]$pct -ge 0.8) { return "summary-green" }
    if ([double]$pct -le -0.8) { return "summary-red" }
    return "summary-yellow"
}
function SignalText($s) {
    if ($s -eq "BULLISH") { return "🟢 偏多" }
    if ($s -eq "BEARISH") { return "🔴 偏空" }
    if ($s -eq "NEUTRAL") { return "🟡 中性震盪" }
    return "資料不足"
}
function StatusText($s) {
    if ($s -eq "Bullish") { return "偏多" }
    if ($s -eq "Bearish") { return "偏空" }
    if ($s -eq "Neutral") { return "中性" }
    return $s
}
function DirectionText($signal) {
    if ($signal -eq "BULLISH") { return "NVDA與TSM ADR偏強，AI與台積電供應鏈盤前加分；仍需搭配台指夜盤與試撮價確認。" }
    if ($signal -eq "BEARISH") { return "國際AI風向偏弱，早盤先保守，不急著低接。" }
    if ($signal -eq "NEUTRAL") { return "國際盤前中性，今天主要看台積電2400與日月光/欣興支撐。" }
    return "資料不足，請檢查 API 或稍後再跑一次。"
}

$cards = ""
foreach ($r in $Results) {
    $cls = CardClass $r.percent_change
    $priceText = FmtNum $r.price
    $pctText = FmtPct $r.percent_change
    $statusText = StatusText $r.status
    $cards += @"
        <div class="summary-card $cls">
          <strong>$($r.name)</strong>
          <span>$priceText</span>
          <span class="names">$pctText｜$statusText</span>
        </div>

"@
}

$signalDisplay = SignalText $globalSignal
$direction = DirectionText $globalSignal

$html = @"
    <!-- GLOBAL_MARKET_BLOCK_START -->
    <section>
      <h2>🌙 國際盤前雷達｜自動更新</h2>
      <p class="note">資料來源：Twelve Data｜更新時間：$($Output.updated_at)</p>
      <div class="summary-grid">
        <div class="summary-card summary-yellow">
          <strong>盤前總燈號</strong>
          <span>$signalDisplay</span>
          <span class="names">平均分數：$avgScore</span>
        </div>
$cards
        <div class="summary-card summary-yellow">
          <strong>小駿判讀</strong>
          <span>$signalDisplay</span>
          <span class="names">$direction</span>
        </div>
      </div>
    </section>
    <!-- GLOBAL_MARKET_BLOCK_END -->
"@

[System.IO.File]::WriteAllText($HtmlOut, $html, [System.Text.UTF8Encoding]::new($true))

# Inject into index.html
if (Test-Path $IndexPath) {
    $index = Get-Content $IndexPath -Raw -Encoding UTF8
    $pattern = '(?s)    <!-- GLOBAL_MARKET_BLOCK_START -->.*?    <!-- GLOBAL_MARKET_BLOCK_END -->'
    if ($index -match $pattern) {
        $index = [regex]::Replace($index, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $html }, 1)
        [System.IO.File]::WriteAllText($IndexPath, $index, [System.Text.UTF8Encoding]::new($false))
        Write-Host "Updated index.html global market block."
    } else {
        Write-Host "Warning: GLOBAL_MARKET_BLOCK markers not found in index.html."
    }
} else {
    Write-Host "Warning: index.html not found. Only global_market files were created."
}

Write-Host "DONE"
Write-Host "Created: $JsonOut"
Write-Host "Created: $HtmlOut"
Write-Host "Log: $LogOut"
