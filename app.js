
const data = window.MOM_AI_REPORT_DATA;
const fmt = (n)=> (n===null || n===undefined || n==='') ? '-' : Number(n).toLocaleString('zh-TW');
const cls = (n)=> Number(n)>0 ? 'up' : Number(n)<0 ? 'down' : 'flat';
document.getElementById('versionStamp').innerHTML = `<b>${data.version}</b><br>${data.updateLabel}<br>${data.source}`;

document.getElementById('summaryCards').innerHTML = data.summaryCards.map(c=>`
  <article class="card"><h3>${c.title}</h3><p>${c.text}</p></article>`).join('');

document.getElementById('levelsTable').innerHTML = `
<thead><tr><th>順位</th><th>代號</th><th>名稱</th><th>收盤</th><th>明日定位</th><th>低接區</th><th>反彈賣區</th><th>風險線</th></tr></thead>
<tbody>${data.levels.map(r=>`<tr><td class="rank">${r.rank}</td><td>${r.code}</td><td>${r.name}</td><td>${fmt(r.close)}</td><td>${r.stance}</td><td><span class="tag">${r.buy}</span></td><td>${r.sell}</td><td>${r.risk}</td></tr>`).join('')}</tbody>`;

document.getElementById('warningGrid').innerHTML = data.warnings.map(w=>`
  <article class="warning"><h3>${w.name}<span class="code">${w.code}</span></h3><p>收盤 ${fmt(w.close)}｜${w.note}</p></article>`).join('');

document.getElementById('sectorGrid').innerHTML = data.sectors.map(s=>`
  <article class="sector"><h3>${s.name} <span class="tag">${s.signal}</span></h3><p>${s.summary}</p><p class="code">${s.codes}</p></article>`).join('');

document.getElementById('focusTable').innerHTML = `
<thead><tr><th>代號</th><th>名稱</th><th>收盤</th><th>漲跌</th><th>幅度%</th><th>最高</th><th>最低</th><th>量</th><th>買進</th><th>賣出</th></tr></thead>
<tbody>${data.focusRows.map(r=>`<tr><td>${r.code}</td><td>${r.name}</td><td>${fmt(r.close)}</td><td class="${cls(r.change)}">${fmt(r.change)}</td><td class="${cls(r.change)}">${fmt(r.pct)}%</td><td>${fmt(r.high)}</td><td>${fmt(r.low)}</td><td>${fmt(r.volume)}</td><td>${fmt(r.bid)}</td><td>${fmt(r.ask)}</td></tr>`).join('')}</tbody>`;
