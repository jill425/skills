# skills

An opinionated Claude Code plugin (`jill425`) for disciplined agent work: every change goes through a written task, an isolated verifier, and moves on to the next task automatically. Docs and skills are written in Traditional Chinese.

一套給 Claude Code 用的工作流 plugin（plugin 名稱 `jill425`）。核心是 task 單：建單 → 執行 → 隔離驗收 → 完成，接著自動做下一張。搭配反向驗證 TDD、改動影響面分析、把一再出現的錯固化成檢查，以及架構文件、技術文章、圖表、潤稿、AI 日報等工具 skill。

## 安裝

```bash
claude plugin marketplace add jill425/skills
claude plugin install jill425@jill425
```

不需要額外的 setup，也不會改你的 git 設定。

**需要**：`git`、`bash`（macOS／Linux；Windows 請用 WSL）、`jq`。用 issue 當 task 後端時需要 `gh`（GitHub）或 `glab`（GitLab）。`verify-tdd.py` 需要 Python 3。

## 裝了之後會改變什麼

- **不常駐任何規則**：規則都在 `contract/` 底下，各 skill 開工時只讀自己需要的那幾份。不用這些 skill 的 session 不受影響。
- **agent commit 後檢查格式**：`hooks/commit-check.sh` 只看 agent 剛做的 commit，不符 commit 格式就要它 amend。你自己手動的 commit 不受影響，也不裝任何 git hook。在 `env` 設 `JILL425_COMMIT_CHECK=off` 可關掉（設在專案的 `.claude/settings.local.json` 只影響那個專案）。
- **本機檔案**：第一次用 task 時建立 `~/.claude/task-backends/projects.md`（每個專案的 task 放在哪）；用 `/jill425:rule-enforce` 新增全域規則時寫進 `~/.claude/enforcement.md`。兩者只存在你的機器上。

**模型分配**：依場景決定模型，不依 session：一般實作用 sonnet，困難的單（調查、效能、跨模組、重做）用 opus，驗收刻意用跟執行者不同的模型，審查與設計的兩方也用不同模型。完整對照見 `contract/dispatch.md`。想改就把 `contract/models.template.md` 複製到 `~/.claude/jill425-models.md`，只寫要改的場景。

**無人值守用 `claude -p` 跑 `/jill425:task-multi-run` 時**，要設 `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0`。`-p` 模式預設在主線最後一次動作後 10 分鐘就停掉背景的 subagent，而執行者做一張單常常超過 10 分鐘，會被中途砍掉。

**整個關掉**：`claude plugin disable jill425@jill425`。移除：`claude plugin uninstall jill425@jill425`，再視需要刪掉上面兩個本機檔案。

**建議自己加的設定**（plugin 不替你決定）：

- `~/.claude/settings.json` 設 `"attribution": {"commit": "", "pr": ""}`，讓 Claude 不在 commit 與 PR 加署名；沒設的話 commit 檢查會要 agent 拿掉。
- 契約裡有兩條在工作流之外也值得守的安全規則，想全域生效就抄進你的 `~/.claude/CLAUDE.md`：
  ```
  1. 破壞性操作先問人：rm -rf、git push --force、git reset --hard、刪分支、DB 寫入與 DDL——先說明動什麼、影響什麼，等回覆再做。（本機開發／測試用的資料庫不在此限）
  2. 正式環境只讀：要寫正式環境的資料就停下交給人；分不清是測試還是正式環境時，一律當正式環境。
  ```

## 工作流

不知道從哪開始就打 `/jill425:start`（只能手動叫用），把需求、錯誤訊息或「繼續」丟給它，它會選下面其中一步。

```
/jill425:project-init ──> /jill425:task-plan ──> /jill425:task-dev（一張，你在場）
   專案 CLAUDE.md       開 task 單        切片 → 回歸與計畫對照 → 收尾 review → task-tester 驗收
   路線圖、架構文件                       未過原地修，最多 3 輪；需要你決定時停下來問

                                        /jill425:task-multi-run（多張，可無人值守）
                                          取下一張 → 派執行者照 task-dev 做 → 完成 → 下一張
                                          沒有可做的單時彙總
```

- **兩種跑法，同一套步驟**：`/jill425:task-dev` 在你面前做一張單；`/jill425:task-multi-run` 依序把待辦派出去（相依已完成者優先、編號小的優先），每張由一個 subagent 照 `task-dev` 做，主線只選單、選模型、轉達問題與彙總，連跑一晚 context 也不會越堆越長。
- **開發中就檢查**：每個 commit 後在背景跑專案的 DoD 指令；每個切片結束，`jill425:check-plan` 在背景拿 diff 跟單比對，列出單上沒要求的 code 與還沒寫的要求。
- **做事與驗收分離**：驗收交給隔離的 `jill425:task-tester`，依單上的 `## Test 方法` 判定，用跟執行者不同的模型；沒過就由同一個執行者原地修，最多 3 輪。單上沒要求的 code 不影響判定，列出來由你決定刪或留。
- **需要你決定就停下來問**：破壞性操作、會改變行為或資料語意的發現、驗收 3 輪仍未過。無人值守時沒有人能回答，這張單記為卡住，連同相依它與受同一個決定影響的單一起跳過。
- **決策紀錄**：選單、跳過、換方向、需要判斷的驗收結論，各記一行到 git 目錄下的 `jill425/decisions.tsv`，早上看得到每個決定的理由。跑完有卡住的單時，彙總會建議用 `/jill425:task-reflect` 回顧。
- **PR／MR 不自動 merge**：完成後照團隊流程 merge；CI 紅燈與 review 留言目前由人處理，彙總會列出待處理的 PR／MR。下一張相依於還沒 merge 的單時，疊在它的分支上做。專案 `CLAUDE.md` 寫明「完成即自動 merge」時才由 agent merge。
- **先讀 code**：建單、實作、驗收、解釋 code 之前，都先讀目前分支上實際的檔案，結論附 `檔案:行`；單上的描述、文件、記憶只當線索，對不上以 code 為準。
- **測試要有鑑別力**：拿掉這張單的實作，新增的測試必須紅；放回必須綠。pytest 專案用 `scripts/verify-tdd.py` 自動驗，其他測試框架照 `contract/tdd-evidence.md` 的手動步驟驗。

完整規則見 `contract/task-contract.md`，以及它開頭列出的幾份分檔。

## task 放在哪

每種工作都開單，單就是這件工作的追蹤紀錄：功能、bug、調查、效能、原型五種，差別只在完成長什麼樣。實作跟單上的做法不同、或做了單上沒定的選擇，都會寫在單上，日後只看單和 code 就看得懂為什麼。

| 後端 | 單存在哪 |
|---|---|
| `github-issues` | GitHub repo 的 issue，PR 以 `Closes #<n>` 連回 |
| `gitlab-issues` | GitLab repo 的 issue，MR 以 `Closes #<iid>` 連回 |
| `local-files` | 專案根目錄 `tasks/` 底下的 Markdown 檔 |

第一次在某個專案用時，agent 會問 task 放在哪個 repo（可以跟 code 不同 repo），記進登記表。

一張單長這樣：

```markdown
## 背景
登入失敗時前端只顯示「錯誤」，使用者不知道是帳號還是密碼錯。

## 目標
登入 API 依失敗原因回傳不同錯誤碼，前端顯示對應訊息。
- 範圍外：密碼重設流程

## 做法
沿用 `auth/errors.py` 的錯誤碼表；不改既有 401 的語意。

## Test 方法
- [ ] `pytest tests/test_login.py` 全綠，含帳號不存在、密碼錯誤兩個案例
- [ ] 測試有鑑別力：拿掉實作後新增的測試全紅（斷言失敗）、放回全綠（驗法見契約〈TDD 證據〉）
```

## Skill 一覽

| 呼叫 | 用途 |
|---|---|
| `/jill425:start` | 入口：依專案現況判斷要初始化專案、開需求單、開 bug 單、還是執行待辦（手動觸發） |
| `/jill425:project-init` | 問答建立專案 CLAUDE.md、README、分階段路線圖、初版架構文件 |
| `/jill425:task-plan` | 釐清需求，按契約開 task 單 |
| `/jill425:task-dev` | 把一張單做到完成：切片開發、開發中檢查、收尾 review、派驗收、未過原地修 |
| `/jill425:task-multi-run` | 依序把待辦派出去做，轉達需要你決定的問題，完成就接下一張 |
| `/jill425:check-plan` | 計畫對照：拿單和 commit 比對，在背景跑，只回報 |
| `jill425:task-tester`（agent） | 隔離驗收，依 `## Test 方法` 判定，另列出單上沒要求的 code |
| `jill425:task-watcher`（agent） | 唯讀檢查者，`check-plan` 用它執行 |
| `/jill425:code-impact` | 改動會壞到哪：證明安全的理由，再派兩個不同模型的攻擊者試著弄壞它，只留跑得出來的發現 |
| `/jill425:code-design` | 跨模組的改動先設計：從呼叫端用法推出型別與介面，比較兩個不同模型畫的方案，對照設計警訊選一個再實作 |
| `/jill425:code-how` | 這段 code 怎麼運作：元件、流程、東西在哪、坑；範圍大時派探索者分頭查再整合 |
| `/jill425:code-why` | 這段 code 為什麼長這樣：查 git、PR／MR、issue 與接上的文件、聊天、錯誤追蹤，每個結論標證據強度 |
| `/jill425:task-reflect` | 回顧一輪：從單上紀錄、決策紀錄、對話找經驗，提出 skill、契約、專案規則的修改，你同意才改 |
| `/jill425:rule-enforce` | 同類錯第二次出現就改成會自動擋的檢查，維護對照表 |
| `/jill425:project-harness` | 產生專案內的 `verify-<app>` skill：啟動、操作、留證據、清理（手動觸發） |
| `/jill425:doc-arch` | 結構化 Markdown 架構文件（`docs/arch/`） |
| `/jill425:doc-article` | 把對話整理成技術文章，寫進 Notion（手動觸發） |
| `/jill425:diagram-mermaid` | 深色技術風 Mermaid 圖（手動觸發） |
| `/jill425:text-polish` | 依對象與頻道潤稿 |
| `/jill425:digest-ai` | 每日 AI 技術日報，寫進 Notion（手動觸發） |

Notion 相關 skill 需要接上 Notion MCP；資料庫以名稱搜尋，找不到時會先問要寫到哪。

## 目錄

| 路徑 | 內容 |
|---|---|
| `contract/task-contract.md` | 主檔：invariants、單的格式、Test 方法、執行期產出、生命週期、決策紀錄、commit 格式、後端 |
| `contract/dispatch.md` | 派 subagent 的慣例與模型分配 |
| `contract/principles.md` | 開發原則 |
| `contract/ticket-kinds.md` | bug、調查、效能、原型單的額外規定 |
| `contract/tdd-evidence.md` | 驗「測試有鑑別力」的方法 |
| `contract/backends/` | task 後端 adapter（GitHub、GitLab、本機檔）、登記表範本、新增後端的說明 |
| `contract/enforcement.md` | 規則 ↔ 強制方式對照表 |
| `contract/models.template.md` | 模型分配的本機設定範本 |
| `scripts/verify-tdd.py` | 反向驗證（pytest） |
| `scripts/log-decision.sh` | 決策紀錄：無人值守時每個重要決定記一行 |
| `hooks/` | agent commit 格式檢查 |
| `skills/`、`agents/` | 各 skill 與 tester、watcher 兩個 agent |
| `tests/e2e/` | 端到端測試；改了 skill、agent 或契約之後跑一次 |

## 搭配

Excalidraw 圖表推薦 [coleam00/excalidraw-diagram-skill](https://github.com/coleam00/excalidraw-diagram-skill)，請直接從上游安裝。

## English

`jill425` is a Claude Code plugin for running agent work through written tasks. All skills, contracts, and hook messages are in Traditional Chinese; the agent reads them fine, but you will need to read Chinese (or a translator) to review tickets and reports.

**Install**

```bash
claude plugin marketplace add jill425/skills
claude plugin install jill425@jill425
```

Requires `git`, `bash` (macOS/Linux; WSL on Windows), and `jq`. Issue backends need `gh` (GitHub) or `glab` (GitLab). `verify-tdd.py` needs Python 3.

**What it changes**

- Nothing is injected into every session. Rules live under `contract/`, and each skill reads only the files it needs when it starts.
- Checks the format of commits the agent makes and asks it to amend when they don't match. Your manual commits and git config are untouched. Opt out with `JILL425_COMMIT_CHECK=off` in a settings `env` block.
- Keeps two local files: `~/.claude/task-backends/projects.md` (where each project's tasks live) and, if you use `/jill425:rule-enforce`, `~/.claude/enforcement.md`.
- Models are chosen per scenario, not per session: sonnet for routine implementation, opus for hard tickets (investigation, performance, cross-module, retries), and the verifier always uses a different model from the implementer. See the contract's model allocation table. Override per role in `~/.claude/jill425-models.md` (template: `contract/models.template.md`).
- For unattended runs with `claude -p`, set `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS=0`; otherwise `-p` stops background subagents 10 minutes after the main thread's last action, and implementing a ticket often takes longer.
- Disable everything with `claude plugin disable jill425@jill425`.
- Two safety rules in the contract (ask before destructive operations; production is read-only) are worth having globally. Copy them into your own `~/.claude/CLAUDE.md` if you want that; the plugin does not do it for you.

**Workflow**

Start with `/jill425:start` (manual only): give it a request, a bug report, or "continue", and it routes to the right step below.

1. `/jill425:project-init` sets up the project's `CLAUDE.md`, README, roadmap, and an architecture doc.
2. `/jill425:task-plan` writes tickets with four sections: background, goal, approach, and objective test criteria.
3. `/jill425:task-dev` takes one ticket to done in front of you: it works in slices, runs the project's checks after each commit, compares each slice against the ticket in the background (`jill425:check-plan`), then sends a fresh `jill425:task-tester` to verify. A failed verification is fixed in place, up to 3 rounds, and when a decision is yours to make it stops and asks. `/jill425:task-multi-run` works through the backlog by dispatching one subagent per ticket that follows the same `task-dev` steps; the main thread only picks, chooses the model, relays questions, and summarizes. In unattended runs a ticket that needs a decision is marked stuck and skipped along with the tickets it affects.
4. Each notable decision (picking, skipping, changing course, judgment calls in verification) is logged to `jill425/decisions.tsv` in the git directory. `/jill425:task-reflect` reviews a run and proposes skill or rule edits, applied only with your approval.
5. PRs/MRs are not merged automatically unless the project's `CLAUDE.md` says so; CI failures and review comments are left to you. A ticket that depends on an unmerged one is stacked on its branch.

Every piece of work gets a ticket (feature, bug, investigation, performance, or prototype), and the ticket is the tracking record: deviations from the planned approach and design choices are written on it, so the ticket and the code never silently diverge.

Tasks can live in GitHub issues, GitLab issues (possibly in a different repo from the code), or Markdown files under `tasks/`. The first time you use a project, the agent asks where its tasks live.

**Read the code first**: every role reads the actual files on the current branch before explaining, changing, or judging code, and cites `file:line`. Ticket descriptions, docs, and memory are hints that may be stale.

**Tests must discriminate**: with the ticket's implementation removed, every new test must fail; with it restored, every test must pass. `scripts/verify-tdd.py` checks this automatically for pytest projects; other frameworks follow a manual procedure in `contract/tdd-evidence.md`.

## 授權

MIT，見 `LICENSE`。部分 skill 改寫自 [pstack](https://github.com/cursor/plugins/tree/main/pstack)（MIT），來源與原授權見 `THIRD_PARTY_NOTICES.md`。
