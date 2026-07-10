
(() => {
  "use strict";
  const VERSION = "V27.5-20260711";
  const PANEL_ID = "v27-seven-giants-panel";
  const STYLE_ID = "v27-seven-giants-style";

  const GIANTS = [
    { code:"2330", name:"台積電", role:"晶圓代工／AI核心", weight:22 },
    { code:"3711", name:"日月光投控", role:"先進封裝／測試", weight:14 },
    { code:"5274", name:"信驊", role:"伺服器管理晶片", weight:12 },
    { code:"2383", name:"台光電", role:"AI高階CCL", weight:14 },
    { code:"6669", name:"緯穎", role:"AI伺服器", weight:14 },
    { code:"2382", name:"廣達", role:"AI伺服器／雲端", weight:14 },
    { code:"3653", name:"健策", role:"散熱／均熱片", weight:10 }
  ];

  function num(v) {
    if (v == null) return NaN;
    const s = String(v).replace(/,/g,"").replace(/%/g,"").trim();
    const x = Number(s);
    return Number.isFinite(x) ? x : NaN;
  }
  function esc(s) {
    return String(s ?? "").replace(/[&<>"']/g, m => ({
      "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"
    })[m]);
  }
  function text(el){ return (el?.textContent || "").replace(/\s+/g," ").trim(); }

  function getHeaderMap(table){
    const rows = [...table.querySelectorAll("tr")];
    for(const row of rows.slice(0,4)){
      const cells=[...row.children].map(c=>text(c));
      if(cells.some(x=>/代號/.test(x)) && cells.some(x=>/名稱/.test(x))){
        const map={};
        cells.forEach((x,i)=>{
          if(/代號/.test(x)) map.code=i;
          else if(/名稱/.test(x)) map.name=i;
          else if(/幅度|漲跌幅/.test(x)) map.pct=i;
          else if(/成交價|收盤|現價/.test(x)) map.price=i;
          else if(/^漲跌$/.test(x)) map.change=i;
          else if(/最高/.test(x)) map.high=i;
          else if(/最低/.test(x)) map.low=i;
          else if(/成交量/.test(x)) map.volume=i;
          else if(/昨量/.test(x)) map.prevVolume=i;
        });
        return map;
      }
    }
    return null;
  }

  function collectStocks(){
    const found = new Map();
    for(const table of document.querySelectorAll("table")){
      const map = getHeaderMap(table);
      if(!map || map.code == null) continue;
      for(const row of table.querySelectorAll("tr")){
        const cells=[...row.children];
        if(cells.length < 3) continue;
        const code=text(cells[map.code]);
        if(!/^\d{2,6}[A-Z]?$/.test(code)) continue;
        const rec={
          code,
          name: map.name!=null ? text(cells[map.name]) : "",
          price: map.price!=null ? num(text(cells[map.price])) : NaN,
          change: map.change!=null ? num(text(cells[map.change])) : NaN,
          pct: map.pct!=null ? num(text(cells[map.pct])) : NaN,
          high: map.high!=null ? num(text(cells[map.high])) : NaN,
          low: map.low!=null ? num(text(cells[map.low])) : NaN,
          volume: map.volume!=null ? num(text(cells[map.volume])) : NaN,
          prevVolume: map.prevVolume!=null ? num(text(cells[map.prevVolume])) : NaN
        };
        const old=found.get(code);
        const score=r=>[r.price,r.pct,r.volume].filter(Number.isFinite).length;
        if(!old || score(rec)>score(old)) found.set(code,rec);
      }
    }
    return found;
  }

  function statusOf(r){
    if(!r || !Number.isFinite(r.pct)) return {label:"無資料", cls:"na", score:0};
    const volRatio = Number.isFinite(r.volume) && Number.isFinite(r.prevVolume) && r.prevVolume>0
      ? r.volume/r.prevVolume : NaN;
    let score=50 + Math.max(-25,Math.min(25,r.pct*5));
    if(Number.isFinite(volRatio)){
      if(r.pct>0 && volRatio>=0.8) score+=8;
      if(r.pct<0 && volRatio>=0.8) score-=8;
    }
    score=Math.max(0,Math.min(100,score));
    if(r.pct>=2) return {label:"強勢",cls:"hot",score};
    if(r.pct>=0.3) return {label:"偏多",cls:"up",score};
    if(r.pct>-0.3) return {label:"中性",cls:"flat",score};
    if(r.pct>-2) return {label:"偏弱",cls:"down",score};
    return {label:"轉弱",cls:"cold",score};
  }

  function findGlobalSignal(){
    const body=text(document.body);
    const candidates=[
      ["極多","ext-hot"],["偏多","ext-up"],["中性偏多","ext-up"],
      ["中性","ext-flat"],["偏空","ext-down"],["極空","ext-cold"]
    ];
    const sections=[...document.querySelectorAll("section,article,div")].filter(x =>
      /全球|國際|美股|夜盤|台指|盤前雷達|市場溫度/.test(text(x).slice(0,120))
    );
    const scope=sections.map(text).join(" ") || body.slice(0,10000);
    for(const [label,cls] of candidates){
      if(scope.includes(label)) return {label,cls};
    }
    return {label:"讀取原有夜盤溫度計",cls:"ext-flat"};
  }

  function strategy(global, mainPct){
    const g=global.label;
    if(/極空|偏空/.test(g) && mainPct<43) return "雙弱：保守，不急接；等 09:08 與量價止穩。";
    if(/偏多|極多/.test(g) && mainPct>=57) return "雙多：優先找強股拉回，不追第一根急拉。";
    if(/偏空|極空/.test(g) && mainPct>=57) return "外弱內強：台股主線有韌性，只做支撐低接。";
    if(/偏多|極多/.test(g) && mainPct<50) return "外多內部分歧：指數可能紅，個股仍需挑選。";
    return "中性：等主線表態；以支撐、量價與不追高為主。";
  }

  function injectStyle(){
    if(document.getElementById(STYLE_ID)) return;
    const st=document.createElement("style");
    st.id=STYLE_ID;
    st.textContent=`
      #${PANEL_ID}{margin:18px auto;padding:18px;border:1px solid #2d3a52;border-radius:16px;
        background:linear-gradient(145deg,#111a2c,#0b1220);color:#eef4ff;box-shadow:0 12px 30px #0005}
      #${PANEL_ID} *{box-sizing:border-box}
      #${PANEL_ID} .v27-head{display:flex;gap:12px;align-items:flex-start;justify-content:space-between;flex-wrap:wrap}
      #${PANEL_ID} h2{margin:0;font-size:22px}
      #${PANEL_ID} .sub{opacity:.76;font-size:13px;margin-top:5px}
      #${PANEL_ID} .meters{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;margin:15px 0}
      #${PANEL_ID} .meter{padding:12px;border:1px solid #263650;border-radius:12px;background:#10192a}
      #${PANEL_ID} .meter b{display:block;font-size:18px;margin-top:5px}
      #${PANEL_ID} .bar{height:8px;background:#222c3d;border-radius:99px;overflow:hidden;margin-top:8px}
      #${PANEL_ID} .fill{height:100%;background:linear-gradient(90deg,#fb5,#2dd4bf);border-radius:99px}
      #${PANEL_ID} .strategy{padding:12px 14px;border-left:4px solid #38bdf8;background:#0b2136;border-radius:9px;margin-bottom:14px}
      #${PANEL_ID} .table-wrap{overflow-x:auto;max-width:100%;border-radius:11px;border:1px solid #263650}
      #${PANEL_ID} table{width:100%;min-width:760px;border-collapse:collapse;background:#0c1423}
      #${PANEL_ID} th,#${PANEL_ID} td{padding:10px 9px;border-bottom:1px solid #263044;text-align:right;white-space:nowrap}
      #${PANEL_ID} th{position:static!important;background:#172338;color:#dbeafe;font-size:13px}
      #${PANEL_ID} td:nth-child(1),#${PANEL_ID} td:nth-child(2),#${PANEL_ID} td:nth-child(3),
      #${PANEL_ID} th:nth-child(1),#${PANEL_ID} th:nth-child(2),#${PANEL_ID} th:nth-child(3){text-align:left}
      #${PANEL_ID} .pill{display:inline-block;padding:4px 8px;border-radius:99px;font-weight:700;font-size:12px}
      #${PANEL_ID} .hot,#${PANEL_ID} .up{background:#073d31;color:#5ee6b3}
      #${PANEL_ID} .flat,#${PANEL_ID} .na{background:#283447;color:#d7dfeb}
      #${PANEL_ID} .down,#${PANEL_ID} .cold{background:#4a1822;color:#ff8ba0}
      #${PANEL_ID} .pos{color:#35e59a;font-weight:700} #${PANEL_ID} .neg{color:#ff5f73;font-weight:700}
      #${PANEL_ID} .foot{font-size:12px;opacity:.68;margin-top:10px}
      @media(max-width:760px){#${PANEL_ID}{margin:10px;padding:13px}#${PANEL_ID} .meters{grid-template-columns:1fr}}
      /* 修正既有快照/100檔表格：表頭不再懸浮遮住資料；表格可左右捲動 */
      .v27-table-fix{overflow-x:auto!important;overflow-y:visible!important;max-width:100%!important}
      .v27-table-fix table{min-width:max-content!important}
      .v27-table-fix th{position:static!important;top:auto!important;z-index:auto!important}
    `;
    document.head.appendChild(st);
  }

  function repairExistingTables(){
    for(const table of document.querySelectorAll("table")){
      const p=table.parentElement;
      if(p) p.classList.add("v27-table-fix");
      for(const th of table.querySelectorAll("th")){
        th.style.position="static";
        th.style.top="auto";
      }
    }
  }

  function findAnchor(){
    const sections=[...document.querySelectorAll("section")];
    return sections.find(s=>/全球|國際|夜盤|盤前雷達|市場溫度/.test(text(s).slice(0,180)))
      || document.querySelector("main > section")
      || document.querySelector("main")
      || document.body;
  }

  function render(){
    injectStyle();
    repairExistingTables();
    const stocks=collectStocks();
    const global=findGlobalSignal();
    const rows=GIANTS.map(g=>{
      const r=stocks.get(g.code);
      const st=statusOf(r);
      return {...g, r, st};
    });
    const have=rows.filter(x=>Number.isFinite(x.r?.pct));
    const denominator=have.reduce((a,x)=>a+x.weight,0) || 1;
    const weighted=have.reduce((a,x)=>a+x.st.score*x.weight,0)/denominator;
    const mainPct=Math.round(weighted);
    const upCount=have.filter(x=>x.r.pct>0.3).length;
    const downCount=have.filter(x=>x.r.pct<-0.3).length;
    const breadth=have.length ? Math.round(upCount/have.length*100) : 0;

    let panel=document.getElementById(PANEL_ID);
    if(!panel){ panel=document.createElement("section"); panel.id=PANEL_ID; }
    panel.innerHTML=`
      <div class="v27-head">
        <div><h2>🧭 台股七巨頭主線溫度計</h2>
          <div class="sub">與原本美股夜盤＋台指夜盤溫度計並行｜${esc(VERSION)}</div></div>
        <span class="pill ${mainPct>=57?"up":mainPct<43?"down":"flat"}">${mainPct>=57?"主線偏多":mainPct<43?"主線偏弱":"主線中性"}</span>
      </div>
      <div class="meters">
        <div class="meter"><span>全球／夜盤風向</span><b>${esc(global.label)}</b><div class="bar"><div class="fill" style="width:${/偏多|極多/.test(global.label)?70:/偏空|極空/.test(global.label)?30:50}%"></div></div></div>
        <div class="meter"><span>七巨頭加權溫度</span><b>${mainPct}%</b><div class="bar"><div class="fill" style="width:${mainPct}%"></div></div></div>
        <div class="meter"><span>主線廣度</span><b>${upCount} 強／${downCount} 弱</b><div class="bar"><div class="fill" style="width:${breadth}%"></div></div></div>
      </div>
      <div class="strategy"><b>今日使用方式：</b>${esc(strategy(global,mainPct))}</div>
      <div class="table-wrap"><table>
        <thead><tr><th>代號</th><th>名稱</th><th>主線角色</th><th>成交／收盤</th><th>漲跌幅</th><th>量比</th><th>狀態</th></tr></thead>
        <tbody>${rows.map(x=>{
          const r=x.r||{};
          const vr=Number.isFinite(r.volume)&&Number.isFinite(r.prevVolume)&&r.prevVolume>0?r.volume/r.prevVolume:NaN;
          return `<tr><td>${x.code}</td><td>${esc(x.name)}</td><td>${esc(x.role)}</td>
            <td>${Number.isFinite(r.price)?r.price.toLocaleString("zh-TW"):"—"}</td>
            <td class="${Number.isFinite(r.pct)&&r.pct>=0?"pos":"neg"}">${Number.isFinite(r.pct)?(r.pct>0?"+":"")+r.pct.toFixed(2)+"%":"—"}</td>
            <td>${Number.isFinite(vr)?vr.toFixed(2)+"x":"—"}</td><td><span class="pill ${x.st.cls}">${x.st.label}</span></td></tr>`;
        }).join("")}</tbody>
      </table></div>
      <div class="foot">判讀順序：先看外部夜盤風向，再看七巨頭是否同步，最後才看個股低接雷達。此區不顯示任何個人持股、成本或股數。</div>`;

    const anchor=findAnchor();
    if(!panel.isConnected){
      if(anchor.tagName==="SECTION") anchor.insertAdjacentElement("afterend",panel);
      else anchor.prepend(panel);
    }
  }

  let timer;
  function schedule(){ clearTimeout(timer); timer=setTimeout(render,250); }
  if(document.readyState==="loading") document.addEventListener("DOMContentLoaded",render,{once:true});
  else render();
  new MutationObserver(schedule).observe(document.documentElement,{childList:true,subtree:true});
})();
