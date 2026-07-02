async function loadData(){
  const res = await fetch('./data/market_snapshot.json?ts=' + Date.now());
  if(!res.ok) throw new Error('資料載入失敗');
  return await res.json();
}
function fmt(v){return (v===0||v)?String(v):''}
function cls(v){return v>0?'pos':v<0?'neg':'flat'}
function renderAlerts(alerts){
  const root=document.querySelector('#alerts');
  root.innerHTML=alerts.map(a=>`<article class="alert ${a.level}"><h3>${a.title}</h3><p>${a.text}</p></article>`).join('');
}
function renderGroups(groups){
  const root=document.querySelector('#groups');
  root.innerHTML=groups.map(g=>`
    <section class="section">
      <h2>${g.name}</h2>
      <div class="tableWrap"><table>
        <thead><tr><th>代號</th><th>名稱</th><th>現價</th><th>漲跌</th><th>幅度</th><th>高 / 低</th><th>狀態</th><th>操作策略</th></tr></thead>
        <tbody>${g.items.map(x=>`
          <tr>
            <td class="code">${x.code}</td><td class="name">${x.name}</td>
            <td class="num">${fmt(x.price)}</td><td class="num ${cls(x.change)}">${fmt(x.change)}</td><td class="num ${cls(x.pct)}">${fmt(x.pct)}%</td>
            <td class="num">${fmt(x.high)} / ${fmt(x.low)}</td><td><span class="tag">${x.tag}</span></td><td class="action">${x.action}</td>
          </tr>`).join('')}</tbody>
      </table></div>
    </section>`).join('');
}
function renderRules(rules){document.querySelector('#rules').innerHTML=rules.map(r=>`<div class="rule">${r}</div>`).join('')}
loadData().then(data=>{
  document.querySelector('#asof').textContent=data.meta.as_of;
  document.querySelector('#view').textContent=data.meta.market_view;
  document.querySelector('#sourceNote').textContent=data.meta.source_note;
  renderAlerts(data.alerts);renderGroups(data.groups);renderRules(data.rules);
}).catch(err=>{document.body.innerHTML='<main class="layout"><h1>資料載入失敗</h1><p>'+err.message+'</p></main>'});
