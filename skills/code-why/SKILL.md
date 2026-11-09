---
name: code-why
description: 查 code 為什麼長這樣：使用者問為什麼這樣寫、能不能拿掉、從哪次改動開始變的時使用。
---

# jill425:code-why — 這段 code 為什麼長這樣

code 只說明它做什麼，不說明它為什麼存在。為什麼散在 commit、PR／MR、issue、文件與對話裡，而且常常不完整、互相矛盾，或根本沒留下。這支 skill 的工作是把找得到的證據攤開，**分清楚哪些是有人寫下的、哪些是推論、哪些查不到**，不把猜測講成事實。

全程唯讀。派 subagent 照 `${CLAUDE_PLUGIN_ROOT}/contract/dispatch.md`。

## 1. 確認對象與問題

**對象**通常是一段 code、一個寫法、一個功能或一個設計決定。**問題**可能是：為什麼這樣設計、當初的取捨、在防哪個邊界情況、受什麼外部限制、是不是死 code、或某個時間點後行為變了。

對象模糊時，從對話脈絡（剛打開的檔、剛改的地方、剛討論的東西）猜最可能的那個，先說出你的理解再查，使用者會修正。

## 2. 建立 code 錨點

派調查者前，自己先整理好這份錨點，之後每個調查者和彙整者都拿同一份：

- 檔案路徑與行號範圍、關鍵符號。
- `git blame -L <起>,<訖> <檔>`：每行最後是哪個 commit 改的。
- `git log --follow --oneline -20 -- <檔>`：跨改名的近期歷史。
- 重要 commit 的全文：`git log -1 --format=%B <sha>`，從中抓 PR／MR 編號與 issue 編號。
- PR／MR 的描述與討論：GitHub 用 `gh pr view <n> --json title,body,comments,reviews`，GitLab 用 `glab mr view <n> --comments`。
- 問題是「以前可以、現在不行」時，找出行為改變的範圍：先用 `git log` 縮小，必要時 `git bisect` 在 scratchpad 的 worktree 裡跑，不在工作目錄裡切 commit。

## 3. 派調查者

先盤點這個環境接了哪些來源，把每個可用的來源歸到一類：

| 類別 | 例子 | 最擅長回答 |
|---|---|---|
| 版本控制 | git、`gh`、`glab`、code 註解、測試 | 實作當下、在 review 裡留下的理由。**一定要查** |
| issue／工單 | GitHub／GitLab issue、Jira、Linear | 產品或業務上的起因 |
| 長篇文件 | Notion、Confluence、Google Docs | 寫成 code 之前的設計理由 |
| 即時對話 | Slack、Teams、Discord | 沒進文件的討論 |
| 錯誤追蹤與監控 | Sentry、Datadog、Grafana | 促成防禦性 code 的實際錯誤與執行狀況 |

每個可用的類別派一個調查者，同一則訊息全部派出，`subagent_type` 用 `general-purpose`（才拿得到 MCP），模型照「why 調查者」。每個 brief：

> 只查 <類別>，用 <可用的工具或 MCP>。不要修改任何檔案。
> 使用者的問題：<原話>
> code 錨點：<步驟 2 的整理>
> 用錨點裡的關鍵字、符號、PR／issue 編號、日期範圍搜尋。每個發現附出處（連結、編號、檔案與行號、日期、作者）與原文摘錄。查了什麼、用什麼關鍵字、找到什麼都要寫；**什麼都沒找到也是有效結果**，照實寫查了哪裡。

某一類沒有可用的工具時不派，在最後的〈查過的來源〉寫「沒有可用的工具，這一類沒查」——這是缺口，不是選擇。

範圍很小、而且 PR 描述已經完整回答時，可以不派調查者自己回答，但要在〈查過的來源〉說明為什麼其他來源不需要查。

## 4. 派彙整者

全部調查者回來後，派一個彙整者（`general-purpose`，模型照「why 彙整者」），brief 附上使用者原話、code 錨點、所有調查者的回報（包括什麼都沒找到的），以及 `${CLAUDE_PLUGIN_ROOT}/skills/code-why/references/synthesis.md` 的路徑，交代它照那份檔的證據強度與輸出格式寫，抽查出處、整合現有回報，全程唯讀。

## 5. 交回

呈現彙整者的結果，可以小修讓它更清楚或補上對話裡的脈絡，證據強度的措辭維持原樣。為某張單而跑時，照 `${CLAUDE_PLUGIN_ROOT}/contract/task-contract.md`〈執行期產出〉的「查證結論」交回；不是為了某張單、但結論會影響之後的開發時，建議使用者開一張調查單記下來。
