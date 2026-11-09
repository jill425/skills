---
name: project-init
description: 專案初始化：要建立或更新專案的 CLAUDE.md、README、分階段路線圖時使用。
---

# jill425:project-init — 建立專案層級設定

透過多輪問答，為當前專案產出三份文件：`./CLAUDE.md`（給 agent／skill 的專案規則）、`./README.md`（給人的上手說明）、`docs/arch/` 初版架構文件（用 `jill425:doc-arch` 產出）。本 skill 只產文件；程式骨架、依賴安裝、建置屬 `jill425:task-plan` 拆單、`jill425:task-run` 執行的範圍。

## 疊加原則＝契約是單一事實來源

task 契約（`${CLAUDE_PLUGIN_ROOT}/contract/task-contract.md`）對所有用這套工作流的專案生效，專案能覆寫什麼、不能覆寫什麼見契約開頭；task 存在哪由本機登記表宣告後端、機制寫在 adapter。專案 CLAUDE.md 只寫**專案特有**內容，與契約重疊的主題一律省略。

## 步驟

1. **掃描專案**：用 Glob／Grep／Read 看 `package.json`、`pyproject.toml`、`go.mod`、目錄結構、既有 README 等，先推斷技術棧與慣例；已能從檔案確認的直接採用。
   ✅ 完成：整理出「已確認」與「待問」兩份清單，待問清單裡沒有任何一項是檔案裡查得到的。

2. **問答釐清**：一次問最關鍵的 1–3 題，由粗到細——專案目標與技術棧 → 開發慣例 → 測試與驗收細節 → **task 要記在哪**（GitHub issue＝`github-issues`、GitLab issue＝`gitlab-issues`，或本機 `tasks/` 檔＝`local-files`；放在 issue 的，問清楚是哪個 repo，可以跟 code 不同 repo；日後改登記表即可換）。**涉及資料庫時必問資料表清單**：有哪些表、各表用途、task 將來會寫入或操作哪些——這份清單是契約 invariant 2 日後的權威來源，資訊不足的標 `<待確認>`。
   ✅ 完成：CLAUDE.md 每一節的內容都有出處（檔案掃描或使用者答案），沒有一節是編的。

3. **驗證環境**：技術棧定案後，用 Bash 實查本機版本與工具鏈（如 `python3 --version`、`node -v`、`uv --version`），確認選定的語言／版本／工具在這台機器上裝得起來、跑得動；有落差當場回報，與使用者敲定用哪個版本再往下。版本約束鎖進 manifest（`pyproject.toml`／`package.json`），CLAUDE.md 只記選型與理由——版本號快照會過期，讓 manifest 當事實來源。
   ✅ 完成：選定的工具鏈每項都在本機實查通過（或已與使用者敲定安裝方案），且版本約束落在 manifest、不在 CLAUDE.md。

4. **擬分階段路線圖**：把專案切成數個階段（MVP-1／MVP-2／Phase…），每階段一塊**端到端、裝得起來跑得動、看得見**的垂直切片（第一階段就是 walking skeleton），列出範圍與檢核點；每階段對應一或多張 task 單，階段門檻＝各單的 `## Test 方法`。
   ✅ 完成：每個階段都答得出「該階段結束時能看到什麼實際在跑」——答不出的階段是水平半成品，重切。

5. **草稿過目**：把 CLAUDE.md（含路線圖與檢核點）與 README 草稿摘要列給使用者。
   ✅ 完成：使用者明確同意。寫檔有副作用，同意前停在這一步。

6. **寫檔**：兩份都寫在專案根目錄；已存在的檔先讀出、以增補／更新處理，保留使用者既有內容。
   - **`./CLAUDE.md`**（給 agent）：專案目標與背景／技術棧（選型與理由，版本以 manifest 為準）／資料表清單（或指明 schema 檔為唯一真實來源＋對照摘要表）／目錄結構／開發慣例／**程式品質 DoD**／測試與驗收方式／分階段路線圖／專案特有限制。DoD 與測試驗收每條寫**可機械執行的實際指令**（lint／format／test、跨層 import 規則）——這是 `jill425:task-plan` 建單與 `jill425:task-tester` 驗收的引用來源。開頭註明「本檔與 jill425 plugin 的 task 契約疊加生效」。
   - **`./README.md`**（給人）：專案簡介／主要功能／技術棧／安裝與環境設定／如何執行（實際指令）／目錄結構簡述／測試怎麼跑／環境變數（指向 `.env.example`）。定位是上手說明，agent 契約內容（issue body 格式、檢核點）留在 CLAUDE.md 就好。
   ✅ 完成：DoD 與測試段的每條指令在本機跑得動；空 repo 還跑不了的（如尚無測試、無原始檔）標「待 walking skeleton 驗證」，由第一張單驗；README 讀完能裝起來、跑起來；兩檔皆無與 task 契約重複的段落，也**沒有任何指向本機路徑的個人設定**（那是與人共用的檔案）。

7. **登記 task 後端**：把步驟 2 問到的後端與 task 位置寫進 `~/.claude/task-backends/projects.md`（不存在就從契約指定的範本建立；以 `git remote get-url origin` 為鍵；無 remote 用本機路徑）。登記表已有該專案就更新那一列、備註保留；專案已推上 remote 但表上仍是本機路徑，就把鍵換成 remote。
   ✅ 完成：登記表有且只有一列對應此專案，且對應的 adapter 檔讀得到。

8. **初版架構文件**：架構定案後，用 `jill425:doc-arch` 產出結構化 Markdown 存 `docs/arch/`；後續結構變動由 `jill425:task-executor` 實作時同步更新。
   ✅ 完成：文件反映定案的分層與資料流，與 CLAUDE.md 一致。

9. **交接**：提示使用者下一步用 `jill425:task-plan` 把第一階段開成單；專案有畫面或對外服務的，walking skeleton 完成後跑 `jill425:project-harness` 產生專案的驅動與留證工具，之後的單才能引用它驗收。
   ✅ 完成：已回報產出的檔案清單與下一步。
