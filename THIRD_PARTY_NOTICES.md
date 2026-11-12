# Third-party notices

本 repo 部分內容改寫自以下 MIT 授權的專案，依授權條款保留其版權聲明。

## pstack

來源：https://github.com/cursor/plugins/tree/main/pstack（作者 Lauren Tan）

| 本 repo | 改寫自 pstack |
|---|---|
| `skills/code-impact` | `blast-radius`、`interrogate`（攻擊與驗證的做法） |
| `skills/code-design` | `architect`（含設計警訊與設計者 brief） |
| 契約〈單的種類〉調查單與效能單的做法 | `runtime-forensics`、`trace-forensics`、`hillclimb` 劇本與 `benchmark-checklist` |
| `skills/code-how` | `how` |
| `skills/code-why` | `why`（含證據強度分級與調查者分工） |
| 契約〈模型分配〉 | `setup-pstack` 的依角色分配模型 |
| `skills/task-reflect` | `reflect`（多視角審視、彙整、核准後才套用） |
| `scripts/log-decision.sh`、契約〈決策紀錄〉 | `show-me-your-work` |
| `skills/rule-enforce` | `correct`、`principle-encode-lessons-in-structure` |
| `skills/project-harness` | `create-verification-skill` |
| `skills/task-multi-run` 的「質疑前提」、bug 類單的找根因方式 | `principle-attack-the-premise`、bug-fix playbook |
| `contract/task-contract.md` 的證據等級 | `blast-radius` |
| `contract/task-contract.md`〈開發原則〉的最小改動、先減再加、改 API 就改完呼叫端、驗證放在邊界、讓型別擋錯、跑幾次結果都一樣、體驗優先、測行為不測實作、做工具不手工 | `principle-laziness-protocol`、`principle-subtract-before-you-add`、`principle-migrate-callers-then-delete-legacy-apis`、`principle-boundary-discipline`、`principle-type-system-discipline`、`principle-make-operations-idempotent`、`principle-experience-first`、`principle-test-behavior-not-implementation`、`principle-build-the-lever`、`principle-model-the-domain`、`principle-minimize-reader-load`、`principle-foundational-thinking`、`principle-separate-before-serializing-shared-state`、`principle-redesign-from-first-principles`、`principle-exhaust-the-design-space`、`principle-outcome-oriented-execution`、`principle-explain-the-number` |

```
MIT License

Copyright (c) 2026 Lauren Tan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
