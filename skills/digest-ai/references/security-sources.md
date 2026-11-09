# 資安來源清單與查詢範本

讀者是 AI / 軟體工程師，所以資安區塊的取捨是：**「會影響我寫的程式、用的工具、跑的系統」優先於一般社會新聞**。來源依可信度與一手程度分層，搜尋時由上往下。

## 收錄優先順序（同時也是篩選標準）

1. **已遭實際利用的漏洞**：被列入 CISA KEV、廠商確認 in-the-wild exploitation、緊急修補（out-of-band patch）。這類有立即行動價值，若影響面大可直接進「今日三大重點」。
2. **AI / LLM 安全**：prompt injection、agent / MCP / coding assistant 的攻擊面、模型或 AI 平台漏洞、AI 被用於攻擊的威脅情資報告。與本日報讀者最相關。
3. **軟體供應鏈**：npm / PyPI / crates / GitHub Actions / VS Code 擴充套件的惡意套件、被劫持的維護者帳號、CI/CD 攻擊。
4. **開發者常用平台與工具的重大漏洞**：雲端（AWS/GCP/Azure）、Kubernetes、瀏覽器、作業系統、常用框架與函式庫（高 CVSS 或影響面廣者）。
5. **重大資安事件**：大規模資料外洩、勒索軟體攻擊重要企業或基礎設施、APT 行動揭露。
6. **台灣在地**：影響台灣企業/政府的事件、TWCERT/CC 與國家資通安全研究院的警訊、台灣研究員的重要發現。
7. **政策與法規**：資安相關法規、出口管制、重大執法行動（botnet 查封、逮捕）。

略過：純行銷的廠商白皮書、沒有新資訊的「年度趨勢預測」、僅聚合轉貼的二手站、無 CVE / 無來源佐證的傳言。

## A. 一手官方與漏洞資料（可信度最高，用來確認事實）

| 來源 | 網址 | 用途 |
|---|---|---|
| CISA KEV 目錄 | cisa.gov/known-exploited-vulnerabilities-catalog | 判斷是否「已遭利用」的權威依據；每則附加入日期 |
| CISA Alerts & Advisories | cisa.gov/news-events/cybersecurity-advisories | 重大警訊、聯合通報 |
| NVD / CVE.org | nvd.nist.gov、cve.org | 確認 CVE 編號、CVSS、受影響版本 |
| GitHub Security Advisories | github.com/advisories | 開源套件漏洞（npm、PyPI、Go、Rust…） |
| OSV.dev | osv.dev | 開源漏洞彙整，含惡意套件（MAL-）紀錄 |
| 廠商 PSIRT / 安全公告 | Microsoft MSRC、Google Chrome Releases、Apple Security Updates、Cisco、Fortinet PSIRT、Ivanti 等 | 修補與 in-the-wild 確認 |
| TWCERT/CC | twcert.org.tw | 台灣漏洞通報與資安訊息 |
| 國家資通安全研究院 | nics.nat.gov.tw | 台灣政府層級的資安警訊 |

## B. 資安新聞媒體（速度快，作為發現管道）

**第一步固定抓這三個首頁**（WebFetch，token 上限約 5000）：`https://thehackernews.com/`、`https://www.securityweek.com/`、`https://www.bleepingcomputer.com/`（事件與勒索類常只有它報）。首頁列出每則標題、日期與摘要，一次就能篩出窗口內候選。台灣在地抓 `https://www.ithome.com.tw/security`。

文章內附的一手連結（廠商公告、研究單位、CVE、GitHub issue）可直接當主連結。要進「今日三大重點」或資訊互相矛盾的條目，才 WebFetch 全文或一手來源，確認 CVE、受影響版本與利用狀態；只看到摘要的註明「依 XX 摘要整理」。

首頁抓完後，用 1–2 次搜尋補漏（AI 安全、供應鏈）、1 次重大事件（`data breach OR ransomware {date}`）、1 次台灣在地。

嚴重性只寫有來源支撐的 CVSS 與利用狀態：「PoC 已公開」與「已遭大規模利用」分開寫。與 AI 主題重疊的漏洞（如 AI coding 工具的 prompt injection）放資安區。

| 來源 | 網址 | 特色 |
|---|---|---|
| BleepingComputer | bleepingcomputer.com | 漏洞、勒索軟體、事件，更新最快 |
| The Record (Recorded Future News) | therecord.media | 國家級威脅、政策、執法，報導嚴謹 |
| SecurityWeek | securityweek.com | 漏洞與產業，每日量大 |
| The Hacker News | thehackernews.com | 覆蓋廣，但標題偏聳動，事實以一手來源為準 |
| Dark Reading | darkreading.com | 企業資安、分析文 |
| Ars Technica Security | arstechnica.com/security | 技術深度佳 |
| iThome 資安 | ithome.com.tw/security | 台灣最完整的中文資安新聞，含在地事件 |
| 資安人 | informationsecurity.com.tw | 台灣產業與法規面 |

## C. 研究單位與威脅情資部落格（一手研究，價值最高）

- **漏洞研究**：Google Project Zero (googleprojectzero.blogspot.com)、watchTowr Labs、Trail of Bits blog、DEVCORE（台灣，Orange Tsai 團隊）、Wiz Research、Assetnote
- **威脅情資**：Google Threat Intelligence / Mandiant、Microsoft Threat Intelligence、Cisco Talos、Palo Alto Unit 42、Check Point Research、ESET WeLiveSecurity、Kaspersky Securelist、Trend Micro Research（台灣淵源）
- **供應鏈**：Socket.dev blog、Aikido Security blog、StepSecurity、Snyk、JFrog Security Research、ReversingLabs
- **AI 安全**：
  - Embrace The Red（Johann Rehberger，AI agent / coding assistant 的 prompt injection 實測）
  - Simon Willison 的 prompt-injection 標籤（已在主名單，留意資安類文章）
  - OWASP GenAI Security Project（LLM Top 10）、MITRE ATLAS
  - AI 廠商的威脅報告與安全公告：Anthropic、OpenAI、Google 的 threat intelligence / misuse 報告
  - HiddenLayer、Protect AI（huntr）、Lakera、Pillar Security 等 AI 安全公司研究

## D. 資安大神（一手觀點）

| 人物 | 管道 | 特色 |
|---|---|---|
| Brian Krebs | krebsonsecurity.com | 調查報導、網路犯罪 |
| Bruce Schneier | schneier.com | 資安政策與評論，常談 AI 安全 |
| Kevin Beaumont | doublepulsar.com、Mastodon/Bluesky @GossiTheDog | 重大漏洞與事件的即時判讀 |
| Troy Hunt | troyhunt.com（Have I Been Pwned） | 資料外洩 |
| Johann Rehberger | embracethered.com | AI agent 攻擊面 |
| Daniel Miessler | danielmiessler.com（Unsupervised Learning） | 資安 × AI 週報與觀點 |
| Clint Gibler | tldrsec.com（tl;dr sec） | 每週精選，用來補漏 |
| Orange Tsai | blog.orange.tw、DEVCORE | 台灣頂尖漏洞研究員 |

## E. 補漏用彙整來源（只用來「發現」，收錄時連到原始來源）

- SANS Internet Storm Center 每日 Diary（isc.sans.edu）
- Risky Business newsletter（risky.biz）
- Hacker News 首頁、r/netsec

## F. 查詢範本（把 {date} 換成實際日期，如 "October 7 2026"）

- `actively exploited vulnerability {date}`、`CISA KEV added {date}`、`zero-day patch {date}`
- `prompt injection {month year}`、`AI agent vulnerability`、`MCP security vulnerability`、`LLM jailbreak research {month year}`
- `malicious npm package {date}`、`PyPI malware {date}`、`supply chain attack {date}`
- `data breach {date}`、`ransomware attack {date}`
- `site:bleepingcomputer.com {date}`、`site:therecord.media`、`site:ithome.com.tw/security`
- `iThome 資安 {日期}`、`TWCERT 漏洞`、`台灣 資安 事件 {日期}`
- 上面的查詢範本是首頁抓取之後的補漏用，不必全部跑。
- 資安新聞常在一天內大量轉載，同一事件只收一則，主連結優先用一手來源，媒體報導放在後面。
