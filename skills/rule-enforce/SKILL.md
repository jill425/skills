---
name: rule-enforce
description: 把一再糾正 agent 的同類錯誤固化成會自動擋的檢查：從對話紀錄、git 歷史、review 意見找出犯過兩次以上的錯，依「架構 → 型別／lint／hook／CI → 測試 → 文件」選最上層擋得住的方式修，並維護「規則 ↔ 誰強制」對照表。當使用者說「又犯同樣的錯」「這個講過很多次了」「把這條規則做成檢查」，或要盤點哪些規則只靠文字時使用。 Use when the agent keeps repeating the same mistake and the rule should become an automated check.
---

# jill425:rule-enforce — 把教訓變成檢查

假設每個 agent 只看得到它打開的檔、會照抄最近的範例、走最短能跑的路。文字規則被跳過時什麼都不會失敗；檢查會。所以同類錯第二次出現，就該讓 repo 擋住它，而不是再寫一次規則。

## 範圍

- 預設只看**當前專案**：該專案的對話紀錄 `~/.claude/projects/<slug>/*.jsonl`（slug＝專案絕對路徑把 `/` 換成 `-`）、Claude Code memory（`~/.claude/projects/<slug>/memory/`）裡使用者給過的回饋、git 歷史、PR／MR review 意見（github-issues：`gh pr list --state merged`、`gh pr view <n> --comments`；gitlab-issues：`glab mr list --merged`、`glab mr view <n> --comments`）。
- 全域層（`~/.claude/` 的契約、skill、hook）只有使用者點名才盤。讀別的專案前先說要讀什麼。

## 步驟

1. **找錯誤類別**：使用者的糾正（「不是這樣」「又…」「我說過」）、revert、緊接在 `feat` 後的 `fix`、amend、review 退件、解釋繞路的註解。歸成類別，**發生兩次才算一類**。對話紀錄量大時交給 subagent 撈，主線只收「類別、次數、出處（紀錄檔名＋時間，或 commit sha）」。
   ✅ 完成：每一類都有至少兩個可追的出處；一次性的錯不列。

2. **對照現有規則**：讀 `${CLAUDE_PLUGIN_ROOT}/contract/enforcement.md`（plugin 內建的規則）、`~/.claude/enforcement.md`（你自己的全域規則，沒有就略過）與專案 CLAUDE.md 的〈規則與強制〉段。已有文字規則卻沒有東西強制的，算**重犯**，排最前面。

3. **選層級**：由上往下，第一個做得到的就用。
   1. **架構**：讓錯的寫法不存在。一份狀態一個擁有者、一件事一種做法；刪掉會被照抄的舊做法與死 code；手動同步的清單改成單一來源；藏起內部，錯的 import 直接失敗。
   2. **型別／lint／hook／CI**：錯的寫法寫不出來或過不了。錯誤訊息要指名改用哪個檔、型別或函式。既有違規很多時只擋新增的。
   3. **測試**：測對外行為，拿掉行為就紅（契約〈TDD 證據〉）。
   4. **文件／agent 規則**：只留給需要判斷的事，寫上一個真實的失敗例子。
   ✅ 完成：每一類都說得出「選這層，因為上一層做不到的原因」。

4. **過目**：列出每類的證據、選的層級、要改的檔。⛔ 使用者同意後才改。專案內的檢查也是 code，照常走 `jill425:task-plan` 開單；`~/.claude/` 底下的檢查使用者同意即可直接做，改前備份到 `~/.claude/backups/`。

5. **證明檢查有效**：新檢查要在**一個真實的過去錯誤**上失敗（checkout 那個 commit、重放那段 commit 訊息或指令），在現況通過。同一個指令本機與 CI 都跑得動。例外寫在違規那一行旁邊，附理由、到期日與核准的人。
   ✅ 完成：附兩段實際輸出——擋下過去的錯、現況照常通過。

6. **更新對照表**：一列一條規則：規則與出處｜強制方式（檔案路徑）｜證明（擋下的過去實例）。被架構消除、已不可能發生的錯，刪掉它的文字規則。

## 對照表放哪

- 全域：`~/.claude/enforcement.md`（只存在本機；不存在就照 `${CLAUDE_PLUGIN_ROOT}/contract/enforcement.md` 的表頭建立）。不寫進 plugin 目錄（plugin 更新時會被覆寫），也不放 `~/.claude/rules/`（每個 session 自動載入，佔常駐 context）。
- 專案：專案 CLAUDE.md 的〈規則與強制〉段。這份與隊友共用，不寫本機路徑。

## 回報

每一類：證據出處、選的層級、為什麼上一層不行、證明輸出。最後附更新後的對照表列。
