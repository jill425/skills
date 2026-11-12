# 來源清單與查詢範本

## A. 大神名單（優先撈取一手內容）

可依使用者偏好增刪。每次執行至少涵蓋「核心」組；「延伸」組視時間抽查。

### 核心
| 人物 | X handle | 一手管道 | 特色 |
|---|---|---|---|
| Andrej Karpathy | @karpathy | karpathy.ai、YouTube @AndrejKarpathy、GitHub karpathy | LLM 原理、教學、vibe coding |
| Simon Willison | @simonw | simonwillison.net（每日更新，常轉述推文） | LLM 工具、提示注入、實測新模型 |
| Peter Steinberger | @steipete | steipete.me、GitHub steipete | AI agent 實戰、Claude Code 工作流、MCP 工具 |
| Addy Osmani | @addyosmani | addyosmani.com、Substack (Elevate) | AI 輔助開發、工程效能、Chrome |
| Swyx (Shawn Wang) | @swyx | latent.space（podcast + newsletter） | AI Engineer 生態、產業脈動 |
| Andrew Ng | @AndrewYNg | deeplearning.ai The Batch | agentic workflow、產業觀點 |

### 延伸
| 人物 | X handle | 一手管道 |
|---|---|---|
| Hamel Husain | @HamelHusain | hamel.dev（evals） |
| Jason Liu | @jxnlco | jxnl.co（RAG、結構化輸出） |
| Lilian Weng | @lilianweng | lilianweng.github.io |
| Sebastian Raschka | @rasbt | magazine.sebastianraschka.com |
| Chip Huyen | @chipro | huyenchip.com（AI 系統設計） |
| Harrison Chase | @hwchase17 | blog.langchain.com |
| Jeremy Howard | @jeremyphoward | answer.ai blog |
| Ethan Mollick | @emollick | oneusefulthing.org |
| Geoffrey Litt | @geoffreylitt | geoffreylitt.com |
| Mitchell Hashimoto | @mitchellh | mitchellh.com |
| Thorsten Ball | @thorstenball | registerspill.thorstenball.com |
| Boris Cherny | @bcherny | Claude Code 相關 |
| Guillermo Rauch | @rauchg | vercel.com/blog |
| Kent C. Dodds / Theo (t3.gg) | @kentcdodds / @theo | YouTube |

## B. 官方發布來源

### 主要實驗室（每天必查，每家至少 1 次）
先 WebFetch 索引頁；被擋（403）或只顯示月份時，改用該列的搜尋關鍵字確認窗內有無新發布。

| 實驗室 | 產品線 | 索引頁 | 被擋時搜尋 |
|---|---|---|---|
| Anthropic | Claude | anthropic.com/news、docs.claude.com release notes | `Anthropic Claude {date}` |
| OpenAI | GPT、Codex、ChatGPT | openai.com/news、platform.openai.com changelog | `OpenAI {date}` |
| Google | Gemini、Genie、AI Studio | deepmind.google/discover/blog、blog.google/technology/ai、developers.googleblog.com、ai.google.dev/gemini-api/docs/changelog | `Gemini {date}`、`Google AI {date}` |
| Meta | Muse、Llama | ai.meta.com/blog、research.meta.ai/blog | `Meta Muse {date}`、`Meta AI {date}` |
| xAI | Grok | x.ai/news、docs.x.ai release notes | `Grok xAI {date}`、`Elon Musk Grok {date}` |
| Mistral | Mistral、Le Chat | mistral.ai/news | `Mistral AI {date}` |

查無窗內新發布的實驗室，列進〈本期覆蓋說明〉。

### 其他
- huggingface.co/blog
- github.blog/changelog、cursor.com/changelog

（研究文章、論文、工程技術深度文的來源另見 `research-sources.md`。）

## C. GitHub 熱門
- github.com/trending（Python / TypeScript / Rust，daily）
- 搜尋「GitHub trending AI repo」+ 日期
- 留意大神推薦的新 repo、重要專案新 release（如 llama.cpp、vLLM、ollama）

## D. YouTube
- Andrej Karpathy、AI Explained、Two Minute Papers、Yannic Kilcher、Latent Space、AI Engineer（會議演講）、Matthew Berman、Fireship、Theo - t3.gg、Dwarkesh Patel
- 只收窗口內上架的影片；大綱以影片說明、章節時間戳、相關報導整理。

## E. 產業動態
- TechCrunch AI、The Verge AI、The Information、Reuters Tech、Bloomberg Tech
- Hacker News 首頁（用來發現大神長文與熱門討論）

## F. 查詢範本（把 {date} 換成實際日期，如 "October 6 2026"）
- `Karpathy {date}`、`simonwillison.net {date}`、`steipete`、`Addy Osmani AI`
- `AI model release {date}`、`new LLM launch today`
- `GitHub trending AI repository {month year}`
- `{人名} YouTube new video`
- `AI startup funding {date}`、`AI news today`
