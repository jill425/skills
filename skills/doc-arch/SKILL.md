---
name: doc-arch
description: 產出「結構化 Markdown 架構文件」（以標題、表格、清單、必要時 ASCII 示意呈現系統結構、分層、資料流、模組依賴），存到 docs/arch/。這是預設的架構文件方式；要 Mermaid 圖時手動用 jill425:diagram-mermaid。當使用者要畫或更新架構圖、分層圖、資料流、系統結構、依賴關係，或說「畫一張圖」「visualize」「產出架構文件」時使用。Use for architecture docs, layer diagrams, data flow, or module dependency write-ups.
---

# jill425:doc-arch — 結構化 Markdown 架構文件

用**純結構化 Markdown**（不使用 mermaid 或其他圖形語法）描述系統架構、分層、資料流、模組依賴。
純文字、可 diff、GitHub / VS Code 原生渲染、低維護。

## 存放

- 檔案存 repo：`docs/arch/*.md`（不存在就建 `docs/arch/`）。
- 一個主題一個檔（如 `overview.md`、`data-flow.md`、`modules.md`），檔名用 kebab-case。
- 已有對應文件時，保留既有內容、以增補/更新方式處理，反映最新架構。

## 事實來源原則

系統架構的事實來源始終是 **code 與專案 CLAUDE.md**；本文件是衍生視圖，跟著它們走。
產文件前先讀 code 與 CLAUDE.md 對齊現況，不要憑空描述，也不要照抄舊版文件或記憶（契約 invariant 6）；舊文件跟 code 對不上時以 code 為準。結構有變時由 `jill425:task-executor` 在實作時同步更新對應文件。

## 表達手法（擇合適者組合）

用這些純 Markdown 元素承載「圖」要傳達的資訊：

- **分層 / 元件清單**：用巢狀清單或標題分層，標明每層/每元件的職責。
- **關係 / 依賴表格**：用表格表達「誰呼叫誰、誰依賴誰、輸入→輸出」。
- **資料流**：用編號步驟或 `A → B → C` 的箭頭文字描述流向，逐步說明每一跳做什麼。
- **ASCII 示意**：必要時用等寬 ASCII 框線圖輔助（放 fenced code block），但以可讀與可 diff 為先，不強求精美。
- 每張「文件」都要有：**用途說明**（這張在描述什麼）、**元件/節點說明**、**關係說明**。

### 範例骨架

```markdown
# 系統架構總覽

## 用途
描述本系統的分層與主要資料流。

## 分層
- **API 層**（`api/`）：接收請求、驗證、路由。
- **服務層**（`services/`）：業務邏輯。
- **資料層**（`repo/`）：資料庫存取。

## 依賴關係
| 來源 | 目標 | 說明 |
|------|------|------|
| API 層 | 服務層 | 呼叫業務方法 |
| 服務層 | 資料層 | 讀寫資料 |

## 主要資料流：建立訂單
1. Client → `POST /orders`（API 層驗證輸入）
2. API 層 → 服務層 `createOrder()`
3. 服務層 → 資料層寫入 `orders` 表
4. 資料層 → 回傳 id，逐層回傳給 Client
```
