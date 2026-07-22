(function () {
  "use strict";
  if (typeof document === "undefined") return;

  var PANEL_ID = "mom-ai-intraday-20260720-1124";
  var STYLE_ID = PANEL_ID + "-style";

  function removeOld() {
    [
      "mom-ai-intraday-20260720-0943",
      "mom-ai-intraday-20260720-1017",
      "mom-ai-intraday-20260720-1032",
      "mom-ai-intraday-20260720-1110",
      PANEL_ID
    ].forEach(function (id) {
      var el = document.getElementById(id);
      if (el && el.parentNode) el.parentNode.removeChild(el);
    });
    var oldStyle = document.getElementById(STYLE_ID);
    if (oldStyle && oldStyle.parentNode) oldStyle.parentNode.removeChild(oldStyle);
  }

  function addStyle() {
    var style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = `
      #${PANEL_ID}{
        margin:16px auto 20px; padding:18px; max-width:1180px;
        border:1px solid #dbe4ee; border-radius:18px;
        background:linear-gradient(135deg,#f8fbff,#ffffff);
        box-shadow:0 10px 30px rgba(15,23,42,.08);
        font-family:system-ui,-apple-system,"Microsoft JhengHei",sans-serif;
        color:#172033;
      }
      #${PANEL_ID} h2{margin:0 0 8px;font-size:clamp(20px,3vw,30px)}
      #${PANEL_ID} .sub{margin:0 0 14px;color:#526174;line-height:1.65}
      #${PANEL_ID} .pills{display:flex;flex-wrap:wrap;gap:8px;margin:10px 0 16px}
      #${PANEL_ID} .pill{padding:7px 11px;border-radius:999px;font-weight:800;font-size:13px;background:#e8eef6}
      #${PANEL_ID} .ok{background:#dcfce7;color:#166534}
      #${PANEL_ID} .warn{background:#fef3c7;color:#92400e}
      #${PANEL_ID} .danger{background:#fee2e2;color:#991b1b}
      #${PANEL_ID} .grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}
      #${PANEL_ID} .card{border:1px solid #e3e9f0;border-radius:14px;padding:14px;background:#fff}
      #${PANEL_ID} .card h3{margin:0 0 8px;font-size:17px}
      #${PANEL_ID} table{width:100%;border-collapse:collapse;margin-top:8px;font-size:14px}
      #${PANEL_ID} th,#${PANEL_ID} td{padding:9px 8px;border-bottom:1px solid #e8edf3;text-align:left;vertical-align:top}
      #${PANEL_ID} th{background:#f4f7fb}
      #${PANEL_ID} .best{font-weight:900;color:#0f766e}
      #${PANEL_ID} .avoid{font-weight:900;color:#b91c1c}
      #${PANEL_ID} .note{margin:12px 0 0;padding:12px 14px;border-left:5px solid #f59e0b;background:#fffbeb;border-radius:10px;line-height:1.65}
      #${PANEL_ID} .foot{margin-top:12px;color:#64748b;font-size:12px}
      @media(max-width:760px){#${PANEL_ID} .grid{grid-template-columns:1fr}#${PANEL_ID}{margin:10px;padding:14px}}
    `;
    document.head.appendChild(style);
  }

  function addPanel() {
    var panel = document.createElement("section");
    panel.id = PANEL_ID;
    panel.innerHTML = `
      <h2>07/20 11:24 盤中決策｜權值續強、PCB／ABF高檔分化</h2>
      <p class="sub">
        台積電2385貼近日高，指數結構仍偏多；欣興、景碩、台燿、聯茂維持強勢。
        南電1190已上漲7.69%，雖仍屬主線，但隔日震盪風險高於台積電。
      </p>
      <div class="pills">
        <span class="pill ok">盤勢：偏多</span>
        <span class="pill ok">最穩候選：台積電拉回</span>
        <span class="pill warn">南電：強勢但不追</span>
        <span class="pill danger">中探針跌停／環球晶弱</span>
      </div>

      <div class="grid">
        <div class="card">
          <h3>👩 媽媽快速看</h3>
          <table>
            <tr><th>項目</th><th>目前判斷</th></tr>
            <tr><td>市場方向</td><td>權值、AI伺服器、PCB／ABF偏多，但高檔股開始分化。</td></tr>
            <tr><td>明日求穩</td><td class="best">台積電優先，但只等回測，不追2385以上。</td></tr>
            <tr><td>高波動選擇</td><td>南電仍強，但今天漲幅大，明天可能沖高震盪。</td></tr>
            <tr><td>操作原則</td><td>拉回分批、漲停不追、弱勢跌破支撐不硬接。</td></tr>
          </table>
        </div>

        <div class="card">
          <h3>🎯 今日低接與警戒</h3>
          <table>
            <tr><th>股票</th><th>等待區</th><th>不要追／警戒</th></tr>
            <tr><td>2330 台積電</td><td><b>2370～2375</b><br>第二區2355～2360</td><td>2385以上不追；2345失守且站不回轉保守</td></tr>
            <tr><td>8046 南電</td><td><b>1165～1170</b><br>第二區1150～1155</td><td>1190附近不追；1145失守停止低接</td></tr>
            <tr><td>4958 臻鼎-KY</td><td>490～493觀察</td><td>506前有壓；已有部位者不宜重複加碼</td></tr>
            <tr><td>3711 日月光</td><td>615～620觀察</td><td>625～633為短壓區</td></tr>
          </table>
        </div>

        <div class="card">
          <h3>🔥 強勢主線</h3>
          <table>
            <tr><th>族群</th><th>代表股</th></tr>
            <tr><td>PCB／ABF</td><td>欣興、景碩、南電、台光電、台燿、聯茂、金像電</td></tr>
            <tr><td>AI／伺服器</td><td>台積電、聯發科、創意、緯穎、台達電、奇鋐</td></tr>
            <tr><td>測試介面</td><td>旺矽、穎崴、精測轉強；中探針仍極弱</td></tr>
            <tr><td>電力</td><td>華城、中興電、士電、亞力溫和走強</td></tr>
          </table>
        </div>

        <div class="card">
          <h3>⚠️ 盤中風險</h3>
          <table>
            <tr><th>現象</th><th>解讀</th></tr>
            <tr><td>南電高檔震盪</td><td>主線未壞，但今日漲幅已大，不適合用追價換明日勝率。</td></tr>
            <tr><td>個股分化</td><td>尖點、環球晶、中探針等明顯弱，不能把紅盤視為全面安全。</td></tr>
            <tr><td>被動元件劇烈分化</td><td>國巨反彈，但華新科、信昌電重挫，族群不是全面多頭。</td></tr>
            <tr><td>午盤追價風險</td><td>強勢股已累積漲幅，午後若量縮，隔日容易出現獲利賣壓。</td></tr>
          </table>
        </div>
      </div>

      <div class="note">
        <b>一句話：</b>明天求穩選台積電，但只買拉回；南電爆發力較高、隔日風險也較高。
        今天若台積電不回2375以下，寧可沒有成交，也不要在日高附近追價。
      </div>
      <div class="foot">公開版不顯示任何個人持股、成本或股數｜資料時間：07/20 11:24</div>
    `;

    var target = document.querySelector("main") || document.body;
    target.insertBefore(panel, target.firstChild);
  }

  function run() {
    removeOld();
    addStyle();
    addPanel();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();