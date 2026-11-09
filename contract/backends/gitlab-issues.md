# Task 後端：gitlab-issues

task 單是 **GitLab repo 的 issue**，一律用 `glab` 存取。格式與規則見契約 `../task-contract.md`（相對本檔）；本檔只寫這個後端的機制。

**task 位置**：登記表記的 issue repo（`group/project`）。它可以跟 code 不同 repo；下文每個 `glab` 指令都帶 `-R <task 位置>`，同一個 repo 時可省。

## 1. 單存在哪、怎麼讀

```bash
glab issue list -R <task 位置>                    # 列出待辦
glab issue view <iid> -R <task 位置>              # 讀一張的全文
glab issue view <iid> -R <task 位置> --comments   # 連執行備註／驗收結果一起讀
```

讀一張時一律帶 `--comments`——現況只可能在 comment 裡（執行備註／驗收結果），body 是唯讀的原始規劃。**沒有 comment 不代表沒進度**：做到哪了看分支與 MR（§4），改了什麼看 diff。

## 2. 怎麼開新單

body 先寫進本 session 的 scratchpad 目錄再送出（長內容直接塞進 shell 會被逸出弄壞）：

```bash
glab issue create -R <task 位置> -t "<動詞開頭的標題>" --description-file <scratchpad>/issue-body.md --yes
```

- `--description-file` 才是讀檔旗標（`-F` 在 glab 是 `--output` 格式，不是 file）。
- `--yes` 免互動確認；少了它會卡在提示上。
- 與既有 issue 相連加 `--linked-issues <iid>`。
- body 就是契約的四段，不加 frontmatter；編號由 GitLab 給（iid），不自訂。

**issue body 建立後唯讀**：執行與驗收的產出一律追加 comment。覆寫 body 會蓋掉原始規劃，讓驗收失去對照基準。

## 3. 執行期產出寫哪

一律**追加 comment**，各自成一則、開頭標明類別（內容格式見契約）：

```bash
glab issue note <iid> -R <task 位置> -m "## 驗收結果
..."
```

| 類別 | 標題 |
|------|------|
| 執行備註 | `## 執行備註`（續做錨點用 `## 執行備註：續做錨點`，最新一則為準） |
| 結論 | `## 結論`（調查、效能、原型單），最新一則為準 |
| 驗收結果 | `## 驗收結果` |

契約六種情況以外不寫執行備註——**照單做的部分不另記一則**，本後端的軌跡是綁在 iid 上的分支、MR 與 commit，要看改了什麼去讀 diff。

驗收結果 comment 是「哪幾條過了」的單一事實來源；body 的 checkbox 留給人自己勾。多輪重做時每輪各追加一則，最新那則為準。

## 4. 生命週期怎麼表示

**不設 status 欄位、不設狀態 label**，用 GitLab 原生語意讀：

| 契約狀態 | 怎麼看 |
|----------|--------|
| 待辦 | issue 仍 open、尚無對應分支或 MR，也沒有標「完成」的驗收結果 |
| 執行中 | 已切到該 issue 的分支 |
| 待測 | 已開 MR |
| 修正重做 | 最新的驗收結果 comment 判定未過——在同一條分支繼續修 |
| 完成 | 最新的驗收結果 comment 標明「完成」；MR merge 後 issue 自動 close |

**現在在做哪一張，看當前 git 分支名帶的 iid**（`git branch --show-current`）。

## 5. 完成是什麼動作

驗收全條通過，驗收角色追加標明「完成」的驗收結果 comment，不需人再確認。MR 照團隊流程 merge。專案 CLAUDE.md 寫明「完成即自動 merge」時，執行角色在 pipeline 綠燈後 `glab mr merge <mr_iid> --squash --yes`；有衝突或 pipeline 紅燈就不 merge，記在單上並視為卡住。

**相依的前一張已完成、但 MR 還沒 merge**：新分支從前一張的分支切出，MR 目標設為前一張的分支（`-b <前一張的分支>`）；前一張 merge 後，把目標改回整合分支：`glab mr update <mr_iid> --target-branch <整合分支>`。

## 6. 命名與關聯慣例

- **一張 issue 一條分支一個 MR**：`git switch -c <iid>-<slug>`。
- **分支上的每個 commit 開頭帶 `#<iid>`**（契約〈git commit〉的格式），iid 就是分支名前綴那個號：
  ```
  #21 feat(auth): add login endpoint
  ```
- MR 標題比照 commit 格式（**同樣帶 `#<iid>` 開頭**）；描述寫這條分支做了什麼，並連回 issue（issue 在別的 repo 時寫 `Closes <group/project>#<iid>`）：
  ```bash
  git push -u origin <iid>-<slug>
  glab mr create -b <整合分支> -t "#<iid> <type>(<scope>): <subject>" -d "<做了什麼>

  Closes #<iid>" --yes
  ```
  **MR 標題帶編號是 squash 後 commit 帶得到編號的唯一保證**：GitLab squash 的預設訊息取自 MR 標題，標題漏了編號，整合分支上留下的那顆 squash commit 就追不回 issue。
  **`-b` 不可省**：沒帶目標分支時 `glab` 用 repo 的**預設分支**，而那未必是實際的整合分支（常見情況：預設分支是 `main`、整合分支是 `develop`）。不確定就看既有 MR 的方向：`glab mr list --merged -P 3`。開錯的補救：`glab mr update <mr_iid> --target-branch <整合分支>`。
- 相依關係走 GitLab 的 related issues（`--linked-issues`），不自訂欄位。
