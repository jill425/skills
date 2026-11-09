# 研究 / 技術文章 來源清單與查詢範本

這個區塊收的是「有新發現或深入技術內容」的長文：AI 實驗室的研究文章與論文、工程團隊的技術深度文。
範例：Anthropic 的 [Emotion concepts and their function in a large language model](https://www.anthropic.com/research/emotion-concepts-function)（可解釋性研究，部落格文 + transformer-circuits.pub 完整論文）。

讀者是 AI / 軟體工程師，所以取捨原則是：**「能改變我對模型行為、訓練方法或 agent 設計的理解」優先於純學術增量改進**。

## 與其他區塊的分界

| 內容 | 放哪裡 |
|---|---|
| 實驗室發表的研究結果、論文、可解釋性 / 對齊 / 評測研究 | 🔬 研究 / 技術文章 |
| 實驗室或公司工程部落格的技術深度文（例如「我們怎麼做 agent 的 context 管理」） | 🔬 研究 / 技術文章 |
| 以系統架構、基礎設施、擴展性為主軸的文章 | 🏗️ 架構與系統設計 |
| 產品 / 模型 / API 新功能上線公告 | 🚀 新功能 / 模型發布 |
| 大神個人部落格寫的研究解讀 | 🧠 大神觀點（並在條目中連到原論文） |
| AI 安全漏洞、prompt injection 攻擊研究 | 🛡️ 資安動態 |

同一件事只放一區。模型發布同時附技術報告時，放 🚀，技術報告連結附在同一則。

## 收錄優先順序

1. **頂尖實驗室的研究文章**：Anthropic、OpenAI、Google DeepMind、Meta FAIR 等官方研究頁新發表的文章（通常有部落格版 + 論文版）。
2. **工程團隊技術深度文**：Anthropic Engineering、OpenAI 開發者部落格、Google Research blog 等，講實作細節與經驗（agent 設計、evals、context engineering、訓練與推論優化）。
3. **社群熱門論文**：Hugging Face Daily Papers 當日高票、被大神轉推/撰文討論、或來自主要實驗室的 arXiv 論文。
4. **獨立研究機構**：METR、Epoch AI、Apollo Research、Redwood Research、AI2、Stanford HAI / CRFM 等的報告與研究。

略過：沒有社群關注的一般 arXiv 投稿（每天上千篇，不可能也不必全看）、只換個 benchmark 刷分的增量論文、純行銷的「研究報告」。

## A. 實驗室研究與工程部落格（一手，優先 WebFetch 索引頁）

先 WebFetch 索引頁（token 上限約 3000–5000），從列表直接篩出窗口內的新文章，比關鍵字搜尋可靠。前四個（Anthropic Research、Anthropic Engineering、OpenAI Research、DeepMind）每天必抓，再看 HF Daily Papers（見 B）；其餘與 C 的獨立機構用 1–2 次組合搜尋涵蓋。

要收錄的研究文至少 WebFetch 一次部落格版正文，才寫得出具體發現與數字。

| 來源 | 索引頁 | 備註 |
|---|---|---|
| Anthropic Research | https://www.anthropic.com/research | 可解釋性、對齊、社會影響、經濟研究 |
| Anthropic Engineering | https://www.anthropic.com/engineering | agent、Claude Code、evals 的工程深度文 |
| Transformer Circuits | https://transformer-circuits.pub | Anthropic 可解釋性完整論文（常與 research 文同步發表） |
| Anthropic Alignment Science | https://alignment.anthropic.com | 對齊研究短文與筆記 |
| OpenAI Research | https://openai.com/research/index | 研究文章與論文 |
| Google DeepMind | https://deepmind.google/discover/blog | 研究與模型技術文 |
| Google Research | https://research.google/blog | 廣泛的 ML 研究 |
| Meta AI / FAIR | https://ai.meta.com/blog | 開源模型與研究 |
| Microsoft Research | https://www.microsoft.com/en-us/research/blog | |
| Apple ML Research | https://machinelearning.apple.com | |
| NVIDIA Technical Blog | https://developer.nvidia.com/blog | 訓練 / 推論優化 |
| Thinking Machines Lab | https://thinkingmachines.ai/blog | Connectionism 系列 |
| Hugging Face Blog | https://huggingface.co/blog | 開源模型技術文、訓練實作 |

## B. 論文發現管道

| 來源 | 網址 | 用法 |
|---|---|---|
| Hugging Face Daily Papers | https://huggingface.co/papers | 每日社群投票的熱門論文，看當天與前一天的頁面 |
| arXiv 新投稿 | arxiv.org/list/cs.CL/new、cs.LG、cs.AI | 只用來確認日期與摘要，不從這裡大量撈 |
| alphaXiv / Papers with Code 熱門 | alphaxiv.org | 補充熱門度訊號 |
| 大神轉介 | Simon Willison、Sebastian Raschka、Lilian Weng 等（見 `sources.md`） | 被大神點名的論文代表有實務價值 |

## C. 獨立研究機構

METR（metr.org）、Epoch AI（epoch.ai）、Apollo Research（apolloresearch.ai）、Redwood Research（redwoodresearch.org）、AI2（allenai.org/blog）、Stanford HAI（hai.stanford.edu/news）、BAIR blog（bair.berkeley.edu/blog）。這些更新頻率低，每天抽查 1–2 個即可，或用一次組合搜尋涵蓋。

## 日期判斷（研究類特別容易出錯）

- 研究頁常在發表後被修訂。**以發表日期為準，不是修改日期**：頁面上顯示的日期或 `published_time` meta，而不是 `modified_time`。例如上面的範例文 published 是 2026-04-02、modified 是 2026-09-09，若窗口落在 9/9 也**不能**收錄。
- arXiv 以 v1 的提交日（Submitted）為準；新版本（v2、v3）不算新內容，除非內容有重大更新且被重新討論。
- 舊論文若在窗口內被大神或實驗室重新討論，依 SKILL.md〈時間窗〉的例外處理：收錄的是新討論，並註明原論文日期。

## 摘要寫法

研究文要讓工程師讀得懂、用得上，每則依這個順序：

1. **研究問題**：他們想回答什麼（1 句）
2. **方法 / 關鍵發現**：怎麼做、發現什麼，盡量帶具體數字（1–2 句，數字一定要來自原文）
3. **對工程師的意涵**：這會怎麼影響寫 prompt、設計 agent、選模型或做 evals（1 句）；看不出實務意涵就寫「偏基礎研究」
4. 連結：部落格文為主連結，有論文就附論文連結

只拿到摘要（abstract）沒讀到正文的，要註明「依摘要整理」。

## 查詢範本（{date} 換成實際日期，如 "October 19 2026"）

- `Anthropic research {month year}`、`OpenAI research paper {date}`、`DeepMind paper {date}`
- `interpretability paper {month year}`、`alignment research new paper`
- `AI agent research paper {date}`、`LLM evaluation new paper`
- `Hugging Face daily papers {date}`
- 搜尋工具有分模式時，選較徹底、結果較新的模式。
