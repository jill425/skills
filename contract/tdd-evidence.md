# 驗「測試有鑑別力」

給 `jill425:task-tester`：驗收程式類單的標準條「測試有鑑別力」時照本檔。要證明的是這張單新增的每個測試，拿掉實作就紅（斷言失敗），放回實作就綠。

**基底**：local-files 是這張單第一個 `#<id>` commit 的上一個 commit；issue 後端是與整合分支的 merge-base。

## pytest 專案

在專案根目錄跑 `../scripts/verify-tdd.py`（用法跑 `--help`）。它在 scratchpad 開 worktree，工作目錄不受影響，跑完自己移除。

- local-files 用 `--id <id>`，issue 後端用 `--base <整合分支>`；`--workdir <scratchpad>/vt-<id>` 讓證據檔留下來。
- `--runner` 取專案 CLAUDE.md 的測試指令（如 `uv run pytest`、`poetry run pytest`、`python -m pytest`）。
- 未進版控但測試要用的檔（如金鑰檔）加 `--copy <path>`。

輸出表格貼進驗收結果當證據。

## 其他測試框架

Jest、Vitest、Go、Flutter 等照同樣的邏輯手動做，測試指令取專案 CLAUDE.md：

1. `git worktree add --detach <scratchpad>/vt-<id> HEAD`，在裡面裝好依賴；未進版控的設定檔照需要複製過去。
2. 對照基底的 diff，列出這張單新增的測試案例。
3. 只跑這些測試：全綠才往下，否則判未過（有實作卻沒綠）。
4. 把這張單改過的非測試檔還原成基底版本（`git checkout <基底> -- <檔>`，新增的檔刪掉），再跑同一批測試：每個都要斷言失敗。
5. `git worktree remove --force <scratchpad>/vt-<id>`。

證據：兩次執行的指令與每個新測試的結果。

## 判讀

腳本的 exit code；手動驗收比照同樣四類寫結論。

| 結果 | 判定 |
|---|---|
| `0` 通過 | 通過 |
| `1` 未過 | 「拿掉實作照樣過」＝測試沒鑑別力，修復是改斷言；「有實作卻沒綠」＝實作沒完成 |
| `2` 通過但有項目需人工看 | 新模組或新函式被拿掉後測試無法收集時，腳本已改用 stub 再驗一次（函式本體換成 `return None`）；仍標 ⚠ 的是 stub 後照樣通過的測試。讀這些測試的斷言，確認驗的是對外可觀察的行為（`principles.md`〈測行為，不測實作〉），在證據行寫結論；不合格判未過 |
| `3` 無法驗證 | 環境起不來，或 worktree 的測試 import 到主目錄的 code。判「此標準無法驗證」並寫原因 |

## 限制

- 只看新增的測試案例；改了既有測試的斷言時，讀 diff 補看。
- worktree 與工作目錄共用本機資料庫等外部資源；另一個 session 正在跑測試時，等它跑完再跑。
- local-files 會把這張單碰過的實作檔整個還原到基底，之後別張單改過同一檔的內容也會一起被拿掉；紅燈可能不是這張單造成的，讀輸出判斷。
