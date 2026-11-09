# Task 後端：github-issues

task 單是 **GitHub repo 的 issue**，一律用 `gh` 存取。格式與規則見契約 `../task-contract.md`（相對本檔）；本檔只寫這個後端的機制。

**task 位置**：登記表記的 issue repo（`owner/repo`）。它可以跟 code 不同 repo；下文每個 `gh issue` 指令都帶 `-R <task 位置>`，同一個 repo 時可省。

## 1. 單存在哪、怎麼讀

```bash
gh issue list -R <task 位置> --state open             # 列出待辦
gh issue view <n> -R <task 位置>                      # 讀一張的全文
gh issue view <n> -R <task 位置> --comments           # 連執行備註／驗收結果一起讀
```

讀一張時一律帶 `--comments`——現況只可能在 comment 裡（執行備註／驗收結果），body 是唯讀的原始規劃。**沒有 comment 不代表沒進度**：做到哪了看分支與 PR（§4），改了什麼看 diff。

## 2. 怎麼開新單

body 先寫進本 session 的 scratchpad 目錄再送出（長內容直接塞進 shell 會被逸出弄壞）：

```bash
gh issue create -R <task 位置> --title "<動詞開頭的標題>" --body-file <scratchpad>/issue-body.md
```

- body 就是契約的四段，不加 frontmatter；編號由 GitHub 給，不自訂。
- 相依關係寫在 issue 的 sub-issue／關聯，或在 body 最後一行寫 `Depends on #<n>`（只記真正的前置）。

**issue body 建立後唯讀**：執行與驗收的產出一律追加 comment。覆寫 body 會蓋掉原始規劃，讓驗收失去對照基準。

## 3. 執行期產出寫哪

一律**追加 comment**，各自成一則、開頭標明類別（內容格式見契約）：

```bash
gh issue comment <n> -R <task 位置> --body-file <scratchpad>/result.md
```

| 類別 | 標題 |
|------|------|
| 執行備註 | `## 執行備註`（續做錨點用 `## 執行備註：續做錨點`，最新一則為準） |
| 結論 | `## 結論`（調查、效能、原型單），最新一則為準 |
| 驗收結果 | `## 驗收結果` |

契約六種情況以外不寫執行備註——**照單做的部分不另記一則**，本後端的軌跡是綁在 issue 編號上的分支、PR 與 commit，要看改了什麼去讀 diff。

驗收結果 comment 是「哪幾條過了」的單一事實來源；body 的 checkbox 留給人自己勾。多輪重做時每輪各追加一則，最新那則為準。

## 4. 生命週期怎麼表示

**不設 status 欄位、不設狀態 label**，用 GitHub 原生語意讀：

| 契約狀態 | 怎麼看 |
|----------|--------|
| 待辦 | issue 仍 open、尚無對應分支或 PR，也沒有標「完成」的驗收結果 |
| 執行中 | 已切到該 issue 的分支 |
| 待測 | 已開 PR |
| 修正重做 | 最新的驗收結果 comment 判定未過——在同一條分支繼續修 |
| 完成 | 最新的驗收結果 comment 標明「完成」；PR merge 後 issue 自動 close |

**現在在做哪一張，看當前 git 分支名帶的編號**（`git branch --show-current`）。

## 5. 完成是什麼動作

驗收全條通過，驗收角色追加標明「完成」的驗收結果 comment，不需人再確認。PR 照團隊流程 merge。專案 CLAUDE.md 寫明「完成即自動 merge」時，執行角色在 checks 全綠後 `gh pr merge <pr> --squash`；有衝突或 checks 紅燈就不 merge，記在單上並視為卡住。

**相依的前一張已完成、但 PR 還沒 merge**：新分支從前一張的分支切出，PR 的 base 設為前一張的分支（`--base <前一張的分支>`）；前一張 merge 後，把 base 改回整合分支：`gh pr edit <pr> --base <整合分支>`。

## 6. 命名與關聯慣例

- **一張 issue 一條分支一個 PR**：`git switch -c <n>-<slug>`。
- **分支上的每個 commit 開頭帶 `#<n>`**（契約〈git commit〉的格式），編號就是分支名前綴那個號。
- PR 標題比照 commit 格式（**同樣帶 `#<n>` 開頭**）；描述寫這條分支做了什麼，並連回 issue（issue 在別的 repo 時寫 `Closes <owner/repo>#<n>`）：
  ```bash
  git push -u origin <n>-<slug>
  gh pr create --base <整合分支> --title "#<n> <type>(<scope>): <subject>" --body-file <scratchpad>/pr-body.md
  ```
  PR body 最後一行寫 `Closes #<n>`。squash merge 的預設訊息取自 PR 標題，標題帶編號，整合分支上的 commit 才追得回 issue。
  **`--base` 不可省**：省略時用 repo 的預設分支，未必是實際的整合分支。不確定就看既有 PR 的方向：`gh pr list --state merged -L 3`。開錯的補救：`gh pr edit <pr> --base <整合分支>`。
