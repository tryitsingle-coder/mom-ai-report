﻿# fetch_global_market_now_v24.ps1
# Clean public version. Fetch Yahoo Finance chart API and generate global_market.json + global_market_block.html.
$ErrorActionPreference = "SilentlyContinue"
Set-Location -Path $PSScriptRoot
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$items = @(
  @{ label="NVIDIA"; symbol="NVDA"; inverse=$false },
  @{ label="台積電ADR"; symbol="TSM"; inverse=$false },
  @{ label="Nasdaq 100期貨"; symbol="NQ=F"; inverse=$false },
  @{ label="S&P 500期貨"; symbol="ES=F"; inverse=$false },
  @{ label="QQQ"; symbol="QQQ"; inverse=$false },
  @{ label="Nasdaq"; symbol="^IXIC"; inverse=$false },
  @{ label="S&P 500"; symbol="^GSPC"; inverse=$false },
  @{ label="VIX"; symbol="^VIX"; inverse=$true },
  @{ label="美元指數"; symbol="DX-Y.NYB"; inverse=$true },
  @{ label="美元/台幣"; symbol="TWD=X"; inverse=$true },
  @{ label="SOXX"; symbol="SOXX"; inverse=$false },
  @{ label="SMH"; symbol="SMH"; inverse=$false },
  @{ label="Dow 30"; symbol="^DJI"; inverse=$false },
  @{ label="Russell 2000"; symbol="^RUT"; inverse=$false }
)

function Get-PreviousItem($symbol) {
  try {
    if(Test-Path ".\global_market.json"){
      $old = Get-Content ".\global_market.json" -Raw -Encoding UTF8 | ConvertFrom-Json
      foreach($it in $old.items){
        if($it.symbol -eq $symbol -and $null -ne $it.pct){
          return $it
        }
      }
    }
  } catch {}
  return $null
}

function Get-YahooPct($symbol) {
  $encoded = [uri]::EscapeDataString($symbol)
  $urls = @(
    "https://query1.finance.yahoo.com/v8/finance/chart/$encoded?range=5d&interval=1d",
    "https://query2.finance.yahoo.com/v8/finance/chart/$encoded?range=5d&interval=1d"
  )
  foreach($url in $urls){
    try {
      $raw = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15 -Headers @{ "User-Agent"="Mozilla/5.0" }
      $r = $raw.Content | ConvertFrom-Json
      $meta = $r.chart.result[0].meta
      $price = [double]$meta.regularMarketPrice
      $prev = [double]$meta.previousClose
      if($prev -ne 0){
        $pct = (($price - $prev) / $prev) * 100
        return @{ price=$price; previous=$prev; pct=[math]::Round($pct,2); ok=$true; source="Yahoo Finance" }
      }
    } catch {}
  }

  $old = Get-PreviousItem $symbol
  if($null -ne $old){
    return @{ price=$old.price; previous=$old.previous; pct=$old.pct; ok=$true; source="沿用上一筆" }
  }
  return @{ price=$null; previous=$null; pct=$null; ok=$false; source="等待更新" }
}

$resultItems = @()
foreach($x in $items){
  $d = Get-YahooPct $x.symbol
  $resultItems += [pscustomobject]@{
    label = $x.label
    symbol = $x.symbol
    price = $d.price
    previous = $d.previous
    pct = $d.pct
    ok = $d.ok
    inverse = $x.inverse
    source = $d.source
  }
}

$score = 50
$okCount = 0
foreach($i in $resultItems){
  if($null -ne $i.pct){
    $okCount += 1
    $p=[double]$i.pct
    if($i.inverse){ if($p -gt 1){$score-=8}elseif($p -lt -1){$score+=5} }
    else { if($p -gt 1){$score+=6}elseif($p -lt -1){$score-=8} }
  }
}
if($score -lt 0){$score=0}; if($score -gt 100){$score=100}

if($okCount -eq 0){
  $status="等待國際盤資料 - 先看 09:08 真方向"
  $score=50
} elseif($score -ge 65){
  $status="偏多 - 可觀察回測低接"
} elseif($score -ge 45){
  $status="中性 - 等 09:08 真方向"
} else {
  $status="偏空 - 開低不急接"
}

$updated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$obj = [pscustomobject]@{ updated_at=$updated; source="Yahoo Finance chart API + previous fallback"; score=$score; status=$status; items=$resultItems }
$obj | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 -Path "global_market.json"

function CardClass($pct, $inverse){
  if($null -eq $pct){ return "summary-gray" }
  $p=[double]$pct
  if($inverse){
    if($p -gt 1){ return "summary-red" }
    if($p -lt -1){ return "summary-green" }
    return "summary-gray"
  } else {
    if($p -gt 1){ return "summary-green" }
    if($p -lt -1){ return "summary-red" }
    return "summary-yellow"
  }
}
$cards = ""
$cards += "<div class='summary-card summary-gray'><strong>盤前判讀</strong><span>$status</span><span class='names'>分數：$score / 100｜更新時間：$updated</span></div>`n"
foreach($i in $resultItems){
  if($null -eq $i.pct){
    $pctText = "等待更新"
  } else {
    $pctText = ("{0:+0.00;-0.00;0.00}%" -f [double]$i.pct)
  }
  $cls = CardClass $i.pct $i.inverse
  $cards += "<div class='summary-card $cls'><strong>$($i.label)</strong><span>$pctText</span><span class='names'>$($i.symbol)｜$($i.source)</span></div>`n"
}
$html = @"
<!-- GLOBAL_MARKET_BLOCK_START -->
<section class="panel global-radar-compact">
  <h2>國際盤前雷達｜自動更新</h2>
  <p class="note global-radar-note">資料來源：Yahoo Finance；若暫時抓不到會沿用上一筆或保持中性；只作為盤前條件加分/扣分。</p>
  <div class="summary-grid">
$cards
  </div>
</section>
<!-- GLOBAL_MARKET_BLOCK_END -->
"@
$html | Set-Content -Encoding UTF8 -Path "global_market_block.html"
"Global market radar updated: $updated score=$score ok=$okCount" | Tee-Object -FilePath "global_market_fetch.log" -Append
