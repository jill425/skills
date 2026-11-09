---
name: diagram-mermaid
description: 產出深色技術風的 Mermaid 架構圖，存到 docs/arch/。
disable-model-invocation: true
---

# Mermaid Diagram

用 Mermaid 產出**會論證、非只展示**的圖,寫進 Markdown code block。特性:純文字事實來源、可 diff、GitHub / VS Code 原生渲染、改一行即更新。預設套用**深色技術風主題**(見 `references/style.md`)。

> Mermaid 檔本身就是圖的事實來源(結構=flowchart 本體、呈現=`config` frontmatter),不需另建資料檔。但**系統架構的事實來源始終是 code 與專案 CLAUDE.md** —— 圖是衍生視圖,結構一變就同步更新對應圖,避免過時。

## 核心原則
- **圖要論證,不只展示**:結構要傳達分層、方向、因果,不是把文字排進盒子。若把文字全拿掉,結構本身仍能說明概念,才算合格。
- **色彩即語意**:顏色一律取自 `references/style.md`,不自創;同一分層 / 同一語意固定同一色。
- **狀態要看得出來**:已建 / 規劃中 / dev-only 用 `classDef` 的線型與顏色區分(見 style)。
- **簡潔勝堆砌**:節點文字精煉;邊上只標關鍵語意(fan-out、單向依賴、重用)。

## 產出規格(硬性)
- 圖寫在 Markdown 的 ` ```mermaid ` code block 內。
- **每個 block 開頭放 `config` frontmatter**,套用深色技術風主題 —— 直接複製 `references/style.md` 的設定區塊。
- 架構圖落點:`docs/arch/<主題>.mermaid.md`(同一主題重畫用同一檔覆蓋),與 `jill425:doc-arch` 的文件放在一起。
- 一份 `.md` 可含多張圖(如主架構圖 + 單一模組內部圖)。

## 流程

### 1. 讀專案結構(先做,不要憑空畫)
弄清楚**分層、模組、資料流、狀態**:
- 專案 `CLAUDE.md`(分層、命名軸、路線圖)— 最優先事實來源。
- 目錄結構:`src/**` 的 package 分層。
- 跨模組呼叫方向(誰呼叫誰、fan-out 到哪些下游 / 上游)。
- 每節點狀態:已建(檔案存在 / 已驗收)、規劃中(路線圖有但未建)、dev/test-only。
> 依賴邊不確定時,直接讀 code 或交給 subagent 查,**不要臆測**。

### 2. 選圖型與版式
讀 `references/patterns.md`,依內容挑最合適的圖型與版式(分層用 subgraph flowchart TD、互動順序用 sequenceDiagram、狀態轉換用 stateDiagram…),並套 `references/style.md` 的色彩與 classDef。

### 3. 寫 Mermaid
- 貼上 style 的 `config` frontmatter → 寫圖本體。
- 分層用 `subgraph`;方向 `flowchart TD`(上到下)為主,層內用 `direction LR`。
- 狀態用 `:::planned` / `:::dev` 套 classDef;主流程實線、旁支 / 弱關聯用虛線 `-.->`。
- 節點內容須與專案 CLAUDE.md 現行分層 / 命名一致;發現圖與現行規則牴觸應**更正並回報**,不複製舊誤。

### 4. 驗證(產出前必做)
Mermaid 語法錯會整張圖不渲染,務必驗:
- 若環境有 mermaid CLI:`npx -y @mermaid-js/mermaid-cli -i <file>.md -o /tmp/diagram.png` 可一次驗語法 + 出 PNG 檢視;跑不動則略過此步。
- 人工檢查:每個 `-->` 兩端節點都有定義;`subgraph` 都有 `end`;`classDef` 名稱與 `:::` 使用一致;中文 / 特殊字元節點文字用 `["..."]` 包住。
- 版式提醒:層內 `direction LR` 若被跨層邊拉成垂直堆疊(Mermaid 已知行為),圖會偏高;必要時減少跨層邊或拆圖。

