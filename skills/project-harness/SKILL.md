---
name: project-harness
description: 替專案產生 verify-<app> skill：啟動真實 app、像使用者一樣操作、留下證據。
disable-model-invocation: true
---

# jill425:project-harness — 產生專案的驗證 skill

測試證明函式對；這個 skill 證明使用者看到的對：啟動真的 app、照使用者的路徑操作、留下證據。產出寫給下一個 agent 看——它會在任務中途、從沒看過這個 app 的情況下讀它。產出放在專案 repo，與隊友共用：不寫本機絕對路徑、不寫密鑰（環境變數指向 `.env.example`）。

## 步驟

1. **從 repo 問，不先問人**：只問 code 裡看不到的。
   - **介面**：使用者實際碰的是什麼——網頁、App（Flutter 等）、API、CLI。有多個就選主要的，其他記下。
   - **啟動**：專案自己寫的啟動指令（`README`、`package.json` scripts、`Makefile`、`docker compose`），port、環境變數、種子資料、登入方式。只啟動本機，不指向任何共用的測試或正式環境（契約 invariant 5）。
   - **驅動**：先找 repo 既有的工具（Playwright／Cypress、`integration_test`、HTTP client 測試），沒有才選通用做法：網頁用 Playwright，Flutter 用 `integration_test`／`flutter drive`，API 用 `curl`／`httpx`，CLI 用 PTY。
   - **觀察**：能拿到什麼證據——截圖、回應內容、log、exit code、DB 狀態。
   - **隔離**：能不能同時開兩份（port、資料目錄）。不行就在產出裡寫明，寧可拒絕也不要操作使用者正在用的那份。
   ✅ 完成：五項都有出處（檔案或使用者答案）。專案目前起不來就先修好或精確回報，不對著壞掉的基底寫步驟。

2. **寫 `.claude/skills/verify-<app>/SKILL.md`**：frontmatter 要有 `name: verify-<app>` 與 `description`（點名 app、介面、何時用；沒有 frontmatter 不會被載入）。各段都用這個 repo 的真實指令與選擇器，不留範例佔位：
   - **啟動**：從空的資料目錄到「可用」的完整指令（含 migration、種子資料），以及怎麼判斷就緒——要可用，不是 process 有回應而已。附關閉方式。
   - **健康檢查**：一個唯讀檢查回答「這份值得操作嗎」：process 在、版本對、port 是我們開的、登入有效。看起來怪就先跑它。
   - **驅動**：真實的指令或選擇器。優先用穩定的把手（ARIA label、`data-testid`、`Key`、路由），不用座標與 tab 順序。
   - **證據**：要存什麼、存哪（例：`.verify-evidence/<日期>-<功能>/`，並加進 `.gitignore`）。標準：走真實使用者路徑，不用內部 setter 或測試專用 endpoint；存「動作」與「結果狀態」，不只最後一張畫面；副作用（寫入的列、送出的請求）一併查；dry-run 實際跳過什麼要觀察，不信它的名字。
   - **清理**：只關自己開的東西，不用 process 名稱去殺；清理後證據還在。
   - **輔助腳本**：放在 skill 目錄內、可執行，用法寫在本文。
   ✅ 完成：檔內沒有佔位字、沒有本機絕對路徑。

3. **功能地圖**：`.claude/skills/verify-<app>/features/README.md`（索引）加上前 3–5 個使用者功能各一檔，從路由、選單、指令、文件找。每檔四段：`子功能`、`怎麼到達（使用者視角）`、`用 <工具> 操作`、`坑`。種子資料缺某個前置條件時，那條路徑回報失敗並把原因寫進 `坑`，不改弱路徑讓它通過。
   ✅ 完成：每個功能檔寫得出「看到什麼就證明它正常」。

4. **自己跑一次**：照產出的指示從頭跑——啟動 → 健康檢查 → 操作地圖上一個功能 → 存證據 → 清理。清理後確認證據還在。失敗就修，每次失敗後也跑清理，不留殘餘 process 與 port。沒跑過的 skill 只是草稿。
   ✅ 完成：附這次的證據路徑與清理後 `ls` 的輸出。

5. **接上流程**：在專案 CLAUDE.md〈測試與驗收〉加一行指向 `verify-<app>`，讓 `jill425:task-plan` 寫 Test 方法、`jill425:task-tester` 驗收時都用它。列出所有產出檔給使用者過目，⛔ 同意後才 commit（`chore(verify): ...`）。

## 維護

app 改了、地圖跟不上時，重跑步驟 3–4 修正走不通的功能檔；新功能上線時補一檔。修正要有實際跑過的證據，不憑讀 code 改地圖。
