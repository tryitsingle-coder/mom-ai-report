const data = window.REPORT_DATA;
const fmt = (v) => {
  if (v === null || v === undefined || Number.isNaN(v)) return "-";
  const n = Number(v);
  return n.toLocaleString("zh-TW", { maximumFractionDigits: 2 });
};
const toneClass = (tone) => tone === "good" ? "good" : tone === "bad" ? "bad" : "warn";

function render() {
  document.getElementById("pageTitle").textContent = data.title;
  document.getElementById("pageSubtitle").textContent = data.subtitle;
  document.getElementById("versionStamp").innerHTML = `<b>${data.version}</b><small>${data.updated}</small>`;

  document.getElementById("summaryCards").innerHTML = data.summaryCards.map(card => `
    <article class="card ${toneClass(card.tone)}">
      <span>${card.title}</span>
      <strong>${card.value}</strong>
      <p>${card.desc}</p>
    </article>
  `).join("");

  document.getElementById("nightGrid").innerHTML = data.nightMarkets.map(m => `
    <div class="market-item">
      <div><b>${m.symbol}</b><small>${m.name}</small></div>
      <div class="market-num"><strong>${m.value}</strong><em class="up">${m.change}</em></div>
      <span>${m.signal}</span>
    </div>
  `).join("");

  document.getElementById("levelsTable").innerHTML = `
    <thead><tr><th>順位</th><th>股票</th><th>低接/支撐</th><th>反彈/壓力</th><th>策略</th></tr></thead>
    <tbody>${data.levels.map(r => `
      <tr><td>${r.rank}</td><td><b>${r.name}</b><small>${r.code}</small></td><td>${r.buy}</td><td>${r.sell}</td><td>${r.note}</td></tr>
    `).join("")}</tbody>`;

  document.getElementById("warningGrid").innerHTML = data.warnings.map(w => `
    <article class="warning"><b>${w.name} <small>${w.code}</small></b><p>${w.reason}</p></article>
  `).join("");

  document.getElementById("sectorGrid").innerHTML = data.sectors.map(s => `
    <article class="sector"><div><b>${s.name}</b><span>${s.signal}</span></div><strong>${s.stars}</strong><p>${s.desc}</p></article>
  `).join("");

  document.getElementById("focusTable").innerHTML = `
    <thead><tr><th>代號</th><th>名稱</th><th>收盤</th><th>漲跌</th><th>高/低</th><th>燈號</th><th>支撐</th><th>壓力</th><th>公開策略</th></tr></thead>
    <tbody>${data.focus.map(r => `
      <tr>
        <td>${r.code}</td><td><b>${r.name}</b><small>${r.category}</small></td><td>${fmt(r.close)}</td><td class="${r.change >= 0 ? 'red' : 'green'}">${fmt(r.change)}</td><td>${fmt(r.high)} / ${fmt(r.low)}</td><td><span class="pill">${r.bias}</span></td><td>${r.support}</td><td>${r.pressure}</td><td>${r.action}</td>
      </tr>
    `).join("")}</tbody>`;

  document.getElementById("ruleList").innerHTML = data.rules.map(r => `<li>${r}</li>`).join("");
}
render();
