(function () {
  if (typeof window === "undefined" || typeof document === "undefined") {
    return;
  }

  function onReady(fn) {
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", fn);
    } else {
      fn();
    }
  }

  function injectStyle() {
    if (document.getElementById("mom-ai-hotfix-20260623-v4-style")) {
      return;
    }
    var style = document.createElement("style");
    style.id = "mom-ai-hotfix-20260623-v4-style";
    style.type = "text/css";
    style.appendChild(document.createTextNode(
      ".mom-ai-hotfix-20260623-v4{margin:14px auto 18px auto;padding:14px 16px;border:1px solid #94a3b8;border-radius:14px;background:#f8fafc;color:#0f172a;box-shadow:0 6px 18px rgba(0,0,0,.08);max-width:1180px;font-family:system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI','Microsoft JhengHei',Arial,sans-serif;line-height:1.65}" +
      ".mom-ai-hotfix-20260623-v4 h2{margin:0 0 8px 0;font-size:20px;color:#1e293b}" +
      ".mom-ai-hotfix-20260623-v4 .pill{display:inline-block;margin:2px 6px 2px 0;padding:3px 9px;border-radius:999px;background:#2563eb;color:#ffffff;font-weight:800;font-size:13px}" +
      ".mom-ai-hotfix-20260623-v4 .warn{background:#b91c1c}" +
      ".mom-ai-hotfix-20260623-v4 .ok{background:#15803d}" +
      ".mom-ai-hotfix-20260623-v4 table{width:100%;border-collapse:collapse;margin-top:8px;font-size:14px;background:#ffffff}" +
      ".mom-ai-hotfix-20260623-v4 th,.mom-ai-hotfix-20260623-v4 td{border:1px solid #cbd5e1;padding:7px 8px;text-align:left;vertical-align:top}" +
      ".mom-ai-hotfix-20260623-v4 th{background:#e2e8f0;color:#0f172a}" +
      ".mom-ai-hotfix-20260623-v4 td{background:#ffffff;color:#111827}" +
      ".mom-ai-hotfix-20260623-v4 b{color:#0f172a}" +
      ".mom-ai-hotfix-20260623-v4 .note{color:#334155;font-size:13px;margin-top:8px}"
    ));
    document.head.appendChild(style);
  }

  function replaceTextNodes(root) {
    var pairs = [
      ["偏弱觀察｜縮小部位", "中性偏多｜開高不追"],
      ["偏弱觀察 | 縮小部位", "中性偏多 | 開高不追"],
      ["國際中性偏弱", "國際中性偏多"],
      ["分數：43 / 100", "分數：約 65～72 / 100"],
      ["分數:43 / 100", "分數：約 65～72 / 100"],
      ["風險分數：56 / 100", "風險分數：45～50 / 100"],
      ["風險分數:56 / 100", "風險分數：45～50 / 100"],
      ["站穩 200 才轉強", "550～560 有守觀察；站回 570～575 轉強；590～598 短壓"],
      ["站穩200才轉強", "550～560 有守觀察；站回 570～575 轉強；590～598 短壓"],
      ["站穩 224 才轉強", "570～575 有守觀察；站穩 581～585 續強；接近 597 不追"],
      ["站穩224才轉強", "570～575 有守觀察；站穩 581～585 續強；接近 597 不追"],
      ["2026/06/23 盤前熱修補", "2026/06/23 盤前熱修補 v4"]
    ];

    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
    var nodes = [];
    var node;
    while ((node = walker.nextNode())) {
      nodes.push(node);
    }

    for (var i = 0; i < nodes.length; i++) {
      var text = nodes[i].nodeValue;
      var changed = false;
      for (var j = 0; j < pairs.length; j++) {
        if (text.indexOf(pairs[j][0]) !== -1) {
          text = text.split(pairs[j][0]).join(pairs[j][1]);
          changed = true;
        }
      }
      if (changed) {
        nodes[i].nodeValue = text;
      }
    }
  }

  function removeOldHotfixPanels() {
    var ids = [
      "mom-ai-hotfix-20260623-v3",
      "mom-ai-hotfix-20260623-v4"
    ];
    for (var i = 0; i < ids.length; i++) {
      var old = document.getElementById(ids[i]);
      if (old && ids[i] !== "mom-ai-hotfix-20260623-v4") {
        old.parentNode.removeChild(old);
      }
    }
    var oldStyles = [
      "mom-ai-hotfix-20260623-v3-style"
    ];
    for (var s = 0; s < oldStyles.length; s++) {
      var st = document.getElementById(oldStyles[s]);
      if (st) st.parentNode.removeChild(st);
    }
  }

  function addHotfixPanel() {
    if (document.getElementById("mom-ai-hotfix-20260623-v4")) {
      return;
    }

    var panel = document.createElement("section");
    panel.id = "mom-ai-hotfix-20260623-v4";
    panel.className = "mom-ai-hotfix-20260623-v4";
    panel.innerHTML =
      '<h2>2026/06/23 盤前熱修補 v4</h2>' +
      '<div><span class="pill ok">中性偏多</span><span class="pill warn">開高不追</span><span class="pill">沿用上一筆不列入分數</span></div>' +
      '<p><b>國際盤前雷達：</b>若資料列顯示「沿用上一筆」，代表該筆即時抓取失敗，只作參考，不納入今日分數。以手動盤前資料校正後，今日判讀改為「中性偏多｜開高不追」。</p>' +
      '<table>' +
      '<tr><th>項目</th><th>修正內容</th><th>盤中用法</th></tr>' +
      '<tr><td>手動盤前參考</td><td>NVDA +0.97%、TSM ADR +1.20%、台指期盤後 +0.94%、美元/台幣 +0.14%</td><td>有利早盤開高，但 06/22 已大漲，等 09:08 / 09:30 確認。</td></tr>' +
      '<tr><td>3044 健鼎</td><td>550～560 有守觀察；570～575 站回轉強；590～598 短壓。</td><td>昨天開高走低，今天要看修復，不追高。</td></tr>' +
      '<tr><td>8021 尖點</td><td>570～575 有守觀察；581～585 續強；接近 597 不追。</td><td>處置 / 高波動股，先觀察，不做追價。</td></tr>' +
      '<tr><td>零股隔日短打</td><td>富喬、亞力、欣銓、京元電子、健鼎優先觀察。</td><td>只做健康回測：守開盤價、有量、不是第一根急拉。</td></tr>' +
      '</table>' +
      '<p class="note">v4 調整：熱修補區改成灰白底、深色字，避免黃底太亮看不到字。</p>';

    var target = document.querySelector("main") || document.body;
    target.insertBefore(panel, target.firstChild);
  }

  onReady(function () {
    removeOldHotfixPanels();
    injectStyle();
    replaceTextNodes(document.body);
    addHotfixPanel();
  });
})();
