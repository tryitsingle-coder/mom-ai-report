$ErrorActionPreference = "SilentlyContinue"
Set-Location -Path $PSScriptRoot

$ExcelPath = "C:\DDE\yuanta_dde.xlsx"
$OutputHtml = Join-Path $PSScriptRoot "index.html"

$InlineCss = @'
*{box-sizing:border-box}
:root{
  --bg:#08111f;
  --bg2:#0f172a;
  --panel:#111c2f;
  --panel2:#0b1324;
  --line:#26344f;
  --text:#e5eefc;
  --muted:#9fb0cc;
  --soft:#17243a;
  --green:#22c55e;
  --green-bg:#102f22;
  --yellow:#facc15;
  --yellow-bg:#312a10;
  --red:#fb7185;
  --red-bg:#34131b;
  --blue:#60a5fa;
  --blue-bg:#10223d;
  --gray:#94a3b8;
}
body{
  margin:0;
  font-family:-apple-system,BlinkMacSystemFont,"Segoe UI","Noto Sans TC","Microsoft JhengHei",Arial,sans-serif;
  background:radial-gradient(circle at top left,#172554 0,#08111f 38%,#050914 100%);
  color:var(--text);
}
.hero{
  display:flex;justify-content:space-between;gap:24px;align-items:flex-start;
  padding:36px 28px;
  background:linear-gradient(135deg,#020617,#111827 52%,#1e293b);
  color:white;border-bottom:1px solid var(--line);
}
.eyebrow{margin:0 0 8px;color:#93c5fd;letter-spacing:.08em;text-transform:uppercase;font-size:13px}
.hero h1{margin:0;font-size:34px}
.subtitle{margin:10px 0 0;line-height:1.7;color:#dbeafe}
.updated{margin:10px 0 0;color:#cbd5e1}
.badge{min-width:160px;text-align:center;border:1px solid rgba(147,197,253,.32);border-radius:18px;padding:14px 18px;background:rgba(15,23,42,.65);font-weight:800;box-shadow:0 12px 32px rgba(0,0,0,.22)}
.badge span,.badge small{display:block;font-size:13px;color:#cbd5e1}
.badge strong{display:block;font-size:28px;margin:4px 0}
main{max-width:1180px;margin:0 auto;padding:24px}
.panel{
  background:linear-gradient(180deg,var(--panel),var(--panel2));
  border:1px solid var(--line);
  border-radius:22px;
  padding:22px;margin:18px 0;
  box-shadow:0 16px 42px rgba(0,0,0,.28);
}
.panel-title{display:flex;justify-content:space-between;gap:16px;align-items:end;margin-bottom:16px}
.panel-title h2{margin:0;font-size:22px}
.panel-title p{margin:0;color:var(--muted);line-height:1.6}
.decision-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:14px}
.decision{border-radius:18px;padding:16px;border:1px solid var(--line);background:#0c1628}
.decision h3{margin:0 0 8px}
.decision ul,.risk-list{margin:0;padding-left:20px;line-height:1.75}
.buy{border-color:#166534;background:#0d251d}
.sell{border-color:#854d0e;background:#251d0d}
.avoid,.risk{border-color:#7f1d1d;background:#271014}
.radar,.grid,.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:12px}
.radar>div,.grid>div,.card{border:1px solid var(--line);border-radius:18px;padding:16px;background:#0c1628}
.code{font-weight:900;font-size:22px;color:#bfdbfe}
.name{font-weight:700;margin-top:4px;color:#f8fafc}
.role{font-size:13px;color:var(--muted);margin-top:8px;line-height:1.5}
.note{color:var(--muted);line-height:1.7}
.table-wrap{overflow:auto;border:1px solid var(--line);border-radius:16px;background:#0b1324}
table{width:100%;border-collapse:collapse}
th,td{padding:11px 12px;border-bottom:1px solid var(--line);text-align:left;vertical-align:top}
th{font-size:13px;color:#cbd5e1;background:#162033;position:sticky;top:0}
td{color:#dbeafe}
tr:last-child td{border-bottom:0}
.watch-table tbody tr:hover{background:#13213a}
.section{margin:18px 0 24px}
.section h3{margin:0 0 10px;font-size:18px;color:#dbeafe}
.symbol{font-weight:900;color:#bfdbfe}
.lamp{display:inline-flex;align-items:center;gap:6px;border-radius:999px;padding:4px 9px;font-size:12px;font-weight:900;white-space:nowrap;border:1px solid transparent}
.lamp-strong{background:var(--green-bg);color:#86efac;border-color:#166534}
.lamp-up{background:#112b25;color:#6ee7b7;border-color:#166534}
.lamp-neutral{background:#162033;color:#cbd5e1;border-color:#334155}
.lamp-watch{background:var(--yellow-bg);color:#fde68a;border-color:#854d0e}
.lamp-weak{background:var(--red-bg);color:#fecdd3;border-color:#7f1d1d}
.stars{letter-spacing:1px;font-weight:900;white-space:nowrap}
.star5{color:#4ade80}.star4{color:#86efac}.star3{color:#cbd5e1}.star2{color:#facc15}.star1{color:#fb7185}
.price-up{color:#86efac;font-weight:800}.price-down{color:#fda4af;font-weight:800}.price-flat{color:#cbd5e1}
.global-radar-compact .summary-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px}
.summary-card{border:1px solid var(--line);border-radius:16px;padding:14px;background:#0c1628}
.summary-card strong{display:block;color:#f8fafc}
.summary-card span{display:block;margin-top:6px}
.summary-card .names{font-size:12px;color:var(--muted);line-height:1.5}
.summary-red{background:#2a1118;border-color:#7f1d1d}.summary-yellow{background:#2b240f;border-color:#854d0e}.summary-green{background:#0d281f;border-color:#166534}.summary-gray{background:#101827;border-color:#334155}
footer{text-align:center;color:var(--muted);padding:24px 16px 40px}
a{color:#93c5fd}
@media(max-width:720px){.hero{display:block}.badge{margin-top:18px}.panel-title{display:block}.hero h1{font-size:28px}}

'@

function Normalize-Code($x){
  if($null -eq $x){ return "" }
  $s = ($x.ToString()).Trim()
  if($s -match '^\d+$'){
    if($s -eq "9823"){ return "009823" }
    if($s -eq "9824"){ return "009824" }
  }
  return $s
}
function N($v){
  if($null -eq $v -or $v -eq ""){ return $null }
  try { return [double]$v } catch { return $null }
}
function F($v){
  if($null -eq $v){ return "-" }
  if([math]::Abs($v) -ge 1000){ return ("{0:N0}" -f $v) }
  return ("{0:N2}" -f $v).TrimEnd("0").TrimEnd(".")
}
function PctText($v){
  if($null -eq $v){ return "-" }
  return ("{0:+0.00;-0.00;0.00}%" -f [double]$v)
}
function PriceClass($pct){
  if($null -eq $pct){ return "price-flat" }
  if($pct -gt 0){ return "price-up" }
  if($pct -lt 0){ return "price-down" }
  return "price-flat"
}
function LampHtml($pct){
  if($null -eq $pct){ return "<span class='lamp lamp-neutral'>&#9898; 觀察</span>" }
  if($pct -ge 3){ return "<span class='lamp lamp-strong'>&#128994; 偏強</span>" }
  if($pct -ge 1){ return "<span class='lamp lamp-up'>&#128994; 轉強</span>" }
  if($pct -le -3){ return "<span class='lamp lamp-weak'>&#128308; 轉弱</span>" }
  if($pct -le -1){ return "<span class='lamp lamp-watch'>&#128993; 偏弱</span>" }
  return "<span class='lamp lamp-neutral'>&#9898; 中性</span>"
}
function StarsHtml($pct){
  if($null -eq $pct){ return "<span class='stars star3'>★★★</span>" }
  if($pct -ge 3){ return "<span class='stars star5'>★★★★★</span>" }
  if($pct -ge 1){ return "<span class='stars star4'>★★★★</span>" }
  if($pct -le -3){ return "<span class='stars star1'>★</span>" }
  if($pct -le -1){ return "<span class='stars star2'>★★</span>" }
  return "<span class='stars star3'>★★★</span>"
}
function StrategyText($pct){
  if($null -eq $pct){ return "等資料" }
  if($pct -ge 3){ return "強勢，等回測不追" }
  if($pct -ge 1){ return "轉強，觀察承接" }
  if($pct -le -3){ return "轉弱，先不攤平" }
  if($pct -le -1){ return "偏弱，等止跌" }
  return "中性，等方向" 
}

if(Test-Path ".\fetch_global_market_now_v24.ps1"){
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\fetch_global_market_now_v24.ps1" | Out-Null
}

$rows = @()
if(Test-Path $ExcelPath){
  try{
    $excel = New-Object -ComObject Excel.Application
    $excel.DisplayAlerts = $false
    $wb = $excel.Workbooks.Open($ExcelPath, $null, $true)
    $ws = $wb.Worksheets.Item(1)
    $used = $ws.UsedRange
    $max = [Math]::Min($used.Rows.Count, 500)
    for($r=2; $r -le $max; $r++){
      $code = Normalize-Code $ws.Cells.Item($r,1).Text
      $name = $ws.Cells.Item($r,2).Text
      if([string]::IsNullOrWhiteSpace($code) -or [string]::IsNullOrWhiteSpace($name)){ continue }
      $prev = N $ws.Cells.Item($r,5).Value2
      $open = N $ws.Cells.Item($r,6).Value2
      $price = N $ws.Cells.Item($r,8).Value2
      $high = N $ws.Cells.Item($r,9).Value2
      $low = N $ws.Cells.Item($r,10).Value2
      $vol = N $ws.Cells.Item($r,11).Value2
      $bid = N $ws.Cells.Item($r,21).Value2
      $ask = N $ws.Cells.Item($r,22).Value2
      $chgPct = $null
      if($prev -and $prev -ne 0 -and $price){ $chgPct = [math]::Round((($price-$prev)/$prev)*100,2) }
      $rows += [pscustomobject]@{ code=$code; name=$name; prev=$prev; open=$open; price=$price; high=$high; low=$low; vol=$vol; bid=$bid; ask=$ask; pct=$chgPct }
    }
    $wb.Close($false); $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($ws) | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wb) | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
  } catch {
    "Excel read failed: $($_.Exception.Message)" | Tee-Object -FilePath "update_ai_report.log" -Append
  }
}

$now = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
$tableRows = ""
foreach($x in $rows){
  $pc = PriceClass $x.pct
  $tableRows += "<tr><td>$(LampHtml $x.pct)</td><td class='symbol'>$($x.code)</td><td>$($x.name)</td><td class='$pc'>$(F $x.price)</td><td class='$pc'>$(PctText $x.pct)</td><td>$(StarsHtml $x.pct)</td><td>$(F $x.high)</td><td>$(F $x.low)</td><td>$(F $x.vol)</td><td>$(StrategyText $x.pct)</td></tr>`n"
}
if($tableRows -eq ""){
  $tableRows = "<tr><td colspan='10'>尚未讀到 DDE Excel。請確認 C:\DDE\yuanta_dde.xlsx 已開啟並有資料。</td></tr>"
}

$globalBlock = ""
if(Test-Path ".\global_market_block.html"){ $globalBlock = Get-Content ".\global_market_block.html" -Raw -Encoding UTF8 }

$html = @"
<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>AI投資觀察報告｜黑底護眼版自動更新</title>
  <link rel="stylesheet" href="style.css">
  <style>
$InlineCss
  </style>
</head>
<body>
<header class="hero">
  <div>
    <p class="eyebrow">PUBLIC AI REPORT</p>
    <h1>AI 投資觀察報告｜黑底護眼版自動更新</h1>
    <p class="subtitle">公開版只顯示市場觀察、甜區、壓力、風險與紀律；不顯示任何個人持股、成本、股數或損益。</p>
    <p class="updated">最後更新：$now</p>
  </div>
  <div class="badge"><span>盤中紀律</span><strong>看燈號</strong><small>不追高，先看支撐</small></div>
</header>
<main>
  <section class="panel priority">
    <div class="panel-title"><h2>優先提醒</h2><p>09:08 前先看試撮，09:30 後看真方向；ETF 優先，個股只做回測有守。</p></div>
    <div class="decision-grid">
      <article class="decision buy"><h3>低接條件</h3><ul><li>台積電與 0052 守住支撐。</li><li>個股回測有量縮承接。</li><li>急拉不追，等第一根止跌紅K。</li></ul></article>
      <article class="decision avoid"><h3>縮手條件</h3><ul><li>台積電跌破盤前關鍵支撐。</li><li>AI 測試鏈/CPO 同步轉弱。</li><li>處置股開高爆量翻黑。</li></ul></article>
    </div>
  </section>

  $globalBlock

  <section class="panel">
    <div class="panel-title"><h2>DDE 即時觀察表｜燈號版</h2><p>🟢 強勢 / 🟡 偏弱觀察 / 🔴 轉弱縮手；星級只是短線熱度，不代表一定買。</p></div>
    <div class="table-wrap">
      <table class="watch-table">
        <thead><tr><th>燈號</th><th>代號</th><th>名稱</th><th>成交</th><th>漲跌%</th><th>星級</th><th>最高</th><th>最低</th><th>量</th><th>操作提醒</th></tr></thead>
        <tbody>$tableRows</tbody>
      </table>
    </div>
  </section>

  <section class="panel risk">
    <div class="panel-title"><h2>風險警報</h2><p>跌破關鍵支撐，不硬接、不攤平。</p></div>
    <ul class="risk-list">
      <li>權值股轉弱時，個股短打降級。</li>
      <li>處置股只觀察承接，不追第一根急拉。</li>
      <li>公開版不顯示任何個人交易資料。</li>
    </ul>
  </section>
</main>
<footer>公開版：僅供投資紀律與觀察，不含個人持股/成本/股數/損益。</footer>
<script src="dde-watchlist.js"></script>
</body>
</html>
"@

$html | Set-Content -Encoding UTF8 -Path $OutputHtml

if(Test-Path ".git"){
  git add index.html style.css dde-watchlist.js global_market.json global_market_block.html fetch_global_market_now_v24.ps1 update_ai_report_public_v24.ps1 auto_update_1min_public_v24.bat RUN_ONCE_update_public_report.bat 2>$null
  git commit -m "Restore dark theme and add DDE signal lights" 2>$null
  git push 2>$null
}
"Updated: $now" | Tee-Object -FilePath "update_ai_report.log" -Append
