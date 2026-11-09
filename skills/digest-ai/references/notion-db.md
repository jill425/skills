# Notion 資料庫規格：AI 技術日報彙整

- 資料庫名稱：**AI 技術日報彙整**。每次先用 `notion-search` 找這個名稱，取得它的 data source（`collection://...`），建頁時 parent 用 `{"type": "data_source_id", "data_source_id": "<查到的 id>"}`。
- 找不到就問使用者：要指定既有資料庫，或照下方〈欄位對應〉建一個新的。

查詢一律用 `notion-search` 限定在該 data source；`notion-query-data-sources`（SQL）在部分 Notion 方案會回 400。

## 寫入流程

1. **查今天的頁面**：搜尋 `AI 技術日報 · YYYY-MM-DD`，比對日期（舊頁面標題可能帶 📰 前綴）。
2. **已存在** → 用 `notion-update-page` 更新該頁內容與欄位（重跑當天排程不產生重複列），`已讀` 保持原值。
3. **不存在** → `notion-create-pages`，parent 用 `data_source_id`；properties 依下方對應表；content 為日報內文。
4. 長日報單次寫入被拒（太大）時，先建頁寫前半，再用 update-page 追加後半。

若建頁回報欄位不存在或型別錯誤，先 fetch 查到的 collection:// 重新讀 schema（使用者可能改過欄位），依最新 schema 調整後再寫。

## 欄位對應

| 欄位 | 型別 | 填法 |
|---|---|---|
| 日報標題 | title | `AI 技術日報 · YYYY-MM-DD`（今天日期；emoji 放 icon 不放標題） |
| 日期 | date | `"date:日期:start": "YYYY-MM-DD"`（今天）、`"date:日期:is_datetime": 0`；不填 end |
| 則數 | number | 收錄條目總數（數字，不是字串）。不含「今日三大重點」與「本期覆蓋說明」，同一事件合併的算 1 則 |
| 來源 | text | 實際有收錄內容的來源名稱，以英文逗號分隔，例如 `Simon Willison's Weblog, Anthropic, Anthropic Research, Hugging Face Papers, Mistral AI, GitHub, Reuters, CISA, BleepingComputer` |
| 涵蓋類型 | multi_select | 只放「本期有至少 1 則」的類型，值必須完全符合下表選項（JSON 陣列字串） |
| 當天主線 | text | 1–3 句話說明今天的主線趨勢（一段話），點出最重要的 1–2 個事件與它們的共同脈絡 |
| 已讀 | checkbox | 新建時一律 `"__NO__"`；更新既有頁面時不要動這個欄位（保留使用者的標記） |

## 日報區塊 → 涵蓋類型 選項

| 日報區塊 | 涵蓋類型選項（完全一致） |
|---|---|
| 🧠 大神觀點（X / 部落格） | `技術大神文章` |
| 🚀 新功能 / 模型發布 | `AI新功能/模型發布` |
| 🔬 研究 / 技術文章 | `研究/技術文章` |
| 🏗️ 架構與系統設計 | `架構設計/系統設計` |
| ⭐ GitHub 熱門 | `GitHub熱門repo` |
| 🎬 YouTube 影片大綱 | `技術大神影片` |
| 🛡️ 資安動態 | `資安動態` |
| 📈 產業動態 | `產業動態` |

寫「本期無」的區塊不要放進涵蓋類型。

**建頁前先確認 `涵蓋類型` 有需要的選項**：fetch data source 看 `涵蓋類型` 的 options：
- 已有 → 直接用。
- 缺少 → 用 `notion-update-data-source` 在 `涵蓋類型` 新增缺少的選項（例如 `資安動態` 用 `yellow`、`研究/技術文章` 用 `purple`），保留其他既有選項不變；一次補齊後再建頁。
- 新增失敗（權限不足等）→ 涵蓋類型先不放缺少的選項，頁面照常寫入，並在對話回覆中提醒使用者手動新增。

## 範例 properties

```json
{
  "日報標題": "AI 技術日報 · 2026-10-07",
  "date:日期:start": "2026-10-07",
  "date:日期:is_datetime": 0,
  "則數": 14,
  "來源": "Simon Willison's Weblog, Anthropic, Mistral AI, GitHub, Reuters",
  "涵蓋類型": "[\"技術大神文章\", \"AI新功能/模型發布\", \"研究/技術文章\", \"GitHub熱門repo\", \"技術大神影片\", \"資安動態\"]",
  "當天主線": "新模型密集發布，社群焦點轉向 agent 評測方法",
  "已讀": "__NO__"
}
```

## 頁面內文

- icon 用 📰。內文不要重複 H1 標題。
- 開頭一行 blockquote 摘要：`> 📊 收錄範圍：…｜共 N 則｜今日主線：…`
- 接著「⚡ 今日三大重點」，再依 SKILL.md 步驟 3 的區塊順序，用 `---` 分隔各區塊。
- 每則條目用 `### N. 標題` 連續編號（跨區塊不重新編號，最後的號碼就是「則數」），條目最後一行 `→ 來源: [名稱](URL)`，多個來源用「｜」分隔。
- 最後放「📝 本期覆蓋說明」與頁尾 `*自動生成於 YYYY-MM-DD｜涵蓋時間窗：…*`。
- 金額不要用「$」符號（Notion 可能當成數學式），改寫成「美元」。
- 來源連結用 Markdown 外部連結 `[標題](https://...)`。
- 長日報若單次寫入被拒（太大），先建頁寫前半，再用 update-page 追加後半。
