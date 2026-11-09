# Task 後端：local-files

task 單是**當前專案根目錄 `tasks/` 底下的 Markdown 檔**，扁平存放、靠檔名編號區分。格式與規則見契約 `../task-contract.md`（相對本檔）；本檔只寫這個後端的機制。

## 1. 單存在哪、怎麼讀

```
tasks/
  INDEX.md              # 看板：所有單與 status（彙整視圖，人工可讀）
  task-1-<slug>.md
  task-2-<slug>.md
```

- **單一 task 檔才是該單的事實來源**，`INDEX.md` 只是彙整視圖。
- 列出待辦：讀 `tasks/INDEX.md`，或掃 `tasks/task-*.md` 的 frontmatter `status`。
- 讀一張：完整讀該檔（frontmatter＋全部段落，含既有 `## 執行備註`／`## 驗收結果`）。
- **`tasks/` 跟 code 一起進版控**。驗收角色只改單檔、不 commit；單檔的變動由執行角色跟下一個 commit 一起提交，沒有 code 變動時單獨 commit `#<id> chore(tasks): <說明>`。

## 2. 怎麼開新單

寫 `tasks/task-<id>-<slug>.md`，並在 `INDEX.md` 補一列。檔案結構：

```markdown
---
id: 2
title: 動詞開頭的簡短描述
status: Not started
dependencies: [1]
---

（契約的四段：背景／目標／做法／Test 方法）

## 執行備註
## 結論
## 驗收結果
```

- `id`：同專案內唯一的整數，從 `1` 起編。開新單時取 `tasks/task-*.md` 現有最大 id 加一；寫檔前確認檔名沒被佔用。
- `dependencies`：依賴的 id 清單，**只記真正的前置**，無則 `[]`。
- 建立時 `status` 一律 `Not started`；`## 執行備註`、`## 結論`、`## 驗收結果` 留空標題等執行期填（`## 結論` 只有調查、效能、原型單會用到）。

`INDEX.md` 格式：

```markdown
# Tasks

| id | title | status | dependencies |
|----|-------|--------|--------------|
| 1  | 建立專案骨架 | Verified    | [] |
| 2  | 接上真實 DB  | Not started | [1] |
```

## 3. 執行期產出寫哪

**寫在該 task 檔的對應段落**（執行備註就地改；驗收結果每輪追加）：

| 類別 | 落點 |
|------|------|
| 執行備註 | `## 執行備註`（契約六種情況以外留空；續做錨點寫成 `### 續做錨點` 一節，就地覆寫，轉 `In review`（待測）時刪除） |
| 結論 | `## 結論`（調查、效能、原型單），就地覆寫，最新為準 |
| 驗收結果 | `## 驗收結果` 底下**每輪追加一節** `### 第 N 輪（YYYY-MM-DD）`（內容格式見契約），不覆寫前輪，最新一輪為準；**並同步**把 `## Test 方法` 的 checkbox 依最新一輪就地勾成 `- [x]`；不通過的維持 `- [ ]` |

輪數就是 `### 第 N 輪` 的節數——`jill425:task-run` 的 3 次上限以此計，前幾輪的判定也從這裡攤給人看。

checkbox 是「哪幾條過了」的單一事實來源——只把結果寫在 `## 驗收結果` 卻放著原 checkbox 不動，會讓已驗的單看起來像沒驗。

本後端不綁分支名（§6），這張單的改動用 `git log --grep '^#<id> '` 找。

## 4. 生命週期怎麼表示

frontmatter 的 `status` 欄位承載，並同步 `INDEX.md` 對應列：

| 契約狀態 | `status` 值 | 誰設定 |
|----------|-------------|--------|
| 待辦 | `Not started` | 規劃 |
| 執行中 | `In progress` | 執行 |
| 待測 | `In review` | 執行 |
| 修正重做 | `Failed` | 驗收 |
| 完成 | `Verified` ＋ 驗收結果最新一輪標註「完成」 | 驗收 |

`Failed` 的單會被執行角色撈回重做，重做時參考 `## 執行備註` 與驗收寫下的失敗說明。舊值 `Done` 視同 `In review`、`Passed` 視同 `Verified`。

**一張單可以開始的條件**：`status` 為 `Not started` 或 `Failed`，**且其 `dependencies` 全部已 `Verified`**。同時滿足的多張都可選。

## 5. 完成是什麼動作

驗收全條通過時，驗收角色把 `status` 改為 `Verified` 並同步 `INDEX.md`，不需人再確認。本後端沒有 PR，code 就在當前分支上，相依它的單可以直接開工。

## 6. 命名與關聯慣例

- 檔名 `task-<id>-<slug>.md`，slug 用簡短英文或拼音。
- 相依關係走 frontmatter `dependencies`；推進順序 = 依賴滿足者優先，同時滿足者 id 小的優先，一次做一張。
- 本後端不綁定分支名；commit 仍照契約〈git commit〉在開頭帶 `#<id>`，`<id>` 取 frontmatter 的 `id`（本後端唯一把單與 code 連起來的線索）。
