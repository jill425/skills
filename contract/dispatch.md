# 派 subagent

派 subagent 的角色（`jill425:task-multi-run`、`jill425:task-dev`、`jill425:code-*`、`jill425:task-reflect`）照本檔。

## 慣例

1. **brief 固定五項**：使用者的原始目標（原話）、單號、要讀的檔（給路徑）、範圍邊界、回報格式。
2. **給路徑**：subagent 自己讀檔，brief 只放路徑。
3. **執行者接續，檢查的一方每次派新的**：使用者的回答、報告與實際不符的補做，傳回同一個執行者接著做；接不回去就派新的，它從單上的續做錨點接手。驗收者、檢查者、攻擊者每次都派新的，看不到前一輪的推理。
4. **worktree**：兩個以上 subagent 會同時改檔，或要拿掉實作來驗時，各自在 scratchpad 開 worktree，用完移除。
5. **報告不等於事實**：採信前自己確認關鍵事實——看 `git log`、diff、單的狀態，跑一次報告裡說通過的關鍵指令。
6. **需要人決定時**：subagent 寫續做錨點、交回「等待決定」，派的一方照 `jill425:task-multi-run` 步驟 3 處理。
7. **檢查的一方在最底層**：主線以下最多三層，第三層不能再派。驗收者與檢查者不再派 subagent。

## 模型分配

依**場景**決定模型，不依 session 是什麼模型：判斷重、出錯代價高的用強的模型；大量讀檔、照指示執行的用快的模型；互相檢查的兩方用**不同**的模型，盲點才不會重複。

使用者在本機 `~/.claude/jill425-models.md` 寫了某個場景的那一行，就以那一行為準（格式見 `models.template.md`）。值為 `inherit` 時不設 `model`。

### 實作與驗收

| 場景 | 模型 | effort |
|---|---|---|
| 執行（一般）：功能、bug、原型單 | `sonnet` | `high` |
| 執行（困難）：見下方判斷 | `opus` | `high` |
| 執行（文件）：純文件、設定單 | `sonnet` | `medium` |
| 驗收 | 跟這張單的執行者不同：執行者是 `opus` 就用 `sonnet`，否則用 `opus` | `high` |
| 計畫對照 | `sonnet`，寫在 `agents/task-watcher.md`，不吃本機設定 | `high` |

使用者直接叫用 `jill425:task-dev` 時，執行者就是 session 的模型。

**困難**由 `jill425:task-multi-run` 派工前讀單判斷，符合任一條就算：
- 單的種類是調查或效能。
- 做法或目標要新增、改變跨模組的介面，新增模組，或碰到併發、資料遷移、複雜的演算法。
- 這張單已經驗收未過一次以上。

### 審查、設計、理解與回顧

| 場景 | 誰派 | 模型 | effort |
|---|---|---|---|
| 攻擊者 A／B | `jill425:code-impact` | `opus`／`sonnet` | `high` |
| 設計者 A／B | `jill425:code-design` | `opus`／`sonnet` | `high` |
| how 探索者／解說者 | `jill425:code-how` | `sonnet`／`opus` | `medium`／`high` |
| why 調查者／彙整者 | `jill425:code-why` | `sonnet`／`opus` | `medium`／`high` |
| reflect 審視者／彙整者 | `jill425:task-reflect` | `sonnet`／`opus` | `high` |

指定的模型被拒絕時，改成不設 `model`，並在報告裡說明。
