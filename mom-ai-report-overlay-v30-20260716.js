(() => {
  "use strict";

  const VERSION = "V31.0-20260716-DDE-SUPPORT";
  const TARGETS = {
    "4958": {name:"臻鼎-KY", theme:"ABF/PCB", sweet:[578,586], deep:[568,572], sell1:[598,603], sell2:[610,615], stop:575, priority:100, zero:true},
    "3037": {name:"欣興", theme:"ABF", sweet:[887,894], deep:[870,875], sell1:[912,920], sell2:[928,938], stop:880, priority:99, zero:true},
    "3189": {name:"景碩", theme:"ABF", sweet:[812,826], deep:[798,805], sell1:[842,850], sell2:[860,872], stop:810, priority:97, zero:true},
    "8046": {name:"南電", theme:"ABF", sweet:[1315,1325], deep:[1290,1305], sell1:[1360,1380], sell2:[1400,1415], stop:1275, priority:96, zero:true},
    "6239": {name:"力成", theme:"AI封測", sweet:[304,309], deep:[298,302], sell1:[313,314], sell2:[317,319], stop:304, priority:91, zero:true},
    "2308": {name:"台達電", theme:"AI電源", sweet:[1815,1830], deep:[1780,1800], sell1:[1850,1860], sell2:[1880,1890], stop:1815, priority:89, zero:true},
    "2327": {name:"國巨*", theme:"被動元件", sweet:[775,789], deep:[755,768], sell1:[800,807], sell2:[812,818], stop:774, priority:88, zero:true},
    "2454": {name:"聯發科", theme:"IC設計", sweet:[3600,3640], deep:[3520,3570], sell1:[3675,3690], sell2:[3720,3740], stop:3600, priority:87, zero:true},
    "52":   {name:"富邦科技", theme:"ETF", sweet:[60.8,61.3], deep:[60.2,60.6], sell1:[61.7,61.9], sell2:[62.1,62.3], stop:60.8, priority:78, zero:true},
    "6770": {name:"力積電", theme:"記憶體", sweet:[70,72], deep:[68.5,69.5], sell1:[74,76], sell2:[77.5,79], stop:68, priority:90, zero:true},
    "6442": {name:"光聖", theme:"CPO", sweet:[1300,1320], deep:[1290,1298], sell1:[1385,1405], sell2:[1430,1450], stop:1290, priority:86, zero:true},
    "6451": {name:"訊芯-KY", theme:"光通訊", sweet:[470,485], deep:[450,465], sell1:[500,510], sell2:[520,535], stop:448, priority:83, zero:true},
    "2330": {name:"台積電", theme:"晶圓代工", sweet:[2395,2420], deep:[2370,2390], sell1:[2450,2460], sell2:[2480,2500], stop:2370, priority:94, zero:true},
    "2449": {name:"京元電子", theme:"AI測試", sweet:[296,303], deep:[288,294], sell1:[309,314], sell2:[318,323], stop:288, priority:85, zero:true},
    "3711": {name:"日月光投控", theme:"先進封裝", sweet:[660,672], deep:[645,655], sell1:[680,690], sell2:[695,705], stop:645, priority:86, zero:true},
    "2344": {name:"華邦電", theme:"記憶體", sweet:[168,173], deep:[163,167], sell1:[178,182], sell2:[185,190], stop:162.5, priority:82, zero:true},
    "2408": {name:"南亞科", theme:"DRAM", sweet:[440,450], deep:[433,439], sell1:[462,475], sell2:[481,490], stop:433, priority:84, zero:true},
    "8299": {name:"群聯", theme:"記憶體控制", sweet:[1930,1970], deep:[1895,1920], sell1:[2020,2050], sell2:[2090,2120], stop:1895, priority:83, zero:true},
    "7710": {name:"東擎科技", theme:"上市審議", sweet:[232,240], deep:[220,228], sell1:[248,255], sell2:[260,268], stop:218, priority:76, zero:true}
  };

  const $=(s,p=document)=>p.querySelector(s), $$=(s,p=document)=>[...p.querySelectorAll(s)];
  const esc=s=>String(s??"").replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]));
  const num=v=>{ const m=String(v??"").replace(/,/g,"").match(/-?\d+(?:\.\d+)?/); return m?Number(m[0]):NaN; };
  const fmt=n=>Number.isFinite(n)?new Intl.NumberFormat("zh-TW",{maximumFractionDigits:2}).format(n):"等待DDE";
  const loadedAt=new Date(); let lastSignature="", changedAt=null, scanAt=null;

  function time(d){return d?new Intl.DateTimeFormat("zh-TW",{month:"2-digit",day:"2-digit",hour:"2-digit",minute:"2-digit",second:"2-digit",hour12:false}).format(d):"--";}
  function canonical(raw){ const x=String(raw||"").trim().replace(/^0+(?=\d)/,""); return TARGETS[x]?x:(TARGETS[String(Number(x))]?String(Number(x)):x); }

  function readFromTables(){
    const out={};
    const aliases={
      code:['代號','股票代號','code'], name:['名稱','股票名稱','name'], change:['漲跌','漲跌價差','change'],
      prev:['昨收','昨日收盤','prev'], open:['開盤','open'], pct:['幅度%','漲跌幅','漲幅%','pct'],
      current:['成交價','現價','成交','current','price'], high:['最高','high'], low:['最低','low'],
      volume:['成交量','volume'], prevVolume:['昨量','昨日量','prevvolume'], lastQty:['單量','最新單量','lastqty'], amount:['成交金額','amount'], sellQty:['賣量','委賣量','sellqty'], buyQty:['買量','委買量','buyqty'], bid:['買進','買價','bid'], ask:['賣出','賣價','ask']
    };
    const norm=v=>String(v||'').replace(/\s+/g,'').toLowerCase();
    $$('table').forEach(table=>{
      const trs=$$('tr',table); if(!trs.length)return;
      let headerIndex=-1, map={};
      for(let r=0;r<Math.min(4,trs.length);r++){
        const cells=$$('th,td',trs[r]).map(x=>norm(x.textContent));
        const temp={};
        for(const [key,names] of Object.entries(aliases)){
          const idx=cells.findIndex(c=>names.some(n=>c===norm(n)));
          if(idx>=0)temp[key]=idx;
        }
        if(temp.code!==undefined && (temp.current!==undefined || temp.change!==undefined)){headerIndex=r;map=temp;break;}
      }
      if(headerIndex<0)return;
      trs.slice(headerIndex+1).forEach(tr=>{
        const c=$$('th,td',tr).map(x=>x.textContent.trim());
        const code=canonical(c[map.code]); if(!TARGETS[code])return;
        const row={code,name:map.name!==undefined?(c[map.name]||TARGETS[code].name):TARGETS[code].name};
        for(const key of ['change','prev','open','pct','current','high','low','volume','prevVolume','lastQty','amount','sellQty','buyQty','bid','ask']){
          if(map[key]!==undefined)row[key]=num(c[map[key]]);
        }
        if(Number.isFinite(row.current))out[code]=row;
      });
    });
    return out;
  }

  function readFromGlobals(){
    const out={}; const pools=[];
    for(const k of Object.keys(window)){
      try{const v=window[k]; if(Array.isArray(v)&&v.length&&typeof v[0]==='object')pools.push(v); else if(v&&Array.isArray(v.rows))pools.push(v.rows);}catch(_){ }
    }
    pools.forEach(arr=>arr.forEach(r=>{ const raw=r?.代號??r?.code; const code=canonical(raw); if(!TARGETS[code])return; const p=num(r?.成交價??r?.current??r?.price); if(!Number.isFinite(p))return; out[code]={code,name:r?.名稱??TARGETS[code].name,current:p,open:num(r?.開盤),high:num(r?.最高),low:num(r?.最低),volume:num(r?.成交量),prevVolume:num(r?.昨量),lastQty:num(r?.單量),amount:num(r?.成交金額),sellQty:num(r?.賣量),buyQty:num(r?.買量),bid:num(r?.買進),ask:num(r?.賣出),pct:num(r?.['幅度%']),change:num(r?.漲跌)}; }));
    return out;
  }

  function evaluate(code,row){
    const t=TARGETS[code], p=row?.current; let score=t.priority, cls='neutral', action='等待盤面資料';
    if(Number.isFinite(p)){
      if(p<t.stop){score-=32;cls='risk';action='跌破防守｜先停手等站回';}
      else if(p>=t.sweet[0]&&p<=t.sweet[1]){score+=18;cls='buy';action='甜甜價｜可小量分批';}
      else if(p>=t.deep[0]&&p<=t.deep[1]){score+=13;cls='deep';action='深甜區｜只接止跌紅K';}
      else if(p<t.deep[0]){score-=10;cls='risk';action='跌太快｜不要徒手接刀';}
      else if(p<t.sweet[0]){score+=8;cls='watch';action='接近甜區｜等不破低';}
      else if(p<=t.sell1[0]){score+=2;cls='watch';action='甜區上方｜掛低不追';}
      else if(p<=t.sell2[1]){score-=7;cls='sell';action='第一波賣區｜偏賣不追';}
      else{score-=18;cls='hot';action='偏高｜等待回測';}
      if(Number.isFinite(row.low)&&p<=row.low*1.008)score-=3;
      if(Number.isFinite(row.open)&&p>=row.open)score+=4;
      if(Number.isFinite(row.high)&&p>=row.high*.995)score+=2;
      if(Number.isFinite(row.pct)&&row.pct>=5&&Number.isFinite(row.change)&&row.change<0)score-=5;
    }
    // DDE 即時承接力：只使用 DDE 可取得欄位，不冒充真正內外盤或五檔總量。
    let supportScore=50, supportLabel='資料不足', supportClass='flat';
    const dayRange=(Number.isFinite(row.high)&&Number.isFinite(row.low))?(row.high-row.low):NaN;
    const dayPos=(Number.isFinite(p)&&Number.isFinite(dayRange)&&dayRange>0)?(p-row.low)/dayRange:NaN;
    const volRatio=(Number.isFinite(row.volume)&&Number.isFinite(row.prevVolume)&&row.prevVolume>0)?row.volume/row.prevVolume:NaN;
    const bookTotal=(Number.isFinite(row.buyQty)?row.buyQty:0)+(Number.isFinite(row.sellQty)?row.sellQty:0);
    const buyRatio=bookTotal>0?(Number.isFinite(row.buyQty)?row.buyQty:0)/bookTotal:NaN;
    if(Number.isFinite(dayPos)) supportScore += (dayPos-.5)*34;
    if(Number.isFinite(buyRatio)) supportScore += (buyRatio-.5)*30;
    if(Number.isFinite(row.bid)&&Number.isFinite(row.ask)&&row.ask>row.bid&&Number.isFinite(p)){
      const quotePos=(p-row.bid)/(row.ask-row.bid);
      supportScore += (Math.max(0,Math.min(1,quotePos))-.5)*18;
    }
    if(Number.isFinite(volRatio)){
      if(volRatio>=1 && Number.isFinite(row.change)) supportScore += row.change>=0?6:-6;
      else if(volRatio>=.5 && Number.isFinite(row.change)) supportScore += row.change>=0?3:-3;
    }
    supportScore=Math.max(0,Math.min(100,Math.round(supportScore)));
    if(supportScore>=68){supportLabel='承接偏強';supportClass='up';}
    else if(supportScore<=37){supportLabel='賣壓偏重';supportClass='down';}
    else {supportLabel='中性震盪';supportClass='flat';}
    score += supportScore>=68?4:supportScore<=37?-4:0;
    score=Math.max(0,Math.min(100,Math.round(score)));
    const stars=score>=92?5:score>=84?4:score>=72?3:score>=58?2:1;
    const distance=Number.isFinite(p)?(p<t.sweet[0]?(p-t.sweet[0])/t.sweet[0]*100:p>t.sweet[1]?(p-t.sweet[1])/t.sweet[1]*100:0):NaN;
    return {...t,...row,code,score,stars,cls,action,distance,supportScore,supportLabel,supportClass,dayPos,volRatio,buyRatio};
  }

  function stars(n){return '★'.repeat(n)+'☆'.repeat(5-n)}
  function card(x,rank){
    const dist=Number.isFinite(x.distance)?`${x.distance>0?'+':''}${x.distance.toFixed(1)}%`:'--';
    const ch=Number.isFinite(x.change)?`${x.change>0?'▲ +':x.change<0?'▼ ':''}${fmt(x.change)}`:'--';
    const pct=Number.isFinite(x.pct)?`${x.pct>0?'+':''}${x.pct.toFixed(2)}%`:'--';
    const chClass=Number.isFinite(x.change)?(x.change>0?'up':x.change<0?'down':'flat'):'flat';
    const vr=Number.isFinite(x.volRatio)?`${(x.volRatio*100).toFixed(0)}%`:'--';
    const br=Number.isFinite(x.buyRatio)?`${(x.buyRatio*100).toFixed(0)}%`:'--';
    const dp=Number.isFinite(x.dayPos)?`${(x.dayPos*100).toFixed(0)}%`:'--';
    return `<article class="v30-card ${x.cls}"><div class="v30-row"><b>${rank?rank+' ':''}${esc(x.name)}</b><strong><small>現價</small>${fmt(x.current)}</strong></div><div class="v30-change ${chClass}">漲跌 ${ch}（${pct}）</div><div class="v30-stars">${stars(x.stars)} <span>${x.score}分</span></div><div class="v31-support ${x.supportClass}"><b>DDE承接力 ${x.supportScore}｜${x.supportLabel}</b><small> 買盤比 ${br}・日內位置 ${dp}・量達昨量 ${vr}</small></div><div class="v30-action">${esc(x.action)}</div><div class="v30-grid"><span>甜甜價 <b>${x.sweet[0]}～${x.sweet[1]}</b></span><span>距甜區 <b>${dist}</b></span><span>第一賣 <b>${x.sell1[0]}～${x.sell1[1]}</b></span><span>第二賣 <b>${x.sell2[0]}～${x.sell2[1]}</b></span><span>防守 <b>${x.stop}</b></span><span>${x.zero?'適合零股':'整張優先'}</span></div></article>`;
  }

  function updatePageHeading(){
    const pageTitle = "Mom AI Report｜07/16 盤中版";
    document.title = pageTitle;
    const h1 = document.querySelector("body > header h1, header h1");
    if(h1) h1.textContent = pageTitle;
    const sub = document.querySelector("body > header .sub, header .sub");
    if(sub){
      sub.innerHTML = '版本：<b>V31.0</b>｜盤中資料：<b>DDE 每分鐘更新</b>｜首頁雷達：<b>每15秒重新排序</b><br>公開版不顯示任何分析師姓名、個人持股、成本或股數。';
    }
  }

  function render(){
    updatePageHeading();
    scanAt=new Date(); const rows={...readFromGlobals(),...readFromTables()};
    const sig=JSON.stringify(Object.keys(rows).sort().map(k=>[k,rows[k].current,rows[k].volume]));
    if(sig&&sig!=='[]'&&sig!==lastSignature){lastSignature=sig;changedAt=new Date();}
    const list=Object.keys(TARGETS).map(k=>evaluate(k,rows[k])).sort((a,b)=>b.score-a.score);
    const top=list.filter(x=>['buy','deep','watch'].includes(x.cls)).slice(0,3);
    const abf=['4958','3037','3189','8046'].map(k=>list.find(x=>x.code===k));
    const holdings=['6239','2308','2327','2454','52'].map(k=>list.find(x=>x.code===k));
    let root=$('#mom-v30-root'); if(!root){root=document.createElement('section');root.id='mom-v30-root';document.body.prepend(root);}
    root.innerHTML=`<style>
#mom-v30-root{font-family:system-ui,-apple-system,"Segoe UI","Noto Sans TC",sans-serif;background:#07111f;color:#eef6ff;padding:14px;border-bottom:4px solid #19d3c5;position:relative;z-index:99999}#mom-v30-root *{box-sizing:border-box}.v30-head{display:flex;justify-content:space-between;gap:10px;align-items:center;flex-wrap:wrap}.v30-head h2{margin:0;font-size:24px}.v30-badge{padding:5px 10px;border:1px solid #27b8ae;border-radius:999px;background:#0d3437;font-size:12px}.v30-time{display:flex;gap:8px 16px;flex-wrap:wrap;margin:9px 0;padding:8px 10px;background:#0d1a2b;border:1px solid #29425f;border-radius:9px;font-size:12px}.v30-live{color:#50e3a4;font-weight:800}.v30-title{margin:13px 0 7px;font-size:16px;font-weight:900}.v30-wrap{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:9px}.v30-card{padding:11px;border-radius:12px;border:1px solid #31445e;background:#101d30}.v30-card.buy{background:#0b382b;border-color:#39c28a}.v30-card.deep{background:#123f31;border-color:#59d69e}.v30-card.watch{background:#24351e;border-color:#90be5e}.v30-card.sell{background:#3c3217;border-color:#d6ac35}.v30-card.hot{background:#412719;border-color:#e07a42}.v30-card.risk{background:#431b26;border-color:#e05b76}.v30-row{display:flex;justify-content:space-between;gap:10px;font-size:17px}.v30-row strong{font-size:20px;display:flex;gap:6px;align-items:baseline}.v30-row strong small{font-size:11px;color:#9fb1c7;font-weight:700}.v30-change{font-size:12px;font-weight:800;margin:3px 0}.v30-change.up{color:#ff6b7a}.v30-change.down{color:#55d9a2}.v30-change.flat{color:#b9c7d8}.v30-stars{color:#ffd84d;font-weight:900;margin:4px 0}.v30-stars span{color:#fff;font-size:12px}.v31-support{font-size:12px;margin:5px 0;padding:6px 7px;border-radius:7px;background:#091522;border:1px solid #31445e}.v31-support b{display:block}.v31-support small{color:#aebed2}.v31-support.up b{color:#ff7584}.v31-support.down b{color:#58dda7}.v31-support.flat b{color:#d7e2ef}.v30-action{font-weight:900;margin:5px 0}.v30-grid{display:grid;grid-template-columns:1fr 1fr;gap:4px 8px;font-size:12px;color:#d7e2ef}.v30-note{font-size:12px;color:#aebed2;margin-top:10px}.v30-collapse{cursor:pointer;border:1px solid #47617e;background:#10243d;color:#fff;border-radius:8px;padding:6px 10px}#mom-v30-root.collapsed .v30-body{display:none}@media(max-width:600px){#mom-v30-root{padding:10px}.v30-head h2{font-size:20px}.v30-grid{grid-template-columns:1fr}}
</style><div class="v30-head"><h2>★★★★★ 即時低接雷達</h2><div><span class="v30-badge">${VERSION}</span> <button class="v30-collapse">收合</button></div></div><div class="v30-time"><span>覆蓋載入：<b>${time(loadedAt)}</b></span><span>最後掃描：<b>${time(scanAt)}</b></span><span>最後更新：<b>${time(changedAt)}</b></span><span class="v30-live">${changedAt?'● 已讀到盤面':'○ 等待盤面資料'}</span></div><div class="v30-body"><div class="v30-title">今天最值得低接 TOP 3</div><div class="v30-wrap">${top.length?top.map((x,i)=>card(x,['①','②','③'][i])).join(''):'<article class="v30-card">啟動每分鐘更新後，這裡會自動排序。</article>'}</div><div class="v30-title">ABF 第一主線</div><div class="v30-wrap">${abf.map(x=>card(x,'')).join('')}</div><div class="v30-title">第一波掛賣雷達（公開策略，不顯示持股）</div><div class="v30-wrap">${holdings.map(x=>card(x,'')).join('')}</div><div class="v30-note">AI整理：DDE承接力以買量／賣量、成交價相對買賣價、日內高低位置、成交量速度計算；不等同真正內外盤或五檔總量。到甜甜價仍須等止跌、不破低或站回開盤；跌破防守先停手。</div></div>`;
    $('.v30-collapse',root)?.addEventListener('click',e=>{root.classList.toggle('collapsed');e.currentTarget.textContent=root.classList.contains('collapsed')?'展開':'收合';});
  }
  render(); setInterval(render,15000);
})();
