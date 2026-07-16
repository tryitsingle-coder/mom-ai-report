
(() => {
  "use strict";

  const VERSION = "V29.1-20260716";
  const TARGETS = {
    "4958": {name:"臻鼎-KY", theme:"ABF/PCB", sweet:[610,620], first:[635,645], stop:600, priority:98},
    "3037": {name:"欣興", theme:"ABF", sweet:[885,910], first:[930,950], stop:870, priority:97},
    "8046": {name:"南電", theme:"ABF", sweet:[1320,1360], first:[1390,1415], stop:1290, priority:96},
    "3189": {name:"景碩", theme:"ABF", sweet:[780,810], first:[835,860], stop:760, priority:93},
    "6770": {name:"力積電", theme:"記憶體", sweet:[69,71], first:[74,76], stop:67.5, priority:91},
    "3711": {name:"日月光投控", theme:"先進封裝", sweet:[650,665], first:[680,695], stop:640, priority:90},
    "2454": {name:"聯發科", theme:"IC設計", sweet:[3550,3650], first:[3780,3850], stop:3490, priority:88},
    "6442": {name:"光聖", theme:"CPO", sweet:[1280,1340], first:[1390,1430], stop:1250, priority:87},
    "6239": {name:"力成", theme:"封測", sweet:[300,310], first:[320,330], stop:292, priority:86},
    "2327": {name:"國巨*", theme:"被動元件", sweet:[760,785], first:[810,830], stop:745, priority:84},
    "2308": {name:"台達電", theme:"AI電源", sweet:[1840,1880], first:[1930,1980], stop:1810, priority:84},
    "2330": {name:"台積電", theme:"晶圓代工", sweet:[2380,2420], first:[2460,2500], stop:2350, priority:95},
    "2344": {name:"華邦電", theme:"記憶體", sweet:[165,172], first:[178,185], stop:160, priority:82},
    "2408": {name:"南亞科", theme:"DRAM", sweet:[440,455], first:[475,490], stop:430, priority:89},
    "3044": {name:"健鼎", theme:"PCB", sweet:[410,420], first:[430,440], stop:402, priority:80}
  };

  const $ = (s, p=document) => p.querySelector(s);
  const $$ = (s, p=document) => [...p.querySelectorAll(s)];
  const num = v => {
    if (v == null) return NaN;
    const m = String(v).replace(/,/g,"").match(/-?\d+(?:\.\d+)?/);
    return m ? Number(m[0]) : NaN;
  };
  const esc = s => String(s ?? "").replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]));
  const overlayLoadedAt = new Date();
  let lastDataSignature = "";
  let lastDataChangedAt = null;
  let lastScanAt = null;

  function fmtTime(d) {
    if (!d) return "--";
    return new Intl.DateTimeFormat("zh-TW", {
      year:"numeric", month:"2-digit", day:"2-digit",
      hour:"2-digit", minute:"2-digit", second:"2-digit",
      hour12:false
    }).format(d);
  }

  function readRows() {
    const result = {};
    $$("table tr").forEach(tr => {
      const cells = $$("th,td", tr).map(x => x.textContent.trim());
      if (cells.length < 3) return;
      let codeIdx = cells.findIndex(x => /^\d{2,6}[A-Z]?$/.test(x.replace(/\s/g,"")));
      if (codeIdx < 0) return;
      const code = cells[codeIdx].replace(/\s/g,"").replace(/^0+(?=\d{2,})/,"");
      const canonical = Object.keys(TARGETS).find(k => String(Number(k)) === String(Number(code))) || code;
      if (!TARGETS[canonical]) return;
      const name = cells[codeIdx+1] || TARGETS[canonical].name;
      const nums = cells.slice(codeIdx+2).map(num).filter(Number.isFinite);
      if (!nums.length) return;
      // 常見順序：現價/開盤/最高/最低/量，或漲跌/昨收/開盤/幅度/成交價...
      let current = nums[0], open=NaN, high=NaN, low=NaN, volume=NaN;
      if (nums.length >= 8) {
        current = nums[4]; open = nums[2]; high = nums[5]; low = nums[6]; volume = nums[7];
      } else if (nums.length >= 5) {
        current = nums[0]; open = nums[1]; high = nums[2]; low = nums[3]; volume = nums[4];
      }
      result[canonical] = {code:canonical, name, current, open, high, low, volume};
    });
    return result;
  }

  function evaluate(code, row) {
    const t = TARGETS[code];
    const p = row?.current;
    let label="等待資料", cls="neutral", score=t.priority;
    if (Number.isFinite(p)) {
      if (p >= t.sweet[0] && p <= t.sweet[1]) { label="甜甜價｜可小量分批"; cls="buy"; score+=30; }
      else if (p < t.sweet[0] && p >= t.stop) { label="深甜區｜先等止跌紅K"; cls="deep"; score+=24; }
      else if (p < t.stop) { label="跌破防守｜先停手"; cls="risk"; score-=40; }
      else if (p <= t.first[0]) { label="接近甜區｜可掛低不追"; cls="watch"; score+=12; }
      else if (p <= t.first[1]) { label="第一波目標區｜偏賣不追"; cls="sell"; score-=5; }
      else { label="高於第一目標｜不追高"; cls="hot"; score-=18; }
      if (Number.isFinite(row.open) && p > row.open) score += 2;
      if (Number.isFinite(row.low) && p <= row.low * 1.012) score += 4;
    }
    return {...t, ...row, code, label, cls, score};
  }

  function render() {
    const rows = readRows();
    lastScanAt = new Date();
    const signature = JSON.stringify(Object.keys(rows).sort().map(k => [
      k, rows[k]?.current, rows[k]?.open, rows[k]?.high, rows[k]?.low, rows[k]?.volume
    ]));
    if (signature && signature !== "[]" && signature !== lastDataSignature) {
      lastDataSignature = signature;
      lastDataChangedAt = new Date();
    }
    const list = Object.keys(TARGETS).map(c => evaluate(c, rows[c])).sort((a,b)=>b.score-a.score);
    const actionable = list.filter(x => ["buy","deep","watch"].includes(x.cls)).slice(0,6);
    const avoid = list.filter(x => ["sell","hot","risk"].includes(x.cls)).slice(0,5);

    let root = $("#mom-v29-root");
    if (!root) {
      root = document.createElement("section");
      root.id = "mom-v29-root";
      document.body.prepend(root);
    }

    const card = x => `
      <div class="v29-card ${x.cls}">
        <div class="v29-title"><b>${esc(x.code)} ${esc(x.name)}</b><span>${Number.isFinite(x.current)?esc(x.current):"等待DDE"}</span></div>
        <div class="v29-status">${esc(x.label)}</div>
        <div class="v29-grid">
          <span>低接：<b>${x.sweet[0]}～${x.sweet[1]}</b></span>
          <span>第一賣價：<b>${x.first[0]}～${x.first[1]}</b></span>
          <span>防守：<b>${x.stop}</b></span>
          <span>${esc(x.theme)}</span>
        </div>
      </div>`;

    root.innerHTML = `
      <style>
        #mom-v29-root{font-family:system-ui,-apple-system,"Segoe UI","Noto Sans TC",sans-serif;background:#08111f;color:#eef5ff;padding:14px;border-bottom:3px solid #2f81f7;position:relative;z-index:9999}
        #mom-v29-root *{box-sizing:border-box}
        .v29-head{display:flex;justify-content:space-between;gap:10px;align-items:center;flex-wrap:wrap}
        .v29-head h2{margin:0;font-size:22px}.v29-badge{background:#17345e;border:1px solid #3979c9;border-radius:999px;padding:5px 10px;font-size:12px}
        .v29-note{margin:8px 0 12px;color:#b9c9df;font-size:13px}
        .v29-timebar{display:flex;flex-wrap:wrap;gap:6px 14px;margin-top:9px;padding:8px 10px;border-radius:9px;background:#0d1a2a;border:1px solid #29425f;font-size:12px;color:#c9d7e8}
        .v29-timebar b{color:#fff}
        .v29-live{font-weight:800}.v29-live.ok{color:#58d68d}.v29-live.wait{color:#f5c96a}
        .v29-section-title{font-weight:800;margin:12px 0 7px}
        .v29-wrap{display:grid;grid-template-columns:repeat(auto-fit,minmax(245px,1fr));gap:8px}
        .v29-card{border:1px solid #31435b;border-radius:12px;padding:10px;background:#101c2e}
        .v29-card.buy{background:#0d3528;border-color:#38a879}.v29-card.deep{background:#123d31;border-color:#52c798}
        .v29-card.watch{background:#25331b;border-color:#91b65c}.v29-card.sell{background:#3d3314;border-color:#d7ae36}
        .v29-card.hot{background:#412619;border-color:#e17b44}.v29-card.risk{background:#431b26;border-color:#d85971}
        .v29-title{display:flex;justify-content:space-between;gap:10px;font-size:16px}.v29-title span{font-weight:800}
        .v29-status{margin:6px 0;font-weight:800}.v29-grid{display:grid;grid-template-columns:1fr 1fr;gap:4px;font-size:12px;color:#d5dfec}
        .v29-small{font-size:12px;color:#aabbd1;margin-top:10px}
        .v29-collapse{cursor:pointer;border:1px solid #47617e;background:#10243d;color:#fff;border-radius:8px;padding:6px 10px}
        #mom-v29-root.collapsed .v29-body{display:none}
        @media(max-width:600px){#mom-v29-root{padding:10px}.v29-head h2{font-size:19px}.v29-grid{grid-template-columns:1fr}}
      </style>
      <div class="v29-head">
        <h2>即時低接雷達｜先看能不能買</h2>
        <div><span class="v29-badge">${VERSION}</span> <button class="v29-collapse" type="button">收合</button></div>
      </div>
      <div class="v29-timebar">
        <span>覆蓋載入：<b>${fmtTime(overlayLoadedAt)}</b></span>
        <span>最後掃描：<b>${fmtTime(lastScanAt)}</b></span>
        <span>盤面變動：<b>${fmtTime(lastDataChangedAt)}</b></span>
        <span class="v29-live ${lastDataChangedAt ? "ok" : "wait"}">${lastDataChangedAt ? "● 已讀到 DDE 資料" : "○ 等待 DDE 資料"}</span>
      </div>
      <div class="v29-body">
        <div class="v29-note">只讀取公開盤面資料，不顯示任何人持股、成本、股數，也不出現分析師姓名。看到「覆蓋載入」時間即代表 V29.1 已正確生效。</div>
        <div class="v29-section-title">🟢 今日低接優先排名</div>
        <div class="v29-wrap">${actionable.length ? actionable.map(card).join("") : '<div class="v29-card neutral">尚未讀到 DDE 表格，啟動每分鐘更新後會自動判斷。</div>'}</div>
        <div class="v29-section-title">🟠 過熱／防守名單</div>
        <div class="v29-wrap">${avoid.map(card).join("")}</div>
        <div class="v29-small">判讀原則：進入低接區才小量分批；跌破防守先停手；到第一波目標區偏向分批賣，不追價。處置股、漲停股與爆量長上影需另外保守處理。</div>
      </div>`;
    $(".v29-collapse",root)?.addEventListener("click", e=>{
      root.classList.toggle("collapsed");
      e.currentTarget.textContent=root.classList.contains("collapsed")?"展開":"收合";
    });
  }

  render();
  setInterval(render, 15000);
})();
