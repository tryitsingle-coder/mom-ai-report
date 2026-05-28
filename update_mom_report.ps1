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
        "2330" { return "S core" }
        "2308" { return "S core" }
        "2383" { return "S core" }
        "3017" { return "S core" }
        "2345" { return "S core" }
        "2317" { return "S core" }
        "2059" { return "S core" }
        "3661" { return "S core" }
        "4958" { return "A attack" }
        "3711" { return "A attack" }
        "2449" { return "A attack" }
        "2368" { return "A attack" }
        "3037" { return "A attack" }
        "8046" { return "A attack" }
        "3189" { return "A attack" }
        "6831" { return "A attack" }
        "0052" { return "ETF" }
        "0050" { return "ETF" }
        "00403A" { return "ETF" }
        default { return "Watch" }
    }
}

function GetSignal($price, $open, $high, $low, $prev) {
    $p = ToNumber $price
    $h = ToNumber $high
    $l = ToNumber $low
    $pr = ToNumber $prev
    if ($null -eq $p) { return @{Text="No data"; Class="stale-row"; Tag="stale"} }
    if ($null -ne $h -and $null -ne $l -and $h -ne $l) {
        $pos = ($p - $l) / ($h - $l)
        if ($pos -le 0.18) { return @{Text="Near low, wait"; Class="watch-row"; Tag="stale"} }
        if ($pos -ge 0.82) { return @{Text="Strong, do not chase"; Class="warn-row"; Tag="warn"} }
    }
    if ($null -ne $pr -and $pr -ne 0) {
        $chg = ($p - $pr) / $pr
        if ($chg -le -0.06) { return @{Text="Risk, defend"; Class="risk-row"; Tag="risk"} }
        if ($chg -ge 0.04) { return @{Text="Strong watch"; Class="warn-row"; Tag="warn"} }
    }
    return @{Text="Watch"; Class="neutral-row"; Tag="neutral"}
}

function LowZone($low, $price) {
    $l = ToNumber $low
    $p = ToNumber $price
    if ($null -eq $l -and $null -eq $p) { return "" }
    if ($null -eq $l) { $l = $p }
    return ("{0} - {1}" -f (Fmt ($l*0.995)), (Fmt ($l*1.005)))
}

function RiskLine($low, $price) {
    $l = ToNumber $low
    $p = ToNumber $price
    if ($null -eq $l -and $null -eq $p) { return "" }
    if ($null -eq $l) { $l = $p }
    return Fmt ($l*0.995)
}

function Pressure($high, $price) {
    $h = ToNumber $high
    $p = ToNumber $price
    if ($null -eq $h -and $null -eq $p) { return "" }
    if ($null -eq $h) { $h = $p }
    return ("{0} / {1}" -f (Fmt $h), (Fmt ($h*1.02)))
}

Write-Host "Reading DDE file: $DdePath"

if (!(Test-Path $DdePath)) {
    throw "Cannot find C:\DDE\yuanta_dde.xlsx. Please start Yuanta DDE first."
}

try {
    $excel = [Runtime.InteropServices.Marshal]::GetActiveObject("Excel.Application")
} catch {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
}

$wb = $null
foreach ($book in $excel.Workbooks) {
    if ($book.FullName -eq $DdePath) { $wb = $book; break }
}
if ($null -eq $wb) { $wb = $excel.Workbooks.Open($DdePath) }

$ws = $wb.Worksheets.Item("Sheet1")
$used = $ws.UsedRange
$rowCount = $used.Rows.Count

# Current yuanta_dde.xlsx layout:
# A code, B name, C prev, D open, E price, G high, H low, J volume
$records = @()
for ($r = 2; $r -le $rowCount; $r++) {
    $code = [string]$ws.Cells.Item($r, 1).Text
    $name = [string]$ws.Cells.Item($r, 2).Text
    $prev = $ws.Cells.Item($r, 3).Value2
    $open = $ws.Cells.Item($r, 4).Value2
    $price = $ws.Cells.Item($r, 5).Value2
    $high = $ws.Cells.Item($r, 7).Value2
    $low = $ws.Cells.Item($r, 8).Value2
    $vol = $ws.Cells.Item($r, 10).Value2
    if (($code.Trim() -eq "") -and ($name.Trim() -eq "") -and ($null -eq $price)) { continue }

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

function FindRec($code) {
    return $records | Where-Object { $_.Code -eq $code } | Select-Object -First 1
}

$focusCodes = @("2330","2308","2383","3017","2345","2317","2059","3661","4958","3711","2449","2368","3037","8046","3189","6831","0052","0050","00403A","1504","3715")
$core = $records | Where-Object { $focusCodes -contains $_.Code } | Select-Object -First 30

function RowHtml($x) {
    $tagClass = switch ($x.TagClass) {
        "risk" { "risk" }
        "warn" { "warn" }
        "stale" { "stale" }
        default { "neutral" }
    }
    return "<tr class='$($x.RowClass)'><td>$(HtmlEncode $x.Code)</td><td>$(HtmlEncode $x.Name)</td><td class='num'>$(Fmt $x.Price)</td><td class='num'>$(Fmt $x.Open)</td><td class='num'>$(Fmt $x.High)</td><td class='num'>$(Fmt $x.Low)</td><td class='num'>$(Fmt $x.Volume)</td><td>$(HtmlEncode $x.Topic)</td><td>$(HtmlEncode $x.LowZone)</td><td>$(HtmlEncode $x.RiskLine)</td><td>$(HtmlEncode $x.Pressure)</td><td><span class='tag $tagClass'>$(HtmlEncode $x.Signal)</span></td></tr>"
}

$coreRows = ($core | ForEach-Object { RowHtml $_ }) -join "`n"
$allRows = ($records | ForEach-Object { RowHtml $_ }) -join "`n"
$updateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$zd = FindRec "4958"
$zdPrice = if ($zd) { ToNumber $zd.Price } else { $null }
$zdNote = "4958 cost notes: Mom 509, Yushen 535. Watch 480/476 first; above 500 reduces pressure."
if ($null -ne $zdPrice) {
    if ($zdPrice -ge 500) { $zdNote = "4958 is back near/above 500. Mom 509 pressure is lower; Yushen 535 still needs staged recovery." }
    elseif ($zdPrice -lt 476) { $zdNote = "4958 is below 476 risk line. Do not average down weakly; defend first." }
}

$html = @"
<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mom AI Report</title>
  <style>
    :root { --ink:#1d2430; --muted:#667085; --line:#d8dee8; --bg:#f5f7fb; --panel:#fff; --green:#147a5a; --red:#b42318; --amber:#a15c07; }
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
    table { width:100%; border-collapse:collapse; font-size:14px; }
    th,td { border-bottom:1px solid var(--line); padding:9px 8px; text-align:left; vertical-align:top; }
    th { background:#f0f4f8; color:#344054; }
    .num { font-variant-numeric:tabular-nums; white-space:nowrap; }
    .tag { display:inline-flex; min-height:28px; align-items:center; border-radius:999px; padding:3px 9px; background:#eef3f8; border:1px solid #d7e0eb; white-space:nowrap; }
    .warn { color:var(--amber); background:#fff2d8; border-color:#f4d18a; }
    .risk { color:var(--red); background:#fde9e7; border-color:#f3b9b4; }
    .stale { color:#475467; background:#f2f4f7; border-color:#d0d5dd; }
    tr.risk-row td { background:#fff6f5; }
    tr.warn-row td { background:#fffaf0; }
    tr.watch-row td { background:#f8fafc; color:#475467; }
    .note { color:var(--muted); font-size:13px; margin:8px 0 0; }
    @media (max-width:900px) { .grid { grid-template-columns:1fr 1fr; } table { font-size:13px; } }
    @media (max-width:640px) { .grid { grid-template-columns:1fr; } th:nth-child(4),td:nth-child(4),th:nth-child(7),td:nth-child(7),th:nth-child(10),td:nth-child(10) { display:none; } }
  </style>
</head>
<body>
  <header>
    <div class="wrap">
      <h1>Mom AI Report</h1>
      <p class="lead">Data source: Yuanta DDE -> C:\DDE\yuanta_dde.xlsx -> one-click updater. Cost and share count are not shown on this public page.</p>
      <div class="grid">
        <div class="metric"><strong>$updateTime</strong><span>Update time</span></div>
        <div class="metric"><strong>DDE/V12</strong><span>Source</span></div>
        <div class="metric"><strong>Risk first</strong><span>No weak averaging down</span></div>
        <div class="metric"><strong>Wait support</strong><span>Do fewer, earn more</span></div>
      </div>
    </div>
  </header>
  <main class="wrap">
    <section>
      <h2>Priority notes</h2>
      <p>$zdNote</p>
      <p class="note">This is a watchlist and risk-control page, not a guaranteed trading signal.</p>
    </section>
    <section>
      <h2>Core watchlist</h2>
      <table>
        <thead><tr><th>Code</th><th>Name</th><th>Price</th><th>Open</th><th>High</th><th>Low</th><th>Vol</th><th>Group</th><th>Sweet zone</th><th>Risk</th><th>Pressure</th><th>Signal</th></tr></thead>
        <tbody>
$coreRows
        </tbody>
      </table>
    </section>
    <section>
      <h2>Full list</h2>
      <table>
        <thead><tr><th>Code</th><th>Name</th><th>Price</th><th>Open</th><th>High</th><th>Low</th><th>Vol</th><th>Group</th><th>Sweet zone</th><th>Risk</th><th>Pressure</th><th>Signal</th></tr></thead>
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
Write-Host "Created index.html"

Push-Location $RepoPath
try {
    if (Test-Path ".git") {
        git add index.html | Out-Null
        $status = git status --porcelain
        if ($status) {
            git commit -m "Update mom AI report from DDE" | Out-Null
            git push | Out-Null
            Write-Host "Pushed to GitHub Pages."
        } else {
            Write-Host "No index.html changes to push."
        }
    } else {
        Write-Host "This folder is not a Git repository. index.html was created only."
    }
} finally {
    Pop-Location
}
