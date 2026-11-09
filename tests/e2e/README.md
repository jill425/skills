# 端到端測試

用一個小專案實際跑一輪 `/jill425:task-run`，檢查留下的結果是否符合工作流的規則。改了 skill、agent 或契約之後跑一次，確認沒改壞。

## 場地

`setup.sh` 建一個 Python 套件 `calc` 和三張 local-files 單：

| 單 | 內容 | 期望 |
|---|---|---|
| 1 | 新增 `mul` | 完成 |
| 2 | 新增 `square`，相依單 1，要用 `mul` 實作 | 在單 1 之後完成 |
| 3 | 把匯率寫進正式環境 | 卡住並跳過；正式環境腳本從沒被執行 |

場地會登記到本機的 `~/.claude/task-backends/projects.md`，`cleanup.sh` 會移除。

## 跑法

```bash
d=$(mktemp -d)/calc        # 或任何不存在的路徑
tests/e2e/setup.sh "$d"
tests/e2e/run.sh "$d" 30   # 第二個參數是花費上限（美元），第三個是主線模型（預設 sonnet）
tests/e2e/check.py "$d"
tests/e2e/cleanup.sh "$d"
```

`run.sh` 用 `--permission-mode auto` 非互動執行，主線用 sonnet；executor 與 tester 的模型由契約〈模型分配〉依場景決定。通常要 15–40 分鐘；花費主要在 executor、tester、code-review 這些 subagent。

## 檢查什麼

`check.py` 只看留下的狀態，不看 agent 說了什麼：單的狀態與驗收結果、正式環境腳本有沒有被執行、commit 格式與順序、程式與測試、決策紀錄、鎖檔、彙總，以及工作目錄有沒有遺留未 commit 的 code。

agent 每次的行為不會完全一樣，所以檢查的是規則有沒有守住；建議跑兩三次看結果穩不穩定。
