(function(){
"use strict";
const id="mom-ai-close-20260721-corrected";
document.getElementById("mom-ai-close-20260721")?.remove();
document.getElementById(id)?.remove();
const s=document.createElement("style");
s.textContent=`#${id}{max-width:1480px;margin:14px auto 18px;padding:16px;border:1px solid #315574;border-radius:18px;background:#0b1c2e;color:#edf6ff;font-family:"Microsoft JhengHei",sans-serif}#${id} h2{margin:0 0 8px}#${id} .grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}#${id} .card{background:#10243a;border:1px solid #29465f;border-radius:14px;padding:13px}#${id} table{width:100%;border-collapse:collapse;font-size:13px}#${id} th,#${id} td{padding:8px;border-bottom:1px solid #20364d;text-align:left}#${id} .up{color:#ff8792;font-weight:900}#${id} .note{margin-top:12px;padding:12px;border-left:5px solid #ffd166;background:#28220f;border-radius:10px}@media(max-width:780px){#${id} .grid{grid-template-columns:1fr}}`;
document.head.appendChild(s);
const p=document.createElement("section");
p.id=id;
p.innerHTML=`
<h2>07/21 收盤修正版｜AI權值與PCB／ABF全面反攻</h2>
<p>正確收盤：台積電2410、臻鼎509、日月光633、南電1190、欣興825漲停、景碩746、台達電1835、聯發科3670漲停。</p>
<div class="grid">
<div class="card"><h3>主要收盤價</h3><table>
<tr><th>股票</th><th>收盤</th><th>漲跌</th></tr>
<tr><td>台積電</td><td>2410</td><td class="up">+90（+3.88%）</td></tr>
<tr><td>臻鼎-KY</td><td>509</td><td class="up">+30.5（+6.37%）</td></tr>
<tr><td>日月光投控</td><td>633</td><td class="up">+36（+6.03%）</td></tr>
<tr><td>南電</td><td>1190</td><td class="up">+85（+7.69%）</td></tr>
<tr><td>欣興</td><td>825</td><td class="up">漲停</td></tr>
<tr><td>景碩</td><td>746</td><td class="up">近漲停</td></tr>
<tr><td>台達電</td><td>1835</td><td class="up">+130（+7.62%）</td></tr>
<tr><td>聯發科</td><td>3670</td><td class="up">漲停</td></tr>
</table></div>
<div class="card"><h3>明日低接計畫</h3><table>
<tr><th>股票</th><th>第一區</th><th>第二區</th></tr>
<tr><td>台積電</td><td>2370～2380</td><td>2355～2360</td></tr>
<tr><td>南電</td><td>1165～1175</td><td>1145～1155</td></tr>
<tr><td>臻鼎-KY</td><td>495～500</td><td>487～490</td></tr>
<tr><td>日月光</td><td>620～625</td><td>609～615</td></tr>
<tr><td>力成</td><td>268～270</td><td>264～266</td></tr>
</table></div>
</div>
<div class="note"><b>一句話：</b>台積電2360仍可掛，屬偏保守深回測價；沒成交就算了，不追2410以上。</div>
`;
(document.querySelector("main")||document.body).prepend(p);
})();