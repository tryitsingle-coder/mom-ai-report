window.REPORT_DATA = {
  "version": "V27.0 0707 盤前夜盤偏多公開版",
  "updated": "2026-07-07 06:20",
  "title": "0707 盤前夜盤偏多版",
  "subtitle": "美股半導體偏多，台積電/聯發科有開高機會；PCB/ABF 仍以反彈減壓為主。",
  "summaryCards": [
    {
      "title": "盤前總結",
      "value": "夜盤偏多，台股有開盤假漲機率",
      "tone": "good",
      "desc": "美股科技、半導體 ETF、TSM ADR 偏多；台幣偏弱略扣分。"
    },
    {
      "title": "核心主軸",
      "value": "台積電、聯發科優先看開高處理",
      "tone": "good",
      "desc": "半導體外盤強，明早先看 09:00～09:15 是否站穩。"
    },
    {
      "title": "PCB/ABF",
      "value": "只當反彈減壓，不列積極低接",
      "tone": "bad",
      "desc": "臻鼎、南電、欣興、景碩、台光電仍是弱勢修復。"
    },
    {
      "title": "操作紀律",
      "value": "開高不追，弱股不攤",
      "tone": "warn",
      "desc": "反彈先降風險；低接只做相對強股回測。"
    }
  ],
  "nightMarkets": [
    {
      "symbol": "NVDA",
      "name": "NVIDIA",
      "value": "195.55",
      "change": "+0.72",
      "signal": "AI 偏多"
    },
    {
      "symbol": "TSM",
      "name": "台積電 ADR",
      "value": "451.79",
      "change": "+17.63",
      "signal": "台積電偏多"
    },
    {
      "symbol": "NASDAQ",
      "name": "Nasdaq Composite",
      "value": "26,121.16",
      "change": "+288.49",
      "signal": "科技股偏多"
    },
    {
      "symbol": "S&P 500",
      "name": "S&P 500",
      "value": "7,537.43",
      "change": "+54.19",
      "signal": "大盤偏多"
    },
    {
      "symbol": "SOXX",
      "name": "半導體 ETF",
      "value": "581.51",
      "change": "+15.19",
      "signal": "半導體偏多"
    },
    {
      "symbol": "SMH",
      "name": "半導體 ETF",
      "value": "604.30",
      "change": "+12.01",
      "signal": "半導體偏多"
    },
    {
      "symbol": "VIX",
      "name": "恐慌指數",
      "value": "15.57",
      "change": "-0.24",
      "signal": "風險下降"
    },
    {
      "symbol": "USD/TWD",
      "name": "美元/台幣",
      "value": "32.06",
      "change": "+0.13",
      "signal": "台幣偏弱，外資面小扣分"
    }
  ],
  "levels": [
    {
      "rank": 1,
      "name": "台積電",
      "code": "2330",
      "buy": "2455 / 2445",
      "sell": "2485 / 2495 / 2500",
      "note": "夜盤偏多支撐，開高不追，站穩再看。"
    },
    {
      "rank": 2,
      "name": "聯發科",
      "code": "2454",
      "buy": "4110 / 4100",
      "sell": "4175 / 4200 / 4250",
      "note": "隔日反彈優先處理，跌破 4100 降風險。"
    },
    {
      "rank": 3,
      "name": "京元電子",
      "code": "2449",
      "buy": "348 / 345",
      "sell": "353 / 356 / 360",
      "note": "相對強股，回測才接。"
    },
    {
      "rank": 4,
      "name": "力成",
      "code": "6239",
      "buy": "342 / 340",
      "sell": "348 / 350",
      "note": "封測相對穩，小量觀察。"
    },
    {
      "rank": 5,
      "name": "亞力",
      "code": "1514",
      "buy": "125 / 124.5",
      "sell": "128 / 130",
      "note": "電力股相對抗跌，勿追開高。"
    }
  ],
  "warnings": [
    {
      "name": "臻鼎-KY",
      "code": "4958",
      "reason": "收 579，跌破 600；只看 590 / 600 / 612~620 反彈減壓。"
    },
    {
      "name": "南電",
      "code": "8046",
      "reason": "收 1075，跌停附近修復；站回 1100 前不追。"
    },
    {
      "name": "欣興",
      "code": "3037",
      "reason": "收 917，族群仍弱；925 / 935 只當反彈壓力。"
    },
    {
      "name": "景碩",
      "code": "3189",
      "reason": "收 763，弱勢明顯；800 / 825 以上再看減壓。"
    },
    {
      "name": "中探針",
      "code": "6217",
      "reason": "進處置，收 256；不加碼，等 268 / 273 / 277 反彈。"
    },
    {
      "name": "台光電",
      "code": "2383",
      "reason": "跌停附近且買盤弱；站回 5600 / 5800 前不碰。"
    },
    {
      "name": "台燿",
      "code": "6274",
      "reason": "PCB 材料破線，反彈不追。"
    },
    {
      "name": "金像電",
      "code": "2368",
      "reason": "弱勢修復，不列低接。"
    }
  ],
  "sectors": [
    {
      "name": "AI 半導體權值",
      "signal": "偏多",
      "stars": "⭐⭐⭐⭐",
      "desc": "TSM ADR、SOXX、SMH 偏多，台積電與聯發科有開高機會。"
    },
    {
      "name": "PCB / ABF",
      "signal": "偏弱",
      "stars": "⭐⭐",
      "desc": "臻鼎、南電、欣興、景碩、台光電仍是反彈減壓，不是追買。"
    },
    {
      "name": "AI 測試鏈",
      "signal": "分化",
      "stars": "⭐⭐⭐",
      "desc": "京元、力成相對強；中探針進處置，不加碼。"
    },
    {
      "name": "電力主線",
      "signal": "相對強",
      "stars": "⭐⭐⭐⭐",
      "desc": "亞力、東元、中興電較抗跌，回測才可小量觀察。"
    },
    {
      "name": "記憶體/半導體材料",
      "signal": "觀察",
      "stars": "⭐⭐⭐",
      "desc": "南亞科、環球晶強，但高檔不追，等回測。"
    }
  ],
  "focus": [
    {
      "code": "2330",
      "name": "台積電",
      "close": 2460.0,
      "change": 15.0,
      "pct": 0.61,
      "high": 2500.0,
      "low": 2455.0,
      "volume": 19209,
      "category": "核心權值",
      "bias": "偏多",
      "support": "2455 / 2445",
      "pressure": "2485 / 2495 / 2500",
      "action": "夜盤 TSM ADR 偏多，開高先看能否站穩，不追高。",
      "tag": "AI 半導體主軸"
    },
    {
      "code": "2454",
      "name": "聯發科",
      "close": 4125.0,
      "change": -70.0,
      "pct": 1.67,
      "high": 4325.0,
      "low": 4110.0,
      "volume": 6288,
      "category": "IC 設計",
      "bias": "中性偏多",
      "support": "4110 / 4100",
      "pressure": "4175 / 4200 / 4250",
      "action": "適合開盤假漲先減碼；跌破 4100 不加碼。",
      "tag": "隔日短打焦點"
    },
    {
      "code": "2308",
      "name": "台達電",
      "close": 1995.0,
      "change": -80.0,
      "pct": 3.86,
      "high": 2135.0,
      "low": 1995.0,
      "volume": 8113,
      "category": "電源/AI 伺服器",
      "bias": "觀察反彈",
      "support": "1995 / 1980",
      "pressure": "2015 / 2030 / 2050",
      "action": "有反彈先處理，不追高；站回 2030 才轉穩。",
      "tag": "反彈減壓"
    },
    {
      "code": "4958",
      "name": "臻鼎-KY",
      "close": 579.0,
      "change": -34.0,
      "pct": 5.55,
      "high": 621.0,
      "low": 567.0,
      "volume": 32178,
      "category": "PCB/載板",
      "bias": "偏弱",
      "support": "579 / 570",
      "pressure": "590 / 600 / 612~620",
      "action": "PCB/ABF 仍弱，只看反彈減壓，不做積極低接。",
      "tag": "共同觀察"
    },
    {
      "code": "8046",
      "name": "南電",
      "close": 1075.0,
      "change": -110.0,
      "pct": 9.28,
      "high": 1170.0,
      "low": 1070.0,
      "volume": 13347,
      "category": "ABF",
      "bias": "偏弱",
      "support": "1070 / 1050",
      "pressure": "1100 / 1115 / 1125",
      "action": "跌停附近反彈，不追；站回 1100 才較穩。",
      "tag": "弱勢修復"
    },
    {
      "code": "3037",
      "name": "欣興",
      "close": 917.0,
      "change": -50.0,
      "pct": 5.17,
      "high": 972.0,
      "low": 897.0,
      "volume": 21783,
      "category": "ABF",
      "bias": "偏弱",
      "support": "917 / 900",
      "pressure": "925 / 935 / 945",
      "action": "反彈先減壓，不是低接順位。",
      "tag": "弱勢修復"
    },
    {
      "code": "3189",
      "name": "景碩",
      "close": 763.0,
      "change": -70.0,
      "pct": 8.4,
      "high": 807.0,
      "low": 763.0,
      "volume": 3521,
      "category": "ABF",
      "bias": "偏弱",
      "support": "763 / 750",
      "pressure": "800 / 825 / 830",
      "action": "處置與族群轉弱影響，反彈分批減壓。",
      "tag": "弱勢修復"
    },
    {
      "code": "6217",
      "name": "中探針",
      "close": 256.0,
      "change": -13.0,
      "pct": 4.83,
      "high": 269.0,
      "low": 256.0,
      "volume": 1385,
      "category": "測試鏈",
      "bias": "偏弱",
      "support": "256 / 250",
      "pressure": "268 / 273 / 277",
      "action": "進處置後不加碼；反彈才減壓。",
      "tag": "處置警戒"
    },
    {
      "code": "2449",
      "name": "京元電子",
      "close": 351.0,
      "change": 16.0,
      "pct": 4.78,
      "high": 367.5,
      "low": 349.5,
      "volume": 51012,
      "category": "測試鏈",
      "bias": "相對強",
      "support": "349.5 / 345",
      "pressure": "353 / 356 / 360",
      "action": "相對強，但開高不追，回測才看。",
      "tag": "低接備選"
    },
    {
      "code": "6239",
      "name": "力成",
      "close": 344.5,
      "change": 6.5,
      "pct": 1.92,
      "high": 360.0,
      "low": 340.5,
      "volume": 41796,
      "category": "封測",
      "bias": "相對強",
      "support": "342 / 340",
      "pressure": "348 / 350",
      "action": "比 ABF 穩，回測可小量觀察。",
      "tag": "低接備選"
    },
    {
      "code": "1514",
      "name": "亞力",
      "close": 126.5,
      "change": 3.5,
      "pct": 2.85,
      "high": 130.0,
      "low": 124.5,
      "volume": 14875,
      "category": "電力",
      "bias": "相對強",
      "support": "125 / 124.5",
      "pressure": "128 / 130",
      "action": "電力相對抗跌，回測才可看。",
      "tag": "低接備選"
    },
    {
      "code": "2383",
      "name": "台光電",
      "close": 5475.0,
      "change": -605.0,
      "pct": 9.95,
      "high": 6250.0,
      "low": 5475.0,
      "volume": 2973,
      "category": "PCB/材料",
      "bias": "危險",
      "support": "5475 / 5400",
      "pressure": "5600 / 5800 / 6000",
      "action": "接近跌停且買盤弱，不低接。",
      "tag": "禁止追低"
    },
    {
      "code": "6274",
      "name": "台燿",
      "close": 1630.0,
      "change": -160.0,
      "pct": 8.94,
      "high": 1825.0,
      "low": 1615.0,
      "volume": 7729,
      "category": "PCB/材料",
      "bias": "偏弱",
      "support": "1615 / 1600",
      "pressure": "1660 / 1700",
      "action": "破線反彈，不追。",
      "tag": "禁止追低"
    }
  ],
  "rules": [
    "開高先賣風險，不追開盤第一根紅 K。",
    "台積電與聯發科受夜盤支撐，可觀察開高後是否站穩。",
    "PCB/ABF 若只有弱反彈，優先減壓，不做積極低接。",
    "處置股與跌停附近股票不攤平，等反彈壓力區處理。",
    "09:05～09:15 確認真強弱，若開高走低，買單全面降級。"
  ]
};
