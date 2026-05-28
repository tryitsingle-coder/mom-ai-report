小駿媽媽AI網頁一鍵更新 使用說明

檔案：
1. 一鍵更新媽媽網頁.bat
2. update_mom_report.ps1

放置位置：
請把這兩個檔案放到 GitHub 專案資料夾 mom-ai-report 裡面，也就是有 index.html 的那個資料夾。

固定流程：
1. 開啟元大點金靈
2. 開啟 1013 DDE
3. 確認 C:\DDE\yuanta_dde.xlsx 有在跳動
4. 開啟 V12 確認資料正常
5. 到 mom-ai-report 資料夾，雙擊「一鍵更新媽媽網頁.bat」
6. 等待完成
7. 30 秒～2 分鐘後刷新媽媽網頁：
   https://tryitsingle-coder.github.io/mom-ai-report/

注意：
- yuanta_dde.xlsx 不要關掉，盤中要保持跳動。
- 如果 bat 顯示「此資料夾不是 Git 專案」，代表你沒有把檔案放到 mom-ai-report 的 GitHub 專案資料夾。
- 如果 git push 失敗，通常是 GitHub 登入或權限問題；index.html 仍會產生，可以手動上傳。
- 媽媽網頁不顯示成本與持股數。


# 小駿媽媽AI網頁一鍵更新
# 讀取 C:\DDE\yuanta_dde.xlsx 目前 Excel 內的即時值，產生 index.html，並嘗試 git push。

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

$DdePath = "C:\DDE\yuanta_dde.xlsx"
$RepoPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$IndexPath = Join-Path $RepoPath "index.html"

function HtmlEncode($s) {
    if ($null -eq $s) { return "" }
    return [System.Net.WebUtility]::HtmlEncode([string]$s)
}

function ToNumber($v) {
    if ($null -eq $v -or $v -eq "") { return $null }
    $s = ([string]$v).Replace(",", "").Trim()
    $n = 0.0
    if ([double]::TryParse($s, [ref]$n)) { return $n }
    return $null
}

function Fmt($v) {
    $n = ToNumber $v
    if ($null -eq $n) { return "" }
    if ([math]::Abs($n) -ge 1000) { return "{0:N0}" -f $n }
    if ([math]::Abs($n) -ge 100) { return "{0:0.#}" -f $n }
    return "{0:0.##}" -f $n
}

function GetTopic($code, $name) {
    $s = [string]$code
    switch ($s) {
        "2330" { return "S級｜大盤方向盤" }
        "2308" { return "S級｜AI電源" }
        "2383" { return "S級｜AI CCL" }
        "3017" { return "S級｜散熱" }
        "2345" { return "S級｜AI網通" }
        "2317" { return "S級｜AI伺服器" }
        "2059" { return "S級｜機構件" }
        "3661" { return "S級｜ASIC" }
        "4958" { return "A級｜AI PCB" }
        "3711" { return "A級｜封測" }
        "2449" { return "A級｜AI測試" }
        "2368" { return "A級｜AI PCB" }
        "3037" { return "A級｜ABF/PCB" }
        "8046" { return "A級｜ABF載板" }
        "3189" { return "A級｜載板" }
        "6831" { return "A級｜高波動" }
        "0052" { return "ETF｜科技底倉" }
        "0050" { return "ETF｜台灣50" }
        "00403A" { return "ETF｜升級50" }
        default { return "觀察" }
    }
}

function GetSignal($price, $open, $high, $low, $prev) {
    $p = ToNumber $price; $o = ToNumber $open; $h = ToNumber $high; $l = ToNumber $low; $pr = ToNumber $prev
    if ($null -eq $p) { return @{Text="無資料"; Class="stale-row"; Tag="stale"} }
    if ($null -ne $h -and $null -ne $l -and $h -ne $l) {
        $pos = ($p - $l) / ($h - $l)
        if ($pos -le 0.18) { return @{Text="收近低點，等止跌"; Class="watch-row"; Tag="watch"} }
        if ($pos -ge 0.82) { return @{Text="偏強，不追高"; Class="warn-row"; Tag="warn"} }
    }
    if ($null -ne $pr -and $pr -ne 0) {
        $chg = ($p - $pr) / $pr
        if ($chg -le -0.06) { return @{Text="跌幅較大，先防守"; Class="risk-row"; Tag="risk"} }
        if ($chg -ge 0.04) { return @{Text="轉強觀察，不追高"; Class="warn-row"; Tag="warn"} }
    }
    return @{Text="觀察"; Class="neutral-row"; Tag="neutral"}
}

function LowZone($low, $price) {
    $l = ToNumber $low; $p = ToNumber $price
    if ($null -eq $l -and $null -eq $p) { return "" }
    if ($null -eq $l) { $l = $p }
    return ("{0}～{1}" -f (Fmt ($l*0.995)), (Fmt ($l*1.005)))
}

function RiskLine($low, $price) {
    $l = ToNumber $low; $p = ToNumber $price
    if ($null -eq $l -and $null -eq $p) { return "" }
    if ($null -eq $l) { $l = $p }
    return Fmt ($l*0.995)
}

function Pressure($high, $price) {
    $h = ToNumber $high; $p = ToNumber $price
    if ($null -eq $h -and $null -eq $p) { return "" }
    if ($null -eq $h) { $h = $p }
    return ("{0} / {1}" -f (Fmt $h), (Fmt ($h*1.02)))
}

Write-Host "讀取元大報價檔：$DdePath"

if (!(Test-Path $DdePath)) {
    throw "找不到 $DdePath，請先用點金靈 DDE 輸出並另存成 yuanta_dde.xlsx"
}

# 連到正在執行的 Excel；讀取開著的 DDE 活頁簿，確保讀到即時跳動值。
$excel = $null
try {
    $excel = [Runtime.InteropServices.Marshal]::GetActiveObject("Excel.Application")
} catch {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
}

$wb = $null
foreach ($book in $excel.Workbooks) {
    if ($book.FullName -eq $DdePath) {
        $wb = $book
        break
    }
}
if ($null -eq $wb) {
    $wb = $excel.Workbooks.Open($DdePath)
}

$ws = $wb.Worksheets.Item("Sheet1")
$used = $ws.UsedRange
$rowCount = $used.Rows.Count
$colCount = $used.Columns.Count

$headers = @{}
for ($c = 1; $c -le $colCount; $c++) {
    $name = [string]$ws.Cells.Item(1,$c).Text
    if ($name -ne "") { $headers[$name.Trim()] = $c }
}

$required = @("代號","名稱","昨收","開盤","成交價","最高","最低","成交量")
foreach ($r in $required) {
    if (!$headers.ContainsKey($r)) {
        throw "yuanta_dde.xlsx 第1列找不到欄位：$r。請確認 DDE 欄位標題。"
    }
}

$records = @()
for ($r = 2; $r -le $rowCount; $r++) {
    $code = [string]$ws.Cells.Item($r, $headers["代號"]).Text
    $name = [string]$ws.Cells.Item($r, $headers["名稱"]).Text
    $price = $ws.Cells.Item($r, $headers["成交價"]).Value2
    if (($code.Trim() -eq "") -and ($name.Trim() -eq "") -and ($null -eq $price)) { continue }

    $prev = $ws.Cells.Item($r, $headers["昨收"]).Value2
    $open = $ws.Cells.Item($r, $headers["開盤"]).Value2
    $high = $ws.Cells.Item($r, $headers["最高"]).Value2
    $low = $ws.Cells.Item($r, $headers["最低"]).Value2
    $vol = $ws.Cells.Item($r, $headers["成交量"]).Value2
    $sig = GetSignal $price $open $high $low $prev

    $records += [pscustomobject]@{
        Code = $code.Trim()
        Name = $name.Trim()
        Prev = $prev
        Price = $price
        Open = $open
        High = $high
        Low = $low
        Volume = $vol
        Topic = GetTopic $code $name
        LowZone = LowZone $low $price
        RiskLine = RiskLine $low $price
        Pressure = Pressure $high $price
        Signal = $sig.Text
        RowClass = $sig.Class
        TagClass = $sig.Tag
    }
}

$updateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 重要持股與家人風險提醒
function FindRec($code) {
    return $records | Where-Object { $_.Code -eq $code -or ($code -eq "0052" -and $_.Name -like "*富邦科技*") -or ($code -eq "0050" -and $_.Name -like "*台灣50*") } | Select-Object -First 1
}

$tsmc = FindRec "2330"
$zd = FindRec "4958"
$jyk = FindRec "2449"
$teco = FindRec "1504"
$dy = FindRec "3715"
$etf52 = FindRec "0052"
$etf403 = FindRec "00403A"

$focusCodes = @("2330","2308","2383","3017","2345","2317","2059","3661","4958","3711","2449","2368","3037","8046","3189","6831","0052","0050","00403A","1504","3715")
$core = $records | Where-Object { $focusCodes -contains $_.Code -or $_.Name -like "*富邦科技*" -or $_.Name -like "*升級50*" } | Select-Object -First 30

function RowHtml($x) {
    $tagClass = switch ($x.TagClass) {
        "risk" {"risk"}
        "warn" {"warn"}
        "watch" {"stale"}
        "stale" {"stale"}
        default {"neutral"}
    }
    return "<tr class='$($x.RowClass)'><td>$(HtmlEncode $x.Code)</td><td>$(HtmlEncode $x.Name)</td><td class='num'>$(Fmt $x.Price)</td><td class='num'>$(Fmt $x.Open)</td><td class='num'>$(Fmt $x.High)</td><td class='num'>$(Fmt $x.Low)</td><td class='num'>$(Fmt $x.Volume)</td><td>$(HtmlEncode $x.Topic)</td><td>$(HtmlEncode $x.LowZone)</td><td>$(HtmlEncode $x.RiskLine)</td><td>$(HtmlEncode $x.Pressure)</td><td><span class='tag $tagClass'>$(HtmlEncode $x.Signal)</span></td></tr>"
}

$coreRows = ($core | ForEach-Object { RowHtml $_ }) -join "`n"
$allRows = ($records | ForEach-Object { RowHtml $_ }) -join "`n"

$zdPrice = if ($zd) { ToNumber $zd.Price } else { $null }
$momZdText = "臻鼎媽媽成本509、祐玄成本535；先看480/476是否守住，站回500再減壓。"
if ($null -ne $zdPrice) {
    if ($zdPrice -ge 500) { $momZdText = "臻鼎已站回500附近，媽媽509壓力下降；祐玄535仍需分段解套。" }
    elseif ($zdPrice -lt 476) { $momZdText = "臻鼎跌破476風險線，不加碼攤平，先防守。" }
}

$html = @"
<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>小駿台股 AI 投資自動更新報告</title>
  <style>
    :root { --ink:#1d2430; --muted:#667085; --line:#d8dee8; --bg:#f5f7fb; --panel:#fff; --green:#147a5a; --red:#b42318; --amber:#a15c07; --blue:#2364aa; }
    * { box-sizing:border-box; }
    body { margin:0; background:var(--bg); color:var(--ink); font-family:"Microsoft JhengHei","Noto Sans TC",system-ui,sans-serif; line-height:1.55; }
    .wrap { width:min(1180px,calc(100% - 32px)); margin:0 auto; }
    header { background:#eef3f8; border-bottom:1px solid var(--line); padding:28px 0 22px; }
    h1 { margin:0 0 10px; font-size:clamp(28px,4vw,46px); line-height:1.12; }
    h2 { margin:0 0 14px; font-size:22px; }
    main { padding:22px 0 44px; }
    section { background:var(--panel); border:1px solid var(--line); border-radius:10px; padding:18px; margin-bottom:16px; }
    .lead { color:#384253; margin:0; font-size:17px; }
    .grid { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:12px; margin-top:16px; }
    .metric { background:#fbfcfe; border:1px solid var(--line); border-radius:9px; padding:12px; }
    .metric strong { display:block; font-size:22px; }
    .metric span { display:block; color:var(--muted); font-size:13px; margin-top:4px; }
    .chips { display:flex; flex-wrap:wrap; gap:8px; }
    .chip { display:inline-flex; align-items:center; min-height:32px; padding:5px 10px; border-radius:999px; background:#eef3f8; border:1px solid #d7e0eb; }
    table { width:100%; border-collapse:collapse; font-size:14px; }
    th,td { border-bottom:1px solid var(--line); padding:9px 8px; text-align:left; vertical-align:top; }
    th { background:#f0f4f8; color:#344054; position:sticky; top:0; }
    .num { font-variant-numeric:tabular-nums; white-space:nowrap; }
    .tag { display:inline-flex; min-height:28px; align-items:center; border-radius:999px; padding:3px 9px; background:#eef3f8; border:1px solid #d7e0eb; white-space:nowrap; }
    .good { color:var(--green); background:#e7f5ee; border-color:#bee8d3; }
    .warn { color:var(--amber); background:#fff2d8; border-color:#f4d18a; }
    .risk { color:var(--red); background:#fde9e7; border-color:#f3b9b4; }
    .stale { color:#475467; background:#f2f4f7; border-color:#d0d5dd; }
    tr.risk-row td { background:#fff6f5; }
    tr.warn-row td { background:#fffaf0; }
    tr.watch-row td { background:#f8fafc; color:#475467; }
    .note { color:var(--muted); font-size:13px; margin:8px 0 0; }
    .cardline { margin:8px 0; }
    @media (max-width:900px) { .grid { grid-template-columns:1fr 1fr; } table { font-size:13px; } }
    @media (max-width:640px) { .grid { grid-template-columns:1fr; } th:nth-child(4),td:nth-child(4),th:nth-child(7),td:nth-child(7),th:nth-child(10),td:nth-child(10) { display:none; } }
  </style>
</head>
<body>
  <header>
    <div class="wrap">
      <h1>小駿台股 AI 投資自動更新報告</h1>
      <p class="lead">資料由元大點金靈 DDE → yuanta_dde.xlsx → 一鍵更新腳本產生。媽媽網頁不顯示成本與持股數。</p>
      <div class="grid">
        <div class="metric"><strong>$updateTime</strong><span>網頁更新時間（台北）</span></div>
        <div class="metric"><strong>V12/DDE</strong><span>資料來源</span></div>
        <div class="metric"><strong>一鍵更新</strong><span>GitHub Pages</span></div>
        <div class="metric"><strong>風控優先</strong><span>做得少，賺得多</span></div>
      </div>
    </div>
  </header>
  <main class="wrap">
    <section>
      <h2>優先提醒</h2>
      <p class="cardline">臻鼎-KY：$momZdText</p>
      <p class="cardline">媽媽帳戶：京元電子、定穎投控、東元仍以成本防守與不弱勢攤平為主。</p>
      <p class="cardline">操作原則：開高不追、急跌不攤、等回測不破與止跌訊號。</p>
      <div class="chips">
        <span class="chip">綠色：接近甜區/可觀察</span>
        <span class="chip">黃色：偏強但不追</span>
        <span class="chip">紅色：風險警訊</span>
        <span class="chip">灰色：收近低點，等止跌</span>
      </div>
      <p class="note">這是投資觀察表，不是保證獲利或下單指令。</p>
    </section>

    <section>
      <h2>核心觀察</h2>
      <table>
        <thead><tr><th>代碼</th><th>名稱</th><th>現價</th><th>開盤</th><th>最高</th><th>最低</th><th>量</th><th>分類</th><th>甜區觀察</th><th>風險線</th><th>壓力</th><th>訊號</th></tr></thead>
        <tbody>
$coreRows
        </tbody>
      </table>
    </section>

    <section>
      <h2>全部追蹤清單</h2>
      <table>
        <thead><tr><th>代碼</th><th>名稱</th><th>現價</th><th>開盤</th><th>最高</th><th>最低</th><th>量</th><th>分類</th><th>甜區觀察</th><th>風險線</th><th>壓力</th><th>訊號</th></tr></thead>
        <tbody>
$allRows
        </tbody>
      </table>
    </section>
  </main>
</body>
</html>
"@

[System.IO.File]::WriteAllText($IndexPath, $html, [System.Text.Encoding]::UTF8)
Write-Host "已產生：$IndexPath"

# 嘗試 git push
Push-Location $RepoPath
try {
    if (Test-Path ".git") {
        git add index.html | Out-Null
        $status = git status --porcelain
        if ($status) {
            git commit -m "Update mom AI report from DDE" | Out-Null
            git push | Out-Null
            Write-Host "已推送到 GitHub Pages。"
        } else {
            Write-Host "index.html 沒有變更，不需要推送。"
        }
    } else {
        Write-Host "此資料夾不是 Git 專案，已只產生 index.html，未自動 push。"
        Write-Host "請把本檔案放在 mom-ai-report 專案資料夾內執行。"
    }
} finally {
    Pop-Location
}

@echo off
chcp 65001 >nul
title 小駿媽媽AI網頁一鍵更新

echo.
echo =========================================
echo   小駿媽媽AI網頁一鍵更新
echo =========================================
echo.
echo 1. 請確認點金靈 DDE 開著
echo 2. 請確認 C:\DDE\yuanta_dde.xlsx 有在跳動
echo 3. 請確認本資料夾是 mom-ai-report GitHub 專案資料夾
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update_mom_report.ps1"

echo.
echo 如果上面顯示完成，等 30 秒～2 分鐘後刷新媽媽網頁。
echo https://tryitsingle-coder.github.io/mom-ai-report/
echo.
pause
