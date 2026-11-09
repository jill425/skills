# jill425 模型分配

複製到 `~/.claude/jill425-models.md` 再改。只寫要改的場景，沒寫的照 `dispatch.md`〈模型分配〉的預設。

格式：`場景: 模型 [effort]`，一行一個。
- 模型：`opus`、`sonnet`、`haiku`、`fable`，或 `inherit`（跟 session 同一個）。
- effort（可省）：`low`、`medium`、`high`、`xhigh`、`max`。

場景名稱：`執行（一般）`、`執行（困難）`、`執行（文件）`、`驗收`、`攻擊者 A`、`攻擊者 B`、`設計者 A`、`設計者 B`、`how 探索者`、`how 解說者`、`why 調查者`、`why 彙整者`、`reflect 審視者`、`reflect 彙整者`。

`驗收` 改了之後就固定用那個模型，不再自動挑跟執行者不同的模型。

範例：

```
執行（一般）: opus high
執行（困難）: fable xhigh
驗收: sonnet high
```
