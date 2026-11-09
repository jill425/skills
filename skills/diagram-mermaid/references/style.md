# 視覺樣式（唯一色彩 / 主題事實來源）

風格目標:**乾淨、現代的深色技術圖**（實色框、清楚分層）。要改品牌風格,只改這裡。

---

## config frontmatter（每個 mermaid block 開頭都貼這段）

```
---
config:
  theme: base
  themeVariables:
    darkMode: true
    fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace'
    background: '#111827'
    primaryColor: '#1f2933'
    primaryTextColor: '#f9fafb'
    primaryBorderColor: '#3b82f6'
    lineColor: '#d1d5db'
    tertiaryColor: '#19212d'
    clusterBkg: '#19212d'
    clusterBorder: '#a855f7'
    titleColor: '#38bdf8'
    edgeLabelBackground: '#111827'
---
```

- 不用 `look: handDrawn`：深色技術風以實色分層框呈現,乾淨、可讀性高。
- 內部小圖(如單一模組)可只保留 `theme` + 前幾個 themeVariables,精簡即可。

---

## 色票

| Token | 用途 | 色值 |
|-------|------|------|
| 畫布底 | 深藍灰、近黑有層次 | `#111827` |
| 節點填色 | 比底亮一階 | `#1f2933` |
| subgraph 底 | 群組區塊底 | `#19212d` |
| 主要文字 | 近白 | `#f9fafb` |
| 次要文字 / 線 | 說明、連線 | `#d1d5db` |
| 標題藍 | subgraph 標題、關鍵標頭 | `#38bdf8` |
| 處理藍 | api / 一般處理節點框 | `#3b82f6` |
| 容器紫 | 業務核心 subgraph 外框 | `#a855f7` |
| 觸發橘 | trigger / dev 旁支 | `#fb923c` |
| 輸出綠 | 上游 / 成功 / 資料流標籤 | `#4ade80` |
| 防腐粉 | 轉換層 / meta / 註解 | `#f472b6` |
| 規劃琥珀 | 尚未建立的節點 | `#c1820a` |
| 停用灰 | 未建 / 停用 | `#6b7280` |

> 顏色編碼意義,不是裝飾。同一分層固定同一色。

---

## 狀態 classDef（貼在 flowchart 末尾）

```
classDef planned stroke:#c1820a,stroke-dasharray:5 4,color:#c1820a;
classDef dev stroke:#fb923c,stroke-dasharray:5 4,color:#fb923c;
```

| 狀態 | 用法 | 表現 |
|------|------|------|
| 已建（built） | 不標 class | 實線 + 主題色 |
| 規劃中（planned） | `節點:::planned` | 琥珀虛線框 |
| dev / test-only | `節點:::dev` | 橘虛線框(邊也用 `-.->`) |

---

## 邊（連線）語意

| 關係 | 語法 | 用途 |
|------|------|------|
| 主資料流 | `A --> B` | 由上往下的正式路徑 |
| 帶說明 | `A -->|"fan-out"| B` | 標關鍵語意(fan-out、單向依賴) |
| 旁支 / 弱關聯 | `A -.-> B` | dev-only、單向重用 service |

節點文字含中文 / 括號 / 斜線一律用 `["..."]` 包住;換行用 `<br/>`。
