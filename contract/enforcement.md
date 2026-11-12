# 規則 ↔ 強制方式（全域）

plugin 內建規則的強制方式。路徑相對本檔所在目錄。你自己新增的全域規則由 `jill425:rule-enforce` 記在本機的 `~/.claude/enforcement.md`，格式同本表。一列一條規則：誰在擋它、擋下過哪個真實的錯。只有「文件」的列表示還沒有東西強制，是下次 `jill425:rule-enforce` 優先處理的對象。

| 規則（出處） | 強制方式 | 怎麼驗它真的會擋 |
|---|---|---|
| commit 格式、subject ≤72 字元、全文 1–2 行、不加 trailer、單內 commit 帶 `#<id>`（契約〈git commit〉） | `../hooks/commit-check.sh`（PostToolUse）：agent commit 後檢查，不符就 exit 2 要它 amend。只看 agent 的 commit，不改任何 git 設定；`#<id>` 只在 repo 近 30 筆有帶時才提醒 | 在暫存 repo 由 agent 分別 commit `feat calc`、`#2 fix: a` 加兩行內文、帶 `Co-Authored-By:` 的訊息，hook 都應 exit 2 |
| 測試有鑑別力（`principles.md`〈交付〉TDD） | pytest 專案：`../scripts/verify-tdd.py`；其他框架：`tdd-evidence.md` 的手動步驟，由 tester 執行 | 在暫存 repo 加一個不依賴實作的測試（如 `assert add(2, 2) == 4` 配新增的 `mul`），腳本應判「拿掉實作照樣過」並 exit 1 |
| invariants 1–6、設計原則 | 文件（需判斷）；invariant 6 由各角色步驟的完成條件「指得出 `檔案:行`」檢查 | — |
